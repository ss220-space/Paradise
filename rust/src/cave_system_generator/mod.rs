//! Procedural cave system generator from https://github.com/tgstation/rust-g/pull/262.
//!
//! The layout is built in layers: BSP partitioning, one room per leaf, a minimum
//! spanning tree of corridors between neighbouring rooms, random noise, and
//! cellular automata smoothing.

mod automata;
mod config;
mod generator;
mod layout;
mod rng;

use self::config::GeneratorConfig;
use self::generator::generate_cave_system;

use meowtonin::{byond_fn, ByondError, ByondResult, ByondValue, ToByond};
use std::error::Error;

use crate::error::catch_panic;

type BoxError = Box<dyn Error + Send + Sync>;
type Result<T> = std::result::Result<T, BoxError>;

#[byond_fn]
fn cave_system_generator_generate(
    width: ByondValue,
    height: ByondValue,
    prefabs_json: ByondValue,
    settings_json: ByondValue,
) -> ByondResult<ByondValue> {
    let width = width.get_number()? as usize;
    let height = height.get_number()? as usize;
    let prefabs_json = prefabs_json.get_string()?;
    let settings_json = settings_json.get_string()?;

    let grid = catch_panic(move || {
        let config = parse_config(&settings_json).map_err(|error| ByondError::Boxed(error))?;
        generate_cave_system(width, height, &prefabs_json, config)
            .map_err(|error| ByondError::Boxed(error))
    })?;

    grid.to_byond()
}

fn parse_config(settings_json: &str) -> Result<GeneratorConfig> {
    if settings_json.is_empty() {
        return Ok(GeneratorConfig::default());
    }
    Ok(serde_json::from_str(settings_json)?)
}

const DEAD: u8 = 0;
const ALIVE: u8 = 1;
const DEF_ALIVE: u8 = 2;
const DEF_DEAD: u8 = 3;
