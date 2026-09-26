use meowtonin::{ByondError, ByondResult};
/// Turns spacemandmm map object to string.
pub fn map_to_string(map: &dmmtools::dmm::Map) -> ByondResult<String> {
    let mut vec = vec![];
    map.to_writer(&mut vec).map_err(ByondError::boxed)?;
    let string = String::from_utf8(vec).map_err(ByondError::boxed)?;
    Ok(string)
}
