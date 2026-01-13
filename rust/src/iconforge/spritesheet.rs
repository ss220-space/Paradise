use super::{
    image_cache,
    universal_icon::{Transform, UniversalIcon, UniversalIconData},
};
use crate::hash::{file_hash, string_hash};
use dashmap::{DashMap, DashSet};
use dmi::icon::{DmiVersion, Icon, IconState};
use image::RgbaImage;
use indexmap::IndexMap;
use once_cell::sync::Lazy;
use rayon::iter::{IntoParallelIterator, IntoParallelRefIterator, ParallelIterator};
use serde::Serialize;
use std::{
    collections::{HashMap, HashSet},
    fs::File,
    hash::BuildHasherDefault,
    sync::{Arc, Mutex, RwLock},
};
use tracy_full::zone;
use twox_hash::XxHash64;

type SpriteJsonMap = HashMap<String, IndexMap<String, UniversalIcon>, BuildHasherDefault<XxHash64>>;
/// This is used to save time decoding 'sprites' a second time between the cache step and the generate step.
static SPRITES_TO_JSON: Lazy<Arc<Mutex<SpriteJsonMap>>> = Lazy::new(|| {
    Arc::new(Mutex::new(HashMap::with_hasher(BuildHasherDefault::<
        XxHash64,
    >::default())))
});

#[derive(Serialize)]
struct SpritesheetResult {
    sizes: Vec<String>,
    sprites: DashMap<String, SpritesheetEntry, BuildHasherDefault<XxHash64>>,
    dmi_hashes: DashMap<String, String>,
    sprites_hash: String,
    error: String,
}

#[derive(Serialize, Clone)]
struct SpritesheetEntry {
    size_id: String,
    position: u32,
}

pub fn generate_spritesheet(
    file_path: &str,
    spritesheet_name: &str,
    sprites: &str,
    hash_icons: bool,
    generate_dmi: bool,
    flatten: bool,
) -> eyre::Result<String> {
    zone!("generate_spritesheet");
    // PNGs cannot be non-flat
    let flatten: bool = !generate_dmi || flatten;
    let error = Arc::new(Mutex::new(Vec::<String>::new()));
    let dmi_hashes = DashMap::<String, String>::new();

    let size_to_icon_objects = Arc::new(Mutex::new(HashMap::<
        String,
        Vec<(&String, &UniversalIcon)>,
    >::new()));
    let sprites_objects =
        DashMap::<String, SpritesheetEntry, BuildHasherDefault<XxHash64>>::with_hasher(
            BuildHasherDefault::<XxHash64>::default(),
        );

    let tree_bases = Arc::new(Mutex::new(HashMap::<
        UniversalIcon,
        Vec<(&String, &UniversalIcon)>,
        BuildHasherDefault<XxHash64>,
    >::with_hasher(
        BuildHasherDefault::<XxHash64>::default()
    )));
    let sprites_hash;
    {
        zone!("compute_sprites_hash");
        sprites_hash = string_hash("xxh64_fixed", sprites)?;
    }
    let sprites_map = match SPRITES_TO_JSON.lock().unwrap().get(&sprites_hash) {
        Some(sprites) => sprites.clone(),
        None => {
            zone!("from_json_sprites"); // byondapi, save us
            serde_json::from_str::<IndexMap<String, UniversalIcon>>(sprites)?
        }
    };

    // Pre-load all the DMIs now.
    // This is much faster than doing it as we go (tested!), because sometimes multiple parallel iterators need the DMI.
    sprites_map.par_iter().for_each(|(sprite_name, icon)| {
        zone!("sprite_to_icons");

        icon.get_nested_icons(true)
            .into_par_iter()
            .for_each(|icon| match image_cache::filepath_to_dmi(&icon.icon_file) {
                Ok(_) => {
                    if hash_icons && !dmi_hashes.contains_key(&icon.icon_file) {
                        zone!("hash_dmi");
                        match file_hash("xxh64_fixed", &icon.icon_file) {
                            Ok(hash) => {
                                zone!("insert_dmi_hash");
                                dmi_hashes.insert(icon.icon_file.clone(), hash);
                            }
                            Err(err) => {
                                error.lock().unwrap().push(err.to_string());
                            }
                        };
                    }
                }
                Err(err) => error.lock().unwrap().push(err.to_string()),
            });

        {
            zone!("map_to_base");
            let base = icon.to_base();
            tree_bases
                .lock()
                .unwrap()
                .entry(base)
                .or_default()
                .push((sprite_name, icon));
        }
    });

    // cache this here so we don't generate the same string 5000 times
    let sprite_name = String::from("N/A, in tree generation stage");

    // Map duplicate transform sets into a tree.
    // This is beneficial in the case where we have the same base image, and the same set of transforms, but change 1 or 2 things at the end.
    // We can greatly reduce the amount of RgbaImages created by first finding these.
    tree_bases
        .lock()
        .unwrap()
        .par_iter()
        .for_each(|(_, icons)| {
            zone!("transform_trees");
            let first_icon = match icons.first() {
                Some((_, icon)) => icon,
                None => {
                    error
                        .lock()
                        .unwrap()
                        .push(String::from("Somehow found no icon for a tree."));
                    return;
                }
            };
            let (base_icon_data, _) =
                match first_icon.get_image_data(&sprite_name, false, false, flatten) {
                    Ok(icon_data) => icon_data,
                    Err(err) => {
                        error.lock().unwrap().push(err.to_string());
                        return;
                    }
                };
            let mut no_transforms = Option::<&UniversalIcon>::None;
            let unique_icons = DashSet::<&UniversalIcon>::new();
            {
                zone!("map_unique");
                icons.iter().for_each(|(_, icon)| {
                    // This will ensure we only map unique transform sets. This also means each UniversalIcon is guaranteed a unique icon_hash
                    // Since all icons share the same 'base'.
                    // Also check to see if the icon is already cached. If so, we can ignore this transform chain.
                    if !image_cache::image_cache_contains(icon) {
                        unique_icons.insert(icon);
                    }
                    if icon.transform.is_empty() {
                        no_transforms = Some(icon);
                    }
                });
            }
            if let Some(entry) = no_transforms {
                image_cache::cache_transformed_images(entry, base_icon_data.clone());
            }
            {
                zone!("transform_all_leaves");
                if let Err(err) = transform_leaves(
                    &unique_icons.into_iter().collect(),
                    base_icon_data.clone(),
                    0,
                    flatten,
                ) {
                    error.lock().unwrap().push(err.to_string());
                }
            }
        });

    // Pick the specific icon states out of the DMI, also generating their transforms, build the spritesheet metadata.
    sprites_map.par_iter().for_each(|sprite_entry| {
        zone!("map_sprite");
        let (sprite_name, icon) = sprite_entry;

        // get RgbaImage, it should already be transformed, so it must be cached.
        let (image_data, _) = match icon.get_image_data(
            sprite_name,
            true,
            true,
            flatten,
        ) {
            Ok(image) => image,
            Err(err) => {
                error.lock().unwrap().push(err.to_string());
                return;
            }
        };

        let first = match image_data.images.first() {
            Some(first) => first,
            None => {
                error.lock().unwrap().push(format!("No images contained in output data for \"{sprite_name}\"! This shouldn't happen..."));
                return;
            }
        };

        {
            zone!("create_game_metadata");
            // Generate the metadata used by the game
            let size_id = format!("{}x{}", first.width(), first.height());
            let icon_position;
            {
                zone!("insert_into_size_map");
                // This scope releases the lock on size_to_icon_objects
                let mut size_map = size_to_icon_objects.lock().unwrap();
                let vec = (*size_map).entry(size_id.to_owned()).or_default();
                icon_position = vec.len() as u32;
                vec.push(sprite_entry);
            }

            {
                zone!("insert_into_sprite_objects");
                sprites_objects.insert(
                    sprite_name.to_owned(),
                    SpritesheetEntry {
                        size_id: size_id.to_owned(),
                        position: icon_position,
                    },
                );
            }
        }
    });

    // all images have been returned now, so continue...
    // Get all the sprites and spew them onto a spritesheet.
    size_to_icon_objects
        .lock()
        .unwrap()
        .par_iter()
        .for_each(|(size_id, sprite_entries)| {
            zone!("join_sprites");
            let file_path = format!(
                "{file_path}{spritesheet_name}_{size_id}.{}",
                if generate_dmi { "dmi" } else { "png" }
            );
            let size_data: Vec<&str> = size_id.split('x').collect();
            let base_width = size_data
                .first()
                .unwrap()
                .to_string()
                .parse::<u32>()
                .unwrap();
            let base_height = size_data
                .last()
                .unwrap()
                .to_string()
                .parse::<u32>()
                .unwrap();

            if generate_dmi {
                let output_states = match create_dmi_output_states(sprite_entries, &sprites_map) {
                    Ok(output_states) => output_states,
                    Err(err) => {
                        error.lock().unwrap().push(err.to_string());
                        return;
                    }
                };
                {
                    zone!("write_spritesheet_dmi");
                    {
                        zone!("create_file");
                        let path = std::path::Path::new(&file_path);
                        if let Err(err) = std::fs::create_dir_all(path.parent().unwrap()) {
                            error.lock().unwrap().push(err.to_string());
                            return;
                        };
                        let mut output_file = match File::create(path) {
                            Ok(file) => file,
                            Err(err) => {
                                error.lock().unwrap().push(err.to_string());
                                return;
                            }
                        };
                        {
                            zone!("save_dmi");
                            let dmi_icon = Icon {
                                version: DmiVersion::default(),
                                width: base_width,
                                height: base_height,
                                states: output_states.lock().unwrap().to_owned(),
                            };
                            if let Err(err) = dmi_icon.save(&mut output_file) {
                                error.lock().unwrap().push(err.to_string());
                            }
                        }
                    }
                }
            } else {
                let final_image = match create_png_image(base_width, base_height, sprite_entries) {
                    Ok(image) => image,
                    Err(err) => {
                        error.lock().unwrap().push(err.to_string());
                        return;
                    }
                };
                {
                    zone!("write_spritesheet_png");
                    let path = std::path::Path::new(&file_path);
                    if let Err(err) = std::fs::create_dir_all(path.parent().unwrap()) {
                        error.lock().unwrap().push(err.to_string());
                        return;
                    };
                    if let Err(err) = final_image.save(file_path) {
                        error.lock().unwrap().push(err.to_string());
                    }
                }
            }
        });

    let sizes: Vec<String> = size_to_icon_objects
        .lock()
        .unwrap()
        .keys()
        .cloned()
        .collect();

    // Collect the game metadata and any errors.
    let returned = SpritesheetResult {
        sizes,
        sprites: sprites_objects,
        dmi_hashes,
        sprites_hash,
        error: error.lock().unwrap().join("\n"),
    };
    Ok(serde_json::to_string::<SpritesheetResult>(&returned)?)
}

fn create_png_image(
    base_width: u32,
    base_height: u32,
    sprite_entries: &Vec<(&String, &UniversalIcon)>,
) -> eyre::Result<RgbaImage> {
    zone!("create_png_image");
    let mut final_image = RgbaImage::new(base_width * sprite_entries.len() as u32, base_height);
    for (idx, sprite_entry) in sprite_entries.iter().enumerate() {
        zone!("join_sprite_png");
        let (sprite_name, icon) = *sprite_entry;
        let image_data = match icon.get_image_data(sprite_name, true, true, true) {
            Ok((image, _)) => image,
            Err(err) => {
                return Err(eyre::eyre!(err.to_string()));
            }
        };
        if image_data.images.len() > 1 {
            return Err(eyre::eyre!("More than one image (non-flattened) sprite {sprite_name} in PNG spritesheet for icon {icon}!"));
        }
        let image = image_data.images.first().unwrap();
        let base_x: u32 = base_width * idx as u32;
        for x in 0..image.width() {
            for y in 0..image.height() {
                final_image.put_pixel(base_x + x, y, *image.get_pixel(x, y))
            }
        }
    }
    Ok(final_image)
}

fn create_dmi_output_states(
    sprite_entries: &Vec<(&String, &UniversalIcon)>,
    sprites_map: &IndexMap<String, UniversalIcon>,
) -> eyre::Result<Arc<Mutex<Vec<IconState>>>> {
    zone!("create_dmi_output_states");
    let output_states = Arc::new(Mutex::new(Vec::<IconState>::with_capacity(
        sprite_entries.len(),
    )));
    let errors = Mutex::new(Vec::<String>::new());
    sprite_entries.par_iter().for_each(|sprite_entry| {
        zone!("create_output_state_dmi");
        let (sprite_name, icon) = *sprite_entry;
        let image_data = match icon.get_image_data(sprite_name, true, true, false) {
            Ok((image, _)) => image,
            Err(err) => {
                errors.lock().unwrap().push(err.to_string());
                return;
            }
        };
        // sometimes DMIs can contain more delays than frames because they retain old data
        let new_delays = Some(
            image_data
                .delay
                .clone()
                .unwrap_or_else(|| vec![1.0; image_data.frames as usize])
                [0..image_data.frames as usize]
                .to_owned(),
        );
        output_states.lock().unwrap().push(IconState {
            name: sprite_name.to_owned(),
            dirs: image_data.dirs,
            frames: image_data.frames,
            delay: new_delays,
            loop_flag: image_data.loop_flag,
            rewind: image_data.rewind,
            movement: false,
            unknown_settings: Option::None,
            hotspot: Option::None,
            images: image_data.images.to_vec(),
        });
    });
    if !errors.lock().unwrap().is_empty() {
        return Err(eyre::eyre!(errors.lock().unwrap().join("\n")));
    }
    // Sort the output states in the relative order of their existence in the input sprites object.
    // This is important for consistency with DM behavior, and it allows the outputted DMI to be used in IconForge's own cache - they will output in the same order between runs.
    // PNGs don't need these because they're only usable in the UI, but these DMI icons are potentially persistent (they may be used at compile time!!)
    output_states
        .lock()
        .unwrap()
        .sort_unstable_by_key(|state| sprites_map.get_index_of(&state.name).unwrap_or(1000));
    Ok(output_states)
}

/// Given an array of 'transform arrays' onto from a shared UniversalIcon base,
/// recursively applies transforms in a tree structure. Maximum transform depth is 128.
fn transform_leaves(
    icons: &Vec<&UniversalIcon>,
    image_data: Arc<UniversalIconData>,
    depth: u8,
    flatten: bool,
) -> eyre::Result<()> {
    zone!("transform_leaf");
    if depth > 128 {
        return Err(eyre::eyre!(
            "Transform depth exceeded 128. https://www.youtube.com/watch?v=CUjrySBwi5Q",
        ));
    }
    let next_transforms = DashMap::<Transform, Vec<&UniversalIcon>>::new();
    let errors = Mutex::new(Vec::<String>::new());

    {
        zone!("get_next_transforms");
        icons.par_iter().for_each(|icon| {
            zone!("collect_icon_transforms");
            if let Some(transform) = icon.transform.get(depth as usize) {
                next_transforms
                    .entry(transform.clone())
                    .or_default()
                    .push(icon);
            }
        });
    }

    {
        zone!("do_next_transforms");
        next_transforms
            .into_par_iter()
            .for_each(|(transform, mut associated_icons)| {
                let altered_image_data = match transform.apply(image_data.clone(), flatten) {
                    Ok(data) => Arc::new(data),
                    Err(err) => {
                        errors.lock().unwrap().push(err.to_string());
                        return;
                    }
                };
                {
                    zone!("filter_associated_icons");
                    associated_icons
                        .clone()
                        .into_iter()
                        .enumerate()
                        .for_each(|(idx, icon)| {
                            if icon.transform.len() as u8 == depth + 1
                                && *icon.transform.last().unwrap() == transform
                            {
                                associated_icons.swap_remove(idx);
                                image_cache::cache_transformed_images(
                                    icon,
                                    altered_image_data.clone(),
                                );
                            }
                        });
                }
                if let Err(err) = transform_leaves(
                    &associated_icons,
                    altered_image_data.clone(),
                    depth + 1,
                    flatten,
                ) {
                    errors.lock().unwrap().push(err.to_string());
                }
            });
    }

    if !errors.lock().unwrap().is_empty() {
        return Err(eyre::eyre!(errors.lock().unwrap().join("\n")));
    }
    Ok(())
}

#[derive(Serialize)]
struct CacheResult {
    result: String,
    fail_reason: String,
}

pub fn cache_valid(
    input_hash: &str,
    dmi_hashes_in: &str,
    sprites_in: &str,
) -> eyre::Result<String> {
    zone!("cache_valid");
    let sprites_hash = string_hash("xxh64_fixed", sprites_in)?;
    if sprites_hash != input_hash {
        return Ok(serde_json::to_string::<CacheResult>(&CacheResult {
            result: String::from("0"),
            fail_reason: String::from("Input hash did not match."),
        })?);
    }
    let dmi_hashes: DashMap<String, String>;
    {
        zone!("from_json_hashes");
        dmi_hashes = serde_json::from_str::<DashMap<String, String>>(dmi_hashes_in)?;
    }
    let mut sprites_json: std::sync::MutexGuard<
        '_,
        HashMap<String, IndexMap<String, UniversalIcon>, BuildHasherDefault<XxHash64>>,
    > = SPRITES_TO_JSON.lock().unwrap();
    let sprites = match sprites_json.get(&sprites_hash) {
        Some(sprites) => sprites,
        None => {
            zone!("from_json_sprites");
            {
                sprites_json.insert(
                    sprites_hash.clone(),
                    serde_json::from_str::<IndexMap<String, UniversalIcon>>(sprites_in)?,
                );
            }
            sprites_json.get(&sprites_hash).unwrap()
        }
    };

    let dmis: HashSet<String>;

    {
        zone!("collect_dmis");
        dmis = sprites
            .par_iter()
            .flat_map(|(_, icon)| {
                icon.get_nested_icons(true)
                    .into_iter()
                    .map(|icon| icon.icon_file.clone())
                    .collect::<HashSet<String>>()
            })
            .collect();
    }

    drop(sprites_json);

    if dmis.len() > dmi_hashes.len() {
        return Ok(serde_json::to_string::<CacheResult>(&CacheResult {
            result: String::from("0"),
            fail_reason: format!("Input hash matched, but more DMIs exist than DMI hashes provided ({} DMIs, {} DMI hashes).", dmis.len(), dmi_hashes.len()),
        })?);
    }

    let fail_reason: Arc<RwLock<Option<String>>> = Arc::new(RwLock::new(None));
    {
        zone!("check_dmis");
        dmis.into_par_iter().for_each(|dmi_path| {
            zone!("check_dmi");
            if fail_reason.read().unwrap().is_some() {
                return;
            }
            match dmi_hashes.get(&dmi_path) {
                Some(hash) => {
                    zone!("hash_dmi");
                    match file_hash("xxh64_fixed", &dmi_path) {
                        Ok(new_hash) => {
                            zone!("check_match");
                            if new_hash != *hash {
                                if fail_reason.read().unwrap().is_some() {
                                    return;
                                }
                                *fail_reason.write().unwrap() = Some(format!("Input hash matched, but dmi_hash was invalid DMI: dmi_path (stored hash: {}, new hash: {new_hash})", hash.clone()));
                            }
                        },
                        Err(err) => {
                            if fail_reason.read().unwrap().is_some() {
                                return;
                            }
                            *fail_reason.write().unwrap() = Some(format!("ERROR: Error while hashing dmi_path '{dmi_path}': {err}"));
                        }
                    }
                }
                None => {
                    if fail_reason.read().unwrap().is_some() {
                        return;
                    }
                    *fail_reason.write().unwrap() = Some(format!("Input hash matched, but no dmi_hash existed for DMI: '{dmi_path}'"));
                }
            }
        });
    }
    if let Some(err) = fail_reason.read().unwrap().clone() {
        return Ok(serde_json::to_string::<CacheResult>(&CacheResult {
            result: String::from("0"),
            fail_reason: err,
        })?);
    }
    Ok(serde_json::to_string::<CacheResult>(&CacheResult {
        result: String::from("1"),
        fail_reason: String::from(""),
    })?)
}
