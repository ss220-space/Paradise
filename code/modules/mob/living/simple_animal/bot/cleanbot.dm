//Cleanbot
/mob/living/simple_animal/bot/cleanbot
	name = "\improper Cleanbot"
	desc = "A little cleaning robot, he looks so excited!"
	icon = 'icons/obj/aibots.dmi'
	icon_state = "cleanbot"
	density = FALSE
	anchored = FALSE
	health = 25
	maxHealth = 25
	radio_channel = "Service" //Service
	bot_filter = RADIO_CLEANBOT
	bot_type = CLEAN_BOT
	model = "Cleanbot"
	bot_purpose = "seek out messes and clean them"
	bot_core_type = /obj/machinery/bot_core/cleanbot
	window_id = "autoclean"
	window_name = "Automatic Station Cleaner v1.1"
	pass_flags = PASSMOB|PASSFLAPS
	path_image_color = "#993299"

	///Mask color defines what color cleanbot's chassis will be. Format: "#RRGGBB"
	var/mask_color = null
	var/blood = TRUE
	var/list/target_types = list()
	var/obj/effect/decal/cleanable/target
	var/max_targets = 50 //Maximum number of targets a cleanbot can ignore.
	var/oldloc = null
	var/closest_dist
	var/closest_loc
	var/failed_steps
	var/next_dest
	var/next_dest_loc



/mob/living/simple_animal/bot/cleanbot/Initialize(mapload)
	. = ..()

	get_targets()

	var/datum/job/janitor/J = new/datum/job/janitor
	access_card.access += J.get_access()
	prev_access = access_card.access
	update_icon(UPDATE_OVERLAYS)


/mob/living/simple_animal/bot/cleanbot/update_icon_state()
	return


/mob/living/simple_animal/bot/cleanbot/update_overlays()
	. = ..()

	var/overlay_state
	switch(mode)
		if(BOT_CLEANING)
			overlay_state = "-c"
		if(BOT_IDLE)
			overlay_state = "[on]"

	. += mutable_appearance(icon, "[icon_state][overlay_state]", appearance_flags = RESET_COLOR)

	if(mask_color)
		. += mutable_appearance(icon, "cleanbot_mask", appearance_flags = RESET_COLOR, color = mask_color)


/mob/living/simple_animal/bot/cleanbot/bot_reset()
	..()
	ignore_list.Cut() //Allows the bot to clean targets it previously ignored due to being unreachable.
	target = null
	oldloc = null


/mob/living/simple_animal/bot/cleanbot/set_custom_texts()
	text_hack = "You corrupt [name]'s cleaning software."
	text_dehack = "[name]'s software has been reset!"
	text_dehack_fail = "[name] does not seem to respond to your repair code!"


/mob/living/simple_animal/bot/cleanbot/attackby(obj/item/I, mob/user, params)
	if(user.a_intent == INTENT_HARM)
		return ..()

	if(istype(I, /obj/item/toy/crayon/spraycan))
		add_fingerprint(user)
		var/obj/item/toy/crayon/spraycan/can = I
		if(can.capped)
			to_chat(user, span_warning("The cap on [can] is sealed."))
			return ATTACK_CHAIN_PROCEED|ATTACK_CHAIN_NO_AFTERATTACK
		playsound(loc, 'sound/effects/spray.ogg', 20, TRUE)
		mask_color = can.colour
		update_icon()
		return ATTACK_CHAIN_PROCEED_SUCCESS|ATTACK_CHAIN_NO_AFTERATTACK

	return ..()


/mob/living/simple_animal/bot/cleanbot/emag_act(mob/user)
	..()
	if(emagged == 2 && user)
		to_chat(user, span_danger("[src] buzzes and beeps."))


/mob/living/simple_animal/bot/cleanbot/process_scan(obj/effect/decal/cleanable/D)
	for(var/T in target_types)
		if(istype(D, T))
			if(locate(src.type) in D.loc)
				return FALSE
			return D


/mob/living/simple_animal/bot/cleanbot/handle_automated_action()
	if(!..())
		return

	if(mode == BOT_CLEANING)
		return

	if(emagged == 2) //Emag functions
		if(issimulatedturf(loc))
			if(prob(10)) //Wets floors randomly
				var/turf/simulated/T = loc
				T.MakeSlippery(TURF_WET_WATER, 80 SECONDS)

			if(prob(5)) //Spawns foam!
				visible_message(span_danger("[src] whirs and bubbles violently, before releasing a plume of froth!"))
				new /obj/effect/particle_effect/foam(loc)

	else if(prob(5))
		audible_message("[src] makes an excited beeping booping sound!")

	if(!target) //Search for cleanables it can see.
		target = scan(/obj/effect/decal/cleanable)

	var/mob/living/simple_animal/bot/cleanbot/otherbot
	if(target)
		otherbot = locate(src.type) in target.loc

	if(otherbot && (src != otherbot) && otherbot.mode == BOT_CLEANING)
		target = null
		path = list()

	if(!target && auto_patrol) //Search for cleanables it can see.
		if(mode == BOT_IDLE || mode == BOT_START_PATROL)
			start_patrol()

		if(mode == BOT_PATROL)
			bot_patrol()

	if(target && loc == get_turf(target))
		start_clean(target)
		path = list()
		target = null

	if(target)
		if(!path || !length(path)) //No path, need a new one
			//Try to produce a path to the target, and ignore airlocks to which it has access.
			path = get_path_to(src, target, max_distance = 30, access = access_card.GetAccess())
			if(!bot_move(target))
				add_to_ignore(target)
				target = null
				path = list()
				return
			mode = BOT_MOVING

		else if(!bot_move(target))
			target = null
			mode = BOT_IDLE
			return

	oldloc = loc


/mob/living/simple_animal/bot/cleanbot/proc/get_targets()
	target_types = new/list()

	target_types += /obj/effect/decal/cleanable/blood/oil
	target_types += /obj/effect/decal/cleanable/vomit
	target_types += /obj/effect/decal/cleanable/blood/gibs/robot
	target_types += /obj/effect/decal/cleanable/crayon
	target_types += /obj/effect/decal/cleanable/liquid_fuel
	target_types += /obj/effect/decal/cleanable/molten_object
	target_types += /obj/effect/decal/cleanable/tomato_smudge
	target_types += /obj/effect/decal/cleanable/egg_smudge
	target_types += /obj/effect/decal/cleanable/pie_smudge
	target_types += /obj/effect/decal/cleanable/flour
	target_types += /obj/effect/decal/cleanable/ash
	target_types += /obj/effect/decal/cleanable/greenglow
	target_types += /obj/effect/decal/cleanable/dirt

	if(blood)
		target_types += /obj/effect/decal/cleanable/blood/xeno/
		target_types += /obj/effect/decal/cleanable/blood/gibs/xeno
		target_types += /obj/effect/decal/cleanable/blood/
		target_types += /obj/effect/decal/cleanable/blood/gibs/
		target_types += /obj/effect/decal/cleanable/blood/tracks
		target_types += /obj/effect/decal/cleanable/dirt
		target_types += /obj/effect/decal/cleanable/trail_holder


/mob/living/simple_animal/bot/cleanbot/proc/start_clean(obj/effect/decal/cleanable/target)
	set_anchored(TRUE)
	visible_message(span_notice("[src] begins to clean up [target]"))
	mode = BOT_CLEANING
	update_icon()
	addtimer(CALLBACK(src, PROC_REF(do_clean), target), 5 SECONDS)


/mob/living/simple_animal/bot/cleanbot/proc/do_clean(obj/effect/decal/cleanable/target)
	if(QDELETED(src))
		return
	if(mode == BOT_CLEANING)
		QDEL_NULL(target)
		set_anchored(FALSE)
	mode = BOT_IDLE
	update_icon()


/mob/living/simple_animal/bot/cleanbot/explode()
	on = FALSE
	visible_message(span_userdanger("[src] blows apart!"))
	var/turf/Tsec = get_turf(src)
	new /obj/item/reagent_containers/glass/bucket(Tsec)
	new /obj/item/assembly/prox_sensor(Tsec)
	if(prob(50))
		drop_part(robot_arm, Tsec)
	do_sparks(3, TRUE, src)
	..()


/mob/living/simple_animal/bot/cleanbot/show_controls(mob/M)
	ui_interact(M)


/mob/living/simple_animal/bot/cleanbot/ui_interact(mob/user, datum/tgui/ui = null)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "BotClean", name)
		ui.open()


/mob/living/simple_animal/bot/cleanbot/ui_data(mob/user)
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
		"cleanblood" = blood
	)
	return data


/mob/living/simple_animal/bot/cleanbot/ui_act(action, params)
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
		if("blood")
			blood =!blood
			get_targets()
		if("ejectpai")
			ejectpai()


/mob/living/simple_animal/bot/cleanbot/UnarmedAttack(atom/A)
	if(!can_unarmed_attack())
		return
	if(istype(A,/obj/effect/decal/cleanable))
		start_clean(A)
	else
		..()


/obj/machinery/bot_core/cleanbot
	req_access = list(ACCESS_JANITOR, ACCESS_ROBOTICS)

