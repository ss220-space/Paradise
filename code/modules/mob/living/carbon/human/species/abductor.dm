/datum/species/abductor
	name = SPECIES_ABDUCTOR
	name_plural = "Abductors"
	a = "an"
	icobase = 'icons/mob/human_races/r_abductor.dmi'
	deform = 'icons/mob/human_races/r_abductor.dmi'
	language = LANGUAGE_HIVE_ABDUCTOR
	default_language = LANGUAGE_HIVE_ABDUCTOR
	eyes = "blank_eyes"
	has_organ = list(
		INTERNAL_ORGAN_HEART = /obj/item/organ/internal/heart,
		INTERNAL_ORGAN_LIVER = /obj/item/organ/internal/liver,
		INTERNAL_ORGAN_KIDNEYS = /obj/item/organ/internal/kidneys,
		INTERNAL_ORGAN_BRAIN = /obj/item/organ/internal/brain/abductor,
		INTERNAL_ORGAN_EYES = /obj/item/organ/internal/eyes/abductor, //3 darksight.
		INTERNAL_ORGAN_EARS = /obj/item/organ/internal/ears,
	)

	meat_type = /obj/item/reagent_containers/food/snacks/meat/humanoid/grey

	inherent_traits = list(
		TRAIT_NO_BLOOD,
		TRAIT_NO_BREATH,
		TRAIT_NO_GUNS,
		TRAIT_VIRUSIMMUNE,
		TRAIT_NO_SPECIES_EXAMINE,
		TRAIT_NO_HUNGER,
		TRAIT_MASTER_SURGEON,
	)
	dies_at_threshold = TRUE

	taste_sensitivity = TASTE_SENSITIVITY_NO_TASTE

	clothing_flags = HAS_UNDERWEAR | HAS_UNDERSHIRT | HAS_SOCKS
	reagent_tag = PROCESS_ORG
	blood_color = "#FF5AFF"
	female_scream_sound = list('sound/goonstation/voice/male_scream.ogg')
	female_cough_sounds = list('sound/effects/mob_effects/m_cougha.ogg','sound/effects/mob_effects/m_coughb.ogg', 'sound/effects/mob_effects/m_coughc.ogg')
	female_sneeze_sound = list('sound/effects/mob_effects/sneeze.ogg') //Abductors always scream like guys
	var/team = 1
	var/scientist = FALSE // vars to not pollute spieces list with castes

	toxic_food = NONE
	disliked_food = NONE

/datum/species/abductor/can_understand(mob/other) //Abductors can understand everyone, but they can only speak over their mindlink to another team-member
	return TRUE

/datum/species/abductor/on_species_gain(mob/living/carbon/human/H)
	. = ..()
	H.gender = NEUTER
	LAZYREINITLIST(H.languages) //Under no condition should you be able to speak any language
	H.add_language(LANGUAGE_HIVE_ABDUCTOR) //other than over the abductor's own mindlink
	H.add_language(LANGUAGE_GREY) // still grey enouhg to speak in psi link
	var/datum/atom_hud/abductor_hud = GLOB.huds[DATA_HUD_ABDUCTOR]
	abductor_hud.add_hud_to(H)

/datum/species/abductor/on_species_loss(mob/living/carbon/human/H)
	. = ..()
	var/datum/atom_hud/abductor_hud = GLOB.huds[DATA_HUD_ABDUCTOR]
	abductor_hud.remove_hud_from(H)
