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

/obj/structure/wryn/wax
	name = "wax"
	desc = "Looks like some kind of thick wax."
	icon = 'icons/obj/smooth_structures/wryn/wall.dmi'
	icon_state = "wall"
	density = TRUE
	opacity = TRUE
	anchored = TRUE
	canSmoothWith = list(/obj/structure/wryn/wax)
	max_integrity = 30
	smooth = SMOOTH_TRUE

/obj/structure/wryn/wax/Initialize()
	if(usr)
		add_fingerprint(usr)
	air_update_turf(1)
	..()

/obj/structure/wryn/wax/Destroy()
	var/turf/T = get_turf(src)
	. = ..()
	T.air_update_turf(TRUE)

/obj/structure/wryn/wax/Move()
	var/turf/T = loc
	. = ..()
	move_update_air(T)

/obj/structure/wryn/wax/CanAtmosPass()
	return !density

/obj/structure/wryn/wax/wall
	name = "wax wall"
	desc = "Thick wax solidified into a wall."
	canSmoothWith = list(/obj/structure/wryn/wax/wall, /obj/structure/wryn/wax/window)

/obj/structure/wryn/wax/window
	name = "wax window"
	desc = "Wax just thin enough to let light pass through."
	icon = 'icons/obj/smooth_structures/wryn/window.dmi'
	icon_state = "window"
	opacity = 0
	max_integrity = 20
	canSmoothWith = list(/obj/structure/wryn/wax/wall, /obj/structure/wryn/wax/window)

/obj/structure/wryn/floor
	icon = 'icons/obj/smooth_structures/wryn/floor.dmi'
	gender = PLURAL
	name = "wax floor"
	desc = "A sticky yellow surface covers the floor."
	anchored = TRUE
	density = FALSE
	layer = TURF_LAYER
	plane = FLOOR_PLANE
	icon_state = "wax_floor"
	max_integrity = 10
	var/current_dir
	var/static/list/floorImageCache


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

