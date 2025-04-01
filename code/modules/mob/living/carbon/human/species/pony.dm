/datum/species/pony
	name = "Pony"
	name_plural = "Ponies"
	a = "a"
	icobase = 'icons/mob/human_races/r_pony.dmi'
	deform = 'icons/mob/human_races/r_pony.dmi'
	language = LANGUAGE_SOL_COMMON

	inherent_traits = list(
		TRAIT_NO_BLOOD,
		TRAIT_HAS_LIPS,
		TRAIT_HAS_REGENERATION,
		TRAIT_NO_BREATH,
		TRAIT_VIRUSIMMUNE,
		TRAIT_NO_SPECIES_EXAMINE,
		TRAIT_NO_HUNGER,
		TRAIT_MASTER_SURGEON,
	)

	taste_sensitivity = TASTE_SENSITIVITY_NO_TASTE

	clothing_flags = HAS_UNDERWEAR | HAS_UNDERSHIRT | HAS_SOCKS
	reagent_tag = PROCESS_ORG
	blood_color = "#FF5AFF"

	toxic_food = NONE
	disliked_food = NONE

/datum/species/pony/can_understand(mob/other)
	return TRUE

/datum/species/pony/get_vision_organ(mob/living/carbon/human/user)
	return NO_VISION_ORGAN
