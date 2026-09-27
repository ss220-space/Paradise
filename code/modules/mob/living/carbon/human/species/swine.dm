#define SWINE_MELEE_FORCE_MOD 0.15

/datum/species/swine
	name = SPECIES_SWINE
	name_plural = "Trottines"
	icobase = 'icons/mob/human_races/r_swine.dmi'
	deform = 'icons/mob/human_races/r_swine.dmi'

	blurb = "Human-pig hybrids, Trottines were initially created for organ-harvesting \
	operations by a long-gone corporation, before bioprinting became such a wide-spread technology. \
	They found success in their attempt to merge human DNA with that of a pig - to make easier transplantable \
	organs such as hearts and lungs - creating a more humanlike being than anticipated."

	inherent_traits = list(
		TRAIT_HAS_LIPS,
	)
	clothing_flags = HAS_UNDERWEAR | HAS_UNDERSHIRT | HAS_SOCKS
	bodyflags = HAS_HEAD_ACCESSORY | HAS_HAIR | HAS_SKIN_TONE
	fit_profile = /datum/species_fit/swine
	reagent_tag = ORGANIC

	blood_species = "Trottine"
	flesh_color = "#ffbeb2"
	default_hair = "Bald"
	default_headacc = "Round Ears"

	brute_mod = 0.8
	burn_mod = 0.8
	tox_mod = 0.7
	siemens_coeff = 0.7
	hunger_drain_mod = 3
	speed_mod = 0.5
	blood_volume_mod = 1.43
	equipment_slowdown_mod = 0.5
	climb_speed_mod = 2.5

	cold_level_1 = 240
	cold_level_2 = 180
	cold_level_3 = 100

	heat_level_1 = 420
	heat_level_2 = 480
	heat_level_3 = 1100

	warning_low_pressure = WARNING_LOW_PRESSURE * 0.8
	hazard_low_pressure = HAZARD_LOW_PRESSURE * 0.8
	warning_high_pressure = WARNING_HIGH_PRESSURE * 1.2
	hazard_high_pressure = HAZARD_HIGH_PRESSURE * 1.2

	meat_type = /obj/item/reagent_containers/food/snacks/meat/humanoid/swine
	special_diet = MATERIAL_CLASS_CLOTH | MATERIAL_CLASS_TECH | MATERIAL_CLASS_SOAP

	allowed_consumed_mobs = list(
		/mob/living/simple_animal/mouse, /mob/living/simple_animal/lizard, /mob/living/simple_animal/chick, /mob/living/simple_animal/chicken, \
		/mob/living/simple_animal/crab, /mob/living/simple_animal/butterfly, /mob/living/simple_animal/parrot, /mob/living/simple_animal/tribble
	)

	scream_verb = "визж%(ит,ат)%"

	suicide_messages = list(
		"пытается откусить себе язык!",
		"вгоняет себе клыки в горло!",
		"сворачивает себе шею!",
		"задерживает дыхание!")

	disliked_food = NONE
	liked_food = FRIED | JUNKFOOD | SUGAR | GROSS | RAW | VEGETABLES | GRAIN

	age_sheet = list(
		SPECIES_AGE_MIN = 18,
		SPECIES_AGE_MAX = 80,
		JOB_MIN_AGE_HIGH_ED = 25,
		JOB_MIN_AGE_COMMAND = 30,
	)

/datum/species/swine/on_species_gain(mob/living/carbon/human/target)
	. = ..()
	RegisterSignal(target, COMSIG_GET_MELEE_DAMAGE_DELTAS, PROC_REF(add_melee_force))

/datum/species/swine/on_species_loss(mob/living/carbon/human/human)
	. = ..()
	UnregisterSignal(human, COMSIG_GET_MELEE_DAMAGE_DELTAS)

/datum/species/swine/proc/add_melee_force(mob/living/user, list/deltas, obj/item/weapon)
	SIGNAL_HANDLER

	if(!weapon || weapon.damtype != BRUTE)
		return
	deltas.Add(weapon.force * SWINE_MELEE_FORCE_MOD)

#undef SWINE_MELEE_FORCE_MOD
