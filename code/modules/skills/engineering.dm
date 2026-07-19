// Engineering skills
/datum/skill/engineering
	category = "Инженерные"
	category_color = "#f37746"

/datum/skill/engineering/building
	id = "engineering.building"
	name = "Строительство"
	desc = "Влияет на скорость строительства."
	duration_mod_signals = list(COMSIG_GET_BUILDING_SPEED_MOD)
	speed_modifiers = alist(
		SKILL_LEVEL_NONE = 1.5,
		SKILL_LEVEL_BEGINNER = 1.25,
		SKILL_LEVEL_BASIC = 1,
		SKILL_LEVEL_ADVANCED = 0.8,
		SKILL_LEVEL_PROFESSIONAL = 0.7,
		SKILL_LEVEL_EXPERT = 0.6,
		SKILL_LEVEL_LEGEND = 0.5,
		SKILL_LEVEL_UNAVAILABLE = 1000,
	)

/datum/skill/engineering/construction
	id = "engineering.construction"
	name = "Конструирование"
	desc = "Влияет на скорость конструирования машинерии."
	duration_mod_signals = list(COMSIG_GET_CONSTRUCTING_SPEED_MOD)
	speed_modifiers = alist(
		SKILL_LEVEL_NONE = 1.5,
		SKILL_LEVEL_BEGINNER = 1.25,
		SKILL_LEVEL_BASIC = 1,
		SKILL_LEVEL_ADVANCED = 0.8,
		SKILL_LEVEL_PROFESSIONAL = 0.7,
		SKILL_LEVEL_EXPERT = 0.6,
		SKILL_LEVEL_LEGEND = 0.5,
		SKILL_LEVEL_UNAVAILABLE = 1000,
	)

/datum/skill/engineering/electrician
	id = "engineering.electrician"
	name = "Электрика"
	desc = "Влияет на работу с электричеством (шанс удара током)."
	duration_mod_signals = list(COMSIG_GET_ELECTRICITY_SPEED_MOD, COMSIG_GET_ELECTRICITY_NEGATIVE_CHANCE_MOD)
	quality_modifiers = list(COMSIG_GET_ELECTRICITY_POSITIVE_CHANCE_MOD)

/datum/skill/engineering/atmos
	id = "engineering.atmos"
	name = "Атмостехника"
	desc = "Влияет на работу с трубами и остальной атмосферной техникой."
	duration_mod_signals = list(COMSIG_GET_ATMOS_SPEED_MOD)
