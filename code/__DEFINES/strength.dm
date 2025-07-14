#define STRENGTH_LEVEL_WEAK			1
#define STRENGTH_LEVEL_NORMAL		2
#define STRENGTH_LEVEL_STRONG		3
#define STRENGTH_LEVEL_IDEAL		4
#define STRENGTH_LEVEL_SUPERHUMAN	5

#define STRENGTH_LEVEL_MAXDEFAULT	4
#define STRENGTH_LEVEL_DEFAULT		2

GLOBAL_LIST_INIT(strength_levels, list(
	/datum/strength_level/weak,
	/datum/strength_level/normal,
	/datum/strength_level/strong,
	/datum/strength_level/ideal,
	/datum/strength_level/superhuman,
))
