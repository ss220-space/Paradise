use atomic_float::AtomicF32;
use byondapi::{byond_string, value::ByondValue};
use parking_lot::RwLock;
use rand::Rng;
use std::sync::atomic::Ordering;

pub struct Sun {
    pub rate: AtomicF32,
    pub dx: AtomicF32,
    pub dy: AtomicF32,
    pub angle: AtomicF32,
    pub solars: RwLock<Vec<ByondValue>>,
}

impl Sun {
    pub fn initialize(&self) -> eyre::Result<ByondValue> {
        let mut rng = rand::thread_rng();
        let angle = rng.gen_range(0.0..=360.0);
        let mut rate = rng.gen_range(0.5..=2.0);

        if rng.gen_bool(0.5) {
            rate = -rate;
        };

        self.rate.store(rate, Ordering::Relaxed);
        self.angle.store(angle, Ordering::Relaxed);

        self.setup_solars()?;
        Ok(ByondValue::from(true))
    }

    pub fn update_position(&self) -> eyre::Result<ByondValue> {
        let new_angle = self.update_angle();

        let (sin, cos) = new_angle.to_radians().sin_cos();
        let max_abs = sin.abs().max(cos.abs());
        let (dx, dy) = (sin / max_abs, cos / max_abs);

        self.dx.store(dx, Ordering::Relaxed);
        self.dy.store(dy, Ordering::Relaxed);

        self.update_solars()?;
        Ok(ByondValue::from(true))
    }

    fn update_angle(&self) -> f32 {
        let updated_angle =
            (360.0 + self.angle.load(Ordering::Relaxed) + self.rate.load(Ordering::Relaxed) * 6.0)
                % 360.0;

        self.angle.store(updated_angle, Ordering::Relaxed);
        updated_angle
    }

    pub fn setup_solars(&self) -> eyre::Result<ByondValue> {
        let solars = self.solars.read();
        let proc_setup = byond_string!("setup");

        solars.iter().for_each(|solar| {
            let _ = solar.call_id(proc_setup, &[]);
        });

        Ok(ByondValue::from(true))
    }

    pub fn update_solars(&self) -> eyre::Result<ByondValue> {
        let solars = self.solars.read();
        let proc_update = byond_string!("update");

        solars.iter().for_each(|solar| {
            let _ = solar.call_id(proc_update, &[]);
        });

        Ok(ByondValue::from(true))
    }

    pub fn add_solar(&self, solar: ByondValue) -> eyre::Result<ByondValue> {
        self.solars.write().push(solar);
        Ok(ByondValue::from(true))
    }

    pub fn remove_solar(&self, solar: &ByondValue) -> eyre::Result<ByondValue> {
        self.solars.write().retain(|element| element != solar);
        Ok(ByondValue::from(true))
    }

    pub fn get_dy(&self) -> eyre::Result<ByondValue> {
        Ok(ByondValue::from(self.dy.load(Ordering::Relaxed)))
    }

    pub fn get_dx(&self) -> eyre::Result<ByondValue> {
        Ok(ByondValue::from(self.dx.load(Ordering::Relaxed)))
    }

    pub fn get_angle(&self) -> eyre::Result<ByondValue> {
        Ok(ByondValue::from(self.angle.load(Ordering::Relaxed)))
    }

    pub fn get_solars_length(&self) -> eyre::Result<ByondValue> {
        Ok(ByondValue::from(self.solars.read().len() as f32))
    }
}
