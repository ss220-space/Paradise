// Medical skills
/datum/skill/medical
	category = "Медицинские"
	category_color = "#57b8f0"

/datum/skill/medical/surgery
	id = "medical.surgery"
	name = "Хирургия"
	desc = "Влияет на скорось и шанс провала хирургических операций."
	duration_mod_signals = list(COMSIG_GET_SURGERY_DURATION_MOD)
	var/success_chance_mods = alist(
		SKILL_LEVEL_NONE = 0.5,
		SKILL_LEVEL_BEGINNER = 0.8,
		SKILL_LEVEL_BASIC = 1,
		SKILL_LEVEL_ADVANCED = 1.15,
		SKILL_LEVEL_PROFESSIONAL = 1.3,
		SKILL_LEVEL_EXPERT = 1.5,
		SKILL_LEVEL_LEGEND = 2,
		SKILL_LEVEL_UNAVAILABLE = 0.001,
	)

/datum/skill/medical/surgery/apply_to_mob(mob/owner)
	. = ..()
	RegisterSignal(owner, COMSIG_GET_SURGERY_SUCCESS_MOD, PROC_REF(get_success_chance_mod))

/datum/skill/medical/surgery/remove_from_mob(mob/owner)
	. = ..()
	UnregisterSignal(owner, COMSIG_GET_SURGERY_SUCCESS_MOD)

/datum/skill/medical/surgery/proc/get_success_chance_mod(mob/living/user, list/results)
	SIGNAL_HANDLER
	get_modifier(user, results, success_chance_mods)


/datum/skill/medical/heal
	id = "medical.heal"
	name = "Лечение"
	desc = "Влияет на скорось и величину лечения медикаментами."
	duration_mod_signals = list(COMSIG_GET_HEAL_DURATION_MOD)
	var/heal_mods = alist(
		SKILL_LEVEL_NONE = 0.75,
		SKILL_LEVEL_BEGINNER = 0.9,
		SKILL_LEVEL_BASIC = 1,
		SKILL_LEVEL_ADVANCED = 1.1,
		SKILL_LEVEL_PROFESSIONAL = 1.2,
		SKILL_LEVEL_EXPERT = 1.35,
		SKILL_LEVEL_LEGEND = 1.5,
		SKILL_LEVEL_UNAVAILABLE = 0.001,
	)

/datum/skill/medical/heal/apply_to_mob(mob/owner)
	. = ..()
	RegisterSignal(owner, COMSIG_GET_HEAL_AMOUNT_MOD, PROC_REF(get_heal_amount_mod))

/datum/skill/medical/heal/remove_from_mob(mob/owner)
	. = ..()
	UnregisterSignal(owner, COMSIG_GET_HEAL_AMOUNT_MOD)

/datum/skill/medical/heal/proc/get_heal_amount_mod(mob/living/user, list/results)
	SIGNAL_HANDLER
	get_modifier(user, results, heal_mods)

/datum/skill/medical/chemistry
	id = "medical.chemistry"
	name = "Химия"
	desc = "Влияет на работу с химией."
	var/chem_dispense_randomizatin_sizes = alist(
		SKILL_LEVEL_NONE = 0.25,
		SKILL_LEVEL_BEGINNER = 0.2,
		SKILL_LEVEL_BASIC = 0.1,
		SKILL_LEVEL_ADVANCED = 0.05,
		SKILL_LEVEL_PROFESSIONAL = 0.01,
		SKILL_LEVEL_EXPERT = 0,
		SKILL_LEVEL_LEGEND = 0,
		SKILL_LEVEL_UNAVAILABLE = 0.5,
	)

/datum/skill/medical/chemistry/apply_to_mob(mob/owner)
	. = ..()
	RegisterSignal(owner, COMSIG_GET_CHEMISTRY_DISPENSE_RAND_SIZE, PROC_REF(get_chemistry_dispense_rand_size))

/datum/skill/medical/chemistry/remove_from_mob(mob/owner)
	. = ..()
	UnregisterSignal(owner, COMSIG_GET_CHEMISTRY_DISPENSE_RAND_SIZE)

/datum/skill/medical/chemistry/proc/get_chemistry_dispense_rand_size(mob/living/user, list/results)
	SIGNAL_HANDLER
	get_modifier(user, results, chem_dispense_randomizatin_sizes)


/datum/skill/medical/genetic
	id = "medical.genetic"
	name = "Генетика"
	desc = "Влияет на работу с генетикой."
	duration_mod_signals = list(COMSIG_GET_IRRADIATION_DURATION_MOD)

/datum/skill/medical/virusology
	id = "medical.virusology"
	name = "Вирусология"
	desc = "Влияет на работу с вирусами."
