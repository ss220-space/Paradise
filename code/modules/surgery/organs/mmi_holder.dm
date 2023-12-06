// Used for an MMI or robotic brain being installed into a human.
/obj/item/organ/internal/brain/mmi_holder
	name = "Man-Machine Interface"
	parent_organ_zone = BODY_ZONE_CHEST
	status = ORGAN_ROBOT
	var/obj/item/mmi/stored_mmi

/obj/item/organ/internal/brain/mmi_holder/Destroy()
	QDEL_NULL(stored_mmi)
	return ..()

/obj/item/organ/internal/brain/mmi_holder/insert(mob/living/target, special = ORGAN_MANIPULATION_DEFAULT)
	..()
	// To supersede the over-writing of the MMI's name from `insert`
	update_from_mmi()

/obj/item/organ/internal/brain/mmi_holder/remove(mob/living/user, special = ORGAN_MANIPULATION_DEFAULT)
	if(!special)
		if(stored_mmi)
			. = stored_mmi
			if(owner.mind)
				owner.mind.transfer_to(stored_mmi.brainmob)
			stored_mmi.forceMove(get_turf(owner))
			stored_mmi = null
	..()
	if(!QDELETED(src))
		qdel(src)

/obj/item/organ/internal/brain/mmi_holder/proc/update_from_mmi()
	if(!stored_mmi)
		return
	name = initial(stored_mmi.name)
	desc = stored_mmi.desc
	icon = stored_mmi.icon
	icon_state = stored_mmi.icon_state
	update_DNA(stored_mmi.brainmob.dna)
