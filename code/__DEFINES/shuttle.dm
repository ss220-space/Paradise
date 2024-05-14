//Docking error flags
#define DOCKING_SUCCESS				0
#define DOCKING_BLOCKED				(1<<0)
#define DOCKING_IMMOBILIZED			(1<<1)
#define DOCKING_AREA_EMPTY			(1<<2)
#define DOCKING_NULL_DESTINATION	(1<<3)
#define DOCKING_NULL_SOURCE			(1<<4)

//Rotation params
#define ROTATE_DIR 1
#define ROTATE_SMOOTH 2
#define ROTATE_OFFSET 4

#define SHUTTLE_DOCKER_LANDING_CLEAR 1
#define SHUTTLE_DOCKER_BLOCKED_BY_HIDDEN_PORT 2
#define SHUTTLE_DOCKER_BLOCKED 3

GLOBAL_LIST_INIT(blacklisted_turf_types_for_transit, list(
	/turf/space,
	/turf/space/openspace,
	/turf/simulated/openspace,
	/turf/simulated/floor/chasm,
	/turf/simulated/floor/plating/lava,
	/turf/simulated/floor/plating/asteroid
	))
