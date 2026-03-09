/datum/element/tts_modifier
	element_flags = ELEMENT_BESPOKE
	argument_hash_start_idx = 2
	var/effect

/datum/element/tts_modifier/Attach(datum/target, req_effect)
	. = ..()
	if(!isitem(target))
		return ELEMENT_INCOMPATIBLE

	effect = req_effect

	RegisterSignal(target, COMSIG_ITEM_EQUIPPED, PROC_REF(on_equipped))
	RegisterSignal(target, COMSIG_ITEM_POST_UNEQUIP, PROC_REF(on_post_unequip))
	RegisterSignal(target, COMSIG_MASKFILTER_UPDATE_STATE, PROC_REF(on_update_state))

/datum/element/tts_modifier/Detach(datum/target)
	UnregisterSignal(target, list(COMSIG_ITEM_EQUIPPED, COMSIG_ITEM_POST_UNEQUIP, COMSIG_MASKFILTER_UPDATE_STATE))
	return ..()

/datum/element/tts_modifier/proc/on_equipped(obj/item/source, mob/living/carbon/user, slot)
	SIGNAL_HANDLER
	if(slot == ITEM_SLOT_MASK)
		update_tts_filter(source, user)

/datum/element/tts_modifier/proc/on_post_unequip(obj/item/source, force, newloc, no_move, invdrop, silent, mob/living/carbon/user)
	SIGNAL_HANDLER
	remove_tts_filter(source, user)

/datum/element/tts_modifier/proc/on_update_state(obj/item/source, mob/living/carbon/user)
	SIGNAL_HANDLER
	update_tts_filter(source, user)

/datum/element/tts_modifier/proc/update_tts_filter(obj/item/source, mob/living/carbon/user)
	if(!istype(user))
		return

	var/active = (user.wear_mask == source)
	
	if(active && istype(source, /obj/item/clothing/mask))
		var/obj/item/clothing/mask/mask_item = source
		if(mask_item.up)
			active = FALSE

	if(!active)
		remove_tts_filter(source, user)
		return

	if(user.tts_effect_override_source && user.tts_effect_override_source != source)
		return

	user.tts_effect_override = effect
	user.tts_effect_override_source = source

/datum/element/tts_modifier/proc/remove_tts_filter(obj/item/source, mob/living/carbon/user)
	if(!istype(user) || user.tts_effect_override_source != source)
		return

	user.tts_effect_override = SOUND_EFFECT_NONE
	user.tts_effect_override_source = null
