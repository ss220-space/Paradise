// Keys for the `teleport_data` list passed alongside COMSIG_MOVABLE_TELEPORTING and
// COMSIG_ATOM_INTERCEPT_TELEPORTING. Interference handlers (BoH, SoH, BSIG fields) read and
// write these to communicate the teleported atom, the (possibly shunted) destination and the
// outcome back to get_teleport_intercepted_destination().
/// The atom being teleported.
#define TELEPORT_INTERCEPT_TELEATOM "teleatom"
/// The current intended destination turf. Handlers may overwrite it to shunt the teleport.
#define TELEPORT_INTERCEPT_DESTINATION "destination"
/// TRUE when the teleport should ignore bluespace interference entirely (always precise).
#define TELEPORT_INTERCEPT_IGNORE_BLUESPACE "ignore_bluespace_interference"
/// TRUE when a BSIG field should fully block the teleport instead of shunting it to the edge.
#define TELEPORT_INTERCEPT_BLOCK_BLUESPACE "block_bluespace_interference"
/// Set by handlers to TRUE when interference fully blocked the teleport (used for notifications).
#define TELEPORT_INTERCEPT_BLUESPACE_BLOCKED "bluespace_interference_blocked"
/// Set by handlers to TRUE when interference shunted the teleport to the field edge.
#define TELEPORT_INTERCEPT_BLUESPACE_SHUNTED "bluespace_interference_shunted"
