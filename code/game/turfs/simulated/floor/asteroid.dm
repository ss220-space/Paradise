
/**********************Asteroid**************************/

/turf/simulated/floor/plating/asteroid
	gender = PLURAL
	name = "asteroid sand"
	baseturf = /turf/simulated/floor/plating/asteroid
	icon_state = "asteroid"
	icon_plating = "asteroid"
	footstep = FOOTSTEP_SAND
	barefootstep = FOOTSTEP_SAND
	clawfootstep = FOOTSTEP_SAND
	heavyfootstep = FOOTSTEP_GENERIC_HEAVY
	var/environment_type = "asteroid"
	var/turf_type = /turf/simulated/floor/plating/asteroid //Because caves do whacky shit to revert to normal
	var/floor_variance = 20 //probability floor has a different icon state
	var/obj/item/stack/digResult = /obj/item/stack/ore/glass/basalt
	var/dug

/turf/simulated/floor/plating/asteroid/Initialize(mapload)
	var/proper_name = name
	. = ..()
	name = proper_name
	if(prob(floor_variance))
		icon_state = "[environment_type][rand(0,12)]"

/turf/simulated/floor/plating/asteroid/proc/getDug()
	new digResult(src, 5)
	dug = TRUE
	update_icon(UPDATE_ICON_STATE)

/turf/simulated/floor/plating/asteroid/proc/can_dig(mob/user)
	if(!dug)
		return TRUE
	if(user)
		to_chat(user, span_notice("Looks like someone has dug here already."))

///Refills the previously dug tile
/turf/simulated/floor/plating/asteroid/proc/refill_dug()
	dug = FALSE
	update_icon(UPDATE_ICON_STATE)

/turf/simulated/floor/plating/asteroid/update_icon_state()
	if(dug)
		icon_plating = "[environment_type]_dug"
		icon_state = "[environment_type]_dug"
	else
		icon_plating = initial(icon_plating)
		if(prob(floor_variance))
			icon_state = "[environment_type][rand(0,12)]"
		else
			icon_state =  initial(icon_state)


/turf/simulated/floor/plating/asteroid/burn_tile()
	return

/turf/simulated/floor/plating/asteroid/MakeSlippery(wet_setting = TURF_WET_WATER, min_wet_time = 0, wet_time_to_add = 0, max_wet_time = MAXIMUM_WET_TIME, permanent = FALSE, should_display_overlay = TRUE)
	return

/turf/simulated/floor/plating/asteroid/MakeDry(wet_setting)
	return

/turf/simulated/floor/plating/asteroid/remove_plating()
	return

/turf/simulated/floor/plating/asteroid/ex_act(severity)
	if(!can_dig())
		return
	switch(severity)
		if(3)
			return
		if(2)
			if(prob(20))
				getDug()
		if(1)
			getDug()


/turf/simulated/floor/plating/asteroid/can_have_cabling()
	return FALSE


/turf/simulated/floor/plating/asteroid/try_replace_tile(obj/item/stack/tile/tile, mob/user, params)
	if(!tile.use(1))
		return
	if(istype(tile, /obj/item/stack/tile/plasteel)) // Turn asteroid floors into plating by default
		ChangeTurf(/turf/simulated/floor/plating, keep_icon = FALSE)
	else
		ChangeTurf(tile.turf_type, keep_icon = FALSE)
	playsound(src, 'sound/weapons/Genhit.ogg', 50, TRUE)


/turf/simulated/floor/plating/asteroid/attackby(obj/item/I, mob/user, params)
	. = ..()

	if(ATTACK_CHAIN_CANCEL_CHECK(.))
		return .

	if((istype(I, /obj/item/shovel) || istype(I, /obj/item/pickaxe)))
		if(!can_dig(user))
			return .
		I.play_tool_sound()
		to_chat(user, span_notice("You start digging..."))
		if(!do_after(user, 4 SECONDS * I.toolspeed, src, category = DA_CAT_TOOL) || !istype(src, /turf/simulated/floor/plating/asteroid) || !can_dig(user))
			return .
		I.play_tool_sound()
		to_chat(user, span_notice("You have dug a hole."))
		if(user.a_intent == INTENT_DISARM)
			new /obj/structure/pit(src)
			dug = TRUE
		else
			getDug()
		return .|ATTACK_CHAIN_SUCCESS

	if(istype(I, /obj/item/storage/bag/ore))
		var/obj/item/storage/bag/ore/bag = I
		if(!bag.pickup_all_on_tile)
			return .
		for(var/obj/item/stack/ore/ore in contents)
			ore.attackby(bag, user, params)
		return .|ATTACK_CHAIN_SUCCESS


/turf/simulated/floor/plating/asteroid/welder_act(mob/user, obj/item/I)
	return

/// Used by ashstorms to replenish basalt tiles that have been dug up without going through all of them.
GLOBAL_LIST_EMPTY(dug_up_basalt)

/turf/simulated/floor/plating/asteroid/basalt
	name = "volcanic floor"
	baseturf = /turf/simulated/floor/plating/asteroid/basalt
	icon_state = "basalt"
	icon_plating = "basalt"
	environment_type = "basalt"
	floor_variance = 15
	digResult = /obj/item/stack/ore/glass/basalt

/turf/simulated/floor/plating/asteroid/basalt/refill_dug()
	. = ..()
	GLOB.dug_up_basalt -= src
	set_basalt_light(src)

/turf/simulated/floor/plating/asteroid/basalt/Destroy()
	GLOB.dug_up_basalt -= src
	return ..()

/turf/simulated/floor/plating/asteroid/basalt/lava //lava underneath
	baseturf = /turf/simulated/floor/lava

/turf/simulated/floor/plating/asteroid/basalt/airless
	temperature = TCMB
	oxygen = 0
	nitrogen = 0

/turf/simulated/floor/plating/asteroid/ancient
	digResult = /obj/item/stack/ore/glass/basalt/ancient
	baseturf = /turf/simulated/floor/plating/asteroid/ancient/airless

/turf/simulated/floor/plating/asteroid/ancient/airless
	temperature = TCMB
	oxygen = 0
	nitrogen = 0

/turf/simulated/floor/plating/asteroid/basalt/Initialize(mapload)
	. = ..()
	set_basalt_light(src)

/turf/simulated/floor/plating/asteroid/basalt/getDug()
	set_light_on(FALSE)
	GLOB.dug_up_basalt |= src
	return ..()

/proc/set_basalt_light(turf/simulated/floor/B)
	switch(B.icon_state)
		if("basalt1", "basalt2", "basalt3")
			B.set_light(2, 0.6, LIGHT_COLOR_LAVA) //more light
		if("basalt5", "basalt9")
			B.set_light(1.4, 0.6, LIGHT_COLOR_LAVA) //barely anything!

///////Surface. The surface is warm, but survivable without a suit. Internals are required. The floors break to chasms, which drop you into the underground.

/turf/simulated/floor/plating/asteroid/basalt/lava_land_surface
	oxygen = 14
	nitrogen = 23
	temperature = 300
	planetary_atmos = TRUE
	baseturf = /turf/simulated/floor/lava/mapping_lava

/turf/simulated/floor/plating/asteroid/airless
	temperature = TCMB
	oxygen = 0
	nitrogen = 0
	turf_type = /turf/simulated/floor/plating/asteroid/airless

/turf/simulated/floor/plating/asteroid/snow
	gender = PLURAL
	name = "snow"
	desc = "Looks cold."
	icon = 'icons/turf/snow.dmi'
	baseturf = /turf/simulated/floor/plating/asteroid/snow
	icon_state = "snow"
	icon_plating = "snow"
	temperature = 180
	slowdown = 2
	environment_type = "snow"
	planetary_atmos = TRUE
	digResult = /obj/item/stack/sheet/mineral/snow

/turf/simulated/floor/plating/asteroid/snow/broken_states()
	return list("snow_dug")

/turf/simulated/floor/plating/asteroid/snow/burn_tile()
	if(!burnt)
		visible_message(span_danger("[src] melts away!."))
		slowdown = 0
		burnt = TRUE
		icon_state = "snow_dug"
		return TRUE
	return FALSE

/turf/simulated/floor/plating/asteroid/snow/airless
	temperature = TCMB
	oxygen = 0
	nitrogen = 0

/turf/simulated/floor/plating/asteroid/snow/temperature
	temperature = 255.37

/turf/simulated/floor/plating/asteroid/snow/atmosphere
	oxygen = 22
	nitrogen = 82
	temperature = 180
	planetary_atmos = FALSE
