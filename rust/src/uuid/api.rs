use crate::uuid::statics::UUID_STORAGE;
use byondapi::value::ByondValue;
use uuid::Uuid;

#[byondapi::bind]
fn get_uuid(object: ByondValue) -> eyre::Result<ByondValue> {
    let generated = Uuid::new_v4();

    UUID_STORAGE.with(|storage| {
        storage.borrow_mut().insert(generated, object);
    });

    Ok(ByondValue::try_from(generated.to_string())?)
}

#[byondapi::bind]
fn get_by_uuid(key: ByondValue) -> eyre::Result<ByondValue> {
    let key_str = key.get_string()?;
    let uuid = Uuid::parse_str(&key_str)?;

    let val = UUID_STORAGE.with(|storage| storage.borrow().get(&uuid).copied());

    Ok(val.unwrap_or_else(ByondValue::null))
}

#[byondapi::bind]
fn untick_by_uuid(key: ByondValue) -> eyre::Result<ByondValue> {
    let key_str = key.get_string()?;
    let uuid = Uuid::parse_str(&key_str)?;

    let val = UUID_STORAGE.with(|storage| storage.borrow_mut().remove(&uuid));

    Ok(val.unwrap_or_else(ByondValue::null))
}
