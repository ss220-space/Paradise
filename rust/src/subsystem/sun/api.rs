use super::sun::Sun;
use byondapi::value::ByondValue;

#[byondapi::bind]
pub fn sun_subsystem_initialize() -> eyre::Result<ByondValue> {
    Sun::initialize()
}

#[byondapi::bind]
pub fn sun_subsystem_fire() -> eyre::Result<ByondValue> {
    Sun::update_position()
}

#[byondapi::bind]
pub fn get_sun_angle() -> eyre::Result<ByondValue> {
    Sun::get_angle()
}

#[byondapi::bind]
pub fn add_solar(solar: ByondValue) -> eyre::Result<ByondValue> {
    Sun::add_solar(solar)
}

#[byondapi::bind]
pub fn remove_solar(solar: ByondValue) -> eyre::Result<ByondValue> {
    Sun::remove_solar(solar)
}

#[byondapi::bind]
pub fn get_solars() -> eyre::Result<ByondValue> {
    Sun::get_solars()
}

#[byondapi::bind]
pub fn get_dy() -> eyre::Result<ByondValue> {
    Sun::get_dy()
}

#[byondapi::bind]
pub fn get_dx() -> eyre::Result<ByondValue> {
    Sun::get_dx()
}
