/obj/effect/proc_holder/spell/summonitem
	name = "Instant Summons"
	desc = "Это заклинание можно использовать для того, чтобы вернуть ранее помеченный предмет в вашу руку из любой точки Вселенной."
	school = "transmutation"
	base_cooldown = 10 SECONDS
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
		var/list/hand_items = list(target.get_active_hand(), target.get_inactive_hand())
		var/message

		if(!marked_item) //linking item to the spell
			message = "<span class='notice'>"
			for(var/obj/item in hand_items)
				if(istype(item, /obj/item/organ/internal/brain)) //Yeah, sadly this doesn't work due to the organ system.
					break
				if(isitem(item))
					var/obj/item/I = item
					if(I.item_flags & ABSTRACT)
						continue
				if(HAS_TRAIT(item, TRAIT_NODROP))
					message += "This feels very redundant, but you go through with it anyway.<br>"
				marked_item = 		item
				message += "You mark [item] for recall.</span>"
				name = "Recall [item]"
				break

			if(!marked_item)
				if(hand_items)
					message = span_caution("У вас нет ничего, что можно было бы пометить для отзыва.")
				else
					message = span_notice("Вы должны держать нужный предмет в руках, чтобы пометить его для отзыва.")

		else if(marked_item && (marked_item in hand_items)) //unlinking item to the spell
			message = span_notice("Вы убираете метку на [marked_item].")
			name = "Instant Summons"
			marked_item = 		null

		else if(marked_item && !marked_item.loc) //the item was destroyed at some point
			message = span_warning("Вы чувствуете, что помеченный предмет был уничтожен!")
			name = "Instant Summons"
			marked_item = 		null

		else	//Getting previously marked item
			var/obj/item_to_retrieve = marked_item
			var/infinite_recursion = 0 //I don't want to know how someone could put something inside itself but these are wizards so let's be safe

			while(!isturf(item_to_retrieve.loc) && infinite_recursion < 10) //if it's in something you get the whole thing.
				if(ismob(item_to_retrieve.loc)) //If its on someone, properly drop it
					var/mob/M = item_to_retrieve.loc

					if(issilicon(M) || !M.drop_item_ground(item_to_retrieve)) //Items in silicons warp the whole silicon
						var/turf/target_turf = get_turf(target)
						if(!target_turf)
							return

						M.visible_message(span_warning("[M] неожиданно исчезает!"), span_danger("Неизвестная сила неожиданно утаскивает тебя!"))
						M.forceMove(target_turf)
						M.loc.visible_message(span_caution("[M] неожиданно появляется!"))
						item_to_retrieve = null
						break

					if(ishuman(M)) //Edge case housekeeping
						var/mob/living/carbon/human/human = M
						if(human.remove_embedded_object(item_to_retrieve))
							to_chat(human, span_warning("Вы замечаете, что предмет [item_to_retrieve] таинственным образом исчез. Какая удача!"))

				else
					if(istype(item_to_retrieve.loc,/obj/machinery/portable_atmospherics/)) //Edge cases for moved machinery
						var/obj/machinery/portable_atmospherics/P = item_to_retrieve.loc
						P.disconnect()
						P.update_icon()
					if(is_type_in_typecache(item_to_retrieve.loc, blacklisted_summons))
						break
					item_to_retrieve = item_to_retrieve.loc

				infinite_recursion += 1

			if(!item_to_retrieve)
				return

			var/turf/target_turf = get_turf(target)
			if(!target_turf)
				return

			item_to_retrieve.loc.visible_message(span_warning("[item_to_retrieve.name] неожиданно исчезает!"))
			playsound(target_turf, 'sound/magic/summonitems_generic.ogg', 50, TRUE)

			if(!target.put_in_active_hand(item_to_retrieve) && !target.put_in_inactive_hand(item_to_retrieve))
				item_to_retrieve.loc = target_turf
				item_to_retrieve.loc.visible_message(span_caution("[item_to_retrieve.name] неожиданно появляется!"))
			else
				item_to_retrieve.loc.visible_message(span_caution("[item_to_retrieve.name] неожиданно появляется в руке [target]!"))

		if(message)
			to_chat(target, message)
