use crate::milla::constants::*;
use crate::milla::model::*;
use byondapi::map::ByondXYZ;
use core::f32;
use eyre::eyre;
use rand::Rng;
use scc::Bag;
use std::collections::HashSet;
use std::f32::consts::E;

pub(crate) fn find_walls(next: &mut ZLevel) {
    for my_index in 0..MAP_SIZE * MAP_SIZE {
        let x = (my_index / MAP_SIZE) as i32;
        let y = (my_index % MAP_SIZE) as i32;

        for (axis, (dx, dy)) in AXES.iter().enumerate() {
            let their_index = match ZLevel::maybe_get_index(x + dx, y + dy) {
                Some(index) => index,
                None => {
                    // Edge of the map, acts like a wall.
                    let my_tile = next.get_tile_mut(my_index);
                    my_tile.wall[axis] = true;
                    continue;
                }
            };

            let (my_tile, their_tile) = next.get_pair_mut(my_index, their_index);
            if *dx > 0
                && (my_tile
                    .airtight_directions
                    .contains(AirtightDirections::EAST)
                    || their_tile
                        .airtight_directions
                        .contains(AirtightDirections::WEST))
            {
                // Something's blocking airflow.
                my_tile.wall[axis] = true;
                continue;
            } else if *dy > 0
                && (my_tile
                    .airtight_directions
                    .contains(AirtightDirections::NORTH)
                    || their_tile
                        .airtight_directions
                        .contains(AirtightDirections::SOUTH))
            {
                // Something's blocking airflow.
                my_tile.wall[axis] = true;
                continue;
            }
            my_tile.wall[axis] = false;
        }
    }
}

/// Calculate the new wind at each boundary.
pub(crate) fn update_wind(prev: &ZLevel, next: &mut ZLevel) {
    for my_index in 0..MAP_SIZE * MAP_SIZE {
        let x = (my_index / MAP_SIZE) as i32;
        let y = (my_index % MAP_SIZE) as i32;
        let my_tile = prev.get_tile(my_index);

        if let AtmosMode::Space = my_tile.mode {
            let my_new_tile = next.get_tile_mut(my_index);
            my_new_tile.wind = [0.0, 0.0];
            continue;
        }

        for (axis, (dx, dy)) in AXES.iter().enumerate() {
            let my_new_tile = next.get_tile_mut(my_index);

            let neighbor_index = match ZLevel::maybe_get_index(x + dx, y + dy) {
                Some(index) => index,
                None => {
                    my_new_tile.wind[axis] = 0.0;
                    continue;
                }
            };

            let neighbor = prev.get_tile(neighbor_index);

            // No wind across walls.
            if my_new_tile.wall[axis] {
                my_new_tile.wind[axis] = 0.0;
                continue;
            }

            let my_pressure = my_tile.pressure();

            if let AtmosMode::Space = neighbor.mode {
                my_new_tile.wind[axis] = WIND_STRENGTH;
                continue;
            }

            let combined_pressure = my_pressure + neighbor.pressure();

            // If there's no air, there's no wind.
            if combined_pressure <= 0.0 {
                my_new_tile.wind[axis] = 0.0;
                continue;
            }

            // A bias from [-1.0, 1.0] representing how much air is flowing
            let pressure_bias = 2.0 * (my_pressure / combined_pressure) - 1.0;

            // New wind mixes the pressure bias with the old wind
            my_new_tile.wind[axis] = (my_tile.wind[axis]
                + WIND_ACCELERATION * (pressure_bias * WIND_STRENGTH - my_tile.wind[axis]))
                .clamp(-MAX_WIND, MAX_WIND);
        }
    }
}

pub(crate) struct AirflowOutcome {
    active_tiles: HashSet<usize>,
    max_gas_delta: f32,
    max_thermal_energy_delta: f32,
}

impl AirflowOutcome {
    fn new() -> Self {
        AirflowOutcome {
            active_tiles: HashSet::with_capacity(1024),
            max_gas_delta: 0.0,
            max_thermal_energy_delta: 0.0,
        }
    }
}

/// Let the air flow until it stabilizes for this tick or we run out of patience.
pub(crate) fn flow_air(prev: &ZLevel, next: &mut ZLevel) -> Result<AirflowOutcome, eyre::Error> {
    let mut outcome = flow_air_once(prev, next, None)?;

    for _iter in 1..MAX_ITERATIONS {
        let new_outcome = flow_air_once(prev, next, Some(&outcome))?;

        // Check for significant changes.
        if new_outcome.max_gas_delta < GAS_CHANGE_SIGNIFICANCE
            && new_outcome.max_thermal_energy_delta < THERMAL_CHANGE_SIGNIFICANCE
        {
            return Ok(new_outcome);
        }

        outcome = new_outcome;
    }

    Ok(outcome)
}

/// Let the air flow at every active tile by one step.
pub(crate) fn flow_air_once(
    prev: &ZLevel,
    next: &mut ZLevel,
    maybe_old_outcome: Option<&AirflowOutcome>,
) -> Result<AirflowOutcome, eyre::Error> {
    let mut new_outcome = AirflowOutcome::new();

    if let Some(old_outcome) = maybe_old_outcome {
        for &my_index in &old_outcome.active_tiles {
            flow_air_once_at_index(prev, next, my_index, &mut new_outcome)?;
        }
    } else {
        for my_index in 0..MAP_SIZE * MAP_SIZE {
            flow_air_once_at_index(prev, next, my_index, &mut new_outcome)?;
        }
    }

    Ok(new_outcome)
}

pub(crate) fn flow_air_once_at_index(
    prev: &ZLevel,
    next: &mut ZLevel,
    my_index: usize,
    outcome: &mut AirflowOutcome,
) -> Result<(), eyre::Error> {
    let x = (my_index / MAP_SIZE) as i32;
    let y = (my_index % MAP_SIZE) as i32;
    let my_tile = prev.get_tile(my_index);

    // Skip tiles that can't change.
    match my_tile.mode {
        AtmosMode::Space | AtmosMode::ExposedTo { .. } => return Ok(()),
        _ => (),
    }

    // Save the values from the prior iteration
    let prev_iter = next.get_tile(my_index).clone();

    // Reset to original values (Gauss-Seidel step)
    {
        let my_new_tile = next.get_tile_mut(my_index);
        my_new_tile.gases.copy_from(&my_tile.gases);
        my_new_tile.thermal_energy = my_tile.thermal_energy;
    }

    let mut total_weighted_temperature = my_tile.temperature() * my_tile.heat_capacity();
    let mut total_temperature_weights: f32 = my_tile.heat_capacity();

    let mut outgoing_gas_mult = [0.0f32; GAS_COUNT];
    let mut new_gas_values = [0.0f32; GAS_COUNT];

    for i in 0..GAS_COUNT {
        new_gas_values[i] = my_tile.gases.values[i];
    }

    for (dir, (dx, dy)) in DIRECTIONS.iter().enumerate() {
        let axis = DIRECTION_AXIS[dir];

        let my_new_tile = next.get_tile(my_index);

        let neighbor_index = match ZLevel::maybe_get_index(x + dx, y + dy) {
            Some(value) => value,
            None => continue,
        };

        let neighbor_tile = next.get_tile(neighbor_index);

        // Don't do anything across walls.
        if dx + dy > 0 {
            if my_new_tile.wall[axis] {
                continue;
            }
        } else {
            if neighbor_tile.wall[axis] {
                continue;
            }
        }

        let (my_new_tile, new_neighbor) = next.get_pair_mut(my_index, neighbor_index);

        let wind = if dx + dy > 0 {
            my_new_tile.wind[axis]
        } else {
            -new_neighbor.wind[axis]
        };

        let (inflow, outflow) = calculate_flow_coefficients(wind);

        for i in 0..GAS_COUNT {
            let incoming = inflow * new_neighbor.gases.values[i];

            new_gas_values[i] += incoming;
            outgoing_gas_mult[i] += outflow;

            let temperature_weight = incoming * SPECIFIC_HEATS[i];
            total_weighted_temperature +=
                new_neighbor.temperature() * temperature_weight * TEMPERATURE_FLOW_RATE;
            total_temperature_weights += temperature_weight * TEMPERATURE_FLOW_RATE;
        }
    }

    let mut max_gas_delta = 0.0f32;
    let my_new_tile = next.get_tile_mut(my_index);

    for i in 0..GAS_COUNT {
        let divisor = 1.0 + outgoing_gas_mult[i];
        let new_value = if divisor > 0.0 {
            new_gas_values[i] / divisor
        } else {
            new_gas_values[i]
        };

        let old_value = prev_iter.gases.values[i];
        my_new_tile.gases.values[i] = new_value;

        if (old_value - new_value).abs() >= GAS_CHANGE_SIGNIFICANCE {
            let new_gas_delta = if old_value + new_value > 0.0 {
                (2.0 * old_value / (old_value + new_value) - 1.0).abs()
            } else {
                0.0
            };
            max_gas_delta = max_gas_delta.max(new_gas_delta);
        }
    }
    my_new_tile.gases.set_dirty();

    if total_temperature_weights > 0.0 {
        let new_temperature = total_weighted_temperature / total_temperature_weights;
        my_new_tile.thermal_energy = new_temperature * my_new_tile.heat_capacity();
    }

    let thermal_diff = (prev_iter.thermal_energy - my_new_tile.thermal_energy).abs();
    let new_thermal_energy_delta = if thermal_diff >= THERMAL_CHANGE_SIGNIFICANCE
        && prev_iter.thermal_energy + my_new_tile.thermal_energy > 0.0
    {
        (2.0 * prev_iter.thermal_energy / (prev_iter.thermal_energy + my_new_tile.thermal_energy)
            - 1.0)
            .abs()
    } else {
        0.0
    };

    outcome.max_gas_delta = outcome.max_gas_delta.max(max_gas_delta);
    outcome.max_thermal_energy_delta = outcome
        .max_thermal_energy_delta
        .max(new_thermal_energy_delta);

    if max_gas_delta >= GAS_CHANGE_SIGNIFICANCE_FRACTION
        || new_thermal_energy_delta >= THERMAL_CHANGE_SIGNIFICANCE_FRACTION
    {
        outcome.active_tiles.insert(my_index);
        for (dx, dy) in DIRECTIONS {
            if let Some(neighbor_index) = ZLevel::maybe_get_index(x + dx, y + dy) {
                outcome.active_tiles.insert(neighbor_index);
            }
        }
    }

    Ok(())
}

fn calculate_flow_coefficients(wind: f32) -> (f32, f32) {
    let mut inflow = DIFFUSION_SPEED;
    let mut outflow = DIFFUSION_SPEED;

    if wind != 0.0 {
        let wind_flow = (1.0 + WIND_SPEED).powf(wind.abs()) - 1.0;

        if wind > 0.0 {
            outflow += wind_flow;
        } else {
            inflow += wind_flow;
        }
    }

    (inflow, outflow)
}

/// Applies effects that happen after the main airflow routine:
/// * Tile modes
/// * Superconductivity
/// * Reactions
/// * Hotspot cleanup
/// * Sanitization
/// * Looking for interesting tiles.
pub(crate) fn post_process(
    prev: &ZLevel,
    next: &mut ZLevel,
    environments: &Box<[Tile]>,
    new_interesting_tiles: &Bag<InterestingTile>,
    z: i32,
) -> Result<(), eyre::Error> {
    for my_index in 0..MAP_SIZE * MAP_SIZE {
        let x = (my_index / MAP_SIZE) as i32;
        let y = (my_index % MAP_SIZE) as i32;
        let my_tile = prev.get_tile(my_index);

        {
            let my_next_tile = next.get_tile_mut(my_index);
            apply_tile_mode(my_next_tile, environments)?;
        }

        if let AtmosMode::Space = my_tile.mode {
            // Space doesn't superconduct, has no reactions, doesn't need to be sanitized, and is never interesting. (Take that, astrophysicists and astronomers!)
            continue;
        }

        for (dx, dy) in AXES {
            let their_index = match ZLevel::maybe_get_index(x + dx, y + dy) {
                Some(index) => index,
                None => continue,
            };

            let (my_next_tile, their_next_tile) = next.get_pair_mut(my_index, their_index);

            if their_next_tile.mode != AtmosMode::Space {
                superconduct(my_next_tile, their_next_tile, dx > 0, false);
            }
        }

        {
            let my_next_tile = next.get_tile_mut(my_index);
            // New tick, reset the fuel tracker.
            my_next_tile.fuel_burnt = 0.0;

            my_next_tile.radiation_energy = 0.0;
            my_next_tile.hallucination_strength = 0.0;
            my_next_tile.updates = ReasonFlags::NONE;
            my_next_tile.nuclear_particles = 0.0;

            react(my_next_tile, false);
            if my_next_tile.hotspot_volume > 0.0 {
                react(my_next_tile, true);
            }
            do_turf_effects(my_next_tile);

            // Sanitize the tile, to avoid negative/NaN/infinity spread.
            sanitize(my_next_tile, my_tile);
        }

        check_interesting(x, y, z, next, my_tile, my_index, new_interesting_tiles)?;
    }
    Ok(())
}

pub(crate) fn sanitize(my_next_tile: &mut Tile, my_tile: &Tile) -> bool {
    let mut sanitized = false;
    for i in 0..GAS_COUNT {
        if !my_next_tile.gases.values[i].is_finite() {
            // Reset back to the last value, in the hopes that it's safe.
            my_next_tile.gases.values[i] = my_tile.gases.values[i];
            my_next_tile.gases.set_dirty();
            sanitized = true;
        } else if my_next_tile.gases.values[i] < 0.0 {
            // Zero out anything that becomes negative.
            my_next_tile.gases.values[i] = 0.0;
            my_next_tile.gases.set_dirty();
            sanitized = true;
        }
    }
    if !my_next_tile.thermal_energy.is_finite() {
        // Reset back to the last value, in the hopes that it's safe.
        my_next_tile.thermal_energy = my_tile.thermal_energy;
        sanitized = true;
    } else if my_next_tile.thermal_energy < 0.0 {
        // Zero out anything that becomes negative.
        my_next_tile.thermal_energy = 0.0;
        sanitized = true;
    }
    if !my_next_tile.wind[0].is_finite() {
        // Reset back to the last value, in the hopes that it's safe.
        my_next_tile.wind[0] = my_tile.wind[0];
        sanitized = true;
    }
    if !my_next_tile.wind[1].is_finite() {
        // Reset back to the last value, in the hopes that it's safe.
        my_next_tile.wind[1] = my_tile.wind[1];
        sanitized = true;
    }
    if my_next_tile.gases.moles() < MINIMUM_NONZERO_MOLES {
        for i in 0..GAS_COUNT {
            my_next_tile.gases.values[i] = 0.0;
        }
        my_next_tile.thermal_energy = 0.0;
        // We don't count this as sanitized because it's expected.
    }

    sanitized
}

#[allow(clippy::if_same_then_else)]
/// Checks a tile to see if it's "interesting" and should be sent to BYOND.
pub(crate) fn check_interesting(
    x: i32,
    y: i32,
    z: i32,
    next: &mut ZLevel,
    my_tile: &Tile,
    my_index: usize,
    new_interesting_tiles: &Bag<InterestingTile>,
) -> Result<(), eyre::Error> {
    let mut reasons: ReasonFlags = ReasonFlags::empty();
    {
        let my_next_tile = next.get_tile_mut(my_index);

        if (my_next_tile.fuel_burnt > REACTION_SIGNIFICANCE_MOLES)
            != (my_tile.fuel_burnt > REACTION_SIGNIFICANCE_MOLES)
        {
            reasons |= ReasonFlags::DISPLAY;
        }

        if (my_next_tile.gases.toxins() >= TOXINS_MIN_VISIBILITY_MOLES)
            != (my_tile.gases.toxins() >= TOXINS_MIN_VISIBILITY_MOLES)
        {
            reasons |= ReasonFlags::DISPLAY;
        }

        if (my_next_tile.gases.sleeping_agent() >= SLEEPING_GAS_VISIBILITY_MOLES)
            != (my_tile.gases.sleeping_agent() >= SLEEPING_GAS_VISIBILITY_MOLES)
        {
            reasons |= ReasonFlags::DISPLAY;
        }

        if (my_next_tile.gases.water_vapor() >= WATER_VAPOR_VISIBILITY_MOLES)
            != (my_tile.gases.water_vapor() >= WATER_VAPOR_VISIBILITY_MOLES)
        {
            reasons |= ReasonFlags::DISPLAY;
        }
        if (my_next_tile.gases.tritium() >= TRITIUM_VISIBILITY_MOLES)
            != (my_tile.gases.tritium() >= TRITIUM_VISIBILITY_MOLES)
        {
            reasons |= ReasonFlags::DISPLAY;
        }

        if (my_next_tile.gases.freon() >= FREON_VISIBILITY_MOLES)
            != (my_tile.gases.freon() >= FREON_VISIBILITY_MOLES)
        {
            reasons |= ReasonFlags::DISPLAY;
        }

        if (my_next_tile.gases.miasma() >= MIASMA_VISIBILITY_MOLES)
            != (my_tile.gases.miasma() >= MIASMA_VISIBILITY_MOLES)
        {
            reasons |= ReasonFlags::DISPLAY;
        }

        if (my_next_tile.gases.proto_nitrate() >= PROTO_NITRATE_VISIBILITY_MOLES)
            != (my_tile.gases.proto_nitrate() >= PROTO_NITRATE_VISIBILITY_MOLES)
        {
            reasons |= ReasonFlags::DISPLAY;
        }

        if (my_next_tile.gases.zauker() >= ZAUKER_VISIBILITY_MOLES)
            != (my_tile.gases.zauker() >= ZAUKER_VISIBILITY_MOLES)
        {
            reasons |= ReasonFlags::DISPLAY;
        }

        if (my_next_tile.gases.nitrium() >= NITRIUM_VISIBILITY_MOLES)
            != (my_tile.gases.nitrium() >= NITRIUM_VISIBILITY_MOLES)
        {
            reasons |= ReasonFlags::DISPLAY;
        }

        if (my_next_tile.gases.healium() >= HEALIUM_VISIBILITY_MOLES)
            != (my_tile.gases.healium() >= HEALIUM_VISIBILITY_MOLES)
        {
            reasons |= ReasonFlags::DISPLAY;
        }

        if (my_next_tile.gases.halon() >= HALON_VISIBILITY_MOLES)
            != (my_tile.gases.halon() >= HALON_VISIBILITY_MOLES)
        {
            reasons |= ReasonFlags::DISPLAY;
        }

        if (my_next_tile.gases.hypernoblium() >= HYPER_NOBLIUM_VISIBILITY_MOLES)
            != (my_tile.gases.hypernoblium() >= HYPER_NOBLIUM_VISIBILITY_MOLES)
        {
            reasons |= ReasonFlags::DISPLAY;
        }

        if (my_next_tile.gases.antinoblium() >= ANTINOBLIUM_VISIBILITY_MOLES)
            != (my_tile.gases.antinoblium() >= ANTINOBLIUM_VISIBILITY_MOLES)
        {
            reasons |= ReasonFlags::DISPLAY;
        }

        reasons |= my_next_tile.updates;

        if my_next_tile.temperature() > PLASMA_BURN_MIN_TEMP {
            if let AtmosMode::ExposedTo { .. } = my_next_tile.mode {
                // Since environments have fixed gases and temperatures, we only count them as
                // interesting (for heat) if there's an active fire.
                if my_next_tile.fuel_burnt > REACTION_SIGNIFICANCE_MOLES {
                    reasons |= ReasonFlags::HOT;
                }
            } else {
                // Anywhere else is interesting if it's hot enough to start a fire.
                reasons |= ReasonFlags::HOT;
            }
        }
    }
    let my_next_tile = next.get_tile(my_index);
    let mut wind_x: f32 = 0.0;
    let my_next_tile_pressure = my_next_tile.pressure();
    if my_next_tile.wind[AXIS_X] > 0.0 {
        wind_x += my_next_tile.wind[AXIS_X] * WIND_SPEED_MULTIPLIER;
    }
    if let Some(index) = ZLevel::maybe_get_index(x - 1, y) {
        let their_next_tile = next.get_tile(index);
        if their_next_tile.wind[AXIS_X] < 0.0 {
            // This is negative, but that's good, because we want it to fight against the wind
            // towards +X.
            wind_x += their_next_tile.wind[AXIS_X] * BYOND_WIND_MULTIPLIER;
        }
    }
    wind_x *= my_next_tile_pressure;
    let mut wind_y: f32 = 0.0;
    if my_next_tile.wind[AXIS_Y] > 0.0 {
        wind_y += my_next_tile.wind[AXIS_Y] * BYOND_WIND_MULTIPLIER;
    }
    if let Some(index) = ZLevel::maybe_get_index(x, y - 1) {
        let their_next_tile = next.get_tile(index);
        if their_next_tile.wind[AXIS_Y] < 0.0 {
            // This is negative, but that's good, because we want it to fight against the wind
            // towards +Y.
            wind_y += their_next_tile.wind[AXIS_Y] * BYOND_WIND_MULTIPLIER;
        }
    }
    wind_y *= my_next_tile_pressure;
    if wind_x * wind_x + wind_y * wind_y > 1.0 {
        // Pressure flowing out of this tile might move stuff.
        reasons |= ReasonFlags::WIND;
    }

    if !reasons.is_empty() {
        // :eyes:
        new_interesting_tiles.push(InterestingTile {
            tile: my_next_tile.clone(),
            // +1 here to convert from our 0-indexing to BYOND's 1-indexing.
            coords: ByondXYZ::with_coords((x as i16 + 1, y as i16 + 1, z as i16 + 1)),
            reasons,
            wind_x,
            wind_y,
        });
    }

    Ok(())
}

/// Perform chemical reactions on the tile.
pub(crate) fn react(my_next_tile: &mut Tile, hotspot_step: bool) {
    let fraction: f32;
    let hotspot_boost: f32;
    let mut cached_heat_capacity: f32;
    let mut cached_temperature: f32;
    let mut thermal_energy: f32;
    let mut cached_radiation: f32 = 0.0;
    if hotspot_step {
        fraction = my_next_tile.hotspot_volume;
        hotspot_boost = PLASMA_BURN_HOTSPOT_RATIO_BOOST;
        cached_heat_capacity = fraction * my_next_tile.heat_capacity();
        cached_temperature = my_next_tile.hotspot_temperature;
        thermal_energy = cached_temperature * cached_heat_capacity;
    } else {
        fraction = 1.0 - my_next_tile.hotspot_volume;
        hotspot_boost = 1.0;
        cached_heat_capacity = fraction * my_next_tile.heat_capacity();
        thermal_energy = fraction * my_next_tile.thermal_energy;
        cached_temperature = thermal_energy / cached_heat_capacity;
    }
    let initial_thermal_energy = thermal_energy;

    // Agent B converting CO2 to O2
    if cached_temperature > AGENT_B_CONVERSION_TEMP
        && my_next_tile.gases.agent_b() > 0.0
        && my_next_tile.gases.carbon_dioxide() > 0.0
        && my_next_tile.gases.toxins() > 0.0
    {
        let co2_converted = fraction
            * (my_next_tile.gases.carbon_dioxide() * 0.75)
                .min(my_next_tile.gases.toxins() * 0.25)
                .min(my_next_tile.gases.agent_b() * 0.05);

        my_next_tile
            .gases
            .set_carbon_dioxide(my_next_tile.gases.carbon_dioxide() - co2_converted);
        my_next_tile
            .gases
            .set_oxygen(my_next_tile.gases.oxygen() + co2_converted);
        my_next_tile
            .gases
            .set_agent_b(my_next_tile.gases.agent_b() - co2_converted * 0.05);
        // Recalculate heat capacity.
        cached_heat_capacity = fraction * my_next_tile.heat_capacity();
        // Add in the new thermal energy.
        thermal_energy += AGENT_B_CONVERSION_ENERGY * co2_converted;
        // Recalculate temperature for any subsequent reactions.
        cached_temperature = thermal_energy / cached_heat_capacity;
        my_next_tile.fuel_burnt += co2_converted;
    }

    // NITRIUM DECOMPOSITION
    if cached_temperature <= NITRIUM_DECOMPOSITION_MAX_TEMP
        && my_next_tile.gases.oxygen() >= 0.0
        && my_next_tile.gases.nitrium() >= 0.0
    {
        let nitrium = my_next_tile.gases.nitrium();
        let heat_efficiency =
            (cached_temperature / NITRIUM_DECOMPOSITION_TEMP_DIVISOR).min(nitrium);

        if heat_efficiency > 0.0 && nitrium - heat_efficiency >= 0.0 {
            let old_heat_capacity = cached_heat_capacity;

            my_next_tile.gases.set_nitrium(nitrium - heat_efficiency);
            my_next_tile
                .gases
                .set_hydrogen(my_next_tile.gases.hydrogen() + heat_efficiency);
            my_next_tile
                .gases
                .set_nitrogen(my_next_tile.gases.nitrogen() + heat_efficiency);

            cached_heat_capacity = fraction * my_next_tile.heat_capacity();

            let energy_released = NITRIUM_DECOMPOSITION_ENERGY * heat_efficiency;

            let new_temp = ((cached_temperature * old_heat_capacity + energy_released)
                / cached_heat_capacity)
                .max(TCMB);

            thermal_energy = new_temp * cached_heat_capacity;
            cached_temperature = new_temp;
        }
    }

    // HALON COMBUSTION
    if cached_temperature >= HALON_COMBUSTION_MIN_TEMPERATURE
        && my_next_tile.gases.halon() >= 0.0
        && my_next_tile.gases.oxygen() >= 0.0
    {
        let halon = my_next_tile.gases.halon();
        let oxygen = my_next_tile.gases.oxygen();

        let heat_efficiency = (cached_temperature / HALON_COMBUSTION_TEMPERATURE_SCALE)
            .min(halon)
            .min(oxygen / 20.0);

        if heat_efficiency > 0.0 {
            my_next_tile.gases.set_halon(halon - heat_efficiency);
            my_next_tile
                .gases
                .set_oxygen(oxygen - heat_efficiency * 20.0);
            my_next_tile
                .gases
                .set_pluoxium(my_next_tile.gases.pluoxium() + heat_efficiency * 2.5);

            cached_heat_capacity = fraction * my_next_tile.heat_capacity();
            let energy_used = HALON_COMBUSTION_ENERGY * heat_efficiency;
            thermal_energy = (thermal_energy - energy_used).max(0.0);
            cached_temperature = thermal_energy / cached_heat_capacity;

            if heat_efficiency > HALON_COMBUSTION_MINIMUM_RESIN_MOLES {
                my_next_tile.updates |= ReasonFlags::CREATE_RESIN;
            }
        }
    }

    // PROTO-NITRATE HYDROGEN CONVERSION
    if my_next_tile.gases.proto_nitrate() >= 0.0
        && my_next_tile.gases.hydrogen() >= PN_HYDROGEN_CONVERSION_THRESHOLD
    {
        let hydrogen = my_next_tile.gases.hydrogen();
        let proto_nitrate = my_next_tile.gases.proto_nitrate();

        let produced_amount = PN_HYDROGEN_CONVERSION_MAX_RATE
            .min(hydrogen)
            .min(proto_nitrate);

        if produced_amount > 0.0 {
            my_next_tile.gases.set_hydrogen(hydrogen - produced_amount);
            my_next_tile
                .gases
                .set_proto_nitrate(proto_nitrate + produced_amount * 0.5);

            cached_heat_capacity = fraction * my_next_tile.heat_capacity();
            let energy_used = PN_HYDROGEN_CONVERSION_ENERGY * produced_amount;
            thermal_energy = (thermal_energy - energy_used).max(0.0);
            cached_temperature = thermal_energy / cached_heat_capacity;
        }
    }

    // PROTO-NITRATE TRITIUM CONVERSION
    if cached_temperature >= PN_TRITIUM_CONVERSION_MIN_TEMP
        && cached_temperature <= PN_TRITIUM_CONVERSION_MAX_TEMP
        && my_next_tile.gases.proto_nitrate() >= 0.0
        && my_next_tile.gases.tritium() >= 0.0
    {
        let proto_nitrate = my_next_tile.gases.proto_nitrate();
        let tritium = my_next_tile.gases.tritium();

        let produced_amount = (cached_temperature / 34.0 * (tritium * proto_nitrate)
            / (tritium + 10.0 * proto_nitrate))
            .min(tritium)
            .min(proto_nitrate / 0.01);

        if produced_amount > 0.0 {
            my_next_tile
                .gases
                .set_proto_nitrate(proto_nitrate - produced_amount * 0.01);
            my_next_tile.gases.set_tritium(tritium - produced_amount);
            my_next_tile
                .gases
                .set_hydrogen(my_next_tile.gases.hydrogen() + produced_amount);

            cached_heat_capacity = fraction * my_next_tile.heat_capacity();
            let energy_released = PN_TRITIUM_CONVERSION_ENERGY * produced_amount;
            thermal_energy += energy_released;
            cached_temperature = thermal_energy / cached_heat_capacity;

            if energy_released > PN_TRITIUM_CONVERSION_RAD_RELEASE_THRESHOLD {
                my_next_tile.updates |= ReasonFlags::RADIATION_PULSE;
                cached_radiation =
                    cached_radiation.max(produced_amount.sqrt() / PN_TRITIUM_RAD_RANGE_DIVISOR);
            }
        }
    }

    // PROTO-NITRATE BZ RESPONSE
    if cached_temperature >= PN_BZASE_MIN_TEMP
        && cached_temperature <= PN_BZASE_MAX_TEMP
        && my_next_tile.gases.proto_nitrate() >= 0.0
        && my_next_tile.gases.bz() >= 0.0
    {
        let proto_nitrate = my_next_tile.gases.proto_nitrate();
        let bz = my_next_tile.gases.bz();

        let consumed_amount = (cached_temperature / 2240.0 * bz * proto_nitrate
            / (bz + proto_nitrate))
            .min(bz)
            .min(proto_nitrate);

        if consumed_amount > 0.0 {
            my_next_tile.gases.set_bz(bz - consumed_amount);
            my_next_tile
                .gases
                .set_nitrogen(my_next_tile.gases.nitrogen() + consumed_amount * 0.4);
            my_next_tile
                .gases
                .set_helium(my_next_tile.gases.helium() + consumed_amount * 1.6);
            my_next_tile
                .gases
                .set_toxins(my_next_tile.gases.toxins() + consumed_amount * 0.8);

            cached_heat_capacity = fraction * my_next_tile.heat_capacity();
            let energy_released = PN_BZASE_ENERGY * consumed_amount;
            thermal_energy += energy_released;
            cached_temperature = thermal_energy / cached_heat_capacity;

            if energy_released > PN_BZASE_RAD_RELEASE_THRESHOLD {
                my_next_tile.updates |= ReasonFlags::RADIATION_PULSE;
                my_next_tile.updates |= ReasonFlags::HALLUCINATION;
                my_next_tile.updates |= ReasonFlags::NUCLEAR_PARTICLES;
                my_next_tile.nuclear_particles = (consumed_amount
                    / PN_BZASE_NUCLEAR_PARTICLE_DIVISOR)
                    .min(PN_BZASE_NUCLEAR_PARTICLE_MAXIMUM as f32);
                cached_radiation = cached_radiation.max(
                    (consumed_amount
                        - my_next_tile.nuclear_particles
                            * PN_BZASE_NUCLEAR_PARTICLE_RADIATION_ENERGY_CONVERSION)
                        .sqrt()
                        / PN_BZASE_RAD_RANGE_DIVISOR,
                );
                my_next_tile.hallucination_strength = consumed_amount * 20.0;
            }
        }
    }

    // N2O FORMATION
    if cached_temperature >= N2O_FORMATION_MIN_TEMPERATURE
        && cached_temperature <= N2O_FORMATION_MAX_TEMPERATURE
        && my_next_tile.gases.oxygen() >= 10.0
        && my_next_tile.gases.nitrogen() >= 20.0
        && my_next_tile.gases.bz() >= 5.0
    {
        let oxygen = my_next_tile.gases.oxygen();
        let nitrogen = my_next_tile.gases.nitrogen();

        let heat_efficiency = (oxygen * 2.0).min(nitrogen);

        if heat_efficiency > 0.0 {
            let old_heat_capacity = cached_heat_capacity;

            my_next_tile
                .gases
                .set_oxygen(oxygen - heat_efficiency * 0.5);
            my_next_tile.gases.set_nitrogen(nitrogen - heat_efficiency);
            my_next_tile
                .gases
                .set_sleeping_agent(my_next_tile.gases.sleeping_agent() + heat_efficiency);

            cached_heat_capacity = fraction * my_next_tile.heat_capacity();
            let energy_released = N2O_FORMATION_ENERGY * heat_efficiency;

            let new_temp = ((cached_temperature * old_heat_capacity + energy_released)
                / cached_heat_capacity)
                .max(TCMB);
            thermal_energy = new_temp * cached_heat_capacity;
            cached_temperature = new_temp;
        }
    }

    // BZ FORMATION
    if cached_temperature <= BZ_FORMATION_MAX_TEMPERATURE
        && my_next_tile.gases.sleeping_agent() >= 10.0
        && my_next_tile.gases.toxins() >= 10.0
    {
        let pressure = my_next_tile.pressure();
        let volume = TILE_VOLUME;

        let environment_efficiency = volume / pressure.max(1.0);
        let n2o = my_next_tile.gases.sleeping_agent();
        let plasma = my_next_tile.gases.toxins();
        let ratio_efficiency = (n2o / plasma).min(1.0);
        let n2o_decomposed_factor = (4.0 * (plasma / (n2o + plasma) - 0.75)).max(0.0);

        let plasma_limit = if n2o_decomposed_factor < 1.0 {
            let denominator = 0.8 * (1.0 - n2o_decomposed_factor);
            if denominator > 0.0 {
                plasma / denominator
            } else {
                plasma / 0.8
            }
        } else {
            plasma / 0.8
        };

        let bz_formed = (0.01 * ratio_efficiency * environment_efficiency)
            .min(n2o * 2.5)
            .min(plasma_limit);

        if bz_formed > 0.0 {
            let old_heat_capacity = cached_heat_capacity;

            if n2o_decomposed_factor > 0.0 {
                let amount_decomposed = 0.4 * bz_formed * n2o_decomposed_factor;
                my_next_tile
                    .gases
                    .set_nitrogen(my_next_tile.gases.nitrogen() + amount_decomposed);
                my_next_tile
                    .gases
                    .set_oxygen(my_next_tile.gases.oxygen() + amount_decomposed * 0.5);
            }

            my_next_tile
                .gases
                .set_bz(my_next_tile.gases.bz() + bz_formed * (1.0 - n2o_decomposed_factor));
            my_next_tile.gases.set_sleeping_agent(n2o - bz_formed * 0.4);
            my_next_tile
                .gases
                .set_toxins(plasma - 0.8 * bz_formed * (1.0 - n2o_decomposed_factor));

            cached_heat_capacity = fraction * my_next_tile.heat_capacity();

            let energy_released = bz_formed
                * (BZ_FORMATION_ENERGY
                    + n2o_decomposed_factor * (N2O_DECOMPOSITION_ENERGY - BZ_FORMATION_ENERGY));

            let new_temp = ((cached_temperature * old_heat_capacity + energy_released)
                / cached_heat_capacity)
                .max(TCMB);
            thermal_energy = new_temp * cached_heat_capacity;
            cached_temperature = new_temp;
        }
    }

    // PLUOXIUM FORMATION
    if cached_temperature >= PLUOXIUM_FORMATION_MIN_TEMP
        && cached_temperature <= PLUOXIUM_FORMATION_MAX_TEMP
        && my_next_tile.gases.carbon_dioxide() >= 0.0
        && my_next_tile.gases.oxygen() >= 0.0
        && my_next_tile.gases.tritium() >= 0.0
    {
        let co2 = my_next_tile.gases.carbon_dioxide();
        let oxygen = my_next_tile.gases.oxygen();
        let tritium = my_next_tile.gases.tritium();

        let produced_amount = PLUOXIUM_FORMATION_MAX_RATE
            .min(co2)
            .min(oxygen / 0.5)
            .min(tritium / 0.01);

        if produced_amount > 0.0 {
            let old_heat_capacity = cached_heat_capacity;

            my_next_tile.gases.set_carbon_dioxide(co2 - produced_amount);
            my_next_tile
                .gases
                .set_oxygen(oxygen - produced_amount * 0.5);
            my_next_tile
                .gases
                .set_tritium(tritium - produced_amount * 0.01);
            my_next_tile
                .gases
                .set_pluoxium(my_next_tile.gases.pluoxium() + produced_amount);
            my_next_tile
                .gases
                .set_hydrogen(my_next_tile.gases.hydrogen() + produced_amount * 0.01);

            cached_heat_capacity = fraction * my_next_tile.heat_capacity();

            let energy_released = PLUOXIUM_FORMATION_ENERGY * produced_amount;

            let new_temp = ((cached_temperature * old_heat_capacity + energy_released)
                / cached_heat_capacity)
                .max(TCMB);
            thermal_energy = new_temp * cached_heat_capacity;
            cached_temperature = new_temp;
        }
    }

    // NITRIUM FORMATION
    if cached_temperature >= NITRIUM_FORMATION_MIN_TEMP
        && my_next_tile.gases.tritium() >= 20.0
        && my_next_tile.gases.nitrogen() >= 10.0
        && my_next_tile.gases.bz() >= 5.0
    {
        let tritium = my_next_tile.gases.tritium();
        let nitrogen = my_next_tile.gases.nitrogen();
        let bz = my_next_tile.gases.bz();

        let heat_efficiency = (cached_temperature / NITRIUM_FORMATION_TEMP_DIVISOR)
            .min(tritium)
            .min(nitrogen)
            .min(bz / 0.05);

        if heat_efficiency > 0.0
            && tritium - heat_efficiency >= 0.0
            && nitrogen - heat_efficiency >= 0.0
            && bz - heat_efficiency * 0.05 >= 0.0
        {
            let old_heat_capacity = cached_heat_capacity;

            my_next_tile.gases.set_tritium(tritium - heat_efficiency);
            my_next_tile.gases.set_nitrogen(nitrogen - heat_efficiency);
            my_next_tile.gases.set_bz(bz - heat_efficiency * 0.05);
            my_next_tile
                .gases
                .set_nitrium(my_next_tile.gases.nitrium() + heat_efficiency);

            cached_heat_capacity = fraction * my_next_tile.heat_capacity();

            let energy_used = NITRIUM_FORMATION_ENERGY * heat_efficiency;

            let new_temp = ((cached_temperature * old_heat_capacity - energy_used)
                / cached_heat_capacity)
                .max(TCMB);
            thermal_energy = new_temp * cached_heat_capacity;
            cached_temperature = new_temp;
        }
    }

    // FREON FORMATION
    if cached_temperature >= FREON_FORMATION_MIN_TEMPERATURE
        && my_next_tile.gases.toxins() >= 0.0 * 6.0
        && my_next_tile.gases.carbon_dioxide() >= 0.0 * 3.0
        && my_next_tile.gases.bz() >= 0.0
    {
        let plasma = my_next_tile.gases.toxins();
        let co2 = my_next_tile.gases.carbon_dioxide();
        let bz = my_next_tile.gases.bz();

        let minimal_mole_factor = (plasma / 0.6).min(bz / 0.1).min(co2 / 0.3);

        let equation_first_part = (-((cached_temperature - 800.0) / 200.0).powi(2)).exp();
        let equation_second_part = 3.0 / (1.0 + (-0.001 * (cached_temperature - 6000.0)).exp());
        let heat_factor = equation_first_part + equation_second_part;

        let freon_formed = (heat_factor * minimal_mole_factor * 0.05)
            .min(plasma / 0.6)
            .min(co2 / 0.3)
            .min(bz / 0.1);

        if freon_formed > 0.0
            && plasma - freon_formed * 0.6 >= 0.0
            && co2 - freon_formed * 0.3 >= 0.0
            && bz - freon_formed * 0.1 >= 0.0
        {
            let old_heat_capacity = cached_heat_capacity;

            my_next_tile.gases.set_toxins(plasma - freon_formed * 0.6);
            my_next_tile
                .gases
                .set_carbon_dioxide(co2 - freon_formed * 0.3);
            my_next_tile.gases.set_bz(bz - freon_formed * 0.1);
            my_next_tile
                .gases
                .set_freon(my_next_tile.gases.freon() + freon_formed);

            cached_heat_capacity = fraction * my_next_tile.heat_capacity();

            let energy_consumed =
                (7000.0 / (1.0 + (-0.0015 * (cached_temperature - 6000.0)).exp()) + 1000.0)
                    * freon_formed
                    * 0.1;

            let new_temp = ((cached_temperature * old_heat_capacity - energy_consumed)
                / cached_heat_capacity)
                .max(TCMB);

            thermal_energy = new_temp * cached_heat_capacity;
            cached_temperature = new_temp;
        }
    }

    // HYPER-NOBLIUM FORMATION
    if cached_temperature >= NOBLIUM_FORMATION_MIN_TEMP
        && cached_temperature <= NOBLIUM_FORMATION_MAX_TEMP
        && my_next_tile.gases.nitrogen() >= 10.0
        && my_next_tile.gases.tritium() >= 5.0
    {
        let nitrogen = my_next_tile.gases.nitrogen();
        let tritium = my_next_tile.gases.tritium();
        let bz = my_next_tile.gases.bz();

        let reduction_factor = (tritium / (tritium + bz)).clamp(0.001, 1.0);
        let nob_formed = ((nitrogen + tritium) * 0.01)
            .min(tritium / (5.0 * reduction_factor))
            .min(nitrogen / 10.0);

        if nob_formed > 0.0 {
            my_next_tile
                .gases
                .set_tritium(tritium - 5.0 * nob_formed * reduction_factor);
            my_next_tile
                .gases
                .set_nitrogen(nitrogen - 10.0 * nob_formed);
            my_next_tile
                .gases
                .set_hypernoblium(my_next_tile.gases.hypernoblium() + nob_formed);

            cached_heat_capacity = fraction * my_next_tile.heat_capacity();
            let energy_released = NOBLIUM_FORMATION_ENERGY * nob_formed / bz.max(1.0);
            thermal_energy += energy_released;
            cached_temperature = thermal_energy / cached_heat_capacity;
        }
    }

    // HEALIUM FORMATION
    if cached_temperature >= HEALIUM_FORMATION_MIN_TEMP
        && cached_temperature <= HEALIUM_FORMATION_MAX_TEMP
        && my_next_tile.gases.bz() >= 0.0
        && my_next_tile.gases.freon() >= 0.0
    {
        let bz = my_next_tile.gases.bz();
        let freon = my_next_tile.gases.freon();

        let heat_efficiency = (cached_temperature * 0.3).min(freon / 2.75).min(bz / 0.25);

        if heat_efficiency > 0.0 {
            my_next_tile.gases.set_freon(freon - heat_efficiency * 2.75);
            my_next_tile.gases.set_bz(bz - heat_efficiency * 0.25);
            my_next_tile
                .gases
                .set_healium(my_next_tile.gases.healium() + heat_efficiency * 3.0);

            cached_heat_capacity = fraction * my_next_tile.heat_capacity();
            let energy_released = HEALIUM_FORMATION_ENERGY * heat_efficiency;
            thermal_energy += energy_released;
            cached_temperature = thermal_energy / cached_heat_capacity;
        }
    }

    // ZAUKER FORMATION
    if cached_temperature >= ZAUKER_FORMATION_MIN_TEMPERATURE
        && cached_temperature <= ZAUKER_FORMATION_MAX_TEMPERATURE
        && my_next_tile.gases.hypernoblium() >= 0.0
        && my_next_tile.gases.nitrium() >= 0.0
    {
        let hypernoblium = my_next_tile.gases.hypernoblium();
        let nitrium = my_next_tile.gases.nitrium();

        let heat_efficiency = (cached_temperature * ZAUKER_FORMATION_TEMPERATURE_SCALE)
            .min(hypernoblium / 0.01)
            .min(nitrium / 0.5);

        if heat_efficiency > 0.0 {
            my_next_tile
                .gases
                .set_hypernoblium(hypernoblium - heat_efficiency * 0.01);
            my_next_tile
                .gases
                .set_nitrium(nitrium - heat_efficiency * 0.5);
            my_next_tile
                .gases
                .set_zauker(my_next_tile.gases.zauker() + heat_efficiency * 0.5);

            cached_heat_capacity = fraction * my_next_tile.heat_capacity();
            let energy_used = ZAUKER_FORMATION_ENERGY * heat_efficiency;
            thermal_energy = (thermal_energy - energy_used).max(0.0);
            cached_temperature = thermal_energy / cached_heat_capacity;
        }
    }

    // PROTO-NITRATE FORMATION
    if cached_temperature >= PN_FORMATION_MIN_TEMPERATURE
        && cached_temperature <= PN_FORMATION_MAX_TEMPERATURE
        && my_next_tile.gases.pluoxium() >= 0.0
        && my_next_tile.gases.hydrogen() >= 0.0
    {
        let pluoxium = my_next_tile.gases.pluoxium();
        let hydrogen = my_next_tile.gases.hydrogen();

        let heat_efficiency = (cached_temperature * PN_FORMATION_TEMPERATURE_SCALE)
            .min(pluoxium / 0.2)
            .min(hydrogen / 2.0);

        if heat_efficiency > 0.0 {
            my_next_tile
                .gases
                .set_hydrogen(hydrogen - heat_efficiency * 2.0);
            my_next_tile
                .gases
                .set_pluoxium(pluoxium - heat_efficiency * 0.2);
            my_next_tile
                .gases
                .set_proto_nitrate(my_next_tile.gases.proto_nitrate() + heat_efficiency * 2.2);

            cached_heat_capacity = fraction * my_next_tile.heat_capacity();
            let energy_released = PN_FORMATION_ENERGY * heat_efficiency;
            thermal_energy += energy_released;
            cached_temperature = thermal_energy / cached_heat_capacity;
        }
    }

    // ANTINOBLIUM REPLICATION
    if my_next_tile.gases.antinoblium() >= MOLES_GAS_VISIBLE
        && cached_temperature >= REACTION_OPPRESSION_MIN_TEMP
    {
        let antinoblium = my_next_tile.gases.antinoblium();
        let total_moles = my_next_tile.gases.moles();
        let total_not_antinoblium = total_moles - antinoblium;

        let old_heat_capacity = my_next_tile.heat_capacity();
        let thermal_energy_before = cached_temperature * old_heat_capacity;

        let mut reaction_rate =
            (antinoblium / ANTINOBLIUM_CONVERSION_DIVISOR).min(total_not_antinoblium);

        if total_not_antinoblium < 0.0 && total_not_antinoblium > 0.0 {
            reaction_rate = total_not_antinoblium;
            for i in 0..GAS_COUNT {
                if i != GAS_ANTINOBLIUM {
                    my_next_tile.gases.values[i] = 0.0;
                }
            }
            my_next_tile
                .gases
                .set_antinoblium(antinoblium + reaction_rate);
        } else if reaction_rate > 0.0 && total_not_antinoblium > 0.0 {
            for i in 0..GAS_COUNT {
                if i != GAS_ANTINOBLIUM {
                    let reduction =
                        reaction_rate * my_next_tile.gases.values[i] / total_not_antinoblium;
                    my_next_tile.gases.values[i] =
                        (my_next_tile.gases.values[i] - reduction).max(0.0);
                }
            }
            my_next_tile
                .gases
                .set_antinoblium(antinoblium + reaction_rate);
        } else {
            return;
        }

        let new_heat_capacity = my_next_tile.heat_capacity();
        if new_heat_capacity > MINIMUM_HEAT_CAPACITY {
            cached_temperature = (thermal_energy_before / new_heat_capacity).max(TCMB);
        } else {
            cached_temperature = TCMB;
        }

        cached_heat_capacity = fraction * new_heat_capacity;

        thermal_energy = cached_temperature * cached_heat_capacity;
    }

    // MIASMA STERILIZATION
    if cached_temperature >= MIASTER_STERILIZATION_TEMP && my_next_tile.gases.miasma() > 0.0 {
        let water_vapor = my_next_tile.gases.water_vapor();
        let total_moles = my_next_tile.gases.moles();

        if water_vapor / total_moles <= MIASTER_STERILIZATION_MAX_HUMIDITY {
            let miasma = my_next_tile.gases.miasma();
            let cleaned_air = miasma.min(
                MIASTER_STERILIZATION_RATE_BASE
                    + (cached_temperature - MIASTER_STERILIZATION_TEMP)
                        / MIASTER_STERILIZATION_RATE_SCALE,
            );

            if cleaned_air > 0.0 {
                my_next_tile.gases.set_miasma(miasma - cleaned_air);
                my_next_tile
                    .gases
                    .set_oxygen(my_next_tile.gases.oxygen() + cleaned_air);

                cached_heat_capacity = fraction * my_next_tile.heat_capacity();
                let energy_released = MIASTER_STERILIZATION_ENERGY * cleaned_air;
                thermal_energy += energy_released;
                cached_temperature = thermal_energy / cached_heat_capacity;
            }
        }
    }

    // Nitrous Oxide breaking down into nitrogen and oxygen.
    if cached_temperature > SLEEPING_GAS_BREAKDOWN_TEMP && my_next_tile.gases.sleeping_agent() > 0.0
    {
        let reaction_percent = (0.00002
            * (cached_temperature - (0.00001 * (cached_temperature.powi(2)))))
        .max(0.0)
        .min(1.0);
        let nitrous_decomposed = reaction_percent * fraction * my_next_tile.gases.sleeping_agent();

        my_next_tile
            .gases
            .set_sleeping_agent(my_next_tile.gases.sleeping_agent() - nitrous_decomposed);
        my_next_tile
            .gases
            .set_nitrogen(my_next_tile.gases.nitrogen() + nitrous_decomposed);
        my_next_tile
            .gases
            .set_oxygen(my_next_tile.gases.oxygen() + nitrous_decomposed / 2.0);

        // Recalculate heat capacity.
        cached_heat_capacity = fraction * my_next_tile.heat_capacity();
        // Add in the new thermal energy.
        thermal_energy += NITROUS_BREAKDOWN_ENERGY * nitrous_decomposed;
        // Recalculate temperature for any subsequent reactions.
        cached_temperature = thermal_energy / cached_heat_capacity;

        my_next_tile.fuel_burnt += nitrous_decomposed;
    }

    // ZAUKER DECOMPOSITION
    if my_next_tile.gases.nitrogen() >= 0.0 && my_next_tile.gases.zauker() >= 0.0 {
        let nitrogen = my_next_tile.gases.nitrogen();
        let zauker = my_next_tile.gases.zauker();

        let burned_fuel = ZAUKER_DECOMPOSITION_MAX_RATE.min(nitrogen).min(zauker);

        if burned_fuel > 0.0 {
            my_next_tile.gases.set_zauker(zauker - burned_fuel);
            my_next_tile
                .gases
                .set_oxygen(my_next_tile.gases.oxygen() + burned_fuel * 0.3);
            my_next_tile
                .gases
                .set_nitrogen(nitrogen + burned_fuel * 0.7);

            cached_heat_capacity = fraction * my_next_tile.heat_capacity();
            let energy_released = ZAUKER_DECOMPOSITION_ENERGY * burned_fuel;
            thermal_energy += energy_released;
            cached_temperature = thermal_energy / cached_heat_capacity;
            my_next_tile.fuel_burnt += burned_fuel;
        }
    }

    // TRITIUM COMBUSTION
    if cached_temperature > TRITIUM_MINIMUM_BURN_TEMPERATURE
        && my_next_tile.gases.tritium() > 0.0
        && my_next_tile.gases.oxygen() > 0.0
    {
        let tritium = my_next_tile.gases.tritium();
        let oxygen = my_next_tile.gases.oxygen();

        let tritium_burnt = fraction
            * (tritium / FIRE_TRITIUM_BURN_RATE_DELTA)
                .min(oxygen / (FIRE_TRITIUM_BURN_RATE_DELTA * TRITIUM_OXYGEN_FULLBURN))
                .min(tritium)
                .min(oxygen * 2.0);

        if tritium_burnt > 0.0 {
            my_next_tile.gases.set_tritium(tritium - tritium_burnt);
            my_next_tile.gases.set_oxygen(oxygen - tritium_burnt * 0.5);
            my_next_tile
                .gases
                .set_water_vapor(my_next_tile.gases.water_vapor() + tritium_burnt);

            cached_heat_capacity = fraction * my_next_tile.heat_capacity();
            let energy_released = FIRE_TRITIUM_ENERGY_RELEASED * tritium_burnt;
            thermal_energy += energy_released;
            cached_temperature = thermal_energy / cached_heat_capacity;
            my_next_tile.fuel_burnt += tritium_burnt;

            if tritium_burnt > TRITIUM_RADIATION_MINIMUM_MOLES
                && energy_released > TRITIUM_RADIATION_RELEASE_THRESHOLD
            {
                let mut rng = rand::rng();
                let random: f32 = rng.random();
                if random < 0.1 {
                    my_next_tile.updates |= ReasonFlags::RADIATION_PULSE;
                    cached_radiation = cached_radiation
                        .max(tritium_burnt.sqrt() / TRITIUM_RADIATION_RANGE_DIVISOR);
                }
            }
        }
    }

    // Plasmafire!
    if cached_temperature > PLASMA_BURN_MIN_TEMP
        && my_next_tile.gases.toxins() > 0.0
        && my_next_tile.gases.oxygen() > 0.0
    {
        let toxins = my_next_tile.gases.toxins();
        let oxygen = my_next_tile.gases.oxygen();
        let is_super_saturated = (oxygen / toxins) >= SUPER_SATURATION_THRESHOLD;
        // How efficient is the burn?
        // Linear scaling fom 0 to 1 as temperatue goes from minimum to optimal.
        let efficiency = ((cached_temperature - PLASMA_BURN_MIN_TEMP)
            / (PLASMA_BURN_OPTIMAL_TEMP - PLASMA_BURN_MIN_TEMP))
            .max(0.0)
            .min(1.0);

        // How much plasma is available to burn?
        let burnable_plasma = fraction * toxins;
        let burnable_oxygen = fraction * oxygen;

        // Actual burn amount.
        let mut plasma_burnt = efficiency * PLASMA_BURN_MAX_RATIO * hotspot_boost * burnable_plasma;
        if plasma_burnt < PLASMA_BURN_MIN_MOLES {
            // Boost up to the minimum.
            plasma_burnt = PLASMA_BURN_MIN_MOLES.min(burnable_plasma);
        }

        let oxygen_burn_ratio = if is_super_saturated {
            OXYGEN_BURN_RATIO_BASE - efficiency
        } else {
            PLASMA_BURN_OXYGEN_PER_PLASMA
        };
        if plasma_burnt * oxygen_burn_ratio > burnable_oxygen {
            // Restrict based on available oxygen.
            plasma_burnt = burnable_oxygen / PLASMA_BURN_OXYGEN_PER_PLASMA;
        }

        my_next_tile.gases.set_toxins(toxins - plasma_burnt);
        my_next_tile
            .gases
            .set_oxygen(oxygen - (plasma_burnt * oxygen_burn_ratio));

        if is_super_saturated {
            my_next_tile
                .gases
                .set_tritium(my_next_tile.gases.tritium() + plasma_burnt);
        } else {
            my_next_tile
                .gases
                .set_carbon_dioxide(my_next_tile.gases.carbon_dioxide() + plasma_burnt * 0.75);
            my_next_tile
                .gases
                .set_water_vapor(my_next_tile.gases.water_vapor() + plasma_burnt * 0.25);
        }

        // Recalculate heat capacity.
        cached_heat_capacity = fraction * my_next_tile.heat_capacity();
        // THEN we can add in the new thermal energy.
        thermal_energy += PLASMA_BURN_ENERGY * plasma_burnt;

        // (or we would, but this is the last reaction)
        cached_temperature = thermal_energy / cached_heat_capacity;

        my_next_tile.fuel_burnt += plasma_burnt;
    }

    // Hydrogen BURNING, also know as Knallgas, which is Swedish. The more you know.
    if cached_temperature > HYDROGEN_MIN_IGNITE_TEMP
        && my_next_tile.gases.hydrogen() > 0.0
        && my_next_tile.gases.oxygen() > 0.0
    {
        // How efficient is the burn?
        // Linear scaling fom 0 to 1 as temperatue goes from minimum to optimal.
        let efficiency = ((cached_temperature - HYDROGEN_MIN_IGNITE_TEMP)
            / (HYDROGEN_OPTIMAL_BURN_TEMP - HYDROGEN_MIN_IGNITE_TEMP))
            .max(0.5)
            .min(1.0);

        // How much hydrogen is available to burn?
        let burnable_hydrogen = my_next_tile.gases.hydrogen();

        // Actual burn amount.
        let mut hydrogen_burnt =
            efficiency * 2.0 * HYDROGEN_BURN_MAX_RATIO * hotspot_boost * burnable_hydrogen;
        if hydrogen_burnt < PLASMA_BURN_MIN_MOLES {
            // Boost up to the minimum.
            hydrogen_burnt = PLASMA_BURN_MIN_MOLES.min(burnable_hydrogen);
        }
        if hydrogen_burnt * HYDROGEN_BURN_OXYGEN_PER_HYDROGEN
            > fraction * my_next_tile.gases.oxygen()
        {
            // Restrict based on available oxygen.
            hydrogen_burnt =
                fraction * my_next_tile.gases.oxygen() / HYDROGEN_BURN_OXYGEN_PER_HYDROGEN;
        }

        my_next_tile
            .gases
            .set_hydrogen(my_next_tile.gases.hydrogen() - hydrogen_burnt);
        my_next_tile.gases.set_oxygen(
            my_next_tile.gases.oxygen() - hydrogen_burnt * HYDROGEN_BURN_OXYGEN_PER_HYDROGEN,
        );
        my_next_tile
            .gases
            .set_water_vapor(my_next_tile.gases.water_vapor() + hydrogen_burnt);

        // Recalculate heat capacity.
        cached_heat_capacity = fraction * my_next_tile.heat_capacity();
        // THEN we can add in the new thermal energy.
        thermal_energy += HYDROGEN_BURN_ENERGY * hydrogen_burnt;
        // Recalculate temperature for any subsequent reactions.
        // (or we would, but this is the last reaction)
        cached_temperature = thermal_energy / cached_heat_capacity;

        my_next_tile.fuel_burnt += hydrogen_burnt;
    }

    // FREON COMBUSTION
    if cached_temperature >= FREON_TERMINAL_TEMPERATURE
        && cached_temperature <= FREON_MAXIMUM_BURN_TEMPERATURE
        && my_next_tile.gases.freon() > 0.0
        && my_next_tile.gases.oxygen() > 0.0
    {
        let temp_scale = if cached_temperature < FREON_LOWER_TEMPERATURE {
            0.5
        } else {
            ((FREON_MAXIMUM_BURN_TEMPERATURE - cached_temperature)
                / (FREON_MAXIMUM_BURN_TEMPERATURE - FREON_TERMINAL_TEMPERATURE))
                .max(0.0)
                .min(1.0)
        };

        let oxygen_burn_ratio = OXYGEN_BURN_RATIO_BASE - temp_scale;
        let freon = fraction * my_next_tile.gases.freon();
        let oxygen = fraction * my_next_tile.gases.oxygen();

        let mut freon_burnt = if oxygen < freon * FREON_OXYGEN_FULLBURN {
            ((oxygen / FREON_OXYGEN_FULLBURN) / FREON_BURN_RATE_DELTA) * temp_scale
        } else {
            (freon / FREON_BURN_RATE_DELTA) * temp_scale
        };

        freon_burnt = freon_burnt.min(freon).min(oxygen / oxygen_burn_ratio);

        if freon_burnt > 0.0 {
            my_next_tile
                .gases
                .set_freon(my_next_tile.gases.freon() - freon_burnt);
            my_next_tile
                .gases
                .set_oxygen(my_next_tile.gases.oxygen() - freon_burnt * oxygen_burn_ratio);
            my_next_tile
                .gases
                .set_carbon_dioxide(my_next_tile.gases.carbon_dioxide() + freon_burnt);

            cached_heat_capacity = fraction * my_next_tile.heat_capacity();
            let energy_consumed = FIRE_FREON_ENERGY_CONSUMED * freon_burnt;

            let old_temp = cached_temperature;
            let new_temp = ((old_temp * cached_heat_capacity - energy_consumed)
                / cached_heat_capacity)
                .max(TCMB);
            thermal_energy = new_temp * cached_heat_capacity;
            cached_temperature = new_temp;
            my_next_tile.fuel_burnt += freon_burnt;

            if cached_temperature < HOT_ICE_FORMATION_MAXIMUM_TEMPERATURE
                && cached_temperature > HOT_ICE_FORMATION_MINIMUM_TEMPERATURE
            {
                let mut rng = rand::rng();
                if rng.random::<f32>() < HOT_ICE_FORMATION_PROB {
                    my_next_tile.updates |= ReasonFlags::CREATE_HOT_ICE;
                }
            }
            my_next_tile.updates |= ReasonFlags::HOT;
        }
    }

    my_next_tile.radiation_energy += cached_radiation;

    if hotspot_step {
        adjust_hotspot(my_next_tile, thermal_energy - initial_thermal_energy);
    } else {
        my_next_tile.thermal_energy += thermal_energy - initial_thermal_energy;
    }
}

/// Apply the effects of the gas onto the turf itself
pub(crate) fn do_turf_effects(my_next_tile: &mut Tile) {
    // Calculate the water saturation pressure using the Arden Buck equation
    let saturation_pressure: f32;
    let water_vapor: f32 = my_next_tile.gases.water_vapor();

    if water_vapor < 0.0 {
        return;
    }

    let cached_temperature = my_next_tile.thermal_energy / my_next_tile.heat_capacity();
    let temp_diff: f32 = cached_temperature - T0C;

    if cached_temperature > T0C {
        saturation_pressure = 0.61121
            * E.powf(
                (18.678 - (temp_diff / 234.5)) * (temp_diff / (cached_temperature + 257.14 - T0C)),
            );
    } else {
        saturation_pressure = 0.61121
            * E.powf(
                (23.036 - (temp_diff / 333.7)) * (temp_diff / (cached_temperature + 279.82 - T0C)),
            );
    }
    let relative_humidity: f32 = (water_vapor * R_IDEAL_GAS_EQUATION * cached_temperature
        / TILE_VOLUME)
        / saturation_pressure;
    if relative_humidity > 1.0 {
        // Condense all the water we cannot hold
        let condensed_water: f32 = water_vapor - water_vapor / relative_humidity;
        my_next_tile
            .gases
            .set_water_vapor(water_vapor - condensed_water);
        //We lose gas, so we lose the thermal energy it had
        my_next_tile.thermal_energy = cached_temperature * my_next_tile.heat_capacity();
        if water_vapor > WATER_VAPOR_MIN_SATURATION_MOLES {
            my_next_tile.updates |= ReasonFlags::CONDENSATION;
        }
    }
}

/// Apply effects caused by the tile's atmos mode.
pub(crate) fn apply_tile_mode(
    my_next_tile: &mut Tile,
    environments: &Box<[Tile]>,
) -> Result<(), eyre::Error> {
    match my_next_tile.mode {
        AtmosMode::Space => {
            // Space tiles lose all gas and thermal energy every tick.
            for gas in 0..GAS_COUNT {
                my_next_tile.gases.values[gas] = 0.0;
            }
            my_next_tile.gases.set_dirty();
            my_next_tile.thermal_energy = 0.0;
        }
        AtmosMode::ExposedTo { environment_id } => {
            // Exposed tiles reset back to the same state every tick.
            if environment_id as usize > environments.len() {
                return Err(eyre!("Invalid environment ID {}", environment_id));
            }

            let environment = &environments[environment_id as usize];
            my_next_tile.gases.copy_from(&environment.gases);
            my_next_tile.thermal_energy = environment.thermal_energy;
        }
        AtmosMode::Sealed => {
            if my_next_tile.temperature() > SPACE_COOLING_THRESHOLD {
                let excess_thermal_energy = my_next_tile.thermal_energy
                    - SPACE_COOLING_THRESHOLD * my_next_tile.heat_capacity();
                let cooling = (SPACE_COOLING_FLAT
                    + SPACE_COOLING_TEMPERATURE_RATIO * my_next_tile.temperature())
                .min(excess_thermal_energy);
                my_next_tile.thermal_energy -= cooling;
            }
        }
        AtmosMode::NoDecay => {} // No special interactions
    }
    Ok(())
}

// Performs superconduction between two superconductivity-connected tiles.
pub(crate) fn superconduct(my_tile: &mut Tile, their_tile: &mut Tile, is_east: bool, force: bool) {
    // Superconduction is scaled to the smaller directional superconductivity setting of the two
    // tiles.
    let mut transfer_coefficient: f32;
    if force {
        transfer_coefficient = OPEN_HEAT_TRANSFER_COEFFICIENT;
    } else if is_east {
        if !my_tile.wall[AXIS_X] {
            // Atmos flows freely here, no need to superconduct.
            return;
        }
        transfer_coefficient = my_tile
            .superconductivity
            .east
            .min(their_tile.superconductivity.west);
    } else {
        if !my_tile.wall[AXIS_Y] {
            // Atmos flows freely here, no need to superconduct.
            return;
        }
        transfer_coefficient = my_tile
            .superconductivity
            .north
            .min(their_tile.superconductivity.south);
    }

    let my_heat_capacity = my_tile.heat_capacity();
    let their_heat_capacity = their_tile.heat_capacity();
    let my_temperature = my_tile.temperature();
    let their_temperature = their_tile.temperature();
    if transfer_coefficient <= 0.0 || my_heat_capacity <= 0.0 || their_heat_capacity <= 0.0 {
        // Nothing to do.
        return;
    }

    // Temporary workaround to match LINDA better for high temperatures.
    if my_temperature > T20C || their_temperature > T20C {
        transfer_coefficient = (transfer_coefficient * 100.0).min(OPEN_HEAT_TRANSFER_COEFFICIENT);
    }

    // This is the formula from LINDA. I have no idea if it's a good one, I just copied it.
    // Positive means heat flow from us to them.
    // Negative means heat flow from them to us.
    let conduction = transfer_coefficient
        * (my_temperature - their_temperature)
        * my_heat_capacity
        * their_heat_capacity
        / (my_heat_capacity + their_heat_capacity);

    let partial_conduction = conduction / 2.0;

    // Half of the conduction always goes to the overall heat of the tile
    my_tile.thermal_energy -= partial_conduction;
    their_tile.thermal_energy += partial_conduction;

    // The other half can spawn or expand hotspots.
    if conduction > 0.0
        && my_tile.temperature() > PLASMA_BURN_OPTIMAL_TEMP
        && their_tile.temperature() < PLASMA_BURN_OPTIMAL_TEMP
    {
        // Positive: Spawn or expand their hotspot.
        adjust_hotspot(their_tile, partial_conduction);
        my_tile.thermal_energy -= partial_conduction;
    } else if conduction < 0.0
        && my_tile.temperature() < PLASMA_BURN_OPTIMAL_TEMP
        && their_tile.temperature() > PLASMA_BURN_OPTIMAL_TEMP
    {
        // Negative: Spawn or expand my hotspot.
        adjust_hotspot(my_tile, -partial_conduction);
        their_tile.thermal_energy += partial_conduction;
    } else {
        // No need for hotspot adjustment.
        my_tile.thermal_energy -= partial_conduction;
        their_tile.thermal_energy += partial_conduction;
    }
}

pub(crate) fn normalise_hotspot(tile: &mut Tile) {
    if tile.hotspot_volume <= 0.0 || tile.hotspot_temperature <= tile.temperature() {
        tile.hotspot_temperature = 0.0;
        tile.hotspot_volume = 0.0;
        return;
    }

    if tile.hotspot_volume >= 1.0 {
        tile.thermal_energy = tile.hotspot_temperature * tile.heat_capacity();
        tile.hotspot_temperature = 0.0;
        tile.hotspot_volume = 0.0;
        return;
    }

    let optimal_temp = if tile.gases.freon() > 0.5 {
        FREON_OPTIMAL_TEMP
    } else {
        PLASMA_BURN_OPTIMAL_TEMP
    };

    let optimal_thermal_energy = optimal_temp * tile.heat_capacity();
    let hotspot_extra_thermal_energy = tile.hotspot_volume
        * (tile.hotspot_temperature - tile.temperature())
        * tile.heat_capacity();

    if tile.thermal_energy + hotspot_extra_thermal_energy >= optimal_thermal_energy {
        tile.thermal_energy += hotspot_extra_thermal_energy;
        tile.hotspot_temperature = 0.0;
        tile.hotspot_volume = 0.0;
        return;
    }

    let hotspot_thermal_energy =
        tile.hotspot_volume * tile.hotspot_temperature * tile.heat_capacity();

    if tile.hotspot_temperature > optimal_temp {
        tile.hotspot_volume = hotspot_thermal_energy / optimal_thermal_energy;
        tile.hotspot_temperature = optimal_temp;
        return;
    }

    let has_fuel = (tile.gases.toxins() > REACTION_SIGNIFICANCE_MOLES)
        || (tile.gases.tritium() > REACTION_SIGNIFICANCE_MOLES)
        || (tile.gases.hydrogen() > REACTION_SIGNIFICANCE_MOLES)
        || (tile.gases.freon() > REACTION_SIGNIFICANCE_MOLES);

    let min_temp = if tile.gases.freon() > REACTION_SIGNIFICANCE_MOLES {
        FREON_TERMINAL_TEMPERATURE
    } else {
        PLASMA_BURN_MIN_TEMP
    };

    if tile.hotspot_temperature < min_temp
        || !has_fuel
        || tile.gases.oxygen() <= REACTION_SIGNIFICANCE_MOLES
        || tile.temperature() < min_temp
    {
        tile.thermal_energy += hotspot_extra_thermal_energy;
        tile.hotspot_temperature = 0.0;
        tile.hotspot_volume = 0.0;
        return;
    }
}

// Adjusts the hotspot based on the given thermal energy delta.
// For positive values, the energy will first be used to reach PLASMA_BURN_OPTIMAL_TEMP, then
// to expand volume up to 1 (filled), and finally dumped into the tile's thermal energy.
// For negative values, only the hotspot's volume is affected.
pub(crate) fn adjust_hotspot(tile: &mut Tile, thermal_energy_delta: f32) {
    if thermal_energy_delta < 0.0 {
        if tile.hotspot_volume <= 0.0 {
            return;
        }
        let total_heat_needed = tile.heat_capacity() * tile.hotspot_temperature;
        let heat_available = tile.heat_capacity() * tile.hotspot_temperature * tile.hotspot_volume
            + thermal_energy_delta;
        tile.hotspot_volume = (heat_available / total_heat_needed).max(0.0);
    } else if tile.hotspot_volume > 0.0 {
        tile.hotspot_temperature +=
            thermal_energy_delta / (tile.heat_capacity() * tile.hotspot_volume);
    } else if tile.temperature() > PLASMA_BURN_OPTIMAL_TEMP {
        tile.thermal_energy += thermal_energy_delta;
    } else {
        let optimal_temp = if tile.gases.freon() > REACTION_SIGNIFICANCE_MOLES {
            FREON_OPTIMAL_TEMP
        } else {
            PLASMA_BURN_OPTIMAL_TEMP
        };

        let optimal_thermal_energy = optimal_temp * tile.heat_capacity();
        tile.hotspot_temperature = optimal_temp;
        tile.hotspot_volume = thermal_energy_delta / (optimal_thermal_energy - tile.thermal_energy);
    }

    normalise_hotspot(tile);
}
// Yay, tests!
#[cfg(test)]
mod tests {
    use super::*;

    // TODO
}
