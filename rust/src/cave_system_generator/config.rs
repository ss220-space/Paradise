use serde::Deserialize;

#[derive(Deserialize, Clone, Copy)]
#[serde(default)]
pub(super) struct GeneratorConfig {
    #[serde(deserialize_with = "de_usize")]
    pub(super) min_bsp_size: usize,
    #[serde(deserialize_with = "de_f64")]
    pub(super) max_ratio: f64,
    #[serde(deserialize_with = "de_usize")]
    pub(super) padding: usize,
    #[serde(deserialize_with = "de_usize")]
    pub(super) room_fill_percent: usize,
    #[serde(deserialize_with = "de_usize")]
    pub(super) corridor_width: usize,
    #[serde(deserialize_with = "de_usize")]
    pub(super) loop_percent: usize,
    #[serde(deserialize_with = "de_usize")]
    pub(super) noise_percent: usize,
    #[serde(deserialize_with = "de_usize")]
    pub(super) ca_steps: usize,
    #[serde(deserialize_with = "de_usize")]
    pub(super) birth_limit: usize,
    #[serde(deserialize_with = "de_usize")]
    pub(super) survival_limit: usize,
    #[serde(deserialize_with = "de_byond_bool")]
    pub(super) edge_is_alive: bool,
    pub(super) seed: Option<u64>,
}

impl Default for GeneratorConfig {
    fn default() -> Self {
        Self {
            min_bsp_size: 25,
            max_ratio: 1.5,
            padding: 1,
            room_fill_percent: 30,
            corridor_width: 1,
            loop_percent: 15,
            noise_percent: 51,
            ca_steps: 8,
            birth_limit: 6,
            survival_limit: 4,
            edge_is_alive: true,
            seed: None,
        }
    }
}

#[derive(Deserialize)]
#[serde(untagged)]
enum FlexibleNumber {
    Int(i64),
    Float(f64),
}

impl FlexibleNumber {
    fn as_usize(self) -> usize {
        match self {
            FlexibleNumber::Int(value) => value.max(0) as usize,
            FlexibleNumber::Float(value) => value.max(0.0) as usize,
        }
    }

    fn as_f64(self) -> f64 {
        match self {
            FlexibleNumber::Int(value) => value as f64,
            FlexibleNumber::Float(value) => value,
        }
    }
}

#[derive(Deserialize)]
#[serde(untagged)]
enum ByondBool {
    Bool(bool),
    Number(FlexibleNumber),
    Text(String),
}

impl ByondBool {
    fn value(self) -> bool {
        match self {
            ByondBool::Bool(value) => value,
            ByondBool::Number(value) => value.as_f64() != 0.0,
            ByondBool::Text(value) => matches!(value.trim(), "1" | "true" | "TRUE" | "True"),
        }
    }
}

fn de_usize<'de, D>(deserializer: D) -> std::result::Result<usize, D::Error>
where
    D: serde::Deserializer<'de>,
{
    Ok(FlexibleNumber::deserialize(deserializer)?.as_usize())
}

fn de_f64<'de, D>(deserializer: D) -> std::result::Result<f64, D::Error>
where
    D: serde::Deserializer<'de>,
{
    Ok(FlexibleNumber::deserialize(deserializer)?.as_f64())
}

fn de_byond_bool<'de, D>(deserializer: D) -> std::result::Result<bool, D::Error>
where
    D: serde::Deserializer<'de>,
{
    Ok(ByondBool::deserialize(deserializer)?.value())
}

#[derive(Deserialize)]
pub(super) struct PrefabConfig {
    #[serde(deserialize_with = "de_usize")]
    pub(super) x: usize,
    #[serde(deserialize_with = "de_usize")]
    pub(super) y: usize,
    #[serde(deserialize_with = "de_usize")]
    pub(super) w: usize,
    #[serde(deserialize_with = "de_usize")]
    pub(super) h: usize,
    #[serde(
        default,
        rename = "isEnclosed",
        deserialize_with = "de_byond_bool"
    )]
    pub(super) is_enclosed: bool,
}
