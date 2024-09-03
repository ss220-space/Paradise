/datum/species/human
	name = SPECIES_HUMAN
	name_plural = "Humans"
	icobase = 'icons/mob/human_races/r_human.dmi'
	deform = 'icons/mob/human_races/r_def_human.dmi'
	primitive_form = /datum/species/monkey
	language = LANGUAGE_SOL_COMMON
	inherent_traits = list(
		TRAIT_HAS_LIPS,
		TRAIT_HAS_REGENERATION,
	)
	skinned_type = /obj/item/stack/sheet/animalhide/human
	clothing_flags = HAS_UNDERWEAR | HAS_UNDERSHIRT | HAS_SOCKS
	bodyflags = HAS_SKIN_TONE | HAS_BODY_MARKINGS
	blood_species = "Human"
	can_be_pale = TRUE
	blurb = "Humanity originated in the Sol system, and over the last five centuries has spread \
	colonies across a wide swathe of space. They hold a wide range of forms and creeds.<br/><br/> \
	While the central Sol government maintains control of its far-flung people, powerful corporate \
	interests, rampant cyber and bio-augmentation and secretive factions make life on most human \
	worlds tumultous at best."

	meat_type = /obj/item/reagent_containers/food/snacks/meat/humanoid/human

	reagent_tag = PROCESS_ORG
	//Has standard darksight of 2.
