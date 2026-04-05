/**
 * Emote observer for item, invoke attack_slef if target emote called with target item in hands.
 */
/datum/component/emote_observer
	var/emote_key

/datum/component/emote_observer/Initialize(emote_key)
	if(!isitem(parent)) // only for items
		return COMPONENT_INCOMPATIBLE
	src.emote_key = emote_key

/datum/component/emote_observer/RegisterWithParent()
	RegisterSignal(parent, COMSIG_ITEM_EQUIPPED, PROC_REF(on_equip))
	RegisterSignal(parent, COMSIG_ITEM_DROPPED, PROC_REF(on_drop))

/datum/component/emote_observer/UnregisterFromParent()
	UnregisterSignal(parent, list(COMSIG_ITEM_EQUIPPED, COMSIG_ITEM_DROPPED))

/datum/component/emote_observer/proc/on_equip(datum/source, mob/user, slot)
	SIGNAL_HANDLER

	if(!(slot & ITEM_SLOT_HANDS))
		on_drop(source, user)
		return FALSE

	// The item is equipped in their hands, register emote signal.
	RegisterSignal(user, COMSIG_MOB_EMOTE, PROC_REF(on_emote), override = TRUE)

/datum/component/emote_observer/proc/on_drop(datum/source, mob/user)
	SIGNAL_HANDLER

	// The item dropped, unregister emote signal
	UnregisterSignal(user, COMSIG_MOB_EMOTE)
	return FALSE

/datum/component/emote_observer/proc/on_emote(mob/living/user, emote)
	SIGNAL_HANDLER
	if(emote != emote_key)
		return //not interesting emote

	var/obj/item/parent_item = parent
	if(!istype(parent_item))
		return

	if(!user.is_in_active_hand(parent_item))
		return

	INVOKE_ASYNC(parent_item, TYPE_PROC_REF(/obj/item, attack_self), user)
