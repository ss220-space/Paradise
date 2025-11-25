// skill levels defines
#define SKILL_LEVEL_UNAVAILABLE -1
#define SKILL_LEVEL_NONE 0
#define SKILL_LEVEL_BEGINNER 1
#define SKILL_LEVEL_BASIC 2
#define SKILL_LEVEL_ADVANCED 3
#define SKILL_LEVEL_PROFESSIONAL 4
#define SKILL_LEVEL_EXPERT 5
#define SKILL_LEVEL_LEGEND 6

/// Maximal level of skill level
#define MAX_SKILL_LEVEL 6
/// Skill level if not exists skill datum
#define DEFAULT_SKILL_LEVEL 2

GLOBAL_LIST_EMPTY(skill_levels)

// helper proc
/proc/get_skill_level_datum(level)
	return GLOB.skill_levels["[level]"]
