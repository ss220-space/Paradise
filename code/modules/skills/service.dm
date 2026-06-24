// Service skills
/datum/skill/service
	category = "Сервис"
	category_color = "#6ca729"

/datum/skill/service/drink_mixing
	id = "service.drink_mixing"
	name = "Смешивание напитков"
	desc = "Влияет на смешивание напитков."
	var/dispense_randomizatin_sizes = alist(
		SKILL_LEVEL_NONE = 0.25,
		SKILL_LEVEL_BEGINNER = 0.2,
		SKILL_LEVEL_BASIC = 0.1,
		SKILL_LEVEL_ADVANCED = 0.05,
		SKILL_LEVEL_PROFESSIONAL = 0.025,
		SKILL_LEVEL_EXPERT = 0.01,
		SKILL_LEVEL_LEGEND = 0,
		SKILL_LEVEL_UNAVAILABLE = 0.5,
	)

/datum/skill/service/drink_mixing/apply_to_mob(mob/owner)
	. = ..()
	RegisterSignal(owner, COMSIG_GET_DRINKS_DISPENSE_RAND_SIZE, PROC_REF(get_drink_dispense_rand_size))

/datum/skill/service/drink_mixing/remove_from_mob(mob/owner)
	. = ..()
	UnregisterSignal(owner, COMSIG_GET_DRINKS_DISPENSE_RAND_SIZE)

/datum/skill/service/drink_mixing/proc/get_drink_dispense_rand_size(mob/living/user, list/results)
	SIGNAL_HANDLER
	get_modifier(user, results, dispense_randomizatin_sizes)

/datum/skill/service/botany
	id = "service.botany"
	name = "Ботаника"
	desc = "Влияет на работу с растениями."
	duration_mod_signals = list()
	quality_mod_signals = list()

/datum/skill/service/cleaning
	id = "service.cleaning"
	name = "Уборка"
	desc = "Влияет на мытье полов и уборку."
	duration_mod_signals = list(COMSIG_GET_CLEANING_SPEED_MOD)
	quality_mod_signals = list(COMSIG_GET_CLEANING_DISTANCE_MOD)
