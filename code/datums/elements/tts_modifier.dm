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

/datum/element/tts_modifier/proc/apply_effect(obj/item/equipped_item, mob/living/carbon/wearer)
	if(!istype(wearer) || !istype(equipped_item))
		return

	var/is_active_mask = (wearer.wear_mask == equipped_item)
	if(istype(equipped_item, /obj/item/clothing/mask))
		var/obj/item/clothing/mask/mask_item = equipped_item
		if(mask_item.up)
			is_active_mask = FALSE

	if(is_active_mask)
		wearer.tts_effect_override = effect
		wearer.tts_effect_override_source = equipped_item
		return

	if(wearer.tts_effect_override_source != equipped_item)
		return

	wearer.tts_effect_override = SOUND_EFFECT_NONE
	wearer.tts_effect_override_source = null

/datum/element/tts_modifier/proc/on_item_equipped(obj/item/equipped_item, mob/wearer, slot)
	SIGNAL_HANDLER
	RegisterSignal(wearer, COMSIG_MOB_UNEQUIPPED_ITEM, PROC_REF(on_mob_unequipped_item), override = TRUE)
	apply_effect(equipped_item, wearer)

/datum/element/tts_modifier/proc/on_mob_unequipped_item(mob/wearer, obj/item/equipped_item, force, atom/newloc)
	SIGNAL_HANDLER
	apply_effect(equipped_item, wearer)
	UnregisterSignal(wearer, COMSIG_MOB_UNEQUIPPED_ITEM)

/datum/element/tts_modifier/proc/on_update_state(obj/item/equipped_item, mob/wearer)
	SIGNAL_HANDLER
	if(wearer)
		apply_effect(equipped_item, wearer)
