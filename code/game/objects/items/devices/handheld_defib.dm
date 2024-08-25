/obj/item/handheld_defibrillator
	name = "handheld defibrillator"
	desc = "Used to restart stopped hearts."
	icon = 'icons/obj/items.dmi'
	lefthand_file = 'icons/mob/inhands/items_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/items_righthand.dmi'
	icon_state = "defib-on"
	item_state = "defib"
	belt_icon = "handheld_defibrillator"
	var/shield_ignore = FALSE
	var/icon_base = "defib"
	var/cooldown = FALSE
	var/charge_time = 100
	var/emagged = FALSE
	var/shocking = FALSE


/obj/item/handheld_defibrillator/update_icon_state()
	if(shocking)
		icon_state = "[icon_base]-shock"
		return
	icon_state = "[icon_base][cooldown ? "-off" : "-on"]"


/obj/item/handheld_defibrillator/emag_act(mob/user)
	if(!emagged)
		add_attack_logs(user, src, "emagged")
		emagged = TRUE
		desc += " The screen only shows the word KILL flashing over and over."
		if(user)
			to_chat(user, span_warning("you short out the safeties on [src]"))
	else
		add_attack_logs(user, src, "un-emagged")
		emagged = FALSE
		desc = "Used to restart stopped hearts."
		if(user)
			to_chat(user, span_warning("You restore the safeties on [src]"))

/obj/item/handheld_defibrillator/emp_act(severity)
	if(emagged)
		emagged = FALSE
		desc = "Used to restart stopped hearts."
		visible_message(span_notice("[src] beeps: Safety protocols enabled!"))
		playsound(get_turf(src), 'sound/machines/defib_saftyon.ogg', 50, 0)
	else
		emagged = TRUE
		desc += " The screen only shows the word KILL flashing over and over."
		visible_message(span_notice("[src] beeps: Safety protocols disabled!"))
		playsound(get_turf(src), 'sound/machines/defib_saftyoff.ogg', 50, 0)


/obj/item/handheld_defibrillator/attack(mob/living/carbon/human/H, mob/living/user, params, def_zone, skip_attack_anim = FALSE)
	if(!istype(H))
		return ..()
	. = ATTACK_CHAIN_PROCEED
	var/blocked = FALSE
	var/obj/item/I = H.get_item_by_slot(ITEM_SLOT_CLOTH_OUTER)
	if(istype(I, /obj/item/clothing/suit/space) && !shield_ignore)
		if(istype(I, /obj/item/clothing/suit/space/hardsuit))
			var/obj/item/clothing/suit/space/hardsuit/hardsuit = I
			blocked = hardsuit.hit_reaction(user, src, attack_text = "the attack", final_block_chance = 0, damage = 0, attack_type = MELEE_ATTACK)
	if(cooldown)
		to_chat(user, span_warning("[src] is still charging!"))
		return .
	if(emagged || (H.health <= HEALTH_THRESHOLD_CRIT) || (H.undergoing_cardiac_arrest()))
		. |= ATTACK_CHAIN_SUCCESS
		user.visible_message(span_notice("[user] shocks [H] with [src]."), span_notice("You tried to shock [H] with [src]."))
		add_attack_logs(user, H, "defibrillated with [src]")
		playsound(get_turf(src), "sound/weapons/egloves.ogg", 75, TRUE)
		if(!blocked)
			if(H.stat == DEAD)
				to_chat(user, span_danger("[H] doesn't respond at all!"))
			if(H.stat != DEAD)
				H.set_heartattack(FALSE)
				var/total_damage = H.getBruteLoss() + H.getFireLoss() + H.getToxLoss()
				if(H.health <= HEALTH_THRESHOLD_CRIT)
					if(total_damage >= 90)
						to_chat(user, span_danger("[H] looks horribly injured. Resuscitation alone may not help revive them."))
					if(prob(66))
						to_chat(user, span_danger("[H] inhales deeply!"))
						H.adjustOxyLoss(-50)
					else
						to_chat(user, span_danger("[H] doesn't respond!"))

				H.AdjustWeakened(4 SECONDS)
				H.AdjustStuttering(20 SECONDS)
				to_chat(H, span_danger("You feel a powerful jolt!"))
				H.shock_internal_organs(100)

				if(emagged && prob(10))
					to_chat(user, span_danger("[src]'s on board scanner indicates that the target is undergoing a cardiac arrest!"))
					H.set_heartattack(TRUE)
		else
			to_chat(user, span_danger("[H] has a hardsuit!"))
		cooldown = TRUE
		shocking = TRUE
		update_icon(UPDATE_ICON_STATE)
		addtimer(CALLBACK(src, PROC_REF(short_charge)), 1 SECONDS)
		addtimer(CALLBACK(src, PROC_REF(recharge)), charge_time)

	else
		to_chat(user, span_notice("[src]'s on board medical scanner indicates that no shock is required."))

/obj/item/handheld_defibrillator/proc/short_charge()
	shocking = FALSE
	update_icon(UPDATE_ICON_STATE)


/obj/item/handheld_defibrillator/proc/recharge()
	cooldown = FALSE
	update_icon(UPDATE_ICON_STATE)
	playsound(loc, "sound/weapons/flash.ogg", 75, 1)

/obj/item/handheld_defibrillator/syndie
	name = "combat handheld defibrillator"
	desc = "Used to restart stopped hearts (Not nanotrasen's pigs hearts)."
	icon_state = "sdefib-on"
	item_state = "sdefib"
	charge_time = 30
	icon_base = "sdefib"
	shield_ignore = TRUE
