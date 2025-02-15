use super::statics::SUN;
use byondapi::value::ByondValue;

#[byondapi::bind]
pub fn sun_subsystem_initialize() -> eyre::Result<ByondValue> {
    let mut sun = SUN.lock().unwrap();
    sun.initialize()
}

#[byondapi::bind]
pub fn sun_subsystem_fire() -> eyre::Result<ByondValue> {
    let mut sun = SUN.lock().unwrap();
    sun.update_position()
}

#[byondapi::bind]
pub fn get_sun_angle() -> eyre::Result<ByondValue> {
    let sun = SUN.lock().unwrap();
    sun.get_angle()
}

#[byondapi::bind]
pub fn add_solar(solar: ByondValue) -> eyre::Result<ByondValue> {
    let mut sun = SUN.lock().unwrap();
    sun.add_solar(solar)
}

#[byondapi::bind]
pub fn remove_solar(solar: ByondValue) -> eyre::Result<ByondValue> {
    let mut sun = SUN.lock().unwrap();
    sun.remove_solar(solar)
}

#[byondapi::bind]
pub fn get_solars() -> eyre::Result<ByondValue> {
    let sun = SUN.lock().unwrap();
    sun.get_solars()
}

#[byondapi::bind]
pub fn get_dy() -> eyre::Result<ByondValue> {
    let sun = SUN.lock().unwrap();
    sun.get_dy()
}

#[byondapi::bind]
pub fn get_dx() -> eyre::Result<ByondValue> {
    let sun = SUN.lock().unwrap();
    sun.get_dx()
}
