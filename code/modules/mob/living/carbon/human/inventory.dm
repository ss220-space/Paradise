/**
 * Determines if mob has and can use his hands like a human
 */
/mob/living/carbon/human/real_human_being()
	return TRUE


/mob/living/carbon/human/has_organ_for_slot(slot)
	switch(slot)
		if(ITEM_SLOT_BACKPACK, ITEM_SLOT_PDA, ITEM_SLOT_ID, ITEM_SLOT_ACCESSORY)
			return TRUE
		if(ITEM_SLOT_BACK, ITEM_SLOT_BELT, ITEM_SLOT_CLOTH_OUTER, ITEM_SLOT_CLOTH_INNER, ITEM_SLOT_POCKET_LEFT, ITEM_SLOT_POCKET_RIGHT, ITEM_SLOT_POCKETS, ITEM_SLOT_SUITSTORE, ITEM_SLOT_NECK)
			return get_organ(BODY_ZONE_CHEST)
		if(ITEM_SLOT_HEAD, ITEM_SLOT_MASK, ITEM_SLOT_EAR_LEFT, ITEM_SLOT_EAR_RIGHT, ITEM_SLOT_EARS, ITEM_SLOT_EYES)
			return get_organ(BODY_ZONE_HEAD)
		if(ITEM_SLOT_HANDS, ITEM_SLOT_GLOVES, ITEM_SLOT_HANDCUFFED)
			return num_hands >= 2
		if(ITEM_SLOT_FEET, ITEM_SLOT_LEGCUFFED)
			return num_legs >= 2
		if(ITEM_SLOT_HAND_LEFT)
			return get_organ(BODY_ZONE_PRECISE_L_HAND)
		if(ITEM_SLOT_HAND_RIGHT)
			return get_organ(BODY_ZONE_PRECISE_R_HAND)


/**
 * Handle stuff to update when a mob equips/unequips a glasses.
 */
/mob/living/carbon/human/wear_glasses_update(obj/item/clothing/glasses/our_glasses)
	if(istype(our_glasses))
		if(our_glasses.tint || initial(our_glasses.tint))
			update_tint()
		if(our_glasses.prescription)
			update_nearsighted_effects()
		if(our_glasses.vision_flags || our_glasses.see_in_dark || our_glasses.invis_override || our_glasses.invis_view || !isnull(our_glasses.lighting_alpha))
			update_sight()
			update_client_colour()

	update_inv_glasses()


/**
 * Handle stuff to update when a mob equips/unequips a mask.
 */
/mob/living/carbon/human/wear_mask_update(obj/item/clothing/mask, toggle_off = FALSE)
	if(istype(mask) && mask.tint || initial(mask.tint))
		update_tint()

	if((mask.flags_inv & (HIDEHAIR|HIDEHEADHAIR|HIDEFACIALHAIR)) || \
		(initial(mask.flags_inv) & (HIDEHAIR|HIDEHEADHAIR|HIDEFACIALHAIR)))
		update_hair()	//rebuild hair
		update_fhair()
		update_head_accessory()

	if(toggle_off && internal && !has_airtight_items())
		internal = null
		update_action_buttons_icon()

	if((mask.flags_inv & HIDEGLASSES) || \
		(mask.flags_inv_transparent & HIDEGLASSES) || \
		(initial(mask.flags_inv) & HIDEGLASSES) || \
		(initial(mask.flags_inv_transparent) & HIDEGLASSES))
		update_inv_glasses()

	if((mask.flags_inv & HIDEHEADSETS) || \
		(mask.flags_inv_transparent & HIDEHEADSETS) || \
		(initial(mask.flags_inv) & HIDEHEADSETS) || \
		(initial(mask.flags_inv_transparent) & HIDEHEADSETS))
		update_inv_ears()

	sec_hud_set_ID()
	update_inv_wear_mask()


/**
 * Handles stuff to update when a mob equips/unequips a headgear.
 */
/mob/living/carbon/human/update_head(obj/item/clothing/head/check_item, forced = FALSE, toggle_off = FALSE)
	check_item = check_item || head
	if(!check_item)
		return

	if(toggle_off && internal && !has_airtight_items())
		internal = null
		update_action_buttons_icon()

	if(forced || \
		(check_item.flags_inv & (HIDEHAIR|HIDEHEADHAIR|HIDEFACIALHAIR)) || \
		(initial(check_item.flags_inv) & (HIDEHAIR|HIDEHEADHAIR|HIDEFACIALHAIR)))
		update_hair()	//rebuild hair
		update_fhair()
		update_head_accessory()

	// Bandanas and paper hats go on the head but are not head clothing
	if(istype(check_item, /obj/item/clothing/head))
		var/obj/item/clothing/head/hat = check_item
		if(forced || hat.tint || initial(hat.tint))
			update_tint()

		if(forced || hat.vision_flags || hat.see_in_dark || !isnull(hat.lighting_alpha))
			update_sight()

	if(forced || \
		(check_item.flags_inv & HIDEHEADSETS) || \
		(check_item.flags_inv_transparent & HIDEHEADSETS) || \
		(initial(check_item.flags_inv) & HIDEHEADSETS) || \
		(initial(check_item.flags_inv_transparent) & HIDEHEADSETS))
		update_inv_ears()
	if(forced || \
		(check_item.flags_inv & HIDEMASK) || \
		(check_item.flags_inv_transparent & HIDEMASK) || \
		(initial(check_item.flags_inv) & HIDEMASK) || \
		(initial(check_item.flags_inv_transparent) & HIDEMASK))
		update_inv_wear_mask()
	if(forced || \
		(check_item.flags_inv & HIDEGLASSES) || \
		(check_item.flags_inv_transparent & HIDEGLASSES) || \
		(initial(check_item.flags_inv) & HIDEGLASSES) || \
		(initial(check_item.flags_inv_transparent) & HIDEGLASSES))
		update_inv_glasses()

	sec_hud_set_ID()
	update_inv_head()


/**
 * Handles stuff to update when a mob equips/unequips a suit.
 */
/mob/living/carbon/human/wear_suit_update(obj/item/clothing/suit)
	if((suit.flags_inv & HIDEJUMPSUIT) || \
		(suit.flags_inv_transparent & HIDEJUMPSUIT) || \
		(initial(suit.flags_inv) & HIDEJUMPSUIT) || \
		(initial(suit.flags_inv_transparent) & HIDEJUMPSUIT))
		update_inv_w_uniform()

	if((suit.flags_inv & HIDESHOES) || \
		(suit.flags_inv_transparent & HIDESHOES) || \
		(initial(suit.flags_inv) & HIDESHOES) || \
		(initial(suit.flags_inv_transparent) & HIDESHOES))
		update_inv_shoes()

	if((suit.flags_inv & HIDEGLOVES) || \
		(suit.flags_inv_transparent & HIDEGLOVES) || \
		(initial(suit.flags_inv) & HIDEGLOVES) || \
		(initial(suit.flags_inv_transparent) & HIDEGLOVES))
		update_inv_gloves()

	update_inv_wear_suit()



/mob/living/carbon/human/can_unEquip(obj/item/I, force = FALSE, disable_messages = TRUE, atom/newloc = null, no_move = FALSE, invdrop = TRUE, silent = TRUE)
	. = ..()
	var/obj/item/organ/O = I
	if(istype(O) && O.owner == src)
		return FALSE // keep a good grip on your heart


/mob/living/carbon/human/do_unEquip(obj/item/I, force = FALSE, atom/newloc, no_move = FALSE, invdrop = TRUE, silent = FALSE)
	. = ..() //See mob.dm for an explanation on this and some rage about people copypasting instead of calling ..() like they should.
	if(!. || !I)
		return .
	//if we actually unequipped an item, this is because we dont want to run this proc twice, once for carbons and once for humans
	var/not_handled = FALSE
	if(I == wear_suit)
		if(s_store && invdrop)
			drop_item_ground(s_store, force = TRUE) //It makes no sense for your suit storage to stay on you if you drop your suit.
		wear_suit = null
		if(!QDELETED(src))
			wear_suit_update(I)
			if(I.breakouttime) //when unequipping a straightjacket
				REMOVE_TRAIT(src, TRAIT_RESTRAINED, SUIT_TRAIT)

	else if(I == w_uniform)
		if(invdrop && !dna.species.nojumpsuit)
			if(r_store)
				drop_item_ground(r_store, force = TRUE) //Again, makes sense for pockets to drop.
			if(l_store)
				drop_item_ground(l_store, force = TRUE)
			if(wear_id)
				drop_item_ground(wear_id, force = TRUE)
			if(belt)
				drop_item_ground(belt, force = TRUE)
			if(wear_pda)
				drop_item_ground(wear_pda, force = TRUE)
		w_uniform = null
		if(!QDELETED(src))
			update_inv_w_uniform()

	else if(I == gloves)
		gloves = null
		if(!QDELETED(src))
			update_inv_gloves()

	else if(I == neck)
		neck = null
		if(!QDELETED(src))
			update_inv_neck()

	else if(I == glasses)
		glasses = null
		if(!QDELETED(src))
			wear_glasses_update(I)

	else if(I == head)
		head = null
		if(!QDELETED(src))
			update_head(I, toggle_off = TRUE)

	else if(I == r_ear)
		r_ear = null
		if(I.slot_flags_2 & ITEM_FLAG_TWOEARS)
			drop_item_ground(l_ear, silent = TRUE)
		if(!QDELETED(src))
			update_inv_ears()

	else if(I == l_ear)
		l_ear = null
		if(I.slot_flags_2 & ITEM_FLAG_TWOEARS)
			drop_item_ground(r_ear, silent = TRUE)
		if(!QDELETED(src))
			update_inv_ears()

	else if(I == shoes)
		shoes = null
		if(!QDELETED(src))
			update_inv_shoes()

	else if(I == belt)
		belt = null
		if(!QDELETED(src))
			update_inv_belt()

	else if(I == wear_mask)
		wear_mask = null
		if(!QDELETED(src))
			wear_mask_update(I, toggle_off = TRUE)

	else if(I == wear_id)
		wear_id = null
		if(!QDELETED(src))
			sec_hud_set_ID()
			update_inv_wear_id()

	else if(I == wear_pda)
		wear_pda = null
		if(!QDELETED(src))
			update_inv_wear_pda()

	else if(I == r_store)
		r_store = null
		if(!QDELETED(src))
			update_inv_pockets()

	else if(I == l_store)
		l_store = null
		if(!QDELETED(src))
			update_inv_pockets()

	else if(I == s_store)
		s_store = null
		if(!QDELETED(src))
			update_inv_s_store()

	else if(I == back)
		back = null
		if(!QDELETED(src))
			update_inv_back()

	else if(I == r_hand)
		r_hand = null
		if(!QDELETED(src))
			update_inv_r_hand()

	else if(I == l_hand)
		l_hand = null
		if(!QDELETED(src))
			update_inv_l_hand()
	else
		not_handled = TRUE

	if(not_handled)
		return .

	update_equipment_speed_mods()


/mob/living/carbon/human/can_equip(obj/item/I, slot, disable_warning = FALSE, bypass_equip_delay_self = FALSE, bypass_obscured = FALSE, bypass_incapacitated = FALSE)
	return dna.species.can_equip(I, slot, src, disable_warning, bypass_equip_delay_self, bypass_obscured, bypass_incapacitated)


/**
 * This is an UNSAFE proc. Use mob_can_equip() before calling this one! Or rather use equip_to_slot_if_possible().
 * Initial is used to indicate whether or not this is the initial equipment (job datums etc) or just a player doing it.
 */
/mob/living/carbon/human/equip_to_slot(obj/item/I, slot, initial)
	if(!slot)
		return
	if(!istype(I))
		return
	if(!has_organ_for_slot(slot))
		return

	if(I == l_hand)
		l_hand = null
		update_inv_l_hand() //So items actually disappear from hands.
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
		if(ITEM_SLOT_BACK)
			back = I
			update_inv_back()

		if(ITEM_SLOT_MASK)
			wear_mask = I
			wear_mask_update(I, toggle_off = FALSE)

		if(ITEM_SLOT_NECK)
			neck = I
			update_inv_neck()

		if(ITEM_SLOT_HANDCUFFED)
			set_handcuffed(I)

		if(ITEM_SLOT_LEGCUFFED)
			set_legcuffed(I)
			update_legcuffed_status()

		if(ITEM_SLOT_HAND_LEFT)
			l_hand = I
			update_inv_l_hand()

		if(ITEM_SLOT_HAND_RIGHT)
			r_hand = I
			update_inv_r_hand()

		if(ITEM_SLOT_BELT)
			belt = I
			update_inv_belt()

		if(ITEM_SLOT_ID)
			wear_id = I
			if(hud_list.len)
				sec_hud_set_ID()
			update_inv_wear_id()

		if(ITEM_SLOT_PDA)
			wear_pda = I
			update_inv_wear_pda()

		if(ITEM_SLOT_EAR_LEFT)
			l_ear = I
			if(l_ear.slot_flags_2 & ITEM_FLAG_TWOEARS)
				I.make_offear(ITEM_SLOT_EAR_RIGHT, src)
			update_inv_ears()

		if(ITEM_SLOT_EAR_RIGHT)
			r_ear = I
			if(r_ear.slot_flags_2 & ITEM_FLAG_TWOEARS)
				I.make_offear(ITEM_SLOT_EAR_LEFT, src)
			update_inv_ears()

		if(ITEM_SLOT_EYES)
			glasses = I
			wear_glasses_update(I)

		if(ITEM_SLOT_GLOVES)
			gloves = I
			update_inv_gloves()

		if(ITEM_SLOT_HEAD)
			head = I
			update_head(I)

		if(ITEM_SLOT_FEET)
			shoes = I
			update_inv_shoes()

		if(ITEM_SLOT_CLOTH_OUTER)
			wear_suit = I
			wear_suit_update(I)
			if(I.breakouttime) //when equipping a straightjacket
				ADD_TRAIT(src, TRAIT_RESTRAINED, SUIT_TRAIT)

		if(ITEM_SLOT_CLOTH_INNER)
			w_uniform = I
			update_inv_w_uniform()

		if(ITEM_SLOT_POCKET_LEFT)
			l_store = I
			update_inv_pockets()

		if(ITEM_SLOT_POCKET_RIGHT)
			r_store = I
			update_inv_pockets()

		if(ITEM_SLOT_SUITSTORE)
			s_store = I
			update_inv_s_store()

		if(ITEM_SLOT_BACKPACK)
			if(isstorage(back))
				if(get_active_hand() == I)
					temporarily_remove_item_from_inventory(I)
				I.forceMove(back)
			else
				I.forceMove(drop_location())

		if(ITEM_SLOT_ACCESSORY)
			var/obj/item/clothing/under/uniform = w_uniform
			uniform.attackby(I, src)

		else
			to_chat(src, span_warning("You are trying to equip this item to an unsupported inventory slot. Report this to a coder!"))

	return I.equipped(src, slot, initial)


/**
 * Returns the item currently in the slot
 */
/mob/living/carbon/human/get_item_by_slot(slot_flag)
	switch(slot_flag)
		if(ITEM_SLOT_BACK)
			return back
		if(ITEM_SLOT_MASK)
			return wear_mask
		if(ITEM_SLOT_NECK)
			return neck
		if(ITEM_SLOT_HANDCUFFED)
			return handcuffed
		if(ITEM_SLOT_LEGCUFFED)
			return legcuffed
		if(ITEM_SLOT_HAND_LEFT)
			return l_hand
		if(ITEM_SLOT_HAND_RIGHT)
			return r_hand
		if(ITEM_SLOT_BELT)
			return belt
		if(ITEM_SLOT_ID)
			return wear_id
		if(ITEM_SLOT_PDA)
			return wear_pda
		if(ITEM_SLOT_EAR_LEFT)
			return l_ear
		if(ITEM_SLOT_EAR_RIGHT)
			return r_ear
		if(ITEM_SLOT_EYES)
			return glasses
		if(ITEM_SLOT_GLOVES)
			return gloves
		if(ITEM_SLOT_HEAD)
			return head
		if(ITEM_SLOT_FEET)
			return shoes
		if(ITEM_SLOT_CLOTH_OUTER)
			return wear_suit
		if(ITEM_SLOT_CLOTH_INNER)
			return w_uniform
		if(ITEM_SLOT_POCKET_LEFT)
			return l_store
		if(ITEM_SLOT_POCKET_RIGHT)
			return r_store
		if(ITEM_SLOT_SUITSTORE)
			return s_store
	return null


/**
 * Returns the item current slot ID by passed item.
 * Returns `null` if slot is not found.
 */
/mob/living/carbon/human/get_slot_by_item(item)
	if(item == back)
		return ITEM_SLOT_BACK
	if(item == wear_mask)
		return ITEM_SLOT_MASK
	if(item == neck)
		return ITEM_SLOT_NECK
	if(item == handcuffed)
		return ITEM_SLOT_HANDCUFFED
	if(item == legcuffed)
		return ITEM_SLOT_LEGCUFFED
	if(item == l_hand)
		return ITEM_SLOT_HAND_LEFT
	if(item == r_hand)
		return ITEM_SLOT_HAND_RIGHT
	if(item == belt)
		return ITEM_SLOT_BELT
	if(item == wear_id)
		return ITEM_SLOT_ID
	if(item == wear_pda)
		return ITEM_SLOT_PDA
	if(item == l_ear)
		return ITEM_SLOT_EAR_LEFT
	if(item == r_ear)
		return ITEM_SLOT_EAR_RIGHT
	if(item == glasses)
		return ITEM_SLOT_EYES
	if(item == gloves)
		return ITEM_SLOT_GLOVES
	if(item == head)
		return ITEM_SLOT_HEAD
	if(item == shoes)
		return ITEM_SLOT_FEET
	if(item == wear_suit)
		return ITEM_SLOT_CLOTH_OUTER
	if(item == w_uniform)
		return ITEM_SLOT_CLOTH_INNER
	if(item == l_store)
		return ITEM_SLOT_POCKET_LEFT
	if(item == r_store)
		return ITEM_SLOT_POCKET_RIGHT
	if(item == s_store)
		return ITEM_SLOT_SUITSTORE
	return NONE


/mob/living/carbon/human/get_all_slots()
	. = get_head_slots() | get_body_slots()


/mob/living/carbon/human/proc/get_body_slots()
	return list(
		l_hand,
		r_hand,
		back,
		s_store,
		handcuffed,
		legcuffed,
		wear_suit,
		gloves,
		shoes,
		belt,
		wear_id,
		wear_pda,
		l_store,
		r_store,
		w_uniform
		)


/mob/living/carbon/human/proc/get_head_slots()
	return list(
		head,
		wear_mask,
		glasses,
		r_ear,
		l_ear,
		)


/mob/living/carbon/human/proc/equipOutfit(outfit, visualsOnly = FALSE)
	var/datum/outfit/O = null

	if(ispath(outfit))
		O = new outfit
	else
		O = outfit
		if(!istype(O))
			return 0
	if(!O)
		return 0

	return O.equip(src, visualsOnly)


//delete all equipment without dropping anything
/mob/living/carbon/human/proc/delete_equipment()
	for(var/slot in get_all_slots())//order matters, dependant slots go first
		qdel(slot)


/mob/living/carbon/human/get_equipped_items(include_pockets = FALSE, include_hands = FALSE)
	var/list/items = ..()
	if(belt)
		items += belt
	if(l_ear)
		items += l_ear
	if(r_ear)
		items += r_ear
	if(glasses)
		items += glasses
	if(gloves)
		items += gloves
	if(neck)
		items += neck
	if(shoes)
		items += shoes
	if(wear_id)
		items += wear_id
	if(wear_pda)
		items += wear_pda
	if(w_uniform)
		items += w_uniform
	if(include_pockets)
		if(l_store)
			items += l_store
		if(r_store)
			items += r_store
		if(s_store)
			items += s_store
	return items


/mob/living/carbon/human/get_equipped_slots(include_pockets = FALSE, include_hands = FALSE)
	. = ..()
	if(belt)
		. |= ITEM_SLOT_BELT
	if(l_ear)
		. |= ITEM_SLOT_EAR_LEFT
	if(r_ear)
		. |= ITEM_SLOT_EAR_RIGHT
	if(glasses)
		. |= ITEM_SLOT_EYES
	if(gloves)
		. |= ITEM_SLOT_GLOVES
	if(neck)
		. |= ITEM_SLOT_NECK
	if(shoes)
		. |= ITEM_SLOT_FEET
	if(wear_id)
		. |= ITEM_SLOT_ID
	if(wear_pda)
		. |= ITEM_SLOT_PDA
	if(w_uniform)
		. |= ITEM_SLOT_CLOTH_INNER
	if(include_pockets)
		if(r_store)
			. |= ITEM_SLOT_POCKET_RIGHT
		if(l_store)
			. |= ITEM_SLOT_POCKET_LEFT
		if(s_store)
			. |= ITEM_SLOT_SUITSTORE


/mob/living/carbon/human/equipped_speed_mods()
	. = ..()
	for(var/obj/item/thing as anything in get_equipped_items())
		if(!(thing.item_flags & IGNORE_SLOWDOWN))
			. += thing.slowdown


/// Returns if the carbon is wearing shock proof gloves
/mob/living/carbon/human/proc/wearing_shock_proof_gloves()
	return gloves?.siemens_coefficient == 0

