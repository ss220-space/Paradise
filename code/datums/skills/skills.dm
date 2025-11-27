//MARK: Skill levels
/*
 * Basic skill level datum
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


//MARK: Skills
/*
 * Basic skill datum
 */
/datum/skill
	// type defined variables
	var/id
	var/category
	var/name
	var/desc
	var/list/duration_mod_signals = list()
	var/list/quality_mod_signals = list()
	// runtime variables
	var/mob/owner = null
	var/datum/skill_level/level

/datum/skill/proc/apply_to_mob(mob/owner)
	src.owner = owner
	for(var/signal as anything in duration_mod_signals)
		RegisterSignal(owner, signal, PROC_REF(get_duration_mod_signal))
	for(var/signal as anything in quality_mod_signals)
		RegisterSignal(owner, signal, PROC_REF(get_quality_mod_signal))

/datum/skill/proc/get_duration_mod_signal(mob/living/user, list/modifiers)
	SIGNAL_HANDLER
	if(!level)
		return
	modifiers.Add(level.duration_mod)

/datum/skill/proc/get_quality_mod_signal(mob/living/user, list/modifiers)
	SIGNAL_HANDLER
	if(!level)
		return
	modifiers.Add(level.quality_mod)

/datum/skill/proc/remove_from_mob()
	UnregisterSignal(owner, duration_mod_signals)
	UnregisterSignal(owner, quality_mod_signals)
	src.owner = null


//TODO make correct descriptions
//MARK: Engineering
/datum/skill/engineering
	category = "Инженерные"

/datum/skill/engineering/building
	id = "engineering.building"
	name = "Строительство"
	desc = "Влияет на скорость строительства."
	duration_mod_signals = list(COMSIG_GET_BUILDING_SPEED_MOD)

/datum/skill/engineering/construction
	id = "engineering.construction"
	name = "Конструирование"
	desc = "Влияет на скорость конструирования машинерии."
	duration_mod_signals = list(COMSIG_GET_CONSTRUCTING_SPEED_MOD)


//MARK: Cargo
/datum/skill/cargo
	category = "Карго"

/datum/skill/cargo/carring
	id = "cargo.carrying"
	name = "Переноска"
	desc = "Влияет на переноски вещей."
	duration_mod_signals = list(COMSIG_GET_PULL_SLOWDOWN_MODIFIERS, COMSIG_GET_GRAB_SPEED_MODIFIERS)


//MARK: Service
/datum/skill/service
	category = "Сервис"

/datum/skill/service/cooking
	id = "service.cooking"
	name = "Готовка"
	desc = "Влияет на готовку."
	duration_mod_signals = list()

/datum/skill/service/butchering
	id = "service.butchering"
	name = "Разделывание туш"
	desc = "Влияет на мастерство разделывания туш."
	duration_mod_signals = list()

/datum/skill/service/drink_mixing
	id = "service.drink_mixing"
	name = "Смешивание напитков"
	desc = "Влияет на смешивание напитков."
	duration_mod_signals = list()
	quality_mod_signals = list()
