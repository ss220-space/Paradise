use super::statics::SUN;
use byondapi::value::ByondValue;
use rand::Rng;

#[byondapi::bind]
pub fn sun_subsystem_initialize() -> eyre::Result<ByondValue> {
    let mut rng = rand::thread_rng();

    let angle: f32 = rng.gen_range(0.0..=360.0);
    let mut rate: f32 = rng.gen_range(0.5..=2.0);

    if rng.gen_bool(0.5) {
        rate = -rate;
    }

    let mut sun = SUN.lock().unwrap();

    sun.solars = Some(ByondValue::new_list()?);
    sun.rate = rate;
    sun.angle = angle;

    let _ = sun.setup_solars();
    Ok(ByondValue::null())
}

#[byondapi::bind]
pub fn sun_subsystem_fire() -> eyre::Result<ByondValue> {
    let mut sun = SUN.lock().unwrap();

    let new_angle: f32 = (360.0 + sun.angle + sun.rate * 6.0) % 360.0;

    sun.angle = new_angle;

    let sin = new_angle.to_radians().sin();
    let cos = new_angle.to_radians().cos();

    let sin_abs = sin.abs();
    let cos_abs = cos.abs();

    if sin_abs < cos_abs {
        sun.dx = sin / cos_abs;
        sun.dy = cos / cos_abs;
    } else {
        sun.dx = sin / sin_abs;
        sun.dy = cos / sin_abs;
    }

    let _ = sun.update_solars();
    Ok(ByondValue::null())
}

#[byondapi::bind]
pub fn get_sun_angle() -> eyre::Result<ByondValue> {
    let sun = SUN.lock().unwrap();
    Ok(sun.get_angle()?)
}

#[byondapi::bind]
pub fn add_solar(solar: ByondValue) -> eyre::Result<ByondValue> {
    let sun = SUN.lock().unwrap();
    Ok(sun.add_solar(solar)?)
}

#[byondapi::bind]
pub fn remove_solar(solar: ByondValue) -> eyre::Result<ByondValue> {
    let sun = SUN.lock().unwrap();
    Ok(sun.remove_solar(solar)?)
}

#[byondapi::bind]
pub fn get_solars() -> eyre::Result<ByondValue> {
    let sun = SUN.lock().unwrap();
    Ok(sun.get_solars()?)
}

#[byondapi::bind]
pub fn get_dy() -> eyre::Result<ByondValue> {
    let sun = SUN.lock().unwrap();
    Ok(sun.get_dy()?)
}

#[byondapi::bind]
pub fn get_dx() -> eyre::Result<ByondValue> {
    let sun = SUN.lock().unwrap();
    Ok(sun.get_dx()?)
}
