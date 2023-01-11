/obj/structure/wryn
	max_integrity = 100

// /obj/structure/wryn/run_obj_armor(damage_amount, damage_type, damage_flag = 0, attack_dir)
// 	if(damage_flag == "melee")
// 		switch(damage_type)
// 			if(BRUTE)
// 				damage_amount *= 2
// 			if(BURN)
// 				damage_amount *= 2
// 	. = ..()

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
	desc = "Looks like some kind of thick resin."
	icon = 'icons/obj/smooth_structures/wryn/wall.dmi'
	icon_state = "wax_wall"
	density = TRUE
	opacity = TRUE
	anchored = TRUE
	//canSmoothWith = list(/obj/structure/alien/resin)
	max_integrity = 30
	//smooth = SMOOTH_TRUE

/obj/structure/wryn/wax/Initialize()
	air_update_turf(1)
	..()

/obj/structure/wryn/wax/Destroy()
	var/turf/T = get_turf(src)
	. = ..()
	T.air_update_turf(TRUE)

/obj/structure/wryn/wax/Move()
	var/turf/T = loc
	..()
	move_update_air(T)

/obj/structure/wryn/wax/CanAtmosPass()
	return !density

/obj/structure/wryn/wax/wall
	name = "wax wall"
	desc = "Thick wax solidified into a wall."
	//canSmoothWith = list(/obj/structure/alien/resin/wall, /obj/structure/alien/resin/membrane)

/obj/structure/wryn/wax/window
	name = "wax window"
	desc = "Wax just thin enough to let light pass through."
	icon = 'icons/obj/smooth_structures/wryn/wall.dmi'
	icon_state = "wax_wall"
	opacity = 0
	max_integrity = 20
	//canSmoothWith = list(/obj/structure/alien/resin/wall, /obj/structure/alien/resin/membrane)

/obj/structure/wryn/floor
	gender = PLURAL
	name = "wax floor"
	desc = "A sticky yellow surface covers the floor."
	anchored = TRUE
	density = FALSE
	layer = TURF_LAYER
	plane = FLOOR_PLANE
	icon_state = "wax_wall"
	max_integrity = 10

/obj/structure/wryn/floor/temperature_expose(datum/gas_mixture/air, exposed_temperature, exposed_volume)
	..()
	if(exposed_temperature > 300)
		take_damage(5, BURN, 0, 0)

