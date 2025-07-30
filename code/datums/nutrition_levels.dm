/datum/nutrition_level
	// How much nutrition for the next and previous levels
	var/level_increase_threshold
	var/level_decrease_threshold
	// Slowdown amount caused by hunger
	var/tool_speed_mod = 0
	var/move_speed_mod = 0
	// How much max stamina human will gain (or lost) on this nutrition level
	var/max_stamina_bonus = 0
	var/sound_env = SOUND_ENVIRONMENT_NONE


/datum/nutrition_level/fat
	level_decrease_threshold = 550


/datum/nutrition_level/full
	level_increase_threshold = 550
	level_decrease_threshold = 450
	max_stamina_bonus = 10
	blood_regen = 0.2
	stamina_regen = -0.5


/datum/nutrition_level/well_fed
	level_increase_threshold = 450
	level_decrease_threshold = 350
	max_stamina_bonus = 5


/datum/nutrition_level/fed
	level_increase_threshold = 350
	level_decrease_threshold = 250


/datum/nutrition_level/hungry
	level_increase_threshold = 250
	level_decrease_threshold = 150
	max_stamina_bonus = -5
	tool_speed_mod = 0.25


/datum/nutrition_level/starving
	level_increase_threshold = 150
	level_decrease_threshold = 100
	max_stamina_bonus = -5
	tool_speed_mod = 0.25
	move_speed_mod = 2


/datum/nutrition_level/hypoglycemia
	level_increase_threshold = 100
	max_stamina_bonus = -10
	tool_speed_mod = 0.5
	move_speed_mod = 4
	sound_env = SOUND_ENVIRONMENT_DRUGGED
