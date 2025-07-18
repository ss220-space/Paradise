/obj/machinery/atmospherics/pipe/cap
	name = "pipe endcap"
	desc = "An endcap for pipes"
	icon = 'icons/obj/atmospherics/pipes/simple.dmi'
	icon_state = "cap"
	level = 2

	dir = SOUTH
	initialize_directions = SOUTH

	device_type = BINARY


/obj/machinery/atmospherics/pipe/cap/SetInitDirections()
	initialize_directions = dir

/obj/machinery/atmospherics/pipe/cap/process_atmos()
	if(!parent)
		..()
	else
		. = PROCESS_KILL



/obj/machinery/atmospherics/pipe/cap/update_overlays()
	. = ..()
	if(!check_icon_cache())
		return

	alpha = 255
	. += SSair.icon_manager.get_atmos_icon("pipe", , pipe_color, "cap" + icon_connect_type)


/obj/machinery/atmospherics/pipe/cap/atmos_init()
	..()
	for(var/obj/machinery/atmospherics/target in get_step(src, dir))
		if(target.initialize_directions & get_dir(target,src))
			var/c = check_connect_types(target,src)
			if(c)
				target.connected_to = c
				src.connected_to = c
				NODE1 = target
				break

	var/turf/T = get_turf(src)			// hide if turf is not intact
	if(!istype(T) || (T.transparent_floor == TURF_TRANSPARENT))
		return
	hide(T.intact)
	update_icon()

/obj/machinery/atmospherics/pipe/cap/visible
	level = 2
	icon_state = "cap"
	plane = GAME_PLANE
	layer = GAS_PIPE_VISIBLE_LAYER

/obj/machinery/atmospherics/pipe/cap/visible/scrubbers
	name = "scrubbers pipe endcap"
	desc = "An endcap for scrubbers pipes"
	icon_state = "cap-scrubbers"
	connect_types = list(3)
	layer = GAS_PIPE_VISIBLE_LAYER + GAS_PIPE_SCRUB_OFFSET
	layer_offset = GAS_PIPE_SCRUB_OFFSET
	icon_connect_type = "-scrubbers"
	color = PIPE_COLOR_RED

/obj/machinery/atmospherics/pipe/cap/visible/supply
	name = "supply pipe endcap"
	desc = "An endcap for supply pipes"
	icon_state = "cap-supply"
	connect_types = list(2)
	layer = GAS_PIPE_VISIBLE_LAYER + GAS_PIPE_SUPPLY_OFFSET
	layer_offset = GAS_PIPE_SUPPLY_OFFSET
	icon_connect_type = "-supply"
	color = PIPE_COLOR_BLUE

/obj/machinery/atmospherics/pipe/cap/hidden
	level = 1
	icon_state = "cap"
	alpha = 128
	plane = GAME_PLANE
	layer = GAS_PIPE_HIDDEN_LAYER

/obj/machinery/atmospherics/pipe/cap/hidden/scrubbers
	name = "scrubbers pipe endcap"
	desc = "An endcap for scrubbers pipes"
	icon_state = "cap-scrubbers"
	connect_types = list(3)
	layer = GAS_PIPE_HIDDEN_LAYER + GAS_PIPE_SCRUB_OFFSET
	layer_offset = GAS_PIPE_SCRUB_OFFSET
	icon_connect_type = "-scrubbers"
	color = PIPE_COLOR_RED

/obj/machinery/atmospherics/pipe/cap/hidden/supply
	name = "supply pipe endcap"
	desc = "An endcap for supply pipes"
	icon_state = "cap-supply"
	connect_types = list(2)
	layer = GAS_PIPE_HIDDEN_LAYER + GAS_PIPE_SUPPLY_OFFSET
	layer_offset = GAS_PIPE_SUPPLY_OFFSET
	icon_connect_type = "-supply"
	color = PIPE_COLOR_BLUE
