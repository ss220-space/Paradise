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
/// Get negative prob modifier for electricity skill (mob/living/user, list/modifiers)
#define COMSIG_GET_ELECTRICITY_NEGATIVE_CHANCE_MOD "get_electricity_negative_prob_mod"
/// Get positive prob modifier for electricity skill (mob/living/user, list/modifiers)
#define COMSIG_GET_ELECTRICITY_POSITIVE_CHANCE_MOD "get_electricity_positive_prob_mod"
/// Get speed modifier for atmos skill (mob/living/user, list/modifiers)
#define COMSIG_GET_ATMOS_SPEED_MOD "get_atmos_speed"
/// Get speed modifier for lockpick skill (mob/living/user, list/modifiers)
#define COMSIG_GET_LOCKPICK_SPEED_MOD "get_lockpick_speed"
/// Get positive prob modifier for lockpick skill (mob/living/user, list/modifiers)
#define COMSIG_GET_LOCKPICK_POSITIVE_CHANCE_MOD "get_lockpick_positive_prob_mod"

// MARK: Service
/// Get speed modifier for cooking skill (mob/living/user, list/modifiers)
#define COMSIG_GET_COOKING_SPEED_MOD "get_cooking_speed"
/// Get speed modifier for butchering (mob/living/user, list/modifiers)
#define COMSIG_GET_BUTCHERING_SPEED_MOD "get_butchering_speed"
/// Get chance to extra cooking count for cooking skill (mob/living/user, list/chances)
#define COMSIG_GET_COOKING_EXTRA_COUNT_CHANCE "get_cooking_extra_count_chance"
/// Get modifier for mixing (mob/living/user, list/modifiers)
#define COMSIG_GET_DRINKS_MIXING_SPEED_MOD "get_drinks_mixing_speed"

// MARK: General
/// Get speed modifier for mech driving skill (mob/living/user, list/modifiers)
#define COMSIG_GET_MECHA_DRIVING_SPEED_MOD "get_mecha_driving_speed"
/// Get speed modifier for climbing into mech (mob/living/user, list/modifiers)
#define COMSIG_GET_MECHA_CLIMBING_SPEED_MOD "get_mecha_climbing_speed"
/// Get quality modifier for cell charge usage on mechs (mob/living/user, list/modifiers)
#define COMSIG_GET_MECHA_CELL_USAGE_MOD "get_mecha_charge_usage"
/// Get speed modifier for activating MOD suits (mob/living/user, list/modifiers)
#define COMSIG_GET_MOD_ACTIVATION_SPEED_MOD "get_mod_activation_speed"
/// Get slowdown modifier for worn space-suits/hardsuits/MOD suits (mob/living/user, list/modifiers)
#define COMSIG_GET_SPACESUIT_SLOWDOWN_MOD "get_spacesuit_slowdown"


// MARK: Combat
/// Get gun accuracy modifier for accuracy skill (mob/living/user, list/modifiers)
#define COMSIG_GET_ACCURACY_MOD "get_accuracy_mod"
/// Get gun spread modifier for accuracy skill (mob/living/user, list/modifiers)
#define COMSIG_GET_SPREAD_MOD "get_spread_mod"
