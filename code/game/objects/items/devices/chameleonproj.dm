/obj/item/chameleon
	name = "chameleon projector"
	ru_names = list(
		NOMINATIVE = "\"Хамелеон\"-проектор",
		GENITIVE = "\"Хамелеон\"-проектора",
		DATIVE = "\"Хамелеон\"-проектору",
		ACCUSATIVE = "\"Хамелеон\"-проектор",
		INSTRUMENTAL = "\"Хамелеон\"-проектором",
		PREPOSITIONAL = "\"Хамелеон\"-проекторе"
	)
	gender = MALE
	icon = 'icons/obj/device.dmi'
	icon_state = "shield0"
	flags = CONDUCT
	slot_flags = ITEM_SLOT_BELT
	item_state = "electronic"
	throwforce = 5
	throw_speed = 3
	throw_range = 5
	w_class = WEIGHT_CLASS_SMALL
	origin_tech = "syndicate=1;magnets=4"
	var/can_use = TRUE
	var/obj/effect/dummy/chameleon/active_dummy = null
	var/saved_appearance = null

/obj/item/chameleon/Initialize(mapload)
	. = ..()
	var/obj/item/cigbutt/butt = /obj/item/cigbutt
	saved_appearance = initial(butt.appearance)

/obj/item/chameleon/dropped(mob/user, slot, silent = FALSE)
	. = ..()
	disrupt()

/obj/item/chameleon/equipped(mob/user, slot, initial)
	. = ..()
	disrupt()

/obj/item/chameleon/attack_self(mob/user)
	toggle(user)

/obj/item/chameleon/afterattack(atom/target, mob/user, proximity, params)
	if(!proximity)
		return
	if(!check_sprite(target))
		return
	if(target.alpha < 255)
		return
	if(target.invisibility)
		return
	if(!active_dummy)
		if(isitem(target) && !istype(target, /obj/item/disk/nuclear))
			playsound(get_turf(src), 'sound/weapons/flash.ogg', 100, TRUE, -6)
			to_chat(user, span_notice("Scanned [target]."))
			var/obj/temp = new /obj()
			temp.appearance = target.appearance
			temp.layer = initial(target.layer)
			SET_PLANE_EXPLICIT(temp, initial(plane), src)
			saved_appearance = temp.appearance

/obj/item/chameleon/proc/check_sprite(atom/target)
	if(icon_exists(target.icon, target.icon_state))
		return TRUE
	return FALSE

/obj/item/chameleon/proc/toggle(mob/user)
	if(!can_use || !saved_appearance)
		return
	if(active_dummy)
		eject_all()
		playsound(get_turf(src), 'sound/effects/pop.ogg', 100, TRUE, -6)
		QDEL_NULL(active_dummy)
		to_chat(user, span_notice("You deactivate [src]."))
		new /obj/effect/temp_visual/emp/pulse(get_turf(src))
	else
		playsound(get_turf(src), 'sound/effects/pop.ogg', 100, TRUE, -6)
		var/obj/effect/dummy/chameleon/C = new/obj/effect/dummy/chameleon(get_turf(user))
		C.activate(user, saved_appearance, src)
		to_chat(user, span_notice("You activate [src]."))
		new /obj/effect/temp_visual/emp/pulse(get_turf(src))

/obj/item/chameleon/proc/disrupt(delete_dummy = 1)
	if(active_dummy)
		do_sparks(5, 0, src)
		eject_all()
		if(delete_dummy)
			qdel(active_dummy)
		active_dummy = null
		can_use = FALSE
		addtimer(VARSET_CALLBACK(src, can_use, TRUE), 5 SECONDS)

/obj/item/chameleon/proc/eject_all()
	for(var/atom/movable/A in active_dummy)
		A.forceMove(active_dummy.loc)

/obj/effect/dummy/chameleon
	name = ""
	desc = ""
	density = FALSE
	anchored = TRUE
	var/can_move = TRUE
	var/obj/item/chameleon/master = null

/obj/effect/dummy/chameleon/proc/activate(mob/M, saved_appearance, obj/item/chameleon/C)
	appearance = saved_appearance
	if(istype(M.buckled, /obj/vehicle))
		var/obj/vehicle/V = M.buckled
		V.unbuckle_mob(M, TRUE)
	M.forceMove(src)
	master = C
	master.active_dummy = src


/obj/effect/dummy/chameleon/attackby(obj/item/I, mob/user, params)
	for(var/mob/snake in src)
		to_chat(snake, span_danger("Your chameleon projector deactivates."))
	master.disrupt()
	return ATTACK_CHAIN_BLOCKED_ALL


/obj/effect/dummy/chameleon/attack_hand()
	for(var/mob/M in src)
		to_chat(M, span_danger("Your chameleon projector deactivates."))
	master.disrupt()

/obj/effect/dummy/chameleon/attack_animal()
	master.disrupt()

/obj/effect/dummy/chameleon/attack_slime()
	master.disrupt()

/obj/effect/dummy/chameleon/attack_alien()
	master.disrupt()

/obj/effect/dummy/chameleon/ex_act(severity) //no longer bomb-proof
	for(var/mob/M in src)
		to_chat(M, span_danger("Your chameleon projector deactivates."))
		spawn()
			M.ex_act(severity)
	master.disrupt()

/obj/effect/dummy/chameleon/bullet_act()
	for(var/mob/M in src)
		to_chat(M, span_danger("Your chameleon projector deactivates."))
	..()
	master.disrupt()

/obj/effect/dummy/chameleon/relaymove(mob/user, direction)
	if(!isturf(loc) || isspaceturf(loc) || !direction)
		return // No magical movement!

	if(can_move)
		can_move = FALSE
		switch(user.bodytemperature)
			if(300 to INFINITY)
				addtimer(VARSET_CALLBACK(src, can_move, TRUE), 1 SECONDS)
			if(295 to 300)
				addtimer(VARSET_CALLBACK(src, can_move, TRUE), 1.3 SECONDS)
			if(280 to 295)
				addtimer(VARSET_CALLBACK(src, can_move, TRUE), 1.6 SECONDS)
			if(260 to 280)
				addtimer(VARSET_CALLBACK(src, can_move, TRUE), 2 SECONDS)
			else
				addtimer(VARSET_CALLBACK(src, can_move, TRUE), 2.5 SECONDS)
		step(src, direction)
	return

/obj/effect/dummy/chameleon/Destroy()
	master.disrupt(0)
	return ..()

/obj/item/borg_chameleon
	name = "cyborg chameleon projector"
	icon = 'icons/obj/device.dmi'
	icon_state = "shield0"
	item_state = "electronic"
	w_class = WEIGHT_CLASS_SMALL
	var/active = FALSE
	var/activationCost = 300
	var/activationUpkeep = 50
	var/last_disguise
	var/disguise = /datum/robot_skin/landmate
	var/loaded_name_disguise = "Standard"
	var/mob/living/silicon/robot/syndicate/saboteur/S
	var/datum/robot_skin/real_skin
	var/list/possible_disguises = list("Last One",
										"Standard" = list(
											/datum/robot_skin/default/std,
											/datum/robot_skin/basic/std,
											/datum/robot_skin/noble/std,
											/datum/robot_skin/paladin/std,
											/datum/robot_skin/robot_drone/std,
											/datum/robot_skin/protectron/std,
											/datum/robot_skin/coffin/std,
											/datum/robot_skin/burger/std,
											/datum/robot_skin/raptor/std,
											/datum/robot_skin/doll/std,
											/datum/robot_skin/buddy/std,
											/datum/robot_skin/mine/std,
											/datum/robot_skin/eyebot/std,
											/datum/robot_skin/seek/std,
											/datum/robot_skin/noble_h/std,
											/datum/robot_skin/mech/std,
											/datum/robot_skin/heavy/std,
											/datum/robot_skin/android
										),
										"Medical" = list(
											/datum/robot_skin/default/medical,
											/datum/robot_skin/basic/medical,
											/datum/robot_skin/noble/medical,
											/datum/robot_skin/cricket/medical,
											/datum/robot_skin/tall/meka/medical,
											/datum/robot_skin/tall/fmeka/medical,
											/datum/robot_skin/tall/mmeka/medical,
											/datum/robot_skin/paladin/medical,
											/datum/robot_skin/robot_drone/medical,
											/datum/robot_skin/protectron/medical,
											/datum/robot_skin/burger/medical,
											/datum/robot_skin/raptor/medical,
											/datum/robot_skin/doll/medical,
											/datum/robot_skin/buddy/medical,
											/datum/robot_skin/mine/medical,
											/datum/robot_skin/eyebot/medical,
											/datum/robot_skin/seek/medical,
											/datum/robot_skin/noble_h/medical,
											/datum/robot_skin/mech/medical,
											/datum/robot_skin/heavy/medical,
											/datum/robot_skin/walla,
											/datum/robot_skin/surgeon,
											/datum/robot_skin/chiefbot,
											/datum/robot_skin/droid_medical,
											/datum/robot_skin/basic/needles
										),
										"Engineering" = list(
											/datum/robot_skin/default/eng,
											/datum/robot_skin/basic/eng,
											/datum/robot_skin/noble/eng,
											/datum/robot_skin/cricket/eng,
											/datum/robot_skin/tall/meka/eng,
											/datum/robot_skin/tall/fmeka/eng,
											/datum/robot_skin/tall/mmeka/eng,
											/datum/robot_skin/paladin/eng,
											/datum/robot_skin/robot_drone/eng,
											/datum/robot_skin/protectron/eng,
											/datum/robot_skin/coffin/eng,
											/datum/robot_skin/burger/eng,
											/datum/robot_skin/raptor/eng,
											/datum/robot_skin/doll/eng,
											/datum/robot_skin/buddy/eng,
											/datum/robot_skin/mine/eng,
											/datum/robot_skin/eyebot/eng,
											/datum/robot_skin/seek/eng,
											/datum/robot_skin/noble_h/eng,
											/datum/robot_skin/mech/eng,
											/datum/robot_skin/heavy/eng,
											/datum/robot_skin/spider/eng,
											/datum/robot_skin/handy_eng,
											/datum/robot_skin/basic/antique,
											/datum/robot_skin/landmate,
											/datum/robot_skin/chiefmate
										),
										"Security" = list(
											/datum/robot_skin/default/sec,
											/datum/robot_skin/basic/sec,
											/datum/robot_skin/noble/sec,
											/datum/robot_skin/cricket/sec,
											/datum/robot_skin/tall/meka/sec,
											/datum/robot_skin/tall/fmeka/sec,
											/datum/robot_skin/tall/mmeka/sec,
											/datum/robot_skin/paladin/sec,
											/datum/robot_skin/robot_drone/sec,
											/datum/robot_skin/protectron/sec,
											/datum/robot_skin/coffin/sec,
											/datum/robot_skin/burger/sec,
											/datum/robot_skin/raptor/sec,
											/datum/robot_skin/doll/sec,
											/datum/robot_skin/buddy/sec,
											/datum/robot_skin/mine/sec,
											/datum/robot_skin/eyebot/sec,
											/datum/robot_skin/seek/sec,
											/datum/robot_skin/noble_h/sec,
											/datum/robot_skin/mech/sec,
											/datum/robot_skin/heavy/sec,
											/datum/robot_skin/spider/sec,
											/datum/robot_skin/securitron,
											/datum/robot_skin/redknight,
											/datum/robot_skin/blackknight,
											/datum/robot_skin/bloodhound
										),
										"Service" = list(
											/datum/robot_skin/default/srv,
											/datum/robot_skin/basic/default,
											/datum/robot_skin/noble/srv,
											/datum/robot_skin/cricket/srv,
											/datum/robot_skin/tall/meka/srv,
											/datum/robot_skin/tall/meka/srv_alt,
											/datum/robot_skin/tall/fmeka/srv,
											/datum/robot_skin/tall/mmeka/srv,
											/datum/robot_skin/paladin/srv,
											/datum/robot_skin/robot_drone/srv,
											/datum/robot_skin/protectron/srv,
											/datum/robot_skin/burger/srv,
											/datum/robot_skin/raptor/srv,
											/datum/robot_skin/doll/srv,
											/datum/robot_skin/buddy/srv,
											/datum/robot_skin/mine/srv,
											/datum/robot_skin/seek/srv,
											/datum/robot_skin/mech/srv,
											/datum/robot_skin/heavy/srv,
											/datum/robot_skin/handy_serv,
											/datum/robot_skin/basic/waitress,
											/datum/robot_skin/basic/bro,
											/datum/robot_skin/toiletbot,
											/datum/robot_skin/maximillion
										),
										"Janitor" = list(
											/datum/robot_skin/default/jan,
											/datum/robot_skin/basic/jan,
											/datum/robot_skin/noble/jan,
											/datum/robot_skin/cricket/jan,
											/datum/robot_skin/tall/meka/jan,
											/datum/robot_skin/tall/fmeka/jan,
											/datum/robot_skin/tall/mmeka/jan,
											/datum/robot_skin/paladin/jan,
											/datum/robot_skin/robot_drone/jan,
											/datum/robot_skin/protectron/jan,
											/datum/robot_skin/burger/jan,
											/datum/robot_skin/raptor/jan,
											/datum/robot_skin/doll/jan,
											/datum/robot_skin/buddy/jan,
											/datum/robot_skin/mine/jan,
											/datum/robot_skin/eyebot/jan,
											/datum/robot_skin/seek/jan,
											/datum/robot_skin/noble_h/jan,
											/datum/robot_skin/mech/jan,
											/datum/robot_skin/heavy/jan,
											/datum/robot_skin/basic/mopbot,
											/datum/robot_skin/mopgearrex
										),
										"Miner" = list(
											/datum/robot_skin/default/mnr,
											/datum/robot_skin/basic/mnr,
											/datum/robot_skin/noble/mnr,
											/datum/robot_skin/cricket/mnr,
											/datum/robot_skin/tall/meka/mnr,
											/datum/robot_skin/tall/fmeka/mnr,
											/datum/robot_skin/tall/mmeka/mnr,
											/datum/robot_skin/paladin/mnr,
											/datum/robot_skin/robot_drone/mnr,
											/datum/robot_skin/protectron/mnr,
											/datum/robot_skin/burger/mnr,
											/datum/robot_skin/raptor/mnr,
											/datum/robot_skin/doll/mnr,
											/datum/robot_skin/buddy/mnr,
											/datum/robot_skin/mine/mnr,
											/datum/robot_skin/seek/mnr,
											/datum/robot_skin/noble_h/mnr,
											/datum/robot_skin/mech/mnr,
											/datum/robot_skin/heavy/mnr,
											/datum/robot_skin/spider/mnr,
											/datum/robot_skin/walle,
											/datum/robot_skin/droid_miner,
											/datum/robot_skin/treadhead,
											/datum/robot_skin/lavaland
										),
										"Syndicate" = list(
											/datum/robot_skin/syndie_bloodhound,
											/datum/robot_skin/syndie_medi,
											/datum/robot_skin/syndi_engi,
											/datum/robot_skin/tall/meka/syndi,
											/datum/robot_skin/tall/fmeka/syndi,
											/datum/robot_skin/tall/mmeka/syndi,
											/datum/robot_skin/heavy/syndi,
											/datum/robot_skin/spider/syndi,
										)
	)

/obj/item/borg_chameleon/Initialize(mapload)
	. = ..()
	disguise = GLOB.robot_skins["[disguise]"]

/obj/item/borg_chameleon/Destroy()
	if(S)
		S.cham_proj = null
	return ..()

/obj/item/borg_chameleon/dropped(mob/user, slot, silent = FALSE)
	. = ..()
	disrupt(user)

/obj/item/borg_chameleon/equipped(mob/user, slot, initial)
	. = ..()
	disrupt(user)

/obj/item/borg_chameleon/attack_self(mob/living/silicon/robot/syndicate/saboteur/user)
	if(user && user.cell && user.cell.charge >  activationCost)
		if(isturf(user.loc))
			toggle(user)
		else
			to_chat(user, span_warning("You can't use [src] while inside something!"))
	else
		to_chat(user, span_warning("You need at least [activationCost] charge in your cell to use [src]!"))

/obj/item/borg_chameleon/proc/toggle(mob/living/silicon/robot/syndicate/saboteur/user)
	if(active)
		playsound(src, 'sound/effects/pop.ogg', 100, TRUE, -6)
		to_chat(user, span_notice("You deactivate [src]."))
		deactivate(user)
	else
		var/choice
		var/new_disguise = tgui_input_list(usr, "Please, select a disguise!", "Robot", possible_disguises)
		if(!new_disguise)
			choice = disguise
		else if(new_disguise == "Last One")
			if(!last_disguise)
				choice = disguise
			choice = last_disguise
		else
			var/datum/robot_skin/skin = user.select_skin(possible_disguises[new_disguise], initial(disguise))
			choice = skin
			last_disguise = skin
			loaded_name_disguise = new_disguise
		if(!choice)
			if(!last_disguise)
				choice = disguise
			else
				choice = last_disguise
		to_chat(user, span_notice("You activate [src]."))
		var/start = user.filters.len
		var/X
		var/Y
		var/rsq
		var/i
		var/f
		for(i in 1 to 7)
			do
				X = 60 * rand() - 30
				Y = 60 * rand() - 30
				rsq = X * X + Y * Y
			while(rsq < 100 || rsq > 900)
			user.filters += filter(type = "wave", x = X, y = Y, size = rand() * 2.5 + 0.5, offset = rand())
		for(i in 1 to 7)
			f = user.filters[start+i]
			animate(f, offset = f:offset, time = 0, loop = 3, flags = ANIMATION_PARALLEL)
			animate(offset = f:offset - 1, time = rand() * 20 + 10)
		if(do_after(user, 5 SECONDS, user) && user.cell.use(activationCost))
			playsound(src, 'sound/effects/bamf.ogg', 100, TRUE, -6)
			to_chat(user, span_notice("You are now disguised as a Nanotrasen cyborg."))
			activate(user, choice)
		else
			to_chat(user, span_warning("The chameleon field fizzles."))
			do_sparks(3, FALSE, user)
			for(i in 1 to min(7, user.filters.len)) // removing filters that are animating does nothing, we gotta stop the animations first
				f = user.filters[start + i]
				animate(f)
		user.filters = null

/obj/item/borg_chameleon/process()
	if(S)
		if(!S.cell || !S.cell.use(activationUpkeep))
			disrupt(S)
	else
		return PROCESS_KILL

/obj/item/borg_chameleon/proc/activate(mob/living/silicon/robot/syndicate/saboteur/user, datum/robot_skin/new_disguise)
	START_PROCESSING(SSobj, src)
	S = user
	user.module.name_disguise = loaded_name_disguise
	user.cham_proj = src
	user.bubble_icon = "robot"
	active = TRUE
	real_skin = user.selected_skin
	user.set_skin(new_disguise)

/obj/item/borg_chameleon/proc/deactivate(mob/living/silicon/robot/syndicate/saboteur/user)
	STOP_PROCESSING(SSobj, src)
	S = user
	user.bubble_icon = "syndibot"
	user.module.name_disguise = initial(user.module.name_disguise)
	active = FALSE
	user.set_skin(real_skin)

/obj/item/borg_chameleon/proc/disrupt(mob/living/silicon/robot/syndicate/saboteur/user)
	if(active)
		to_chat(user, span_danger("Your chameleon field deactivates."))
		deactivate(user)
