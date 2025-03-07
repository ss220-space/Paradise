use super::statics::*;
use byondapi::{byond_string, value::ByondValue};
use rand::Rng;
use std::sync::atomic::Ordering;

pub struct Sun {}

impl Sun {
    pub fn initialize() -> eyre::Result<ByondValue> {
        let mut rng = rand::thread_rng();
        let angle = rng.gen_range(0.0..=360.0);
        let mut rate = rng.gen_range(0.5..=2.0);

        if rng.gen_bool(0.5) {
            rate = -rate;
        };

        RATE.store(rate, Ordering::Relaxed);
        ANGLE.store(angle, Ordering::Relaxed);

        Self::setup_solars()?;
        Ok(ByondValue::from(true))
    }

    pub fn update_position() -> eyre::Result<ByondValue> {
        let new_angle = Self::calculate_new_angle();

        let (sin, cos) = new_angle.to_radians().sin_cos();
        let max_abs = sin.abs().max(cos.abs());
        let (dx, dy) = (sin / max_abs, cos / max_abs);

        DX.store(dx, Ordering::Relaxed);
        DY.store(dy, Ordering::Relaxed);

        Self::update_solars()?;
        Ok(ByondValue::from(true))
    }

    fn calculate_new_angle() -> f32 {
        let updated_angle =
            (360.0 + ANGLE.load(Ordering::Relaxed) + RATE.load(Ordering::Relaxed) * 6.0) % 360.0;

        ANGLE.store(updated_angle, Ordering::Relaxed);
        updated_angle
    }

    pub fn setup_solars() -> eyre::Result<ByondValue> {
        let solars = SOLARS.read();
        let proc_setup = byond_string!("setup");

        solars.iter().for_each(|solar| {
            let _ = solar.call_id(proc_setup, &[]);
        });

        Ok(ByondValue::from(true))
    }

    pub fn update_solars() -> eyre::Result<ByondValue> {
        let solars = SOLARS.read();
        let proc_update = byond_string!("update");

        solars.iter().for_each(|solar| {
            let _ = solar.call_id(proc_update, &[]);
        });

        Ok(ByondValue::from(true))
    }

    pub fn add_solar(solar: ByondValue) -> eyre::Result<ByondValue> {
        SOLARS.write().push(solar);
        Ok(ByondValue::from(true))
    }

    pub fn remove_solar(solar: ByondValue) -> eyre::Result<ByondValue> {
        SOLARS.write().retain(|element| element != &solar);
        Ok(ByondValue::from(true))
    }

    pub fn get_dy() -> eyre::Result<ByondValue> {
        Ok(ByondValue::from(DY.load(Ordering::Relaxed)))
    }

    pub fn get_dx() -> eyre::Result<ByondValue> {
        Ok(ByondValue::from(DX.load(Ordering::Relaxed)))
    }

    pub fn get_angle() -> eyre::Result<ByondValue> {
        Ok(ByondValue::from(ANGLE.load(Ordering::Relaxed)))
    }

    pub fn get_solars() -> eyre::Result<ByondValue> {
        let mut byond_list = ByondValue::new_list()?;
        let solars = SOLARS.read();

        solars.iter().for_each(|solar| {
            let _ = byond_list.push_list(*solar);
        });

        Ok(byond_list)
    }
}
