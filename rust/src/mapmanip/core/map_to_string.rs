/// Turns spacemandmm map object to string.
pub fn map_to_string(map: &dmmtools::dmm::Map) -> eyre::Result<String> {
    let mut vec = vec![];
    map.to_writer(&mut vec)?;
    let string = String::from_utf8(vec)?;
    Ok(string)
}
