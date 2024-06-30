/mob/living/carbon/swap_hand()
	var/obj/item/item_in_hand = get_active_hand()

	if(SEND_SIGNAL(src, COMSIG_MOB_SWAPPING_HANDS, item_in_hand) & COMPONENT_BLOCK_SWAP)
		to_chat(src, span_warning("Ваши руки заняты удержанием [item_in_hand]."))
		return FALSE

	hand = !hand
	update_hands_HUD()
	SEND_SIGNAL(src, COMSIG_MOB_SWAP_HANDS)
	return TRUE


/mob/living/carbon/activate_hand(selhand)
	if(selhand != hand)
		swap_hand()


/mob/living/carbon/resist_restraints()
	INVOKE_ASYNC(src, PROC_REF(resist_muzzle))
	var/obj/item/restraints
	if(wear_suit?.breakouttime)
		restraints = wear_suit
	else if(handcuffed)
		restraints = handcuffed
	else if(legcuffed)
		restraints = legcuffed
	if(restraints)
		cuff_resist(restraints)


/// Simple helper used to equip passed item to the predefined slots.
/mob/living/carbon/proc/apply_restraints(cuffs, slot_flag, qdel_on_fail = FALSE, silent = FALSE)
	if(!isitem(cuffs))
		CRASH("Wrong object ([cuffs]) passed as argument")
	switch(slot_flag)
		if(ITEM_SLOT_HANDCUFFED)
			return equip_to_slot_if_possible(cuffs, ITEM_SLOT_HANDCUFFED, qdel_on_fail = qdel_on_fail, disable_warning = silent, initial = silent)
		if(ITEM_SLOT_LEGCUFFED)
			return equip_to_slot_if_possible(cuffs, ITEM_SLOT_LEGCUFFED, qdel_on_fail = qdel_on_fail, disable_warning = silent, initial = silent)
		else
			CRASH("Wrong slot passed as argument")


/// Forcefully removes legcuffs and handcuffs.
/mob/living/carbon/proc/uncuff()
	if(handcuffed)
		drop_item_ground(handcuffed, TRUE)

	if(legcuffed)
		drop_item_ground(legcuffed, TRUE)


/// Modifies the handcuffed value if a different value is passed, returning FALSE otherwise.
/// The variable should only be changed through this proc.
/mob/living/carbon/proc/set_handcuffed(new_value)
	if(handcuffed == new_value)
		return FALSE
	. = handcuffed
	handcuffed = new_value
	if(.)
		if(!handcuffed)
			clear_alert(ALERT_HANDCUFFED)
			REMOVE_TRAIT(src, TRAIT_RESTRAINED, HANDCUFFED_TRAIT)
	else if(handcuffed)
		throw_alert(ALERT_HANDCUFFED, /atom/movable/screen/alert/restrained/handcuffed, new_master = handcuffed)
		ADD_TRAIT(src, TRAIT_RESTRAINED, HANDCUFFED_TRAIT)

	update_hands_HUD()
	update_inv_handcuffed()


/// Modifies the legcuffed value if a different value is passed, returning FALSE otherwise.
/// The variable should only be changed through this proc.
/mob/living/carbon/proc/set_legcuffed(new_value)
	if(legcuffed == new_value)
		return FALSE
	. = legcuffed
	legcuffed = new_value


/// Updates move intent, popup alert and human legcuffed overlay.
/mob/living/carbon/proc/update_legcuffed_status()
	if(legcuffed)
		throw_alert(ALERT_LEGCUFFED, /atom/movable/screen/alert/restrained/legcuffed, new_master = legcuffed)
		if(m_intent == MOVE_INTENT_RUN)
			toggle_move_intent()

	else
		clear_alert(ALERT_LEGCUFFED)
		if(m_intent == MOVE_INTENT_WALK)
			toggle_move_intent()

	update_inv_legcuffed()


/// General proc to resist passed item.
/mob/living/carbon/proc/cuff_resist(obj/item/I, cuff_break = FALSE)
	. = FALSE
	var/breakouttime = I.breakouttime
	if(cuff_break)
		breakouttime = 5 SECONDS	// very fast!
		visible_message(
			span_warning("[name] пыта[pluralize_ru(gender,"ет","ют")]ся сломать [I.name]!"),
			span_notice("Вы пытаетесь сломать [I.name]... (Процесс займёт 5 секунд и Вам нельзя двигаться.)"),
		)
		if(do_after(src, breakouttime, src, DEFAULT_DOAFTER_IGNORE|DA_IGNORE_HELD_ITEM))
			. = clear_cuffs(I, cuff_break)
		else
			to_chat(src, span_warning("Вам не удалось сломать [I.name]!"))
	else
		visible_message(
			span_warning("[name] пыта[pluralize_ru(gender,"ет","ют")]ся снять [I.name]!"),
			span_notice("Вы пытаетесь снять [I.name]... (Процесс займёт [breakouttime / 10] секунд и Вам нельзя двигаться.)"),
		)
		if(do_after(src, breakouttime, src, DEFAULT_DOAFTER_IGNORE|DA_IGNORE_HELD_ITEM))
			. = clear_cuffs(I, cuff_break)
		else
			to_chat(src, span_warning("Вам не удалось снять [I.name]!"))


/mob/living/carbon/proc/clear_cuffs(obj/item/I, cuff_break)
	if(!I.loc || buckled)
		return FALSE
	if(I != handcuffed && I != legcuffed && I != wear_suit)
		return FALSE
	visible_message(
		span_danger("[name] удалось [cuff_break ? "сломать" : "снять"] [I.name]!"),
		span_notice("Вы успешно [cuff_break ? "сломали" : "сняли"] [I.name]."),
	)
	if(cuff_break)
		qdel(I)
		return TRUE
	return drop_item_ground(I)


/mob/living/carbon/is_muzzled()
	return istype(wear_mask, /obj/item/clothing/mask/muzzle)


/mob/living/carbon/is_facehugged()
	return istype(wear_mask, /obj/item/clothing/mask/facehugger)


/mob/living/carbon/resist_muzzle()
	if(!istype(wear_mask, /obj/item/clothing/mask/muzzle))
		return
	var/obj/item/clothing/mask/muzzle/I = wear_mask
	var/time = I.resist_time
	if(!time)	//if it's 0, you can't get out of it
		to_chat(src, "[capitalize(I.name)] слишком хорошо зафиксирован!")
		return

	visible_message(
		span_warning("[name] грыз[pluralize_ru(gender,"ёт","ут")] [I.name], пытаясь освободиться!"),
		span_notice("Вы пытаетесь избавиться от [I.name]... (Это займет [time / 10] секунд и вам нельзя двигаться.)"),
	)

	if(!do_after(src, time, src, DEFAULT_DOAFTER_IGNORE|DA_IGNORE_HELD_ITEM) || QDELETED(I) || I != wear_mask)
		return

	visible_message(
		span_danger("[name] избавил[genderize_ru(gender,"ся","ась","ось","ись")] от [I.name]!"),
		span_notice("Вы успешно избавились от [I.name]."),
	)
	if(I.security_lock)
		I.do_break()
	drop_item_ground(I, TRUE)


/mob/living/carbon/show_inv(mob/user)
	user.set_machine(src)

	var/dat = {"<meta charset="UTF-8"><table>
	<tr><td><B>Left Hand:</B></td><td><A href='?src=[UID()];item=[ITEM_SLOT_HAND_LEFT]'>[(l_hand && !(l_hand.item_flags&ABSTRACT)) ? l_hand : "<font color=grey>Empty</font>"]</A></td></tr>
	<tr><td><B>Right Hand:</B></td><td><A href='?src=[UID()];item=[ITEM_SLOT_HAND_RIGHT]'>[(r_hand && !(r_hand.item_flags&ABSTRACT)) ? r_hand : "<font color=grey>Empty</font>"]</A></td></tr>
	<tr><td>&nbsp;</td></tr>"}

	dat += "<tr><td><B>Internals:</B></td><td>"

	if(has_airtight_items() && length(find_air_tanks()))
		dat += "<A href='?src=[UID()];internal=1'>[internal ? "Disable Internals" : "Set Internals"]</A>"
	else
		dat += "<font color=grey>Not available</font>"

	dat += "</td></tr><tr><td>&nbsp;</td></tr>"

	dat += "<tr><td><B>Back:</B></td><td><A href='?src=[UID()];item=[ITEM_SLOT_BACK]'>[(back && !(back.item_flags&ABSTRACT)) ? back : "<font color=grey>Empty</font>"]</A></td></tr><tr><td>&nbsp;</td></tr>"

	dat += "<tr><td><B>Head:</B></td><td><A href='?src=[UID()];item=[ITEM_SLOT_HEAD]'>[(head && !(head.item_flags&ABSTRACT)) ? head : "<font color=grey>Empty</font>"]</A></td></tr>"

	dat += "<tr><td><B>Mask:</B></td><td><A href='?src=[UID()];item=[ITEM_SLOT_MASK]'>[(wear_mask && !(wear_mask.item_flags&ABSTRACT)) ? wear_mask : "<font color=grey>Empty</font>"]</A></td></tr>"

	if(istype(wear_mask, /obj/item/clothing/mask/muzzle))
		var/obj/item/clothing/mask/muzzle/M = wear_mask
		if(M.security_lock)
			dat += "&nbsp;<A href='?src=[M.UID()];locked=\ref[src]'>[M.locked ? "Disable Lock" : "Set Lock"]</A>"

		dat += "</td></tr><tr><td>&nbsp;</td></tr>"

	if(handcuffed)
		dat += "<tr><td><B>Handcuffed:</B> <A href='?src=[UID()];item=[ITEM_SLOT_HANDCUFFED]'>Remove</A></td></tr>"
	if(legcuffed)
		dat += "<tr><td><A href='?src=[UID()];item=[ITEM_SLOT_LEGCUFFED]'>Legcuffed</A></td></tr>"

	dat += {"</table>
	<A href='?src=[user.UID()];mach_close=mob\ref[src]'>Close</A>
	"}

	var/datum/browser/popup = new(user, "mob\ref[src]", "[src]", 440, 500)
	popup.set_content(dat)
	popup.open()


/mob/living/carbon/Topic(href, href_list)
	..()
	//strip panel
	if(usr.incapacitated() || !Adjacent(usr) || HAS_TRAIT(usr, TRAIT_HANDS_BLOCKED))
		return

	if(href_list["internal"])
		if(internal)
			visible_message(
				span_danger("[usr] пыта[pluralize_ru(usr.gender,"ет","ют")]ся закрыть воздушный клапан на баллоне у [name]!"),
				span_userdanger("[usr] пыта[pluralize_ru(usr.gender,"ет","ют")]ся закрыть воздушный клапан на Вашем баллоне!"),
			)
			if(!do_after(usr, POCKET_STRIP_DELAY, src, NONE) || !internal)
				return
			internal = null
			update_action_buttons_icon()
		else
			if(!has_airtight_items())
				to_chat(usr, span_warning("[name] не облада[pluralize_ru(gender,"ет","ют")] подходящей маской или шлемом!"))
				return

			var/list/airtanks = find_air_tanks()
			if(!length(airtanks))
				return

			var/obj/item/tank/our_tank
			if(length(airtanks) > 1)
				var/obj/item/tank/choice = tgui_input_list(usr, "Choose a tank to open valve on.", "Tank selection.", airtanks)
				if(!choice || usr.incapacitated() || !Adjacent(usr))
					return
				if(internal)
					to_chat(usr, span_warning("[name] уже име[pluralize_ru(gender,"ет","ют")] подключённый баллон."))
					return
				if(choice.loc != src)
					to_chat(usr, span_warning("[name] более не облада[pluralize_ru(gender,"ет","ют")] указанным баллоном."))
					return
				if(!has_airtight_items())
					to_chat(usr, span_warning("[name] более не облада[pluralize_ru(gender,"ет","ют")] подходящей маской или шлемом."))
					return
				our_tank = choice
			else
				our_tank = airtanks[1]

			visible_message(
				span_danger("[usr] пыта[pluralize_ru(usr.gender,"ет","ют")]ся открыть воздушный клапан на баллоне у [name]!"),
				span_userdanger("[usr] пыта[pluralize_ru(usr.gender,"ет","ют")]ся открыть воздушный клапан на Вашем баллоне!"),
			)
			if(!do_after(usr, POCKET_STRIP_DELAY, src, NONE))
				return
			if(internal)
				to_chat(usr, span_warning("[name] уже име[pluralize_ru(src.gender,"ет","ют")] подключённый баллон."))
				return
			if(our_tank.loc != src)
				to_chat(usr, span_warning("[name] более не облада[pluralize_ru(src.gender,"ет","ют")] баллоном."))
				return
			if(!has_airtight_items())
				to_chat(usr, span_warning("[name] более не облада[pluralize_ru(src.gender,"ет","ют")] подходящей маской или шлемом."))
				return
			internal = our_tank
			update_action_buttons_icon()

		for(var/mob/viewer as anything in viewers(1, src))
			if(viewer.machine == src)
				show_inv(viewer)

		visible_message(
			span_danger("[usr] [internal ? "открыва" : "закрыва"][pluralize_ru(usr.gender,"ет","ют")] воздушный клапан на баллоне у [name]!"),
			span_userdanger("[usr] [internal ? "открыва" : "закрыва"][pluralize_ru(usr.gender,"ет","ют")] воздушный клапан на Вашем баллоне!"),
		)


/mob/living/carbon/do_unEquip(obj/item/I, force = FALSE, atom/newloc, no_move = FALSE, invdrop = TRUE, silent = FALSE)
	. = ..()
	if(!. || !I)
		return

	if(I == back)
		back = null
		if(!QDELETED(src))
			update_inv_back()

	else if(I == wear_mask)
		if(ishuman(src)) //If we don't do this hair won't be properly rebuilt.
			return
		wear_mask = null
		if(!QDELETED(src))
			update_inv_wear_mask()

	else if(I == handcuffed)
		set_handcuffed(null)
		if(buckled?.buckle_requires_restraints)
			buckled.unbuckle_mob(src)

	else if(I == legcuffed)
		set_legcuffed(null)
		if(!QDELETED(src))
			update_legcuffed_status()


/**
 * All the necessary checks for carbon to put an item in hand
 */
/mob/living/carbon/put_in_hand_check(obj/item/I, hand_id)
	if(!istype(I))
		return FALSE

	if(SEND_SIGNAL(src, COMSIG_CARBON_TRY_PUT_IN_HAND, I, hand_id) & COMPONENT_CARBON_CANT_PUT_IN_HAND)
		return FALSE

	if(I.item_flags & NOPICKUP)
		return FALSE

	if(!(mobility_flags & MOBILITY_PICKUP) && !(I.item_flags & ABSTRACT))
		return FALSE

	if(hand_id == ITEM_SLOT_HAND_LEFT && !has_left_hand())
		return FALSE

	else if(hand_id == ITEM_SLOT_HAND_RIGHT && !has_right_hand())
		return FALSE

	if(!isnull(pull_hand) && pull_hand != PULL_WITHOUT_HANDS && ((hand_id == ITEM_SLOT_HAND_LEFT && pull_hand == PULL_HAND_LEFT) || (hand_id == ITEM_SLOT_HAND_RIGHT && pull_hand == PULL_HAND_RIGHT)))
		return FALSE

	return hand_id == ITEM_SLOT_HAND_LEFT ? !l_hand : !r_hand


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
/mob/living/carbon/put_in_hands(obj/item/I, force = FALSE, qdel_on_fail = FALSE, merge_stacks = TRUE, ignore_anim = TRUE, silent = FALSE)

	// Its always TRUE if there is no item, since we are using this proc in 'if()' statements
	if(!I)
		return TRUE

	if(QDELING(I))
		return FALSE

	if(!real_human_being())	// Not a real hero :'(
		var/atom/drop_loc = drop_location()
		I.forceMove(drop_loc)
		I.pixel_x = I.base_pixel_x
		I.pixel_y = I.base_pixel_y
		I.layer = initial(I.layer)
		SET_PLANE_EXPLICIT(I, initial(I.plane), drop_loc)
		I.dropped(src, NONE, silent)
		return TRUE

	// If the item is a stack and we're already holding a stack then merge
	if(isstack(I))
		var/obj/item/stack/item_stack = I
		var/obj/item/stack/active_stack = get_active_hand()

		if(item_stack.is_zero_amount(delete_if_zero = TRUE))
			return FALSE

		if(merge_stacks)
			if(istype(active_stack) && active_stack.can_merge(item_stack, inhand = TRUE))
				if(!ignore_anim)
					I.do_pickup_animation(src)
				if(item_stack.merge(active_stack))
					to_chat(src, span_notice("Your [active_stack.name] stack now contains [active_stack.get_amount()] [active_stack.singular_name]\s."))
					return TRUE
			else
				var/obj/item/stack/inactive_stack = get_inactive_hand()
				if(istype(inactive_stack) && inactive_stack.can_merge(item_stack, inhand = TRUE))
					if(!ignore_anim)
						I.do_pickup_animation(src)
					if(item_stack.merge(inactive_stack))
						to_chat(src, span_notice("Your [inactive_stack.name] stack now contains [inactive_stack.get_amount()] [inactive_stack.singular_name]\s."))
						return TRUE

	if(put_in_active_hand(I, force, ignore_anim, silent))
		return TRUE
	if(put_in_inactive_hand(I, force, ignore_anim, silent))
		return TRUE

	if(qdel_on_fail)
		qdel(I)
		return FALSE

	var/atom/drop_loc = drop_location()
	I.forceMove(drop_loc)
	I.layer = initial(I.layer)
	SET_PLANE_EXPLICIT(I, initial(I.plane), drop_loc)
	I.dropped(src, NONE, silent)

	return FALSE


/mob/living/carbon/get_item_by_slot(slot_flag)
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
		if(ITEM_SLOT_HANDCUFFED)
			return handcuffed
		if(ITEM_SLOT_LEGCUFFED)
			return legcuffed
	return null


/mob/living/carbon/get_slot_by_item(item)
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
	if(item == handcuffed)
		return ITEM_SLOT_HANDCUFFED
	if(item == legcuffed)
		return ITEM_SLOT_LEGCUFFED
	return NONE


/mob/living/carbon/get_all_slots()
	return list(l_hand,
				r_hand,
				handcuffed,
				legcuffed,
				back,
				wear_mask)


/mob/living/carbon/get_access_locations()
	. = ..()
	. |= list(get_active_hand(), get_inactive_hand())


/mob/living/carbon/get_equipped_items(include_pockets = FALSE, include_hands = FALSE)
	var/list/items = ..()
	if(wear_suit)
		items += wear_suit
	if(head)
		items += head
	return items


/mob/living/carbon/get_equipped_slots(include_pockets = FALSE, include_hands = FALSE)
	. = ..()
	if(wear_suit)
		. |= ITEM_SLOT_CLOTH_OUTER
	if(head)
		. |= ITEM_SLOT_HEAD


/mob/living/carbon/update_equipment_speed_mods()
	. = ..()
	update_limbless_slowdown()	// in case we get crutches



/mob/living/carbon/proc/has_airtight_items()
	if(get_organ_slot(INTERNAL_ORGAN_BREATHING_TUBE))
		return TRUE

	if(isclothing(wear_mask))
		var/obj/item/clothing/our_mask = wear_mask
		if(our_mask.clothing_flags & AIRTIGHT)
			return TRUE

	if(isclothing(head))
		var/obj/item/clothing/our_helmet = head
		if(our_helmet.clothing_flags & AIRTIGHT)
			return TRUE

	return FALSE


/mob/living/carbon/proc/find_air_tanks()
	. = list()
	for(var/obj/item/tank/tank in get_equipped_items(include_pockets = TRUE, include_hands = TRUE))
		. += tank


/mob/living/carbon/covered_with_thick_material(check_zone, full_body_check = FALSE)
	if(full_body_check)
		if(!isclothing(head))
			return FALSE
		var/obj/item/clothing/cloth = head
		if(!(cloth.clothing_flags & THICKMATERIAL))
			return FALSE

		if(!isclothing(wear_suit))
			return FALSE
		cloth = wear_suit
		if(!(cloth.clothing_flags & THICKMATERIAL))
			return FALSE

		return TRUE

	if(!check_zone)
		check_zone = BODY_ZONE_CHEST

	if(above_neck(check_zone))
		if(isclothing(head))
			var/obj/item/clothing/cloth = head
			if(cloth.clothing_flags & THICKMATERIAL)
				return TRUE
	else
		if(isclothing(wear_suit))
			var/obj/item/clothing/cloth = wear_suit
			if(cloth.clothing_flags & THICKMATERIAL)
				return TRUE

	return FALSE

