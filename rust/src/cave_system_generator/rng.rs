use std::time::{SystemTime, UNIX_EPOCH};

pub(super) struct CaveRng {
    state: u64,
}

impl CaveRng {
    pub(super) fn new(seed: u64) -> Self {
        Self {
            state: seed ^ 0x9E37_79B9_7F4A_7C15,
        }
    }

    fn next_u64(&mut self) -> u64 {
        self.state = self.state.wrapping_add(0x9E37_79B9_7F4A_7C15);
        let mut z = self.state;
        z = (z ^ (z >> 30)).wrapping_mul(0xBF58_476D_1CE4_E5B9);
        z = (z ^ (z >> 27)).wrapping_mul(0x94D0_49BB_1331_11EB);
        z ^ (z >> 31)
    }

    fn next_f64(&mut self) -> f64 {
        (self.next_u64() >> 11) as f64 / (1u64 << 53) as f64
    }

    pub(super) fn range(&mut self, low: usize, high: usize) -> usize {
        if high <= low {
            return low;
        }
        low + (self.next_u64() % (high - low) as u64) as usize
    }

    pub(super) fn chance(&mut self, percent: f64) -> bool {
        self.next_f64() < (percent / 100.0).clamp(0.0, 1.0)
    }
}

pub(super) fn random_seed() -> u64 {
    let clock = SystemTime::now()
        .duration_since(UNIX_EPOCH)
        .map(|elapsed| elapsed.as_nanos() as u64)
        .unwrap_or(0x5EED);
    clock ^ ((std::process::id() as u64) << 32)
}
