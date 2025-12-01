// MARK: All skills signals
/// Get skill level signal, return to levels list (mob/living/user, skill_type, list/levels)
#define COMSIG_GET_SKILL_LEVEL "get_skill_level"
/// Check skill available signal (mob/living/user, skill_type)
#define COMSIG_SKILL_AVAILABLE "get_skill_available"
	/// Skill not available (locked)
	#define SKILL_NOT_AVAILABLE_RESULT (1<<0)
	/// Skill available
	#define SKILL_AVAILABLE_RESULT (1<<1)

// MARK: Engineering
/// Get speed modifier for building skill (mob/living/user, list/modifiers)
#define COMSIG_GET_BUILDING_SPEED_MOD "get_building_speed"
/// Get speed modifier for constructing skill (mob/living/user, list/modifiers)
#define COMSIG_GET_CONSTRUCTING_SPEED_MOD "get_constructing_speed"
/// Get speed modifier for electricity skill (mob/living/user, list/modifiers)
#define COMSIG_GET_ELECTRICITY_SPEED_MOD "get_electricity_speed"
/// Get speed modifier for atmos skill (mob/living/user, list/modifiers)
#define COMSIG_GET_ATMOS_SPEED_MOD "get_atmos_speed"
/// Get speed modifier for lockpick skill (mob/living/user, list/modifiers)
#define COMSIG_GET_LOCKPICK_SPEED_MOD "get_lockpick_speed"

// MARK: Service
/// Get speed modifier for cooking skill (mob/living/user, list/modifiers)
#define COMSIG_GET_COOKING_SPEED_MOD "get_cooking_speed"
/// Get speed modifier for butchering (mob/living/user, list/modifiers)
#define COMSIG_GET_BUTCHERING_SPEED_MOD "get_butchering_speed"
/// Get chance to extra cooking count for cooking skill (mob/living/user, list/chances)
#define COMSIG_GET_COOKING_EXTRA_COUNT_CHANCE "get_cooking_extra_count_chance"
/// Get modifier for mixing (mob/living/user, list/modifiers)
#define COMSIG_GET_DRINKS_MIXING_SPEED_MOD "get_drinks_mixing_speed"
