// Combat skills (Security)
/datum/skill/combat
	category = "Боевые"
	category_color = "#dd3535"


// MARK: Accuracy
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
	UnregisterSignal(owner, list(COMSIG_GET_ACCURACY_MOD, COMSIG_GET_SPREAD_MOD))

/datum/skill/combat/accuracy/proc/get_accuracy_modifier(mob/living/user, list/results)
	SIGNAL_HANDLER
	get_modifier(user, results, accuracy_modifiers)

/datum/skill/combat/accuracy/proc/get_spread_modifier(mob/living/user, list/results)
	SIGNAL_HANDLER
	get_modifier(user, results, spread_modifiers)


// MARK: Guns
/datum/skill/combat/guns
	id = "combat.guns"
	name = "Владение стрелковым оружием"
	desc = "Влияет на скорость перезарядки."
	duration_mod_signals = list(COMSIG_GET_GUN_RELOAD_MOD, COMSIG_GET_MAGAZINE_RELOAD_MOD)
	var/missfire_chances = alist(
		SKILL_LEVEL_NONE = 4,
		SKILL_LEVEL_BEGINNER = 2,
		SKILL_LEVEL_BASIC = 1,
		SKILL_LEVEL_ADVANCED = 0,
		SKILL_LEVEL_PROFESSIONAL = 0,
		SKILL_LEVEL_EXPERT = 0,
		SKILL_LEVEL_LEGEND = 0,
		SKILL_LEVEL_UNAVAILABLE = 50,
	)
	var/recoil_modifiers = alist(
		SKILL_LEVEL_NONE = 2,
		SKILL_LEVEL_BEGINNER = 1.5,
		SKILL_LEVEL_BASIC = 1,
		SKILL_LEVEL_ADVANCED = 0.75,
		SKILL_LEVEL_PROFESSIONAL = 0.5,
		SKILL_LEVEL_EXPERT = 0.25,
		SKILL_LEVEL_LEGEND = 0.1,
		SKILL_LEVEL_UNAVAILABLE = 5,
	)

/datum/skill/combat/guns/apply_to_mob(mob/owner)
	. = ..()
	RegisterSignal(owner, COMSIG_GET_MISSFIRE_CHANCE, PROC_REF(get_missfire_chance))
	RegisterSignal(owner, COMSIG_GET_RECOIL_MOD, PROC_REF(get_recoil_mod))

/datum/skill/combat/guns/remove_from_mob(mob/owner)
	. = ..()
	UnregisterSignal(owner, list(COMSIG_GET_MISSFIRE_CHANCE, COMSIG_GET_RECOIL_MOD))

/datum/skill/combat/guns/proc/get_missfire_chance(mob/living/user, list/results)
	SIGNAL_HANDLER
	get_modifier(user, results, missfire_chances)

/datum/skill/combat/guns/proc/get_recoil_mod(mob/living/user, list/results)
	SIGNAL_HANDLER
	get_modifier(user, results, recoil_modifiers)


// MARK: Melee
/datum/skill/combat/melee
	id = "combat.melee"
	name = "Владение оружием ближнего боя"
	desc = "Влияет на урон и скорость работы с оружием ближнего боя."
	var/damage_mod = alist(
		SKILL_LEVEL_NONE = 0.70,
		SKILL_LEVEL_BEGINNER = 0.80,
		SKILL_LEVEL_BASIC = 1.0,
		SKILL_LEVEL_ADVANCED = 1.10,
		SKILL_LEVEL_PROFESSIONAL = 1.20,
		SKILL_LEVEL_EXPERT = 1.35,
		SKILL_LEVEL_LEGEND = 1.50,
		SKILL_LEVEL_UNAVAILABLE = 0.01,
	)

/datum/skill/combat/melee/apply_to_mob(mob/owner)
	. = ..()
	RegisterSignal(owner, COMSIG_GET_MELEE_DAMAGE_MOD, PROC_REF(get_melee_damage_mod))

/datum/skill/combat/melee/remove_from_mob(mob/owner)
	. = ..()
	UnregisterSignal(owner, COMSIG_GET_MELEE_DAMAGE_MOD)

/datum/skill/combat/melee/proc/get_melee_damage_mod(mob/living/user, list/results)
	SIGNAL_HANDLER
	get_modifier(user, results, damage_mod)


// MARK: Fists
/datum/skill/combat/fists
	id = "combat.fists"
	name = "Безоружный бой"
	desc = "Влияет на урон кулаками, шансы обезоруживания и скорость грабов."


// MARK: Shields
/datum/skill/combat/shields
	id = "combat.shields"
	name = "Владение щитами (парирование)"
	desc = "Влияет на шансы блока щитами и парирование."
