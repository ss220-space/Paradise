use super::statics::SUN;
use byondapi::value::ByondValue;

#[byondapi::bind]
pub fn sun_subsystem_initialize() -> eyre::Result<ByondValue> {
    SUN.initialize()
}

#[byondapi::bind]
pub fn sun_subsystem_fire() -> eyre::Result<ByondValue> {
    SUN.update_position()
}

#[byondapi::bind]
pub fn get_sun_angle() -> eyre::Result<ByondValue> {
    SUN.get_angle()
}

#[byondapi::bind]
pub fn add_solar(solar: ByondValue) -> eyre::Result<ByondValue> {
    SUN.add_solar(solar)
}

#[byondapi::bind]
pub fn remove_solar(solar: ByondValue) -> eyre::Result<ByondValue> {
    SUN.remove_solar(&solar)
}

#[byondapi::bind]
pub fn get_dy() -> eyre::Result<ByondValue> {
    SUN.get_dy()
}

#[byondapi::bind]
pub fn get_dx() -> eyre::Result<ByondValue> {
    SUN.get_dx()
}

#[byondapi::bind]
pub fn get_solars_length() -> eyre::Result<ByondValue> {
    SUN.get_solars_length()
}
