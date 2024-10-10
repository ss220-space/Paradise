/obj/effect/proc_holder/spell/lichdom
	name = "Bind Soul"
	desc = "Тёмный некромантический пакт, который навсегда привязывает вашу душу к предмету по вашему выбору. Пока и ваше тело, и предмет остаются нетронутыми и находятся на одном Z-уровне, вы можете возрождаться после смерти, хотя время между перевоплощениями будет неуклонно расти с каждым использованием."
	school = "necromancy"
	base_cooldown = 1 SECONDS
	cooldown_min = 1 SECONDS
	clothes_req = FALSE
	human_req = FALSE
	centcom_cancast = FALSE
	invocation = "NECREM IMORTIUM!"
	invocation_type = "shout"
	level_max = 0 //cannot be improved
	var/phylactery_made = FALSE
	var/obj/item/marked_item
	var/mob/living/current_body
	var/resurrections = 0
	var/existence_stops_round_end = FALSE
	var/focusing = FALSE

	action_icon_state = "skeleton"


/obj/effect/proc_holder/spell/lichdom/create_new_targeting()
	return new /datum/spell_targeting/self


/obj/effect/proc_holder/spell/lichdom/Destroy()
	marked_item = null
	current_body = null
	for(var/datum/mind/w_mind in SSticker.mode.wizards) //Make sure no other bones are about
		for(var/obj/effect/proc_holder/spell/lichdom/spell in w_mind.spell_list)
			if(spell != src && spell.existence_stops_round_end)
				return ..()

	if(existence_stops_round_end)
		CONFIG_SET(flag/continuous_rounds, FALSE)

	return ..()


/obj/effect/proc_holder/spell/lichdom/can_cast(mob/user = usr, charge_check = TRUE, show_message = FALSE)
	if(focusing)
		return FALSE

	return ..()


/obj/effect/proc_holder/spell/lichdom/cast(list/targets, mob/user = usr)

	if(phylactery_made) //Death is not my end!
		if(iscarbon(user) && !user.stat)
			to_chat(user, span_notice("Вы недостаточно мертвы, чтобы воскреснуть!"))	//Usually a good problem to have
			cooldown_handler.revert_cast()
			return

		if(QDELETED(marked_item)) //Wait nevermind
			to_chat(user, span_warning("Ваша филактерия разрушена!"))
			return

		var/turf/user_turf = get_turf(user)
		var/turf/item_turf = get_turf(marked_item)

		if(user_turf.z != item_turf.z)
			to_chat(user, span_warning("Ваша филактерия слишком далеко!"))
			return

		var/mob/living/carbon/human/lich = new(item_turf)

		lich.real_name = user.mind.name
		lich.set_species(/datum/species/skeleton) // Wizard variant
		user.mind.transfer_to(lich)
		to_chat(lich, span_warning("Ваши кости стучат и ломаются, медленно вытягиваясь обратно в этот мир!"))
		cooldown_handler.recharge_duration += 1 MINUTES
		cooldown_handler.start_recharge()

		var/mob/old_body = current_body
		var/turf/body_turf = get_turf(old_body)
		current_body = lich
		var/stun_time = (1 + resurrections) STATUS_EFFECT_CONSTANT
		lich.Weaken(stun_time)
		resurrections++
		equip_lich(lich)

		if(old_body && old_body.loc)
			if(iscarbon(old_body))
				for(var/obj/item/item in old_body.contents)
					old_body.drop_item_ground(item)

			var/wheres_wizdo = dir2text(get_dir(body_turf, item_turf))
			if(wheres_wizdo)
				old_body.visible_message(span_warning("Неожиданно труп [old_body.name] разваливается на куски! Вы видите, как из останков поднимается странная энергия и устремляется к [wheres_wizdo]!"))
				body_turf.Beam(item_turf,icon_state="lichbeam",icon='icons/effects/effects.dmi',time=stun_time,maxdistance=INFINITY)

			old_body.dust()

		return

	//linking item to the spell
	var/obj/item/item = user.get_active_hand()
	if(!item)
		to_chat(user, span_warning("Вы должны держать предмет, который желаете сделать своей филактерией..."))
		return

	if((item.item_flags & ABSTRACT) || HAS_TRAIT(item, TRAIT_NODROP))
		to_chat(user, span_warning("[item.name] нельзя использовать для ритуала!"))
		return

	to_chat(user, span_warning("Вы начинаете фокусировать само своё естество в [item]..."))

	focusing = TRUE
	if(!do_after(user, 5 SECONDS, user))
		focusing = FALSE
		return
	focusing = FALSE

	if(QDELETED(item) || item.loc != user) //I changed my mind I don't want to put my soul in a cheeseburger!
		to_chat(user, span_warning("Ваша душа возвращается в ваше тело, так как [item] пропал из зоны действия!"))
		return

	if(!CONFIG_GET(flag/continuous_rounds))
		existence_stops_round_end = TRUE
		CONFIG_SET(flag/continuous_rounds, TRUE)

	name = "RISE!"
	desc = "Восстаньте из мёртвых! Вы появитесь на месте расположения филактерии, а ваше старое тело рассыпется в прах."
	updateButtonIcon(change_name = TRUE)

	cooldown_handler.recharge_duration = 3 MINUTES
	cooldown_handler.revert_cast()
	stat_allowed = DEAD
	phylactery_made = TRUE

	current_body = user.mind.current
	marked_item = item
	marked_item.name = "Ensouled [marked_item.name]"
	marked_item.desc = "Ужасная аура окружает этот предмет, само его существование оскорбительно для жизни..."
	marked_item.color = "#003300"
	to_chat(user, span_userdanger("Ты с ужасом и восхищением наблюдаешь, как кожа отслаивается от костей! Кровь кипит, нервы гниют, глаза вылезают из орбит! Когда твои органы рассыпаются в прах, ты смиряешься со своим выбором. Отныне ты лич!"))

	if(ishuman(user))
		var/mob/living/carbon/human/h_user = user
		h_user.set_species(/datum/species/skeleton)
		h_user.drop_item_ground(h_user.wear_suit)
		h_user.drop_item_ground(h_user.head)
		h_user.drop_item_ground(h_user.shoes)
		h_user.drop_item_ground(h_user.head)
		equip_lich(h_user)


/obj/effect/proc_holder/spell/lichdom/proc/equip_lich(mob/living/carbon/human/user)
		user.equip_to_slot_or_del(new /obj/item/clothing/suit/wizrobe/black(user), ITEM_SLOT_CLOTH_OUTER)
		user.equip_to_slot_or_del(new /obj/item/clothing/head/wizard/black(user), ITEM_SLOT_HEAD)
		user.equip_to_slot_or_del(new /obj/item/clothing/shoes/sandal(user), ITEM_SLOT_FEET)
		user.equip_to_slot_or_del(new /obj/item/clothing/under/color/black(user), ITEM_SLOT_CLOTH_INNER)

