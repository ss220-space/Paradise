#define GAS_O2 (1 << 0)
#define GAS_N2 (1 << 1)
#define GAS_PL (1 << 2)
#define GAS_CO2 (1 << 3)
#define GAS_N2O (1 << 4)
#define GAS_A_B (1 << 5)
#define GAS_H2 (1 << 6)
#define GAS_H20 (1 << 7)

//ATMOS
//stuff you should probably leave well alone!
/// kPa*L/(K*mol)
#define R_IDEAL_GAS_EQUATION 8.31
/// kPa
#define ONE_ATMOSPHERE 101.325
/// -270.3degC
#define TCMB 2.7
/// -48.15degC
#define TCRYO 265
/// 0degC
#define T0C 273.15
/// 20degC
#define T20C 293.15
/// 100degC
#define T100C 373.15

#define T1000K 1000
#define T1500K 1500
#define T999K 999
#define T2500K 2500
#define T500K 500
#define T3500K 3500
#define T3800K 3800

#define T300K 300

///This is a number I got by quickly searching up the temperature to melt iron/glass, though not really realistic.
///This is used for places where lighters should not be hot enough to be used as a welding tool on.
#define HIGH_TEMPERATURE_REQUIRED T1500K

///Minimum temperature for items on fire
#define BURNING_ITEM_MINIMUM_TEMPERATURE (150 + T0C)

/// -14C - Temperature used for kitchen cold room, medical freezer, etc.
#define COLD_ROOM_TEMP 259.15
/// -193C - Temperature used for server rooms
#define SERVER_ROOM_TEMP 80

#define MOLES_CELLSTANDARD (ONE_ATMOSPHERE*CELL_VOLUME/(T20C*R_IDEAL_GAS_EQUATION)) //moles in a 2.5 m^3 cell at 101.325 Pa and 20 degC
#define M_CELL_WITH_RATIO (MOLES_CELLSTANDARD * 0.005) //compared against for superconductivity
#define O2STANDARD 0.21 //percentage of oxygen in a normal mixture of air
#define N2STANDARD 0.79 //same but for nitrogen
#define MOLES_O2STANDARD (MOLES_CELLSTANDARD*O2STANDARD) // O2 standard value (21%)
#define MOLES_N2STANDARD (MOLES_CELLSTANDARD*N2STANDARD) // N2 standard value (79%)
#define CELL_VOLUME 2500 //liters in a cell
//liters in a normal breath
#define BREATH_VOLUME 1
#define BREATH_PERCENTAGE (BREATH_VOLUME/CELL_VOLUME) //Amount of air to take a from a tile

//EXCITED GROUPS
#define EXCITED_GROUP_BREAKDOWN_CYCLES 10 //number of FULL air controller ticks before an excited group breaks down (averages gas contents across turfs)
#define EXCITED_GROUP_DISMANTLE_CYCLES 20 //number of FULL air controller ticks before an excited group dismantles and removes its turfs from active
#define MINIMUM_AIR_RATIO_TO_SUSPEND 0.005 //Minimum ratio of air that must move to/from a tile to suspend group processing
#define MINIMUM_AIR_TO_SUSPEND (MOLES_CELLSTANDARD * MINIMUM_AIR_RATIO_TO_SUSPEND)	//Minimum amount of air that has to move before a group processing can be suspended
#define MINIMUM_MOLES_DELTA_TO_MOVE (MOLES_CELLSTANDARD * MINIMUM_AIR_RATIO_TO_SUSPEND) //Either this must be active
#define MINIMUM_TEMPERATURE_TO_MOVE (T20C + 100) //or this (or both, obviously)
#define MINIMUM_TEMPERATURE_RATIO_TO_SUSPEND 0.012
#define MINIMUM_TEMPERATURE_DELTA_TO_SUSPEND 4 //Minimum temperature difference before group processing is suspended
#define MINIMUM_TEMPERATURE_DELTA_TO_CONSIDER 0.5 //Minimum temperature difference before the gas temperatures are just set to be equal
#define MINIMUM_TEMPERATURE_FOR_SUPERCONDUCTION (T20C + 10)
#define MINIMUM_TEMPERATURE_START_SUPERCONDUCTION (T20C + 200)


// Body temperature warning icons
/// The temperature the red icon is displayed.
#define HEAT_WARNING_3 (BODYTEMP_HEAT_DAMAGE_LIMIT + 360) //+700k
/// The temperature the orange icon is displayed.
#define HEAT_WARNING_2 (BODYTEMP_HEAT_DAMAGE_LIMIT + 120) //460K
/// The temperature the yellow icon is displayed.
#define HEAT_WARNING_1 (BODYTEMP_HEAT_DAMAGE_LIMIT) //340K
/// The temperature the light green icon is displayed.
#define COLD_WARNING_1 (BODYTEMP_COLD_DAMAGE_LIMIT) //270k
/// The temperature the cyan icon is displayed.
#define COLD_WARNING_2 (BODYTEMP_COLD_DAMAGE_LIMIT - 70) //200k
/// The temperature the blue icon is displayed.
#define COLD_WARNING_3 (BODYTEMP_COLD_DAMAGE_LIMIT - 150) //120k

//HEAT TRANSFER COEFFICIENTS
//Must be between 0 and 1. Values closer to 1 equalize temperature faster
//Capped at OPEN_HEAT_TRANSFER_COEFFICIENT, both here and in Rust.

#define WALL_HEAT_TRANSFER_COEFFICIENT 0.0
#define DOOR_HEAT_TRANSFER_COEFFICIENT 0.001
#define OPEN_HEAT_TRANSFER_COEFFICIENT 0.4
#define WINDOW_HEAT_TRANSFER_COEFFICIENT 0.001
// This looks silly, but it's for clarity when reading elsewhere.
#define ZERO_HEAT_TRANSFER_COEFFICIENT 0.0

#define HEAT_CAPACITY_VACUUM 700000 //a hack to help make vacuums "cold", sacrificing realism for gameplay

//FIRE
#define FIRE_MINIMUM_TEMPERATURE_TO_SPREAD (150 + T0C)
#define FIRE_MINIMUM_TEMPERATURE_TO_EXIST (100 + T0C)
#define FIRE_SPREAD_RADIOSITY_SCALE 0.85
#define FIRE_CARBON_ENERGY_RELEASED 500000 //Amount of heat released per mole of burnt carbon into the tile
#define FIRE_PLASMA_ENERGY_RELEASED 3000000 //Amount of heat released per mole of burnt plasma into the tile
#define FIRE_GROWTH_RATE 40000 //For small fires

//Plasma fire properties
#define OXYGEN_BURN_RATE_BASE 1.4
#define PLASMA_BURN_RATE_DELTA 4
#define PLASMA_MINIMUM_BURN_TEMPERATURE (100 + T0C)
#define PLASMA_UPPER_TEMPERATURE (1370 + T0C)
#define PLASMA_MINIMUM_OXYGEN_NEEDED 2
#define PLASMA_MINIMUM_OXYGEN_PLASMA_RATIO 30
#define PLASMA_OXYGEN_FULLBURN 10

//GASES
#define MIN_TOXIC_GAS_DAMAGE 1
#define MAX_TOXIC_GAS_DAMAGE 10

//HYDROGEN
#define HYDROGEN_BURN_ENERGY 2500000
#define HYDROGEN_MIN_IGNITE_TEMP 500

//WATER VAPOR
#define WATER_VAPOR_PER_PLASMA_BURNT 6
#define WATER_VAPOR_REACTION_ENERGY 200
#define H2_NEEDED_FOR_H2O 2
#define O2_NEEDED_FOR_H2O 1

// Pressure limits.
#define HAZARD_HIGH_PRESSURE 550 //This determins at what pressure the ultra-high pressure red icon is displayed. (This one is set as a constant)
#define WARNING_HIGH_PRESSURE 325 //This determins when the orange pressure icon is displayed (it is 0.7 * HAZARD_HIGH_PRESSURE)
#define WARNING_LOW_PRESSURE 50 //This is when the gray low pressure icon is displayed. (it is 2.5 * HAZARD_LOW_PRESSURE)
#define HAZARD_LOW_PRESSURE 20 //This is when the black ultra-low pressure icon is displayed. (This one is set as a constant)

#define TEMPERATURE_DAMAGE_COEFFICIENT 1.5 //This is used in handle_temperature_damage() for humans, and in reagents that affect body temperature. Temperature damage is multiplied by this amount.

#define BODYTEMP_NORMAL 310.15 //The natural temperature for a body
#define BODYTEMP_AUTORECOVERY_DIVISOR 12 //This is the divisor which handles how much of the temperature difference between the current body temperature and 310.15K (optimal temperature) humans auto-regenerate each tick. The higher the number, the slower the recovery. This is applied each tick, so long as the mob is alive.
#define BODYTEMP_AUTORECOVERY_MINIMUM 10 //Minimum amount of kelvin moved toward 310.15K per tick. So long as abs(310.15 - bodytemp) is more than 50.
#define BODYTEMP_COLD_DIVISOR 6 //Similar to the BODYTEMP_AUTORECOVERY_DIVISOR, but this is the divisor which is applied at the stage that follows autorecovery. This is the divisor which comes into play when the human's loc temperature is lower than their body temperature. Make it lower to lose bodytemp faster.
#define BODYTEMP_HEAT_DIVISOR 6 //Similar to the BODYTEMP_AUTORECOVERY_DIVISOR, but this is the divisor which is applied at the stage that follows autorecovery. This is the divisor which comes into play when the human's loc temperature is higher than their body temperature. Make it lower to gain bodytemp faster.
#define BODYTEMP_COOLING_MAX -30 //The maximum number of degrees that your body can cool in 1 tick, when in a cold area.
#define BODYTEMP_HEATING_MAX 30 //The maximum number of degrees that your body can heat up in 1 tick, when in a hot area.

#define BODYTEMP_HEAT_DAMAGE_LIMIT (BODYTEMP_NORMAL + 50) // The limit the human body can take before it starts taking damage from heat.
#define BODYTEMP_COLD_DAMAGE_LIMIT (BODYTEMP_NORMAL - 50) // The limit the human body can take before it starts taking damage from coldness.

#define SPACE_HELM_MIN_TEMP_PROTECT 2.0 //what min_cold_protection_temperature is set to for space-helmet quality headwear. MUST NOT BE 0.
#define SPACE_HELM_MAX_TEMP_PROTECT 1500 //Thermal insulation works both ways /Malkevin
#define SPACE_SUIT_MIN_TEMP_PROTECT 2.0 //what min_cold_protection_temperature is set to for space-suit quality jumpsuits or suits. MUST NOT BE 0.
#define SPACE_SUIT_MAX_TEMP_PROTECT 1500

#define FIRE_SUIT_MIN_TEMP_PROTECT 60 //Cold protection for firesuits
#define FIRE_SUIT_MAX_TEMP_PROTECT 30000 //what max_heat_protection_temperature is set to for firesuit quality suits. MUST NOT BE 0.
#define FIRE_HELM_MIN_TEMP_PROTECT 60 //Cold protection for fire helmets
#define FIRE_HELM_MAX_TEMP_PROTECT 30000 //for fire helmet quality items (red and white hardhats)

#define COAT_MIN_TEMP_PROTECT (T0C - 60) //Cold protection for coats
#define COAT_HOOD_MIN_TEMP_PROTECT (T0C - 60) //Cold protection for coat hoods

#define FIRE_IMMUNITY_MAX_TEMP_PROTECT 35000 //what max_heat_protection_temperature is set to for firesuit quality suits and helmets. MUST NOT BE 0.

#define HELMET_MIN_TEMP_PROTECT 160 //For normal helmets
#define HELMET_MAX_TEMP_PROTECT 600 //For normal helmets
#define ARMOR_MIN_TEMP_PROTECT 160 //For armor
#define ARMOR_MAX_TEMP_PROTECT 600 //For armor

#define GLOVES_MIN_TEMP_PROTECT 2.0 //For some gloves (black and)
#define GLOVES_MAX_TEMP_PROTECT 1500 //For some gloves
#define SHOES_MIN_TEMP_PROTECT 2.0 //For gloves
#define SHOES_MAX_TEMP_PROTECT 1500 //For gloves

#define PRESSURE_DAMAGE_COEFFICIENT 8 //The amount of pressure damage someone takes is equal to (pressure / HAZARD_HIGH_PRESSURE)*PRESSURE_DAMAGE_COEFFICIENT, with the maximum of MAX_PRESSURE_DAMAGE
#define MAX_HIGH_PRESSURE_DAMAGE 8
#define LOW_PRESSURE_DAMAGE 8 //The amounb of damage someone takes when in a low pressure area (The pressure threshold is so low that it doesn't make sense to do any calculations, so it just applies this flat value).

#define COLD_SLOWDOWN_FACTOR 20 //Humans are slowed by the difference between bodytemp and BODYTEMP_COLD_DAMAGE_LIMIT divided by this

//PIPES
// Atmos pipe limits
#define MAX_OUTPUT_PRESSURE 4500 // (kPa) What pressure pumps and powered equipment max out at.
#define MAX_TRANSFER_RATE 200 // (L/s) Maximum speed powered equipment can work at.

//TANKS
#define TANK_LEAK_PRESSURE (30.*ONE_ATMOSPHERE) //Tank starts leaking
#define TANK_RUPTURE_PRESSURE (40.*ONE_ATMOSPHERE) //Tank spills all contents into atmosphere
#define TANK_FRAGMENT_PRESSURE (50.*ONE_ATMOSPHERE) //Boom 3x3 base explosion
#define TANK_FRAGMENT_SCALE (10.*ONE_ATMOSPHERE) //+1 for each SCALE kPa aboe threshold
#define TANK_MAX_RELEASE_PRESSURE (ONE_ATMOSPHERE * 3)
#define TANK_MIN_RELEASE_PRESSURE 0
#define TANK_DEFAULT_RELEASE_PRESSURE 16

// Atmos alarm defines
#define ATMOS_ALARM_NONE 0
#define ATMOS_ALARM_WARNING 1
#define ATMOS_ALARM_DANGER 2

#define MINIMUM_MOLE_COUNT 0.01

// Ventcrawling bitflags, handled in var/vent_movement
///Allows for ventcrawling to occur. All atmospheric machines have this flag on by default. Cryo is the exception
#define VENTCRAWL_ALLOWED (1<<0)
///Allows mobs to enter or leave from atmospheric machines. On for passive, unary, and scrubber vents.
#define VENTCRAWL_ENTRANCE_ALLOWED (1<<1)
///Used to check if a machinery is visible. Called by update_pipe_vision(). On by default for all except cryo.
#define VENTCRAWL_CAN_SEE (1<<2)

GLOBAL_LIST_EMPTY(gas_sensors)

#define SENSOR_SCAN_PRESSURE (1<<0)
#define SENSOR_SCAN_TEMPERATURE (1<<1)

#define SENSOR_COMPOSITION_OXYGEN (1<<2)    // 4
#define SENSOR_COMPOSITION_TOXINS (1<<3)    // 8
#define SENSOR_COMPOSITION_NITROGEN (1<<4)  // 16
#define SENSOR_COMPOSITION_CO2 (1<<5)       // 32
#define SENSOR_COMPOSITION_N2O (1<<6)       // 64
#define SENSOR_COMPOSITION_H2 (1<<7)        // 128
#define SENSOR_COMPOSITION_H2O (1<<8)       // 256
#define SENSOR_COMPOSITION_AGENT_B (1<<9)   // 512
#define SENSOR_COMPOSITION_TRITIUM (1<<10)  // 1024
#define SENSOR_COMPOSITION_BZ (1<<11)       // 2048
#define SENSOR_COMPOSITION_PLUOXIUM (1<<12) // 4096
#define SENSOR_COMPOSITION_MIASMA (1<<13)   // 8192
#define SENSOR_COMPOSITION_FREON (1<<14)    // 16384
#define SENSOR_COMPOSITION_NITRIUM (1<<15)  // 32768
#define SENSOR_COMPOSITION_HEALIUM (1<<16)  // 65536
#define SENSOR_COMPOSITION_PROTO_NITRATE (1<<17) // 131072
#define SENSOR_COMPOSITION_ZAUKER (1<<18)   // 262144
#define SENSOR_COMPOSITION_HALON (1<<19)    // 524288
#define SENSOR_COMPOSITION_HELIUM (1<<20)   // 1048576
#define SENSOR_COMPOSITION_ANTINOBLIUM (1<<21) // 2097152
#define SENSOR_COMPOSITION_HYPERNOBLIUM (1<<22) // 4194304

/// Maximum germ level you can reach by standing still
#define GERM_LEVEL_AMBIENT 110
/// Maximum germ level you can reach by running around
#define GERM_LEVEL_MOVE_CAP 200

// Atmos stuff that fucking terrifies me
#define LINDA_SPAWN_TOXINS (1<<1)
#define LINDA_SPAWN_OXYGEN (1<<2)
#define LINDA_SPAWN_CO2 (1<<3)
#define LINDA_SPAWN_NITROGEN (1<<4)
#define LINDA_SPAWN_N2O (1<<5)
#define LINDA_SPAWN_AGENT_B (1<<6)
#define LINDA_SPAWN_AIR (1<<7)
#define LINDA_SPAWN_HEAT (1<<8)
#define LINDA_SPAWN_HYDROGEN (1<<9)
#define LINDA_SPAWN_WATER_VAPOR (1<<10)
#define LINDA_SPAWN_TRITIUM (1<<11)
#define LINDA_SPAWN_BZ (1<<12)
#define LINDA_SPAWN_PLUOXIUM (1<<13)
#define LINDA_SPAWN_MIASMA (1<<14)
#define LINDA_SPAWN_FREON (1<<15)
#define LINDA_SPAWN_NITRIUM (1<<16)
#define LINDA_SPAWN_HEALIUM (1<<17)
#define LINDA_SPAWN_PROTO_NITRATE (1<<18)
#define LINDA_SPAWN_ZAUKER (1<<19)
#define LINDA_SPAWN_HALON (1<<20)
#define LINDA_SPAWN_HELIUM (1<<21)
#define LINDA_SPAWN_ANTINOBLIUM (1<<22)
#define LINDA_SPAWN_HYPER_NOBLIUM (1<<23)

//LAVALAND
#define LAVALAND_EQUIPMENT_EFFECT_PRESSURE 50 //what pressure you have to be under to increase the effect of equipment meant for lavaland
#define LAVALAND_TEMPERATURE 300
#define LAVALAND_OXYGEN 14
#define LAVALAND_NITROGEN 23


// Reactions
#define N2O_DECOMPOSITION_MIN_ENERGY 1400
#define N2O_DECOMPOSITION_ENERGY_RELEASED 200000
/// The coefficient a for a function of the form: 1 - (a / (x + c)^2) which gives a decomposition rate of 0.5 at 50000 Kelvin
/// And a decomposition close to 0 at 1400 Kelvin
#define N2O_DECOMPOSITION_COEFFICIENT_A 1.376651173e10
/// The coefficient c for a function of the form: 1 - (a / (x + c)^2) which gives a decomposition rate of 0.5 at 50000 Kelvin
/// And a decomposition rate close to 0 at 1400 Kelvin
#define N2O_DECOMPOSITION_COEFFICIENT_C 115930.77913
/// Agent B starts working at this temperature
#define AGENT_B_CONVERSION_MIN_TEMP 900
/// Agent B released this much energy per mole of CO2 converted to O2
#define AGENT_B_CONVERSION_ENERGY_RELEASED 20000

// From milla/src/lib.rs
#define ATMOS_MODE_SPACE 0
#define ATMOS_MODE_SEALED 1
#define ATMOS_MODE_EXPOSED_TO_ENVIRONMENT 2

/// Lavaland environment: hot, low pressure.
#define ENVIRONMENT_LAVALAND "lavaland"
/// Temperate environment: Normal atmosphere, 20 C.
#define ENVIRONMENT_TEMPERATE "temperate"
/// Cold environment: Normal atmosphere, -93 C.
#define ENVIRONMENT_COLD "cold"

/// How far away should we load the pressure HUD data from MILLA?
#define PRESSURE_HUD_LOAD_RADIUS 15

/// How far away should we send the pressure HUD to the player?
#define PRESSURE_HUD_RADIUS 12


#define DONT_PASS_EXTERNAL_PRESURE_BOUND (1<<0)
#define DONT_PASS_INPUT_PRESURE_MIN (1<<1)
#define DONT_PASS_OUTPUT_PRESURE_MAX (1<<2)


/// The threshold of the tritium combustion's radiation. Lower values means it will be able to penetrate through more structures.
#define ATMOS_RADIATION_THRESHOLD 0.3

/// Maximum range a radiation pulse is allowed to be from a gas reaction.
#define GAS_REACTION_MAXIMUM_RADIATION_PULSE_RANGE 20


// MILLA

// Indexes for Tiles and InterestingTiles
// Must match the order in milla/src/model.rs
#define MILLA_INDEX_AIRTIGHT_DIRECTIONS 1
#define MILLA_INDEX_OXYGEN 2
#define MILLA_INDEX_CARBON_DIOXIDE 3
#define MILLA_INDEX_NITROGEN 4
#define MILLA_INDEX_TOXINS 5
#define MILLA_INDEX_SLEEPING_AGENT 6
#define MILLA_INDEX_AGENT_B 7
#define MILLA_INDEX_HYDROGEN 8
#define MILLA_INDEX_WATER_VAPOR 9
#define MILLA_INDEX_TRITIUM 10
#define MILLA_INDEX_BZ 11
#define MILLA_INDEX_PLUOXIUM 12
#define MILLA_INDEX_MIASMA 13
#define MILLA_INDEX_FREON 14
#define MILLA_INDEX_NITRIUM 15
#define MILLA_INDEX_HEALIUM 16
#define MILLA_INDEX_PROTO_NITRATE 17
#define MILLA_INDEX_ZAUKER 18
#define MILLA_INDEX_HALON 19
#define MILLA_INDEX_HELIUM 20
#define MILLA_INDEX_ANTINOBLIUM 21
#define MILLA_INDEX_HYPER_NOBLIUM 22
#define MILLA_INDEX_ATMOS_MODE 23
#define MILLA_INDEX_ENVIRONMENT_ID 24
#define MILLA_INDEX_SUPERCONDUCTIVITY_NORTH 25
#define MILLA_INDEX_SUPERCONDUCTIVITY_EAST 26
#define MILLA_INDEX_SUPERCONDUCTIVITY_SOUTH 27
#define MILLA_INDEX_SUPERCONDUCTIVITY_WEST 28
#define MILLA_INDEX_INNATE_HEAT_CAPACITY 29
#define MILLA_INDEX_TEMPERATURE 30
#define MILLA_INDEX_HOTSPOT_TEMPERATURE 31
#define MILLA_INDEX_HOTSPOT_VOLUME 32
#define MILLA_INDEX_WIND_X 33
#define MILLA_INDEX_WIND_Y 34
#define MILLA_INDEX_FUEL_BURNT 35

/// The number of values per tile.
#define MILLA_TILE_SIZE MILLA_INDEX_FUEL_BURNT

// These are only for InterestingTiles.
#define MILLA_INDEX_TURF 36
#define MILLA_INDEX_INTERESTING_REASONS 37
#define MILLA_INDEX_AIRFLOW_X 38
#define MILLA_INDEX_AIRFLOW_Y 39
#define MILLA_INDEX_RADIATION_ENERGY 40
#define MILLA_INDEX_HALLUCINATION_STRENGTH 41
#define MILLA_INDEX_NUCLEAR_PARTICLES 42

/// The number of values per interesting tile.
#define MILLA_INTERESTING_TILE_SIZE MILLA_INDEX_NUCLEAR_PARTICLES
/// Interesting because it needs a display update.
#define MILLA_INTERESTING_REASON_DISPLAY (1<<0)
/// Interesting because it's hot enough to start a fire. Excludes normal-temperature Lavaland tiles without an active fire.
#define MILLA_INTERESTING_REASON_HOT (1<<1)
/// Interesting because it has wind that can push stuff around.
#define MILLA_INTERESTING_REASON_WIND (1<<2)
/// Interesting because it has water vapor condensation
#define MILLA_INTERESTING_REASON_CONDENSATION (1<<3)
/// Interesting because it has radiation pulse
#define MILLA_INTERESTING_REASON_RADIATION_PULSE (1<<4)
/// Interesting because it can create hot ice
#define MILLA_INTERESTING_REASON_CREATE_HOT_ICE (1<<5)
/// Interesting because it can create resin
#define MILLA_INTERESTING_REASON_CREATE_RESIN (1<<6)
/// Interesting because it causes hallucinations
#define MILLA_INTERESTING_REASON_HALLUCINATION (1<<7)
/// Interesting because it has nuclear particles
#define MILLA_INTERESTING_REASON_NUCLEAR_PARTICLES (1<<8)

#define MILLA_NORTH (1 << 0)
#define MILLA_EAST (1 << 1)
#define MILLA_SOUTH (1 << 2)
#define MILLA_WEST (1 << 3)

// Vent pump modes
/// Don't go over the external pressure
#define ONLY_CHECK_EXT_PRESSURE 1
/// Only release until we reach this pressure
#define ONLY_CHECK_INT_PRESSURE 2

#define TLV_O2 "oxygen"
#define TLV_N2 "nitrogen"
#define TLV_PL "plasma"
#define TLV_CO2 "carbon_dioxide"
#define TLV_N2O "nitrous_oxide"
#define TLV_H2 "hydrogen"
#define TLV_H2O "water_vapor"
#define TLV_AGENT_B "agent_b"
#define TLV_TRITIUM "tritium"
#define TLV_BZ "bz"
#define TLV_PLUOXIUM "pluoxium"
#define TLV_MIASMA "miasma"
#define TLV_FREON "freon"
#define TLV_NITRIUM "nitrium"
#define TLV_HEALIUM "healium"
#define TLV_PROTO_NITRATE "proto_nitrate"
#define TLV_ZAUKER "zauker"
#define TLV_HALON "halon"
#define TLV_HELIUM "helium"
#define TLV_ANTINOBLIUM "antinoblium"
#define TLV_HYPERNOBLIUM "hypernoblium"
#define TLV_OTHER "other"
#define TLV_PRESSURE "pressure"
#define TLV_TEMPERATURE "temperature"
#define TLV_TOTAL_MOLES "total_moles"


#define SCRUB_O2 (1<<0)
#define SCRUB_N2 (1<<1)
#define SCRUB_CO2 (1<<2)
#define SCRUB_PL (1<<3)
#define SCRUB_N2O (1<<4)
#define SCRUB_H2 (1<<5)
#define SCRUB_H2O (1<<6)
#define SCRUB_TRITIUM (1<<7)
#define SCRUB_BZ (1<<8)
#define SCRUB_PLUOXIUM (1<<9)
#define SCRUB_MIASMA (1<<10)
#define SCRUB_FREON (1<<11)
#define SCRUB_NITRIUM (1<<12)
#define SCRUB_HEALIUM (1<<13)
#define SCRUB_PROTO_NITRATE (1<<14)
#define SCRUB_ZAUKER (1<<15)
#define SCRUB_HALON (1<<16)
#define SCRUB_HELIUM (1<<17)
#define SCRUB_ANTINOBLIUM (1<<18)
#define SCRUB_HYPERNOBLIUM (1<<19)

#define SCRUB_ALL_GASES (~0)

// Meta gas list indexes
#define META_GAS_ID 1
#define META_GAS_NAME 2
#define META_GAS_DESC 3
#define META_GAS_PRIMARY_COLOR 4
#define META_GAS_SCRUB_FLAG 5
#define META_GAS_SENSOR_FLAG 6

#define MOLES_GAS_VISIBLE 0.25

#define TOXINS_MIN_VISIBILITY_MOLES MOLES_GAS_VISIBLE * 2
#define SLEEPING_GAS_VISIBILITY_MOLES MOLES_GAS_VISIBLE * 4
#define WATER_VAPOR_VISIBILITY_MOLES MOLES_GAS_VISIBLE * 8
#define TRITIUM_VISIBILITY_MOLES MOLES_GAS_VISIBLE
#define FREON_VISIBILITY_MOLES MOLES_GAS_VISIBLE * 30
#define MIASMA_VISIBILITY_MOLES MOLES_GAS_VISIBLE * 60
#define PROTO_NITRATE_VISIBILITY_MOLES MOLES_GAS_VISIBLE
#define ZAUKER_VISIBILITY_MOLES MOLES_GAS_VISIBLE
#define NITRIUM_VISIBILITY_MOLES MOLES_GAS_VISIBLE
#define HEALIUM_VISIBILITY_MOLES MOLES_GAS_VISIBLE
#define HALON_VISIBILITY_MOLES MOLES_GAS_VISIBLE
#define HYPER_NOBLIUM_VISIBILITY_MOLES MOLES_GAS_VISIBLE
#define ANTINOBLIUM_VISIBILITY_MOLES MOLES_GAS_VISIBLE

// Miaster:
/// The minimum temperature miasma begins being sterilized at.
#define MIASTER_STERILIZATION_TEMP (FIRE_MINIMUM_TEMPERATURE_TO_EXIST + 70)
/// The maximum ratio of water vapor to other gases miasma can be sterilized at.
#define MIASTER_STERILIZATION_MAX_HUMIDITY 0.1
/// The minimum amount of miasma that will be sterilized in a reaction tick.
#define MIASTER_STERILIZATION_RATE_BASE 20
/// The temperature required to sterilize an additional mole of miasma in a reaction tick.
#define MIASTER_STERILIZATION_RATE_SCALE 20
/// The amount of energy released when a mole of miasma is sterilized.
#define MIASTER_STERILIZATION_ENERGY 2e-3

// Fire:

// - General:

// - Plasma:
/// The maximum and default amount of plasma consumed as oxydizer per mole of plasma burnt.
#define OXYGEN_BURN_RATIO_BASE 1.4
/// The minimum ratio of oxygen to plasma necessary to start producing tritium.
#define SUPER_SATURATION_THRESHOLD 96

// - Hydrogen:
/// The minimum temperature hydrogen combusts at.
#define HYDROGEN_MINIMUM_BURN_TEMPERATURE FIRE_MINIMUM_TEMPERATURE_TO_EXIST
/// The amount of energy released by burning one mole of hydrogen.
#define FIRE_HYDROGEN_ENERGY_RELEASED 2.8e6
/// Multiplier for hydrogen fire with O2 moles * HYDROGEN_OXYGEN_FULLBURN for the maximum fuel consumption
#define HYDROGEN_OXYGEN_FULLBURN 10
/// The divisor for the maximum hydrogen burn rate. (1/2 of the hydrogen can burn in one reaction tick.)
#define FIRE_HYDROGEN_BURN_RATE_DELTA 2

// - Tritium:
/// The minimum temperature tritium combusts at.
#define TRITIUM_MINIMUM_BURN_TEMPERATURE FIRE_MINIMUM_TEMPERATURE_TO_EXIST
/// The amount of energy released by burning one mole of tritium.
#define FIRE_TRITIUM_ENERGY_RELEASED FIRE_HYDROGEN_ENERGY_RELEASED
/// Multiplier for TRITIUM fire with O2 moles * TRITIUM_OXYGEN_FULLBURN for the maximum fuel consumption
#define TRITIUM_OXYGEN_FULLBURN HYDROGEN_OXYGEN_FULLBURN
/// The divisor for the maximum tritium burn rate. (1/2 of the tritium can burn in one reaction tick.)
#define FIRE_TRITIUM_BURN_RATE_DELTA FIRE_HYDROGEN_BURN_RATE_DELTA
/// The minimum number of moles of trit that must be burnt for a tritium fire reaction to produce a radiation pulse. (0.01 moles trit or 10 moles oxygen to start producing rads.)
#define TRITIUM_RADIATION_MINIMUM_MOLES 0.1
/// The minimum released energy necessary for tritium to release radiation during combustion. (at a mix volume of [CELL_VOLUME]).
#define TRITIUM_RADIATION_RELEASE_THRESHOLD (FIRE_TRITIUM_ENERGY_RELEASED)
/// A scaling factor for the range of radiation pulses produced by tritium fires.
#define TRITIUM_RADIATION_RANGE_DIVISOR 0.5
/// The threshold of the tritium combustion's radiation. Lower values means it will be able to penetrate through more structures.
#define TRITIUM_RADIATION_THRESHOLD 0.3

// - Freon:
/// The maximum temperature freon can combust at.
#define FREON_MAXIMUM_BURN_TEMPERATURE 283
///Minimum temperature allowed for the burn to go at max speed, we would have negative pressure otherwise
#define FREON_LOWER_TEMPERATURE 60
///Terminal temperature after which we stop the reaction
#define FREON_TERMINAL_TEMPERATURE 20
/// Multiplier for freonfire with O2 moles * FREON_OXYGEN_FULLBURN for the maximum fuel consumption
#define FREON_OXYGEN_FULLBURN 10
/// The maximum fraction of the freon in a mix that can combust each reaction tick.
#define FREON_BURN_RATE_DELTA 4
/// The amount of heat absorbed per mole of freon burnt.
#define FIRE_FREON_ENERGY_CONSUMED 3e5
/// The maximum temperature at which freon combustion can form hot ice.
#define HOT_ICE_FORMATION_MAXIMUM_TEMPERATURE 160
/// The minimum temperature at which freon combustion can form hot ice.
#define HOT_ICE_FORMATION_MINIMUM_TEMPERATURE 120
/// The chance for hot ice to form when freon reacts on a turf.
#define HOT_ICE_FORMATION_PROB 2

// N2O:
/// The minimum temperature N2O can form from nitrogen and oxygen in the presence of BZ at.
#define N2O_FORMATION_MIN_TEMPERATURE 200
/// The maximum temperature N2O can form from nitrogen and oxygen in the presence of BZ at.
#define N2O_FORMATION_MAX_TEMPERATURE 250
/// The amount of energy released when a mole of N2O forms from nitrogen and oxygen in the presence of BZ.
#define N2O_FORMATION_ENERGY 10000

/// The minimum temperature N2O can decompose at.
#define N2O_DECOMPOSITION_MIN_TEMPERATURE 1400
/// The maximum temperature N2O can decompose at.
#define N2O_DECOMPOSITION_MAX_TEMPERATURE 100000
/// The maximum portion of the N2O that can decompose each reaction tick. (50%)
#define N2O_DECOMPOSITION_RATE_DIVISOR 2
/// One root of the parabola used to scale N2O decomposition rates.
#define N2O_DECOMPOSITION_MIN_SCALE_TEMP 0
/// The other root of the parabola used to scale N2O decomposition rates.
#define N2O_DECOMPOSITION_MAX_SCALE_TEMP 100000
/// The divisor used to normalize the N2O decomp scaling parabola. Basically the value of the apex/nadir of (x - [N2O_DECOMPOSITION_MIN_SCALE_TEMP]) * (x - [N2O_DECOMPOSITION_MAX_SCALE_TEMP]).
#define N2O_DECOMPOSITION_SCALE_DIVISOR ((-1/4) * ((N2O_DECOMPOSITION_MAX_SCALE_TEMP - N2O_DECOMPOSITION_MIN_SCALE_TEMP)**2))
/// The amount of energy released when one mole of N2O decomposes into nitrogen and oxygen.
#define N2O_DECOMPOSITION_ENERGY 200000

// BZ:
/// The maximum temperature BZ can form at. Deliberately set lower than the minimum burn temperature for most combustible gases in an attempt to prevent long fuse singlecaps.
#define BZ_FORMATION_MAX_TEMPERATURE (FIRE_MINIMUM_TEMPERATURE_TO_EXIST - 60) // Yes, someone used this as a bomb timer. I hate players.
/// The amount of energy 1 mole of BZ forming from N2O and plasma releases.
#define BZ_FORMATION_ENERGY 80000

// Pluoxium:
/// The minimum temperature pluoxium can form from carbon dioxide, oxygen, and tritium at.
#define PLUOXIUM_FORMATION_MIN_TEMP 50
/// The maximum temperature pluoxium can form from carbon dioxide, oxygen, and tritium at.
#define PLUOXIUM_FORMATION_MAX_TEMP T0C
/// The maximum amount of pluoxium that can form from carbon dioxide, oxygen, and tritium per reaction tick.
#define PLUOXIUM_FORMATION_MAX_RATE 5
/// The amount of energy one mole of pluoxium forming from carbon dioxide, oxygen, and tritium releases.
#define PLUOXIUM_FORMATION_ENERGY 250

// Nitrium:
/// The minimum temperature necessary for nitrium to form from tritium, nitrogen, and BZ.
#define NITRIUM_FORMATION_MIN_TEMP 1500
/// A scaling divisor for the rate of nitrium formation relative to mix temperature.
#define NITRIUM_FORMATION_TEMP_DIVISOR (FIRE_MINIMUM_TEMPERATURE_TO_EXIST * 8)
/// The amount of thermal energy consumed when a mole of nitrium is formed from tritium, nitrogen, and BZ.
#define NITRIUM_FORMATION_ENERGY 100000

/// The maximum temperature nitrium can decompose into nitrogen and hydrogen at.
#define NITRIUM_DECOMPOSITION_MAX_TEMP (T0C + 70) //Pretty warm, explicitly not fire temps. Time bombs are cool, but not that cool. If it makes you feel any better it's close.
/// A scaling divisor for the rate of nitrium decomposition relative to mix temperature.
#define NITRIUM_DECOMPOSITION_TEMP_DIVISOR (FIRE_MINIMUM_TEMPERATURE_TO_EXIST * 8)
/// The amount of energy released when a mole of nitrium decomposes into nitrogen and hydrogen.
#define NITRIUM_DECOMPOSITION_ENERGY 30000

// Freon:
/// The minimum temperature freon can form from plasma, CO2, and BZ at.
#define FREON_FORMATION_MIN_TEMPERATURE (FIRE_MINIMUM_TEMPERATURE_TO_EXIST + 100)
/// The amount of energy 2.5 moles of freon forming from plasma, CO2, and BZ consumes.
#define FREON_FORMATION_ENERGY 100

// H-Nob:
/// The maximum temperature hyper-noblium can form from tritium and nitrogen at.
#define NOBLIUM_FORMATION_MIN_TEMP TCMB
/// The maximum temperature hyper-noblium can form from tritium and nitrogen at.
#define NOBLIUM_FORMATION_MAX_TEMP 15
/// The amount of energy a single mole of hyper-noblium forming from tritium and nitrogen releases.
#define NOBLIUM_FORMATION_ENERGY 2e7

/// The number of moles of hyper-noblium required to prevent reactions.
#define REACTION_OPPRESSION_THRESHOLD 5
/// Minimum temperature required for hypernoblium to prevent reactions.
#define REACTION_OPPRESSION_MIN_TEMP 20

// Halon:
/// Energy released per mole of BZ consumed during halon formation.
#define HALON_FORMATION_ENERGY 91232.1

/// How much energy a mole of halon combusting consumes.
#define HALON_COMBUSTION_ENERGY 2500
/// The minimum temperature required for halon to combust.
#define HALON_COMBUSTION_MIN_TEMPERATURE (T0C + 70)
/// The temperature scale for halon combustion reaction rate.
#define HALON_COMBUSTION_TEMPERATURE_SCALE (FIRE_MINIMUM_TEMPERATURE_TO_EXIST * 10)
/// Amount of halon required to be consumed in order to release resin. This is always possible as long as there's enough gas.
#define HALON_COMBUSTION_MINIMUM_RESIN_MOLES (0.99 * HALON_COMBUSTION_MIN_TEMPERATURE / HALON_COMBUSTION_TEMPERATURE_SCALE)
/// The volume of the resin foam fluid when halon combusts, in turfs.
#define HALON_COMBUSTION_RESIN_VOLUME 1

// Healium:
/// The minimum temperature healium can form from BZ and freon at.
#define HEALIUM_FORMATION_MIN_TEMP 25
/// The maximum temperature healium can form from BZ and freon at.
#define HEALIUM_FORMATION_MAX_TEMP 300
/// The amount of energy three moles of healium forming from BZ and freon releases.
#define HEALIUM_FORMATION_ENERGY 9000

// Zauker:
/// The minimum temperature zauker can form from hyper-noblium and nitrium at.
#define ZAUKER_FORMATION_MIN_TEMPERATURE 50000
/// The maximum temperature zauker can form from hyper-noblium and nitrium at.
#define ZAUKER_FORMATION_MAX_TEMPERATURE 75000
/// The temperature scaling factor for zauker formation. At most this many moles of zauker can form per reaction tick per kelvin.
#define ZAUKER_FORMATION_TEMPERATURE_SCALE 5e-6
/// The amount of energy half a mole of zauker forming from hypernoblium and nitrium consumes.
#define ZAUKER_FORMATION_ENERGY 5000

/// The maximum number of moles of zauker that can decompose per reaction tick.
#define ZAUKER_DECOMPOSITION_MAX_RATE 20
/// The amount of energy a mole of zauker decomposing in the presence of nitrogen releases.
#define ZAUKER_DECOMPOSITION_ENERGY 460

// Proto-Nitrate:
/// The minimum temperature proto-nitrate can form from pluoxium and hydrogen at.
#define PN_FORMATION_MIN_TEMPERATURE 5000
/// The maximum temperature proto-nitrate can form from pluoxium and hydrogen at.
#define PN_FORMATION_MAX_TEMPERATURE 10000
/// The temperature scaling factor for proto-nitrate formation. At most this many moles of zauker can form per reaction tick per kelvin.
#define PN_FORMATION_TEMPERATURE_SCALE 5e-3
/// The amount of energy 2.2 moles of proto-nitrate forming from pluoxium and hydrogen releases.
#define PN_FORMATION_ENERGY 650

/// The amount of hydrogen necessary for proto-nitrate to start converting it to more proto-nitrate.
#define PN_HYDROGEN_CONVERSION_THRESHOLD 150
/// The maximum number of moles of hydrogen that can be converted into proto-nitrate in a single reaction tick.
#define PN_HYDROGEN_CONVERSION_MAX_RATE 5
/// The amount of energy converting a mole of hydrogen into half a mole of proto-nitrate consumes.
#define PN_HYDROGEN_CONVERSION_ENERGY 2500

/// The minimum temperature proto-nitrate can convert tritium to hydrogen at.
#define PN_TRITIUM_CONVERSION_MIN_TEMP 150
/// The maximum temperature proto-nitrate can convert tritium to hydrogen at.
#define PN_TRITIUM_CONVERSION_MAX_TEMP 340
/// The amount of energy proto-nitrate converting a mole of tritium into hydrogen releases.
#define PN_TRITIUM_CONVERSION_ENERGY 10000
/// The minimum released energy necessary for proto-nitrate to release radiation when converting tritium. (With a reaction vessel volume of [CELL_VOLUME])
#define PN_TRITIUM_CONVERSION_RAD_RELEASE_THRESHOLD 10000
/// A scaling factor for the range of the radiation pulses generated when proto-nitrate converts tritium to hydrogen.
#define PN_TRITIUM_RAD_RANGE_DIVISOR 0.5
/// The threshold of the radiation pulse released when proto-nitrate converts tritium into hydrogen. Lower values means it will be able to penetrate through more structures.
#define PN_TRITIUM_RAD_THRESHOLD 0.3

/// The minimum temperature proto-nitrate can break BZ down at.
#define PN_BZASE_MIN_TEMP 260
/// The maximum temperature proto-nitrate can break BZ down at.
#define PN_BZASE_MAX_TEMP 280
/// The amount of energy proto-nitrate breaking down a mole of BZ releases.
#define PN_BZASE_ENERGY 60000
/// The minimum released energy necessary for proto-nitrate to release rads when breaking down BZ (at a mix volume of [CELL_VOLUME]).
#define PN_BZASE_RAD_RELEASE_THRESHOLD 60000
/// A scaling factor for the range of the radiation pulses generated when proto-nitrate breaks down BZ.
#define PN_BZASE_RAD_RANGE_DIVISOR 1.5
/// The threshold of the radiation pulse released when proto-nitrate breaks down BZ. Lower values means it will be able to penetrate through more structures.
#define PN_BZASE_RAD_THRESHOLD 0.3
/// A scaling factor for the nuclear particle production generated when proto-nitrate breaks down BZ.
#define PN_BZASE_NUCLEAR_PARTICLE_DIVISOR 5
/// The maximum amount of nuclear particles that can be produced from proto-nitrate breaking down BZ.
#define PN_BZASE_NUCLEAR_PARTICLE_MAXIMUM 6
/// How much radiation in consumed amount does a nuclear particle take from radiation when proto-nitrate breaks down BZ.
#define PN_BZASE_NUCLEAR_PARTICLE_RADIATION_ENERGY_CONVERSION 2.5

// Antinoblium:
/// The divisor for the maximum antinoblium conversion rate. (1/90 of the antinoblium converts other gases to antinoblium in one reaction tick.)
#define ANTINOBLIUM_CONVERSION_DIVISOR 90

