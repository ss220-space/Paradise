use crate::uuid::statics::{UUID_COUNTER, UUID_STORAGE};
use byondapi::value::ByondValue;

#[byondapi::bind]
fn get_uuid(object: ByondValue) -> eyre::Result<ByondValue> {
    let to_grant = UUID_COUNTER.with(|counter| {
        counter.update(|val| val + 1);
        counter.get()
    });

    UUID_STORAGE.with(|storage| {
        storage.borrow_mut().insert(to_grant, object);
    });

    Ok(ByondValue::try_from(to_grant.to_string())?)
}

#[byondapi::bind]
fn get_by_uuid(key: ByondValue) -> eyre::Result<ByondValue> {
    let key_str = key.get_string()?;
    let key_u32 = key_str.parse::<u32>()?;

    let val = UUID_STORAGE.with(|storage| storage.borrow().get(&key_u32).copied());

    Ok(val.unwrap_or_else(ByondValue::null))
}

#[byondapi::bind]
fn untick_by_uuid(key: ByondValue) -> eyre::Result<ByondValue> {
    let key_str = key.get_string()?;
    let key_u32 = key_str.parse::<u32>()?;

    let val = UUID_STORAGE.with(|storage| storage.borrow_mut().remove(&key_u32));

    Ok(val.unwrap_or_else(ByondValue::null))
}

#[byondapi::bind]
fn get_uuid_counter_value() -> eyre::Result<ByondValue> {
    let val = UUID_COUNTER.with(|counter| counter.get());
    Ok(ByondValue::try_from(val.to_string())?)
}
