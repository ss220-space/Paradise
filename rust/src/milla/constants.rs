/// How many Z levels we allow before being suspicious that the wrong number was sent.
pub(crate) const MAX_Z_LEVELS: i32 = 20;

/// How big is the map? Assumed square.
pub(crate) const MAP_SIZE: usize = 255;

/// One atmosphere, in kPa.
pub(crate) const ONE_ATMOSPHERE: f32 = 101.325;

/// The temperature of space, in Kelvin
pub(crate) const TCMB: f32 = 2.725;

/// 0 degrees Celsius, in Kelvin
pub(crate) const T0C: f32 = 273.15;

/// 20 degrees Celsius, in Kelvin
pub(crate) const T20C: f32 = T0C + 20.0;

/// How well does heat transfer in ideal circumstances?
pub(crate) const OPEN_HEAT_TRANSFER_COEFFICIENT: f32 = 0.4;

/// The constant R from the ideal gas equation.
pub(crate) const R_IDEAL_GAS_EQUATION: f32 = 8.31;

/// How big a tile is, in liters.
pub(crate) const TILE_VOLUME: f32 = 2500.0;

/// How many moles of toxins are needed for a fire to exist. For reasons, this is also how hany
pub(crate) const TOXINS_MIN_VISIBILITY_MOLES: f32 = 0.5;
pub(crate) const SLEEPING_GAS_VISIBILITY_MOLES: f32 = 1.0;
pub(crate) const WATER_VAPOR_VISIBILITY_MOLES: f32 = 2.0;
pub(crate) const TRITIUM_VISIBILITY_MOLES: f32 = 0.25;
pub(crate) const FREON_VISIBILITY_MOLES: f32 = 7.5;
pub(crate) const MIASMA_VISIBILITY_MOLES: f32 = 15.0;
pub(crate) const PROTO_NITRATE_VISIBILITY_MOLES: f32 = 0.25;
pub(crate) const ZAUKER_VISIBILITY_MOLES: f32 = 0.25;
pub(crate) const NITRIUM_VISIBILITY_MOLES: f32 = 0.25;
pub(crate) const HEALIUM_VISIBILITY_MOLES: f32 = 0.25;
pub(crate) const HALON_VISIBILITY_MOLES: f32 = 0.25;
pub(crate) const HYPER_NOBLIUM_VISIBILITY_MOLES: f32 = 0.25;
pub(crate) const ANTINOBLIUM_VISIBILITY_MOLES: f32 = 0.25;

/// How much stuff needs to react before we think hotspots and BYOND care.
pub(crate) const REACTION_SIGNIFICANCE_MOLES: f32 = 0.1;

/// How hot does it need to be for Agent B to work?
pub(crate) const AGENT_B_CONVERSION_TEMP: f32 = 900.0;

/// How hot does it need to be for sleeping gass to break down?
pub(crate) const SLEEPING_GAS_BREAKDOWN_TEMP: f32 = 1400.0;

/// How much water vapor is produced per plasma burnt.
pub(crate) const WATER_VAPOR_PER_PLASMA_BURNT: f32 = 6.0;

pub(crate) const GAS_OXYGEN: usize = 0;
pub(crate) const GAS_CARBON_DIOXIDE: usize = 1;
pub(crate) const GAS_NITROGEN: usize = 2;
pub(crate) const GAS_TOXINS: usize = 3;
pub(crate) const GAS_SLEEPING_AGENT: usize = 4;
pub(crate) const GAS_AGENT_B: usize = 5;
pub(crate) const GAS_HYDROGEN: usize = 6;
pub(crate) const GAS_WATER_VAPOR: usize = 7;
pub(crate) const GAS_TRITIUM: usize = 8;
pub(crate) const GAS_BZ: usize = 9;
pub(crate) const GAS_PLUOXIUM: usize = 10;
pub(crate) const GAS_MIASMA: usize = 11;
pub(crate) const GAS_FREON: usize = 12;
pub(crate) const GAS_NITRIUM: usize = 13;
pub(crate) const GAS_HEALIUM: usize = 14;
pub(crate) const GAS_PROTO_NITRATE: usize = 15;
pub(crate) const GAS_ZAUKER: usize = 16;
pub(crate) const GAS_HALON: usize = 17;
pub(crate) const GAS_HELIUM: usize = 18;
pub(crate) const GAS_ANTINOBLIUM: usize = 19;
pub(crate) const GAS_HYPER_NOBLIUM: usize = 20;

pub(crate) const GAS_COUNT: usize = GAS_HYPER_NOBLIUM + 1;

/// The two axes, Y and X. The order is arbitrary, but may break things if changed.
pub(crate) const AXES: [(i32, i32); 2] = [(1, 0), (0, 1)];

/// The index of the X axis in AXES.
pub(crate) const AXIS_X: usize = 0;
/// The index of the Y axis in AXES.
pub(crate) const AXIS_Y: usize = 1;

/// The four directions: up, down, right, and left. The order is arbitrary, but may break things if changed.
pub(crate) const DIRECTIONS: [(i32, i32); 4] = [(1, 0), (-1, 0), (0, -1), (0, 1)];

/// Gives the axis for each direction.
pub(crate) const DIRECTION_AXIS: [usize; 4] = [0, 0, 1, 1];

// The numbers here are completely wrong for actual gases, but they're what LINDA used, so we'll
// keep them for now.

pub(crate) const SPECIFIC_HEAT_OXYGEN: f32 = 20.0;
pub(crate) const SPECIFIC_HEAT_CARBON_DIOXIDE: f32 = 30.0;
pub(crate) const SPECIFIC_HEAT_NITROGEN: f32 = 20.0;
pub(crate) const SPECIFIC_HEAT_TOXINS: f32 = 200.0;
pub(crate) const SPECIFIC_HEAT_SLEEPING_AGENT: f32 = 40.0;
pub(crate) const SPECIFIC_HEAT_AGENT_B: f32 = 300.0;
pub(crate) const SPECIFIC_HEAT_HYDROGEN: f32 = 15.0;
pub(crate) const SPECIFIC_HEAT_WATER_VAPOR: f32 = 33.0;
pub(crate) const SPECIFIC_HEAT_TRITIUM: f32 = 10.0;
pub(crate) const SPECIFIC_HEAT_BZ: f32 = 20.0;
pub(crate) const SPECIFIC_HEAT_PLUOXIUM: f32 = 80.0;
pub(crate) const SPECIFIC_HEAT_MIASMA: f32 = 20.0;
pub(crate) const SPECIFIC_HEAT_FREON: f32 = 600.0;
pub(crate) const SPECIFIC_HEAT_NITRIUM: f32 = 10.0;
pub(crate) const SPECIFIC_HEAT_HEALIUM: f32 = 10.0;
pub(crate) const SPECIFIC_HEAT_PROTO_NITRATE: f32 = 30.0;
pub(crate) const SPECIFIC_HEAT_ZAUKER: f32 = 350.0;
pub(crate) const SPECIFIC_HEAT_HALON: f32 = 175.0;
pub(crate) const SPECIFIC_HEAT_HELIUM: f32 = 15.0;
pub(crate) const SPECIFIC_HEAT_ANTINOBLIUM: f32 = 1.0;
pub(crate) const SPECIFIC_HEAT_HYPER_NOBLIUM: f32 = 2000.0;

// Convenience array, so we can add loop through gases and calculate heat capacity.
pub(crate) const SPECIFIC_HEATS: [f32; GAS_COUNT] = [
    SPECIFIC_HEAT_OXYGEN,
    SPECIFIC_HEAT_CARBON_DIOXIDE,
    SPECIFIC_HEAT_NITROGEN,
    SPECIFIC_HEAT_TOXINS,
    SPECIFIC_HEAT_SLEEPING_AGENT,
    SPECIFIC_HEAT_AGENT_B,
    SPECIFIC_HEAT_HYDROGEN,
    SPECIFIC_HEAT_WATER_VAPOR,
    SPECIFIC_HEAT_TRITIUM,
    SPECIFIC_HEAT_BZ,
    SPECIFIC_HEAT_PLUOXIUM,
    SPECIFIC_HEAT_MIASMA,
    SPECIFIC_HEAT_FREON,
    SPECIFIC_HEAT_NITRIUM,
    SPECIFIC_HEAT_HEALIUM,
    SPECIFIC_HEAT_PROTO_NITRATE,
    SPECIFIC_HEAT_ZAUKER,
    SPECIFIC_HEAT_HALON,
    SPECIFIC_HEAT_HELIUM,
    SPECIFIC_HEAT_ANTINOBLIUM,
    SPECIFIC_HEAT_HYPER_NOBLIUM,
];

pub(crate) const FIRE_MINIMUM_TEMPERATURE_TO_EXIST: f32 = 100.0 + T0C;

/// How hot does it need to be for a plasma fire to start?
pub(crate) const PLASMA_BURN_MIN_TEMP: f32 = FIRE_MINIMUM_TEMPERATURE_TO_EXIST;

/// How hot does it need to be for a plasma fire to work as well as possible?
pub(crate) const PLASMA_BURN_OPTIMAL_TEMP: f32 = 1370.0 + T0C;

/// How much of the plasma are we willing to burn each tick?
pub(crate) const PLASMA_BURN_MAX_RATIO: f32 = 0.01;

/// How much of the plasma do we burn anyway if the ratio would make it really small?
pub(crate) const PLASMA_BURN_MIN_MOLES: f32 = 0.001;

/// How much of a boost to burn ratio do we give to hotspots?
pub(crate) const PLASMA_BURN_HOTSPOT_RATIO_BOOST: f32 = 10.0;

/// How much oxygen do we use per plasma?
pub(crate) const PLASMA_BURN_OXYGEN_PER_PLASMA: f32 = 0.4;

/// How hot does hydrogen need to be for it to ignite?
pub(crate) const HYDROGEN_MIN_IGNITE_TEMP: f32 = 500.0 + T0C;

/// How hot does hydrogen need to be for it to burn as well as possible?
pub(crate) const HYDROGEN_OPTIMAL_BURN_TEMP: f32 = 2500.0 + T0C;

/// How much of the hydrogen are we willing to burn each tick?
pub(crate) const HYDROGEN_BURN_MAX_RATIO: f32 = 0.07;

/// How much oxygen do we consume for every hydrogen?
pub(crate) const HYDROGEN_BURN_OXYGEN_PER_HYDROGEN: f32 = 0.5;

/// How much thermal energy is produced, in joules per mole of agent b.
pub(crate) const AGENT_B_CONVERSION_ENERGY: f32 = 20_000.0;

/// How much thermal energy is produced, in joules per mole of sleeping agent.
pub(crate) const NITROUS_BREAKDOWN_ENERGY: f32 = 200_000.0;

/// Minimum moles of water vapor required to initiate condensation.
pub(crate) const WATER_VAPOR_MIN_SATURATION_MOLES: f32 = 0.001;

// How much thermal energy is produced, in joules per mole of water vapor.
pub(crate) const WATER_VAPOR_BREAKDOWN_ENERGY: f32 = 200.0;

/// How much thermal energy is produced, in joules per mole of sleeping toxins.
pub(crate) const PLASMA_BURN_ENERGY: f32 = 3_000_000.0;

/// How much thermal energy is produced, in joules per mole of hydrogen.
pub(crate) const HYDROGEN_BURN_ENERGY: f32 = 2_500_000.0;

/// We allow small deviations in tests as our spring chain solution is not exact.
#[cfg(test)]
pub(crate) const TEST_TOLERANCE: f32 = 0.1;

/// When space cooling starts, in Kelvin.
pub(crate) const SPACE_COOLING_THRESHOLD: f32 = T20C;

/// Lose this amount of heat energy per tick if above SPACE_COOLING_THRESHOLD.
pub(crate) const SPACE_COOLING_FLAT: f32 = 200.0;

/// Lose this ratio of heat energy per Kelvin per tick if above SPACE_COOLING_THRESHOLD.
pub(crate) const SPACE_COOLING_TEMPERATURE_RATIO: f32 = 0.4;

/// Tiles with less than this much gas will become empty.
pub(crate) const MINIMUM_NONZERO_MOLES: f32 = 0.1;

/// How many iterations of gas flow are we willing to run per tick?
pub(crate) const MAX_ITERATIONS: usize = 100;

/// When we stop caring about gas changes and end iteration, in moles on a single tile.
pub(crate) const GAS_CHANGE_SIGNIFICANCE: f32 = 0.01;

/// When we stop caring about gas changes and end iteration, roughly as a fraction of the gas.
pub(crate) const GAS_CHANGE_SIGNIFICANCE_FRACTION: f32 = 0.001;

/// When we stop caring about thermal energy changes and end iteration, in thermal energy on a
/// single tile.
pub(crate) const THERMAL_CHANGE_SIGNIFICANCE: f32 = 0.1;

/// When we stop caring about thermal energy changes and end iteration, roughly as a fraction of
/// the thermal energy.
pub(crate) const THERMAL_CHANGE_SIGNIFICANCE_FRACTION: f32 = 0.001;

/// Controls how strongly each type of gas moves towards an even spread, ignoring wind.
/// [0.0, f32::INFINITY]
pub(crate) const DIFFUSION_SPEED: f32 = 0.2;

/// Controls how quickly the wind moves air.
/// (0.0, f32::INFINITY]
pub(crate) const WIND_STRENGTH: f32 = 8.0;

/// Controls how fast the wind changes towards what the current pressur gradient wants.
/// (0.0, 1.0], a value of 0.25 means getting 25% closer every tick.
pub(crate) const WIND_ACCELERATION: f32 = 0.05;

/// Controls how quickly the wind spreads from tile to tile.
/// [0.0, f32::INFINITY]
pub(crate) const WIND_SPEED: f32 = 0.5;

pub(crate) const WIND_SPEED_MULTIPLIER: f32 = WIND_SPEED * BYOND_WIND_MULTIPLIER;

/// A hard cap on how strong wind can become.
/// [0.0, f32::INFINITY]
pub(crate) const MAX_WIND: f32 = f32::INFINITY;

/// How fast should temperature flow?
/// [0.0, f32::INFINITY]
pub(crate) const TEMPERATURE_FLOW_RATE: f32 = 0.2;

/// Direct multiplier on strength of wind reported to BYOND.
/// [0.0, f32::INFINITY]
pub(crate) const BYOND_WIND_MULTIPLIER: f32 = 0.5;

/// The smallest temperature allowed for the purpose of caluclating pressure.
/// Prevents weirdness from absolute-zero gas having no pressure at all.
pub(crate) const MINIMUM_TEMPERATURE_FOR_PRESSURE: f32 = 1.0;

pub(crate) const MINIMUM_MOLE_COUNT: f32 = 0.01;
pub(crate) const MOLES_GAS_VISIBLE: f32 = 0.25;

// Miasma Sterilization
pub(crate) const MIASTER_STERILIZATION_TEMP: f32 = FIRE_MINIMUM_TEMPERATURE_TO_EXIST + 70.0;
pub(crate) const MIASTER_STERILIZATION_MAX_HUMIDITY: f32 = 0.1;
pub(crate) const MIASTER_STERILIZATION_RATE_BASE: f32 = 20.0;
pub(crate) const MIASTER_STERILIZATION_RATE_SCALE: f32 = 20.0;
pub(crate) const MIASTER_STERILIZATION_ENERGY: f32 = 2e3;

// Plasma Fire
pub(crate) const OXYGEN_BURN_RATIO_BASE: f32 = 1.4;
pub(crate) const SUPER_SATURATION_THRESHOLD: f32 = 96.0;

// Hydrogen Fire
pub(crate) const FIRE_HYDROGEN_ENERGY_RELEASED: f32 = 2.8e6;

// Tritium Fire
pub(crate) const TRITIUM_MINIMUM_BURN_TEMPERATURE: f32 = FIRE_MINIMUM_TEMPERATURE_TO_EXIST;
pub(crate) const FIRE_TRITIUM_ENERGY_RELEASED: f32 = FIRE_HYDROGEN_ENERGY_RELEASED;
pub(crate) const TRITIUM_OXYGEN_FULLBURN: f32 = 10.0;
pub(crate) const FIRE_TRITIUM_BURN_RATE_DELTA: f32 = 2.0;
pub(crate) const TRITIUM_RADIATION_MINIMUM_MOLES: f32 = 0.1;
pub(crate) const TRITIUM_RADIATION_RELEASE_THRESHOLD: f32 = FIRE_TRITIUM_ENERGY_RELEASED;
pub(crate) const TRITIUM_RADIATION_RANGE_DIVISOR: f32 = 0.5;

// Freon Fire
pub(crate) const FREON_MAXIMUM_BURN_TEMPERATURE: f32 = 283.0;
pub(crate) const FREON_LOWER_TEMPERATURE: f32 = 60.0;
pub(crate) const FREON_TERMINAL_TEMPERATURE: f32 = 20.0;
pub(crate) const FREON_OXYGEN_FULLBURN: f32 = 10.0;
pub(crate) const FREON_BURN_RATE_DELTA: f32 = 4.0;
pub(crate) const FIRE_FREON_ENERGY_CONSUMED: f32 = 3e5;
pub(crate) const HOT_ICE_FORMATION_MAXIMUM_TEMPERATURE: f32 = 160.0;
pub(crate) const HOT_ICE_FORMATION_MINIMUM_TEMPERATURE: f32 = 120.0;
pub(crate) const HOT_ICE_FORMATION_PROB: f32 = 0.02;

// N2O Formation
pub(crate) const N2O_FORMATION_MIN_TEMPERATURE: f32 = 200.0;
pub(crate) const N2O_FORMATION_MAX_TEMPERATURE: f32 = 250.0;
pub(crate) const N2O_FORMATION_ENERGY: f32 = 10000.0;

// N2O Decomposition
pub(crate) const N2O_DECOMPOSITION_ENERGY: f32 = 200000.0;

// BZ Formation
pub(crate) const BZ_FORMATION_MAX_TEMPERATURE: f32 = FIRE_MINIMUM_TEMPERATURE_TO_EXIST - 60.0;
pub(crate) const BZ_FORMATION_ENERGY: f32 = 80000.0;

// Pluoxium Formation
pub(crate) const PLUOXIUM_FORMATION_MIN_TEMP: f32 = 50.0;
pub(crate) const PLUOXIUM_FORMATION_MAX_TEMP: f32 = T0C;
pub(crate) const PLUOXIUM_FORMATION_MAX_RATE: f32 = 5.0;
pub(crate) const PLUOXIUM_FORMATION_ENERGY: f32 = 250.0;

// Nitrium Formation
pub(crate) const NITRIUM_FORMATION_MIN_TEMP: f32 = 1500.0;
pub(crate) const NITRIUM_FORMATION_TEMP_DIVISOR: f32 = FIRE_MINIMUM_TEMPERATURE_TO_EXIST * 8.0;
pub(crate) const NITRIUM_FORMATION_ENERGY: f32 = 100000.0;

// Nitrium Decomposition
pub(crate) const NITRIUM_DECOMPOSITION_MAX_TEMP: f32 = T0C + 70.0;
pub(crate) const NITRIUM_DECOMPOSITION_TEMP_DIVISOR: f32 = FIRE_MINIMUM_TEMPERATURE_TO_EXIST * 8.0;
pub(crate) const NITRIUM_DECOMPOSITION_ENERGY: f32 = 30000.0;

// Freon Formation
pub(crate) const FREON_FORMATION_MIN_TEMPERATURE: f32 = FIRE_MINIMUM_TEMPERATURE_TO_EXIST + 100.0;

// Hyper-Noblium Formation
pub(crate) const NOBLIUM_FORMATION_MIN_TEMP: f32 = TCMB;
pub(crate) const NOBLIUM_FORMATION_MAX_TEMP: f32 = 15.0;
pub(crate) const NOBLIUM_FORMATION_ENERGY: f32 = 2e7;

// Halon
pub(crate) const HALON_COMBUSTION_ENERGY: f32 = 2500.0;
pub(crate) const HALON_COMBUSTION_MIN_TEMPERATURE: f32 = T0C + 70.0;
pub(crate) const HALON_COMBUSTION_TEMPERATURE_SCALE: f32 = FIRE_MINIMUM_TEMPERATURE_TO_EXIST * 10.0;
pub(crate) const HALON_COMBUSTION_MINIMUM_RESIN_MOLES: f32 =
    0.99 * HALON_COMBUSTION_MIN_TEMPERATURE / HALON_COMBUSTION_TEMPERATURE_SCALE;
pub(crate) const HALON_COMBUSTION_RESIN_VOLUME: f32 = 1.0;

// Healium Formation
pub(crate) const HEALIUM_FORMATION_MIN_TEMP: f32 = 25.0;
pub(crate) const HEALIUM_FORMATION_MAX_TEMP: f32 = 300.0;
pub(crate) const HEALIUM_FORMATION_ENERGY: f32 = 9000.0;

// Zauker Formation
pub(crate) const ZAUKER_FORMATION_MIN_TEMPERATURE: f32 = 50000.0;
pub(crate) const ZAUKER_FORMATION_MAX_TEMPERATURE: f32 = 75000.0;
pub(crate) const ZAUKER_FORMATION_TEMPERATURE_SCALE: f32 = 5e-6;
pub(crate) const ZAUKER_FORMATION_ENERGY: f32 = 5000.0;

// Zauker Decomposition
pub(crate) const ZAUKER_DECOMPOSITION_MAX_RATE: f32 = 20.0;
pub(crate) const ZAUKER_DECOMPOSITION_ENERGY: f32 = 460.0;

// Proto-Nitrate Formation
pub(crate) const PN_FORMATION_MIN_TEMPERATURE: f32 = 5000.0;
pub(crate) const PN_FORMATION_MAX_TEMPERATURE: f32 = 10000.0;
pub(crate) const PN_FORMATION_TEMPERATURE_SCALE: f32 = 5e-3;
pub(crate) const PN_FORMATION_ENERGY: f32 = 650.0;

// Proto-Nitrate Hydrogen Conversion
pub(crate) const PN_HYDROGEN_CONVERSION_THRESHOLD: f32 = 150.0;
pub(crate) const PN_HYDROGEN_CONVERSION_MAX_RATE: f32 = 5.0;
pub(crate) const PN_HYDROGEN_CONVERSION_ENERGY: f32 = 2500.0;

// Proto-Nitrate Tritium Conversion
pub(crate) const PN_TRITIUM_CONVERSION_MIN_TEMP: f32 = 150.0;
pub(crate) const PN_TRITIUM_CONVERSION_MAX_TEMP: f32 = 340.0;
pub(crate) const PN_TRITIUM_CONVERSION_ENERGY: f32 = 10000.0;
pub(crate) const PN_TRITIUM_CONVERSION_RAD_RELEASE_THRESHOLD: f32 = 10000.0;
pub(crate) const PN_TRITIUM_RAD_RANGE_DIVISOR: f32 = 0.5;

// Proto-Nitrate BZ Response
pub(crate) const PN_BZASE_MIN_TEMP: f32 = 260.0;
pub(crate) const PN_BZASE_MAX_TEMP: f32 = 280.0;
pub(crate) const PN_BZASE_ENERGY: f32 = 60000.0;
pub(crate) const PN_BZASE_RAD_RELEASE_THRESHOLD: f32 = 60000.0;
pub(crate) const PN_BZASE_RAD_RANGE_DIVISOR: f32 = 1.5;
pub(crate) const PN_BZASE_NUCLEAR_PARTICLE_DIVISOR: f32 = 5.0;
pub(crate) const PN_BZASE_NUCLEAR_PARTICLE_MAXIMUM: i32 = 6;
pub(crate) const PN_BZASE_NUCLEAR_PARTICLE_RADIATION_ENERGY_CONVERSION: f32 = 2.5;

// Antinoblium
pub(crate) const ANTINOBLIUM_CONVERSION_DIVISOR: f32 = 90.0;
pub(crate) const REACTION_OPPRESSION_MIN_TEMP: f32 = 20.0;

pub(crate) const MOLAR_ACCURACY: f32 = 0.0001;

pub const FREON_OPTIMAL_TEMP: f32 = 283.0;

pub const MINIMUM_HEAT_CAPACITY: f32 = 0.0003;
