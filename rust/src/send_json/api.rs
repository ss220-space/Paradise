use super::socket::send_to_socket;
use crate::logging;
use byondapi::value::ByondValue;

/// BYOND API для отправки JSON данных на сервер.
///
/// Возвращает:
/// - 1.0 если успешно отправлено
/// - 0.0 если произошла ошибка (детали в логах)
#[byondapi::bind]
fn send_json(json_data: ByondValue) -> eyre::Result<ByondValue> {
    logging::setup_panic_handler();

    let json_str: String = json_data.try_into()?;

    match send_to_socket(&json_str) {
        Ok(_) => Ok(ByondValue::from(1.0)),
        Err(e) => Err(eyre::eyre!(format!(
            "Failed to send JSON data: {e}\n Full error chain: {e:#?}"
        ))),
    }
}
