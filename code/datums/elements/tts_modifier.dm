/datum/element/tts_modifier
	element_flags = ELEMENT_BESPOKE
	argument_hash_start_idx = 2
	var/effect

/datum/element/tts_modifier/Attach(datum/target, req_effect)
	. = ..()
	if(!isitem(target))
		return ELEMENT_INCOMPATIBLE

	effect = req_effect

	RegisterSignal(target, COMSIG_ITEM_EQUIPPED, PROC_REF(on_item_equipped))
	RegisterSignal(target, COMSIG_MASKFILTER_UPDATE_STATE, PROC_REF(on_update_state))

/datum/element/tts_modifier/Detach(datum/target)
	. = ..()
	UnregisterSignal(target, list(COMSIG_ITEM_EQUIPPED, COMSIG_MASKFILTER_UPDATE_STATE))

/datum/element/tts_modifier/proc/apply_effect(obj/item/I, mob/living/carbon/C)
	if(!istype(C) || !istype(I))
		return

	var/is_active_mask = (C.wear_mask == I)
	if(istype(I, /obj/item/clothing/mask))
		var/obj/item/clothing/mask/M = I
		if(M.up)
			is_active_mask = FALSE

	if(is_active_mask)
		C.tts_effect_override = effect
		C.tts_effect_override_source = I
	else
		if(C.tts_effect_override_source == I)
			C.tts_effect_override = SOUND_EFFECT_NONE
			C.tts_effect_override_source = null

/datum/element/tts_modifier/proc/on_item_equipped(obj/item/I, mob/M, slot)
	SIGNAL_HANDLER
	RegisterSignal(M, COMSIG_MOB_UNEQUIPPED_ITEM, PROC_REF(on_mob_unequipped_item), override = TRUE)
	apply_effect(I, M)

/datum/element/tts_modifier/proc/on_mob_unequipped_item(mob/source, obj/item/I, force, atom/newloc)
	SIGNAL_HANDLER
	apply_effect(I, source)
	UnregisterSignal(source, COMSIG_MOB_UNEQUIPPED_ITEM)

/datum/element/tts_modifier/proc/on_update_state(obj/item/I, mob/M)
	SIGNAL_HANDLER
	if(M)
		apply_effect(I, M)
