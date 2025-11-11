/obj/item/handheld_defibrillator
	name = "handheld defibrillator"
	desc = "Used to restart stopped hearts."
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


/obj/item/handheld_defibrillator/update_icon_state()
	if(shocking)
		icon_state = "[icon_base]-shock"
		return
	if(max_charges == 1)  // yellow and syndicate defibrillator
		icon_state = "[icon_base][charges == 0 ? "-off" : "-on"]"
	else
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

	if(charges == 0)
		to_chat(user, span_warning("[src] is still charging!"))
		return .

	if((H.health <= HEALTH_THRESHOLD_CRIT) || (H.undergoing_cardiac_arrest()))
		. |= ATTACK_CHAIN_SUCCESS
		user.visible_message(span_notice("[user] shocks [H] with [src]."), span_notice("You tried to shock [H] with [src]."))
		add_attack_logs(user, H, "defibrillated with [src]")
		playsound(get_turf(src), 'sound/weapons/egloves.ogg', 75, TRUE)
		if(!blocked)
			if(H.stat == DEAD)
				to_chat(user, span_danger("[H] doesn't respond at all!"))
			if(H.stat != DEAD)
				H.set_heartattack(FALSE)
				var/total_damage = H.getBruteLoss() + H.getFireLoss() + H.getToxLoss()
				if(H.health <= HEALTH_THRESHOLD_CRIT)
					if(total_damage >= 90)
						to_chat(user, span_danger("[H] looks horribly injured. Resuscitation alone may not help revive them."))
					if((prob(66)) || (advanced))
						to_chat(user, span_danger("[H] inhales deeply!"))
						H.adjustOxyLoss(-50)
					else
						to_chat(user, span_danger("[H] doesn't respond!"))

				H.AdjustKnockdown(4 SECONDS)
				H.AdjustStuttering(20 SECONDS)
				to_chat(H, span_danger("You feel a powerful jolt!"))
				H.shock_internal_organs(100)
		else
			to_chat(user, span_danger("[H] has a hardsuit!"))
		shocking = TRUE
		update_icon(UPDATE_ICON_STATE)
		addtimer(CALLBACK(src, PROC_REF(short_charge)), 1 SECONDS)
		if(charges > 0)
			charges--
			update_icon(UPDATE_ICON_STATE)
			addtimer(CALLBACK(src, PROC_REF(recharge)), charge_time)

	else
		to_chat(user, span_notice("[src]'s on board medical scanner indicates that no shock is required."))

/obj/item/handheld_defibrillator/proc/short_charge()
	shocking = FALSE
	update_icon(UPDATE_ICON_STATE)


/obj/item/handheld_defibrillator/proc/recharge()
	charges++
	update_icon(UPDATE_ICON_STATE)
	playsound(loc, 'sound/weapons/flash.ogg', 75, TRUE)


/obj/item/handheld_defibrillator/syndie
	name = "combat handheld defibrillator"
	desc = "Used to restart stopped hearts (Not nanotrasen's pigs hearts)."
	icon_state = "sdefib-on"
	item_state = "sdefib"
	charge_time = 30
	icon_base = "sdefib"
	shield_ignore = TRUE

/obj/item/handheld_defibrillator/advanced
	name = "advanced handheld defibrillator"
	desc = "Used to more effectively restart stopped hearts."  // TODO: перевод
	icon_state = "adv-defib-3"
	item_state = "adv-defib"
	icon_base = "adv-defib"
	advanced = TRUE
	charges = 3
	max_charges = 3
	charge_time = 70

/obj/item/handheld_defibrillator/advanced/examine(mob/user)
	. = ..()
	. += span_notice("[src] has <b>[charges]</b> out of <b>[max_charges]</b> charges left.")
