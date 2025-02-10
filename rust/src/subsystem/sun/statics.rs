use super::sun::Sun;
use std::sync::Mutex;

pub static SUN: Mutex<Sun> = Mutex::new(Sun {
    rate: 0.0,
    dx: 0.0,
    dy: 0.0,
    solars: None,
    angle: 0.0,
});
