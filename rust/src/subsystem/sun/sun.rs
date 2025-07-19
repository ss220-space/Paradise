use byondapi::{byond_string, value::ByondValue};
use rand::Rng;
use std::cell::Cell;
use std::cell::RefCell;
use std::collections::HashMap;

pub struct Sun {
    pub solars: RefCell<HashMap<u32, ByondValue>>,
    pub rate: Cell<f32>,
    pub dx: Cell<f32>,
    pub dy: Cell<f32>,
    pub angle: Cell<f32>,
}

impl Sun {
    pub fn initialize(&self) -> eyre::Result<ByondValue> {
        let mut rng = rand::thread_rng();
        let angle = rng.gen_range(0.0..=360.0);
        let mut rate = rng.gen_range(0.5..=2.0);

        if rng.gen_bool(0.5) {
            rate = -rate;
        };

        self.rate.replace(rate);
        self.angle.replace(angle);

        self.setup_solars()?;
        Ok(ByondValue::null())
    }

    pub fn update_position(&self) -> eyre::Result<ByondValue> {
        let new_angle = self.update_angle();

        let (sin, cos) = new_angle.to_radians().sin_cos();
        let max_abs = sin.abs().max(cos.abs());
        let (dx, dy) = (sin / max_abs, cos / max_abs);

        self.dx.replace(dx);
        self.dy.replace(dy);

        self.update_solars()?;
        Ok(ByondValue::null())
    }

    fn update_angle(&self) -> f32 {
        let updated_angle = (360.0 + self.angle.get() + self.rate.get() * 6.0) % 360.0;

        self.angle.replace(updated_angle);
        updated_angle
    }

    pub fn setup_solars(&self) -> eyre::Result<ByondValue> {
        let proc_setup = byond_string!("setup");

        self.solars.borrow().values().for_each(|solar| {
            let _ = solar.call_id(proc_setup, &[]);
        });

        Ok(ByondValue::null())
    }

    pub fn update_solars(&self) -> eyre::Result<ByondValue> {
        let proc_update = byond_string!("update");

        self.solars.borrow().values().for_each(|solar| {
            let _ = solar.call_id(proc_update, &[]);
        });

        Ok(ByondValue::null())
    }

    #[inline]
    pub fn add_solar(&self, solar: ByondValue, solar_uid: u32) -> eyre::Result<ByondValue> {
        self.solars.borrow_mut().insert(solar_uid, solar);
        Ok(ByondValue::null())
    }

    #[inline]
    pub fn remove_solar(&self, solar_uid: u32) -> eyre::Result<ByondValue> {
        self.solars.borrow_mut().remove(&solar_uid);
        Ok(ByondValue::null())
    }
}
