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

/obj/effect/proc_holder/spell/summonitem/proc/find_item_in_any_mob()
	if(is_internal_organ(marked_item))
		var/obj/item/organ/internal/organ = marked_item
		if(organ.owner && iscarbon(organ.owner))
			return list(organ, organ.owner, "internal_organ")

	if(isexternalorgan(marked_item))
		var/obj/item/organ/external/organ = marked_item
		if(organ.owner && iscarbon(organ.owner))
			return list(organ, organ.owner, "external_organ")

	for(var/mob/living/carbon/human/H in GLOB.player_list)
		for(var/obj/item/organ/external/EP in H.bodyparts)
			if(EP.hidden && EP.hidden == marked_item)
				return list(EP.hidden, H, "hidden")

		for(var/obj/item/I in H.contents)
			if(I == marked_item)
				return list(I, H, "contents")

	return null


/obj/effect/proc_holder/spell/summonitem/proc/do_instant_summon(mob/living/target, mob/user)
	var/obj/item_to_retrieve = marked_item

	if(!item_to_retrieve || QDELETED(item_to_retrieve))
		to_chat(target, span_warning("Отмеченный предмет больше не существует."))
		unlink_item_to_spell(target, user, null)
		return

	if(isturf(item_to_retrieve.loc))
		if(is_type_in_typecache(item_to_retrieve.loc, blacklisted_summons))
			to_chat(target, span_warning("Неизвестная сила мешает призвать отмеченный предмет!"))
			return
		teleportate_item_to_target(item_to_retrieve, target)
		return

	if(!isturf(item_to_retrieve.loc) && item_to_retrieve.loc)
		var/infinite_recursion = 0
		var/mob/living/organ_owner_for_teleport

		while(!isturf(item_to_retrieve.loc) && infinite_recursion < 10)
			if(is_type_in_typecache(item_to_retrieve.loc, blacklisted_summons))
				to_chat(target, span_warning("Неизвестная сила мешает призвать отмеченный предмет!"))
				return

			if(ismob(item_to_retrieve.loc))
				var/mob/item_owner = item_to_retrieve.loc

				if(isexternalorgan(item_to_retrieve))
					var/obj/item/organ/external/external_organ = item_to_retrieve
					var/atom/movable/thing = external_organ.droplimb(1, DROPLIMB_SHARP)
					if(thing)
						thing.forceMove(get_turf(item_owner))
					break

				if(is_internal_organ(item_to_retrieve))
					var/obj/item/organ/internal/internal_organ = item_to_retrieve
					if(ismob(item_owner))
						organ_owner_for_teleport = item_owner
						internal_organ.remove(item_owner)
						internal_organ.forceMove(get_turf(item_owner))
					break

				if(ishuman(item_owner))
					var/mob/living/carbon/human/H = item_owner
					for(var/obj/item/organ/external/EP in H.bodyparts)
						if(EP.hidden == item_to_retrieve)
							EP.hidden = null
							break

				if(!item_owner.drop_item_ground(item_to_retrieve, force = TRUE))
					to_chat(target, span_warning("У вас не получается призвать привязанный предмет!"))
					return
				break

			if(isobj(item_to_retrieve.loc))
				var/obj/container_obj = item_to_retrieve.loc
				if(container_obj.anchored)
					break
				if(istype(container_obj, /obj/machinery/portable_atmospherics/))
					var/obj/machinery/portable_atmospherics/P = container_obj
					P.disconnect()
					P.update_icon()
				item_to_retrieve = container_obj

			infinite_recursion += 1

		if(!QDELETED(item_to_retrieve))
			teleportate_item_to_target(item_to_retrieve, target, organ_owner_for_teleport)
		return

	var/list/found = find_item_in_any_mob()
	if(found)
		var/obj/found_item = found[1]
		var/mob/living/carbon/owner_mob = found[2]
		var/location_type = found[3]
		var/turf/item_turf = get_turf(owner_mob)

		switch(location_type)
			if("internal_organ")
				var/obj/item/organ/internal/internal_organ = found_item
				internal_organ.remove(owner_mob)
				if(item_turf)
					internal_organ.forceMove(item_turf)
				teleportate_item_to_target(internal_organ, target, owner_mob)
				return

			if("hidden")
				if(!ishuman(owner_mob))
					return
				var/mob/living/carbon/human/H = owner_mob
				var/obj/item/organ/external/affected_organ
				for(var/obj/item/organ/external/EP in H.bodyparts)
					if(EP.hidden == found_item)
						affected_organ = EP
						break

				if(affected_organ)
					affected_organ.hidden = null
					if(item_turf)
						found_item.forceMove(item_turf)
					teleportate_item_to_target(found_item, target)
					return

			if("contents")
				if(item_turf)
					found_item.forceMove(item_turf)
				teleportate_item_to_target(found_item, target)
				return

			if("external_organ")
				var/obj/item/organ/external/external_organ = found_item
				external_organ.droplimb(1, DROPLIMB_SHARP)
				teleportate_item_to_target(external_organ, target)
				return

	if(item_to_retrieve.loc && item_to_retrieve.forceMove(item_to_retrieve.loc))
		teleportate_item_to_target(item_to_retrieve, target)
		return

	to_chat(target, span_warning("У вас не получается призвать привязанный предмет!"))


/obj/effect/proc_holder/spell/summonitem/proc/do_instant_summon_old_variant(mob/living/target, mob/user) // Remove it later, or create old variant of speel
	var/obj/item_to_retrieve = marked_item
	var/infinite_recursion = 0 //I don't want to know how someone could put something inside itself but these are wizards so let's be safe

	while(!isturf(item_to_retrieve.loc) && infinite_recursion < 10) //if it's in something you get the whole thing.
		if(ismob(item_to_retrieve.loc)) //If its on someone, properly drop it
			var/mob/M = item_to_retrieve.loc

			if(issilicon(M) || !M.drop_item_ground(item_to_retrieve)) //Items in silicons warp the whole silicon
				var/turf/target_turf = get_turf(target)
				if(!target_turf)
					return

				M.visible_message(span_warning("[M] suddenly disappears!"), span_danger("A force suddenly pulls you away!"))
				M.forceMove(target_turf)
				M.loc.visible_message(span_caution("[M] suddenly appears!"))
				item_to_retrieve = null
				break

			if(ishuman(M)) //Edge case housekeeping
				var/mob/living/carbon/human/human = M
				if(human.remove_embedded_object(item_to_retrieve))
					to_chat(human, span_warning("The [item_to_retrieve] that was embedded into you has mysteriously vanished. How fortunate!"))

		else
			if(istype(item_to_retrieve.loc,/obj/machinery/portable_atmospherics/)) //Edge cases for moved machinery
				var/obj/machinery/portable_atmospherics/P = item_to_retrieve.loc
				P.disconnect()
				P.update_icon()
			if(is_type_in_typecache(item_to_retrieve.loc, blacklisted_summons))
				break
			item_to_retrieve = item_to_retrieve.loc
			if(ismodstorage(item_to_retrieve))
				var/obj/item/storage/backpack/modstorage/bag = item_to_retrieve
				if(bag.source && bag.source.mod)
					item_to_retrieve = bag.source.mod //Grab the modsuit.

		infinite_recursion += 1

	teleportate_item_to_target(item_to_retrieve, target)


/obj/effect/proc_holder/spell/summonitem/proc/teleportate_item_to_target(obj/item_to_retrieve, mob/living/target, mob/living/organ_owner = null)
	if(!item_to_retrieve)
		return

	var/turf/target_turf = get_turf(target)
	if(!target_turf)
		return

	var/atom/old_loc = item_to_retrieve.loc

	if(is_internal_organ(item_to_retrieve) && organ_owner)
		to_chat(organ_owner, span_danger("Вы чувствуете странную пустоту внутри..."))
	else if(old_loc)
		old_loc.visible_message(span_warning("[DECLENT_RU_CAP(item_to_retrieve, NOMINATIVE)] неожиданно исчезает!"))

	playsound(target_turf, 'sound/magic/summonitems_generic.ogg', 50, TRUE)

	item_to_retrieve.forceMove(target_turf)

	var/is_hidden_organ = is_internal_organ(item_to_retrieve) && organ_owner

	if(target.put_in_active_hand(item_to_retrieve) || target.put_in_inactive_hand(item_to_retrieve))
		if(!is_hidden_organ)
			target_turf.visible_message(span_caution("[DECLENT_RU_CAP(item_to_retrieve, NOMINATIVE)] внезапно появляется в руках [target.declent_ru(PREPOSITIONAL)]!"))
		return

	if(!is_hidden_organ)
		target_turf.visible_message(span_caution("[DECLENT_RU_CAP(item_to_retrieve, NOMINATIVE)] внезапно появляется!"))
