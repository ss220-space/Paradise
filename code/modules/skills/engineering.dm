// Engineering skills
/datum/skill/engineering
	category = "Инженерные"
	category_color = "#f37746"

/datum/skill/engineering/building
	id = "engineering.building"
	name = "Строительство"
	desc = "Влияет на скорость строительства и взаимодействия с машинерией."
	duration_mod_names = list(BUILDING_SPEED_MOD)

/datum/skill/engineering/electrician
	id = "engineering.electrician"
	name = "Электрика"
	desc = "Влияет на работу с проводами (шанс удара током, отображение информации о проводе), а также на взлом (шкафы, кейсы)."
	duration_mod_names = list(ELECTRICITY_NEGATIVE_CHANCE_MOD, LOCKPICK_SPEED_MOD)
	quality_mod_names = list(LOCKPICK_POSITIVE_CHANCE_MOD)

/datum/skill/engineering/atmos
	id = "engineering.atmos"
	name = "Атмостехника"
	desc = "Влияет на работу с трубами (скорость использования RPD и силу откидывания из-за труб под давлением)."
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
