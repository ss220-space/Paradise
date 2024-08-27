/mob/living/simple_animal/bot/honkbot
	name = "\improper honkbot"
	desc = "A little robot. It looks happy with its bike horn."
	icon = 'icons/obj/aibots.dmi'
	icon_state = "honkbot"
	density = FALSE
	anchored = FALSE
	health = 25
	maxHealth = 25
	damage_coeff = list(BRUTE = 0.5, BURN = 0.7, TOX = 0, CLONE = 0, STAMINA = 0, OXY = 0)
	pass_flags = PASSMOB|PASSFLAPS
	radio_channel = "Service" //Service
	bot_type = HONK_BOT
	bot_filter = RADIO_HONKBOT
	model = "Honkbot"
	bot_core_type = /obj/machinery/bot_core/honkbot
	window_id = "autohonk"
	window_name = "Honkomatic Bike Horn Unit v1.0.7"
	data_hud_type = DATA_HUD_SECURITY_BASIC // show jobs
	path_image_color = "#FF69B4"

	var/honksound = 'sound/items/bikehorn.ogg' //customizable sound
	var/spam_flag = FALSE
	var/cooldowntime = 3 SECONDS
	var/cooldowntimehorn = 1 SECONDS
	var/mob/living/carbon/target
	var/oldtarget_name
	var/target_lastloc = FALSE	//Loc of target when arrested.
	var/last_found = FALSE	//There's a delay
	var/threatlevel = FALSE
	var/arrest_type = FALSE


/obj/machinery/bot_core/honkbot
	req_access = list(ACCESS_CLOWN, ACCESS_ROBOTICS, ACCESS_MIME)


/mob/living/simple_animal/bot/honkbot/Initialize(mapload)
	. = ..()
	update_icon()
	auto_patrol = TRUE
	var/datum/job/clown/J = new /datum/job/clown()
	access_card.access += J.get_access()
	prev_access = access_card.access

	var/static/list/loc_connections = list(
		COMSIG_ATOM_ENTERED = PROC_REF(on_entered),
	)
	AddElement(/datum/element/connect_loc, loc_connections)


/mob/living/simple_animal/bot/honkbot/proc/sensor_blink()
	icon_state = "honkbot-c"
	addtimer(CALLBACK(src, TYPE_PROC_REF(/atom, update_icon)), 0.5 SECONDS, TIMER_OVERRIDE|TIMER_UNIQUE)


//honkbots react with sounds.
/mob/living/simple_animal/bot/honkbot/proc/react_ping()
	playsound(src, 'sound/machines/ping.ogg', 50, TRUE, -1) //the first sound upon creation!
	spam_flag = TRUE
	sensor_blink()
	addtimer(VARSET_CALLBACK(src, spam_flag, FALSE), 1.8 SECONDS)	// calibrates before starting the honk


/mob/living/simple_animal/bot/honkbot/proc/react_buzz()
	playsound(src, 'sound/machines/buzz-sigh.ogg', 50, TRUE, -1)
	sensor_blink()


/mob/living/simple_animal/bot/honkbot/bot_reset()
	..()
	target = null
	oldtarget_name = null
	set_anchored(FALSE)
	SSmove_manager.stop_looping(src)
	last_found = world.time
	spam_flag = FALSE


/mob/living/simple_animal/bot/honkbot/set_custom_texts()
	text_hack = "You overload [name]'s sound control system"
	text_dehack = "You reboot [name] and restore the sound control system."
	text_dehack_fail = "[name] refuses to accept your authority!"


/mob/living/simple_animal/bot/honkbot/get_controls(mob/user)
	var/dat
	dat += hack(user)
	dat += showpai(user)
	dat += text({"
	<TT><B>Honkomatic Bike Horn Unit v1.0.7 controls</B></TT><BR><BR>
	Status: []<BR>
	Behaviour controls are [locked ? "locked" : "unlocked"]<BR>
	Maintenance panel is [open ? "opened" : "closed"]<BR>"},

	"<a href='byond://?src=[UID()];power=1'>[on ? "On" : "Off"]</A>")

	if(!locked || issilicon(user) || user.can_admin_interact())
		dat += "Auto Patrol <a href='byond://?src=[UID()];operation=patrol'>[auto_patrol ? "On" : "Off"]</A><BR>"

	return	dat


/mob/living/simple_animal/bot/honkbot/proc/retaliate(mob/living/carbon/human/H)
	threatlevel = 6
	target = H
	mode = BOT_HUNT


/mob/living/simple_animal/bot/honkbot/attack_hand(mob/living/carbon/human/H)
	if(H.a_intent == INTENT_HARM)
		retaliate(H)
		addtimer(CALLBACK(src, PROC_REF(react_buzz)), 0.5 SECONDS)
	return ..()


/mob/living/simple_animal/bot/honkbot/emag_act(mob/user)
	..()
	if(emagged == 2)
		if(user)
			to_chat(user, span_warning("You short out [src]'s target assessment circuits. It gives out an evil laugh!!"))
			oldtarget_name = user.name
		audible_message(span_danger("[src] gives out an evil laugh!"))
		playsound(src, 'sound/machines/honkbot_evil_laugh.ogg', 75, TRUE, -1) // evil laughter
		update_icon()


/mob/living/simple_animal/bot/honkbot/bullet_act(obj/item/projectile/Proj)
	if((istype(Proj,/obj/item/projectile/beam)) || (istype(Proj,/obj/item/projectile/bullet) && (Proj.damage_type == BURN))||(Proj.damage_type == BRUTE) && (!Proj.nodamage && Proj.damage < health && ishuman(Proj.firer)))
		retaliate(Proj.firer)
	..()


/mob/living/simple_animal/bot/honkbot/UnarmedAttack(atom/A)
	if(!on || !can_unarmed_attack())
		return
	if(iscarbon(A))
		var/mob/living/carbon/C = A
		if(emagged <= 1)
			honk_attack(A)
		else
			if(!C.IsWeakened() || arrest_type)
				stun_attack(A)
		..()
	else if(!spam_flag) //honking at the ground
		bike_horn(A)


/mob/living/simple_animal/bot/honkbot/hitby(atom/movable/AM, skipcatch = FALSE, hitpush = TRUE, blocked = FALSE, datum/thrownthing/throwingdatum)
	if(isitem(AM))
		playsound(src, honksound, 50, TRUE, -1)
		var/obj/item/I = AM
		var/mob/thrower = locateUID(I.thrownby)
		if(I.throwforce < health && ishuman(thrower))
			retaliate(thrower)
	..()


/mob/living/simple_animal/bot/honkbot/proc/bike_horn() //use bike_horn
	if(emagged <= 1)
		if(!spam_flag)
			playsound(src, honksound, 50, TRUE, -1)
			spam_flag = TRUE //prevent spam
			sensor_blink()
			addtimer(VARSET_CALLBACK(src, spam_flag, FALSE), cooldowntimehorn)
	else if(emagged == 2) //emagged honkbots will spam short and memorable sounds.
		if(!spam_flag)
			playsound(src, "honkbot_e", 50, 0)
			spam_flag = TRUE // prevent spam
			icon_state = "honkbot-e"
			addtimer(CALLBACK(src, TYPE_PROC_REF(/atom, update_icon)), 3 SECONDS, TIMER_OVERRIDE|TIMER_UNIQUE)
		addtimer(VARSET_CALLBACK(src, spam_flag, FALSE), cooldowntimehorn)


/mob/living/simple_animal/bot/honkbot/proc/honk_attack(mob/living/carbon/C) // horn attack
	if(!spam_flag)
		playsound(loc, honksound, 50, TRUE, -1)
		spam_flag = TRUE // prevent spam
		sensor_blink()
		addtimer(VARSET_CALLBACK(src, spam_flag, FALSE), cooldowntimehorn)


/mob/living/simple_animal/bot/honkbot/proc/stun_attack(mob/living/carbon/C) // airhorn stun
	if(!spam_flag)
		playsound(src, 'sound/items/AirHorn.ogg', 100, TRUE, -1) //HEEEEEEEEEEEENK!!
		sensor_blink()
	if(!spam_flag)
		if(ishuman(C))
			var/mob/living/carbon/human/H = C
			if(H.check_ear_prot() >= HEARING_PROTECTION_MAJOR)
				return
			C.SetStuttering(40 SECONDS) //stammer
			C.AdjustDeaf(10 SECONDS) //far less damage than the H.O.N.K.
			var/obj/item/organ/internal/ears/ears = C.get_int_organ(/obj/item/organ/internal/ears)
			if(istype(ears))
				ears.internal_receive_damage(5)
			C.Jitter(100 SECONDS)
			C.Weaken(10 SECONDS)
			if(client) //prevent spam from players..
				spam_flag = TRUE
			if(emagged <= 1) //HONK once, then leave
				threatlevel -= 6
				target = oldtarget_name
			else // you really don't want to hit an emagged honkbot
				threatlevel = 6 // will never let you go
			addtimer(VARSET_CALLBACK(src, spam_flag, FALSE), cooldowntime)
			add_attack_logs(src, C, "honked by [src]")
			C.visible_message("<span class='danger'>[src] has honked [C]!</span>",\
					"<span class='userdanger'>[src] has honked you!</span>")
		else
			C.Stuttering(40 SECONDS)
			C.Stun(20 SECONDS)
			addtimer(VARSET_CALLBACK(src, spam_flag, FALSE), cooldowntime)


/mob/living/simple_animal/bot/honkbot/handle_automated_action()
	if(!..())
		return

	switch(mode)
		if(BOT_IDLE)		// idle
			SSmove_manager.stop_looping(src)
			look_for_perp()
			if(!mode && auto_patrol)
				mode = BOT_START_PATROL
		if(BOT_HUNT)
			// if can't reach perp for long enough, go idle
			if(frustration >= 5) //gives up easier than beepsky
				SSmove_manager.stop_looping(src)
				playsound(loc, 'sound/misc/sadtrombone.ogg', 25, TRUE, -1)
				back_to_idle()
				return

			if(target)		// make sure target exists
				if(Adjacent(target) && isturf(target.loc))
					if(threatlevel <= 4)
						honk_attack(target)
					else
						if(threatlevel >= 6)
							set waitfor = 0
							stun_attack(target)
							set_anchored(FALSE)
							target_lastloc = target.loc
					return
				else	// not next to perp
					var/turf/olddist = get_dist(src, target)
					SSmove_manager.move_to(src, target, 1, BOT_STEP_DELAY)
					if((get_dist(src, target)) >= (olddist))
						frustration++
					else
						frustration = 0
			else
				back_to_idle()

		if(BOT_START_PATROL)
			look_for_perp()
			start_patrol()

		if(BOT_PATROL)
			look_for_perp()
			bot_patrol()


/mob/living/simple_animal/bot/honkbot/proc/back_to_idle()
	set_anchored(FALSE)
	mode = BOT_IDLE
	target = null
	last_found = world.time
	frustration = 0
	INVOKE_ASYNC(src, PROC_REF(handle_automated_action)) //responds quickly


/mob/living/simple_animal/bot/honkbot/proc/back_to_hunt()
	set_anchored(FALSE)
	frustration = 0
	mode = BOT_HUNT
	INVOKE_ASYNC(src, PROC_REF(handle_automated_action)) // responds quickly


/mob/living/simple_animal/bot/honkbot/proc/look_for_perp()
	set_anchored(FALSE)
	for(var/mob/living/carbon/C in view(7, src))
		if((C.stat) || (C.handcuffed))
			continue

		if((C.name == oldtarget_name) && (world.time < last_found + 100))
			continue

		if(threatlevel <= 3 && emagged <= 1)
			if(C in view(4, src)) //keep the range short for patrolling
				if(!spam_flag)
					bike_horn()
		else if(threatlevel >= 4)
			if(!spam_flag || emagged > 1)
				target = C
				oldtarget_name = C.name
				bike_horn()
				speak("Honk!")
				visible_message("<b>[src]</b> starts chasing [C.name]!")
				mode = BOT_HUNT
				INVOKE_ASYNC(src, PROC_REF(handle_automated_action))
				break
			else
				continue

		else if(emagged > 1)
			bike_horn() //just spam the shit outta this


/mob/living/simple_animal/bot/honkbot/explode()	//doesn't drop cardboard nor its assembly, since its a very frail material.
	SSmove_manager.stop_looping(src)
	visible_message(span_boldannounceic("[src] blows apart!"))
	var/turf/Tsec = get_turf(src)
	new /obj/item/bikehorn(Tsec)
	new /obj/item/assembly/prox_sensor(Tsec)
	if(prob(50))
		drop_part(robot_arm, Tsec)
	new /obj/effect/decal/cleanable/blood/oil(loc)
	var/datum/effect_system/spark_spread/s = new
	s.set_up(3, 1, src)
	s.start()
	..()


/mob/living/simple_animal/bot/honkbot/attack_alien(mob/living/carbon/alien/user)
	..()
	if(!isalien(target))
		target = user
		mode = BOT_HUNT


/mob/living/simple_animal/bot/honkbot/proc/on_entered(datum/source, mob/living/carbon/arrived, atom/old_loc, list/atom/old_locs)
	SIGNAL_HANDLER

	if(!on || !iscarbon(arrived) || arrived != target || in_range(src, target))
		return

	arrived.visible_message(span_warning("[pick( \
						  "[arrived] dives out of [src]'s way!", \
						  "[arrived] stumbles over [src]!", \
						  "[arrived] jumps out of [src]'s path!", \
						  "[arrived] trips over [src] and falls!", \
						  "[arrived] topples over [src]!", \
						  "[arrived] leaps out of [src]'s way!")]"))
	arrived.Weaken(10 SECONDS)
	if(!client)
		INVOKE_ASYNC(src, PROC_REF(speak), "honk")
	sensor_blink()

