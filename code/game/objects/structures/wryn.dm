/obj/structure/wryn
	max_integrity = 100

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

/obj/structure/wryn/ComponentInitialize()
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

// Structure themself

/obj/structure/wryn/wax/wall
	name = "wax wall"
	desc = "Похоже на затвердевшую массу воска."
	smoothing_groups = SMOOTH_GROUP_WRYN_WAX_WALL + SMOOTH_GROUP_WRYN_WAX_WINDOW
	obj_flags = BLOCK_Z_IN_DOWN | BLOCK_Z_IN_UP

/obj/structure/wryn/wax/wall/get_ru_names()
	return list(
		NOMINATIVE = "соты",
		GENITIVE = "сот",
		DATIVE = "сотам",
		ACCUSATIVE = "соты",
		INSTRUMENTAL = "сотами",
		PREPOSITIONAL = "сотах"
	)

/obj/structure/wryn/wax/window
	name = "wax window"
	desc = "Воск на этой стенке настолько тонкий, что через него может проходить свет."
	icon = 'icons/obj/smooth_structures/wryn/window.dmi'
	base_icon_state = "window"
	icon_state = "window-0"
	smoothing_groups = SMOOTH_GROUP_WRYN_WAX_WALL + SMOOTH_GROUP_WRYN_WAX_WINDOW
	opacity = FALSE
	max_integrity = 20

/obj/structure/wryn/wax/window/get_ru_names()
	return list(
		NOMINATIVE = "прозрачныые соты",
		GENITIVE = "прозрачных сот",
		DATIVE = "прозрачным сотам сотам",
		ACCUSATIVE = "прозрачные соты",
		INSTRUMENTAL = "прозрачными сотами",
		PREPOSITIONAL = "прозрачных сотах"
	)

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

/obj/structure/wryn/floor/get_ru_names()
	return list(
		NOMINATIVE = "пол из воска",
		GENITIVE = "пола из воска",
		DATIVE = "полу из воска",
		ACCUSATIVE = "пол из воска",
		INSTRUMENTAL = "полом из воска",
		PREPOSITIONAL = "поле из воска"
	)

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

/obj/structure/alien/resin/door/wax
	name = "wax door"
	desc = "Объёмная масса воска, напоминающая дверь."
	icon = 'icons/obj/smooth_structures/wryn/wax_door.dmi'
	icon_state = "wax_door_closed"
	icon_closed = "wax_door_closed"
	icon_opened = "wax_door_opened"
	icon_closing = "wax_door_closing"
	icon_opening = "wax_door_opening"
	max_integrity = 50

/obj/structure/alien/resin/door/wax/get_ru_names()
	return list(
		NOMINATIVE = "дверь из сот",
		GENITIVE = "двери из сот",
		DATIVE = "двери из сот",
		ACCUSATIVE = "дверь из сот",
		INSTRUMENTAL = "дверью из сот",
		PREPOSITIONAL = "двери из сот"
	)

/obj/structure/alien/resin/door/wax/ComponentInitialize()
	. = ..()
	AddComponent(/datum/component/wryn_destruction)

/obj/structure/alien/resin/door/wax/update_icon_state()
	switch(state)
		if(WAX_DOOR_CLOSED)
			icon_state = "wax_door_closed"
		if(WAX_DOOR_OPENED)
			icon_state = "wax_door_opened"

/obj/structure/alien/resin/door/wax/attack_alien(mob/living/carbon/alien/humanoid/user)
	return

/obj/structure/alien/resin/door/wax/attack_animal(mob/living/simple_animal/M)
	return

/obj/structure/alien/resin/door/wax/attack_check(mob/living/user)
	if(!iswryn(user))
		to_chat(user, span_notice("Вы даже не знаете, что делать с этой массой воска."))

	if(user.a_intent == INTENT_HARM)
		return TRUE

	return try_switch_state(user)


/obj/structure/alien/resin/door/wax/try_switch_state(atom/movable/user)
	if(operating)
		return FALSE

	add_fingerprint(user)
	if(!isliving(user))
		return FALSE

	if(!iswryn(user))
		return FALSE
	var/mob/living/carbon/human/wryn = user
	if(wryn.incapacitated())
		return FALSE

	switch_state()
	return TRUE
