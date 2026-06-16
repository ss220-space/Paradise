use crate::uuid::statics::UUID_STORAGE;
use base64::prelude::*;
use meowtonin::{byond_fn, ByondError, ByondResult, ByondValue, ToByond};
use std::error::Error;

use slotmap::{Key, KeyData};

#[byond_fn]
fn get_uuid(object: ByondValue) -> ByondResult<ByondValue> {
    object.inc_ref();
    let val = UUID_STORAGE.with(|storage| storage.borrow_mut().insert(object));
    let key_bytes = val.data().as_ffi().to_le_bytes();
    let encoded_key = BASE64_URL_SAFE_NO_PAD.encode(key_bytes);
    encoded_key.to_byond()
}

#[byond_fn]
fn get_by_uuid(key: ByondValue) -> ByondResult<ByondValue> {
    let key_str = key.get_string()?;
    let decoded_bytes = BASE64_URL_SAFE_NO_PAD
        .decode(key_str)
        .map_err(ByondError::boxed)?;

    let key_u64 =
        u64::from_le_bytes(decoded_bytes.try_into().map_err(|_| {
            ByondError::Boxed(Box::<dyn Error + Send + Sync>::from("UUID not fit."))
        })?);

    let key = KeyData::from_ffi(key_u64).into();

    let val = UUID_STORAGE.with(|storage| storage.borrow().get(key).cloned());

    Ok(val.unwrap_or(ByondValue::NULL))
}

#[byond_fn]
fn untick_by_uuid(key: ByondValue) -> ByondResult<ByondValue> {
    let key_str = key.get_string()?;
    let decoded_bytes = BASE64_URL_SAFE_NO_PAD
        .decode(key_str)
        .map_err(ByondError::boxed)?;

    let key_u64 =
        u64::from_le_bytes(decoded_bytes.try_into().map_err(|_| {
            ByondError::Boxed(Box::<dyn Error + Send + Sync>::from("UUID not fit."))
        })?);

    let key = KeyData::from_ffi(key_u64).into();

    let val = UUID_STORAGE.with(|storage| storage.borrow_mut().remove(key));

    Ok(val.unwrap_or(ByondValue::NULL))
}

#[byond_fn]
fn get_uuid_counter_value() -> ByondResult<ByondValue> {
    let len = UUID_STORAGE.with(|storage| storage.borrow().len());
    len.to_byond()
}

#[byond_fn]
fn clear_uuid_storage() -> ByondResult<ByondValue> {
    UUID_STORAGE.with(|storage| {
        let mut storage = storage.borrow_mut();
        storage.clear();
    });
    Ok(ByondValue::NULL)
}
