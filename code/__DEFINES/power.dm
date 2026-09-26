#define SOLAR_MAX_DIST 40

#define TRACKER_OFF 0
#define TRACKER_TIMED 1
#define TRACKER_AUTO 2

/// The watt is the standard unit of power for this codebase. Do not change this.
#define WATT 1
/// The joule is the standard unit of energy for this codebase. Do not change this.
#define JOULE 1
/// The watt is the standard unit of power for this codebase. You can use this with other defines to clarify that it will be multiplied by time.
#define WATTS * WATT
/// The joule is the standard unit of energy for this codebase. You can use this with other defines to clarify that it will not be multiplied by time.
#define JOULES * JOULE
/// Conversion ratio from Watt over a machine process tick time to Joules
#define WATT_TICK_TO_JOULE 2

///powel cell charge defines
#define CELL_CHARGE_UPPER_BORDER INFINITY
#define CELL_CHARGE_HIGH 0.75
#define CELL_CHARGE_TWO_THIRDS 0.66
#define CELL_CHARGE_MEDIUM 0.5
#define CELL_CHARGE_ONE_THIRD 0.33
#define CELL_CHARGE_LOW 0.25
#define CELL_CHARGE_LOWER_BORDER 0.01

///The capacity of a standard power cell
#define STANDARD_CELL_VALUE (10 KILO)
	///The amount of energy, in joules, a standard powercell has.
	#define STANDARD_CELL_CHARGE (STANDARD_CELL_VALUE JOULES) // 10 KJ.
	///The amount of power, in watts, a standard powercell can give.
	#define STANDARD_CELL_RATE (STANDARD_CELL_VALUE WATTS) // 10 KW.

/// Capacity of a standard battery
#define STANDARD_BATTERY_VALUE (STANDARD_CELL_VALUE * 100)
	/// The amount of energy, in joules, a standard battery has.
	#define STANDARD_BATTERY_CHARGE (STANDARD_BATTERY_VALUE JOULES) // 1 MJ
	/// The amount of energy, in watts, a standard battery can give.
	#define STANDARD_BATTERY_RATE (STANDARD_BATTERY_VALUE WATTS) // 1 MW
