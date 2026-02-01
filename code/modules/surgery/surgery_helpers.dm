///returns modfier to make surgery harder if patient is conscious and feels pain
/proc/get_pain_modifier(mob/living/carbon/human/target)
	if(target.stat == DEAD) // Operating on dead people is easy
		return 1
	var/datum/status_effect/incapacitating/sleeping/S = target.IsSleeping()
	if(target.stat == UNCONSCIOUS && S)
		// Either unconscious due to something other than sleep,
		// or "sleeping" due to being hard knocked out (N2O or similar), rather than just napping.
		// Either way, not easily woken up.
		return 1
	if(HAS_TRAIT(target, TRAIT_NO_PAIN))//if you don't feel pain, you can hold still
		return 1
	if(target.reagents.has_reagent("hydrocodone"))//really good pain killer
		return 0.99
	if(target.reagents.has_reagent("morphine"))//Just as effective as Hydrocodone, but has an addiction chance
		return 0.99
	if(target.reagents.has_reagent("syntmorphine"))
		return 0.99
	var/drunk = target.get_drunkenness()
	if(drunk >= 80)//really damn drunk
		return 0.95
	if(drunk >= 40)//pretty drunk
		return 0.9
	if(target.reagents.has_reagent("sal_acid")) //it's better than nothing, as far as painkillers go.
		return 0.85
	if(drunk >= 15)//a little drunk
		return 0.85
	return 0.8 //20% failure chance

/proc/get_location_modifier(mob/target)
	var/turf/T = get_turf(target)
	if(locate(/obj/machinery/optable, T))
		return 1
	else if(locate(/obj/structure/table, T))
		return 0.8
	else if(locate(/obj/structure/bed, T))
		return 0.7
	else
		return 0.5

///check if mob is lying down on something we can operate on.
/proc/on_operable_surface(mob/living/carbon/target)
	if(locate(/obj/machinery/optable, target.loc) && target.body_position == LYING_DOWN)
		return TRUE
	if(locate(/obj/structure/bed, target.loc) && target.body_position == LYING_DOWN)
		return TRUE
	if(locate(/obj/structure/table, target.loc) && target.body_position == LYING_DOWN)
		return TRUE
	return FALSE

/**
 * Called when a limb containing this object is placed back on a body.
 *
 * Arguments:
 * * parent - bodypart in which our src object is placed.
 * * target - future owner of the limb.
 */
/atom/movable/proc/attempt_become_organ(obj/item/organ/external/parent, mob/living/carbon/human/target, special = ORGAN_MANIPULATION_DEFAULT)
	return FALSE

/// Check to see if a surgical operation proposed on ourselves is valid or not. We are the target of the surgery
/mob/living/proc/can_run_surgery(datum/surgery/surgery, mob/surgeon, obj/item/organ/external/affecting)
	if(!affecting)
		// try to pull it if it isn't passed in (it's a parameter mostly for optimization purposes)
		affecting = get_organ(check_zone(surgeon.zone_selected))

	if(!surgery.possible_locs.Find(surgeon.zone_selected))
		return
	if(affecting)
		if(!surgery.requires_bodypart)
			return
		if((surgery.is_organ_noncompatible(affecting)))
			return
	else if(surgery.requires_bodypart) //mob with no limb in surgery zone when we need a limb
		return
	if(surgery.lying_required && body_position != LYING_DOWN)
		return
	if(!surgery.self_operable && src == surgeon)
		return
	if(!surgery.can_start(surgeon, src))
		return

	return TRUE

/// This proc is made to check if we can interact or use (directly or in the other way) the specific bodypart
/// Not to check if one clothing blocks access to the other clothing for that we have flags_inv var
/proc/get_location_accessible(mob/M, location)
	var/covered_locations	= 0	//based on body_parts_covered
	var/eyesmouth_covered	= 0	//based on flags_cover
	if(iscarbon(M))
		var/mob/living/carbon/C = M
		for(var/obj/item/clothing/I in list(C.back, C.wear_mask))
			covered_locations |= I.body_parts_covered
			eyesmouth_covered |= I.flags_cover
		if(ishuman(C))
			var/mob/living/carbon/human/H = C
			for(var/obj/item/I in list(H.wear_suit, H.w_uniform, H.shoes, H.belt, H.gloves, H.glasses, H.head, H.r_ear, H.l_ear, H.neck))
				covered_locations |= I.body_parts_covered
				eyesmouth_covered |= I.flags_cover
	// If we check for mouth or eyes for gods sake use the appropriate flags for THEM!
	// Not for the face, head e.t.c.
	// HIDENAME(formerly known as HIDEFACE) flag was made to check if we appear as unknown
	// HIDEGLASSES(formerly known as HIDEEYES) flag was made, ironically, to check if it hides our GLASSES
	// not to check if it makes using the fucking mouth/eyes impossible!!!
	// - Furukai
	switch(location)
		if(BODY_ZONE_HEAD)
			if(covered_locations & HEAD)
				return FALSE
		if(BODY_ZONE_PRECISE_EYES)
			if(eyesmouth_covered & MASKCOVERSEYES || eyesmouth_covered & GLASSESCOVERSEYES || eyesmouth_covered & HEADCOVERSEYES)
				return FALSE
		if(BODY_ZONE_PRECISE_MOUTH)
			if(eyesmouth_covered & HEADCOVERSMOUTH || eyesmouth_covered & MASKCOVERSMOUTH)
				return FALSE
		if(BODY_ZONE_CHEST)
			if(covered_locations & UPPER_TORSO)
				return FALSE
		if(BODY_ZONE_PRECISE_GROIN)
			if(covered_locations & LOWER_TORSO)
				return FALSE
		if(BODY_ZONE_L_ARM)
			if(covered_locations & ARM_LEFT)
				return FALSE
		if(BODY_ZONE_R_ARM)
			if(covered_locations & ARM_RIGHT)
				return FALSE
		if(BODY_ZONE_L_LEG)
			if(covered_locations & LEG_LEFT)
				return FALSE
		if(BODY_ZONE_R_LEG)
			if(covered_locations & LEG_RIGHT)
				return FALSE
		if(BODY_ZONE_PRECISE_L_HAND)
			if(covered_locations & HAND_LEFT)
				return FALSE
		if(BODY_ZONE_PRECISE_R_HAND)
			if(covered_locations & HAND_RIGHT)
				return FALSE
		if(BODY_ZONE_PRECISE_L_FOOT)
			if(covered_locations & FOOT_LEFT)
				return FALSE
		if(BODY_ZONE_PRECISE_R_FOOT)
			if(covered_locations & FOOT_RIGHT)
				return FALSE

	return TRUE
