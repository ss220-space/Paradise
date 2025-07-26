/obj/effect/proc_holder/spell/pointed/burglar_finesse
	name = "Хитрость взломщика"
	desc = "Помещает случайный предмет из рюкзака выбранной жертвы вам в руку."
	action_background_icon_state = "bg_heretic"
	overlay_icon_state = "bg_heretic_border"
	action_icon = 'icons/mob/actions/actions_ecult.dmi'
	action_icon_state = "burglarsfinesse"

	school = SCHOOL_FORBIDDEN
	human_req = FALSE
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
		to_chat(cast_on, span_danger("Вы чувствуете легкий рывок!"))
		to_chat(action.owner, span_danger("[cast_on.declent_ru(NOMINATIVE)] отражает попытку кражи!"))
		return FALSE

	var/obj/item/storage/storage_item = cast_on.get_item_by_slot(ITEM_SLOT_BACK)

	if(isnull(storage_item))
		return FALSE

	var/obj/item/item = pick(storage_item.return_inv())
	if(isnull(item))
		return FALSE

	to_chat(cast_on, span_warning("Ваш[genderize_ru(storage_item.gender, "", "а", "е", "и")] [storage_item.declent_ru(NOMINATIVE)] станов[pluralize_ru(storage_item.gender, "и", "я")]тся легче..."))
	to_chat(action.owner, span_notice("Вы делаете легкий взмах рукой, доставая [item.declent_ru(ACCUSATIVE)] из [storage_item.declent_ru(GENITIVE)]."))
	if(action.owner.put_in_active_hand(item))
		return

	if(action.owner.put_in_inactive_hand(item))
		return

	item.forceMove(get_turf(action.owner))
