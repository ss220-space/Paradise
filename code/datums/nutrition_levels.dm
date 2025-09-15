/// Different nutrition levels used by /datum/element/nutrition_effects, currently works only for /mob/living/carbon/human
/datum/nutrition_level
	/// How much nutrition for the next and previous levels
	var/level_increase_threshold
	var/level_decrease_threshold
	/// Slowdown amount caused by hunger
	var/tool_speed_mod = 0
	var/move_speed_mod = 0
	/// How much max stamina human will gain (or lost) on this nutrition level
	var/max_stamina_bonus = 0
	/// Used by hypoglycemia for sound distortion
	var/sound_env = SOUND_ENVIRONMENT_NONE
	/// Amount of regen on nutrition level
	var/blood_regen = 0
	var/stamina_regen = 0
	/// Icon used for nutrition bar hud
	var/icon_state


// NUTRITION_LEVEL_HYPOGLYCEMIA
/datum/nutrition_level/hypoglycemia
	level_increase_threshold = 100
	level_decrease_threshold = -INFINITY
	max_stamina_bonus = -10
	tool_speed_mod = 0.5
	move_speed_mod = 6
	icon_state = "starving"
	sound_env = SOUND_ENVIRONMENT_DRUGGED


// NUTRITION_LEVEL_STARVING
/datum/nutrition_level/starving
	level_increase_threshold = 150
	level_decrease_threshold = 100
	max_stamina_bonus = -10
	tool_speed_mod = 0.25
	move_speed_mod = 3
	icon_state = "starving"


// NUTRITION_LEVEL_HUNGRY
/datum/nutrition_level/hungry
	level_increase_threshold = 250
	level_decrease_threshold = 150
	max_stamina_bonus = -5
	tool_speed_mod = 0.25
	icon_state = "hungry"


// NUTRITION_LEVEL_FED
/datum/nutrition_level/fed
	level_increase_threshold = 350
	level_decrease_threshold = 250
	icon_state = "fed"


// NUTRITION_LEVEL_WELL_FED
/datum/nutrition_level/well_fed
	level_increase_threshold = 450
	level_decrease_threshold = 350
	max_stamina_bonus = 5
	icon_state = "well_fed"


// NUTRITION_LEVEL_FULL
/datum/nutrition_level/full
	level_increase_threshold = 550
	level_decrease_threshold = 450
	max_stamina_bonus = 10
	blood_regen = 0.2
	stamina_regen = -0.5
	icon_state = "full"


// NUTRITION_LEVEL_FAT
/datum/nutrition_level/fat
	level_increase_threshold = INFINITY
	level_decrease_threshold = 550
	icon_state = "fat"
