/mob/proc/get_int_organ(typepath) //int stands for internal
	return

/mob/proc/get_organs_zone(zone)
	return

/mob/proc/get_organ_slot(slot) //is it a brain, is it a brain_tumor?
	return

/**
 * Returns specified external organ by zone index.
 *
 * Arguments:
 * * zone - bodypart index (see [combat.dm] for defines)
 */
/mob/proc/get_organ(zone)
	return

/mob/living/carbon/get_int_organ(typepath)
	return (locate(typepath) in internal_organs)


/mob/living/carbon/get_organs_zone(zone, subzones = FALSE)
	var/list/returnorg = list()
	if(subzones)
		// Include subzones - groin for chest, eyes and mouth for head
		//Fethas note:We have check_zone, i may need to remove the below
		if(zone == BODY_ZONE_HEAD)
			returnorg = get_organs_zone(BODY_ZONE_PRECISE_EYES) + get_organs_zone(BODY_ZONE_PRECISE_MOUTH)
		if(zone == BODY_ZONE_CHEST)
			returnorg = get_organs_zone(BODY_ZONE_PRECISE_GROIN)

	for(var/obj/item/organ/internal/organ as anything in internal_organs)
		if(zone == organ.parent_organ_zone)
			returnorg += organ
	return returnorg


/mob/living/carbon/get_organ_slot(slot)
	return internal_organs_slot[slot]


/proc/is_int_organ(atom/A)
	return istype(A, /obj/item/organ/internal)


/mob/proc/has_active_hand()
	return hand ? has_left_hand() : has_right_hand()


/mob/proc/has_inactive_hand()
	return hand ? has_right_hand() : has_left_hand()


/mob/proc/has_left_hand()
	return TRUE

/mob/living/carbon/human/has_left_hand()
	return get_organ(BODY_ZONE_PRECISE_L_HAND)

/mob/proc/has_right_hand()
	return TRUE

/mob/living/carbon/human/has_right_hand()
	return get_organ(BODY_ZONE_PRECISE_R_HAND)

/mob/proc/has_both_hands()
	return TRUE

/mob/living/carbon/human/has_both_hands()
	if(has_left_hand() && has_right_hand())
		return TRUE
	return FALSE

/mob/proc/l_arm_broken()
	return FALSE

/mob/living/carbon/human/l_arm_broken()
	var/obj/item/organ/external/hand/l_hand = get_organ(BODY_ZONE_PRECISE_L_HAND)
	var/obj/item/organ/external/arm/l_arm = get_organ(BODY_ZONE_L_ARM)
	if(!l_hand || !l_arm)
		return FALSE
	if(l_hand.is_traumatized() || l_arm.is_traumatized())
		return TRUE
	return FALSE

/mob/proc/r_arm_broken()
	return TRUE

/mob/living/carbon/human/r_arm_broken()
	var/obj/item/organ/external/hand/right/r_hand = get_organ(BODY_ZONE_PRECISE_R_HAND)
	var/obj/item/organ/external/arm/right/r_arm = get_organ(BODY_ZONE_R_ARM)
	if(!r_hand || !r_arm)
		return FALSE
	if(r_hand.is_traumatized() || r_arm.is_traumatized())
		return TRUE
	return FALSE

