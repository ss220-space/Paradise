/**
 * Determines if mob has and can use his hands like a human
 */
/mob/living/carbon/human/real_human_being()
	return TRUE


/mob/living/carbon/human/proc/is_type_in_hands(typepath)
	if(istype(l_hand,typepath))
		return l_hand
	if(istype(r_hand,typepath))
		return r_hand
	return FALSE


/mob/living/carbon/human/has_organ_for_slot(slot)
	switch(slot)
		if(SLOT_HUD_IN_BACKPACK, SLOT_HUD_WEAR_PDA, SLOT_HUD_WEAR_ID, SLOT_HUD_TIE)
			return TRUE
		if(SLOT_HUD_BACK, SLOT_HUD_BELT, SLOT_HUD_OUTER_SUIT, SLOT_HUD_JUMPSUIT, SLOT_HUD_LEFT_STORE, SLOT_HUD_RIGHT_STORE, SLOT_HUD_SUIT_STORE, SLOT_HUD_NECK)
			return get_organ(BODY_ZONE_CHEST)
		if(SLOT_HUD_HEAD, SLOT_HUD_WEAR_MASK, SLOT_HUD_LEFT_EAR, SLOT_HUD_RIGHT_EAR, SLOT_HUD_GLASSES)
			return get_organ(BODY_ZONE_HEAD)
		if(SLOT_HUD_HANDCUFFED, SLOT_HUD_GLOVES)
			return num_hands >= 2
		if(SLOT_HUD_LEGCUFFED, SLOT_HUD_SHOES)
			return num_legs >= 2
		if(SLOT_HUD_LEFT_HAND)
			return get_organ(BODY_ZONE_PRECISE_L_HAND)
		if(SLOT_HUD_RIGHT_HAND)
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
/mob/living/carbon/human/wear_mask_update(obj/item/clothing/mask, toggle_off = TRUE)
	if(istype(mask) && mask.tint || initial(mask.tint))
		update_tint()

	if((mask.flags & (BLOCKHAIR|BLOCKHEADHAIR|BLOCKFACIALHAIR)) || (initial(mask.flags) & (BLOCKHAIR|BLOCKHEADHAIR|BLOCKFACIALHAIR)))
		update_hair()	//rebuild hair
		update_fhair()
		update_head_accessory()

	if(toggle_off && internal && !get_organ_slot(INTERNAL_ORGAN_BREATHING_TUBE))
		internal = null
		update_action_buttons_icon()

	if((mask.flags_inv & HIDEGLASSES) || (initial(mask.flags_inv) & HIDEGLASSES))
		update_inv_glasses()
	if((mask.flags_inv & HIDEHEADSETS) || (initial(mask.flags_inv) & HIDEHEADSETS))
		update_inv_ears()

	sec_hud_set_ID()
	update_inv_wear_mask()


/**
 * Handles stuff to update when a mob equips/unequips a headgear.
 */
/mob/living/carbon/human/update_head(obj/item/clothing/head/check_item, forced = FALSE)
	check_item = check_item || head
	if(!check_item)
		return

	if(forced || (check_item.flags & (BLOCKHAIR|BLOCKHEADHAIR|BLOCKFACIALHAIR)) || (initial(check_item.flags) & (BLOCKHAIR|BLOCKHEADHAIR|BLOCKFACIALHAIR)))
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

	if(forced || (check_item.flags_inv & HIDEHEADSETS) || (initial(check_item.flags_inv) & HIDEHEADSETS))
		update_inv_ears()
	if(forced || (check_item.flags_inv & HIDEMASK) || (initial(check_item.flags_inv) & HIDEMASK))
		update_inv_wear_mask()
	if(forced || (check_item.flags_inv & HIDEGLASSES) || (initial(check_item.flags_inv) & HIDEGLASSES))
		update_inv_glasses()

	sec_hud_set_ID()
	update_inv_head()


/**
 * Handles stuff to update when a mob equips/unequips a suit.
 */
/mob/living/carbon/human/wear_suit_update(obj/item/clothing/suit)
	if((suit.flags_inv & HIDEJUMPSUIT) || (initial(suit.flags_inv) & HIDEJUMPSUIT))
		update_inv_w_uniform()
	if((suit.flags_inv & HIDESHOES) || (initial(suit.flags_inv) & HIDESHOES))
		update_inv_shoes()
	if((suit.flags_inv & HIDEGLOVES) || (initial(suit.flags_inv) & HIDEGLOVES))
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
		return

	if(I == wear_suit)
		if(s_store && invdrop)
			drop_item_ground(s_store, force = TRUE) //It makes no sense for your suit storage to stay on you if you drop your suit.
		wear_suit = null
		if(!QDELETED(src))
			wear_suit_update(I)

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
			update_head(I)

	else if(I == r_ear)
		r_ear = null
		if(!QDELETED(src))
			if(I.slot_flags & SLOT_FLAG_TWOEARS)
				qdel(l_ear)
				l_ear = null
			update_inv_ears()

	else if(I == l_ear)
		l_ear = null
		if(!QDELETED(src))
			if(I.slot_flags & SLOT_FLAG_TWOEARS)
				qdel(r_ear)
				r_ear = null
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

	update_equipment_speed_mods()


/mob/living/carbon/human/can_equip(obj/item/I, slot, disable_warning = FALSE, bypass_equip_delay_self = FALSE, bypass_obscured = FALSE)
	return dna.species.can_equip(I, slot, disable_warning, src, disable_warning, bypass_equip_delay_self, bypass_obscured)


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
	I.plane = ABOVE_HUD_PLANE

	switch(slot)
		if(SLOT_HUD_BACK)
			back = I
			update_inv_back()

		if(SLOT_HUD_WEAR_MASK)
			wear_mask = I
			wear_mask_update(I, toggle_off = FALSE)

		if(SLOT_HUD_NECK)
			neck = I
			update_inv_neck()

		if(SLOT_HUD_HANDCUFFED)
			handcuffed = I
			update_handcuffed_status()

		if(SLOT_HUD_LEGCUFFED)
			legcuffed = I
			update_legcuffed_status()

		if(SLOT_HUD_LEFT_HAND)
			l_hand = I
			update_inv_l_hand()

		if(SLOT_HUD_RIGHT_HAND)
			r_hand = I
			update_inv_r_hand()

		if(SLOT_HUD_BELT)
			belt = I
			update_inv_belt()

		if(SLOT_HUD_WEAR_ID)
			wear_id = I
			if(hud_list.len)
				sec_hud_set_ID()
			update_inv_wear_id()

		if(SLOT_HUD_WEAR_PDA)
			wear_pda = I
			update_inv_wear_pda()

		if(SLOT_HUD_LEFT_EAR)
			l_ear = I
			if(l_ear.slot_flags & SLOT_FLAG_TWOEARS)
				var/obj/item/offear = new I.type(src)
				r_ear = offear
				offear.layer = ABOVE_HUD_LAYER
				offear.plane = ABOVE_HUD_PLANE
			update_inv_ears()

		if(SLOT_HUD_RIGHT_EAR)
			r_ear = I
			if(r_ear.slot_flags & SLOT_FLAG_TWOEARS)
				var/obj/item/offear = new I.type(src)
				l_ear = offear
				offear.layer = ABOVE_HUD_LAYER
				offear.plane = ABOVE_HUD_PLANE
			update_inv_ears()

		if(SLOT_HUD_GLASSES)
			glasses = I
			wear_glasses_update(I)

		if(SLOT_HUD_GLOVES)
			gloves = I
			update_inv_gloves()

		if(SLOT_HUD_HEAD)
			head = I
			update_head(I)

		if(SLOT_HUD_SHOES)
			shoes = I
			update_inv_shoes()

		if(SLOT_HUD_OUTER_SUIT)
			wear_suit = I
			wear_suit_update(I)

		if(SLOT_HUD_JUMPSUIT)
			w_uniform = I
			update_inv_w_uniform()

		if(SLOT_HUD_LEFT_STORE)
			l_store = I
			update_inv_pockets()

		if(SLOT_HUD_RIGHT_STORE)
			r_store = I
			update_inv_pockets()

		if(SLOT_HUD_SUIT_STORE)
			s_store = I
			update_inv_s_store()

		if(SLOT_HUD_IN_BACKPACK)
			if(istype(back, /obj/item/storage))
				if(get_active_hand() == I)
					temporarily_remove_item_from_inventory(I)
				I.forceMove(back)
			else
				I.forceMove(drop_location())

		if(SLOT_HUD_TIE)
			var/obj/item/clothing/under/uniform = w_uniform
			uniform.attackby(I, src)

		else
			to_chat(src, span_warning("You are trying to equip this item to an unsupported inventory slot. Report this to a coder!"))

	return I.equipped(src, slot, initial)


/**
 * Check for slot obscuration by suit or headgear
 */
/mob/living/carbon/human/proc/has_obscured_slot(slot)
	switch(slot)
		if(SLOT_HUD_JUMPSUIT)
			return wear_suit && (wear_suit.flags_inv & HIDEJUMPSUIT)
		if(SLOT_HUD_GLOVES)
			return wear_suit && (wear_suit.flags_inv & HIDEGLOVES)
		if(SLOT_HUD_SHOES)
			return wear_suit && (wear_suit.flags_inv & HIDESHOES)
		if(SLOT_HUD_WEAR_MASK)
			return head && (head.flags_inv & HIDEMASK)
		if(SLOT_HUD_GLASSES)
			return head && (head.flags_inv & HIDEGLASSES) || wear_mask && (wear_mask.flags_inv & HIDEGLASSES)
		if(SLOT_HUD_LEFT_EAR, SLOT_HUD_RIGHT_EAR)
			return head && (head.flags_inv & HIDEHEADSETS) || wear_mask && (wear_mask.flags_inv & HIDEHEADSETS)
		else
			return FALSE

/**
 * Returns the item currently in the slot
 */
/mob/living/carbon/human/get_item_by_slot(slot_id)
	switch(slot_id)
		if(SLOT_HUD_BACK)
			return back
		if(SLOT_HUD_WEAR_MASK)
			return wear_mask
		if(SLOT_HUD_NECK)
			return neck
		if(SLOT_HUD_HANDCUFFED)
			return handcuffed
		if(SLOT_HUD_LEGCUFFED)
			return legcuffed
		if(SLOT_HUD_LEFT_HAND)
			return l_hand
		if(SLOT_HUD_RIGHT_HAND)
			return r_hand
		if(SLOT_HUD_BELT)
			return belt
		if(SLOT_HUD_WEAR_ID)
			return wear_id
		if(SLOT_HUD_WEAR_PDA)
			return wear_pda
		if(SLOT_HUD_LEFT_EAR)
			return l_ear
		if(SLOT_HUD_RIGHT_EAR)
			return r_ear
		if(SLOT_HUD_GLASSES)
			return glasses
		if(SLOT_HUD_GLOVES)
			return gloves
		if(SLOT_HUD_HEAD)
			return head
		if(SLOT_HUD_SHOES)
			return shoes
		if(SLOT_HUD_OUTER_SUIT)
			return wear_suit
		if(SLOT_HUD_JUMPSUIT)
			return w_uniform
		if(SLOT_HUD_LEFT_STORE)
			return l_store
		if(SLOT_HUD_RIGHT_STORE)
			return r_store
		if(SLOT_HUD_SUIT_STORE)
			return s_store
	return null


/**
 * Returns the item current slot ID by passed item.
 * Returns `null` if slot is not found.
 */
/mob/living/carbon/human/get_slot_by_item(item)
	if(item == back)
		return SLOT_HUD_BACK
	if(item == wear_mask)
		return SLOT_HUD_WEAR_MASK
	if(item == neck)
		return SLOT_HUD_NECK
	if(item == handcuffed)
		return SLOT_HUD_HANDCUFFED
	if(item == legcuffed)
		return SLOT_HUD_LEGCUFFED
	if(item == l_hand)
		return SLOT_HUD_LEFT_HAND
	if(item == r_hand)
		return SLOT_HUD_RIGHT_HAND
	if(item == belt)
		return SLOT_HUD_BELT
	if(item == wear_id)
		return SLOT_HUD_WEAR_ID
	if(item == wear_pda)
		return SLOT_HUD_WEAR_PDA
	if(item == l_ear)
		return SLOT_HUD_LEFT_EAR
	if(item == r_ear)
		return SLOT_HUD_RIGHT_EAR
	if(item == glasses)
		return SLOT_HUD_GLASSES
	if(item == gloves)
		return SLOT_HUD_GLOVES
	if(item == head)
		return SLOT_HUD_HEAD
	if(item == shoes)
		return SLOT_HUD_SHOES
	if(item == wear_suit)
		return SLOT_HUD_OUTER_SUIT
	if(item == w_uniform)
		return SLOT_HUD_JUMPSUIT
	if(item == l_store)
		return SLOT_HUD_LEFT_STORE
	if(item == r_store)
		return SLOT_HUD_RIGHT_STORE
	if(item == s_store)
		return SLOT_HUD_SUIT_STORE
	return null


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


/**
 * Humans have their pickpocket gloves, so they get no message when stealing things
 */
/mob/living/carbon/human/stripPanelUnequip(obj/item/what, mob/who, where)
	var/is_silent = FALSE
	var/obj/item/clothing/gloves/G = gloves
	if(istype(G))
		is_silent = G.pickpocket

	..(what, who, where, silent = is_silent)


/**
 * Humans have their pickpocket gloves, so they get no message when stealing things
 */
/mob/living/carbon/human/stripPanelEquip(obj/item/what, mob/who, where)
	var/is_silent = FALSE
	var/obj/item/clothing/gloves/G = gloves
	if(istype(G))
		is_silent = G.pickpocket

	..(what, who, where, silent = is_silent)


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


/mob/living/carbon/human/equipped_speed_mods()
	. = ..()
	for(var/obj/item/thing as anything in get_equipped_items())
		if(!thing.is_speedslimepotioned)
			. += thing.slowdown

