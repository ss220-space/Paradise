// skill levels defines
#define SKILL_LEVEL_UNAVAILABLE 0
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
#define DEFAULT_SKILL_LEVEL 1

/// Countf of free skill points by default
#define BASIC_SKILL_POINTS_COUNT 5
/// Countf of free skill points for some roles
#define ADVANCED_SKILL_POINTS_COUNT 10
/// Countf of free skill points for antags
#define BASIC_ANTAG_SKILL_POINTS_BONUS 1


/// Default limit for use free skill points on single skill
#define DEFAULT_FREE_POINTS_USE_LIMIT 2

// MARK: Engineering
/// Speed modifier for building skill
#define BUILDING_SPEED_MOD "building_speed_mod"
/// Speed modifier for constructing skill
#define CONSTRUCTING_SPEED_MOD "constructing_speed_mod"
/// Speed modifier for electricity skill
#define ELECTRICITY_SPEED_MOD "electricity_speed_mod"
/// Negative probability modifier for electricity skill
#define ELECTRICITY_NEGATIVE_CHANCE_MOD "electricity_negative_chance_mod"
/// Positive probability modifier for electricity skill
#define ELECTRICITY_POSITIVE_CHANCE_MOD "electricity_positive_chance_mod"
/// Speed modifier for atmos skill
#define ATMOS_SPEED_MOD "atmos_speed_mod"
/// Speed modifier for lockpick skill
#define LOCKPICK_SPEED_MOD "lockpick_speed_mod"
/// Positive probability modifier for lockpick skill
#define LOCKPICK_POSITIVE_CHANCE_MOD "lockpick_positive_chance_mod"
/// Unsafe pressure release mod
#define UNSAFE_PRESSURE_MOD "unsafe_pressure_mod"

// MARK: Service
/// Speed modifier for cooking skill
#define COOKING_SPEED_MOD "cooking_speed_mod"
/// Broke modifier for cooking skill
#define COOKING_BROKE_MOD "cooking_broke_mod"
/// Speed modifier for butchering
#define BUTCHERING_SPEED_MOD "butchering_speed_mod"
/// Chance for extra cooking count
#define COOKING_EXTRA_COUNT_CHANCE "cooking_extra_count_chance"
/// Dispense random size modifier for drinks skill
#define DRINKS_DISPENSE_RAND_SIZE "drinks_dispense_rand_size"
/// Сhance to dispense a random reagent
#define DRINKS_DISPENSE_RAND_REAGENT_PROB "drinks_dispense_rand_reagent_prob"
/// Plant growth rate modifier for botany skill
#define PLANT_GROWTH_RATE "plant_growth_rate"
/// Hydroponic cultivation modifier for botany skill
#define HYDROPONIC_CULTIVATION_MOD "hydroponic_cultivation_mod"
/// Harvest modifier for botany skill
#define HYDROPONIC_HARVEST_MOD "hydroponic_harvest_mod"
/// Speed modifier for cleaning skill
#define CLEANING_SPEED_MOD "cleaning_speed_mod"
/// Cleaning distance modifier for cleaning skill
#define CLEANING_DISTANCE "cleaning_distance"

#define MINING_SPEED_MOD "mining_speed_mod"

#define MINING_PROBS_MOD "mining_probs_mod"

// MARK: General
/// Speed modifier for mech driving skill
#define MECHA_DRIVING_SPEED_MOD "mecha_driving_speed_mod"
/// Speed modifier for climbing into mech
#define MECHA_CLIMBING_SPEED_MOD "mecha_climbing_speed_mod"
/// Cell charge usage modifier for mechs
#define MECHA_CELL_USAGE_MOD "mecha_cell_usage_mod"
/// Speed modifier for activating MOD suits
#define MOD_ACTIVATION_SPEED_MOD "mod_activation_speed_mod"
/// Slowdown modifier for worn space-suits/hardsuits/MOD suits
#define SPACESUIT_SLOWDOWN_MOD "spacesuit_slowdown_mod"
/// Spacepod battery usage modifier
#define SPACEPOD_BATTERY_USAGE_MOD "spacepod_battery_usage_mod"
/// Grab speed modifier
#define GRAB_SPEED_MODIFIERS "grab_speed_modifiers"
/// Grab slowdown modifier
#define PULL_SLOWDOWN_MODIFIERS "pull_slowdown_modifiers"

// MARK: Combat
/// Accuracy modifier for accuracy skill
#define ACCURACY_MOD "accuracy_mod"
/// Spread modifier for accuracy skill
#define SPREAD_MOD "spread_mod"
/// Gun reload speed modifier for guns skill
#define GUN_RELOAD_MOD "gun_reload_mod"
/// Magazine reload speed modifier for guns skill
#define MAGAZINE_RELOAD_MOD "magazine_reload_mod"
/// Misfire chance modifier for guns skill
#define MISFIRE_CHANCE "misfire_chance"
/// Recoil modifier for guns skill
#define RECOIL_MOD "recoil_mod"
/// Melee weapon damage modifier for melee skill
#define MELEE_DAMAGE_MOD "melee_damage_mod"
/// Unarmed melee damage modifier for fists skill
#define FISTS_DAMAGE_MOD "fists_damage_mod"
/// Disarm chance modifier for fists skill
#define FISTS_DISARM_MOD "fists_disarm_mod"
/// Grab duration modifier for fists skill
#define FISTS_GRAB_MOD "fists_grab_mod"
/// Shield chance modifier for shields skill
#define SHIELD_MOD "shield_mod"
/// Accuracy modifier for bows skill
#define BOW_ACCURACY_MOD "bow_accuracy_mod"
/// Spread modifier for bows skill
#define BOW_SPREAD_MOD "bow_spread_mod"
/// Slowdown modifier for bows skill
#define BOW_SLOWDOWN_MOD "bow_slowdown_mod"
/// Bow ready to fire time modifier
#define BOW_READY_TO_FIRE_MOD "bow_ready_to_fire_mod"

// MARK: Medical
/// Duration modifier for surgery skill
#define SURGERY_DURATION_MOD "surgery_duration_mod"
/// Success chance modifier for surgery skill
#define SURGERY_SUCCESS_MOD "surgery_success_mod"
/// Duration modifier for heal skill
#define HEAL_DURATION_MOD "heal_duration_mod"
/// Amount modifier for heal skill
#define HEAL_AMOUNT_MOD "heal_amount_mod"
/// Dispense random size modifier for chemistry skill
#define CHEMISTRY_DISPENSE_RAND_SIZE "chemistry_dispense_rand_size"
/// Сhance to dispense a random reagent
#define CHEMISTRY_DISPENSE_RAND_REAGENT_PROB "chemistry_dispense_rand_reagent_prob"
/// Irradiation duration modifier for genetic skill
#define IRRADIATION_DURATION_MOD "irradiation_duration_mod"

// MARK: Research
/// Mech Construction сhance to print a random item from the category
#define MECH_CONSTRUCT_RAND_BUILD_PROB "mech_construct_rand_build_prob"
/// Construction duration modifier for mech construct skill
#define MECH_CONSTRUCT_DURATION_MOD "mech_construct_duration_mod"
/// Protolathe сhance to print a random item from the category
#define PROTOLATHE_RAND_BUILD_PROB "protolathe_rand_build_prob"
/// Protolathe item creation duration modifier
#define PROTOLATHE_DURATION_MOD "protolathe_duration_mod"
/// Protolathe item creation resource modifier
#define PROTOLATHE_RESOURCE_MOD "protolathe_resource_mod"
/// Research duration modifier
#define RESEARCH_DURATION_MOD "research_duration_mod"
/// Research success chance modifier
#define RESEARCH_SUCCESS_MOD "research_success_mod"
/// Double loot chance modifier for xenobio skill
#define XENOBIO_DOUBLE_LOOT_MOD "xenobio_double_loot_mod"

// MARK: Not skills mod sources
#define STRENGTH_MOD_SOURCE "strength_mod_source"

/// Calculate skill modifier by signal
#define CALCULATE_SKILL_MOD(user, mod_name, mod) var/mod = 1;\
	var/alist/mod##_s = alist();\
	if(user){\
		SEND_SIGNAL(user, COMSIG_GET_SKILL_MOD(mod_name), (mod##_s), (mod_name));\
		mod = values_product((mod##_s));\
	}
/// Get skill level by signal
#define GET_SKILL_LEVEL(user, skill_type, lvl) var/lvl = SKILL_LEVEL_BASIC;\
	if(user){\
		var/list/lvl##_s = list();\
		SEND_SIGNAL(user, COMSIG_GET_SKILL_LEVEL, skill_type, (lvl##_s));\
		for(var/m_level in (lvl##_s)){\
			lvl = m_level;\
		}\
	}
/// Get skill level by signal
#define AVAILABLE_SKILL(user, skill_type) (SEND_SIGNAL(user, COMSIG_SKILL_AVAILABLE, skill_type) == SKILL_AVAILABLE_RESULT)

GLOBAL_LIST_INIT(skill_level_names, alist(
	SKILL_LEVEL_NONE = "нет навыка",
	SKILL_LEVEL_BEGINNER = "начальный навык",
	SKILL_LEVEL_BASIC = "базовый навык",
	SKILL_LEVEL_ADVANCED = "продвинутый навык",
	SKILL_LEVEL_PROFESSIONAL = "профессиональный навык",
	SKILL_LEVEL_EXPERT = "экспертный навык",
	SKILL_LEVEL_LEGEND = "легендарный навык",
	SKILL_LEVEL_UNAVAILABLE = "недоступно",
))
GLOBAL_LIST_INIT(skill_level_colors, alist(
	SKILL_LEVEL_NONE = "#ea9999",
	SKILL_LEVEL_BEGINNER = "#ffe599",
	SKILL_LEVEL_BASIC = "#b6d7a8",
	SKILL_LEVEL_ADVANCED = "#a4c2f4",
	SKILL_LEVEL_PROFESSIONAL = "#3c78d8",
	SKILL_LEVEL_EXPERT = "#b4a7d6",
	SKILL_LEVEL_LEGEND = "#a64d79",
	SKILL_LEVEL_UNAVAILABLE = "#999999",
))

GLOBAL_LIST_INIT(skill_neurotrainer_blacklist, list(
	/obj/item/neurotrainer/all_without_combat,
	/obj/item/neurotrainer/general,
	/obj/item/neurotrainer/service,
	/obj/item/neurotrainer/combat,
	/obj/item/neurotrainer/engineering,
	/obj/item/neurotrainer/medical,
	/obj/item/neurotrainer/research,
))
GLOBAL_LIST_EMPTY(skill_neurotrainers)
GLOBAL_LIST_EMPTY(skill_types)

GLOBAL_LIST_INIT(antag_skills, list(
		/datum/skill/combat/accuracy = SKILL_LEVEL_ADVANCED,
		/datum/skill/combat/guns = SKILL_LEVEL_ADVANCED,
		/datum/skill/combat/melee = SKILL_LEVEL_ADVANCED,
		/datum/skill/combat/fists = SKILL_LEVEL_ADVANCED,
))
