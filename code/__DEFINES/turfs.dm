#define TURF_TRAIT "turf"

/// Turf will be passable if density is 0
#define TURF_PATHING_PASS_DENSITY 0
/// Turf will be passable depending on [CanAStarPass] return value
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

/// Maximum amount of time, (in deciseconds) a tile can be wet for.
#define MAXIMUM_WET_TIME (5 MINUTES)

//Wet floor type flags. Stronger ones should be higher in number.
/// Turf is dry and mobs won't slip
#define TURF_DRY (0)
/// Turf has water on the floor and mobs will slip unless walking or using galoshes
#define TURF_WET_WATER (1<<0)
/// Turf has a thick layer of ice on the floor and mobs will slip in the direction until they bump into something
#define TURF_WET_PERMAFROST (1<<1)
/// Turf has a thin layer of ice on the floor and mobs will slip
#define TURF_WET_ICE (1<<2)
/// Turf has lube on the floor and mobs will slip
#define TURF_WET_LUBE (1<<3)


//spisjeno with TG


#define CHANGETURF_DEFER_CHANGE (1<<0)
#define CHANGETURF_IGNORE_AIR (1<<1) // This flag prevents changeturf from gathering air from nearby turfs to fill the new turf with an approximation of local air
#define CHANGETURF_FORCEOP (1<<2)
#define CHANGETURF_SKIP (1<<3) // A flag for PlaceOnTop to just instance the new turf instead of calling ChangeTurf. Used for uninitialized turfs NOTHING ELSE
#define CHANGETURF_INHERIT_AIR (1<<4) // Inherit air from previous turf. Implies CHANGETURF_IGNORE_AIR
#define CHANGETURF_RECALC_ADJACENT (1<<5) //Immediately recalc adjacent atmos turfs instead of queuing.
#define CHANGETURF_TRAPDOOR_INDUCED (1<<6) // Caused by a trapdoor, for trapdoor to know that this changeturf was caused by itself


///Returns all turfs in a zlevel
#define Z_TURFS(ZLEVEL) block(locate(1,1,ZLEVEL), locate(world.maxx, world.maxy, ZLEVEL))

///Returns all currently loaded turfs
#define ALL_TURFS(...) block(locate(1, 1, 1), locate(world.maxx, world.maxy, world.maxz))

#define TURF_FROM_COORDS_LIST(List) (locate(List[1], List[2], List[3]))


