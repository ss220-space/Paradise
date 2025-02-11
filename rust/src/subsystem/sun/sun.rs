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
            solar.call("setup", &[])?;
        }
        Ok(ByondValue::from(true))
    }

    pub fn update_solars(&mut self) -> eyre::Result<ByondValue> {
        let solars_list = self.solars.unwrap_or_default();

        for solar in solars_list.get_list_values()? {
            if solar.read_var("powernet")?.is_null() {
                solars_list.call("Remove", &[solar])?;
                continue;
            }
            solar.call("update", &[])?;
        }
        Ok(ByondValue::from(true))
    }

    pub fn add_solar(&self, solar: ByondValue) -> eyre::Result<ByondValue> {
        self.solars.unwrap_or_default().push_list(solar)?;
        Ok(solar)
    }

    pub fn remove_solar(&self, solar: ByondValue) -> eyre::Result<ByondValue> {
        self.solars.unwrap_or_default().call("Remove", &[solar])?;
        Ok(solar)
    }

    pub fn get_dy(&self) -> eyre::Result<ByondValue> {
        Ok(ByondValue::from(self.dy))
    }

    pub fn get_dx(&self) -> eyre::Result<ByondValue> {
        Ok(ByondValue::from(self.dx))
    }

    pub fn get_solars(&self) -> eyre::Result<ByondValue> {
        Ok(self.solars.unwrap_or_default())
    }
}
