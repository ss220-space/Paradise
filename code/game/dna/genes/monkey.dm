/datum/dna/gene/monkey
	name = "Monkey"

/datum/dna/gene/monkey/New()
	..()
	block = GLOB.monkeyblock


/datum/dna/gene/monkey/can_activate(mob/living/mutant, flags)
	return ishuman(mutant) && !is_monkeybasic(mutant) && !HAS_TRAIT(mutant, TRAIT_NO_TRANSFORM)


/datum/dna/gene/monkey/can_deactivate(mob/living/mutant, flags)
	return ishuman(mutant) && is_monkeybasic(mutant) && !HAS_TRAIT(mutant, TRAIT_NO_TRANSFORM)


/datum/dna/gene/monkey/activate(mob/living/carbon/human/mutant, flags)
	. = ..()

	for(var/obj/item/item as anything in mutant.get_equipped_items(include_pockets = TRUE, include_hands = TRUE))
		mutant.drop_item_ground(item, force = TRUE)

	ADD_TRAIT(mutant, TRAIT_NO_TRANSFORM, TEMPORARY_TRANSFORMATION_TRAIT)
	mutant.invisibility = INVISIBILITY_ABSTRACT
	var/has_primitive_form = mutant.dna.species.primitive_form // cache this
	if(has_primitive_form)
		mutant.set_species(has_primitive_form, keep_missing_bodyparts = TRUE)

	new /obj/effect/temp_visual/monkeyify(mutant.loc)
	sleep(2.2 SECONDS)
	if(QDELETED(mutant))
		return

	REMOVE_TRAIT(mutant, TRAIT_NO_TRANSFORM, TEMPORARY_TRANSFORMATION_TRAIT)
	mutant.invisibility = initial(mutant.invisibility)

	if(!has_primitive_form) //If the pre-change mob in question has no primitive set, this is going to be messy.
		mutant.gib()
		return

	to_chat(mutant, "<B>You are now a [mutant.dna.species.name].</B>")


/datum/dna/gene/monkey/deactivate(mob/living/carbon/human/mutant, flags)
	. = ..()

	for(var/obj/item/item as anything in mutant.get_equipped_items(include_pockets = TRUE, include_hands = TRUE))
		if(item == mutant.w_uniform) // will be torn
			continue
		mutant.drop_item_ground(item, force = TRUE)

	ADD_TRAIT(mutant, TRAIT_NO_TRANSFORM, TEMPORARY_TRANSFORMATION_TRAIT)
	mutant.invisibility = INVISIBILITY_ABSTRACT
	var/has_greater_form = mutant.dna.species.greater_form //cache this
	if(has_greater_form)
		mutant.set_species(has_greater_form, keep_missing_bodyparts = TRUE)

	new /obj/effect/temp_visual/monkeyify/humanify(mutant.loc)
	sleep(2.2 SECONDS)
	if(QDELETED(mutant))
		return

	REMOVE_TRAIT(mutant, TRAIT_NO_TRANSFORM, TEMPORARY_TRANSFORMATION_TRAIT)
	mutant.invisibility = initial(mutant.invisibility)

	if(!has_greater_form) //If the pre-change mob in question has no primitive set, this is going to be messy.
		mutant.gib()
		return

	mutant.real_name = mutant.dna.real_name
	mutant.name = mutant.real_name

	to_chat(mutant, "<B>You are now a [mutant.dna.species.name].</B>")

