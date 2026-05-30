use crate::logging;
use byondapi::prelude::*;
use super::socket::send_to_socket;

/// BYOND API для отправки JSON данных на voicechat сервер.
/// 
/// Возвращает:
/// - 1.0 если успешно отправлено
/// - 0.0 если произошла ошибка (детали в логах)
#[byondapi::bind]
fn voicechat_send_json(json_data: ByondValue) -> eyre::Result<ByondValue> {
    logging::setup_panic_handler();
    
    // Конвертируем ByondValue в обычную Rust строку
    let json_str: String = json_data.try_into()?;
    
    // Пытаемся отправить данные
    match send_to_socket(&json_str) {
        Ok(_) => {
            // Успех — возвращаем 1.0 как в оригинальном C++ коде
            Ok(ByondValue::from(1.0))
        }
        Err(e) => {
            // Ошибка — логируем и возвращаем 0.0
            // eprintln используем как временное решение, позже перейдём на нормальный logger
            eprintln!(
                "[VOICECHAT ERROR] Failed to send JSON data: {}\n\
                 Full error chain: {:#?}",
                e, e
            );
            Ok(ByondValue::from(0.0))
        }
    }
}
