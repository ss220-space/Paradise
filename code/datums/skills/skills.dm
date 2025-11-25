/*
 * Basic skills datum
 */
/datum/skill_level
	var/level
	var/name
	var/desc
	/// Action duration modifier
	var/duration_mod
	/// Action modifier for make quality
	var/quality_mod

/datum/skill_level/unavailable
	level = SKILL_LEVEL_UNAVAILABLE
	name = "недоступно"
	desc = "Персонаж не может выполнять данные действия, навык запрещает взаимодействия с чем то."
	duration_mod = 1000
	quality_mod = 0.001

/datum/skill_level/none
	level = SKILL_LEVEL_NONE
	name = "нет навыка"
	desc = "Персонаж не умеет выполнять данное действие"
	duration_mod = 2
	quality_mod = 0.5

/datum/skill_level/beginner
	level = SKILL_LEVEL_BEGINNER
	name = "начальный навык"
	desc = "Персонаж только учится выполнять определенные действия"
	duration_mod = 1.5
	quality_mod = 0.75

/datum/skill_level/basic
	level = SKILL_LEVEL_BASIC
	name = "базовый навык"
	desc = "Персонаж базово умеет выполнять определенное действие"
	duration_mod = 1
	quality_mod = 1

/datum/skill_level/advanced
	level = SKILL_LEVEL_ADVANCED
	name = "продвинутый навык"
	desc = "Персонаж хорошо умеет выполнять определенное действие"
	duration_mod = 0.75
	quality_mod = 1.25

/datum/skill_level/professional
	level = SKILL_LEVEL_PROFESSIONAL
	name = "профессиональный навык"
	desc = "Персонаж очень опытен в данных действиях и данные действия для него уже рутина"
	duration_mod = 0.5
	quality_mod = 1.5

/datum/skill_level/expert
	level = SKILL_LEVEL_EXPERT
	name = "экспертный навык"
	desc = "Персонаж является экспертом в данной сфере"
	duration_mod = 0.25
	quality_mod = 2

/datum/skill_level/legend
	level = SKILL_LEVEL_LEGEND
	name = "легендарный навык"
	desc = "Одним словом легенда"
	duration_mod = 0.1
	quality_mod = 3
