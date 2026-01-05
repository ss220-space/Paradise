#define SM_EVENT_THREAT_D "Delta"
#define SM_EVENT_THREAT_C "Charlie"
#define SM_EVENT_THREAT_B "Bravo"
#define SM_EVENT_THREAT_A "Alpha"
#define SM_EVENT_THREAT_S "Sierra"

// These are used by supermatter and supermatter monitor program, mostly for UI updating purposes. Higher should always be worse!
// [/obj/machinery/atmospherics/supermatter_crystal/proc/get_status]
/// Unknown status, shouldn't happen but just in case.
#define SUPERMATTER_ERROR -1
/// No or minimal energy
#define SUPERMATTER_INACTIVE 0
/// Normal operation
#define SUPERMATTER_NORMAL 1
/// Ambient temp 80% of the default temp for SM to take damage.
#define SUPERMATTER_NOTIFY 2
/// Integrity below [/obj/machinery/atmospherics/supermatter_crystal/var/warning_point]. Start complaining on comms.
#define SUPERMATTER_WARNING 3
/// Integrity below [/obj/machinery/atmospherics/supermatter_crystal/var/danger_point]. Start spawning anomalies.
#define SUPERMATTER_DANGER 4
/// Integrity below [/obj/machinery/atmospherics/supermatter_crystal/var/emergency_point]. Start complaining to more people.
#define SUPERMATTER_EMERGENCY 5
/// Currently counting down to delamination. True [/obj/machinery/atmospherics/supermatter_crystal/var/final_countdown]
#define SUPERMATTER_DELAMINATING 6

/// Higher == Crystal safe operational temperature is higher.
#define SUPERMATTER_HEAT_PENALTY_THRESHOLD 40
