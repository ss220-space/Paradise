use memory_stats::memory_stats;
use meowtonin::{byond_fn, ByondResult, ByondValue, ToByond};

const BYTES_PER_MB: u64 = 1_048_576;

#[byond_fn]
fn process_physical_memory() -> ByondResult<ByondValue> {
    let memory_mb = memory_stats()
        .map(|stats| stats.physical_mem as u64 / BYTES_PER_MB)
        .unwrap_or(0);

    (memory_mb as f32).to_byond()
}

#[byond_fn]
fn process_virtual_memory() -> ByondResult<ByondValue> {
    let memory_mb = memory_stats()
        .map(|stats| stats.virtual_mem as u64 / BYTES_PER_MB)
        .unwrap_or(0);

    (memory_mb as f32).to_byond()
}
