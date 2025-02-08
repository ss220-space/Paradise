use byondapi::value::ByondValue;
use eyre::Result;
use rand::Rng;

#[byondapi::bind]
pub fn sun_subsystem_initialize(mut subsystem: ByondValue) -> eyre::Result<ByondValue> {
    let mut rng = rand::thread_rng();

    let angle: f32 = rng.gen_range(0.0..=360.0);
    let mut rate: f32 = rng.gen_range(0.5..=2.0);

    if rng.gen_bool(0.5) {
        rate = -rate;
    }

    let solars = subsystem.read_var("solars")?;

    for solar in solars.get_list_values()? {
        solar.call("setup", &[])?;
    }

    subsystem.write_var("angle", &ByondValue::from(angle))?;
    subsystem.write_var("rate", &ByondValue::from(rate))?;

    Ok(ByondValue::null())
}

#[byondapi::bind]
pub fn sun_subsystem_fire(mut subsystem: ByondValue) -> eyre::Result<ByondValue> {
    let angle = subsystem.read_var("angle")?.get_number()?;
    let rate = subsystem.read_var("rate")?.get_number()?;
    let new_angle = (360.0 + angle + rate * 6.0) % 360.0;

    subsystem.write_var("angle", &ByondValue::from(new_angle))?;

    let sin = new_angle.to_radians().sin();
    let cos = new_angle.to_radians().cos();

    let sin_abs = sin.abs();
    let cos_abs = cos.abs();

    if sin_abs < cos_abs {
        subsystem.write_var("dx", &ByondValue::from(sin / cos_abs))?;
        subsystem.write_var("dy", &ByondValue::from(cos / cos_abs))?;
    } else {
        subsystem.write_var("dx", &ByondValue::from(sin / sin_abs))?;
        subsystem.write_var("dy", &ByondValue::from(cos / sin_abs))?;
    }

    let solars = subsystem.read_var("solars")?;

    for solar in solars.get_list_values()? {
        if solar.read_var("powernet")?.is_null() {
            solars.call("Remove", &[solar])?;
            continue;
        }
        solar.call("update", &[])?;
    }
    Ok(ByondValue::null())
}
