use meowtonin::{byond_fn, ByondError, ByondResult, ByondValue};

#[byond_fn]
fn exit_byond_process() -> ByondResult<()> {
    std::process::exit(0);
}
