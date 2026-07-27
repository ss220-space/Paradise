// MARK: All skills signals
/// Get skill level signal, return to levels list (mob/living/user, skill_type, list/levels)
#define COMSIG_GET_SKILL_LEVEL "get_skill_level"
/// Check skill available signal (mob/living/user, skill_type)
#define COMSIG_SKILL_AVAILABLE "get_skill_available"
	/// Skill not available (locked)
	#define SKILL_NOT_AVAILABLE_RESULT (1<<0)
	/// Skill available
	#define SKILL_AVAILABLE_RESULT (1<<1)

/// Signal pattern: Template for fetching skill modifier contributions. Sends a modifier alist and the modifier name. DO NOT SEND DIRECTLY!!! Use CALCULATE_SKILL_MOD() macro instead.
#define COMSIG_GET_SKILL_MOD(mod) "get_skill_mod[mod]"
