// Combat skills (Security)
/datum/skill/combat
	category = "Боевые"
	category_color = "#dd3535"

/datum/skill/combat/accuracy
	id = "combat.accuracy"
	name = "Точность стрельбы"
	desc = "Влияет на меткость стрельбы."
	var/accuracy_modifiers = alist(
		SKILL_LEVEL_NONE = 0.9,
		SKILL_LEVEL_BEGINNER = 1,
		SKILL_LEVEL_BASIC = 1.1,
		SKILL_LEVEL_ADVANCED = 1.2,
		SKILL_LEVEL_PROFESSIONAL = 1.3,
		SKILL_LEVEL_EXPERT = 1.4,
		SKILL_LEVEL_LEGEND = 1.5,
		SKILL_LEVEL_UNAVAILABLE = 0.1,
	)
	var/spread_modifiers = alist(
		SKILL_LEVEL_NONE = 2,
		SKILL_LEVEL_BEGINNER = 1.5,
		SKILL_LEVEL_BASIC = 1,
		SKILL_LEVEL_ADVANCED = 0.75,
		SKILL_LEVEL_PROFESSIONAL = 0.5,
		SKILL_LEVEL_EXPERT = 0.25,
		SKILL_LEVEL_LEGEND = 0.1,
		SKILL_LEVEL_UNAVAILABLE = 5,
	)

/datum/skill/combat/accuracy/apply_to_mob(mob/owner)
	. = ..()
	RegisterSignal(owner, COMSIG_GET_ACCURACY_MOD, PROC_REF(get_accuracy_modifier))
	RegisterSignal(owner, COMSIG_GET_SPREAD_MOD, PROC_REF(get_spread_modifier))

/datum/skill/combat/accuracy/remove_from_mob(mob/owner)
	. = ..()
	UnregisterSignal(owner, COMSIG_GET_ACCURACY_MOD, COMSIG_GET_SPREAD_MOD)

/datum/skill/combat/accuracy/proc/get_accuracy_modifier(mob/living/user, list/results)
	SIGNAL_HANDLER
	get_modifier(user, results, accuracy_modifiers)

/datum/skill/combat/accuracy/proc/get_spread_modifier(mob/living/user, list/results)
	SIGNAL_HANDLER
	get_modifier(user, results, spread_modifiers)

/datum/skill/combat/guns
	id = "combat.guns"
	name = "Владение стрелковым оружием"
	desc = "Влияет на скорость перезарядки."

/datum/skill/combat/melee
	id = "combat.melee"
	name = "Владение оружием ближнего боя"
	desc = "Влияет на урон и скорость работы с оружием ближнего боя."

/datum/skill/combat/fists
	id = "combat.fists"
	name = "Безоружный бой"
	desc = "Влияет на урон кулаками, шансы обезоруживания и скорость грабов."

/datum/skill/combat/shields
	id = "combat.shields"
	name = "Владение щитами (парирование)"
	desc = "Влияет на шансы блока щитами и парирование."
