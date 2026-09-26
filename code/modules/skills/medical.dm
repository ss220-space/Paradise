// Medical skills
/datum/skill/medical
	category = "Медицинские"
	category_color = "#57b8f0"

/datum/skill/medical/surgery
	id = "medical.surgery"
	name = "Хирургия"
	desc = "Влияет на скорось и шанс провала хирургических операций."
	duration_mod_names = list(SURGERY_DURATION_MOD)
	skills_mods = alist(
		SURGERY_SUCCESS_MOD = alist(
			SKILL_LEVEL_NONE = 0.5,
			SKILL_LEVEL_BEGINNER = 0.8,
			SKILL_LEVEL_BASIC = 1,
			SKILL_LEVEL_ADVANCED = 1.15,
			SKILL_LEVEL_PROFESSIONAL = 1.3,
			SKILL_LEVEL_EXPERT = 1.5,
			SKILL_LEVEL_LEGEND = 2,
			SKILL_LEVEL_UNAVAILABLE = 0.001,
		),
	)

/datum/skill/medical/heal
	id = "medical.heal"
	name = "Лечение"
	desc = "Влияет на скорось и величину лечения медикаментами."
	duration_mod_names = list(HEAL_DURATION_MOD)
	skills_mods = alist(
		HEAL_AMOUNT_MOD = alist(
			SKILL_LEVEL_NONE = 0.75,
			SKILL_LEVEL_BEGINNER = 0.9,
			SKILL_LEVEL_BASIC = 1,
			SKILL_LEVEL_ADVANCED = 1.1,
			SKILL_LEVEL_PROFESSIONAL = 1.2,
			SKILL_LEVEL_EXPERT = 1.35,
			SKILL_LEVEL_LEGEND = 1.5,
			SKILL_LEVEL_UNAVAILABLE = 0.001,
		),
	)

/datum/skill/medical/chemistry
	id = "medical.chemistry"
	name = "Химия"
	desc = "Влияет на работу с химией."
	skills_mods = alist(
		CHEMISTRY_DISPENSE_RAND_SIZE = alist(
			SKILL_LEVEL_NONE = 0.75,
			SKILL_LEVEL_BEGINNER = 0.5,
			SKILL_LEVEL_BASIC = 0.2,
			SKILL_LEVEL_ADVANCED = 0,
			SKILL_LEVEL_PROFESSIONAL = 0,
			SKILL_LEVEL_EXPERT = 0,
			SKILL_LEVEL_LEGEND = 0,
			SKILL_LEVEL_UNAVAILABLE = 0.5,
		),
		CHEMISTRY_DISPENSE_RAND_REAGENT_PROB = alist(
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

/datum/skill/medical/genetic
	id = "medical.genetic"
	name = "Генетика"
	desc = "Влияет на работу с генетикой."
	duration_mod_names = list(IRRADIATION_DURATION_MOD)

/datum/skill/medical/virusology
	id = "medical.virusology"
	name = "Вирусология"
	desc = "Влияет на работу с вирусами."
