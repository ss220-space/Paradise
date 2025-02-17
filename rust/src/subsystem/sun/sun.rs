use super::statics::*;
use byondapi::value::ByondValue;
use rand::Rng;

pub struct Sun {}

impl Sun {
    pub fn initialize() -> eyre::Result<ByondValue> {
        let mut rng = rand::thread_rng();
        let angle = rng.gen_range(0.0..=360.0);
        let mut rate = rng.gen_range(0.5..=2.0);

        if rng.gen_bool(0.5) {
            rate = -rate;
        };

        {
            *RATE.write() = rate;
            *ANGLE.write() = angle;
        };

        Self::setup_solars()?;
        Ok(ByondValue::from(true))
    }

    pub fn update_position() -> eyre::Result<ByondValue> {
        let new_angle = {
            let mut angle = ANGLE.write();
            *angle = (360.0 + *angle + *RATE.read() * 6.0) % 360.0;
            *angle
        };

        let (sin, cos) = new_angle.to_radians().sin_cos();
        let max_abs = sin.abs().max(cos.abs());
        let (dx, dy) = (sin / max_abs, cos / max_abs);

        {
            *DX.write() = dx;
            *DY.write() = dy;
        };

        Self::update_solars()?;
        Ok(ByondValue::from(true))
    }

    pub fn setup_solars() -> eyre::Result<ByondValue> {
        let solars = SOLARS.read();

        solars.iter().for_each(|solar| {
            let _ = solar.call("setup", &[]);
        });

        Ok(ByondValue::from(true))
    }

    pub fn update_solars() -> eyre::Result<ByondValue> {
        let solars = SOLARS.write();

        solars.iter().for_each(|solar| {
            let _ = solar.call("update", &[]);
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
        Ok(ByondValue::from(*DY.read()))
    }

    pub fn get_dx() -> eyre::Result<ByondValue> {
        Ok(ByondValue::from(*DX.read()))
    }

    pub fn get_angle() -> eyre::Result<ByondValue> {
        Ok(ByondValue::from(*ANGLE.read()))
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
