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

/// The amount of energy, in joules, a standard powercell has.
#define STANDARD_CELL_CHARGE (1 MEGA JOULES) // 1 MJ.
