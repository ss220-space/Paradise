use crate::uuid::statics::UUID_STORAGE;
use base64::prelude::*;
use byondapi::value::ByondValue;
use slotmap::{Key, KeyData};

#[byondapi::bind]
fn get_uuid(object: ByondValue) -> eyre::Result<ByondValue> {
    let val = UUID_STORAGE.with(|storage| storage.borrow_mut().insert(object));
    let key_bytes = val.data().as_ffi().to_le_bytes();
    let encoded_key = BASE64_URL_SAFE_NO_PAD.encode(key_bytes);

    Ok(ByondValue::try_from(encoded_key)?)
}

#[byondapi::bind]
fn get_by_uuid(key: ByondValue) -> eyre::Result<ByondValue> {
    let key_str = key.get_string()?;
    let decoded_bytes = BASE64_URL_SAFE_NO_PAD.decode(key_str)?;

    let key_u64 = u64::from_le_bytes(
        decoded_bytes
            .try_into()
            .map_err(|_| eyre::eyre!("UUID not fit."))?,
    );

    let key = KeyData::from_ffi(key_u64).into();

    let val = UUID_STORAGE.with(|storage| storage.borrow().get(key).copied());

    Ok(val.unwrap_or_else(ByondValue::null))
}

#[byondapi::bind]
fn untick_by_uuid(key: ByondValue) -> eyre::Result<ByondValue> {
    let key_str = key.get_string()?;
    let decoded_bytes = BASE64_URL_SAFE_NO_PAD.decode(key_str)?;

    let key_u64 = u64::from_le_bytes(
        decoded_bytes
            .try_into()
            .map_err(|_| eyre::eyre!("UUID not fit."))?,
    );

    let key = KeyData::from_ffi(key_u64).into();

    let val = UUID_STORAGE.with(|storage| storage.borrow_mut().remove(key));

    Ok(val.unwrap_or_else(ByondValue::null))
}

#[byondapi::bind]
fn get_uuid_counter_value() -> eyre::Result<ByondValue> {
    let len = UUID_STORAGE.with(|storage| storage.borrow().len());
    Ok(ByondValue::try_from(len.to_string())?)
}
