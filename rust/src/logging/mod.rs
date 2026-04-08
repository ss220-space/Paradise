use byondapi::global_call::call_global;
use byondapi::prelude::ByondValue;
use byondapi::threadsync::thread_sync;
use chrono::prelude::Utc;
use uuid::Uuid;

/// Call stack trace dm method with message.
pub(crate) fn dm_call_stack_trace(msg: String) -> eyre::Result<()> {
    call_global("stack_trace", &[ByondValue::new_str(msg)?])?;

    Ok(())
}

/// Panic handler, called on unhandled errors.
/// Writes panic info to a text file, and calls dm stack trace proc as well.
pub(crate) fn setup_panic_handler() {
    std::panic::set_hook(Box::new(|info| {
        let msg = format!("Panic! {info}");
        let msg_copy = msg.clone();
        let _ = std::panic::catch_unwind(|| {
            thread_sync(
                || -> ByondValue {
                    let _ = std::panic::catch_unwind(|| {
                        if let Err(error) = dm_call_stack_trace(msg_copy) {
                            let second_msg = format!("BYOND error \n {:#?}", error);
                            let panic_guid = Uuid::new_v4();
                            let ts = Utc::now().format("%Y%m%d_%H%M%S").to_string();
                            let file_end = format!("{}_{}", ts, panic_guid);

                            // Handle the Result from create_dated_log_path
                            if let Ok(log_path) = create_dated_log_path() {
                                let _ = std::fs::write(
                                    format!(
                                        "{}/rustlibs_dm_trace_failed_{}.txt",
                                        log_path, file_end
                                    ),
                                    second_msg.clone(),
                                );
                            }
                        }
                    });
                    Default::default()
                },
                true,
            );
        });

        // GUID may seem pointless but on the off chance we get 2 panics in the same second its needed
        let _ = std::panic::catch_unwind(|| {
            let panic_guid = get_safe_uuid();
            let ts = get_safe_timestamp();
            let file_end = format!("{}_{}", ts, panic_guid);

            // Handle the Result from create_dated_log_path
            if let Ok(log_path) = create_dated_log_path() {
                let _ = std::fs::write(
                    format!("{}/rustlibs_panic_{}.txt", log_path, file_end),
                    msg.clone(),
                );
            }
        });
    }))
}

fn create_dated_log_path() -> std::io::Result<String> {
    let now = chrono::Utc::now();
    let year = now.format("%Y").to_string();
    let month = now.format("%m-%B").to_string();
    let day = now.format("%d-%A").to_string();
    let log_path = format!("data/logs/{}/{}/{}", year, month, day);
    std::fs::create_dir_all(&log_path)?;
    Ok(log_path)
}

fn get_safe_timestamp() -> String {
    match std::time::SystemTime::now().duration_since(std::time::UNIX_EPOCH) {
        Ok(duration) => duration.as_secs().to_string(),
        Err(_) => "unknown_time".to_string(),
    }
}

fn get_safe_uuid() -> String {
    match std::panic::catch_unwind(|| Uuid::new_v4().to_string()) {
        Ok(uuid) => uuid,
        Err(_) => format!("rand_{}", rand::random::<u64>()),
    }
}
