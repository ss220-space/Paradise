//LISTMOS
//indices of values in gas lists.
///Amount of total moles in said gas mixture
#define MOLES 1
///Archived version of MOLES
#define ARCHIVE 2
///All gas related variables
#define GAS_META 3
///Gas specific heat per mole
#define META_GAS_SPECIFIC_HEAT 1
///Name of the gas
#define META_GAS_NAME 2
///Amount of moles required of the gas to be visible
#define META_GAS_MOLES_VISIBLE 3
///Overlay path of the gas, also setup the alpha based on the amount
#define META_GAS_OVERLAY 4
///Id of the gas for quick access
#define META_GAS_ID 5
//ATMOS
//stuff you should probably leave well alone!
/// kPa*L/(K*mol)
#define R_IDEAL_GAS_EQUATION 8.31
/// kPa
#define ONE_ATMOSPHERE 101.325
/// -270.3degC
#define TCMB 2.7
// -48.15degC
#define TCRYO 265
/// 0degC
#define T0C 273.15
/// 20degC
#define T20C 293.15
/// -14C - Temperature used for kitchen cold room, medical freezer, etc.
#define COLD_ROOM_TEMP 259.15

/**
 *I feel the need to document what happens here. Basically this is used
 *catch rounding errors, and make gas go away in small portions.
 *People have raised it to higher levels in the past, do not do this. Consider this number a soft limit
 *If you're making gasmixtures that have unexpected behavior related to this value, you're doing something wrong.
 *
 *On an unrelated note this may cause a bug that creates negative gas, related to round(). When it has a second arg it will round up.
 *So for instance round(0.5, 1) == 1. I've hardcoded a fix for this into share, by forcing the garbage collect.
 *Any other attempts to fix it just killed atmos. I leave this to a greater man then I
 */
/// The minimum heat capacity of a gas
#define MINIMUM_HEAT_CAPACITY 0.0003
/// Minimum mole count of a gas
#define MINIMUM_MOLE_COUNT 0.01
/// Molar accuracy to round to
#define MOLAR_ACCURACY  1E-4
/// Types of gases (based on gaslist_cache)
#define GAS_TYPE_COUNT GLOB.gaslist_cache.len
/// Maximum error caused by QUANTIZE when removing gas (roughly, in reality around 2 * MOLAR_ACCURACY less)
#define MAXIMUM_ERROR_GAS_REMOVAL (MOLAR_ACCURACY * GAS_TYPE_COUNT)

/// Moles in a standard cell after which gases are visible
#define MOLES_GAS_VISIBLE 0.25

/// moles_visible * FACTOR_GAS_VISIBLE_MAX = Moles after which gas is at maximum visibility
#define FACTOR_GAS_VISIBLE_MAX 20
/// Mole step for alpha updates. This means alpha can update at 0.25, 0.5, 0.75 and so on
#define MOLES_GAS_VISIBLE_STEP 0.25
/// The total visible states
#define TOTAL_VISIBLE_STATES (FACTOR_GAS_VISIBLE_MAX * (1 / MOLES_GAS_VISIBLE_STEP))

//REACTIONS
//return values for reactions (bitflags)
///The gas mixture is not reacting
#define NO_REACTION 0
///The gas mixture is reacting
#define REACTING 1
///The gas mixture is able to stop all reactions
#define STOP_REACTIONS 2

//Fusion
///Maximum instability before the reaction goes endothermic
#define FUSION_INSTABILITY_ENDOTHERMALITY 4
///Maximum reachable fusion temperature
#define FUSION_MAXIMUM_TEMPERATURE 1e8


//EXCITED GROUPS
/**
 * Some further context on breakdown. Unlike dismantle, the breakdown ticker doesn't reset itself when a tile is added
 * This is because we cannot expect maps to have small spaces, so we need to even ourselves out often
 * We do this to avoid equalizing a large space in one tick, with some significant amount of say heat diff
 * This way large areas don't suddenly all become cold at once, it acts more like a wave
 *
 * Because of this and the behavior of share(), the breakdown cycles value can be tweaked directly to effect how fast we want gas to move
 */
/// number of FULL air controller ticks before an excited group breaks down (averages gas contents across turfs)
#define EXCITED_GROUP_BREAKDOWN_CYCLES 5
/// number of FULL air controller ticks before an excited group dismantles and removes its turfs from active
#define EXCITED_GROUP_DISMANTLE_CYCLES ((EXCITED_GROUP_BREAKDOWN_CYCLES * 2) + 1) //Reset after 2 breakdowns
/// Ratio of air that must move to/from a tile to reset group processing
#define MINIMUM_AIR_RATIO_TO_SUSPEND 0.1
/// Minimum ratio of air that must move to/from a tile
#define MINIMUM_AIR_RATIO_TO_MOVE 0.001
/// Minimum amount of air that has to move before a group processing can be suspended (Round about 10)
#define MINIMUM_AIR_TO_SUSPEND (MOLES_CELLSTANDARD*MINIMUM_AIR_RATIO_TO_SUSPEND)
/// Either this must be active (round about 0.1) //Might need to raise this a tad to better support space leaks. we'll see
#define MINIMUM_MOLES_DELTA_TO_MOVE (MOLES_CELLSTANDARD*MINIMUM_AIR_RATIO_TO_MOVE)
/// or this (or both, obviously)
#define MINIMUM_TEMPERATURE_TO_MOVE (T20C+100)
/// Minimum temperature difference before group processing is suspended
#define MINIMUM_TEMPERATURE_DELTA_TO_SUSPEND 4
/// Minimum temperature difference before the gas temperatures are just set to be equal
#define MINIMUM_TEMPERATURE_DELTA_TO_CONSIDER 0.5
///Minimum temperature to continue superconduction once started
#define MINIMUM_TEMPERATURE_FOR_SUPERCONDUCTION (T20C+80)
///Minimum temperature to start doing superconduction calculations
#define MINIMUM_TEMPERATURE_START_SUPERCONDUCTION (T20C+400)

//HEAT TRANSFER COEFFICIENTS
//Must be between 0 and 1. Values closer to 1 equalize temperature faster
//Should not exceed 0.4 else strange heat flow occur
#define WALL_HEAT_TRANSFER_COEFFICIENT 0.0
#define OPEN_HEAT_TRANSFER_COEFFICIENT 0.4
/// a hack for now
#define WINDOW_HEAT_TRANSFER_COEFFICIENT 0.1
/// a hack to help make vacuums "cold", sacrificing realism for gameplay
#define HEAT_CAPACITY_VACUUM 7000

//FIRE
///Minimum temperature for fire to move to the next turf (150 °C or 433 K)
#define FIRE_MINIMUM_TEMPERATURE_TO_SPREAD (150+T0C)
///Minimum temperature for fire to exist on a turf (100 °C or 373 K)
#define FIRE_MINIMUM_TEMPERATURE_TO_EXIST (100+T0C)
///Multiplier for the temperature shared to other turfs
#define FIRE_SPREAD_RADIOSITY_SCALE 0.85
///Helper for small fires to grow
#define FIRE_GROWTH_RATE 40000
//Amount of heat released per mole of burnt carbon into the tile
#define FIRE_CARBON_ENERGY_RELEASED 500000
//Amount of heat released per mole of burnt plasma into the tile
#define FIRE_PLASMA_ENERGY_RELEASED 3000000

///Multiplier for the temperature shared to other turfs
#define COLD_FIRE_SPREAD_RADIOSITY_SCALE 0.95

///moles in a 2.5 m^3 cell at 101.325 Pa and 20 degC (103 or so)
#define MOLES_CELLSTANDARD (ONE_ATMOSPHERE*CELL_VOLUME/(T20C*R_IDEAL_GAS_EQUATION))
///compared against for superconductivity
#define M_CELL_WITH_RATIO (MOLES_CELLSTANDARD * 0.005)
/// percentage of oxygen in a normal mixture of air
#define O2STANDARD 0.21
/// same but for nitrogen
#define N2STANDARD 0.79
/// O2 standard value (21%)
#define MOLES_O2STANDARD (MOLES_CELLSTANDARD*O2STANDARD)
/// N2 standard value (79%)
#define MOLES_N2STANDARD (MOLES_CELLSTANDARD*N2STANDARD)
/// liters in a cell
#define CELL_VOLUME 2500

///O2 value for anesthetic canister
#define O2_ANESTHETIC 0.65
///N2O value for anesthetic canister
#define N2O_ANESTHETIC 0.35

//CANATMOSPASS
#define ATMOS_PASS_YES 1
#define ATMOS_PASS_NO 0
/// ask can_atmos_pass()
#define ATMOS_PASS_PROC -1
/// just check density
#define ATMOS_PASS_DENSITY -2

//Adjacent turf related defines, they dictate what to do with a turf once it's been recalculated
//Used as "state" in CALCULATE_ADJACENT_TURFS
///Normal non-active turf
#define NORMAL_TURF 1
///Set the turf to be activated on the next calculation
#define MAKE_ACTIVE 2
///Disable excited group
#define KILL_EXCITED 3

/// How many maximum iterations do we allow the Newton-Raphson approximation for gas pressure to do.
#define ATMOS_PRESSURE_APPROXIMATION_ITERATIONS 20
/// We deal with big numbers and a lot of math, things are bound to get imprecise. Take this traveller.
#define ATMOS_PRESSURE_ERROR_TOLERANCE 0.01


/*
 * НАЧАЛО КОД ПАРАДИЗ. РАЗОБРАТЬ
 */
//liters in a normal breath
#define BREATH_VOLUME			1
#define BREATH_PERCENTAGE		(BREATH_VOLUME/CELL_VOLUME)					//Amount of air to take a from a tile


//Plasma fire properties
#define OXYGEN_BURN_RATE_BASE				1.4
#define PLASMA_BURN_RATE_DELTA				4
#define PLASMA_MINIMUM_BURN_TEMPERATURE		(100+T0C)
#define PLASMA_UPPER_TEMPERATURE			(1370+T0C)
#define PLASMA_MINIMUM_OXYGEN_NEEDED		2
#define PLASMA_MINIMUM_OXYGEN_PLASMA_RATIO	30
#define PLASMA_OXYGEN_FULLBURN				10

//GASES
#define MIN_TOXIC_GAS_DAMAGE				1
#define MAX_TOXIC_GAS_DAMAGE				10
#define MOLES_PLASMA_VISIBLE				0.5		//Moles in a standard cell after which plasma is visible

// Pressure limits.
#define HAZARD_HIGH_PRESSURE				550		//This determins at what pressure the ultra-high pressure red icon is displayed. (This one is set as a constant)
#define WARNING_HIGH_PRESSURE				325		//This determins when the orange pressure icon is displayed (it is 0.7 * HAZARD_HIGH_PRESSURE)
#define WARNING_LOW_PRESSURE				50		//This is when the gray low pressure icon is displayed. (it is 2.5 * HAZARD_LOW_PRESSURE)
#define HAZARD_LOW_PRESSURE					20		//This is when the black ultra-low pressure icon is displayed. (This one is set as a constant)

#define TEMPERATURE_DAMAGE_COEFFICIENT		1.5		//This is used in handle_temperature_damage() for humans, and in reagents that affect body temperature. Temperature damage is multiplied by this amount.

#define BODYTEMP_NORMAL						310.15			//The natural temperature for a body
#define BODYTEMP_AUTORECOVERY_DIVISOR		12		//This is the divisor which handles how much of the temperature difference between the current body temperature and 310.15K (optimal temperature) humans auto-regenerate each tick. The higher the number, the slower the recovery. This is applied each tick, so long as the mob is alive.
#define BODYTEMP_AUTORECOVERY_MINIMUM		10		//Minimum amount of kelvin moved toward 310.15K per tick. So long as abs(310.15 - bodytemp) is more than 50.
#define BODYTEMP_COLD_DIVISOR				6		//Similar to the BODYTEMP_AUTORECOVERY_DIVISOR, but this is the divisor which is applied at the stage that follows autorecovery. This is the divisor which comes into play when the human's loc temperature is lower than their body temperature. Make it lower to lose bodytemp faster.
#define BODYTEMP_HEAT_DIVISOR				6		//Similar to the BODYTEMP_AUTORECOVERY_DIVISOR, but this is the divisor which is applied at the stage that follows autorecovery. This is the divisor which comes into play when the human's loc temperature is higher than their body temperature. Make it lower to gain bodytemp faster.
#define BODYTEMP_COOLING_MAX				30		//The maximum number of degrees that your body can cool in 1 tick, when in a cold area.
#define BODYTEMP_HEATING_MAX				30		//The maximum number of degrees that your body can heat up in 1 tick, when in a hot area.

#define BODYTEMP_HEAT_DAMAGE_LIMIT			(BODYTEMP_NORMAL + 50) // The limit the human body can take before it starts taking damage from heat.
#define BODYTEMP_COLD_DAMAGE_LIMIT			(BODYTEMP_NORMAL - 50) // The limit the human body can take before it starts taking damage from coldness.

#define SPACE_HELM_MIN_TEMP_PROTECT			2.0		//what min_cold_protection_temperature is set to for space-helmet quality headwear. MUST NOT BE 0.
#define SPACE_HELM_MAX_TEMP_PROTECT			1500	//Thermal insulation works both ways /Malkevin
#define SPACE_SUIT_MIN_TEMP_PROTECT			2.0		//what min_cold_protection_temperature is set to for space-suit quality jumpsuits or suits. MUST NOT BE 0.
#define SPACE_SUIT_MAX_TEMP_PROTECT			1500

#define FIRE_SUIT_MIN_TEMP_PROTECT			60		//Cold protection for firesuits
#define FIRE_SUIT_MAX_TEMP_PROTECT			30000	//what max_heat_protection_temperature is set to for firesuit quality suits. MUST NOT BE 0.
#define FIRE_HELM_MIN_TEMP_PROTECT			60		//Cold protection for fire helmets
#define FIRE_HELM_MAX_TEMP_PROTECT			30000	//for fire helmet quality items (red and white hardhats)

#define FIRE_IMMUNITY_MAX_TEMP_PROTECT		35000		//what max_heat_protection_temperature is set to for firesuit quality suits and helmets. MUST NOT BE 0.

#define HELMET_MIN_TEMP_PROTECT				160		//For normal helmets
#define HELMET_MAX_TEMP_PROTECT				600		//For normal helmets
#define ARMOR_MIN_TEMP_PROTECT				160		//For armor
#define ARMOR_MAX_TEMP_PROTECT				600		//For armor

#define GLOVES_MIN_TEMP_PROTECT				2.0		//For some gloves (black and)
#define GLOVES_MAX_TEMP_PROTECT				1500	//For some gloves
#define SHOES_MIN_TEMP_PROTECT				2.0		//For gloves
#define SHOES_MAX_TEMP_PROTECT				1500	//For gloves

#define PRESSURE_DAMAGE_COEFFICIENT			8		//The amount of pressure damage someone takes is equal to (pressure / HAZARD_HIGH_PRESSURE)*PRESSURE_DAMAGE_COEFFICIENT, with the maximum of MAX_PRESSURE_DAMAGE
#define MAX_HIGH_PRESSURE_DAMAGE			8
#define LOW_PRESSURE_DAMAGE					8		//The amounb of damage someone takes when in a low pressure area (The pressure threshold is so low that it doesn't make sense to do any calculations, so it just applies this flat value).

#define COLD_SLOWDOWN_FACTOR				20		//Humans are slowed by the difference between bodytemp and BODYTEMP_COLD_DAMAGE_LIMIT divided by this

//PIPES
// Atmos pipe limits
#define MAX_OUTPUT_PRESSURE					4500 // (kPa) What pressure pumps and powered equipment max out at.
#define MAX_TRANSFER_RATE					200 // (L/s) Maximum speed powered equipment can work at.

//TANKS
#define TANK_LEAK_PRESSURE					(30.*ONE_ATMOSPHERE)	//Tank starts leaking
#define TANK_RUPTURE_PRESSURE				(40.*ONE_ATMOSPHERE)	//Tank spills all contents into atmosphere
#define TANK_FRAGMENT_PRESSURE				(50.*ONE_ATMOSPHERE)	//Boom 3x3 base explosion
#define TANK_FRAGMENT_SCALE	    			(10.*ONE_ATMOSPHERE)	//+1 for each SCALE kPa aboe threshold
#define TANK_MAX_RELEASE_PRESSURE 			(ONE_ATMOSPHERE * 3)
#define TANK_MIN_RELEASE_PRESSURE 			0
#define TANK_DEFAULT_RELEASE_PRESSURE 		16

// Atmos alarm defines
#define ATMOS_ALARM_NONE					0
#define ATMOS_ALARM_WARNING					1
#define ATMOS_ALARM_DANGER					2

//LAVALAND
#define LAVALAND_EQUIPMENT_EFFECT_PRESSURE 50 //what pressure you have to be under to increase the effect of equipment meant for lavaland
