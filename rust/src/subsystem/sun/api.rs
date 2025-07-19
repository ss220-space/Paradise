use super::statics::SUN;
use byondapi::value::ByondValue;

#[byondapi::bind]
pub fn sun_subsystem_initialize() -> eyre::Result<ByondValue> {
    SUN.with(|sun| sun.initialize())
}

#[byondapi::bind]
pub fn sun_subsystem_fire() -> eyre::Result<ByondValue> {
    SUN.with(|sun| sun.update_position())
}

#[byondapi::bind]
pub fn add_solar(solar: ByondValue, solar_uid: ByondValue) -> eyre::Result<ByondValue> {
    SUN.with(|sun| sun.add_solar(solar, solar_uid.get_number()?.to_bits()))
}

#[byondapi::bind]
pub fn remove_solar(solar_uid: ByondValue) -> eyre::Result<ByondValue> {
    SUN.with(|sun| sun.remove_solar(solar_uid.get_number()?.to_bits()))
}

#[byondapi::bind]
pub fn get_sun_dy() -> eyre::Result<ByondValue> {
    SUN.with(|sun| Ok(ByondValue::from(sun.dy.get())))
}

#[byondapi::bind]
pub fn get_sun_dx() -> eyre::Result<ByondValue> {
    SUN.with(|sun| Ok(ByondValue::from(sun.dx.get())))
}

#[byondapi::bind]
pub fn get_sun_angle() -> eyre::Result<ByondValue> {
    SUN.with(|sun| Ok(ByondValue::from(sun.angle.get())))
}

#[byondapi::bind]
pub fn get_solars_length() -> eyre::Result<ByondValue> {
    SUN.with(|sun| Ok(ByondValue::from(sun.solars.borrow().len() as f32)))
}
