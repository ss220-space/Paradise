use super::sun::Sun;
use atomic_float::AtomicF32;
use parking_lot::RwLock;

pub static SUN: Sun = Sun {
    rate: AtomicF32::new(0.0),
    dx: AtomicF32::new(0.0),
    dy: AtomicF32::new(0.0),
    angle: AtomicF32::new(0.0),
    solars: RwLock::new(Vec::new()),
};
