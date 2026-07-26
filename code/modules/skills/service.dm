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
			SKILL_LEVEL_NONE = 0.25,
			SKILL_LEVEL_BEGINNER = 0.2,
			SKILL_LEVEL_BASIC = 0.1,
			SKILL_LEVEL_ADVANCED = 0.05,
			SKILL_LEVEL_PROFESSIONAL = 0.025,
			SKILL_LEVEL_EXPERT = 0.01,
			SKILL_LEVEL_LEGEND = 0,
			SKILL_LEVEL_UNAVAILABLE = 0.5,
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
	)

/datum/skill/service/cleaning
	id = "service.cleaning"
	name = "Уборка"
	desc = "Влияет на мытье полов и уборку."
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
