/// signals from globally accessible objects

///from SSsun when the sun changes position : (azimuth)
#define COMSIG_SUN_MOVED "sun_moved"

///from SSsecurity_level on planning security level change : (previous_level_number, new_level_number)
#define COMSIG_SECURITY_LEVEL_CHANGE_PLANNED "security_level_change_planned"
///from SSsecurity_level when the security level changes : (previous_level_number, new_level_number)
#define COMSIG_SECURITY_LEVEL_CHANGED "security_level_changed"
