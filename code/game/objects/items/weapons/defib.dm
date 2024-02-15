//backpack item

/obj/item/defibrillator
	name = "defibrillator"
	desc = "A device that delivers powerful shocks to detachable paddles that resuscitate incapacitated patients."
	icon_state = "defibunit"
	item_state = "defibunit"
	slot_flags = SLOT_BACK
	force = 5
	throwforce = 6
	w_class = WEIGHT_CLASS_BULKY
	origin_tech = "biotech=4"
	actions_types = list(/datum/action/item_action/toggle_paddles)
	armor = list("melee" = 0, "bullet" = 0, "laser" = 0, "energy" = 0, "bomb" = 0, "bio" = 0, "rad" = 0, "fire" = 50, "acid" = 50)
	sprite_sheets = list(
		"Vox" = 'icons/mob/clothing/species/vox/back.dmi'
		)

	var/paddles_on_defib = TRUE //if the paddles are on the defib (TRUE)
	var/safety = TRUE //if you can zap people with the defibs on harm mode
	var/powered = FALSE //if there's a cell in the defib with enough power for a revive, blocks paddles from reviving otherwise
	var/obj/item/twohanded/shockpaddles/paddles
	var/obj/item/stock_parts/cell/high/cell = null
	var/combat = FALSE //can we revive through space suits?

	/// Type of paddles that should be attached to this defib.
	var/obj/item/twohanded/shockpaddles/paddle_type = /obj/item/twohanded/shockpaddles


/obj/item/defibrillator/Initialize(mapload) // Base version starts without a cell for rnd
	. = ..()
	paddles = new paddle_type(src)
	update_icon(UPDATE_OVERLAYS)


/obj/item/defibrillator/Destroy()
	if(!paddles_on_defib)
		var/holder = get(paddles.loc, /mob/living/carbon/human)
		retrieve_paddles(holder)
	QDEL_NULL(paddles)
	QDEL_NULL(cell)
	return ..()


/obj/item/defibrillator/loaded/Initialize(mapload) // Loaded version starts with high-capacity cell.
	. = ..()
	cell = new(src)
	update_icon(UPDATE_OVERLAYS)


/obj/item/defibrillator/get_cell()
	return cell


/obj/item/defibrillator/update_icon(updates = ALL)
	update_power()
	..()


/obj/item/defibrillator/examine(mob/user)
	. = ..()
	. += span_info("<b>Ctrl-Click</b> to remove the paddles from the defibrillator.")


/obj/item/defibrillator/proc/update_power()
	if(cell)
		if(cell.charge < paddles.revivecost)
			powered = FALSE
		else
			powered = TRUE
	else
		powered = FALSE


/obj/item/defibrillator/update_overlays()
	. = ..()
	if(paddles_on_defib)
		. += "[icon_state]-paddles"
	if(powered)
		. += "[icon_state]-powered"
	if(!safety)
		. += "[icon_state]-emagged"
	if(powered && cell)
		var/ratio = cell.charge / cell.maxcharge
		ratio = CEILING(ratio*4, 1) * 25
		. += "[icon_state]-charge[ratio]"
	if(!cell)
		. += "[icon_state]-nocell"


/obj/item/defibrillator/CheckParts(list/parts_list)
	..()
	cell = locate(/obj/item/stock_parts/cell) in contents
	update_icon(UPDATE_OVERLAYS)


/obj/item/defibrillator/ui_action_click(mob/user)
	if(!ishuman(user) || !Adjacent(user))
		return

	toggle_paddles(user)


/obj/item/defibrillator/CtrlClick(mob/user)
	if(!ishuman(user) || !Adjacent(user))
		return

	toggle_paddles(user)


/obj/item/defibrillator/attackby(obj/item/W, mob/user, params)
	if(istype(W, /obj/item/stock_parts/cell))
		var/obj/item/stock_parts/cell/C = W
		if(cell)
			to_chat(user, span_notice("[src] already has a cell."))
		else
			if(C.maxcharge < paddles.revivecost)
				to_chat(user, span_notice("[src] requires a higher capacity cell."))
				return
			if(!user.drop_transfer_item_to_loc(W, src))
				return

			cell = W
			update_icon(UPDATE_OVERLAYS)
			to_chat(user, span_notice("You install a cell in [src]."))

	else if(W == paddles)
		toggle_paddles(user)

	else
		return ..()


/obj/item/defibrillator/screwdriver_act(mob/living/user, obj/item/I)
	if(!cell)
		to_chat(user, span_notice("[src] doesn't have a cell."))
		return

	// we want an infinite power cell to stay inside (used in advanced compact defib)
	if(istype(cell, /obj/item/stock_parts/cell/infinite))
		to_chat(user, span_notice("[src] somehow resists your attempt to remove a cell."))
		return

	cell.update_icon()
	cell.forceMove_turf()
	cell = null
	I.play_tool_sound(src)
	to_chat(user, span_notice("You remove the cell from [src]."))
	update_icon(UPDATE_OVERLAYS)
	return TRUE


/obj/item/defibrillator/emag_act(user)
	if(safety)
		add_attack_logs(user, src, "emagged")
		safety = FALSE
		if(user)
			to_chat(user, span_warning("You silently disable [src]'s safety protocols with the card."))
	else
		add_attack_logs(user, src, "un-emagged")
		safety = TRUE
		to_chat(user, span_notice("You silently enable [src]'s safety protocols with the card."))
	update_icon(UPDATE_OVERLAYS)


/obj/item/defibrillator/emp_act(severity)
	if(cell)
		deductcharge(1000 / severity)
	if(safety)
		safety = FALSE
		visible_message(span_notice("[src] beeps: Safety protocols disabled!"))
		playsound(get_turf(src), 'sound/machines/defib_saftyoff.ogg', 50, FALSE)
	else
		safety = TRUE
		visible_message(span_notice("[src] beeps: Safety protocols enabled!"))
		playsound(get_turf(src), 'sound/machines/defib_saftyon.ogg', 50, FALSE)
	update_icon(UPDATE_OVERLAYS)
	..()


/obj/item/defibrillator/verb/toggle_paddles_verb()
	set name = "Toggle Paddles"
	set category = "Object"
	set src in oview(1)

	toggle_paddles(usr)


/obj/item/defibrillator/proc/toggle_paddles(mob/living/carbon/human/user = usr)
	if(!paddles)
		to_chat(user, span_warning("[src] has no paddles!"))
		return

	if(paddles_on_defib)
		dispence_paddles(user)
	else
		retrieve_paddles(user)

	for(var/datum/action/action as anything in actions)
		action.UpdateButtonIcon()


/obj/item/defibrillator/proc/dispence_paddles(mob/living/carbon/human/user)
	if(!paddles || !paddles_on_defib || !ishuman(user) || user.incapacitated())
		return

	//Detach the paddles into the user's hands
	var/obj/item/organ/external/hand_left = user.get_organ(BODY_ZONE_PRECISE_L_HAND)
	var/obj/item/organ/external/hand_right = user.get_organ(BODY_ZONE_PRECISE_R_HAND)

	if((!hand_left || !hand_left.is_usable()) && (!hand_right || !hand_right.is_usable()))
		to_chat(user, span_warning("You can't use your hands to take out the paddles!"))
		return

	paddles.loc = get_turf(src)	// we need this to play animation properly
	if(!user.put_in_hands(paddles, ignore_anim = FALSE))
		paddles.loc = src
		to_chat(user, span_warning("You need a free hand to hold the paddles!"))
		return

	paddles_on_defib = FALSE
	paddles.update_icon(UPDATE_ICON_STATE)
	update_icon(UPDATE_OVERLAYS)


/obj/item/defibrillator/proc/retrieve_paddles(mob/user)
	if(!paddles || paddles_on_defib)
		return
	if(user?.is_in_hands(paddles))
		user.drop_item_ground(paddles)
	paddles.do_pickup_animation(src)
	paddles.forceMove(src)
	paddles_on_defib = TRUE
	update_icon(UPDATE_OVERLAYS)
	paddles.update_icon(UPDATE_ICON_STATE)


/obj/item/defibrillator/equipped(mob/user, slot)
	. = ..()
	if(slot != slot_back)
		retrieve_paddles(user)


/obj/item/defibrillator/item_action_slot_check(slot, mob/user)
	return slot == slot_back


/obj/item/defibrillator/proc/deductcharge(chrgdeductamt)
	if(cell)
		if(cell.charge < (paddles.revivecost+chrgdeductamt))
			powered = FALSE
			update_icon(UPDATE_OVERLAYS)
		if(cell.use(chrgdeductamt))
			update_icon(UPDATE_OVERLAYS)
			return TRUE
		else
			update_icon(UPDATE_OVERLAYS)
			return FALSE

/obj/item/defibrillator/compact
	name = "compact defibrillator"
	desc = "A belt-equipped defibrillator that can be rapidly deployed."
	icon_state = "defibcompact"
	item_state = "defibcompact"
	w_class = WEIGHT_CLASS_NORMAL
	slot_flags = SLOT_BELT
	origin_tech = "biotech=5"

/obj/item/defibrillator/compact/item_action_slot_check(slot, mob/user)
	if(slot == slot_belt)
		return TRUE

/obj/item/defibrillator/compact/loaded/Initialize(mapload)
	. = ..()
	cell = new(src)
	update_icon(UPDATE_OVERLAYS)

/obj/item/defibrillator/compact/combat
	name = "combat defibrillator"
	desc = "A belt-equipped blood-red defibrillator that can be rapidly deployed. Does not have the restrictions or safeties of conventional defibrillators and can revive through space suits."
	icon_state = "defibcombat"
	item_state = "defibcombat"
	paddle_type = /obj/item/twohanded/shockpaddles/syndicate
	combat = TRUE
	safety = FALSE

/obj/item/defibrillator/compact/combat/loaded/Initialize(mapload)
	. = ..()
	cell = new(src)
	update_icon(UPDATE_OVERLAYS)

/obj/item/defibrillator/compact/advanced
	name = "advanced compact defibrillator"
	desc = "A belt-mounted state-of-the-art defibrillator that can be rapidly deployed in all environments. Uses an experimental self-charging cell, meaning that it will (probably) never stop working. Can be used to defibrillate through space suits. It is impossible to damage."
	icon_state = "defibnt"
	item_state = "defibnt"
	paddle_type = /obj/item/twohanded/shockpaddles/advanced
	combat = TRUE
	safety = TRUE
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | ACID_PROOF //Objective item, better not have it destroyed.
	var/next_emp_message //to prevent spam from the emagging message on the advanced defibrillator


/obj/item/defibrillator/compact/advanced/attackby(obj/item/W, mob/user, params)
	if(W == paddles)
		toggle_paddles(user)


/obj/item/defibrillator/compact/advanced/loaded/Initialize(mapload)
	. = ..()
	cell = new /obj/item/stock_parts/cell/infinite(src)
	update_icon(UPDATE_OVERLAYS)


/obj/item/defibrillator/compact/advanced/emp_act(severity)
	if(world.time > next_emp_message)
		atom_say("Warning: Electromagnetic pulse detected. Integrated shielding prevented all potential hardware damage.")
		playsound(src, 'sound/machines/defib_saftyon.ogg', 50)
		next_emp_message = world.time + 5 SECONDS

//paddles

/obj/item/twohanded/shockpaddles
	name = "defibrillator paddles"
	desc = "A pair of plastic-gripped paddles with flat metal surfaces that are used to deliver powerful electric shocks."
	icon_state = "defibpaddles"
	item_state = "defibpaddles"
	force = 0
	throwforce = 6
	w_class = WEIGHT_CLASS_BULKY
	resistance_flags = INDESTRUCTIBLE
	toolspeed = 1
	flags = ABSTRACT

	var/revivecost = 1000
	var/cooldown = FALSE
	var/busy = FALSE
	var/obj/item/defibrillator/defib

/obj/item/twohanded/shockpaddles/advanced
	name = "advanced defibrillator paddles"
	desc = "A pair of high-tech paddles with flat plasteel surfaces that are used to deliver powerful electric shocks. They possess the ability to penetrate armor to deliver shock."
	icon_state = "ntpaddles"
	item_state = "ntpaddles"

/obj/item/twohanded/shockpaddles/syndicate
	name = "combat defibrillator paddles"
	desc = "A pair of high-tech paddles with flat plasteel surfaces to revive deceased operatives (unless they exploded). They possess both the ability to penetrate armor and to deliver powerful or disabling shocks offensively."
	icon_state = "syndiepaddles"
	item_state = "syndiepaddles"


/obj/item/twohanded/shockpaddles/New(mainunit)
	..()
	check_defib_exists(mainunit)


/obj/item/twohanded/shockpaddles/proc/spend_charge()
	defib.deductcharge(revivecost)


/obj/item/twohanded/shockpaddles/proc/trigger_cooldown(mob/user)
	cooldown = TRUE
	update_icon(UPDATE_ICON_STATE)
	addtimer(CALLBACK(src, PROC_REF(on_cooldown_end), user), 5 SECONDS)


/obj/item/twohanded/shockpaddles/proc/on_cooldown_end(mob/living/silicon/robot/user)
	var/check_cell = isrobot(user) ? user.cell.charge : defib.cell.charge
	if(check_cell >= revivecost)
		user.visible_message(span_notice("[src] beeps: Unit ready."))
		playsound(get_turf(src), 'sound/machines/defib_ready.ogg', 50)
	else
		user.visible_message(span_notice("[src] beeps: Charge depleted."))
		playsound(get_turf(src), 'sound/machines/defib_failed.ogg', 50)
	cooldown = FALSE
	update_icon(UPDATE_ICON_STATE)


/obj/item/twohanded/shockpaddles/update_icon_state()
	var/is_wielded = HAS_TRAIT(src, TRAIT_WIELDED)
	icon_state = "[initial(icon_state)][is_wielded][cooldown ? "_cooldown" : ""]"
	item_state = "[initial(icon_state)][is_wielded]"


/obj/item/twohanded/shockpaddles/suicide_act(mob/user)
	user.visible_message(span_suicide("[user] is putting the live paddles on [user.p_their()] chest! It looks like [user.p_theyre()] trying to commit suicide."))
	defib.deductcharge(revivecost)
	playsound(get_turf(src), 'sound/machines/defib_zap.ogg', 50, 1, -1)
	return OXYLOSS


/obj/item/twohanded/shockpaddles/dropped(mob/user, silent = FALSE)
	. = ..()
	if(defib)
		defib.toggle_paddles(user)
		if(!silent)
			to_chat(user, span_notice("The paddles snap back into the main unit."))


/obj/item/twohanded/shockpaddles/equip_to_best_slot(mob/user, force = FALSE)
	user.drop_item_ground(src)


/obj/item/twohanded/shockpaddles/on_mob_move(dir, mob/user)
	if(defib && !in_range(defib, src))
		user.drop_item_ground(src, force = TRUE)


/obj/item/twohanded/shockpaddles/proc/check_defib_exists(obj/item/defibrillator/mainunit)
	if(!mainunit || !istype(mainunit))	//To avoid weird issues from admin spawns
		qdel(src)
		return
	loc = mainunit
	defib = mainunit


/obj/item/twohanded/shockpaddles/attack(mob/M, mob/user)
	var/tobehealed
	var/threshold = -HEALTH_THRESHOLD_DEAD
	var/mob/living/carbon/human/H = M

	var/is_combat_borg = FALSE
	if(isrobot(user))
		var/mob/living/silicon/robot/R = user
		is_combat_borg = istype(R.module, /obj/item/robot_module/syndicate_medical) || istype(R.module, /obj/item/robot_module/ninja)

	var/ignores_hardsuits = defib?.combat || is_combat_borg

	if(busy)
		return
	if(!isrobot(user) && !defib.powered)
		user.visible_message(span_notice("[defib] beeps: Unit is unpowered."))
		playsound(get_turf(src), 'sound/machines/defib_failed.ogg', 50, 0)
		return
	if(!isrobot(user) && !wielded)
		to_chat(user, span_boldnotice("You need to wield the paddles in both hands before you can use them on someone!"))
		return
	if(cooldown)
		to_chat(user, span_notice("[defib || src] is recharging."))
		return
	if(!ishuman(M))
		if(isrobot(user))
			to_chat(user, span_notice("This unit is only designed to work on humanoid lifeforms."))
		else
			to_chat(user, span_notice("The instructions on [defib] don't mention how to revive that..."))
		return
	else
		var/can_harm
		if(isrobot(user))
			var/mob/living/silicon/robot/R = user
			can_harm = R.emagged || is_combat_borg
		else
			can_harm = !defib.safety

		if(user.a_intent == INTENT_HARM && can_harm)
			busy = TRUE
			H.visible_message(
				span_danger("[user] has touched [H.name] with [src]!"),
				span_userdanger("[user] has touched [H.name] with [src]!"),
			)
			H.adjustStaminaLoss(50)
			H.Weaken(4 SECONDS)
			playsound(get_turf(src), 'sound/machines/defib_zap.ogg', 50, 1, -1)
			H.emote("gasp")
			if(!H.undergoing_cardiac_arrest() && (prob(10) || defib?.combat)) // Your heart explodes.
				H.set_heartattack(TRUE)
			H.shock_internal_organs(100)
			add_attack_logs(user, M, "Stunned with [src]")
			busy = FALSE
			spend_charge(user)
			trigger_cooldown(user)
			return
		user.visible_message(
			span_warning("[user] begins to place [src] on [M.name]'s chest."),
			span_warning("You begin to place [src] on [M.name]'s chest."),
		)
		busy = TRUE
		if(do_after(user, 30 * toolspeed * gettoolspeedmod(user), target = M)) //beginning to place the paddles on patient's chest to allow some time for people to move away to stop the process
			user.visible_message(
				span_notice("[user] places [src] on [M.name]'s chest."),
				span_warning("You place [src] on [M.name]'s chest."),
			)
			playsound(get_turf(src), 'sound/machines/defib_charge.ogg', 50, 0)
			var/mob/dead/observer/ghost = H.get_ghost(TRUE)
			if(ghost && !ghost.client)
				// In case the ghost's not getting deleted for some reason
				H.key = ghost.key
				log_runtime(EXCEPTION("Ghost of name [ghost.name] is bound to [H.real_name], but lacks a client. Deleting ghost."), src)

				QDEL_NULL(ghost)
			var/tplus = world.time - H.timeofdeath
			var/tlimit = DEFIB_TIME_LIMIT
			var/tloss = DEFIB_TIME_LOSS
			if(do_after(user, 20 * toolspeed * gettoolspeedmod(user), target = M)) //placed on chest and short delay to shock for dramatic effect, revive time is 5sec total
				for(var/obj/item/carried_item in H.contents)
					if(istype(carried_item, /obj/item/clothing/suit/space))
						if(!ignores_hardsuits)
							user.visible_message(span_notice("[defib || src] buzzes: Patient's chest is obscured. Operation aborted."))
							playsound(get_turf(src), 'sound/machines/defib_failed.ogg', 50, 0)
							busy = FALSE
							return
				if(H.undergoing_cardiac_arrest())
					if(!H.get_int_organ(/obj/item/organ/internal/heart) && !H.get_int_organ(/obj/item/organ/internal/brain/slime)) //prevents defibing someone still alive suffering from a heart attack attack if they lack a heart
						user.visible_message(span_boldnotice("[defib || src] buzzes: Resuscitation failed - Failed to pick up any heart electrical activity."))
						playsound(get_turf(src), 'sound/machines/defib_failed.ogg', 50, 0)
						busy = FALSE
						return
					else
						var/obj/item/organ/internal/heart/heart = H.get_int_organ(/obj/item/organ/internal/heart)
						if(heart.is_dead())
							user.visible_message(span_boldnotice("[defib || src] buzzes: Resuscitation failed - Heart necrosis detected."))
							playsound(get_turf(src), 'sound/machines/defib_failed.ogg', 50, 0)
							busy = FALSE
							return
						H.set_heartattack(FALSE)
						H.shock_internal_organs(100)
						user.visible_message(span_boldnotice("[defib || src] pings: Cardiac arrhythmia corrected."))
						M.visible_message(span_warning("[M]'s body convulses a bit."))
						playsound(get_turf(src), 'sound/machines/defib_zap.ogg', 50, 1, -1)
						playsound(get_turf(src), "bodyfall", 50, 1)
						playsound(get_turf(src), 'sound/machines/defib_success.ogg', 50, 0)
						busy = FALSE
						spend_charge(user)
						trigger_cooldown(user)
						return
				if(H.stat == DEAD)
					var/health = H.health
					M.visible_message(span_warning("[M]'s body convulses a bit."))
					playsound(get_turf(src), "bodyfall", 50, 1)
					playsound(get_turf(src), 'sound/machines/defib_zap.ogg', 50, 1, -1)
					var/total_cloneloss = H.cloneloss
					var/total_bruteloss = 0
					var/total_burnloss = 0
					for(var/obj/item/organ/external/O as anything in H.bodyparts)
						total_bruteloss += O.brute_dam
						total_burnloss += O.burn_dam
					if(total_cloneloss <= 180 && total_bruteloss <= 180 && total_burnloss <= 180 && !H.suiciding && !ghost && tplus < tlimit && !(NOCLONE in H.mutations) && (H.mind && H.mind.is_revivable()) && (H.get_int_organ(/obj/item/organ/internal/heart) || H.get_int_organ(/obj/item/organ/internal/brain/slime)))
						tobehealed = min(health + threshold, 0) // It's HILARIOUS without this min statement, let me tell you
						tobehealed -= 5 //They get 5 of each type of damage healed so excessive combined damage will not immediately kill them after they get revived
						H.adjustOxyLoss(tobehealed)
						H.adjustToxLoss(tobehealed)
						user.visible_message(span_boldnotice("[defib || src] pings: Resuscitation successful."))
						playsound(get_turf(src), 'sound/machines/defib_success.ogg', 50, 0)
						H.update_revive(TRUE, TRUE)
						H.KnockOut()
						H.Paralyse(10 SECONDS)
						H.emote("gasp")
						if(tplus > tloss)
							H.setBrainLoss( max(0, min(99, ((tlimit - tplus) / tlimit * 100))))

						if(ishuman(H.pulledby)) // for some reason, pulledby isnt a list despite it being possible to be pulled by multiple people
							excess_shock(user, H, H.pulledby)
						for(var/obj/item/grab/G in H.grabbed_by)
							if(ishuman(G.assailant))
								excess_shock(user, H, G.assailant)

						H.shock_internal_organs(100)
						H.med_hud_set_health()
						H.med_hud_set_status()
						add_attack_logs(user, M, "Revived with [src]")
					else
						if(tplus > tlimit|| !H.get_int_organ(/obj/item/organ/internal/heart))
							user.visible_message(span_boldnotice("[defib || src] buzzes: Resuscitation failed - Heart tissue damage beyond point of no return for defibrillation."))
						else if(total_cloneloss > 180 || total_bruteloss > 180 || total_burnloss > 180)
							user.visible_message(span_boldnotice("[defib || src] buzzes: Resuscitation failed - Severe tissue damage detected."))
						else if(ghost)
							if(!ghost.can_reenter_corpse) // DNR or AntagHUD
								user.visible_message(span_notice("[defib || src] buzzes: Resucitation failed: No electrical brain activity detected."))
							else
								user.visible_message(span_notice("[defib || src] buzzes: Resuscitation failed: Patient's brain is unresponsive. Further attempts may succeed."))
								to_chat(ghost, "[span_ghostalert("Your heart is being defibrillated. Return to your body if you want to be revived!")] (Verbs -> Ghost -> Re-enter corpse)")
								window_flash(ghost.client)
								SEND_SOUND(ghost, 'sound/effects/genetics.ogg')
						else
							user.visible_message(span_notice("[defib || src] buzzes: Resuscitation failed."))
						playsound(get_turf(src), 'sound/machines/defib_failed.ogg', 50, 0)

					spend_charge(user)
					trigger_cooldown(user)
				else
					user.visible_message(span_notice("[defib || src] buzzes: Patient is not in a valid state. Operation aborted."))
					playsound(get_turf(src), 'sound/machines/defib_failed.ogg', 50, 0)
		busy = FALSE
/*
 * user = the person using the defib
 * origin = person being revived
 * affecting = person being shocked with excess energy from the defib
*/
/obj/item/twohanded/shockpaddles/proc/excess_shock(mob/user, mob/living/carbon/human/origin, mob/living/carbon/human/affecting)
	if(user == affecting)
		return

	if(electrocute_mob(affecting, defib.cell, origin)) // shock anyone touching them >:)
		var/obj/item/organ/internal/heart/HE = affecting.get_organ_slot(INTERNAL_ORGAN_HEART)
		if(HE.parent_organ_zone == BODY_ZONE_CHEST && affecting.has_both_hands()) // making sure the shock will go through their heart (drask hearts are in their head), and that they have both arms so the shock can cross their heart inside their chest
			var/obj/item/organ/external/bodypart_upper = affecting.hand ? affecting.get_organ(BODY_ZONE_L_ARM) : affecting.get_organ(BODY_ZONE_R_ARM)
			var/obj/item/organ/external/bodypart_lower = affecting.hand ? affecting.get_organ(BODY_ZONE_PRECISE_L_HAND) : affecting.get_organ(BODY_ZONE_PRECISE_R_HAND)
			affecting.visible_message(
				span_danger("[affecting]'s entire body shakes as a shock travels up their arm!"),
				span_userdanger("You feel a powerful shock travel up your [bodypart_upper.name] and back down your [bodypart_lower.name]!"),
			)
			affecting.set_heartattack(TRUE)

/obj/item/twohanded/shockpaddles/borg
	desc = "A pair of mounted paddles with flat metal surfaces that are used to deliver powerful electric shocks."
	icon_state = "defibpaddles0"
	item_state = "defibpaddles0"

/obj/item/twohanded/shockpaddles/borg/check_defib_exists(obj/item/defibrillator/mainunit)
	// No-op.

/obj/item/twohanded/shockpaddles/borg/dropped(mob/user, silent = FALSE)
	SHOULD_CALL_PARENT(FALSE)
	// No-op.

/obj/item/twohanded/shockpaddles/borg/spend_charge(mob/user)
	var/mob/living/silicon/robot/R = user
	R.cell.use(revivecost)

/obj/item/twohanded/shockpaddles/borg/attack_self()
	// Standard two-handed weapon behavior is disabled.

/obj/item/twohanded/shockpaddles/borg/update_icon_state()
	icon_state = "[initial(icon_state)][cooldown ? "_cooldown" : ""]"

