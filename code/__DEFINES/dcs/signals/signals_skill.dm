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
#define COMSIG_GET_COOKING_SPEED_MOD "get_cooking_speed_mod"
/// Get broke modifier for cooking skill (mob/living/user, list/modifiers)
#define COMSIG_GET_COOKING_BROKE_MOD "get_cooking_broke_mod"
/// Get speed modifier for butchering (mob/living/user, list/modifiers)
#define COMSIG_GET_BUTCHERING_SPEED_MOD "get_butchering_speed"
/// Get chance to extra cooking count for cooking skill (mob/living/user, list/chances)
#define COMSIG_GET_COOKING_EXTRA_COUNT_CHANCE "get_cooking_extra_count_chance"
/// Get chem reaction amount modifier for drinks skill (mob/living/user, list/modifiers)
#define COMSIG_GET_DRINKS_DISPENSE_RAND_SIZE "get_drinks_dispense_rand_size"

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
/// Get spacepod battery usage modifier (mob/living/user, list/modifiers)
#define COMSIG_GET_SPACEPOD_BATTERY_USAGE_MOD "get_spacepod_battery_usage"

// MARK: Service
/// Get speed modifier for cleaning skill (mob/living/user, list/modifiers)
#define COMSIG_GET_CLEANING_SPEED_MOD "get_cleaning_speed"
/// Get cleaning distance modifier for cleaning skill (mob/living/user, list/modifiers)
#define COMSIG_GET_CLEANING_DISTANCE_MOD

// MARK: Combat
/// Get gun accuracy modifier for accuracy skill (mob/living/user, list/modifiers)
#define COMSIG_GET_ACCURACY_MOD "get_accuracy_mod"
/// Get gun spread modifier for accuracy skill (mob/living/user, list/modifiers)
#define COMSIG_GET_SPREAD_MOD "get_spread_mod"
/// Get gun reload speed modifier for guns skill (mob/living/user, list/modifiers)
#define COMSIG_GET_GUN_RELOAD_MOD "get_gun_reload_mod"
/// Get magazine reload speed modifier for guns skill (mob/living/user, list/modifiers)
#define COMSIG_GET_MAGAZINE_RELOAD_MOD "get_magazine_reload_mod"
/// Get missfire chance for guns skill (mob/living/user, list/modifiers)
#define COMSIG_GET_MISSFIRE_CHANCE "get_missfire_chance"
/// Get gun recoil mod for guns skill (mob/living/user, list/modifiers)
#define COMSIG_GET_RECOIL_MOD "get_recoil_mod"
/// Get melee weapon damage mod for melee skill (mob/living/user, list/modifiers)
#define COMSIG_GET_MELEE_DAMAGE_MOD "get_melee_damage_mod"
/// Get unarmed melee damage mod for fists skill (mob/living/user, list/modifiers)
#define COMSIG_GET_FISTS_DAMAGE_MOD "get_fists_damage_mod"
/// Get disarm chance mod for fists skill (mob/living/user, list/modifiers)
#define COMSIG_GET_FISTS_DISARM_MOD "get_fists_disarm_mod"
/// Get grab duration mod for fists skill (mob/living/user, list/modifiers)
#define COMSIG_GET_FISTS_GRAB_MOD "get_fists_grab_mod"
/// Get shield chance mod for shields skill (mob/living/user, list/modifiers)
#define COMSIG_GET_SHIELD_MOD "get_shield_mod"

// MARK: Medical
/// Get surgeon duration modifier for surgery skill (mob/living/user, list/modifiers)
#define COMSIG_GET_SURGERY_DURATION_MOD "get_surgery_duration_mod"
/// Get surgeon success chance modifier for surgery skill (mob/living/user, list/modifiers)
#define COMSIG_GET_SURGERY_SUCCESS_MOD "get_surgery_success_mod"
/// Get heal duration modifier for heal skill (mob/living/user, list/modifiers)
#define COMSIG_GET_HEAL_DURATION_MOD "get_heal_duration_mod"
/// Get heal amount modifier for heal skill (mob/living/user, list/modifiers)
#define COMSIG_GET_HEAL_AMOUNT_MOD "get_heal_amount_mod"
/// Get chem reaction amount modifier for chemistry skill (mob/living/user, list/modifiers)
#define COMSIG_GET_CHEMISTRY_DISPENSE_RAND_SIZE "get_chemistry_dispense_rand_size"
/// Get genetic irradiation duration modifier for genetic skill (mob/living/user, list/modifiers)
#define COMSIG_GET_IRRADIATION_DURATION_MOD "get_irradiation_duration_mod"
