// Engineering skills
/datum/skill/engineering
	category = "Инженерные"
	category_color = "#f37746"

/datum/skill/engineering/building
	id = "engineering.building"
	name = "Строительство"
	desc = "Влияет на скорость строительства."
	duration_mod_names = list(BUILDING_SPEED_MOD)

/datum/skill/engineering/construction
	id = "engineering.construction"
	name = "Конструирование"
	desc = "Влияет на скорость конструирования машинерии."
	duration_mod_names = list(CONSTRUCTING_SPEED_MOD)

/datum/skill/engineering/electrician
	id = "engineering.electrician"
	name = "Электрика"
	desc = "Влияет на работу с проводами, взлом вещей и безопасность трогать провода (шанс удара током)."
	duration_mod_names = list(ELECTRICITY_SPEED_MOD, ELECTRICITY_NEGATIVE_CHANCE_MOD, LOCKPICK_SPEED_MOD)
	quality_mod_names = list(ELECTRICITY_POSITIVE_CHANCE_MOD, LOCKPICK_POSITIVE_CHANCE_MOD)

/datum/skill/engineering/atmos
	id = "engineering.atmos"
	name = "Атмостехника"
	desc = "Влияет на работу с трубами и остальной атмосферной техникой, а так же на силу удара от давления в трубах."
	duration_mod_names = list(ATMOS_SPEED_MOD)
	skills_mods = alist(
		UNSAFE_PRESSURE_MOD = alist(
			SKILL_LEVEL_NONE = 1.1,
			SKILL_LEVEL_BEGINNER = 1.05,
			SKILL_LEVEL_BASIC = 1,
			SKILL_LEVEL_ADVANCED = 0.7,
			SKILL_LEVEL_PROFESSIONAL = 0.5,
			SKILL_LEVEL_EXPERT = 0.3,
			SKILL_LEVEL_LEGEND = 0.1,
			SKILL_LEVEL_UNAVAILABLE = 2,
		),
	)
