/**
 * Emote observer for item, invoke attack_slef if target emote called with target item in hands.
 */
/datum/element/item_emote_observer
	element_flags = ELEMENT_BESPOKE|ELEMENT_DETACH_ON_HOST_DESTROY
	argument_hash_start_idx = 1
	var/emote_key

/datum/element/item_emote_observer/Attach(datum/target, emote_key)
	. = ..()
	if(!isitem(target)) // only for items
		return ELEMENT_INCOMPATIBLE
	src.emote_key = emote_key
	RegisterSignal(target, COMSIG_ITEM_EQUIPPED, PROC_REF(on_equip))
	RegisterSignal(target, COMSIG_ITEM_DROPPED, PROC_REF(on_drop))

/datum/element/item_emote_observer/Detach(datum/target)
	. = ..()
	UnregisterSignal(target, list(COMSIG_ITEM_EQUIPPED, COMSIG_ITEM_DROPPED))

/datum/element/item_emote_observer/proc/on_equip(datum/source, mob/user, slot)
	SIGNAL_HANDLER

	if(!(slot & ITEM_SLOT_HANDS) || !user.is_in_active_hand(source))
		on_drop(source, user)
		return FALSE

	// The item is equipped in their hands, register emote signal.
	RegisterSignal(user, COMSIG_MOB_EMOTE, PROC_REF(on_emote))

/datum/element/item_emote_observer/proc/on_drop(datum/source, mob/user)
	SIGNAL_HANDLER

	// The item dropped, unregister emote signal
	UnregisterSignal(user, COMSIG_MOB_EMOTE)
	return FALSE

/datum/element/item_emote_observer/proc/on_emote(mob/living/user, emote)
	SIGNAL_HANDLER
	if(emote != emote_key)
		return //not interesting emote

	var/obj/item/parent_item = user.get_active_hand()
	if(!parent_item || !istype(parent_item))
		return

	INVOKE_ASYNC(parent_item, TYPE_PROC_REF(/obj/item, attack_self), user)
