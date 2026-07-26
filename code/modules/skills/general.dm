// General skills
/datum/skill/general
	category = "Общие"
	category_color = "#b88646"

/datum/skill/general/carrying
	id = "general.carrying"
	name = "Переноска"
	desc = "Влияет на переноски вещей."
	duration_mod_names = list(PULL_SLOWDOWN_MODIFIERS, GRAB_SPEED_MODIFIERS)

/datum/skill/general/mech_drive
	id = "general.mech_drive"
	name = "Управление мехами (подами)"
	desc = "Влияет на скорость передвижения мехов и подов. Также влияет на скорость разряда батареи."
	duration_mod_names = list(MECHA_CLIMBING_SPEED_MOD)
	quality_mod_names = list(MECHA_CELL_USAGE_MOD, SPACEPOD_BATTERY_USAGE_MOD)
	skills_mods = alist(
		MECHA_DRIVING_SPEED_MOD = alist(
			SKILL_LEVEL_NONE = 1.75,
			SKILL_LEVEL_BEGINNER = 1.5,
			SKILL_LEVEL_BASIC = 1.35,
			SKILL_LEVEL_ADVANCED = 1.20,
			SKILL_LEVEL_PROFESSIONAL = 1.05,
			SKILL_LEVEL_EXPERT = 0.9,
			SKILL_LEVEL_LEGEND = 0.75,
			SKILL_LEVEL_UNAVAILABLE = 0.01,
		),
	)

/datum/skill/general/mod_use
	id = "general.mod_use"
	name = "ВКД"
	desc = "Влияет на скорость одевания МЭКов и РИГов."
	duration_mod_names = list(MOD_ACTIVATION_SPEED_MOD, SPACESUIT_SLOWDOWN_MOD)

/datum/skill/general/cooking
	id = "general.cooking"
	name = "Готовка"
	desc = "Влияет на готовку."
	duration_mod_names = list(COOKING_SPEED_MOD, BUTCHERING_SPEED_MOD)
	quality_mod_names = list(COOKING_BROKE_MOD)
	skills_mods = alist(
		COOKING_EXTRA_COUNT_CHANCE = alist(
			SKILL_LEVEL_NONE = 0,
			SKILL_LEVEL_BEGINNER = 5,
			SKILL_LEVEL_BASIC = 10,
			SKILL_LEVEL_ADVANCED = 25,
			SKILL_LEVEL_PROFESSIONAL = 50,
			SKILL_LEVEL_EXPERT = 75,
			SKILL_LEVEL_LEGEND = 100,
			SKILL_LEVEL_UNAVAILABLE = 0.001,
		),
	)
