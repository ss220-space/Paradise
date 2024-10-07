
/proc/get_pain_modifier(mob/living/carbon/human/target) //returns modfier to make surgery harder if patient is conscious and feels pain
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

//check if mob is lying down on something we can operate on.
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
