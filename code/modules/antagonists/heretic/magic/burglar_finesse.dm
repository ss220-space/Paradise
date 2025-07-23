/obj/effect/proc_holder/spell/pointed/burglar_finesse
	name = "Хитрость взломщика"
	desc = "Steal a random item from the victim's backpack."
	action_background_icon_state = "bg_heretic"
	overlay_icon_state = "bg_heretic_border"
	action_icon = 'icons/mob/actions/actions_ecult.dmi'
	action_icon_state = "burglarsfinesse"

	school = SCHOOL_FORBIDDEN
	clothes_req = FALSE
	base_cooldown = 40 SECONDS

	invocation = "Y'O'K!"
	invocation_type = INVOCATION_WHISPER
	spell_requirements = NONE

	cast_range = 6


/obj/effect/proc_holder/spell/pointed/burglar_finesse/valid_target(mob/living/carbon/human/cast_on)
	if(!istype(cast_on))
		return FALSE

	var/obj/item/back_item = cast_on.get_item_by_slot(ITEM_SLOT_BACK)
	return ..() && isstorage(back_item)


/obj/effect/proc_holder/spell/pointed/burglar_finesse/cast(list/targets)
	var/mob/living/carbon/human/cast_on = targets[1]
	. = ..()
	if(cast_on.can_block_magic(antimagic_flags))
		to_chat(cast_on, span_danger("You feel a light tug, but are otherwise fine, you were protected by holiness!"))
		to_chat(action.owner, span_danger("[cast_on] is protected by holy forces!"))
		return FALSE

	var/obj/item/storage/storage_item = cast_on.get_item_by_slot(ITEM_SLOT_BACK)

	if(isnull(storage_item))
		return FALSE

	var/item = pick(storage_item.return_inv())
	if(isnull(item))
		return FALSE

	to_chat(cast_on, span_warning("Your [storage_item] feels lighter..."))
	to_chat(action.owner, span_notice("With a blink, you pull [item] out of [cast_on][p_s()] [storage_item]."))
	action.owner.put_in_active_hand(item)
