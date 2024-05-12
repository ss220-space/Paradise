/obj/item/organ/internal/body_egg
	name = "body egg"
	desc = "All slimy and yuck."
	icon_state = "innards"
	origin_tech = "biotech=5"
	parent_organ_zone = BODY_ZONE_CHEST
	slot = INTERNAL_ORGAN_PARASITE_EGG

/obj/item/organ/internal/body_egg/on_find(mob/living/finder)
	..()
	to_chat(finder, span_warning("You found an unknown alien organism in [owner]'s [parent_organ_zone]!"))


/obj/item/organ/internal/body_egg/insert(mob/living/carbon/M, special = ORGAN_MANIPULATION_DEFAULT)
	. = ..()
	ADD_TRAIT(owner, TRAIT_XENO_HOST, GENERIC_TRAIT)
	START_PROCESSING(SSobj, src)
	owner.med_hud_set_status()
	INVOKE_ASYNC(src, PROC_REF(AddInfectionImages), owner)


/obj/item/organ/internal/body_egg/remove(mob/living/carbon/M, special = ORGAN_MANIPULATION_DEFAULT)
	STOP_PROCESSING(SSobj, src)
	if(owner)
		REMOVE_TRAIT(owner, TRAIT_XENO_HOST, GENERIC_TRAIT)
		owner.med_hud_set_status()
		INVOKE_ASYNC(src, PROC_REF(RemoveInfectionImages), owner)
	. = ..()

/obj/item/organ/internal/body_egg/process()
	if(!owner)
		return
	if(!(src in owner.internal_organs))
		remove(owner)
		return
	egg_process()

/obj/item/organ/internal/body_egg/proc/egg_process()
	return

/obj/item/organ/internal/body_egg/proc/RefreshInfectionImage()
	RemoveInfectionImages()
	AddInfectionImages()

/obj/item/organ/internal/body_egg/proc/AddInfectionImages()
	return

/obj/item/organ/internal/body_egg/proc/RemoveInfectionImages()
	return
