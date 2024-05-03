/mob/living/carbon/human/Moved(atom/OldLoc, Dir, Forced = FALSE)
	. = ..()
	//if((!OldLoc || !OldLoc.has_gravity()) && has_gravity()) //Temporary disable stun when gravity change
	//	thunk()


/mob/living/carbon/human/get_movespeed_modifiers()
	var/list/considering = ..()
	if(HAS_TRAIT(src, TRAIT_IGNORESLOWDOWN))
		. = list()
		for(var/id in considering)
			var/datum/movespeed_modifier/M = considering[id]
			if((M.flags & IGNORE_NOSLOW) || M.multiplicative_slowdown < 0)
				.[id] = M
		return .
	return considering


/mob/living/carbon/human/Process_Spacemove(movement_dir = 0)
	if(..())
		return TRUE

	var/jetpacks = list()

	if(istype(back, /obj/item/tank/jetpack))
		jetpacks += back

	var/obj/item/clothing/suit/space/space_suit = wear_suit
	if(istype(space_suit) && space_suit.jetpack)
		jetpacks += space_suit.jetpack

	for(var/obj/item/tank/jetpack/jetpack as anything in jetpacks)
		if((movement_dir || jetpack.stabilizers) && jetpack.allow_thrust(0.01, src, should_leave_trail = movement_dir))
			return TRUE

	if(dna.species.spec_Process_Spacemove(src))
		return TRUE

	return FALSE


/mob/living/carbon/human/Move(NewLoc, direct)
	. = ..()
	if(.) // did we actually move?
		if(!lying_angle && !buckled && !throwing)
			update_splints()
		if(dna.species.fragile_bones_chance > 0 && (m_intent != MOVE_INTENT_WALK || pulling))
			if(prob(dna.species.fragile_bones_chance))
				for(var/zone in list(BODY_ZONE_L_LEG, BODY_ZONE_R_LEG, BODY_ZONE_PRECISE_L_FOOT, BODY_ZONE_PRECISE_R_FOOT))
					var/obj/item/organ/external/leg = get_organ(zone)
					if(leg.has_fracture())
						continue
					else
						leg.fracture()
						break
			else
				if(dna.species.fragile_bones_chance && prob(30))
					playsound(src, "bonebreak", 10, TRUE)

	if(!has_gravity())
		return

	var/obj/item/clothing/shoes/S = shoes

	if(S && !lying_angle && loc == NewLoc)
		SEND_SIGNAL(S, COMSIG_SHOES_STEP_ACTION)

	//Bloody footprints
	var/turf/T = get_turf(src)
	var/hasfeet = num_legs >= 2

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


/mob/living/carbon/human/set_usable_legs(new_value)
	. = ..()
	if(isnull(.))
		return .
	update_fractures_slowdown()
	/*
	if(. == 0)
		if(usable_legs != 0) //From having no usable legs to having some.
			REMOVE_TRAIT(src, TRAIT_FLOORED, LACKING_LOCOMOTION_APPENDAGES_TRAIT)
			REMOVE_TRAIT(src, TRAIT_IMMOBILIZED, LACKING_LOCOMOTION_APPENDAGES_TRAIT)
	else if(usable_legs == 0 && !(movement_type & (FLYING | FLOATING))) //From having usable legs to no longer having them.
		ADD_TRAIT(src, TRAIT_FLOORED, LACKING_LOCOMOTION_APPENDAGES_TRAIT)
		if(!usable_hands)
			ADD_TRAIT(src, TRAIT_IMMOBILIZED, LACKING_LOCOMOTION_APPENDAGES_TRAIT)
	*/


/mob/living/carbon/human/set_usable_hands(new_value)
	. = ..()
	if(isnull(.))
		return .
	/*
	if(. == 0)
		REMOVE_TRAIT(src, TRAIT_HANDS_BLOCKED, LACKING_MANIPULATION_APPENDAGES_TRAIT)
		if(usable_hands != 0) //From having no usable hands to having some.
			REMOVE_TRAIT(src, TRAIT_IMMOBILIZED, LACKING_LOCOMOTION_APPENDAGES_TRAIT)
	else if(usable_hands == 0 && default_num_hands > 0) //From having usable hands to no longer having them.
		ADD_TRAIT(src, TRAIT_HANDS_BLOCKED, LACKING_MANIPULATION_APPENDAGES_TRAIT)
		if(!usable_legs && !(movement_type & (FLYING | FLOATING)))
			ADD_TRAIT(src, TRAIT_IMMOBILIZED, LACKING_LOCOMOTION_APPENDAGES_TRAIT)
	*/


/mob/living/carbon/human/on_movement_type_flag_enabled(datum/source, flag, old_movement_type)
	. = ..()
	if(movement_type & (FLYING|FLOATING) && !(old_movement_type & (FLYING|FLOATING)))
		remove_movespeed_modifier(/datum/movespeed_modifier/limbless)
		remove_movespeed_modifier(/datum/movespeed_modifier/fractures)
		remove_movespeed_modifier(/datum/movespeed_modifier/hunger)
		update_obesity_slowdown()


/mob/living/carbon/human/on_movement_type_flag_disabled(datum/source, flag, old_movement_type)
	. = ..()
	if(old_movement_type & (FLYING|FLOATING) && !(movement_type & (FLYING|FLOATING)))
		update_obesity_slowdown()
		update_hunger_slowdown()
		update_limbless_slowdown()
		update_fractures_slowdown()

		/*
		var/limbless_slowdown = 0
		if(usable_legs < default_num_legs)
			limbless_slowdown += (default_num_legs - usable_legs) * 3
			if(!usable_legs)
				ADD_TRAIT(src, TRAIT_FLOORED, LACKING_LOCOMOTION_APPENDAGES_TRAIT)
				if(usable_hands < default_num_hands)
					limbless_slowdown += (default_num_hands - usable_hands) * 3
					if(!usable_hands)
						ADD_TRAIT(src, TRAIT_IMMOBILIZED, LACKING_LOCOMOTION_APPENDAGES_TRAIT)

		if(limbless_slowdown)
			add_or_update_variable_movespeed_modifier(/datum/movespeed_modifier/limbless, multiplicative_slowdown = limbless_slowdown)
		else
			remove_movespeed_modifier(/datum/movespeed_modifier/limbless)
		*/


/// Proc used to weaken the user when moving from no gravity to positive gravity.
/mob/living/carbon/human/proc/thunk()
	if(buckled || mob_negates_gravity() || incorporeal_move)
		return

	if(dna?.species.spec_thunk(src)) //Species level thunk overrides
		return

	if(m_intent != MOVE_INTENT_RUN)
		return

	Weaken(4 SECONDS)
	to_chat(src, "Gravity!")

