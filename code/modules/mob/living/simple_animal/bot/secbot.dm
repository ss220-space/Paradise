#define BATON_COOLDOWN 3.5 SECONDS
#define SPEAK_COOLDOWN 10 SECONDS

/mob/living/simple_animal/bot/secbot
	name = "\improper Securitron"
	desc = "A little security robot.  He looks less than thrilled."
	icon = 'icons/obj/aibots.dmi'
	icon_state = "secbot0"
	density = FALSE
	anchored = FALSE
	health = 25
	maxHealth = 25
	damage_coeff = list(BRUTE = 0.5, BURN = 0.7, TOX = 0, CLONE = 0, STAMINA = 0, OXY = 0)
	pass_flags = PASSMOB|PASSFLAPS

	allow_pai = FALSE

	radio_channel = "Security" //Security channel
	bot_type = SEC_BOT
	bot_filter = RADIO_SECBOT
	model = "Securitron"
	bot_purpose = "seek out criminals, handcuff them, and report their location to security"
	bot_core_type = /obj/machinery/bot_core/secbot
	window_id = "autosec"
	window_name = "Automatic Security Unit v1.6"
	path_image_color = "#FF0000"
	data_hud_type = DATA_HUD_SECURITY_ADVANCED

	var/base_icon = "secbot"
	var/mob/living/carbon/target
	var/oldtarget_name
	var/threatlevel = 0
	/// Loc of target when arrested.
	var/target_lastloc
	/// Delay between checks for target.
	var/last_found
	/// When making an arrest, should it notify everyone on the security channel?
	var/declare_arrests = TRUE
	/// If `TRUE`, arrest people with no IDs.
	var/idcheck = FALSE
	/// If `TRUE`, arrest people for weapons if they don't have access.
	var/weaponscheck = FALSE
	/// Does it check security records?
	var/check_records = TRUE
	/// If `TRUE`, don't handcuff.
	var/arrest_type = FALSE
	//If `TRUE`, beat instead of stun
	var/harmbaton = FALSE
	/// If `TRUE`, flash lights
	var/flashing_lights = FALSE
	var/baton_delayed = FALSE
	var/prev_flashing_lights = FALSE
	var/speak_cooldown = FALSE


/mob/living/simple_animal/bot/secbot/beepsky
	name = "Officer Beepsky"
	desc = "It's Officer Beepsky! Powered by a potato and a shot of whiskey."
	idcheck = FALSE
	weaponscheck = FALSE
	auto_patrol = TRUE


/mob/living/simple_animal/bot/secbot/beepsky/explode()
	var/turf/Tsec = get_turf(src)
	new /obj/item/stock_parts/cell/potato(Tsec)
	var/obj/item/reagent_containers/food/drinks/drinkingglass/S = new(Tsec)
	S.reagents.add_reagent("whiskey", 15)
	S.on_reagent_change()
	..()


/mob/living/simple_animal/bot/secbot/pingsky
	name = "Officer Pingsky"
	desc = "It's Officer Pingsky! Delegated to satellite guard duty for harbouring anti-human sentiment."
	radio_channel = "AI Private"


/mob/living/simple_animal/bot/secbot/ofitser
	name = "Prison Ofitser"
	desc = "It's Prison Ofitser! Powered by the tears and sweat of prisoners."
	idcheck = FALSE
	weaponscheck = TRUE
	auto_patrol = TRUE


/mob/living/simple_animal/bot/secbot/buzzsky
	name = "Officer Buzzsky"
	desc = "It's Officer Buzzsky! Rusted and falling apart, he seems less than thrilled with the crew for leaving him in his current state."
	base_icon = "rustbot"
	icon_state = "rustbot0"
	declare_arrests = FALSE
	arrest_type = TRUE
	harmbaton = TRUE
	emagged = 2


/mob/living/simple_animal/bot/secbot/armsky
	name = "Sergeant-at-Armsky"
	health = 45
	idcheck = TRUE
	arrest_type = TRUE
	weaponscheck = TRUE
	auto_patrol = TRUE


/mob/living/simple_animal/bot/secbot/podsky
	name = "Officer Podsky"
	health = 45
	idcheck = TRUE
	arrest_type = TRUE
	weaponscheck = TRUE


/mob/living/simple_animal/bot/secbot/Initialize(mapload)
	. = ..()
	icon_state = "[base_icon][on]"
	var/datum/job/detective/J = new/datum/job/detective
	access_card.access += J.get_access()
	prev_access = access_card.access

	AddSpell(new /obj/effect/proc_holder/spell/bot_speed)

	//SECHUD
	var/datum/atom_hud/secsensor = GLOB.huds[DATA_HUD_SECURITY_ADVANCED]
	secsensor.add_hud_to(src)

	var/static/list/loc_connections = list(
		COMSIG_ATOM_ENTERED = PROC_REF(on_entered),
	)
	AddElement(/datum/element/connect_loc, loc_connections)


/mob/living/simple_animal/bot/secbot/turn_on()
	..()
	icon_state = "[base_icon][on]"


/mob/living/simple_animal/bot/secbot/turn_off()
	..()
	icon_state = "[base_icon][on]"


/mob/living/simple_animal/bot/secbot/bot_reset()
	..()
	target = null
	oldtarget_name = null
	set_anchored(FALSE)
	SSmove_manager.stop_looping(src)
	set_path(null)
	last_found = world.time


/mob/living/simple_animal/bot/secbot/set_custom_texts()
	text_hack = "You overload [name]'s target identification system."
	text_dehack = "You reboot [name] and restore the target identification."
	text_dehack_fail = "[name] refuses to accept your authority!"


/mob/living/simple_animal/bot/secbot/show_controls(mob/M)
	ui_interact(M)


/mob/living/simple_animal/bot/secbot/ui_interact(mob/user, datum/tgui/ui = null)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "BotSecurity", name)
		ui.open()


/mob/living/simple_animal/bot/secbot/ui_data(mob/user)
	var/list/data = list(
		"locked" = locked, // controls, locked or not
		"noaccess" = topic_denied(user), // does the current user have access? admins, silicons etc can still access bots with locked controls
		"maintpanel" = open,
		"on" = on,
		"autopatrol" = auto_patrol,
		"painame" = paicard ? paicard.pai.name : null,
		"canhack" = canhack(user),
		"emagged" = emagged, // this is an int, NOT a boolean
		"remote_disabled" = remote_disabled, // -- STUFF BELOW HERE IS SPECIFIC TO THIS BOT
		"check_id" = idcheck,
		"check_weapons" = weaponscheck,
		"check_warrant" = check_records,
		"arrest_mode" = arrest_type, // detain or arrest
		"arrest_declare" = declare_arrests // announce arrests on radio
	)
	return data


/mob/living/simple_animal/bot/secbot/ui_act(action, params)
	if (..())
		return
	if(topic_denied(usr))
		to_chat(usr, "<span class='warning'>[src]'s interface is not responding!</span>")
		return
	add_fingerprint(usr)
	. = TRUE
	switch(action)
		if("power")
			if(on)
				turn_off()
			else
				turn_on()
		if("autopatrol")
			auto_patrol = !auto_patrol
			bot_reset()
		if("hack")
			handle_hacking(usr)
		if("disableremote")
			remote_disabled = !remote_disabled
		if("authweapon")
			weaponscheck = !weaponscheck
		if("authid")
			idcheck = !idcheck
		if("authwarrant")
			check_records = !check_records
		if("arrtype")
			arrest_type = !arrest_type
		if("arrdeclare")
			declare_arrests = !declare_arrests
		if("ejectpai")
			ejectpai()

/mob/living/simple_animal/bot/secbot/update_icon_state()
	icon_state = "[base_icon][on]"

/mob/living/simple_animal/bot/secbot/proc/retaliate(mob/living/carbon/human/H)
	threatlevel = H.assess_threat(src)
	threatlevel += 6
	if(threatlevel >= 4)
		target = H
		mode = BOT_HUNT


/mob/living/simple_animal/bot/secbot/attack_hand(mob/living/carbon/human/H)
	if(H.a_intent == INTENT_HARM || H.a_intent == INTENT_DISARM)
		retaliate(H)
	return ..()


/mob/living/simple_animal/bot/secbot/attackby(obj/item/I, mob/user, params)
	var/current_health = health
	. = ..()
	if(ATTACK_CHAIN_CANCEL_CHECK(.) || health >= current_health)
		return .
	retaliate(user)


/mob/living/simple_animal/bot/secbot/emag_act(mob/user)
	..()
	if(emagged == 2)
		if(user)
			to_chat(user, span_danger("You short out [src]'s target assessment circuits."))
			oldtarget_name = user.name
		audible_message(span_danger("[src] buzzes oddly!"))
		declare_arrests = FALSE
		icon_state = "[base_icon][on]"


/mob/living/simple_animal/bot/secbot/bullet_act(obj/item/projectile/Proj)
	if(istype(Proj ,/obj/item/projectile/beam) || istype(Proj,/obj/item/projectile/bullet))
		if((Proj.damage_type == BURN) || (Proj.damage_type == BRUTE))
			if(!Proj.nodamage && Proj.damage < src.health)
				retaliate(Proj.firer)
	..()


/mob/living/simple_animal/bot/secbot/UnarmedAttack(atom/A)
	if(!on || !can_unarmed_attack())
		return
	if(iscarbon(A))
		var/mob/living/carbon/C = A
		if((C.staminaloss < 110 || arrest_type) && !baton_delayed)
			stun_attack(A)
		else if(C.has_organ_for_slot(ITEM_SLOT_HANDCUFFED) && !C.handcuffed)
			cuff(A)
	else
		..()


/mob/living/simple_animal/bot/secbot/hitby(atom/movable/AM, skipcatch = FALSE, hitpush = TRUE, blocked = FALSE, datum/thrownthing/throwingdatum)
	if(isitem(AM))
		var/obj/item/I = AM
		var/mob/thrower = locateUID(I.thrownby)
		if(I.throwforce < health && ishuman(thrower))
			retaliate(thrower)
	..()


/mob/living/simple_animal/bot/secbot/proc/cuff(mob/living/carbon/C)
	mode = BOT_ARREST
	playsound(loc, 'sound/weapons/cablecuff.ogg', 30, TRUE, -2)
	C.visible_message(span_danger("[src] is trying to put zipties on [C]!"),
					span_userdanger("[src] is trying to put zipties on you!"))
	addtimer(CALLBACK(src, PROC_REF(cuff_callback), C), 6 SECONDS)


/mob/living/simple_animal/bot/secbot/proc/cuff_callback(mob/living/carbon/C)
	if(QDELETED(src) || QDELETED(C))
		return

	if(!Adjacent(C) || !isturf(C.loc) || C.handcuffed)
		return

	C.apply_restraints(new /obj/item/restraints/handcuffs/cable/zipties/used(null), ITEM_SLOT_HANDCUFFED, TRUE)

	playsound(loc, pick('sound/voice/bgod.ogg', 'sound/voice/biamthelaw.ogg', 'sound/voice/bsecureday.ogg', 'sound/voice/bradio.ogg', 'sound/voice/binsult.ogg', 'sound/voice/bcreep.ogg'), 50, 0)
	back_to_idle()


/mob/living/simple_animal/bot/secbot/proc/stun_attack(mob/living/carbon/C)
	playsound(loc, 'sound/weapons/egloves.ogg', 50, TRUE, -1)
	if(harmbaton)
		playsound(loc, 'sound/weapons/genhit1.ogg', 50, 1, -1)
	do_attack_animation(C)
	icon_state = "[base_icon]-c"
	addtimer(VARSET_CALLBACK(src, icon_state, "[base_icon][on]"), 0.2 SECONDS)
	var/threat = C.assess_threat(src)
	if(ishuman(C) && harmbaton) // Bots with harmbaton enabled become shitcurity. - Dave
		C.apply_damage(10, BRUTE)
	C.SetStuttering(10 SECONDS)
	C.Weaken(4 SECONDS)
	C.apply_damage(45, STAMINA)
	baton_delayed = TRUE
	addtimer(VARSET_CALLBACK(src, baton_delayed, FALSE), BATON_COOLDOWN)
	add_attack_logs(src, C, "stunned")
	if(declare_arrests)
		var/area/location = get_area(src)
		if(!speak_cooldown)
			speak("[arrest_type ? "Detaining" : "Arresting"] level [threat] scumbag <b>[C]</b> in [location].", radio_channel)
			speak_cooldown = TRUE
			addtimer(VARSET_CALLBACK(src, speak_cooldown, FALSE), SPEAK_COOLDOWN)
	C.visible_message(span_danger("[src] has [harmbaton ? "beaten" : "stunned"] [C]!"),
					span_userdanger("[src] has [harmbaton ? "beaten" : "stunned"] you!"))


/mob/living/simple_animal/bot/secbot/Life(seconds, times_fired)
	. = ..()
	if(flashing_lights)
		switch(light_color)
			if(LIGHT_COLOR_PURE_RED)
				light_color = LIGHT_COLOR_PURE_BLUE
			if(LIGHT_COLOR_PURE_BLUE)
				light_color = LIGHT_COLOR_PURE_RED
			else
				light_color = LIGHT_COLOR_PURE_RED
		set_light_color(light_color)
	else if(prev_flashing_lights)
		light_color = LIGHT_COLOR_WHITE
		set_light_color(light_color)

	prev_flashing_lights = flashing_lights


/mob/living/simple_animal/bot/secbot/verb/toggle_flashing_lights()
	set name = "Toggle Flashing Lights"
	set category = "Object"
	set src = usr

	flashing_lights = !flashing_lights


/mob/living/simple_animal/bot/secbot/handle_automated_action()
	if(!..())
		return

	flashing_lights = mode == BOT_HUNT

	switch(mode)
		if(BOT_IDLE)		// idle
			SSmove_manager.stop_looping(src)
			set_path(null)
			look_for_perp()	// see if any criminals are in range
			if(!mode && auto_patrol)	// still idle, and set to patrol
				mode = BOT_START_PATROL	// switch to patrol mode

		if(BOT_HUNT)		// hunting for perp
			// if can't reach perp for long enough, go idle
			if(frustration >= 8)
				SSmove_manager.stop_looping(src)
				set_path(null)
				back_to_idle()
				return

			if(target)		// make sure target exists
				if(Adjacent(target) && isturf(target.loc) && !baton_delayed)	// if right next to perp
					stun_attack(target)

					mode = BOT_PREP_ARREST
					set_anchored(TRUE)
					target_lastloc = target.loc
					return

				else								// not next to perp
					var/turf/olddist = get_dist(src, target)
					SSmove_manager.move_to(src, target, 1, BOT_STEP_DELAY)
					if((get_dist(src, target)) >= (olddist))
						frustration++
					else
						frustration = 0
			else
				back_to_idle()

		if(BOT_PREP_ARREST)		// preparing to arrest target
			// see if he got away. If he's no no longer adjacent or inside a closet or about to get up, we hunt again.
			if( !Adjacent(target) || !isturf(target.loc) || world.time - target.stam_regen_start_time < 4 SECONDS && target.getStaminaLoss() <= 100)
				back_to_hunt()
				return

			if(iscarbon(target) && target.has_organ_for_slot(ITEM_SLOT_HANDCUFFED))
				if(!arrest_type)
					if(!target.handcuffed)  //he's not cuffed? Try to cuff him!
						cuff(target)
					else
						back_to_idle()
						return
			else
				back_to_idle()
				return

		if(BOT_ARREST)
			if(!target)
				set_anchored(FALSE)
				mode = BOT_IDLE
				last_found = world.time
				frustration = 0
				return

			if(target.handcuffed) //no target or target cuffed? back to idle.
				back_to_idle()
				return

			if(!Adjacent(target) || !isturf(target.loc) || (target.loc != target_lastloc && target.staminaloss < 110)) //if he's changed loc and about to get up or not adjacent or got into a closet, we prep arrest again.
				back_to_hunt()
				return
			else //Try arresting again if the target escapes.
				mode = BOT_PREP_ARREST
				set_anchored(FALSE)

		if(BOT_START_PATROL)
			look_for_perp()
			start_patrol()

		if(BOT_PATROL)
			look_for_perp()
			bot_patrol()


/mob/living/simple_animal/bot/secbot/proc/back_to_idle()
	set_anchored(FALSE)
	mode = BOT_IDLE
	target = null
	last_found = world.time
	frustration = 0
	INVOKE_ASYNC(src, PROC_REF(handle_automated_action))


/mob/living/simple_animal/bot/secbot/proc/back_to_hunt()
	set_anchored(FALSE)
	frustration = 0
	mode = BOT_HUNT
	INVOKE_ASYNC(src, PROC_REF(handle_automated_action))


/**
 * Look for a criminal in view of the bot.
 */
/mob/living/simple_animal/bot/secbot/proc/look_for_perp()
	set_anchored(FALSE)
	for(var/mob/living/carbon/C in view(7,src)) //Let's find us a criminal
		if((C.stat) || (C.handcuffed))
			continue

		if((C.name == oldtarget_name) && (world.time < last_found + 100))
			continue

		threatlevel = C.assess_threat(src)

		if(!threatlevel)
			continue

		else if(threatlevel >= 4)
			target = C
			oldtarget_name = C.name
			speak("Level [threatlevel] infraction alert!")
			playsound(loc, pick('sound/voice/bcriminal.ogg', 'sound/voice/bjustice.ogg', 'sound/voice/bfreeze.ogg'), 50, 0)
			visible_message("<b>[src]</b> points at [C.name]!")
			mode = BOT_HUNT
			INVOKE_ASYNC(src, PROC_REF(handle_automated_action))
			break
		else
			continue


/mob/living/simple_animal/bot/secbot/proc/check_for_weapons(obj/item/slot_item)
	if(slot_item && slot_item.needs_permit)
		return TRUE
	return FALSE


/mob/living/simple_animal/bot/secbot/explode()
	SSmove_manager.stop_looping(src)
	visible_message("<span class='userdanger'>[src] blows apart!</span>")
	var/turf/Tsec = get_turf(src)
	var/obj/item/secbot_assembly/Sa = new /obj/item/secbot_assembly(Tsec)
	Sa.build_step = 1
	Sa.add_overlay("hs_hole")
	Sa.created_name = name
	new /obj/item/assembly/prox_sensor(Tsec)
	new /obj/item/melee/baton/security(Tsec)
	if(prob(50))
		drop_part(robot_arm, Tsec)
	do_sparks(3, TRUE, src)
	new /obj/effect/decal/cleanable/blood/oil(loc)
	..()


/mob/living/simple_animal/bot/secbot/attack_alien(mob/living/carbon/alien/user as mob)
	..()
	if(!isalien(target))
		target = user
		mode = BOT_HUNT


/mob/living/simple_animal/bot/secbot/proc/on_entered(datum/source, mob/living/arrived, atom/old_loc, list/atom/old_locs)
	SIGNAL_HANDLER

	secbot_crossed(arrived)


/mob/living/simple_animal/bot/secbot/proc/secbot_crossed(mob/living/carbon/arrived)
	if(!iscarbon(arrived) || arrived != target || in_range(src, arrived))
		return

	arrived.visible_message(span_warning("[pick( \
						  "[arrived] dives out of [src]'s way!", \
						  "[arrived] stumbles over [src]!", \
						  "[arrived] jumps out of [src]'s path!", \
						  "[arrived] trips over [src] and falls!", \
						  "[arrived] topples over [src]!", \
						  "[arrived] leaps out of [src]'s way!")]"))
	arrived.Weaken(4 SECONDS)


/obj/machinery/bot_core/secbot
	req_access = list(ACCESS_SECURITY)



#undef SPEAK_COOLDOWN
#undef BATON_COOLDOWN
