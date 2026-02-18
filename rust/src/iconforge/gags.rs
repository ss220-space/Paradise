use super::{blending, icon_operations, image_cache::filepath_to_dmi};
use dashmap::DashMap;
use dmi::icon::{DmiVersion, Icon, IconState};
use image::RgbaImage;
use once_cell::sync::Lazy;
use rayon::iter::{IntoParallelRefIterator, ParallelIterator};
use serde::{Deserialize, Serialize};
use std::{
    collections::HashMap,
    fs::File,
    str::FromStr,
    sync::{Arc, Mutex},
};
use tracy_full::zone;

type GAGSConfigEntry = Vec<GAGSLayerGroupOption>;

#[derive(Serialize, Deserialize, Clone)]
#[serde(untagged)]
enum GAGSLayerGroupOption {
    GAGSLayer(GAGSLayer),
    GAGSLayerGroup(Vec<GAGSLayerGroupOption>),
}

#[derive(Serialize, Deserialize, Clone)]
#[serde(untagged)]
enum GAGSColorID {
    GAGSColorStatic(String),
    GAGSColorIndex(u8),
}

#[derive(Serialize, Deserialize, Clone)]
#[serde(tag = "type", rename_all = "snake_case")]
enum GAGSLayer {
    IconState {
        icon_state: String,
        blend_mode: String,
        #[serde(default)]
        color_ids: Vec<GAGSColorID>,
    },
    Reference {
        reference_type: String,
        #[serde(default)]
        icon_state: String,
        blend_mode: String,
        #[serde(default)]
        color_ids: Vec<GAGSColorID>,
    },
    ColorMatrix {
        blend_mode: String,
        color_matrix: [[f32; 4]; 5],
    },
}

impl GAGSLayer {
    fn get_blendmode_str(&self) -> &String {
        match self {
            GAGSLayer::IconState {
                icon_state: _,
                blend_mode,
                color_ids: _,
            } => blend_mode,
            GAGSLayer::Reference {
                reference_type: _,
                icon_state: _,
                blend_mode,
                color_ids: _,
            } => blend_mode,
            GAGSLayer::ColorMatrix {
                blend_mode,
                color_matrix: _,
            } => blend_mode,
        }
    }

    fn get_blendmode(&self) -> eyre::Result<blending::BlendMode> {
        blending::BlendMode::from_str(self.get_blendmode_str().as_str())
    }
}

type GAGSConfig = HashMap<String, GAGSConfigEntry>;

struct GAGSData {
    config: GAGSConfig,
    config_path: String,
    config_icon: Arc<Icon>,
}

static GAGS_CACHE: Lazy<DashMap<String, GAGSData>> = Lazy::new(DashMap::new);

/// Loads a GAGS config and the requested DMIs into memory for use by iconforge_gags()
pub fn load_gags_config(
    config_path: &str,
    config_json: &str,
    config_icon_path: &str,
) -> eyre::Result<String> {
    zone!("load_gags_config");
    let gags_config: GAGSConfig;
    {
        zone!("gags_from_json");
        gags_config = serde_json::from_str::<GAGSConfig>(config_json)?;
    }
    let icon_data = match filepath_to_dmi(config_icon_path) {
        Ok(data) => data,
        Err(err) => {
            return Err(eyre::eyre!(err));
        }
    };
    {
        zone!("gags_insert_config");
        GAGS_CACHE.insert(
            config_path.to_owned(),
            GAGSData {
                config: gags_config,
                config_path: config_path.to_owned(),
                config_icon: icon_data,
            },
        );
    }
    Ok(String::from("OK"))
}

/// Given an config path and a list of color_ids, outputs a dmi at output_dmi_path with the config's states.
pub fn gags(config_path: &str, colors: &str, output_dmi_path: &str) -> eyre::Result<String> {
    zone!("gags");
    let gags_data = match GAGS_CACHE.get(config_path) {
        Some(config) => config,
        None => {
            return Err(eyre::eyre!(
                "Provided config_path {config_path} has not been loaded by iconforge_load_gags_config!"
            ));
        }
    };

    let colors_vec = colors
        .split('#')
        .map(|x| String::from("#") + x)
        .filter(|x| x != "#")
        .collect::<Vec<String>>();
    let errors = Arc::new(Mutex::new(Vec::<String>::new()));

    let output_states = Arc::new(Mutex::new(Vec::<IconState>::new()));
    gags_data.config.par_iter().for_each(|(icon_state_name, layer_groups)| {
        zone!("gags_create_icon_state");
        let mut first_matched_state: Option<IconState> = None;
        let mut last_matched_state: Option<IconState> = None;
        let transformed_images = match generate_layer_groups_for_iconstate(icon_state_name, &colors_vec, layer_groups, &gags_data, None, &mut first_matched_state, &mut last_matched_state) {
            Ok(images) => images,
            Err(err) => {
                errors.lock().unwrap().push(err.to_string());
                return;
            }
        };
        let icon_state = match first_matched_state {
            Some(state) => state,
            None => {
                errors.lock().unwrap().push(format!("GAGS state {icon_state_name} for GAGS config {config_path} had no matching icon_states in any layers!"));
                return;
            }
        };

        {
            zone!("gags_insert_icon_state");
            output_states.lock().unwrap().push(IconState {
                name: icon_state_name.to_owned(),
                dirs: icon_state.dirs,
                frames: icon_state.frames,
                delay: icon_state.delay.to_owned(),
                loop_flag: icon_state.loop_flag,
                rewind: icon_state.rewind,
                movement: icon_state.movement,
                unknown_settings: icon_state.unknown_settings.to_owned(),
                hotspot: icon_state.hotspot,
                images: transformed_images,
            });
        }
    });

    let errors_unlocked = errors.lock().unwrap();
    if !errors_unlocked.is_empty() {
        return Err(eyre::eyre!(errors_unlocked.join("\n")));
    }

    {
        zone!("gags_sort_states");
        // This is important, because it allows GAGS icons to be included inside of caches - they will output in the same order between runs.
        output_states
            .lock()
            .unwrap()
            .sort_unstable_by(|state1, state2| state1.name.cmp(&state2.name))
    }

    {
        zone!("gags_write_dmi");
        let path = std::path::Path::new(output_dmi_path);
        std::fs::create_dir_all(path.parent().unwrap())?;
        let mut output_file = File::create(path)?;

        if let Err(err) = (Icon {
            version: DmiVersion::default(),
            width: gags_data.config_icon.width,
            height: gags_data.config_icon.height,
            states: output_states.lock().unwrap().to_owned(),
        }
        .save(&mut output_file))
        {
            return Err(eyre::eyre!("Error during icon saving: {err}"));
        }
    }

    Ok(String::from("OK"))
}

/// Version of gags() for use by the reference layer type that acts in memory
fn gags_internal(
    config_path: &str,
    colors_vec: &Vec<String>,
    icon_state: &String,
    last_external_images: Option<Vec<RgbaImage>>,
    first_matched_state: &mut Option<IconState>,
    last_matched_state: &mut Option<IconState>,
) -> eyre::Result<Vec<RgbaImage>> {
    zone!("gags_internal");
    let gags_data = match GAGS_CACHE.get(config_path) {
        Some(config) => config,
        None => {
            return Err(eyre::eyre!("Provided config_path {config_path} has not been loaded by iconforge_load_gags_config (from gags_internal)!"));
        }
    };

    let layer_groups = match gags_data.config.get(icon_state) {
        Some(data) => data,
        None => {
            return Err(eyre::eyre!("Provided config_path {config_path} did not contain requested icon_state {icon_state} for reference type."));
        }
    };
    {
        zone!("gags_create_icon_state");
        let mut first_matched_state_internal: Option<IconState> = None;
        let mut last_matched_state_internal: Option<IconState> = None;
        let transformed_images = match generate_layer_groups_for_iconstate(
            icon_state,
            colors_vec,
            layer_groups,
            &gags_data,
            last_external_images,
            &mut first_matched_state_internal,
            &mut last_matched_state_internal,
        ) {
            Ok(images) => images,
            Err(err) => {
                return Err(eyre::eyre!(err));
            }
        };
        {
            zone!("update_first_matched_state");
            if first_matched_state.is_none() && first_matched_state_internal.is_some() {
                *first_matched_state = first_matched_state_internal;
            }
            *last_matched_state = last_matched_state_internal;
        }
        Ok(transformed_images)
    }
}

/// Recursive function that parses out GAGS configs into layer groups.
fn generate_layer_groups_for_iconstate(
    state_name: &str,
    colors: &Vec<String>,
    layer_groups: &Vec<GAGSLayerGroupOption>,
    gags_data: &GAGSData,
    last_external_images: Option<Vec<RgbaImage>>,
    first_matched_state: &mut Option<IconState>,
    last_matched_state: &mut Option<IconState>,
) -> eyre::Result<Vec<RgbaImage>> {
    zone!("generate_layer_groups_for_iconstate");
    let mut new_images: Option<Vec<RgbaImage>> = None;
    for option in layer_groups {
        zone!("process_gags_layergroup_option");
        let (layer_images, blend_mode_result) = match option {
            GAGSLayerGroupOption::GAGSLayer(layer) => (
                generate_layer_for_iconstate(
                    state_name,
                    colors,
                    layer,
                    gags_data,
                    new_images.clone().or(last_external_images.clone()),
                    first_matched_state,
                    last_matched_state,
                )?,
                layer.get_blendmode(),
            ),
            GAGSLayerGroupOption::GAGSLayerGroup(layers) => {
                if layers.is_empty() {
                    return Err(eyre::eyre!(
                        "Empty layer group provided to GAGS state {state_name} for GAGS config {} !",
                        gags_data.config_path
                    ));
                }
                (
                    generate_layer_groups_for_iconstate(
                        state_name,
                        colors,
                        layers,
                        gags_data,
                        new_images.clone().or(last_external_images.clone()),
                        first_matched_state,
                        last_matched_state,
                    )?,
                    match layers.first().unwrap() {
                        GAGSLayerGroupOption::GAGSLayer(layer) => layer.get_blendmode(),
                        GAGSLayerGroupOption::GAGSLayerGroup(_) => {
                            return Err(eyre::eyre!("Layer group began with another layer group in GAGS state {state_name} for GAGS config {} !", gags_data.config_path));
                        }
                    },
                )
            }
        };

        let blend_mode = blend_mode_result?;
        new_images = match new_images {
            Some(images) => Some(icon_operations::blend_images_other(
                images,
                layer_images,
                &blend_mode,
                first_matched_state,
                last_matched_state,
            )?),
            None => Some(layer_images),
        }
    }
    match new_images {
        Some(images) => Ok(images),
        None => Err(eyre::eyre!("No image found for GAGS state {state_name}")),
    }
}

/// Generates a specific layer.
fn generate_layer_for_iconstate(
    state_name: &str,
    colors: &[String],
    layer: &GAGSLayer,
    gags_data: &GAGSData,
    new_images: Option<Vec<RgbaImage>>,
    first_matched_state: &mut Option<IconState>,
    last_matched_state: &mut Option<IconState>,
) -> eyre::Result<Vec<RgbaImage>> {
    zone!("generate_layer_for_iconstate");
    let images_result: Option<Vec<RgbaImage>> = match layer {
        GAGSLayer::IconState {
            icon_state,
            blend_mode: _,
            color_ids,
        } => {
            zone!("gags_layer_type_icon_state");
            let icon_state: &IconState = match gags_data
                .config_icon
                .states
                .iter()
                .find(|state| state.name == *icon_state)
            {
                Some(state) => state,
                None => {
                    return Err(eyre::eyre!(
                        "Invalid icon_state {state_name} in layer provided for GAGS config {}",
                        gags_data.config_path
                    ));
                }
            };

            if first_matched_state.is_none() {
                *first_matched_state = Some(icon_state.clone());
            }

            *last_matched_state = Some(icon_state.clone());

            let images = icon_state.images.clone();
            if !color_ids.is_empty() {
                // silly BYOND, indexes from 1! Also, for some reason this is an array despite only ever having one value. Thanks TG :)
                let actual_color = match color_ids.first().unwrap() {
                    GAGSColorID::GAGSColorIndex(idx) => colors.get(*idx as usize - 1).unwrap(),
                    GAGSColorID::GAGSColorStatic(color) => color,
                };
                let rgba = icon_operations::hex_to_rgba(actual_color)?;
                return Ok(map_cloned_images(&images, |image| {
                    icon_operations::blend_color(image, rgba, &blending::BlendMode::Multiply)
                }));
            } else {
                return Ok(images); // this will get blended by the layergroup.
            }
        }
        GAGSLayer::Reference {
            reference_type,
            icon_state,
            blend_mode: _,
            color_ids,
        } => {
            zone!("gags_layer_type_reference");
            let mut colors_in: Vec<String> = colors.to_owned();
            if !color_ids.is_empty() {
                colors_in = color_ids
                    .iter()
                    .map(|color| match color {
                        GAGSColorID::GAGSColorIndex(idx) => {
                            colors.get(*idx as usize - 1).unwrap().clone()
                        }
                        GAGSColorID::GAGSColorStatic(color) => color.clone(),
                    })
                    .collect();
            }
            Some(gags_internal(
                reference_type,
                &colors_in,
                icon_state,
                new_images,
                first_matched_state,
                last_matched_state,
            )?)
        }
        GAGSLayer::ColorMatrix {
            blend_mode: _,
            color_matrix,
        } => last_matched_state.as_ref().map(|o| {
            map_cloned_images(&o.images.clone(), |image| {
                icon_operations::map_colors(
                    image,
                    color_matrix[0][0],
                    color_matrix[0][1],
                    color_matrix[0][2],
                    Some(color_matrix[0][3]),
                    color_matrix[1][0],
                    color_matrix[1][1],
                    color_matrix[1][2],
                    Some(color_matrix[1][3]),
                    color_matrix[2][0],
                    color_matrix[2][1],
                    color_matrix[2][2],
                    Some(color_matrix[2][3]),
                    Some(color_matrix[3][0]),
                    Some(color_matrix[3][1]),
                    Some(color_matrix[3][2]),
                    Some(color_matrix[3][3]),
                    Some(color_matrix[4][0]),
                    Some(color_matrix[4][1]),
                    Some(color_matrix[4][2]),
                    Some(color_matrix[4][3]),
                )
            })
        }),
    };

    match images_result {
        Some(images) => Ok(images),
        None => Err(eyre::eyre!(
            "No images found for GAGS state {state_name} for GAGS config {} !",
            gags_data.config_path
        )),
    }
}

pub fn map_cloned_images<F>(images: &Vec<RgbaImage>, do_fn: F) -> Vec<RgbaImage>
where
    F: Fn(&mut RgbaImage) + Send + Sync,
{
    images
        .par_iter()
        .map(|image| {
            let mut new_image = image.clone();
            do_fn(&mut new_image);
            new_image
        })
        .collect()
}
