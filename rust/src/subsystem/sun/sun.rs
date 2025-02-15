use byondapi::value::ByondValue;
use rand::Rng;

pub struct Sun {
    pub rate: f32,
    pub dx: f32,
    pub dy: f32,
    pub solars: Vec<ByondValue>,
    pub angle: f32,
}

impl Sun {
    pub const fn default() -> Self {
        Sun {
            rate: 0.0,
            dx: 0.0,
            dy: 0.0,
            solars: Vec::new(),
            angle: 0.0,
        }
    }

    pub fn initialize(&mut self) -> eyre::Result<ByondValue> {
        let mut rng = rand::thread_rng();

        let angle = rng.gen_range(0.0..=360.0);
        let mut rate = rng.gen_range(0.5..=2.0);

        if rng.gen_bool(0.5) {
            rate = -rate;
        }

        self.rate = rate;
        self.angle = angle;

        self.setup_solars()?;
        Ok(ByondValue::null())
    }

    pub fn update_position(&mut self) -> eyre::Result<ByondValue> {
        let new_angle = (360.0 + self.angle + self.rate * 6.0) % 360.0;

        self.angle = new_angle;

        let sin = new_angle.to_radians().sin();
        let cos = new_angle.to_radians().cos();

        let sin_abs = sin.abs();
        let cos_abs = cos.abs();

        if sin_abs < cos_abs {
            self.dx = sin / cos_abs;
            self.dy = cos / cos_abs;
        } else {
            self.dx = sin / sin_abs;
            self.dy = cos / sin_abs;
        }

        self.update_solars()?;
        Ok(ByondValue::null())
    }

    pub fn setup_solars(&self) -> eyre::Result<ByondValue> {
        for solar in &self.solars {
            solar.call("setup", &[])?;
        }

        Ok(ByondValue::from(true))
    }

    pub fn update_solars(&mut self) -> eyre::Result<ByondValue> {
        self.solars.retain(|solar| {
            solar.read_var("powernet").unwrap_or_default().is_null()
                || solar.call("update", &[]).is_ok()
        });

        Ok(ByondValue::from(true))
    }

    pub fn add_solar(&mut self, solar: ByondValue) -> eyre::Result<ByondValue> {
        if self.solars.contains(&solar) {
            return Ok(ByondValue::from(false));
        }

        self.solars.push(solar);
        Ok(ByondValue::from(true))
    }

    pub fn remove_solar(&mut self, solar: ByondValue) -> eyre::Result<ByondValue> {
        self.solars.retain(|&element| element != solar);
        Ok(ByondValue::from(true))
    }

    pub fn get_dy(&self) -> eyre::Result<ByondValue> {
        Ok(ByondValue::from(self.dy))
    }

    pub fn get_dx(&self) -> eyre::Result<ByondValue> {
        Ok(ByondValue::from(self.dx))
    }

    pub fn get_solars(&self) -> eyre::Result<ByondValue> {
        let mut byond_list = ByondValue::new_list()?;

        for solar in &self.solars {
            byond_list.push_list(solar.clone())?;
        }

        Ok(byond_list)
    }

    pub fn get_angle(&self) -> eyre::Result<ByondValue> {
        Ok(ByondValue::from(self.angle))
    }
}
