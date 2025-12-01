// Service skills
/datum/skill/service
	category = "Сервис"

/datum/skill/service/cooking
	id = "service.cooking"
	name = "Готовка"
	desc = "Влияет на готовку."
	duration_mod_signals = list(COMSIG_GET_COOKING_SPEED_MOD, COMSIG_GET_BUTCHERING_SPEED_MOD)
	// chance to create extra dish for cooking
	var/extra_count_chance = list(
		SKILL_LEVEL_NONE = 0,
		SKILL_LEVEL_BEGINNER = 5,
		SKILL_LEVEL_BASIC = 10,
		SKILL_LEVEL_ADVANCED = 25,
		SKILL_LEVEL_PROFESSIONAL = 50,
		SKILL_LEVEL_EXPERT = 75,
		SKILL_LEVEL_LEGEND = 100,
		SKILL_LEVEL_UNAVAILABLE = 0.001,
	)

/datum/skill/service/cooking/apply_to_mob(mob/owner)
	. = ..()
	RegisterSignal(owner, COMSIG_GET_COOKING_EXTRA_COUNT_CHANCE, PROC_REF(get_extra_count_chance))

/datum/skill/service/cooking/remove_from_mob(mob/owner)
	. = ..()
	UnregisterSignal(owner, COMSIG_GET_COOKING_EXTRA_COUNT_CHANCE)


/datum/skill/service/cooking/proc/get_extra_count_chance(mob/living/user, list/chances)
	SIGNAL_HANDLER
	GET_SKILL_LEVEL(user, src.type, level)
	if(!level)
		return
	var/chance = extra_count_chance[level]
	if(chance != null)
		chances.Add(chance)

/datum/skill/service/drink_mixing
	id = "service.drink_mixing"
	name = "Смешивание напитков"
	desc = "Влияет на смешивание напитков."
	duration_mod_signals = list()
	quality_mod_signals = list()

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
	duration_mod_signals = list()
	quality_mod_signals = list()
