// Science skills (R&D)
/datum/skill/research
	category = "Научные"
	category_color = "#c68cfa"

/datum/skill/research/research
	id = "research.research"
	name = "Исследования"
	desc = "Влияет на шансы разбора для получения техов."
	duration_mod_names = list(RESEARCH_DURATION_MOD)
	skills_mods = alist(
		RESEARCH_SUCCESS_MOD = alist(
			SKILL_LEVEL_NONE = 0.1,
			SKILL_LEVEL_BEGINNER = 0.25,
			SKILL_LEVEL_BASIC = 1,
			SKILL_LEVEL_ADVANCED = 1,
			SKILL_LEVEL_PROFESSIONAL = 1,
			SKILL_LEVEL_EXPERT = 1,
			SKILL_LEVEL_LEGEND = 1,
			SKILL_LEVEL_UNAVAILABLE = 0.01,
		),
	)

/datum/skill/research/protolathe
	id = "research.protolathe"
	name = "Обращение с протолатом"
	desc = "Влияет на скорость и шанс успеха при работе с протолатом."
	duration_mod_names = list(PROTOLATHE_DURATION_MOD)
	skills_mods = alist(
		PROTOLATHE_RAND_BUILD_PROB = alist(
			SKILL_LEVEL_NONE = 0.5,
			SKILL_LEVEL_BEGINNER = 0.05,
			SKILL_LEVEL_BASIC = 0,
			SKILL_LEVEL_ADVANCED = 0,
			SKILL_LEVEL_PROFESSIONAL = 0,
			SKILL_LEVEL_EXPERT = 0,
			SKILL_LEVEL_LEGEND = 0,
			SKILL_LEVEL_UNAVAILABLE = 0.5,
		),
	)

/datum/skill/research/robotics
	id = "research.robotics"
	name = "Робототехника"
	desc = "Влияет на скорость постройки мехов и печати их запчастей, а так же на работу с проводами роботов и киборгов."
	duration_mod_names = list(MECH_CONSTRUCT_DURATION_MOD, PROTOLATHE_RESOURCE_MOD)
	skills_mods = alist(
		MECH_CONSTRUCT_RAND_BUILD_PROB = alist(
			SKILL_LEVEL_NONE = 0.5,
			SKILL_LEVEL_BEGINNER = 0.05,
			SKILL_LEVEL_BASIC = 0,
			SKILL_LEVEL_ADVANCED = 0,
			SKILL_LEVEL_PROFESSIONAL = 0,
			SKILL_LEVEL_EXPERT = 0,
			SKILL_LEVEL_LEGEND = 0,
			SKILL_LEVEL_UNAVAILABLE = 0.5,
		),
	)

/datum/skill/research/xenobiology
	id = "research.xenobiology"
	name = "Ксенобиология"
	desc = "Влияет на шанс двойного лута с ядра слаймов."
	skills_mods = alist(
		XENOBIO_DOUBLE_LOOT_MOD = alist(
			SKILL_LEVEL_NONE = 0.05,
			SKILL_LEVEL_BEGINNER = 0.1,
			SKILL_LEVEL_BASIC = 0.25,
			SKILL_LEVEL_ADVANCED = 0.5,
			SKILL_LEVEL_PROFESSIONAL = 0.5,
			SKILL_LEVEL_EXPERT = 0.75,
			SKILL_LEVEL_LEGEND = 1,
			SKILL_LEVEL_UNAVAILABLE = 0.001,
		),
	)
