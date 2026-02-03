
/datum/action/changeling/hand_strain
	name = "Перенапряжение Руки"
	desc = "Позволяет намертво вцепиться в предмет активной руки. Стоимость 10 химикатов."
	helptext = "Позволяет прикрепить предмет в активной руке, предотвращая его выпадение. Повторное использование отпускает предмет."
	button_icon_state = "limb_throw"
	power_type = CHANGELING_PURCHASABLE_POWER
	dna_cost = 1
	chemical_cost = 10
	req_stat = UNCONSCIOUS

	/// Currently attached item
	var/obj/item/attached_item = null
	/// Flag to prevent recursion
	var/releasing = FALSE

/datum/action/changeling/hand_strain/Remove(mob/user)
	if(attached_item)
		var/item_name = attached_item.name
		release_item()
		to_chat(user, span_notice("вы отпускаете [item_name]."))
	. = ..()

/datum/action/changeling/hand_strain/sting_action(mob/living/carbon/user)
	if(!istype(user))
		return FALSE

	// Check active hand
	var/obj/item/held_item
	if(user.hand) // 1 - left hand, 0 - right hand
		held_item = user.l_hand
	else
		held_item = user.r_hand

	if(!held_item)
		to_chat(user, span_warning("это не активная рука!"))
		return FALSE

	// If there's already an attached item
	if(attached_item)
		// If it's the same item - release it
		if(held_item == attached_item)
			var/item_name = attached_item.name
			release_item()
			to_chat(user, span_notice("вы отпускаете [item_name]."))
		else
			// Release old item and attach new one
			var/old_item_name = attached_item.name
			release_item()
			attach_item(held_item)
			to_chat(user, span_notice("вы отпускаете [old_item_name] и цепляетесь мёртвой хваткой в [held_item.name]!"))
	else
		// Attach new item
		attach_item(held_item)
		to_chat(user, span_notice("вы вцепились мёртвой хваткой в [held_item.name]!"))

	return TRUE

/// Attach an item to the hand
/datum/action/changeling/hand_strain/proc/attach_item(obj/item/I)
	if(!I || !owner)
		return

	// If item already has NODROP from another source, ignore it
	if(HAS_TRAIT_FROM(I, TRAIT_NODROP, ANTIDROP_TRAIT))
		to_chat(owner, span_warning("[I.name] уже невозможно выпустить из-за импланта антидроп!"))
		return

	attached_item = I

	// Add NODROP trait to the item
	ADD_TRAIT(attached_item, TRAIT_NODROP, CHANGELING_HAND_STRAIN_TRAIT)
	// Add trait to the mob for examine text
	ADD_TRAIT(owner, TRAIT_CHANGELING_HAND_STRAIN_ACTIVE, CHANGELING_HAND_STRAIN_TRAIT)

	// Register signals for tracking
	RegisterSignal(attached_item, COMSIG_ITEM_DROPPED, .proc/on_item_dropped)
	RegisterSignal(attached_item, COMSIG_QDELETING, .proc/on_item_deleted)

	// Sound effect
	playsound(owner, 'sound/effects/bone_break_6.ogg', 100, TRUE)

/// Release the item
/datum/action/changeling/hand_strain/proc/release_item()
	if(!attached_item || releasing)
		return

	releasing = TRUE

	// Remove NODROP trait from the item
	REMOVE_TRAIT(attached_item, TRAIT_NODROP, CHANGELING_HAND_STRAIN_TRAIT)
	// Remove trait from the mob
	REMOVE_TRAIT(owner, TRAIT_CHANGELING_HAND_STRAIN_ACTIVE, CHANGELING_HAND_STRAIN_TRAIT)

	// Unregister signals
	UnregisterSignal(attached_item, list(COMSIG_ITEM_DROPPED, COMSIG_QDELETING))

	attached_item = null
	releasing = FALSE

	playsound(owner, 'sound/effects/bone_break_5.ogg', 100, TRUE)

/// If item is attempted to be dropped - prevent it
/datum/action/changeling/hand_strain/proc/on_item_dropped(obj/item/I, mob/dropper)
	SIGNAL_HANDLER

	if(releasing || !attached_item || attached_item != I)
		return

	// Return item to hand
	to_chat(dropper, span_warning("Вы пытаетесь отпустить [I], но ваша рука не слушается!"))

	if(dropper.put_in_active_hand(I))
		return TRUE

/// If item is being deleted - clear reference
/datum/action/changeling/hand_strain/proc/on_item_deleted(datum/source)
	SIGNAL_HANDLER

	if(source == attached_item)
		// Remove trait from mob when item is destroyed
		REMOVE_TRAIT(owner, TRAIT_CHANGELING_HAND_STRAIN_ACTIVE, CHANGELING_HAND_STRAIN_TRAIT)
		UnregisterSignal(attached_item, list(COMSIG_ITEM_DROPPED, COMSIG_QDELETING))
		attached_item = null
