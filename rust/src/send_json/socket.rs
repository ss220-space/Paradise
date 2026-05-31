use eyre::{eyre, Result};
use std::io::Write;
use std::time::Duration;

/// Отправляет JSON данные на voicechat сокет.
///
/// На Windows: TCP на 127.0.0.1:27000
/// На Unix/Linux/Mac: Unix domain socket в текущей директории
///
/// Возвращает Ok(()) если успешно отправлено, Err если упало.
pub fn send_to_socket(data: &str) -> Result<()> {
    let timeout = Duration::from_secs(5);

    #[cfg(target_os = "windows")]
    return send_tcp_windows(data, timeout);

    #[cfg(not(target_os = "windows"))]
    return send_unix_socket(data, timeout);
}

#[cfg(target_os = "windows")]
fn send_tcp_windows(data: &str, timeout: Duration) -> Result<()> {
    use std::net::TcpStream;

    let addr = "127.0.0.1:27000";

    let mut stream = TcpStream::connect(addr).map_err(|e| {
        eyre!(
            "Failed to connect to server at {addr}: {e}. \
            Make sure the Node.js server is running."
        )
    })?;

    stream
        .set_write_timeout(Some(timeout))
        .map_err(|e| eyre!("Failed to set socket timeout: {}", e))?;

    stream.write_all(data.as_bytes()).map_err(|e| {
        eyre!(
            "Failed to send JSON data to server: {}. \
            Data size: {} bytes",
            e,
            data.len()
        )
    })?;

    Ok(())
}

#[cfg(not(target_os = "windows"))]
fn send_unix_socket(data: &str, _timeout: Duration) -> Result<()> {
    use std::os::unix::net::UnixStream;

    let socket_path = "byond_node.sock";

    let mut stream = UnixStream::connect(socket_path).map_err(|e| {
        eyre!(
            "Failed to connect to Unix socket at '{}': {}. \
            Make sure the Node.js voicechat server is running.",
            socket_path,
            e
        )
    })?;

    stream.write_all(data.as_bytes()).map_err(|e| {
        eyre!(
            "Failed to send JSON data to voicechat server: {}. \
            Data size: {} bytes",
            e,
            data.len()
        )
    })?;

    Ok(())
}
