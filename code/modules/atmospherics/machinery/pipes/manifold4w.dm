/obj/machinery/atmospherics/pipe/manifold4w
	icon = 'icons/obj/atmospherics/pipes/manifold.dmi'
	icon_state = ""
	name = "4-way pipe manifold"
	desc = "A manifold composed of regular pipes"

	dir = SOUTH
	initialize_directions = NORTH|SOUTH|EAST|WEST

	device_type = QUATERNARY

/obj/machinery/atmospherics/pipe/manifold4w/New()
	..()
	alpha = 255
	icon = null

/obj/machinery/atmospherics/pipe/manifold4w/SetInitDirections()
	initialize_directions = initial(initialize_directions)

/obj/machinery/atmospherics/pipe/manifold4w/process_atmos()
	if(!parent)
		..()
	else
		. = PROCESS_KILL

/obj/machinery/atmospherics/pipe/manifold4w/update_overlays()
	. = ..()

	if(!check_icon_cache())
		return

	alpha = 255

	. += SSair.icon_manager.get_atmos_icon("manifold", color = pipe_color, state = "4way" + icon_connect_type)
	. += SSair.icon_manager.get_atmos_icon("manifold", state = "clamps_4way" + icon_connect_type)
	update_underlays()


/obj/machinery/atmospherics/pipe/manifold4w/update_underlays()
	if(!..())
		return

	underlays.Cut()

	var/turf/source_turf = get_turf(src)
	if(!istype(source_turf))
		return

	var/list/directions = list(NORTH, SOUTH, EAST, WEST)


	directions -= dir
	for(var/node in nodes)
		var/node_direction = get_dir(src, node)
		directions -= add_underlay(source_turf, node, node_direction, icon_connect_type)

	for(var/check_dir in directions)
		add_underlay(source_turf, direction = check_dir, icon_connect_type = src.icon_connect_type)

/obj/machinery/atmospherics/pipe/manifold4w/visible
	icon_state = "map_4way"
	level = 2
	plane = GAME_PLANE
	layer = GAS_PIPE_VISIBLE_LAYER

/obj/machinery/atmospherics/pipe/manifold4w/visible/scrubbers
	name="4-way scrubbers pipe manifold"
	desc = "A manifold composed of scrubbers pipes"
	icon_state = "map_4way-scrubbers"
	connect_types = list(3)
	layer = GAS_PIPE_HIDDEN_LAYER + GAS_PIPE_SCRUB_OFFSET
	layer_offset = GAS_PIPE_SCRUB_OFFSET
	icon_connect_type = "-scrubbers"
	color = PIPE_COLOR_RED

/obj/machinery/atmospherics/pipe/manifold4w/visible/supply
	name="4-way air supply pipe manifold"
	desc = "A manifold composed of supply pipes"
	icon_state = "map_4way-supply"
	connect_types = list(2)
	layer = GAS_PIPE_HIDDEN_LAYER + GAS_PIPE_SUPPLY_OFFSET
	layer_offset = GAS_PIPE_SUPPLY_OFFSET
	icon_connect_type = "-supply"
	color = PIPE_COLOR_BLUE

/obj/machinery/atmospherics/pipe/manifold4w/visible/yellow
	color = PIPE_COLOR_YELLOW

/obj/machinery/atmospherics/pipe/manifold4w/visible/cyan
	color = PIPE_COLOR_CYAN

/obj/machinery/atmospherics/pipe/manifold4w/visible/green
	color = PIPE_COLOR_GREEN

/obj/machinery/atmospherics/pipe/manifold4w/visible/purple
	color = PIPE_COLOR_PURPLE

/obj/machinery/atmospherics/pipe/manifold4w/hidden
	icon_state = "map_4way"
	level = 1
	alpha = 128		//set for the benefit of mapping - this is reset to opaque when the pipe is spawned in game
	plane = GAME_PLANE
	layer = GAS_PIPE_HIDDEN_LAYER

/obj/machinery/atmospherics/pipe/manifold4w/hidden/scrubbers
	name="4-way scrubbers pipe manifold"
	desc = "A manifold composed of scrubbers pipes"
	icon_state = "map_4way-scrubbers"
	connect_types = list(3)
	layer = GAS_PIPE_HIDDEN_LAYER + GAS_PIPE_SCRUB_OFFSET
	layer_offset = GAS_PIPE_SCRUB_OFFSET
	icon_connect_type = "-scrubbers"
	color = PIPE_COLOR_RED

/obj/machinery/atmospherics/pipe/manifold4w/hidden/supply
	name="4-way air supply pipe manifold"
	desc = "A manifold composed of supply pipes"
	icon_state = "map_4way-supply"
	connect_types = list(2)
	layer = GAS_PIPE_HIDDEN_LAYER + GAS_PIPE_SUPPLY_OFFSET
	layer_offset = GAS_PIPE_SUPPLY_OFFSET
	icon_connect_type = "-supply"
	color = PIPE_COLOR_BLUE

/obj/machinery/atmospherics/pipe/manifold4w/hidden/yellow
	color = PIPE_COLOR_YELLOW

/obj/machinery/atmospherics/pipe/manifold4w/hidden/cyan
	color = PIPE_COLOR_CYAN

/obj/machinery/atmospherics/pipe/manifold4w/hidden/green
	color = PIPE_COLOR_GREEN

/obj/machinery/atmospherics/pipe/manifold4w/hidden/purple
	color = PIPE_COLOR_PURPLE
