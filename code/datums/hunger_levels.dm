/datum/hunger_level
	var/min_nutrition
	var/move_mod = 0
	var/tool_mod = 0
	var/stamina_max = MAX_STAMINA_LOSS
	var/sound_env = SOUND_ENVIRONMENT_NONE
	var/regen_stamina = FALSE
	var/regen_blood = FALSE

GLOBAL_LIST(hunger_levels)

/proc/InitHungerLevels()
	if(GLOB.hunger_levels && GLOB.hunger_levels.len)
		return TRUE

	GLOB.hunger_levels = list()
	GLOB.hunger_levels += new /datum/hunger_level {
		min_nutrition = 0
		move_mod = 2
		tool_mod = 0.5
		stamina_max = 110
		sound_env = SOUND_ENVIRONMENT_DRUGGED
	}

	GLOB.hunger_levels += new /datum/hunger_level {
		min_nutrition = NUTRITION_LEVEL_HYPOGLYCEMIA + 1
		move_mod = 1
		tool_mod = 0.25
		stamina_max = 115
		sound_env = SOUND_ENVIRONMENT_NONE
	}

	GLOB.hunger_levels += new /datum/hunger_level {
		min_nutrition = NUTRITION_LEVEL_HUNGRY + 1
		move_mod = 0
		tool_mod = 0
		stamina_max = MAX_STAMINA_LOSS
		sound_env = SOUND_ENVIRONMENT_NONE
	}

	GLOB.hunger_levels += new /datum/hunger_level {
		min_nutrition = NUTRITION_LEVEL_FED + 1
		move_mod = 0
		tool_mod = 0
		stamina_max = 125
		sound_env = SOUND_ENVIRONMENT_NONE
	}

	GLOB.hunger_levels += new /datum/hunger_level {
		min_nutrition = NUTRITION_LEVEL_WELL_FED + 1
		move_mod = 0
		tool_mod = 0
		stamina_max = 130
		sound_env = SOUND_ENVIRONMENT_NONE
		regen_stamina = TRUE
		regen_blood = TRUE
	}

	return TRUE
