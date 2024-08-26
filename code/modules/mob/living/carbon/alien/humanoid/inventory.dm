/mob/living/carbon/alien/humanoid/do_unEquip(obj/item/I, force = FALSE, atom/newloc, no_move = FALSE, invdrop = TRUE, silent = FALSE)
	. = ..()
	if(!. || !I)
		return

	//if we actually unequipped an item, this is because we dont want to run this proc twice, once for carbons and once for aliens
	var/not_handled = FALSE

	if(I == r_store)
		r_store = null
		if(!QDELETED(src))
			update_inv_pockets()

	else if(I == l_store)
		l_store = null
		if(!QDELETED(src))
			update_inv_pockets()
	else
		not_handled = TRUE

	if(not_handled)
		return .

	update_equipment_speed_mods()


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
	SET_PLANE_EXPLICIT(I, ABOVE_HUD_PLANE, src)

	switch(slot)
		if(ITEM_SLOT_HAND_LEFT)
			l_hand = I
			update_inv_l_hand()

		if(ITEM_SLOT_HAND_RIGHT)
			r_hand = I
			update_inv_r_hand()

		if(ITEM_SLOT_POCKET_RIGHT)
			r_store = I
			update_inv_pockets()

		if(ITEM_SLOT_POCKET_LEFT)
			l_store = I
			update_inv_pockets()

		if(ITEM_SLOT_HANDCUFFED)
			set_handcuffed(I)

		if(ITEM_SLOT_LEGCUFFED)
			set_legcuffed(I)
			update_legcuffed_status()

	return I.equipped(src, slot, initial)


/mob/living/carbon/alien/humanoid/can_equip(obj/item/I, slot, disable_warning = FALSE, bypass_equip_delay_self = FALSE, bypass_obscured = FALSE, bypass_incapacitated = FALSE)
	switch(slot)
		if(ITEM_SLOT_HAND_LEFT)
			if(l_hand)
				return FALSE
			if(!I.allowed_for_alien())
				return FALSE
			if(!bypass_incapacitated && incapacitated())
				return FALSE
			return TRUE

		if(ITEM_SLOT_HAND_RIGHT)
			if(r_hand)
				return FALSE
			if(!I.allowed_for_alien())
				return FALSE
			if(!bypass_incapacitated && incapacitated())
				return FALSE
			return TRUE

		if(ITEM_SLOT_POCKET_LEFT)
			if(l_store)
				return FALSE
			if(!I.allowed_for_alien())
				return FALSE
			if(HAS_TRAIT(I, TRAIT_NODROP))
				return FALSE
			if(I.slot_flags_2 & ITEM_FLAG_POCKET_DENY)
				return FALSE

			return I.w_class <= WEIGHT_CLASS_SMALL || (I.slot_flags_2 & ITEM_FLAG_POCKET_LARGE)

		if(ITEM_SLOT_POCKET_RIGHT)
			if(r_store)
				return FALSE
			if(!I.allowed_for_alien())
				return FALSE
			if(HAS_TRAIT(I, TRAIT_NODROP))
				return FALSE
			if(I.slot_flags_2 & ITEM_FLAG_POCKET_DENY)
				return FALSE

			return I.w_class <= WEIGHT_CLASS_SMALL || (I.slot_flags_2 & ITEM_FLAG_POCKET_LARGE)

		if(ITEM_SLOT_HANDCUFFED)
			return !handcuffed && (I.slot_flags & ITEM_SLOT_HANDCUFFED)

		if(ITEM_SLOT_LEGCUFFED)
			return !legcuffed && (I.slot_flags & ITEM_SLOT_LEGCUFFED)


/mob/living/carbon/alien/humanoid/get_item_by_slot(slot_flag)
	switch(slot_flag)
		if(ITEM_SLOT_BACK)
			return back
		if(ITEM_SLOT_MASK)
			return wear_mask
		if(ITEM_SLOT_CLOTH_OUTER)
			return wear_suit
		if(ITEM_SLOT_HAND_LEFT)
			return l_hand
		if(ITEM_SLOT_HAND_RIGHT)
			return r_hand
		if(ITEM_SLOT_POCKET_LEFT)
			return l_store
		if(ITEM_SLOT_POCKET_RIGHT)
			return r_store
		if(ITEM_SLOT_HANDCUFFED)
			return handcuffed
		if(ITEM_SLOT_LEGCUFFED)
			return legcuffed
	return null


/mob/living/carbon/alien/humanoid/get_slot_by_item(item)
	if(item == back)
		return ITEM_SLOT_BACK
	if(item == wear_mask)
		return ITEM_SLOT_MASK
	if(item == wear_suit)
		return ITEM_SLOT_CLOTH_OUTER
	if(item == l_hand)
		return ITEM_SLOT_HAND_LEFT
	if(item == r_hand)
		return ITEM_SLOT_HAND_RIGHT
	if(item == l_store)
		return ITEM_SLOT_POCKET_LEFT
	if(item == r_store)
		return ITEM_SLOT_POCKET_RIGHT
	if(item == handcuffed)
		return ITEM_SLOT_HANDCUFFED
	if(item == legcuffed)
		return ITEM_SLOT_LEGCUFFED
	return NONE


/mob/living/carbon/alien/humanoid/has_organ_for_slot(slot_flag)
	switch(slot_flag)
		if(ITEM_SLOT_BACK, ITEM_SLOT_MASK, ITEM_SLOT_CLOTH_OUTER, ITEM_SLOT_HAND_LEFT, ITEM_SLOT_HAND_RIGHT, ITEM_SLOT_HANDS, ITEM_SLOT_POCKET_LEFT, ITEM_SLOT_POCKET_RIGHT, ITEM_SLOT_POCKETS, ITEM_SLOT_HANDCUFFED, ITEM_SLOT_LEGCUFFED)
			return TRUE
		else
			return FALSE

