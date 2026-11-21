// Service skills
/datum/skill/service
	category = "Сервис"
	category_color = "#6ca729"

/datum/skill/service/drink_mixing
	id = "service.drink_mixing"
	name = "Смешивание напитков"
	desc = "Влияет на смешивание напитков."
	skills_mods = alist(
		DRINKS_DISPENSE_RAND_SIZE = alist(
			SKILL_LEVEL_NONE = 0.5,
			SKILL_LEVEL_BEGINNER = 0.2,
			SKILL_LEVEL_BASIC = 0,
			SKILL_LEVEL_ADVANCED = 0,
			SKILL_LEVEL_PROFESSIONAL = 0,
			SKILL_LEVEL_EXPERT = 0,
			SKILL_LEVEL_LEGEND = 0,
			SKILL_LEVEL_UNAVAILABLE = 1,
		),
		DRINKS_DISPENSE_RAND_REAGENT_PROB = alist(
			SKILL_LEVEL_NONE = 0.5,
			SKILL_LEVEL_BEGINNER = 0.05,
			SKILL_LEVEL_BASIC = 0,
			SKILL_LEVEL_ADVANCED = 0,
			SKILL_LEVEL_PROFESSIONAL = 0,
			SKILL_LEVEL_EXPERT = 0,
			SKILL_LEVEL_LEGEND = 0,
			SKILL_LEVEL_UNAVAILABLE = 1,
		),
	)

/datum/skill/service/botany
	id = "service.botany"
	name = "Ботаника"
	desc = "Влияет на работу с растениями."
	duration_mod_names = list(HYDROPONIC_CULTIVATION_MOD, HYDROPONIC_HARVEST_MOD)
	skills_mods = alist(
		PLANT_GROWTH_RATE = alist(
			SKILL_LEVEL_NONE = 0.5,
			SKILL_LEVEL_BEGINNER = 0.75,
			SKILL_LEVEL_BASIC = 1,
			SKILL_LEVEL_ADVANCED = 1.1,
			SKILL_LEVEL_PROFESSIONAL = 1.25,
			SKILL_LEVEL_EXPERT = 1.5,
			SKILL_LEVEL_LEGEND = 2,
			SKILL_LEVEL_UNAVAILABLE = 0.1,
		),
		BOTANY_DISPENSE_RAND_SIZE = alist(
			SKILL_LEVEL_NONE = 0.5,
			SKILL_LEVEL_BEGINNER = 0.2,
			SKILL_LEVEL_BASIC = 0,
			SKILL_LEVEL_ADVANCED = 0,
			SKILL_LEVEL_PROFESSIONAL = 0,
			SKILL_LEVEL_EXPERT = 0,
			SKILL_LEVEL_LEGEND = 0,
			SKILL_LEVEL_UNAVAILABLE = 1,
		),
		BOTANY_DISPENSE_RAND_REAGENT_PROB = alist(
			SKILL_LEVEL_NONE = 0.5,
			SKILL_LEVEL_BEGINNER = 0.05,
			SKILL_LEVEL_BASIC = 0,
			SKILL_LEVEL_ADVANCED = 0,
			SKILL_LEVEL_PROFESSIONAL = 0,
			SKILL_LEVEL_EXPERT = 0,
			SKILL_LEVEL_LEGEND = 0,
			SKILL_LEVEL_UNAVAILABLE = 1,
		),
	)

/datum/skill/service/cleaning
	id = "service.cleaning"
	name = "Уборка"
	desc = "Влияет на мытье полов и уборку, а так же расход реагента шваброй при этом."
	duration_mod_names = list(CLEANING_SPEED_MOD)
	skills_mods = alist(
		CLEANING_DISTANCE = alist(
			SKILL_LEVEL_NONE = 1,
			SKILL_LEVEL_BEGINNER = 2,
			SKILL_LEVEL_BASIC = 3,
			SKILL_LEVEL_ADVANCED = 4,
			SKILL_LEVEL_PROFESSIONAL = 5,
			SKILL_LEVEL_EXPERT = 6,
			SKILL_LEVEL_LEGEND = 7,
			SKILL_LEVEL_UNAVAILABLE = 0,
		),
	)

/datum/skill/service/cooking
	id = "service.cooking"
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
