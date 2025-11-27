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

/// Skill modifier types
#define SKILL_MOD_TYPE_DURATION "duration"
#define SKILL_MOD_TYPE_QUALITY "quality"

GLOBAL_LIST_EMPTY(skill_levels)
GLOBAL_LIST_EMPTY(character_skills)

#define CALCULATE_SKILL_MOD(user, signal, mod) var/mod = 1;\
	var/list/mods = list();\
	SEND_SIGNAL(user, signal, mods);\
	for(var/modifier in mods){\
		mod *= modifier;\
	}
