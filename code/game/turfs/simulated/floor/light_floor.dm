#define LIGHTFLOOR_ON 1
#define LIGHTFLOOR_WHITE 2
#define LIGHTFLOOR_RED 3
#define LIGHTFLOOR_GREEN 4
#define LIGHTFLOOR_YELLOW 5
#define LIGHTFLOOR_BLUE 6
#define LIGHTFLOOR_PURPLE 7

#define LIGHTFLOOR_GENERICCYCLE 8
#define LIGHTFLOOR_CYCLEA 9
#define LIGHTFLOOR_CYCLEB 10

/turf/simulated/floor/light
	name = "\improper light floor"
	light_range = 5
	icon_state = "light_on"
	floor_tile = /obj/item/stack/tile/light
	var/on = TRUE
	var/state = LIGHTFLOOR_ON
	var/can_modify_colour = TRUE

/turf/simulated/floor/light/Initialize(mapload)
	. = ..()
	update_icon()


/turf/simulated/floor/light/broken_states()
	return list("light_broken")


/turf/simulated/floor/light/update_icon_state()
	if(!on)
		set_light_on(FALSE)
		icon_state = "light_off"
		return

	switch(state)
		if(LIGHTFLOOR_ON)
			icon_state = "light_on"
			set_light(5, null,LIGHT_COLOR_LIGHTBLUE, l_on = TRUE)
		if(LIGHTFLOOR_WHITE)
			icon_state = "light_on-w"
			set_light(5, null,LIGHT_COLOR_WHITE, l_on = TRUE)
		if(LIGHTFLOOR_RED)
			icon_state = "light_on-r"
			set_light(5, null,LIGHT_COLOR_RED, l_on = TRUE)
		if(LIGHTFLOOR_GREEN)
			icon_state = "light_on-g"
			set_light(5, null,LIGHT_COLOR_PURE_GREEN, l_on = TRUE)
		if(LIGHTFLOOR_YELLOW)
			icon_state = "light_on-y"
			set_light(5, null,"#FFFF00")
		if(LIGHTFLOOR_BLUE)
			icon_state = "light_on-b"
			set_light(5, null,LIGHT_COLOR_DARKBLUE, l_on = TRUE)
		if(LIGHTFLOOR_PURPLE)
			icon_state = "light_on-p"
			set_light(5, null,LIGHT_COLOR_PURPLE, l_on = TRUE)
		if(LIGHTFLOOR_GENERICCYCLE)
			icon_state = "light_on-cycle_all"
			set_light(5, null,LIGHT_COLOR_WHITE, l_on = TRUE)
		if(LIGHTFLOOR_CYCLEA)
			icon_state = "light_on-dancefloor_A"
			set_light(5,null,LIGHT_COLOR_RED, l_on = TRUE)
		if(LIGHTFLOOR_CYCLEB)
			icon_state = "light_on-dancefloor_B"
			set_light(5, null,LIGHT_COLOR_DARKBLUE, l_on = TRUE)
		else
			icon_state = "light_off"
			set_light_on(FALSE)


/turf/simulated/floor/light/BeforeChange()
	set_light_on(FALSE)
	..()

/turf/simulated/floor/light/attack_hand(mob/user)
	if(!can_modify_colour)
		return
	toggle_light(!on)


/turf/simulated/floor/light/attackby(obj/item/I, mob/user, params)
	. = ..()

	if(ATTACK_CHAIN_CANCEL_CHECK(.))
		return .

	if(istype(I, /obj/item/light/bulb)) //only for light tiles
		if(state)
			to_chat(user, span_notice("The light bulb seems fine, no need to replace it."))
			return .
		if(!user.drop_transfer_item_to_loc(I, src))
			return .
		qdel(I)
		state = LIGHTFLOOR_ON
		update_icon()
		to_chat(user, span_notice("You replace the light bulb."))
		return .|ATTACK_CHAIN_BLOCKED_ALL


/turf/simulated/floor/light/multitool_act(mob/user, obj/item/I)
	. = TRUE
	if(!can_modify_colour)
		return
	if(!I.use_tool(src, user, 0, volume = I.tool_volume))
		return
	if(state != 0)
		if(state < LIGHTFLOOR_PURPLE)
			state++
		else
			state = LIGHTFLOOR_ON
		to_chat(user, span_notice("You change [src]'s light bulb color."))
		update_icon()
	else
		to_chat(user, span_warning("[src]'s light bulb appears to have burned out."))

/turf/simulated/floor/light/proc/toggle_light(light)
	// 0 = OFF
	// 1 = ON
	on = light
	update_icon()

/turf/simulated/floor/light/extinguish_light(force = FALSE)
	if(on)
		toggle_light(FALSE)
		visible_message(span_danger("[src] flickers and falls dark."))

//Cycles through all of the colours
/turf/simulated/floor/light/colour_cycle
	state = LIGHTFLOOR_GENERICCYCLE
	can_modify_colour = FALSE

//Two different "dancefloor" types so that you can have a checkered pattern
// (also has a longer delay than colour_cycle between cycling colours)
/turf/simulated/floor/light/colour_cycle/dancefloor_a
	name = "dancefloor"
	desc = "Funky floor."
	state = LIGHTFLOOR_CYCLEA

/turf/simulated/floor/light/colour_cycle/dancefloor_b
	name = "dancefloor"
	desc = "Funky floor."
	state = LIGHTFLOOR_CYCLEB


#undef LIGHTFLOOR_ON
#undef LIGHTFLOOR_WHITE
#undef LIGHTFLOOR_RED
#undef LIGHTFLOOR_GREEN
#undef LIGHTFLOOR_YELLOW
#undef LIGHTFLOOR_BLUE
#undef LIGHTFLOOR_PURPLE

#undef LIGHTFLOOR_GENERICCYCLE
#undef LIGHTFLOOR_CYCLEA
#undef LIGHTFLOOR_CYCLEB
