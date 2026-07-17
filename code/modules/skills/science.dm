// Science skills (R&D)
/datum/skill/research
	category = "Научные"
	category_color = "#c68cfa"

/datum/skill/research/research
	id = "research.research"
	name = "Исследования"
	desc = "Влияет на шансы разбора для получения техов."
	duration_mod_signals = list(COMSIG_GET_RESEARCH_DURATION_MOD)
	// success deconstruct chance modifier ([0-1])
	var/success_chance_mod = alist(
		SKILL_LEVEL_NONE = 0.1,
		SKILL_LEVEL_BEGINNER = 0.25,
		SKILL_LEVEL_BASIC = 0.5,
		SKILL_LEVEL_ADVANCED = 0.7,
		SKILL_LEVEL_PROFESSIONAL = 0.8,
		SKILL_LEVEL_EXPERT = 0.9,
		SKILL_LEVEL_LEGEND = 1,
		SKILL_LEVEL_UNAVAILABLE = 0.01,
	)

/datum/skill/research/research/apply_to_mob(mob/owner)
	. = ..()
	RegisterSignal(owner, COMSIG_GET_RESEARCH_SUCCESS_MOD, PROC_REF(get_success_chance_mod))

/datum/skill/research/research/remove_from_mob(mob/owner)
	. = ..()
	UnregisterSignal(owner, COMSIG_GET_RESEARCH_SUCCESS_MOD)

/datum/skill/research/research/proc/get_success_chance_mod(mob/living/user, list/chances)
	SIGNAL_HANDLER
	get_modifier(user, chances, success_chance_mod)

/datum/skill/research/protolathe
	id = "research.protolathe"
	name = "Обращение с протолатом"
	desc = "Влияет на скорость и шанс успеха при работе с протолатом."
	duration_mod_signals = list(COMSIG_GET_PROTOLATHE_DURATION_MOD)

/datum/skill/research/mech_construct
	id = "research.mech_construct"
	name = "Конструирование мехов"
	desc = "Влияет на скорость постройки мехов и печати их запчастей."
	duration_mod_signals = list(COMSIG_GET_MECH_CONSTRUCT_DURATION_MOD, COMSIG_GET_PROTOLATHE_RESOURCE_MOD)

/datum/skill/research/xenobiology
	id = "research.xenobiology"
	name = "Ксенобиология"
	desc = "Влияет на шанс двойного лута с ядра слаймов."
	// success deconstruct chance modifier ([0-1])
	var/double_loot_mod = alist(
		SKILL_LEVEL_NONE = 0.05,
		SKILL_LEVEL_BEGINNER = 0.1,
		SKILL_LEVEL_BASIC = 0.25,
		SKILL_LEVEL_ADVANCED = 0.5,
		SKILL_LEVEL_PROFESSIONAL = 0.5,
		SKILL_LEVEL_EXPERT = 0.75,
		SKILL_LEVEL_LEGEND = 1,
		SKILL_LEVEL_UNAVAILABLE = 0.001,
	)

/datum/skill/research/xenobiology/apply_to_mob(mob/owner)
	. = ..()
	RegisterSignal(owner, COMSIG_GET_XENOBIO_DOUBLE_LOOT_MOD, PROC_REF(get_double_loot_mod))

/datum/skill/research/xenobiology/remove_from_mob(mob/owner)
	. = ..()
	UnregisterSignal(owner, COMSIG_GET_XENOBIO_DOUBLE_LOOT_MOD)

/datum/skill/research/xenobiology/proc/get_double_loot_mod(mob/living/user, list/chances)
	SIGNAL_HANDLER
	get_modifier(user, chances, double_loot_mod)
