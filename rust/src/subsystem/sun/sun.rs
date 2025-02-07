use byondapi::prelude::*;
use byondapi::value::ByondValue;
use eyre::Result;
use rand::Rng;

#[byondapi::bind]
pub fn sun_subsystem_initialize(mut subsystem: ByondValue) -> eyre::Result<ByondValue> {
    let mut rng = rand::thread_rng();

    let angle: f32 = rng.gen_range(0.0..=360.0);
    let mut rate: f32 = rng.gen_range(50.0..=200.0) / 100.0;

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

    let s = new_angle.to_radians().sin();
    let c = new_angle.to_radians().cos();

    if s.abs() < c.abs() {
        subsystem.write_var("dx", &ByondValue::from(s / c.abs()))?;
        subsystem.write_var("dy", &ByondValue::from(c / c.abs()))?;
    } else {
        subsystem.write_var("dx", &ByondValue::from(s / s.abs()))?;
        subsystem.write_var("dy", &ByondValue::from(c / s.abs()))?;
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
