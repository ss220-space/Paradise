// Science skills (R&D)
/datum/skill/research
	category = "Научные"
	category_color = "#c68cfa"

/datum/skill/research/research
	id = "research.research"
	name = "Исследования"
	desc = "Влияет на времени печати и разбора, потребление ресурсов, шансы напечатать больше, шансы неудачного разбора."
	duration_mod_names = list(RESEARCH_DURATION_MOD, PROTOLATHE_RESOURCE_MOD)
	skills_mods = alist(
		RESEARCH_SUCCESS_DECONSTRUCT_MOD = alist(
			SKILL_LEVEL_NONE = 0.25,
			SKILL_LEVEL_BEGINNER = 0.5,
			SKILL_LEVEL_BASIC = 1,
			SKILL_LEVEL_ADVANCED = 1,
			SKILL_LEVEL_PROFESSIONAL = 1,
			SKILL_LEVEL_EXPERT = 1,
			SKILL_LEVEL_LEGEND = 1,
			SKILL_LEVEL_UNAVAILABLE = 0,
		),
		RESEARCH_ADDITIONAL_CHANCE = alist(
			SKILL_LEVEL_NONE = 5,
			SKILL_LEVEL_BEGINNER = 10,
			SKILL_LEVEL_BASIC = 15,
			SKILL_LEVEL_ADVANCED = 30,
			SKILL_LEVEL_PROFESSIONAL = 50,
			SKILL_LEVEL_EXPERT = 75,
			SKILL_LEVEL_LEGEND = 100,
			SKILL_LEVEL_UNAVAILABLE = 0,
		),
		RESEARCH_ADDITIONAL_PRINT = alist(
			SKILL_LEVEL_NONE = 1,
			SKILL_LEVEL_BEGINNER = 1,
			SKILL_LEVEL_BASIC = 2,
			SKILL_LEVEL_ADVANCED = 2,
			SKILL_LEVEL_PROFESSIONAL = 3,
			SKILL_LEVEL_EXPERT = 4,
			SKILL_LEVEL_LEGEND = 5,
			SKILL_LEVEL_UNAVAILABLE = 0,
		),
	)

/datum/skill/research/mech_construct
	id = "research.mech_construct"
	name = "Конструирование мехов"
	desc = "Влияет на скорость постройки, скорость печати запчастей, стоимость печати запчастей."
	duration_mod_names = list(MECH_CONSTRUCT_DURATION_MOD, MECH_CONSTRUCT_RESOURCE_MOD)

/datum/skill/research/xenobiology
	id = "research.xenobiology"
	name = "Ксенобиология"
	desc = "Влияет на скорость переработки слаймов в гриндере, шанс получить больше с ядра, количество дополнительного лута с ядра."
	duration_mod_names = list(XENOBIO_DURATION_MOD)
	skills_mods = alist(
		XENOBIO_LOOT_CHANCE = alist(
			SKILL_LEVEL_NONE = 5,
			SKILL_LEVEL_BEGINNER = 10,
			SKILL_LEVEL_BASIC = 15,
			SKILL_LEVEL_ADVANCED = 30,
			SKILL_LEVEL_PROFESSIONAL = 50,
			SKILL_LEVEL_EXPERT = 75,
			SKILL_LEVEL_LEGEND = 100,
			SKILL_LEVEL_UNAVAILABLE = 0,
		),
		XENOBIO_ADDITIONAL_LOOT = alist(
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
