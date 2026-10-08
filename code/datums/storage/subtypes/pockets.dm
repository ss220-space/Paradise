/datum/storage/pockets
	max_slots = 2
	max_specific_storage = WEIGHT_CLASS_SMALL
	max_total_storage = 50
	do_rustle = FALSE

/datum/storage/pockets/attempt_insert(obj/item/to_insert, mob/user, override, force, messages)
	. = ..()
	if(!.)
		return

	if(!silent || override)
		return

	if(quickdraw)
		to_chat(user, span_notice("You discreetly slip [to_insert] into [parent]. Right-click to remove it."))
	else
		to_chat(user, span_notice("You discreetly slip [to_insert] into [parent]."))


/datum/storage/pockets/belt_shoulder_system
	max_slots = 4

///Small pockets
/datum/storage/pockets/small
	max_slots = 1
	attack_hand_interact = FALSE

///Tiny pockets
/datum/storage/pockets/tiny
	max_slots = 1
	max_specific_storage = WEIGHT_CLASS_TINY
	attack_hand_interact = FALSE
