use byondapi::value::ByondValue;
use std::sync::RwLock;

pub static RATE: RwLock<f32> = RwLock::new(0.0);
pub static DX: RwLock<f32> = RwLock::new(0.0);
pub static DY: RwLock<f32> = RwLock::new(0.0);
pub static SOLARS: RwLock<Vec<ByondValue>> = RwLock::new(Vec::new());
pub static ANGLE: RwLock<f32> = RwLock::new(0.0);
