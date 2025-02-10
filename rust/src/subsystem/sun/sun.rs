use byondapi::value::ByondValue;

pub struct Sun {
    pub rate: f32,
    pub dx: f32,
    pub dy: f32,
    pub solars: Option<ByondValue>,
    pub angle: f32,
}

impl Sun {
    pub fn setup_solars(&self) -> eyre::Result<ByondValue> {
        for solar in self.solars.unwrap_or_default().get_list_values()? {
            let _ = solar.call("setup", &[])?;
        }
        Ok(ByondValue::from(true))
    }
    pub fn update_solars(&mut self) -> eyre::Result<ByondValue> {
        if let Some(solars) = &mut self.solars {
            let solars_list = solars.get_list_values()?;
            for solar in solars_list {
                if solar.read_var("powernet")?.is_null() {
                    let _ = solars.call("Remove", &[solar])?;
                    continue;
                }
                let _ = solar.call("update", &[])?;
            }
            return Ok(ByondValue::from(true));
        }
        Ok(ByondValue::null())
    }
    pub fn add_solar(&self, solar: ByondValue) -> eyre::Result<ByondValue> {
        if let Some(mut solars) = self.solars {
            let _ = solars.push_list(solar);
            return Ok(solar);
        }
        Ok(ByondValue::null())
    }
    pub fn remove_solar(&self, solar: ByondValue) -> eyre::Result<ByondValue> {
        if let Some(solars) = self.solars {
            let _ = solars.call("Remove", &[solar]);
            return Ok(solar);
        }
        Ok(ByondValue::null())
    }
    pub fn get_dy(&self) -> eyre::Result<ByondValue> {
        Ok(ByondValue::from(self.dy))
    }
    pub fn get_dx(&self) -> eyre::Result<ByondValue> {
        Ok(ByondValue::from(self.dx))
    }
    pub fn get_solars(&self) -> eyre::Result<ByondValue> {
        if let Some(solars) = self.solars {
            return Ok(solars);
        }
        Ok(ByondValue::null())
    }
}
