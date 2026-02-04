// General skills
/datum/skill/general
	category = "Общие"
	category_color = "#b88646"

/datum/skill/general/carring
	id = "general.carrying"
	name = "Переноска"
	desc = "Влияет на переноски вещей."
	duration_mod_signals = list(COMSIG_GET_PULL_SLOWDOWN_MODIFIERS, COMSIG_GET_GRAB_SPEED_MODIFIERS)

/datum/skill/general/mech_drive
	id = "general.mech_drive"
	name = "Управление мехами (подами)"
	desc = "Влияет на скорость передвижения мехов и подов. Также влияет на скорость разряда батареи."
	duration_mod_signals = list(COMSIG_GET_MECHA_DRIVING_SPEED_MOD, COMSIG_GET_MECHA_CLIMBING_SPEED_MOD)
	duration_mod_signals = list(COMSIG_GET_MECHA_CELL_USAGE_MOD)

/datum/skill/general/mod_use
	id = "general.mod_use"
	name = "ВКД"
	desc = "Влияет на скорость одевания МЭКов и РИГов."

/datum/skill/general/cooking
	id = "general.cooking"
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

/datum/skill/general/cooking/apply_to_mob(mob/owner)
	. = ..()
	RegisterSignal(owner, COMSIG_GET_COOKING_EXTRA_COUNT_CHANCE, PROC_REF(get_extra_count_chance))

/datum/skill/general/cooking/remove_from_mob(mob/owner)
	. = ..()
	UnregisterSignal(owner, COMSIG_GET_COOKING_EXTRA_COUNT_CHANCE)


/datum/skill/general/cooking/proc/get_extra_count_chance(mob/living/user, list/chances)
	SIGNAL_HANDLER
	GET_SKILL_LEVEL(user, src.type, level)
	if(!level)
		return
	var/chance = extra_count_chance[level]
	if(chance != null)
		chances.Add(chance)
