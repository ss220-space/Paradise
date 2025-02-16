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
        }

        {
            let mut rate_lock = RATE
                .write()
                .map_err(|_| eyre::eyre!("Failed to lock RATE"))?;
            let mut angle_lock = ANGLE
                .write()
                .map_err(|_| eyre::eyre!("Failed to lock ANGLE"))?;

            *rate_lock = rate;
            *angle_lock = angle;
        }

        Self::setup_solars()?;
        Ok(ByondValue::from(true))
    }

    pub fn update_position() -> eyre::Result<ByondValue> {
        let new_angle = {
            let angle_read = ANGLE
                .read()
                .map_err(|_| eyre::eyre!("Failed to lock ANGLE"))?;
            let rate_read = RATE
                .read()
                .map_err(|_| eyre::eyre!("Failed to lock RATE"))?;

            (360.0 + *angle_read + *rate_read * 6.0) % 360.0
        };

        {
            let mut angle_write = ANGLE
                .write()
                .map_err(|_| eyre::eyre!("Failed to lock ANGLE"))?;
            *angle_write = new_angle;
        }

        let sin = new_angle.to_radians().sin();
        let cos = new_angle.to_radians().cos();
        let sin_abs = sin.abs();
        let cos_abs = cos.abs();

        let dx = sin / if sin_abs < cos_abs { cos_abs } else { sin_abs };
        let dy = cos / if sin_abs < cos_abs { cos_abs } else { sin_abs };

        {
            let mut dx_write = DX.write().map_err(|_| eyre::eyre!("Failed to lock DX"))?;
            let mut dy_write = DY.write().map_err(|_| eyre::eyre!("Failed to lock DY"))?;

            *dx_write = dx;
            *dy_write = dy;
        }

        Self::update_solars()?;
        Ok(ByondValue::from(true))
    }

    pub fn setup_solars() -> eyre::Result<ByondValue> {
        let solars_lock = SOLARS
            .read()
            .map_err(|_| eyre::eyre!("Failed to lock SOLARS"))?;

        for solar in solars_lock.iter() {
            solar
                .call("setup", &[])
                .map_err(|_| eyre::eyre!("Failed to setup solar"))?;
        }

        Ok(ByondValue::from(true))
    }

    pub fn update_solars() -> eyre::Result<ByondValue> {
        let mut solars_lock = SOLARS
            .write()
            .map_err(|_| eyre::eyre!("Failed to lock SOLARS"))?;

        solars_lock.retain(|solar| {
            solar.read_var("powernet").unwrap_or_default().is_null()
                || solar.call("update", &[]).is_ok()
        });

        Ok(ByondValue::from(true))
    }

    pub fn add_solar(solar: ByondValue) -> eyre::Result<ByondValue> {
        let mut solars_lock = SOLARS
            .write()
            .map_err(|_| eyre::eyre!("Failed to lock SOLARS"))?;

        solars_lock.push(solar);
        Ok(ByondValue::from(true))
    }

    pub fn remove_solar(solar: ByondValue) -> eyre::Result<ByondValue> {
        let mut solars_lock = SOLARS
            .write()
            .map_err(|_| eyre::eyre!("Failed to lock SOLARS"))?;

        solars_lock.retain(|element| element != &solar);
        Ok(ByondValue::from(true))
    }

    pub fn get_dy() -> eyre::Result<ByondValue> {
        let dy_lock = DY.read().map_err(|_| eyre::eyre!("Failed to lock DY"))?;
        Ok(ByondValue::from(*dy_lock))
    }

    pub fn get_dx() -> eyre::Result<ByondValue> {
        let dx_lock = DX.read().map_err(|_| eyre::eyre!("Failed to lock DX"))?;
        Ok(ByondValue::from(*dx_lock))
    }

    pub fn get_angle() -> eyre::Result<ByondValue> {
        let angle_lock = ANGLE
            .read()
            .map_err(|_| eyre::eyre!("Failed to lock ANGLE"))?;

        Ok(ByondValue::from(*angle_lock))
    }

    pub fn get_solars() -> eyre::Result<ByondValue> {
        let solars_lock = SOLARS
            .read()
            .map_err(|_| eyre::eyre!("Failed to lock SOLARS"))?;

        let mut byond_list = ByondValue::new_list()?;

        for solar in &*solars_lock {
            byond_list.push_list(solar.clone())?;
        }

        Ok(byond_list)
    }
}
