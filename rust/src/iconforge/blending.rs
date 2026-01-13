use once_cell::sync::Lazy;
use serde::Serialize;
use std::str::FromStr;

pub static ALPHA_TABLE: Lazy<[u8; 256 * 256]> = Lazy::new(|| {
    let mut table = [0u8; 256 * 256];

    for dst in 0..256 {
        for src in 0..256 {
            let index = dst * 256 + src;
            let value = ((src as f32) * (dst as f32 / 255.0) + 0.5).floor() as i32;
            table[index] = if (0..256).contains(&value) {
                value as u8
            } else {
                0xFF
            };
        }
    }

    table
});

// The numbers correspond to BYOND ICON_X blend modes. https://www.byond.com/docs/ref/#/icon/proc/Blend
#[derive(Clone, Hash, Eq, PartialEq, Serialize)]
#[repr(u8)]
pub enum BlendMode {
    Add = 0,
    Subtract = 1,
    Multiply = 2,
    Overlay = 3,
    And = 4,
    Or = 5,
    Underlay = 6,
}

impl BlendMode {
    pub fn from_u8(blend_mode: &u8) -> eyre::Result<BlendMode> {
        match *blend_mode {
            0 => Ok(BlendMode::Add),
            1 => Ok(BlendMode::Subtract),
            2 => Ok(BlendMode::Multiply),
            3 => Ok(BlendMode::Overlay),
            4 => Ok(BlendMode::And),
            5 => Ok(BlendMode::Or),
            6 => Ok(BlendMode::Underlay),
            _ => Err(eyre::eyre!("blend_mode '{blend_mode}' is not supported!")),
        }
    }

    pub fn blend_u8(&self, color: &[u8], other_color: &[u8]) -> [u8; 4] {
        let (r1, g1, b1, a1) = (color[0], color[1], color[2], color[3]);
        let (r2, g2, b2, a2) = (
            other_color[0],
            other_color[1],
            other_color[2],
            other_color[3],
        );

        let add_channel = |c_src: u8, c_dst: u8| c_src.saturating_add(c_dst);
        let subtract_channel = |c_src: u8, c_dst: u8| c_src.saturating_sub(c_dst);
        let multiply_channel = |c_src: u8, c_dst: u8| ((c_src as u16 * c_dst as u16) / 255) as u8;
        let overlay_channel = |c_src: u8, c_dst: u8, a_src: u8, a_dst: u8| {
            if a_src == 0 {
                c_dst
            } else {
                let delta = (c_dst as i32 - c_src as i32) * a_dst as i32 / 255;
                (c_src as i32 + delta).clamp(0, 255) as u8
            }
        };
        let overlay_alpha = |a_src: u8, a_dst: u8| {
            let a_src = a_src as f32 / 255.0;
            let a_dst = a_dst as f32 / 255.0;
            ((a_src + a_dst * (1.0 - a_src)) * 255.0)
                .round()
                .clamp(0.0, 255.0) as u8
        };

        let alpha_lookup =
            |a_src: u8, a_dst: u8| ALPHA_TABLE[a_dst as usize + (a_src as usize) * 256];

        match self {
            BlendMode::Add | BlendMode::And => [
                add_channel(r1, r2),
                add_channel(g1, g2),
                add_channel(b1, b2),
                alpha_lookup(a1, a2),
            ],
            BlendMode::Subtract => [
                subtract_channel(r1, r2),
                subtract_channel(g1, g2),
                subtract_channel(b1, b2),
                alpha_lookup(a1, a2),
            ],
            BlendMode::Multiply => [
                multiply_channel(r1, r2),
                multiply_channel(g1, g2),
                multiply_channel(b1, b2),
                alpha_lookup(a1, a2),
            ],
            BlendMode::Overlay => [
                overlay_channel(r1, r2, a1, a2),
                overlay_channel(g1, g2, a1, a2),
                overlay_channel(b1, b2, a1, a2),
                overlay_alpha(a1, a2),
            ],
            BlendMode::Or => {
                if a1 == 0 {
                    return [r2, g2, b2, a2];
                }
                if a2 == 0 {
                    return [r1, g1, b1, a1];
                }
                [
                    add_channel(r1, r2),
                    add_channel(g1, g2),
                    add_channel(b1, b2),
                    !ALPHA_TABLE[0x10000usize
                        .wrapping_sub(a1 as usize)
                        .wrapping_sub(a2 as usize * 256)
                        .min(65535)],
                ]
            }
            BlendMode::Underlay => [
                overlay_channel(r2, r1, a2, a1),
                overlay_channel(g2, g1, a2, a1),
                overlay_channel(b2, b1, a2, a1),
                overlay_alpha(a2, a1),
            ],
        }
    }
}

impl FromStr for BlendMode {
    type Err = eyre::Report;

    fn from_str(blend_mode: &str) -> eyre::Result<BlendMode> {
        match blend_mode {
            "add" => Ok(BlendMode::Add),
            "subtract" => Ok(BlendMode::Subtract),
            "multiply" => Ok(BlendMode::Multiply),
            "overlay" => Ok(BlendMode::Overlay),
            "and" => Ok(BlendMode::And),
            "or" => Ok(BlendMode::Or),
            "underlay" => Ok(BlendMode::Underlay),
            _ => Err(eyre::eyre!("blend_mode '{blend_mode}' is not supported!")),
        }
    }
}
