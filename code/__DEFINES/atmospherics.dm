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
#define MOLES_PLASMA_VISIBLE 0.5 //Moles in a standard cell after which plasma is visible
#define MOLES_WATER_VAPOR_VISIBLE 2.0 //Moles in a standard cell after which water vapor is visible

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

#define SENSOR_COMPOSITION_OXYGEN (1<<2)
#define SENSOR_COMPOSITION_TOXINS (1<<3)
#define SENSOR_COMPOSITION_NITROGEN (1<<4)
#define SENSOR_COMPOSITION_CO2 (1<<5)
#define SENSOR_COMPOSITION_N2O (1<<6)
#define SENSOR_COMPOSITION_H2 (1<<7)
#define SENSOR_COMPOSITION_H2O (1<<8)

/// Maximum germ level you can reach by standing still
#define GERM_LEVEL_AMBIENT 110
/// Maximum germ level you can reach by running around
#define GERM_LEVEL_MOVE_CAP 200

// Atmos stuff that fucking terrifies me
#define LINDA_SPAWN_HEAT (1<<0)
#define LINDA_SPAWN_20C (1<<1)
#define LINDA_SPAWN_TOXINS (1<<2)
#define LINDA_SPAWN_OXYGEN (1<<3)
#define LINDA_SPAWN_CO2 (1<<4)
#define LINDA_SPAWN_NITROGEN (1<<5)
#define LINDA_SPAWN_N2O (1<<6)
#define LINDA_SPAWN_AGENT_B (1<<7)
#define LINDA_SPAWN_AIR (1<<8)
#define LINDA_SPAWN_COLD (1<<9)
#define LINDA_SPAWN_HYDROGEN (1<<10)
#define LINDA_SPAWN_WATER_VAPOR (1<<11)

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
#define MILLA_INDEX_ATMOS_MODE 10
#define MILLA_INDEX_ENVIRONMENT_ID 11
#define MILLA_INDEX_SUPERCONDUCTIVITY_NORTH 12
#define MILLA_INDEX_SUPERCONDUCTIVITY_EAST 13
#define MILLA_INDEX_SUPERCONDUCTIVITY_SOUTH 14
#define MILLA_INDEX_SUPERCONDUCTIVITY_WEST 15
#define MILLA_INDEX_INNATE_HEAT_CAPACITY 16
#define MILLA_INDEX_TEMPERATURE 17
#define MILLA_INDEX_HOTSPOT_TEMPERATURE 18
#define MILLA_INDEX_HOTSPOT_VOLUME 19
#define MILLA_INDEX_WIND_X 20
#define MILLA_INDEX_WIND_Y 21
#define MILLA_INDEX_FUEL_BURNT 22

/// The number of values per tile.
#define MILLA_TILE_SIZE MILLA_INDEX_FUEL_BURNT

// These are only for InterestingTiles.
#define MILLA_INDEX_TURF 23
#define MILLA_INDEX_INTERESTING_REASONS 24
#define MILLA_INDEX_AIRFLOW_X 25
#define MILLA_INDEX_AIRFLOW_Y 26

/// The number of values per interesting tile.
#define MILLA_INTERESTING_TILE_SIZE MILLA_INDEX_AIRFLOW_Y
/// Interesting because it needs a display update.
#define MILLA_INTERESTING_REASON_DISPLAY (1 << 0)
/// Interesting because it's hot enough to start a fire. Excludes normal-temperature Lavaland tiles without an active fire.
#define MILLA_INTERESTING_REASON_HOT (1 << 1)
/// Interesting because it has wind that can push stuff around.
#define MILLA_INTERESTING_REASON_WIND (1 << 2)
/// Interesting because it has water vapor condensation
#define MILLA_INTERESTING_REASON_CONDENSATION (1 << 3)

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
#define TLV_OTHER "other"
#define TLV_PRESSURE "pressure"
#define TLV_TEMPERATURE "temperature"

