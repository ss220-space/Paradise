#define TURF_TRAIT "turf"
/// Turf will be passable if density is 0
#define TURF_PATHING_PASS_DENSITY 0
/// Turf will be passable depending on [CanPathfindPass] return value
#define TURF_PATHING_PASS_PROC 1
/// Turf is never passable
#define TURF_PATHING_PASS_NO 2
/// Turf trait for when a turf is transparent
#define TURF_Z_TRANSPARENT_TRAIT "turf_z_transparent"
/// Turf that is covered. Any turf which doesn't use alpha-channel. Don't use this. Use !transparent_floor
#define TURF_NONTRANSPARENT 0
/// Turf that is uses alpha-channel such as glass floor. It shows what's underneath but doesn't grant access to what's under(cables, pipes).
#define TURF_TRANSPARENT 1
/// Used only by /turf/openspace. Show and grants access to what's under.
#define TURF_FULLTRANSPARENT 2

#define IS_OPAQUE_TURF(turf) (turf.directional_opacity == ALL_CARDINALS)
