// General skills
/datum/skill/general
	category = "Общие"
	category_color = "#b88646"

/datum/skill/general/carrying
	id = "general.carrying"
	name = "Переноска"
	desc = "Влияет на переноску вещей и скорость захвата."
	skills_mods = alist(
		PULL_SLOWDOWN_MODIFIERS = alist(
			SKILL_LEVEL_NONE = 1.2,
			SKILL_LEVEL_BEGINNER = 1.1,
			SKILL_LEVEL_BASIC = 1,
			SKILL_LEVEL_ADVANCED = 0.9,
			SKILL_LEVEL_PROFESSIONAL = 0.7,
			SKILL_LEVEL_EXPERT = 0.6,
			SKILL_LEVEL_LEGEND = 0.5,
			SKILL_LEVEL_UNAVAILABLE = 3,
		),
		GRAB_SPEED_MODIFIERS = alist(
			SKILL_LEVEL_NONE = 1.2,
			SKILL_LEVEL_BEGINNER = 1.1,
			SKILL_LEVEL_BASIC = 1,
			SKILL_LEVEL_ADVANCED = 0.95,
			SKILL_LEVEL_PROFESSIONAL = 0.9,
			SKILL_LEVEL_EXPERT = 0.85,
			SKILL_LEVEL_LEGEND = 0.8,
			SKILL_LEVEL_UNAVAILABLE = 3,
		),
	)

/datum/skill/general/mech_drive
	id = "general.mech_drive"
	name = "Управление мехами и подами"
	desc = "Влияет на скорость входа, скорость ремонта, а также потребление батареи."
	duration_mod_names = list(MECHA_DURATION_SPEED_MOD)
	quality_mod_names = list(MECHA_CELL_USAGE_MOD, SPACEPOD_BATTERY_USAGE_MOD)

/datum/skill/general/mod_use
	id = "general.mod_use"
	name = "ВКД"
	desc = "Влияет на скорость одевания и передвижения в МЭКах и РИГах."
	duration_mod_names = list(MOD_ACTIVATION_SPEED_MOD)
	skills_mods = alist(
		SPACESUIT_SLOWDOWN_MOD = alist(
			SKILL_LEVEL_NONE = 1.2,
			SKILL_LEVEL_BEGINNER = 1.1,
			SKILL_LEVEL_BASIC = 1,
			SKILL_LEVEL_ADVANCED = 0.9,
			SKILL_LEVEL_PROFESSIONAL = 0.8,
			SKILL_LEVEL_EXPERT = 0.7,
			SKILL_LEVEL_LEGEND = 0.6,
			SKILL_LEVEL_UNAVAILABLE = 3,
		),
	)

/datum/skill/general/mixing
	id = "general.mixing"
	name = "Смешивание"
	desc = "Влияет на ввод реагентов в ёмкость, а также потребление энергии раздатчиком."
	duration_mod_names = list(MIXING_DISPENCE_CELL_USE_MOD)
	skills_mods = alist(
		MIXING_DISPENSE_RAND_SIZE = alist(
			SKILL_LEVEL_NONE = 0.75,
			SKILL_LEVEL_BEGINNER = 0.5,
			SKILL_LEVEL_BASIC = 0,
			SKILL_LEVEL_ADVANCED = 0,
			SKILL_LEVEL_PROFESSIONAL = 0,
			SKILL_LEVEL_EXPERT = 0,
			SKILL_LEVEL_LEGEND = 0,
			SKILL_LEVEL_UNAVAILABLE = 10,
		),
	)

/datum/skill/general/cooking
	id = "general.cooking"
	name = "Готовка"
	desc = "Влияет на скорость приготовления блюд, шанс дополнительной порции, шанс поломки при неправильном рецепте."
	duration_mod_names = list(COOKING_SPEED_MOD, BUTCHERING_SPEED_MOD)
	quality_mod_names = list(COOKING_BROKE_MOD)
	skills_mods = alist(
		COOKING_EXTRA_COUNT_CHANCE = alist(
			SKILL_LEVEL_NONE = 5,
			SKILL_LEVEL_BEGINNER = 10,
			SKILL_LEVEL_BASIC = 15,
			SKILL_LEVEL_ADVANCED = 30,
			SKILL_LEVEL_PROFESSIONAL = 50,
			SKILL_LEVEL_EXPERT = 75,
			SKILL_LEVEL_LEGEND = 100,
			SKILL_LEVEL_UNAVAILABLE = 0,
		),
	)
