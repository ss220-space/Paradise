/mob/living/carbon/human/Moved(atom/old_loc, movement_dir, forced, list/old_locs, momentum_change = TRUE)
	. = ..()
	if(!forced && (!old_loc || !old_loc.has_gravity()) && has_gravity())
		thunk()


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


/mob/living/carbon/human/Process_Spacemove(movement_dir = NONE, continuous_move = FALSE)
	if(movement_type & FLYING)
		return TRUE
	if(dna.species.spec_Process_Spacemove(src, movement_dir, continuous_move = FALSE))
		return TRUE
	return ..()


/mob/living/carbon/human/Move(atom/newloc, direct = NONE, glide_size_override = 0, update_dir = TRUE)
	. = ..()
	if(.) // did we actually move?
		if(body_position != LYING_DOWN && !buckled && !throwing)
			update_splints()
		var/break_bones_chance = get_bones_symptom_prob()
		if(break_bones_chance && (m_intent == MOVE_INTENT_RUN || pulling))
			if(prob(break_bones_chance))
				for(var/zone in list(BODY_ZONE_L_LEG, BODY_ZONE_R_LEG, BODY_ZONE_PRECISE_L_FOOT, BODY_ZONE_PRECISE_R_FOOT))
					var/obj/item/organ/external/leg = get_organ(zone)
					if(leg.has_fracture())
						continue
					else
						leg.fracture()
						break
			else if(prob(30))
				playsound(src, "bonebreak", 10, TRUE)

	if(!has_gravity())
		return .

	if(nutrition && stat != DEAD && !isvampire(src))
		var/hunger = HUNGER_FACTOR * 0.1 * dna.species.hunger_drain_mod * physiology.hunger_mod
		if(m_intent == MOVE_INTENT_RUN)
			hunger *= 2
		adjust_nutrition(-hunger)

	var/obj/item/clothing/shoes/S = shoes

	if(S && body_position != LYING_DOWN && loc == newloc)
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


/mob/living/carbon/human/on_fall()
	. = ..()
	if(HAS_TRAIT_FROM(src, TRAIT_FLOORED, LACKING_LOCOMOTION_APPENDAGES_TRAIT) && has_pain())
		INVOKE_ASYNC(src, PROC_REF(emote), "scream")


/mob/living/carbon/human/set_usable_legs(new_value, special = ORGAN_MANIPULATION_DEFAULT)
	. = ..()
	if(isnull(.) || special != ORGAN_MANIPULATION_DEFAULT)
		return .

	if(. == 0)
		if(usable_legs != 0) //From having no usable legs to having some.
			REMOVE_TRAIT(src, TRAIT_FLOORED, LACKING_LOCOMOTION_APPENDAGES_TRAIT)
			REMOVE_TRAIT(src, TRAIT_IMMOBILIZED, LACKING_LOCOMOTION_APPENDAGES_TRAIT)
	else if(usable_legs == 0 && !(movement_type & (FLYING|FLOATING))) //From having usable legs to no longer having them.
		ADD_TRAIT(src, TRAIT_FLOORED, LACKING_LOCOMOTION_APPENDAGES_TRAIT)
		if(!usable_hands)
			ADD_TRAIT(src, TRAIT_IMMOBILIZED, LACKING_LOCOMOTION_APPENDAGES_TRAIT)

	update_fractures_slowdown()


/mob/living/carbon/human/set_usable_hands(new_value, special = ORGAN_MANIPULATION_DEFAULT, hand_index)
	. = ..()
	if(isnull(.) || special != ORGAN_MANIPULATION_DEFAULT)
		return .

	if(. == 0)
		REMOVE_TRAIT(src, TRAIT_HANDS_BLOCKED, LACKING_MANIPULATION_APPENDAGES_TRAIT)
		if(usable_hands != 0) //From having no usable hands to having some.
			REMOVE_TRAIT(src, TRAIT_IMMOBILIZED, LACKING_LOCOMOTION_APPENDAGES_TRAIT)
	else if(usable_hands == 0 && default_num_hands > 0) //From having usable hands to no longer having them.
		ADD_TRAIT(src, TRAIT_HANDS_BLOCKED, LACKING_MANIPULATION_APPENDAGES_TRAIT)
		if(!usable_legs && !(movement_type & (FLYING|FLOATING)))
			ADD_TRAIT(src, TRAIT_IMMOBILIZED, LACKING_LOCOMOTION_APPENDAGES_TRAIT)

	update_hands_HUD()


/mob/living/carbon/human/on_movement_type_flag_enabled(datum/source, flag, old_movement_type)
	. = ..()
	if(movement_type & (FLYING|FLOATING) && !(old_movement_type & (FLYING|FLOATING)))
		remove_traits(list(TRAIT_FLOORED, TRAIT_IMMOBILIZED), LACKING_LOCOMOTION_APPENDAGES_TRAIT)
		remove_movespeed_modifier(/datum/movespeed_modifier/limbless)
		remove_movespeed_modifier(/datum/movespeed_modifier/fractures)
		remove_movespeed_modifier(/datum/movespeed_modifier/hunger)
		update_fat_slowdown()


/mob/living/carbon/human/on_movement_type_flag_disabled(datum/source, flag, old_movement_type)
	. = ..()
	if(old_movement_type & (FLYING|FLOATING) && !(movement_type & (FLYING|FLOATING)))

		var/limbless_slowdown = 0
		if(usable_legs < default_num_legs)
			limbless_slowdown += (default_num_legs - usable_legs) * 4 - get_crutches()
			if(!usable_legs)
				ADD_TRAIT(src, TRAIT_FLOORED, LACKING_LOCOMOTION_APPENDAGES_TRAIT)
				if(usable_hands < default_num_hands)
					limbless_slowdown += (default_num_hands - usable_hands) * 4
					if(!usable_hands)
						ADD_TRAIT(src, TRAIT_IMMOBILIZED, LACKING_LOCOMOTION_APPENDAGES_TRAIT)

		if(limbless_slowdown)
			add_or_update_variable_movespeed_modifier(/datum/movespeed_modifier/limbless, multiplicative_slowdown = limbless_slowdown)
		else
			remove_movespeed_modifier(/datum/movespeed_modifier/limbless)

		update_fractures_slowdown()
		update_hunger_slowdown()
		update_fat_slowdown()


/// Proc used to recalculate traits and slowdowns after species change.
/mob/living/carbon/human/proc/recalculate_limbs_status()
	if(usable_legs > 0) // gained leg usage
		REMOVE_TRAIT(src, TRAIT_FLOORED, LACKING_LOCOMOTION_APPENDAGES_TRAIT)
		REMOVE_TRAIT(src, TRAIT_IMMOBILIZED, LACKING_LOCOMOTION_APPENDAGES_TRAIT)
	else if(usable_legs == 0 && !(movement_type & (FLYING|FLOATING))) // lost leg usage, not flying
		ADD_TRAIT(src, TRAIT_FLOORED, LACKING_LOCOMOTION_APPENDAGES_TRAIT)
		if(usable_hands == 0) // lost hand usage
			ADD_TRAIT(src, TRAIT_IMMOBILIZED, LACKING_LOCOMOTION_APPENDAGES_TRAIT)

	if(usable_hands > 0) // gained hand usage
		REMOVE_TRAIT(src, TRAIT_HANDS_BLOCKED, LACKING_MANIPULATION_APPENDAGES_TRAIT)
	else if(usable_hands == 0) // lost hand usage
		ADD_TRAIT(src, TRAIT_HANDS_BLOCKED, LACKING_MANIPULATION_APPENDAGES_TRAIT)

	update_limbless_slowdown()
	update_fractures_slowdown()
	update_hands_HUD()


/// Proc used to inflict stamina damage when user is moving from no gravity to positive gravity.
/mob/living/carbon/human/proc/thunk()
	if(buckled || incorporeal_move || body_position == LYING_DOWN || mob_negates_gravity())
		return

	if(dna?.species.spec_thunk(src)) //Species level thunk overrides
		return

	if(m_intent != MOVE_INTENT_RUN)
		return

	to_chat(src, span_userdanger("Gravity exhausts you!"))
	apply_damage(35, STAMINA)


/mob/living/carbon/human/slip(weaken, obj/slipped_on, lube_flags, tilesSlipped)
	if(HAS_TRAIT(src, TRAIT_NO_SLIP_ALL))
		return FALSE

	if(HAS_TRAIT(src, TRAIT_NO_SLIP_WATER) && !(lube_flags & SLIP_IGNORE_NO_SLIP_WATER))
		return FALSE

	if(HAS_TRAIT(src, TRAIT_NO_SLIP_ICE) && (lube_flags & SLIDE_ICE))
		return FALSE

	return ..()
