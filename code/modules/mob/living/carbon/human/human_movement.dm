/mob/living/carbon/human/movement_delay()
	. = 0
	. += ..()
	. += CONFIG_GET(number/human_delay)
	. += dna.species.movement_delay(src)

/mob/living/carbon/human/Process_Spacemove(movement_dir = 0)
	if(..())
		return TRUE

	var/jetpacks = list()

	if(istype(back, /obj/item/tank/jetpack))
		jetpacks += back

	var/obj/item/clothing/suit/space/space_suit = wear_suit
	if(istype(space_suit) && space_suit.jetpack)
		jetpacks += space_suit.jetpack

	for(var/obj/item/tank/jetpack/jetpack in jetpacks)
		if((movement_dir || jetpack.stabilizers) && jetpack.allow_thrust(0.01, src, should_leave_trail = movement_dir))
			return TRUE

	if(dna.species.spec_Process_Spacemove(src))
		return TRUE

	return FALSE

/mob/living/carbon/human/mob_has_gravity()
	. = ..()
	if(!.)
		if(mob_negates_gravity())
			. = 1

/mob/living/carbon/human/mob_negates_gravity()
	return shoes && shoes.negates_gravity()

/mob/living/carbon/human/Move(NewLoc, direct)
	. = ..()
	if(.) // did we actually move?
		if(!lying && !buckled && !throwing)
			for(var/obj/item/organ/external/splinted in splinted_limbs)
				splinted.update_splints()
		if(dna.species.fragile_bones_chance > 0 && (m_intent != MOVE_INTENT_WALK || pulling))
			if(prob(dna.species.fragile_bones_chance))
				for(var/zone in list("l_leg", "l_foot", "r_leg", "r_foot"))
					var/obj/item/organ/external/leg = get_organ(zone)
					if(leg.status & ORGAN_BROKEN)
						continue
					else
						leg.fracture()
						break
			else
				if(dna.species.fragile_bones_chance && prob(30))
					playsound(src, "bonebreak", 10, 1)

	if(!has_gravity(loc))
		return

	var/obj/item/clothing/shoes/S = shoes

	if(S && !lying && loc == NewLoc)
		SEND_SIGNAL(S, COMSIG_SHOES_STEP_ACTION)

	//Bloody footprints
	var/turf/T = get_turf(src)
	var/obj/item/organ/external/l_foot = get_organ("l_foot")
	var/obj/item/organ/external/r_foot = get_organ("r_foot")
	var/hasfeet = TRUE
	if(!l_foot && !r_foot)
		hasfeet = FALSE

	if(shoes)
		if(S.bloody_shoes && S.bloody_shoes[S.blood_state])
			for(var/obj/effect/decal/cleanable/blood/footprints/oldFP in T)
				if(oldFP && oldFP.blood_state == S.blood_state && oldFP.basecolor == S.blood_color)
					return
			//No oldFP or it's a different kind of blood
			S.bloody_shoes[S.blood_state] = max(0, S.bloody_shoes[S.blood_state] - BLOOD_LOSS_PER_STEP)
			if(S.bloody_shoes[S.blood_state] > BLOOD_LOSS_IN_SPREAD)
				createFootprintsFrom(shoes, dir, T)
			update_inv_shoes()
	else if(hasfeet)
		if(bloody_feet && bloody_feet[blood_state])
			for(var/obj/effect/decal/cleanable/blood/footprints/oldFP in T)
				if(oldFP && oldFP.blood_state == blood_state && oldFP.basecolor == feet_blood_color)
					return
			bloody_feet[blood_state] = max(0, bloody_feet[blood_state] - BLOOD_LOSS_PER_STEP)
			if(bloody_feet[blood_state] > BLOOD_LOSS_IN_SPREAD)
				createFootprintsFrom(src, dir, T)
			update_inv_shoes()
	//End bloody footprints
