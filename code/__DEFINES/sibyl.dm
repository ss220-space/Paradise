/**
 * # Sibyl System Constants
 */

// Sibyl System tier flags
#define SIBYL_TIER_NONLETHAL (1<<0)
#define SIBYL_TIER_LETHAL (1<<1)
#define SIBYL_TIER_DESTRUCTIVE (1<<2)

// Sibyl System states
#define SIBSYS_STATE_UNINSTALLED 0
#define SIBSYS_STATE_INSTALLED 1
#define SIBSYS_STATE_SCREWDRIVER_ACT 2
#define SIBSYS_STATE_WELDER_ACT 3

// Sibyl System cooldowns and durations
#define SIBYL_LINK_SOUND_COOLDOWN 10 SECONDS
#define SIBYL_DISMANTLE_DURATION 16 SECONDS
