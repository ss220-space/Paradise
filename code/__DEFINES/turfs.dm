#define TURF_TRAIT "turf"
/// Turf will be passable if density is 0
#define TURF_PATHING_PASS_DENSITY 0
/// Turf will be passable depending on [CanPathfindPass] return value
#define TURF_PATHING_PASS_PROC 1
/// Turf is never passable
#define TURF_PATHING_PASS_NO 2
///Turf trait for when a turf is transparent
#define TURF_Z_TRANSPARENT_TRAIT "turf_z_transparent"

#define IS_OPAQUE_TURF(turf) (turf.directional_opacity == ALL_CARDINALS)
