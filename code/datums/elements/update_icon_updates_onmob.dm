//update_icon() may change the onmob icons
/datum/element/update_icon_updates_onmob
	element_flags = ELEMENT_BESPOKE
	argument_hash_start_idx = 2
	///The ITEM_SLOT_X flags to update on the parent mob in additon to the item's slot_flags.
	var/update_flags = NONE
	///Should the element call [/mob/proc/update_body()] in addition to clothing updates?
	var/update_body = FALSE

/datum/element/update_icon_updates_onmob/Attach(datum/target, flags, body = FALSE)
	. = ..()
	if(!isitem(target))
		return ELEMENT_INCOMPATIBLE
	RegisterSignal(target, COMSIG_ATOM_UPDATED_ICON, PROC_REF(update_onmob))
	update_flags = flags || NONE
	update_body = body

/datum/element/update_icon_updates_onmob/proc/update_onmob(obj/item/target)
	SIGNAL_HANDLER

	if(ismob(target.loc))
		var/mob/target_mob = target.loc
		if(target_mob.is_in_hands(target))
			target_mob.update_held_items()
		else
			target_mob.update_clothing((target.slot_flags|update_flags))
