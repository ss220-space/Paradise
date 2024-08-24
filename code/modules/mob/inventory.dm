/**
 * Determines if mob has and can use his hands like a human
 */
/mob/proc/real_human_being()
	return FALSE


/**
 * This proc is called whenever someone clicks an inventory UI slot.
 */
/mob/proc/attack_ui(slot, params)
	var/obj/item/hand_item = get_active_hand()

	if(istype(hand_item))
		if(equip_to_slot_if_possible(hand_item, slot))
			return TRUE

	if(!hand_item)
		// Activate the item
		var/obj/item/target_item = get_item_by_slot(slot)
		if(istype(target_item))
			var/list/modifiers = params2list(params)
			target_item.attack_hand(src, modifiers)

	return FALSE


/**
 * This proc is called whenever mob's client presses 'equip_held_object' hotkey
 */
/mob/verb/quick_equip()
	set name = "quick-equip"
	set hidden = TRUE

	DEFAULT_QUEUE_OR_CALL_VERB(VERB_CALLBACK(src, PROC_REF(run_quick_equip)))


/**
 * Proc extender of [/mob/verb/quick_equip] used to make the verb queuable if the server is overloaded
 */
/mob/proc/run_quick_equip()
	var/obj/item/I = get_active_hand()
	if(!I)
		if(pulling && isliving(src))
			var/mob/living/grabber = src
			if(!isnull(grabber.pull_hand) && grabber.pull_hand != PULL_WITHOUT_HANDS)
				if(next_move <= world.time && grabber.hand == grabber.pull_hand && grabber.on_grab_quick_equip(pulling, grabber.pull_hand))
					grabber.changeNext_move(grabber.grab_state > GRAB_PASSIVE ? CLICK_CD_GRABBING : CLICK_CD_PULLING)
				return
		to_chat(src, span_warning("Вы ничего не держите в руке!"))
		return

	if(!QDELETED(I) && I.user_can_equip(src))
		I.equip_to_best_slot(src)


/**
* Puts item into an appropriate inventory slot. Doesn't matter if a mob type doesn't have a slot.
*
* Arguments:
* * 'force' - set to `TRUE` if you want to ignore equip delay and clothing obscuration.
* * 'drop_on_fail' - set to `TRUE` if item should be dropped on equip fail.
* * 'qdel_on_fail' - set to `TRUE` if item should be deleted on equip fail.
* * 'silent' - to stop warning if item has 'equip_delay_self'
*/
/mob/proc/equip_to_appropriate_slot(obj/item/I, force = FALSE, drop_on_fail = FALSE, qdel_on_fail = FALSE, silent = FALSE)
	if(!istype(I))
		return FALSE

	if(I.equip_delay_self > 0)
		if(!silent)
			to_chat(src, span_warning("Вы должны экипировать [I] вручную!"))
		return FALSE

	var/list/priority_list = list(
		ITEM_SLOT_BACK, ITEM_SLOT_PDA, ITEM_SLOT_ID,
		ITEM_SLOT_CLOTH_INNER, ITEM_SLOT_CLOTH_OUTER, ITEM_SLOT_MASK,
		ITEM_SLOT_NECK, ITEM_SLOT_EYES, ITEM_SLOT_EAR_LEFT,
		ITEM_SLOT_EAR_RIGHT, ITEM_SLOT_HEAD, ITEM_SLOT_BELT,
		ITEM_SLOT_SUITSTORE, ITEM_SLOT_ACCESSORY, ITEM_SLOT_GLOVES,
		ITEM_SLOT_FEET, ITEM_SLOT_POCKET_LEFT, ITEM_SLOT_POCKET_RIGHT,
	)

	for(var/slot in priority_list)
		if(equip_to_slot_if_possible(I, slot, FALSE, FALSE, force, force, force, TRUE))
			return TRUE

	if(drop_on_fail)
		if(I in get_equipped_items(include_pockets = TRUE, include_hands = TRUE))
			drop_item_ground(I)
		else
			I.forceMove(drop_location())
		return FALSE

	if(qdel_on_fail)
		if(I in get_equipped_items(include_pockets = TRUE, include_hands = TRUE))
			temporarily_remove_item_from_inventory(I, force = TRUE)
		qdel(I)

	return FALSE


/**
 * Equipping passed item `I` in any slot of passed list by order
 */
/mob/proc/equip_in_one_of_slots(obj/item/I, list/slots, qdel_on_fail = FALSE)
	for(var/slot in slots)
		if(equip_to_slot_if_possible(I, slots[slot]))
			return slot

	if(qdel_on_fail)
		qdel(I)

	return null


/**
 * Just another helper. Puts item in one of the hands if they are empty.
 */
/mob/proc/put_in_any_hand_if_possible(obj/item/I, drop_on_fail = FALSE, qdel_on_fail = FALSE, ignore_anim = TRUE)
	if(put_in_active_hand(I, ignore_anim = ignore_anim))
		return TRUE
	else if(put_in_inactive_hand(I, ignore_anim = ignore_anim))
		return TRUE

	if(drop_on_fail)
		if(I in get_equipped_items(include_pockets = TRUE, include_hands = TRUE))
			drop_item_ground(I)
		else
			I.forceMove(drop_location())
		return FALSE

	if(qdel_on_fail)
		if(I in get_equipped_items(include_pockets = TRUE, include_hands = TRUE))
			temporarily_remove_item_from_inventory(I, force = TRUE)
		qdel(I)

	return FALSE


/**
 * Convinience proc. Collects crap that fails to equip either onto the mob's back, or drops it.
 * Used in job equipping so shit doesn't pile up at the start loc.
 */
/mob/proc/equip_or_collect(obj/item/I, slot)
	if(QDELETED(I))
		return
	if(I.mob_can_equip(src, slot, disable_warning = TRUE, bypass_equip_delay_self = TRUE, bypass_obscured = TRUE, bypass_incapacitated = TRUE))
		//Mob can equip.  Equip it.
		equip_to_slot(I, slot, initial = TRUE)
	else
		//Mob can't equip it.  Put it their backpack or toss it on the floor
		if(isstorage(back))
			//Now, B represents a container we can insert I into.
			var/obj/item/storage/backpack = back
			if(backpack.can_be_inserted(I, stop_messages = TRUE))
				backpack.handle_item_insertion(I, prevent_warning = TRUE)
				return
		var/turf/T = get_turf(src)
		if(istype(T))
			I.forceMove(T)


/**
 * This is just a commonly used configuration for the equip_to_slot_if_possible() proc.
 * Used to equip people when the rounds starts and when events happen and such.
 */
/mob/proc/equip_to_slot_or_del(obj/item/I, slot)
	return equip_to_slot_if_possible(I, slot, qdel_on_fail = TRUE, bypass_equip_delay_self = TRUE, bypass_obscured = TRUE, bypass_incapacitated = TRUE, disable_warning = TRUE, initial = TRUE)


/**
 * Mob tries to equip an item to a passed slot.
 * This is a SAFE proc. Use this instead of [equip_to_slot()]!
 *
 * * 'qdel_on_fail' - set to `TRUE` to have it delete `I` if it fails to equip
 * * 'disable_warning' - set to `TRUE` if you want to disable the 'you are unable to equip that' warning.
 * * 'bypass_equip_delay_self' - set to `TRUE` if you want to prevent item equipment delay
 * * 'bypass_obscured' - set `TRUE` if you want to ignore clothing obscuration
 * * 'initial' - used to indicate whether our items is initial equipment (job datums etc) or just a player doing it
 */
/mob/proc/equip_to_slot_if_possible(obj/item/I, slot, drop_on_fail = FALSE, qdel_on_fail = FALSE, bypass_equip_delay_self = FALSE, bypass_obscured = FALSE, bypass_incapacitated = FALSE, disable_warning = FALSE, initial = FALSE)
	if(!istype(I) || QDELETED(I)) //This qdeleted is to prevent stupid behavior with things that qdel during init
		return FALSE

	if(!I.mob_can_equip(src, slot, disable_warning, bypass_equip_delay_self, bypass_obscured, bypass_incapacitated))
		if(drop_on_fail)
			if(I in get_equipped_items(include_pockets = TRUE, include_hands = TRUE))
				drop_item_ground(I)
			else
				I.forceMove(drop_location())
			return FALSE

		if(qdel_on_fail)
			if(I in get_equipped_items(include_pockets = TRUE, include_hands = TRUE))
				temporarily_remove_item_from_inventory(I, force = TRUE)
			qdel(I)

		return FALSE

	equip_to_slot(I, slot, initial)	//This proc should not ever fail.
	return TRUE


/**
 * This is an UNSAFE proc. It merely handles the actual job of equipping.
 * All the checks on whether you can or can't eqip need to be done before! Use mob_can_equip() for that task.
 * In most cases you will want to use [equip_to_slot_if_possible()]
 */
/mob/proc/equip_to_slot(obj/item/I, slot, initial)
	return


/**
 * Returns if a certain item can be equipped to a certain slot.
 * Always call [obj/item/mob_can_equip()] instead of this proc.
 */
/mob/proc/can_equip(obj/item/I, slot, disable_warning = FALSE, bypass_equip_delay_self = FALSE, bypass_obscured = FALSE, bypass_incapacitated = FALSE)
	return FALSE


/**
 * Returns item if its in mob's left or right hand
 */
/mob/proc/is_in_hands(obj/item/I)
	if(I == l_hand)
		return l_hand
	if(I == r_hand)
		return r_hand
	return null


/**
 * Returns `TRUE` if item is in mob's active hand
 */
/mob/proc/is_in_active_hand(obj/item/I)
	var/obj/item/item_to_test = get_active_hand()

	return item_to_test && item_to_test.is_equivalent(I)


/**
 * Returns `TRUE` if item is in mob's inactive hand
 */
/mob/proc/is_in_inactive_hand(obj/item/I)
	var/obj/item/item_to_test = get_inactive_hand()

	return item_to_test && item_to_test.is_equivalent(I)


/**
 * Check used for telekinesis grabs
 */
/obj/item/proc/is_equivalent(obj/item/I)
	return I == src


/**
 * Returns the thing in our active hand
 */
/mob/proc/get_active_hand()
	if(hand)
		return l_hand
	else
		return r_hand


/**
 * Returns the thing in our inactive hand
 */
/mob/proc/get_inactive_hand()
	if(hand)
		return r_hand
	else
		return l_hand


/**
 * Only external organs and only for humans
 */
/mob/proc/has_organ_for_slot(slot_flag)
	return FALSE


/**
 * Nonliving mobs don't have hands
 */
/mob/proc/put_in_hand_check(obj/item/I, hand_id)
	return FALSE


/**
 * Specal proc for special mobs that use "hands" in weird ways.
 */
/mob/proc/special_hands_drop_action()
	return


/**
 * DO NO USE THIS PROC, there are plenty of helpers below: put_in_l_hand, put_in_active_hand, put_in_hands etc.
 * Puts an item into hand by `hand_id` (ITEM_SLOT_HAND_LEFT / ITEM_SLOT_HAND_RIGHT) and calls all necessary triggers/updates.
 *
 * Returns `TRUE` on success.
 */
/mob/proc/put_in_hand(obj/item/I, hand_id, force = FALSE, ignore_anim = TRUE, silent = FALSE)

	// Its always 'TRUE' if there is no item, since we are using helpers with this proc in 'if()' statements
	if(!I)
		return TRUE

	if(QDELING(I))
		return FALSE

	if(!put_in_hand_check(I, hand_id) && !force)
		return FALSE

	if(!ignore_anim)
		I.do_pickup_animation(src)

	var/hand_item
	if(hand_id == ITEM_SLOT_HAND_LEFT)
		hand_item = l_hand
	else if(hand_id == ITEM_SLOT_HAND_RIGHT)
		hand_item = r_hand
	if(hand_item)
		drop_item_ground(hand_item, force = TRUE, silent = silent)

	I.pulledby?.stop_pulling()
	I.forceMove(src)
	I.pixel_x = I.base_pixel_x
	I.pixel_y = I.base_pixel_y

	if(hand_id == ITEM_SLOT_HAND_LEFT)
		l_hand = I
	else if(hand_id == ITEM_SLOT_HAND_RIGHT)
		r_hand = I

	// Equip failed / item qdeled / loc changed
	if(!I.equipped(src, hand_id, silent) || QDELETED(I) || I.loc != src)
		if(hand_id == ITEM_SLOT_HAND_LEFT)
			l_hand = null
		else if(hand_id == ITEM_SLOT_HAND_RIGHT)
			r_hand = null
		return FALSE

	if(hand_id == ITEM_SLOT_HAND_LEFT)
		update_inv_l_hand()
	else if(hand_id == ITEM_SLOT_HAND_RIGHT)
		update_inv_r_hand()

	I.layer = ABOVE_HUD_LAYER
	SET_PLANE_EXPLICIT(I, ABOVE_HUD_PLANE, src)

	return TRUE


/**
 * Puts item into `l_hand` if possible and calls all necessary triggers/updates. Returns `TRUE` on success.
 */
/mob/proc/put_in_l_hand(obj/item/I, force = FALSE, ignore_anim = TRUE, silent = FALSE)
	return put_in_hand(I, ITEM_SLOT_HAND_LEFT, force, ignore_anim, silent)


/**
 * Puts item into `r_hand` if possible and calls all necessary triggers/updates. Returns `TRUE` on success.
 */
/mob/proc/put_in_r_hand(obj/item/I, force = FALSE, ignore_anim = TRUE, silent = FALSE)
	return put_in_hand(I, ITEM_SLOT_HAND_RIGHT, force, ignore_anim, silent)


/**
 * Puts item into active hand if possible. Returns `TRUE` on success.
 */
/mob/proc/put_in_active_hand(obj/item/I, force = FALSE, ignore_anim = TRUE, silent = FALSE)
	if(hand)
		return put_in_l_hand(I, force, ignore_anim, silent)
	else
		return put_in_r_hand(I, force, ignore_anim, silent)


/**
 * Puts item into inactive hand if possible. Returns `TRUE` on success.
 */
/mob/proc/put_in_inactive_hand(obj/item/I, force = FALSE, ignore_anim = TRUE, silent = FALSE)
	if(hand)
		return put_in_r_hand(I, force, ignore_anim, silent)
	else
		return put_in_l_hand(I, force, ignore_anim, silent)


/**
 * Put item in our active hand if possible. Failing that it tries our inactive hand. Returns `TRUE` on success.
 * If both fail it drops item on the floor and returns `FALSE`
 * Just puts stuff on the floor for most mobs, since all mobs have hands but putting stuff in the AI/corgi/ghost hand is VERY BAD.
 *
 * Arguments
 * * 'force' overrides TRAIT_NODROP and clothing obscuration.
 * * 'qdel_on_fail' qdels item if failed to pick in both hands.
 * * 'merge_stacks' set to `TRUE` to allow stack auto-merging even when both hands are full.
 * * 'ignore_anim' set to `TRUE` to prevent pick up animation.
 * * 'silent' set to `TRUE` to stop pick up sounds.
 */
/mob/proc/put_in_hands(obj/item/I, force = FALSE, qdel_on_fail = FALSE, merge_stacks = TRUE, ignore_anim = TRUE, silent = FALSE)
	return FALSE


/**
 * Drops item in left hand.
 */
/mob/proc/drop_l_hand(force = FALSE, silent = FALSE)
	return drop_item_ground(l_hand, force, silent = silent)


/**
 * Drops item in right hand.
 */
/mob/proc/drop_r_hand(force = FALSE, silent = FALSE)
	return drop_item_ground(r_hand, force, silent = silent)


/**
 * Drops item in active hand.
 */
/mob/proc/drop_from_active_hand(force = FALSE, silent = FALSE)
	if(hand)
		return drop_l_hand(force, silent)
	else
		return drop_r_hand(force, silent)

/**
 * Drops item in inactive hand.
 */
/mob/proc/drop_from_inactive_hand(force = FALSE, silent = FALSE)
	if(hand)
		return drop_r_hand(force, silent)
	else
		return drop_l_hand(force, silent)


/**
 * Drops items in both hands.
 */
/mob/proc/drop_from_hands(force = FALSE, silent = FALSE)
	drop_l_hand(force, silent)
	drop_r_hand(force, silent)


/**
 * Item will be dropped on turf below user, then forceMoved to `newloc`.
 * Returns `TRUE` if item is successfully transfered.
 * Returns `FALSE` if `newloc` is not specified or if its `null`.
 * Returns `FALSE` if item can not be dropped due to TRAIT_NODROP or if item slot is obscured.
 * Thic proc is required if you expect transfer animation to be properly played,
 * since item loc should be turf only to properly register image.
 *
 * Arguments:
 * * 'force' overrides TRAIT_NODROP and clothing obscuration.
 * * 'invdrop' prevents stuff in belt/id/pockets/PDA slots from dropping if item was in jumpsuit slot. Only set to `FALSE` if it's going to be immediately replaced.
 * * 'silent' set to `TRUE` if you want to disable warning messages.
 */
/mob/proc/drop_transfer_item_to_loc(obj/item/I, atom/newloc, force = FALSE, invdrop = TRUE, silent = FALSE)
	if(isnull(newloc))
		return FALSE

	. = do_unEquip(I, force, drop_location(), FALSE, invdrop, silent)

	if(!. || !I)
		return

	I.do_pickup_animation(newloc)
	I.forceMove(newloc)


/**
 * Used to drop an item (if it exists) to the ground.
 * Returns `TRUE` if item is successfully dropped.
 * Returns `FALSE` if item can not be dropped due to TRAIT_NODROP or if item slot is obscured.
 * If item can be dropped, it will be forceMove()'d to the ground and the turf's Entered() will be called.
 *
 * Arguments:
 * * 'force' overrides TRAIT_NODROP and clothing obscuration.
 * * 'invdrop' prevents stuff in belt/id/pockets/PDA slots from dropping if item was in jumpsuit slot. Only set to `FALSE` if it's going to be immediately replaced.
 * * 'silent' set to `TRUE` if you want to disable warning messages.
 * * 'ignore_pixel_shift' set to `TRUE` if you want to prevent item's visual position randomization.
*/
/mob/proc/drop_item_ground(obj/item/I, force = FALSE, invdrop = TRUE, silent = FALSE, ignore_pixel_shift = FALSE)

	. = do_unEquip(I, force, drop_location(), FALSE, invdrop, silent)

	if(!. || !I) //ensure the item exists and that it was dropped properly.
		return

	var/shift_max = world.icon_size / 2
	var/shift_limit_x = initial(pixel_x) + shift_max
	var/shift_limit_y = initial(pixel_y) + shift_max
	var/shift_x
	var/shift_y

	if(ignore_pixel_shift || (I.item_flags & NO_PIXEL_RANDOM_DROP))
		shift_x = clamp(pixel_x, -shift_limit_x, shift_limit_x)
		shift_y = clamp(pixel_y, -shift_limit_y, shift_limit_y)
	else
		shift_x = clamp(pixel_x + rand(-6, 6), -shift_limit_x, shift_limit_x)
		shift_y = clamp(pixel_y + rand(-6, 6), -shift_limit_y, shift_limit_y)

	I.pixel_x = shift_x
	I.pixel_y = shift_y
	I.do_drop_animation(src)


/**
 * For when the item will be immediately placed in a loc other than the ground.
 * If `newloc` is not a turf and you expect animation to register, use [drop_transfer_item_to_loc()] instead.
 *
 * Arguments:
 * * 'force' overrides TRAIT_NODROP and clothing obscuration.
 * * 'invdrop' prevents stuff in belt/id/pockets/PDA slots from dropping if item was in jumpsuit slot. Only set to `FALSE` if it's going to be immediately replaced.
 * * 'silent' set to `TRUE` if you want to disable warning messages.
 */
/mob/proc/transfer_item_to_loc(obj/item/I, atom/newloc, force = FALSE, invdrop = TRUE, silent = FALSE)
	. = do_unEquip(I, force, newloc, FALSE, invdrop, silent)
	I.do_drop_animation(src)


/**
 * Visibly unequips `I` but item is not moved and remains in `src`.
 * Item MUST BE FORCEMOVE'D OR QDEL'D afterwards.
 *
 * Arguments:
 * * 'force' overrides TRAIT_NODROP and clothing obscuration.
 * * 'invdrop' prevents stuff in belt/id/pockets/PDA slots from dropping if item was in jumpsuit slot. Only set to `FALSE` if it's going to be immediately replaced.
 * * 'silent' set to `TRUE` if you want to disable warning messages.
 */
/mob/proc/temporarily_remove_item_from_inventory(obj/item/I, force = FALSE, invdrop = TRUE, silent = TRUE)
	. = do_unEquip(I, force, null, TRUE, invdrop, silent)


/**
 * DO NOT CALL THIS PROC.
 * Use one of the 4 helper above.
 * You may override it, but do not modify the args.
 */
/mob/proc/do_unEquip(obj/item/I, force = FALSE, atom/newloc, no_move = FALSE, invdrop = TRUE, silent = FALSE)
	// 'force' overrides TRAIT_NODROP and clothing obscuration
	// 'no_move' is used when item is just gonna be immediately moved afterwards
	// 'invdrop' prevents stuff in belt/id/pockets/PDA slots from dropping when item in jumsuit slot was removed
	PROTECTED_PROC(TRUE)

	// If there's nothing to drop, the drop is automatically succesfull
	if(!I)
		return TRUE

	if(!can_unEquip(I, force, silent, newloc, no_move, invdrop))
		return FALSE

	var/slot = get_slot_by_item(I)
	//if we actually unequipped an item
	var/not_handled = FALSE

	if(I == r_hand)
		r_hand = null
		update_inv_r_hand()
	else if(I == l_hand)
		l_hand = null
		update_inv_l_hand()
	else if(I in tkgrabbed_objects)
		var/obj/item/tk_grab/tkgrab = tkgrabbed_objects[I]
		drop_item_ground(tkgrab, force)
	else
		not_handled = TRUE

	if(I)
		if(client)
			client.screen -= I
		I.layer = initial(I.layer)
		SET_PLANE_EXPLICIT(I, initial(I.plane), newloc)
		if(!no_move && !(I.item_flags & DROPDEL)) // Item may be moved/qdel'd immedietely, don't bother moving it
			if(isnull(newloc))
				I.move_to_null_space()
			else
				I.forceMove(newloc)
		I.dropped(src, slot, silent)

	SEND_SIGNAL(I, COMSIG_ITEM_POST_UNEQUIP, force, newloc, no_move, invdrop, silent)
	if(!not_handled)
		update_equipment_speed_mods()
	return TRUE


/**
 * General checks for do_unEquip proc: TRAIT_NODROP, obscurity and component blocking possibility.
 * Set 'silent' to `FALSE` if you want to get warning messages.
 */
/mob/proc/can_unEquip(obj/item/I, force = FALSE, silent = TRUE, atom/newloc, no_move = FALSE, invdrop = TRUE)

	// If there's nothing to unequip we can do it
	if(!I)
		return TRUE

	// TRAIT_NODROP
	if(!force && HAS_TRAIT(I, TRAIT_NODROP))
		if(!silent && !(I.item_flags & ABSTRACT) && !isrobot(src))
			to_chat(src, span_warning("Неведомая сила не позволяет Вам снять [I.name]."))
		return FALSE

	// Checking clothing obscuration
	if(!force && (get_slot_by_item(I) & check_obscured_slots()))
		if(!silent)
			to_chat(src, span_warning("Вы не можете снять [I.name], слот закрыт другой одеждой."))
		return FALSE

	//Possible component blocking
	if((SEND_SIGNAL(I, COMSIG_ITEM_PRE_UNEQUIP, force, newloc, no_move, invdrop, silent) & COMPONENT_ITEM_BLOCK_UNEQUIP) && !force)
		return FALSE

	return TRUE


/**
 * Collects flags_inv bitflags from all equipped items and returns slots considered as obscure.
 *
 * Arguments:
 * * check_transparent - If `TRUE` bitflags from var/flags_inv_transparent will be considered, works like a toggle (^=) for var/flags_inv.
 * Used in overlay updates to properly cover or uncover certain zones.
 */
/mob/proc/check_obscured_slots(check_transparent)
	. = NONE


/**
 * For wheter we want to check if mob manipulates an item in hands/backpack etc,
 * and not actually wearing it in any REAL equipment slot.
 */
/mob/proc/is_general_slot(slot)
	return (slot & (ITEM_SLOT_HANDS|ITEM_SLOT_POCKETS|ITEM_SLOT_BACKPACK|ITEM_SLOT_HANDCUFFED|ITEM_SLOT_LEGCUFFED|ITEM_SLOT_ACCESSORY))


/// Collects all items in possibly equipped slots.
/mob/proc/get_equipped_items(include_pockets = FALSE, include_hands = FALSE)
	var/list/items = list()
	if(back)
		items += back
	if(wear_mask)
		items += wear_mask
	if(include_hands)
		if(l_hand)
			items += l_hand
		if(r_hand)
			items += r_hand
	return items


/// Same as above but we get slots, not items.
/mob/proc/get_equipped_slots(include_pockets = FALSE, include_hands = FALSE)
	. = NONE
	if(back)
		. |= ITEM_SLOT_BACK
	if(wear_mask)
		. |= ITEM_SLOT_MASK
	if(include_hands)
		if(l_hand)
			. |= ITEM_SLOT_HAND_LEFT
		if(r_hand)
			. |= ITEM_SLOT_HAND_RIGHT


/mob/proc/get_all_slots()
	return list(wear_mask, back, l_hand, r_hand)


/mob/proc/get_id_card()
	for(var/obj/item/I in get_access_locations())
		if(I.GetID())
			return I.GetID()


/mob/proc/get_all_id_cards()
	var/list/obj/item/card/id/id_cards = list()
	for(var/obj/item/I in get_access_locations())
		if(I.GetID())
			id_cards += I.GetID()
	return id_cards


/mob/proc/get_item_by_slot(slot_flag)
	switch(slot_flag)
		if(ITEM_SLOT_MASK)
			return wear_mask
		if(ITEM_SLOT_BACK)
			return back
		if(ITEM_SLOT_HAND_LEFT)
			return l_hand
		if(ITEM_SLOT_HAND_RIGHT)
			return r_hand
	return null


/mob/proc/get_slot_by_item(item)
	if(item == back)
		return ITEM_SLOT_BACK
	if(item == wear_mask)
		return ITEM_SLOT_MASK
	if(item == l_hand)
		return ITEM_SLOT_HAND_LEFT
	if(item == r_hand)
		return ITEM_SLOT_HAND_RIGHT
	return NONE


//search for a path in inventory and storage items in that inventory (backpack, belt, etc) and return it. Not recursive, so doesnt search storage in storage
/mob/proc/find_item(path)
	for(var/obj/item/I in contents)
		if(isstorage(I))
			for(var/obj/item/SI in I.contents)
				if(istype(SI, path))
					return SI
		else if(istype(I, path))
			return I


/mob/proc/update_equipment_speed_mods()
	var/speedies = equipped_speed_mods()
	if(speedies)
		add_or_update_variable_movespeed_modifier(/datum/movespeed_modifier/equipment_speedmod, multiplicative_slowdown = speedies)
	else
		remove_movespeed_modifier(/datum/movespeed_modifier/equipment_speedmod)


/// Gets the combined speed modification of all worn items
/// Except base mob type doesnt really wear items
/mob/proc/equipped_speed_mods()
	. = 0
	for(var/obj/item/thing in list(get_active_hand(), get_inactive_hand()))
		if(thing && (thing.item_flags & SLOWS_WHILE_IN_HAND) && !(thing.item_flags & IGNORE_SLOWDOWN))
			. += thing.slowdown


/mob/proc/covered_with_thick_material(check_zone, full_body_check = FALSE)
	return FALSE


/mob/proc/is_type_in_hands(typepath)
	if(istype(l_hand,typepath))
		return l_hand
	if(istype(r_hand,typepath))
		return r_hand
	return null

