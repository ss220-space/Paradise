/obj/item/handheld_defibrillator
	name = "handheld defibrillator"
	desc = "Используется для перезапуска остановленных сердец."
	icon_state = "defib-on"
	item_state = "defib"
	belt_icon = "handheld_defibrillator"
	var/shield_ignore = FALSE
	var/icon_base = "defib"
	var/cooldown = FALSE
	var/charge_time = 100
	var/shocking = FALSE
	var/advanced = FALSE
	var/charges = 1
	var/max_charges = 1

/obj/item/handheld_defibrillator/get_ru_names()
	return list(
		NOMINATIVE = "ручной дефибриллятор",
		GENITIVE = "ручного дефибриллятора",
		DATIVE = "ручному дефибриллятору",
		ACCUSATIVE = "ручной дефибриллятор",
		INSTRUMENTAL = "ручным дефибриллятором",
		PREPOSITIONAL = "ручном дефибрилляторе"
	)


/obj/item/handheld_defibrillator/update_icon_state()
	if(shocking)
		icon_state = "[icon_base]-shock"
		return
	if(max_charges == 1)  // yellow and syndicate
		icon_state = "[icon_base][charges == 0 ? "-off" : "-on"]"
	else  // advanced
		icon_state = "[icon_base]-[charges]"

/obj/item/handheld_defibrillator/attack(mob/living/carbon/human/H, mob/living/user, params, def_zone, skip_attack_anim = FALSE)
	if(!istype(H))
		return ..()
	. = ATTACK_CHAIN_PROCEED
	var/blocked = FALSE
	var/obj/item/I = H.get_item_by_slot(ITEM_SLOT_CLOTH_OUTER)
	if(istype(I, /obj/item/clothing/suit/space) && !shield_ignore)
		if(istype(I, /obj/item/clothing/suit/space/hardsuit))
			var/obj/item/clothing/suit/space/hardsuit/hardsuit = I
			blocked = hardsuit.hit_reaction(user, src, attack_text = "the attack", final_block_chance = 0, damage = 0, attack_type = ITEM_ATTACK)

	if((charges == 0) || (shocking))
		balloon_alert(usr, "дефибриллятор всё ещё заряжается!")
		return .

	if((H.health <= HEALTH_THRESHOLD_CRIT) || (H.undergoing_cardiac_arrest()))
		. |= ATTACK_CHAIN_SUCCESS
		user.visible_message(span_notice("[user] использует [declent_ru(ACCUSATIVE)] на [H]."), span_notice("Вы попытались использовать [declent_ru(ACCUSATIVE)] на [H]."))
		add_attack_logs(user, H, "defibrillated with [src]")
		playsound(get_turf(src), 'sound/weapons/egloves.ogg', 75, TRUE)
		if(!blocked)
			if(H.stat == DEAD)
				balloon_alert(usr, "цель не реагирует!")
			if(H.stat != DEAD)
				H.set_heartattack(FALSE)
				var/total_damage = H.getBruteLoss() + H.getFireLoss() + H.getToxLoss()
				if(H.health <= HEALTH_THRESHOLD_CRIT)
					if(total_damage >= 90)
						to_chat(user, span_danger("Цель сильно ранена, дефибрилляция может быть неэффективна"))
					if((prob(66)) || (advanced))
						balloon_alert(usr, "цель делает глубокий вдох!")
						H.adjustOxyLoss(-50)
					else
						balloon_alert(usr, "цель не реагирует!")

				H.AdjustKnockdown(4 SECONDS)
				H.AdjustStuttering(20 SECONDS)
				to_chat(H, span_danger("Вы чувствуете сильный удар током!"))
				H.shock_internal_organs(100)
		else
			balloon_alert(usr, "слишком толстый слой материала для применения!")
		shocking = TRUE
		update_icon(UPDATE_ICON_STATE)
		addtimer(CALLBACK(src, PROC_REF(short_charge)), 1 SECONDS)
		if(charges > 0)
			charges--
			update_icon(UPDATE_ICON_STATE)
			addtimer(CALLBACK(src, PROC_REF(recharge)), charge_time)

	else
		balloon_alert(usr, "дефибрилляция не требуется")

/obj/item/handheld_defibrillator/proc/short_charge()
	shocking = FALSE
	update_icon(UPDATE_ICON_STATE)


/obj/item/handheld_defibrillator/proc/recharge()
	charges++
	update_icon(UPDATE_ICON_STATE)
	playsound(loc, 'sound/weapons/flash.ogg', 75, TRUE)


/obj/item/handheld_defibrillator/syndie
	name = "combat handheld defibrillator"
	desc = "Используется для перезапуска остановленных сердец (Не для свиней из Нанотрейзен)."
	icon_state = "sdefib-on"
	item_state = "sdefib"
	charge_time = 30
	icon_base = "sdefib"
	shield_ignore = TRUE

/obj/item/handheld_defibrillator/syndie/get_ru_names()
	return list(
		NOMINATIVE = "боевой ручной дефибриллятор",
		GENITIVE = "боевого ручного дефибриллятора",
		DATIVE = "боевому ручному дефибриллятору",
		ACCUSATIVE = "боевой ручной дефибриллятор",
		INSTRUMENTAL = "боевым ручным дефибриллятором",
		PREPOSITIONAL = "боевом ручном дефибрилляторе"
	)

/obj/item/handheld_defibrillator/advanced
	name = "advanced handheld defibrillator"
	desc = "Используется для эффективного перезапуска остановленных сердец, имеет улучшенную батарею на три быстровосстанавливающихся заряда."
	icon_state = "adv_defib-3"
	item_state = "adv_defib"
	icon_base = "adv_defib"
	belt_icon = "advanced_handheld_defibrillator"
	advanced = TRUE
	charges = 3
	max_charges = 3
	charge_time = 70

/obj/item/handheld_defibrillator/advanced/get_ru_names()
	return list(
		NOMINATIVE = "продвинутый ручной дефибриллятор",
		GENITIVE = " продвинутого ручного дефибриллятора",
		DATIVE = "продвинутому ручному дефибриллятору",
		ACCUSATIVE = "продвинутый ручной дефибриллятор",
		INSTRUMENTAL = "продвинутым ручным дефибриллятором",
		PREPOSITIONAL = "продвинутом ручном дефибрилляторе"
	)

/obj/item/handheld_defibrillator/advanced/examine(mob/user)
	. = ..()
	. += span_notice("У [declent_ru(GENITIVE)] осталось <b>[charges]</b> заряда из <b>[max_charges]</b>.")
