GLOBAL_LIST_EMPTY(hunger_levels)
/datum/hunger_level
	var/above = null
	var/below = null
	var/min_nutrition = 0
	var/move_mod = 0
	var/tool_mod = 0
	var/stamina_max = MAX_STAMINA_LOSS
	var/sound_env = SOUND_ENVIRONMENT_NONE
	var/regen_stamina = FALSE
	var/regen_blood = FALSE

/datum/hunger_level/starving
	min_nutrition = 0
	move_mod = 2
	tool_mod = 0.5
	stamina_max = MAX_STAMINA_LOSS - 10
	sound_env = SOUND_ENVIRONMENT_DRUGGED
	above = /datum/hunger_level/hungry
	below = null

/datum/hunger_level/hungry
	min_nutrition = NUTRITION_LEVEL_HYPOGLYCEMIA + 1
	move_mod = 1
	tool_mod = 0.25
	stamina_max = MAX_STAMINA_LOSS - 5
	sound_env = SOUND_ENVIRONMENT_NONE
	above = /datum/hunger_level/normal
	below = /datum/hunger_level/starving

/datum/hunger_level/normal
	min_nutrition = NUTRITION_LEVEL_HUNGRY + 1
	move_mod = 0
	tool_mod = 0
	stamina_max = MAX_STAMINA_LOSS
	sound_env = SOUND_ENVIRONMENT_NONE
	above = /datum/hunger_level/fed
	below = /datum/hunger_level/hungry

/datum/hunger_level/fed
	min_nutrition = NUTRITION_LEVEL_FED + 1
	move_mod = 0
	tool_mod = 0
	stamina_max = MAX_STAMINA_LOSS + 5
	sound_env = SOUND_ENVIRONMENT_NONE
	above = /datum/hunger_level/full
	below = /datum/hunger_level/normal

/datum/hunger_level/full
	min_nutrition = NUTRITION_LEVEL_WELL_FED + 1
	move_mod = 0
	tool_mod = 0
	stamina_max = MAX_STAMINA_LOSS + 10
	sound_env = SOUND_ENVIRONMENT_NONE
	regen_stamina = TRUE
	regen_blood = TRUE
	above = null
	below = /datum/hunger_level/fed
