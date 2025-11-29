// skill levels defines
#define SKILL_LEVEL_UNAVAILABLE 8
#define SKILL_LEVEL_NONE 1
#define SKILL_LEVEL_BEGINNER 2
#define SKILL_LEVEL_BASIC 3
#define SKILL_LEVEL_ADVANCED 4
#define SKILL_LEVEL_PROFESSIONAL 5
#define SKILL_LEVEL_EXPERT 6
#define SKILL_LEVEL_LEGEND 7

/// Maximal level of skill level
#define MAX_SKILL_LEVEL 6
/// Skill level if not exists skill datum
#define DEFAULT_SKILL_LEVEL 2

/// Calculate skill modifier by signal
#define CALCULATE_SKILL_MOD(user, signal, mod) var/mod = 1;\
	var/list/mods = list();\
	SEND_SIGNAL(user, signal, mods);\
	for(var/modifier in mods){\
		mod *= modifier;\
	}

GLOBAL_LIST_INIT(skill_level_names, list(
	"[SKILL_LEVEL_UNAVAILABLE]" = "недоступно",
	"[SKILL_LEVEL_NONE]" = "нет навыка",
	"[SKILL_LEVEL_BEGINNER]" = "начальный навык",
	"[SKILL_LEVEL_BASIC]" = "базовый навык",
	"[SKILL_LEVEL_ADVANCED]" = "продвинутый навык",
	"[SKILL_LEVEL_PROFESSIONAL]" = "профессиональный навык",
	"[SKILL_LEVEL_EXPERT]" = "экспертный навык",
	"[SKILL_LEVEL_LEGEND]" = "легендарный навык",
))
