/datum/action/changeling/hand_strain
	name = "Перенапряжение руки"
	desc = "Позволяет намертво вцепиться в предмет активной руки. Стоимость 10 химикатов."
	helptext = "Позволяет крепко схватить предмет в руке, предотвращая его выпадение. Повторное использование отпускает предмет."
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
		release_item()
		to_chat(user, span_notice("Вы отпускаете [attached_item.declent_ru(ACCUSATIVE)]."))
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
		user.balloon_alert(user, "активная рука пуста!")
		return FALSE

	// If there's already an attached item
	if(attached_item)
		// If it's the same item - release it
		if(held_item == attached_item)
			var/declined_name = attached_item.declent_ru(ACCUSATIVE)
			release_item()
			to_chat(user, span_notice("Вы отпускаете [declined_name]."))
		else
			// Release old item and attach new one
			var/old_item_decl_name = attached_item.declent_ru(ACCUSATIVE)
			release_item()
			attach_item(held_item)
			to_chat(user, span_notice("Вы отпускаете [old_item_decl_name] и цепляетесь мёртвой хваткой в [held_item.declent_ru(ACCUSATIVE)]!"))
	else
		// Attach new item
		attach_item(held_item)
		to_chat(user, span_notice("Вы вцепились мёртвой хваткой в [held_item.declent_ru(ACCUSATIVE)]!"))
	return TRUE

/// Attach an item to the hand
/datum/action/changeling/hand_strain/proc/attach_item(obj/item/I)
	if(!I || !owner)
		return

	// If item already has NODROP from another source, ignore it
	if(HAS_TRAIT_FROM(I, TRAIT_NODROP, ANTIDROP_TRAIT))
		to_chat(owner, span_warning("[I.declent_ru(ACCUSATIVE)] уже невозможно выпустить из-за импланта антидроп!"))
		return

	attached_item = I

	// Add NODROP trait to the item
	ADD_TRAIT(attached_item, TRAIT_NODROP, TRAIT_CHANGELING_HAND_STRAIN)
	// Add trait to the mob for examine text
	ADD_TRAIT(owner, TRAIT_CHANGELING_HAND_STRAIN_ACTIVE, TRAIT_CHANGELING_HAND_STRAIN)

	// Register signals for tracking
	RegisterSignal(attached_item, COMSIG_ITEM_DROPPED, PROC_REF(on_item_dropped))
	RegisterSignal(attached_item, COMSIG_QDELETING, PROC_REF(on_item_deleted))

	// Sound effect
	playsound(owner, 'sound/effects/bone_break_6.ogg', 100, TRUE)

/// Release the item
/datum/action/changeling/hand_strain/proc/release_item()
	if(!attached_item || releasing)
		return

	releasing = TRUE

	// Remove NODROP trait from the item
	REMOVE_TRAIT(attached_item, TRAIT_NODROP, TRAIT_CHANGELING_HAND_STRAIN)
	// Remove trait from the mob
	REMOVE_TRAIT(owner, TRAIT_CHANGELING_HAND_STRAIN_ACTIVE, TRAIT_CHANGELING_HAND_STRAIN)

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
	to_chat(dropper, span_warning("Вы пытаетесь отпустить [I.declent_ru(ACCUSATIVE)], но ваша рука не слушается!"))

	if(dropper.put_in_active_hand(I))
		return TRUE

/// If item is being deleted - clear reference
/datum/action/changeling/hand_strain/proc/on_item_deleted(datum/source)
	SIGNAL_HANDLER

	if(source == attached_item)
		// Remove trait from mob when item is destroyed
		REMOVE_TRAIT(owner, TRAIT_CHANGELING_HAND_STRAIN_ACTIVE, TRAIT_CHANGELING_HAND_STRAIN)
		UnregisterSignal(attached_item, list(COMSIG_ITEM_DROPPED, COMSIG_QDELETING))
		attached_item = null
