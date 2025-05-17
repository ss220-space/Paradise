/obj/structure/wryn
	max_integrity = 100
	var/damage = 0
	var/modifier = 0

/obj/structure/wryn/play_attack_sound(damage_amount, damage_type = BRUTE, damage_flag = 0)
	switch(damage_type)
		if(BRUTE)
			if(damage_amount)
				playsound(loc, 'sound/effects/attackblob.ogg', 100, TRUE)
			else
				playsound(src, 'sound/weapons/tap.ogg', 50, TRUE)
		if(BURN)
			if(damage_amount)
				playsound(loc, 'sound/items/welder.ogg', 100, TRUE)

/obj/structure/wryn/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/wryn_destruction)



// wax structures procs

/obj/structure/wryn/wax
	name = "wax"
	desc = "Похоже на толстую стенку из воска."
	icon = 'icons/obj/smooth_structures/wryn/wall.dmi'
	icon_state = "wall"
	base_icon_state = "wall"
	density = TRUE
	opacity = TRUE
	anchored = TRUE
	canSmoothWith = SMOOTH_GROUP_WRYN_WAX_WALL + SMOOTH_GROUP_WRYN_WAX_WINDOW
	max_integrity = 30
	smoothing_groups = SMOOTH_GROUP_WRYN_WAX
	smooth = SMOOTH_BITMASK


/obj/structure/wryn/wax/Initialize()
	if(usr)
		add_fingerprint(usr)
	air_update_turf(1)
	..()

/obj/structure/wryn/wax/Destroy()
	var/turf/T = get_turf(src)
	. = ..()
	T.air_update_turf(TRUE)

/obj/structure/wryn/wax/Move(atom/newloc, direct = NONE, glide_size_override = 0, update_dir = TRUE)
	var/turf/T = loc
	. = ..()
	move_update_air(T)

/obj/structure/wryn/wax/CanAtmosPass(turf/T, vertical)
	return !density

// Structure themselfs

/obj/structure/wryn/wax/wall
	name = "wax wall"
	desc = "Похоже на затвердевшую массу воска."
	smoothing_groups = SMOOTH_GROUP_WRYN_WAX_WALL + SMOOTH_GROUP_WRYN_WAX_WINDOW
	obj_flags = BLOCK_Z_IN_DOWN | BLOCK_Z_IN_UP

/obj/structure/wryn/wax/window
	name = "wax window"
	desc = "Воск на этой стенке настолько тонкий, что через него может проходить свет."
	icon = 'icons/obj/smooth_structures/wryn/window.dmi'
	base_icon_state = "window"
	icon_state = "window-0"
	smoothing_groups = SMOOTH_GROUP_WRYN_WAX_WALL + SMOOTH_GROUP_WRYN_WAX_WINDOW
	opacity = FALSE
	max_integrity = 20

/obj/structure/wryn/floor
	icon = 'icons/obj/smooth_structures/wryn/floor.dmi'
	gender = PLURAL
	name = "wax floor"
	desc = "Что-то жёлтое и липкое покрывает пол... Так стоп..."
	anchored = TRUE
	density = FALSE
	layer = TURF_LAYER
	plane = FLOOR_PLANE
	var/list/icons = list("wax_floor1", "wax_floor2", "wax_floor3")
	icon_state = "wax_floor1"
	max_integrity = 10
	var/current_dir
	var/static/list/floorImageCache
	obj_flags = BLOCK_Z_OUT_DOWN | BLOCK_Z_IN_UP

// wax floor procs

/obj/structure/wryn/floor/update_overlays()
	. = ..()
	for(var/check_dir in GLOB.cardinal)
		var/turf/check = get_step(src, check_dir)
		if(issimulatedturf(check) && !(locate(/obj/structure/wryn) in check))
			. += floorImageCache["[GetOppositeDir(check_dir)]"]


/obj/structure/wryn/floor/proc/fullUpdateWeedOverlays()
	if(!length(floorImageCache))
		floorImageCache = list(4)
		floorImageCache["[NORTH]"] = image('icons/obj/smooth_structures/wryn/floor.dmi', "wax_floor_side_n", layer=2.11, pixel_y = -32)
		floorImageCache["[SOUTH]"] = image('icons/obj/smooth_structures/wryn/floor.dmi', "wax_floor_side_s", layer=2.11, pixel_y = 32)
		floorImageCache["[EAST]"] = image('icons/obj/smooth_structures/wryn/floor.dmi', "wax_floor_side_e", layer=2.11, pixel_x = -32)
		floorImageCache["[WEST]"] = image('icons/obj/smooth_structures/wryn/floor.dmi', "wax_floor_side_w", layer=2.11, pixel_x = 32)

	for(var/obj/structure/wryn/floor/floor in range(1,src))
		floor.update_icon(UPDATE_OVERLAYS)


/obj/structure/wryn/floor/New(pos)
	..()
	var/picked = pick(icons)
	icon_state = picked
	fullUpdateWeedOverlays()

/obj/structure/wryn/floor/Destroy()
	fullUpdateWeedOverlays()
	return ..()


/obj/structure/wryn/wax/CanAllowThrough(atom/movable/mover, border_dir)
	. = ..()
	if(checkpass(mover))
		return TRUE
	if(checkpass(mover, PASSGLASS))
		return !opacity


/obj/structure/wryn/floor/temperature_expose(datum/gas_mixture/air, exposed_temperature, exposed_volume)
	..()
	if(exposed_temperature > 300)
		take_damage(5, BURN, 0, 0)

#define WAX_DOOR_CLOSED 0
#define WAX_DOOR_OPENED 1

// wax door procs

/obj/structure/wryn/wax/door
	name = "wax door"
	desc = "Толстая масса воска, напоминающая дверь."
	icon = 'icons/obj/smooth_structures/wryn/wax_door.dmi'
	icon_state = "wax_door_closed"
	max_integrity = 50
	canSmoothWith = null
	smooth = NONE
	pass_flags_self = PASSDOOR
	var/state = WAX_DOOR_CLOSED
	var/operating = FALSE
	var/autoclose = TRUE
	var/autoclose_delay = 10 SECONDS


/obj/structure/wryn/wax/door/Initialize()
	. = ..()
	update_freelook_sight()


/obj/structure/wryn/wax/door/Destroy()
	set_density(FALSE)
	update_freelook_sight()
	return ..()


/obj/structure/wryn/wax/door/update_icon_state()
	switch(state)
		if(WAX_DOOR_CLOSED)
			icon_state = "wax_door_closed"
		if(WAX_DOOR_OPENED)
			icon_state = "wax_door_opened"

/obj/structure/wryn/wax/door/attack_animal(mob/living/simple_animal/animal)
	if(animal.a_intent == INTENT_HARM)
		return ..()

	return try_switch_state(animal)

/obj/structure/wryn/wax/door/attack_hand(mob/living/user)
	if(user.a_intent == INTENT_HARM)
		return ..()
	if(!iswryn(user))
		to_chat(user, span_notice("Вы даже не знаете, что делать с этой массой воска."))

	return try_switch_state(user)

/obj/structure/wryn/wax/door/attack_ghost(mob/user)
	if(user.can_advanced_admin_interact())
		switch_state()

/obj/structure/wryn/wax/door/attack_tk(mob/user)
	return

/obj/structure/wryn/wax/door/proc/try_switch_state(atom/movable/user)
	if(operating)
		return FALSE

	add_fingerprint(user)
	if(!isliving(user))
		return FALSE
	// var/mob/living/mob = user
	if(!istype(user, /mob/living/carbon/human/wryn))
		return FALSE

	var/mob/living/carbon/human/wryn/wryn = user
	if(wryn.incapacitated())
		return FALSE

	switch_state()
	return TRUE

/obj/structure/wryn/wax/door/proc/switch_state()
	switch(state)
		if(WAX_DOOR_CLOSED)
			open()
		if(WAX_DOOR_OPENED)
			close()

/obj/structure/wryn/wax/door/proc/open()

	if(operating || !density)
		return

	if(autoclose)
		autoclose_in(autoclose_delay)

	flick("wax_door_opening", src)
	playsound(loc, 'sound/creatures/alien/xeno_door_open.ogg', 100, TRUE)
	operating = TRUE

	sleep(0.1 SECONDS)
	set_opacity(FALSE)
	update_freelook_sight()

	sleep(0.4 SECONDS)
	set_density(FALSE)
	air_update_turf(TRUE)

	sleep(0.1 SECONDS)
	operating = FALSE
	state = WAX_DOOR_OPENED
	update_icon()


/obj/structure/wryn/wax/door/proc/close()

	if(operating || density)
		return

	var/turf/source_turf = get_turf(src)
	for(var/atom/movable/moving_atom in source_turf)
		if(moving_atom.density && moving_atom != src)
			if(autoclose)
				autoclose_in(autoclose_delay * 0.5)
			return

	flick("wax_door_closing", src)
	playsound(loc, 'sound/creatures/alien/xeno_door_close.ogg', 100, TRUE)
	operating = TRUE

	sleep(0.1 SECONDS)
	set_density(TRUE)
	air_update_turf(TRUE)

	sleep(0.4 SECONDS)
	set_opacity(TRUE)
	update_freelook_sight()

	sleep(0.1 SECONDS)
	operating = FALSE
	state = WAX_DOOR_CLOSED
	update_icon()
	check_mobs()


/obj/structure/wryn/wax/door/proc/check_mobs()
	if(locate(/mob/living) in get_turf(src))
		sleep(0.1 SECONDS)
		open()


/obj/structure/wryn/wax/door/proc/autoclose()
	if(!QDELETED(src) && !density && !operating && autoclose)
		close()


/obj/structure/wryn/wax/door/proc/autoclose_in(wait)
	addtimer(CALLBACK(src, PROC_REF(autoclose)), wait, TIMER_UNIQUE | TIMER_NO_HASH_WAIT | TIMER_OVERRIDE)


/obj/structure/wryn/wax/door/proc/update_freelook_sight()
	if(GLOB.cameranet)
		GLOB.cameranet.updateVisibility(src, opacity_check = FALSE)


#undef WAX_DOOR_CLOSED
#undef WAX_DOOR_OPENED
