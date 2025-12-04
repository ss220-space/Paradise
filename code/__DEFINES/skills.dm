// skill levels defines
#define SKILL_LEVEL_NONE 1
#define SKILL_LEVEL_BEGINNER 2
#define SKILL_LEVEL_BASIC 3
#define SKILL_LEVEL_ADVANCED 4
#define SKILL_LEVEL_PROFESSIONAL 5
#define SKILL_LEVEL_EXPERT 6
#define SKILL_LEVEL_LEGEND 7
#define SKILL_LEVEL_UNAVAILABLE 8

/// Maximal level of skill level
#define MAX_SKILL_LEVEL 6
/// Skill level if not exists skill datum
#define DEFAULT_SKILL_LEVEL 2

/// Calculate skill modifier by signal
#define CALCULATE_SKILL_MOD(user, signal, mod) var/mod = 1;\
	var/list/mod##_s = list();\
	SEND_SIGNAL(user, signal, (mod##_s));\
	for(var/modifier in (mod##_s)){\
		mod *= modifier;\
	}
/// Get skill level by signal
#define GET_SKILL_LEVEL(user, skill_type, lvl) var/lvl = SKILL_LEVEL_BASIC;\
	var/list/lvl##_s = list();\
	SEND_SIGNAL(user, COMSIG_GET_SKILL_LEVEL, skill_type, (lvl##_s));\
	for(var/m_level in (lvl##_s)){\
		lvl = m_level;\
	}
/// Get skill level by signal
#define AVAILABLE_SKILL(user, skill_type) (SEND_SIGNAL(user, COMSIG_SKILL_AVAILABLE, skill_type) == SKILL_AVAILABLE_RESULT)
/// Check level great than
#define CHECK_SKILL_LEVEL(user, skill_type, req_level) (AVAILABLE_SKILL(user, skill_type) && SEND_SIGNAL(user, COMSIG_SKILL_AVAILABLE, skill_type) >= req_level)

GLOBAL_LIST_INIT(skill_level_names, list(
	"[SKILL_LEVEL_NONE]" = "нет навыка",
	"[SKILL_LEVEL_BEGINNER]" = "начальный навык",
	"[SKILL_LEVEL_BASIC]" = "базовый навык",
	"[SKILL_LEVEL_ADVANCED]" = "продвинутый навык",
	"[SKILL_LEVEL_PROFESSIONAL]" = "профессиональный навык",
	"[SKILL_LEVEL_EXPERT]" = "экспертный навык",
	"[SKILL_LEVEL_LEGEND]" = "легендарный навык",
	"[SKILL_LEVEL_UNAVAILABLE]" = "недоступно",
))
GLOBAL_LIST_INIT(skill_level_colors, list(
	"[SKILL_LEVEL_NONE]" = "#ea9999",
	"[SKILL_LEVEL_BEGINNER]" = "#ffe599",
	"[SKILL_LEVEL_BASIC]" = "#b6d7a8",
	"[SKILL_LEVEL_ADVANCED]" = "#a4c2f4",
	"[SKILL_LEVEL_PROFESSIONAL]" = "#3c78d8",
	"[SKILL_LEVEL_EXPERT]" = "#b4a7d6",
	"[SKILL_LEVEL_LEGEND]" = "#a64d79",
	"[SKILL_LEVEL_UNAVAILABLE]" = "#999999",
))
