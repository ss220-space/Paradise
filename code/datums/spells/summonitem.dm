#define MAX_CONTAINER_DEPTH 10

/obj/effect/proc_holder/spell/summonitem
	name = "Мгновенный призыв"
	desc = "Это заклинание позволяет вернуть ранее отмеченный предмет в вашу руку откуда угодно из Вселенной."
	school = "transmutation"
	cooldown_min = 10 SECONDS
	clothes_req = FALSE
	human_req = FALSE
	invocation = "GAR YOK"
	invocation_type = "whisper"
	level_max = 0 //cannot be improved

	var/obj/marked_item
	/// List of objects which will result in the spell stopping with the recursion search
	var/static/list/blacklisted_summons = list(/obj/machinery/computer/cryopod = TRUE, /obj/machinery/atmospherics = TRUE, /obj/structure/disposalholder = TRUE, /obj/machinery/disposal = TRUE)
	action_icon_state = "summons"

/obj/effect/proc_holder/spell/summonitem/create_new_targeting()
	return new /datum/spell_targeting/self

/obj/effect/proc_holder/spell/summonitem/cast(list/targets, mob/user = usr)
	for(var/mob/living/target in targets)
		cast_on_target(target, user)

/obj/effect/proc_holder/spell/summonitem/proc/cast_on_target(mob/living/target, mob/user)
	if(!marked_item)
		link_item_to_spell(target, user)
		return

	if(QDELETED(marked_item))
		unlink_item_to_spell(target, user, span_warning("Вы чувствуете, что отмеченный предмет уничтожен."))
		return

	var/obj/item/in_active_hand = target.get_active_hand()
	var/obj/item/in_inactive_hand = target.get_inactive_hand()

	if(marked_item == in_active_hand || marked_item == in_inactive_hand)
		unlink_item_to_spell(target, user, span_notice("Вы удалили отметку с [marked_item.declent_ru(GENITIVE)], теперь вы не можете его призвать."))
		return

	do_instant_summon(target, user)


/obj/effect/proc_holder/spell/summonitem/proc/link_item_to_spell(mob/living/target, mob/user)
	var/obj/item/held_item = target.get_active_hand()
	if(!held_item)
		held_item = target.get_inactive_hand()

	if(!held_item)
		to_chat(target, span_notice("Вы должны держать нужный предмет в руках, чтобы пометить его для призыва."))
		return

	if(held_item.item_flags & ABSTRACT)
		to_chat(target, span_caution("Вы не можете отметить [held_item.declent_ru(ACCUSATIVE)] для призыва."))
		return

	marked_item = held_item
	to_chat(target, span_notice("Вы отметили [marked_item.declent_ru(ACCUSATIVE)] для призыва."))

/obj/effect/proc_holder/spell/summonitem/proc/unlink_item_to_spell(mob/living/target, mob/user, reason)
	marked_item = null
	if(reason)
		to_chat(target, span_notice(reason))

/obj/effect/proc_holder/spell/summonitem/proc/do_instant_summon(mob/living/target, mob/living/user)
	var/obj/item_to_retrieve = marked_item

	if(!item_to_retrieve || QDELETED(item_to_retrieve))
		to_chat(target, span_warning("Отмеченный предмет больше не существует."))
		unlink_item_to_spell(target, user, null)
		return

	if(isexternalorgan(item_to_retrieve) || is_internal_organ(item_to_retrieve))
		SEND_SIGNAL(item_to_retrieve, COMSIG_ORGAN_SUMMONED, target)

	if(item_to_retrieve.loc)
		var/infinite_recursion = 0

		while(!isturf(item_to_retrieve.loc) && infinite_recursion < MAX_CONTAINER_DEPTH)
			if(is_type_in_typecache(item_to_retrieve.loc, blacklisted_summons))
				to_chat(target, span_warning("Неизвестная сила мешает призвать отмеченный предмет!"))
				return

			if(ismob(item_to_retrieve.loc))
				var/mob/item_owner = item_to_retrieve.loc
				if(ishuman(item_owner))
					var/mob/living/carbon/human/human = item_owner
					var/list/bodyparts = human.bodyparts
					for(var/obj/item/organ/external/bodypart in bodyparts)
						if(bodypart.hidden == item_to_retrieve)
							bodypart.hidden = null
							break

					if(!item_owner.drop_item_ground(item_to_retrieve, force = TRUE))
						to_chat(target, span_warning("У вас не получается призвать привязанный предмет!"))
						break
				break

			if(isobj(item_to_retrieve.loc))
				var/obj/container_obj = item_to_retrieve.loc
				if(isexternalorgan(container_obj))
					var/obj/item/organ/external/external_organ = container_obj
					if(external_organ.remove_embedded_object(item_to_retrieve))
						break

				if(container_obj.anchored)
					break

				if(istype(container_obj, /obj/machinery/portable_atmospherics/))
					var/obj/machinery/portable_atmospherics/portable_atmos = container_obj
					portable_atmos.disconnect()
					portable_atmos.update_icon()

				item_to_retrieve = container_obj
				infinite_recursion += 1

		if(!QDELETED(item_to_retrieve))
			teleport_item_to_target(item_to_retrieve, target)
		return

	to_chat(target, span_warning("У вас не получается призвать привязанный предмет!"))

/obj/effect/proc_holder/spell/summonitem/proc/teleport_item_to_target(obj/item_to_retrieve, mob/living/target)
	if(!item_to_retrieve)
		return

	var/turf/target_turf = get_turf(target)
	if(!target_turf)
		return

	var/atom/old_loc = item_to_retrieve.loc

	if(old_loc)
		old_loc.visible_message(span_warning("[DECLENT_RU_CAP(item_to_retrieve, NOMINATIVE)] неожиданно исчезает!"))

	playsound(target_turf, 'sound/magic/summonitems_generic.ogg', 50, TRUE)

	item_to_retrieve.forceMove(target_turf)

	if(target.put_in_active_hand(item_to_retrieve) || target.put_in_inactive_hand(item_to_retrieve))
		target_turf.visible_message(span_warning("[DECLENT_RU_CAP(item_to_retrieve, NOMINATIVE)] внезапно появляется в руках [target.declent_ru(GENITIVE)]!"))
		return

	target_turf.visible_message(span_warning("[DECLENT_RU_CAP(item_to_retrieve, NOMINATIVE)] внезапно появляется!"))

#undef MAX_CONTAINER_DEPTH
