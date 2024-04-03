/mob/living/carbon/alien/humanoid/do_unEquip(obj/item/I, force = FALSE, atom/newloc, no_move = FALSE, invdrop = TRUE, silent = FALSE)
	. = ..()
	if(!. || !I)
		return

	if(I == r_store)
		r_store = null
		if(!QDELETED(src))
			update_inv_pockets()

	else if(I == l_store)
		l_store = null
		if(!QDELETED(src))
			update_inv_pockets()


/mob/living/carbon/alien/humanoid/equip_to_slot(obj/item/I, slot, initial)
	if(!slot)
		return
	if(!istype(I))
		return

	if(I == l_hand)
		l_hand = null
		update_inv_l_hand()
	else if(I == r_hand)
		r_hand = null
		update_inv_r_hand()

	if(I.pulledby)
		I.pulledby.stop_pulling()

	I.pixel_x = initial(I.pixel_x)
	I.pixel_y = initial(I.pixel_y)
	I.screen_loc = null
	I.forceMove(src)
	I.layer = ABOVE_HUD_LAYER
	I.plane = ABOVE_HUD_PLANE

	switch(slot)
		if(SLOT_HUD_LEFT_HAND)
			l_hand = I
			update_inv_l_hand()

		if(SLOT_HUD_RIGHT_HAND)
			r_hand = I
			update_inv_r_hand()

		if(SLOT_HUD_RIGHT_STORE)
			r_store = I
			update_inv_pockets()

		if(SLOT_HUD_LEFT_STORE)
			l_store = I
			update_inv_pockets()

		if(SLOT_HUD_HANDCUFFED)
			handcuffed = I
			update_handcuffed_status()

		if(SLOT_HUD_LEGCUFFED)
			legcuffed = I
			update_legcuffed_status()

	return I.equipped(src, slot, initial)


/mob/living/carbon/alien/humanoid/can_equip(obj/item/I, slot, disable_warning = FALSE, bypass_equip_delay_self = FALSE, bypass_obscured = FALSE)
	switch(slot)
		if(SLOT_HUD_LEFT_HAND)
			if(l_hand)
				return FALSE
			if(!I.allowed_for_alien())
				return FALSE
			if(incapacitated())
				return FALSE
			return TRUE

		if(SLOT_HUD_RIGHT_HAND)
			if(r_hand)
				return FALSE
			if(!I.allowed_for_alien())
				return FALSE
			if(incapacitated())
				return FALSE
			return TRUE

		if(SLOT_HUD_LEFT_STORE)
			if(l_store)
				return FALSE
			if(!I.allowed_for_alien())
				return FALSE
			if(I.flags & NODROP)
				return FALSE
			if(I.slot_flags & SLOT_FLAG_DENYPOCKET)
				return FALSE

			return I.w_class <= WEIGHT_CLASS_SMALL || (I.slot_flags & SLOT_FLAG_POCKET)

		if(SLOT_HUD_RIGHT_STORE)
			if(r_store)
				return FALSE
			if(!I.allowed_for_alien())
				return FALSE
			if(I.flags & NODROP)
				return FALSE
			if(I.slot_flags & SLOT_FLAG_DENYPOCKET)
				return FALSE

			return I.w_class <= WEIGHT_CLASS_SMALL || (I.slot_flags & SLOT_FLAG_POCKET)

		if(SLOT_HUD_HANDCUFFED)
			return !handcuffed && istype(I, /obj/item/restraints/handcuffs)

		if(SLOT_HUD_LEGCUFFED)
			return !legcuffed && istype(I, /obj/item/restraints/legcuffs)


/mob/living/carbon/alien/humanoid/get_item_by_slot(slot_id)
	switch(slot_id)
		if(SLOT_HUD_BACK)
			return back
		if(SLOT_HUD_WEAR_MASK)
			return wear_mask
		if(SLOT_HUD_OUTER_SUIT)
			return wear_suit
		if(SLOT_HUD_LEFT_HAND)
			return l_hand
		if(SLOT_HUD_RIGHT_HAND)
			return r_hand
		if(SLOT_HUD_LEFT_STORE)
			return l_store
		if(SLOT_HUD_RIGHT_STORE)
			return r_store
		if(SLOT_HUD_HANDCUFFED)
			return handcuffed
		if(SLOT_HUD_LEGCUFFED)
			return legcuffed
	return null


/mob/living/carbon/alien/humanoid/get_slot_by_item(item)
	if(item == back)
		return SLOT_HUD_BACK
	if(item == wear_mask)
		return SLOT_HUD_WEAR_MASK
	if(item == wear_suit)
		return SLOT_HUD_OUTER_SUIT
	if(item == l_hand)
		return SLOT_HUD_LEFT_HAND
	if(item == r_hand)
		return SLOT_HUD_RIGHT_HAND
	if(item == l_store)
		return SLOT_HUD_LEFT_STORE
	if(item == r_store)
		return SLOT_HUD_RIGHT_STORE
	if(item == handcuffed)
		return SLOT_HUD_HANDCUFFED
	if(item == legcuffed)
		return SLOT_HUD_LEGCUFFED
	return null


/mob/living/carbon/alien/humanoid/has_organ_for_slot(slot_id)
	switch(slot_id)
		if(SLOT_HUD_BACK, SLOT_HUD_WEAR_MASK, SLOT_HUD_OUTER_SUIT, SLOT_HUD_LEFT_HAND, SLOT_HUD_RIGHT_HAND, SLOT_HUD_LEFT_STORE, SLOT_HUD_RIGHT_STORE, SLOT_HUD_HANDCUFFED, SLOT_HUD_LEGCUFFED)
			return TRUE
		else
			return FALSE

