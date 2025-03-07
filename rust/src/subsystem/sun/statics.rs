use atomic_float::AtomicF32;
use byondapi::value::ByondValue;
use parking_lot::RwLock;

pub static RATE: AtomicF32 = AtomicF32::new(0.0);
pub static DX: AtomicF32 = AtomicF32::new(0.0);
pub static DY: AtomicF32 = AtomicF32::new(0.0);
pub static ANGLE: AtomicF32 = AtomicF32::new(0.0);
pub static SOLARS: RwLock<Vec<ByondValue>> = RwLock::new(Vec::new());
