#[allow(dead_code)] // Used depending on feature set
/// Utility for BYOND functions to catch panic unwinds safely and return a Result<String, Error>, as expected.
/// Usage: catch_panic(|| internal_safe_function(arguments))
pub fn catch_panic<F>(f: F) -> eyre::Result<String>
where
    F: FnOnce() -> eyre::Result<String> + std::panic::UnwindSafe,
{
    match std::panic::catch_unwind(f) {
        Ok(o) => o,
        Err(e) => {
            let message: Option<String> = e
                .downcast_ref::<&'static str>()
                .map(|payload| payload.to_string())
                .or_else(|| e.downcast_ref::<String>().cloned());
            Err(eyre::eyre!(message
                .unwrap_or(String::from(
                    "Failed to stringify panic! Check rustg-panic.log!",
                ))
                .to_owned(),))
        }
    }
}
