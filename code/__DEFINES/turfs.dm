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

#define CHANGETURF_IGNORE_AIR (1<<0) // This flag prevents changeturf from gathering air from nearby turfs to fill the new turf with an approximation of local air
#define CHANGETURF_KEEP_CABLING (1<<1) // This flags prevents from cables being removed. Used in maploader only

#define IS_OPAQUE_TURF(turf) (turf.directional_opacity == ALL_CARDINALS)

//supposedly the fastest way to do this according to https://gist.github.com/Giacom/be635398926bb463b42a
///Returns a list of turf in a square
#define RANGE_TURFS(RADIUS, CENTER) \
	RECT_TURFS(RADIUS, RADIUS, CENTER)

#define RECT_TURFS(H_RADIUS, V_RADIUS, CENTER) \
	block( \
	max(CENTER.x - (H_RADIUS), 1),          max(CENTER.y - (V_RADIUS), 1),          CENTER.z, \
	min(CENTER.x + (H_RADIUS), world.maxx), min(CENTER.y + (V_RADIUS), world.maxy), CENTER.z \
	)

/// Returns the turfs on the edge of a square with CENTER in the middle and with the given RADIUS. If used near the edge of the map, will still work fine.
// order of the additions: top edge + bottom edge + left edge + right edge
#define RANGE_EDGE_TURFS(RADIUS, CENTER)\
	(CENTER.y + RADIUS < world.maxy ? block(max(CENTER.x - RADIUS, 1), min(CENTER.y + RADIUS, world.maxy), CENTER.z, min(CENTER.x + RADIUS, world.maxx), min(CENTER.y + RADIUS, world.maxy), CENTER.z) : list()) +\
	(CENTER.y - RADIUS > 1 ? block(max(CENTER.x - RADIUS, 1), max(CENTER.y - RADIUS, 1), CENTER.z, min(CENTER.x + RADIUS, world.maxx), max(CENTER.y - RADIUS, 1), CENTER.z) : list()) +\
	(CENTER.x - RADIUS > 1 ? block(max(CENTER.x - RADIUS, 1), min(CENTER.y + RADIUS - 1, world.maxy), CENTER.z, max(CENTER.x - RADIUS, 1), max(CENTER.y - RADIUS + 1, 1), CENTER.z) : list()) +\
	(CENTER.x + RADIUS < world.maxx ? block(min(CENTER.x + RADIUS, world.maxx), min(CENTER.y + RADIUS - 1, world.maxy), CENTER.z, min(CENTER.x + RADIUS, world.maxx), max(CENTER.y - RADIUS + 1, 1), CENTER.z) : list())

/// Returns a list of turfs in the rectangle specified by BOTTOM LEFT corner and height/width, checks for being outside the world border for you
#define CORNER_BLOCK(corner, width, height) CORNER_BLOCK_OFFSET(corner, width, height, 0, 0)

/// Returns a list of turfs similar to CORNER_BLOCK but with offsets
#define CORNER_BLOCK_OFFSET(corner, width, height, offset_x, offset_y) ((block(locate(corner.x + offset_x, corner.y + offset_y, corner.z), locate(min(corner.x + (width - 1) + offset_x, world.maxx), min(corner.y + (height - 1) + offset_y, world.maxy), corner.z))))

/// Returns an outline (neighboring turfs) of the given block
#define CORNER_OUTLINE(corner, width, height) ( \
	CORNER_BLOCK_OFFSET(corner, width + 2, 1, -1, -1) + \
	CORNER_BLOCK_OFFSET(corner, width + 2, 1, -1, height) + \
	CORNER_BLOCK_OFFSET(corner, 1, height, -1, 0) + \
	CORNER_BLOCK_OFFSET(corner, 1, height, width, 0))

/// Returns a list of around us
#define TURF_NEIGHBORS(turf) (CORNER_BLOCK_OFFSET(turf, 3, 3, -1, -1) - turf)

///Returns all turfs in a zlevel
#define Z_TURFS(ZLEVEL) block(1,1,ZLEVEL, world.maxx, world.maxy, ZLEVEL)

///Returns all currently loaded turfs
#define ALL_TURFS(...) block(1, 1, 1, world.maxx, world.maxy, world.maxz)

#define TURF_FROM_COORDS_LIST(List) (locate(List[1], List[2], List[3]))

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
