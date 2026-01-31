use dmi::icon::Looping;
use image::RgbaImage;
use ordered_float::OrderedFloat;
use rayon::iter::{IntoParallelRefIterator, ParallelIterator};
use serde::{Deserialize, Serialize};
use tracy_full::zone;

#[derive(Serialize, Deserialize, Clone, Eq, PartialEq, Hash)]
pub struct UniversalIcon {
    pub icon_file: String,
    pub icon_state: String,
    pub dir: Option<u8>,
    pub frame: Option<u32>,
    pub transform: Vec<Transform>,
}

impl std::fmt::Display for UniversalIcon {
    fn fmt(&self, f: &mut std::fmt::Formatter) -> std::fmt::Result {
        write!(
            f,
            "UniversalIcon(icon_file={}, icon_state={}, dir={:?}, frame={:?})",
            self.icon_file, self.icon_state, self.dir, self.frame
        )
    }
}

impl UniversalIcon {
    /// Returns a new UniversalIcon that's a copy of the current one without any transforms
    pub fn to_base(&self) -> Self {
        UniversalIcon {
            icon_file: self.icon_file.to_owned(),
            icon_state: self.icon_state.to_owned(),
            dir: self.dir,
            frame: self.frame,
            transform: Vec::new(),
        }
    }

    /// Gives a list of nested icons within this UniversalIcon. Optionally returns a reference to the self at the start of the list.
    pub fn get_nested_icons(&self, include_self: bool) -> Vec<&UniversalIcon> {
        zone!("get_nested_icons");
        let mut icons: Vec<&UniversalIcon> = Vec::new();
        if include_self {
            icons.push(self);
        }
        for transform in &self.transform {
            if let Transform::BlendIcon { icon, .. } = transform {
                let nested = icon.get_nested_icons(true);
                for icon in nested {
                    icons.push(icon)
                }
            }
        }
        icons
    }
}

#[derive(Serialize, Deserialize, Clone, Eq, PartialEq, Hash)]
#[serde(tag = "type")]
pub enum Transform {
    BlendColor {
        color: String,
        blend_mode: u8,
    },
    BlendIcon {
        icon: UniversalIcon,
        blend_mode: u8,
        x: Option<i32>,
        y: Option<i32>,
    },
    Scale {
        width: u32,
        height: u32,
    },
    Crop {
        x1: i32,
        y1: i32,
        x2: i32,
        y2: i32,
    },
    #[rustfmt::skip]
    MapColors {
        rr: OrderedFloat<f32>, rg: OrderedFloat<f32>, rb: OrderedFloat<f32>, ra: Option<OrderedFloat<f32>>,
        gr: OrderedFloat<f32>, gg: OrderedFloat<f32>, gb: OrderedFloat<f32>, ga: Option<OrderedFloat<f32>>,
        br: OrderedFloat<f32>, bg: OrderedFloat<f32>, bb: OrderedFloat<f32>, ba: Option<OrderedFloat<f32>>,
        ar: Option<OrderedFloat<f32>>, ag: Option<OrderedFloat<f32>>, ab: Option<OrderedFloat<f32>>, aa: Option<OrderedFloat<f32>>,
        r0: Option<OrderedFloat<f32>>, g0: Option<OrderedFloat<f32>>, b0: Option<OrderedFloat<f32>>, a0: Option<OrderedFloat<f32>>,
    },
    Flip {
        dir: u8,
    },
    Turn {
        angle: OrderedFloat<f32>,
    },
    Shift {
        dir: u8,
        offset: i32,
        wrap: u8,
    },
    SwapColor {
        src_color: String,
        dst_color: String,
    },
    DrawBox {
        color: Option<String>,
        x1: i32,
        y1: i32,
        x2: Option<i32>,
        y2: Option<i32>,
    },
}

#[derive(Clone)]
pub struct UniversalIconData {
    pub images: Vec<RgbaImage>,
    pub frames: u32,
    pub dirs: u8,
    pub delay: Option<Vec<f32>>,
    pub loop_flag: Looping,
    pub rewind: bool,
}

impl UniversalIconData {
    pub fn map_cloned_images<F>(&self, do_fn: F) -> Vec<RgbaImage>
    where
        F: Fn(&mut RgbaImage) + Send + Sync,
    {
        self.images
            .par_iter()
            .map(|image| {
                let mut new_image = image.clone();
                do_fn(&mut new_image);
                new_image
            })
            .collect()
    }
}
