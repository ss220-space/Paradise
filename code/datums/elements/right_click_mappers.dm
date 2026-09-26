
/**
 * Element for call mapped proc when player click right button on item.
 */
/datum/element/right_click_mapper

/datum/element/right_click_mapper/Attach(datum/target, screentip_text)
	. = ..()

	if(!isitem(target))
		return COMPONENT_INCOMPATIBLE

	RegisterSignal(target, COMSIG_ATOM_ATTACK_HAND_SECONDARY, PROC_REF(on_attack_hand_secondary))
	target.AddElement(/datum/element/contextual_screentip_bare_hands, rmb_text = screentip_text)

/datum/element/right_click_mapper/Detach(datum/target)
	UnregisterSignal(target, COMSIG_ATOM_ATTACK_HAND_SECONDARY)
	target.RemoveElement(/datum/element/contextual_screentip_bare_hands)
	. = ..()

/datum/element/right_click_mapper/proc/on_attack_hand_secondary(var/obj/item/target_item, mob/user)
	SIGNAL_HANDLER

	call_mapped_proc(target_item, user)
	return COMPONENT_CANCEL_ATTACK_CHAIN

/datum/element/right_click_mapper/proc/call_mapped_proc(obj/item/target_item, mob/user)
	return

/// Map right click to ui_action_click(mob/user, datum/action/action, leftclick) (Warning: Do not use for items where used action arg!)
/datum/element/right_click_mapper/ui_action_click

/datum/element/right_click_mapper/ui_action_click/call_mapped_proc(obj/item/target_item, mob/user)
	target_item.ui_action_click(user, null, TRUE)

/// Map right click to attack_self(mob/user)
/datum/element/right_click_mapper/attack_self

/datum/element/right_click_mapper/attack_self/call_mapped_proc(obj/item/target_item, mob/user)
	target_item.attack_self(user)
