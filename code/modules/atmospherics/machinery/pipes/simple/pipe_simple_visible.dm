/obj/machinery/atmospherics/pipe/simple/visible
	icon_state = "intact"
	level = 2
	// these are inherited, but it's nice to have them explicit here
	plane = GAME_PLANE
	layer = GAS_PIPE_VISIBLE_LAYER

/obj/machinery/atmospherics/pipe/simple/visible/scrubbers
	name = "Scrubbers pipe"
	desc = "A one meter section of scrubbers pipe"
	icon_state = "intact-scrubbers"
	connect_types = list(3)
	layer = GAS_PIPE_HIDDEN_LAYER + GAS_PIPE_SCRUB_OFFSET
	layer_offset = GAS_PIPE_SCRUB_OFFSET
	icon_connect_type = "-scrubbers"
	color = PIPE_COLOR_RED

/obj/machinery/atmospherics/pipe/simple/visible/supply
	name = "Air supply pipe"
	desc = "A one meter section of supply pipe"
	icon_state = "intact-supply"
	connect_types = list(2)
	layer = GAS_PIPE_HIDDEN_LAYER + GAS_PIPE_SUPPLY_OFFSET
	layer_offset = GAS_PIPE_SUPPLY_OFFSET
	icon_connect_type = "-supply"
	color = PIPE_COLOR_BLUE

/obj/machinery/atmospherics/pipe/simple/visible/yellow
	color = PIPE_COLOR_YELLOW

/obj/machinery/atmospherics/pipe/simple/visible/cyan
	color = PIPE_COLOR_CYAN

/obj/machinery/atmospherics/pipe/simple/visible/green
	color = PIPE_COLOR_GREEN

/obj/machinery/atmospherics/pipe/simple/visible/purple
	color = PIPE_COLOR_PURPLE

/obj/machinery/atmospherics/pipe/simple/visible/universal
	name="Universal pipe adapter"
	desc = "An adapter for regular, supply and scrubbers pipes"
	connect_types = list(1,2,3)
	icon_state = "map_universal"


/obj/machinery/atmospherics/pipe/simple/visible/universal/update_overlays()
	. = list()
	if(!check_icon_cache())
		return .

	alpha = 255

	. += SSair.icon_manager.get_atmos_icon("pipe", color = pipe_color, state = "universal")
	update_underlays()


/obj/machinery/atmospherics/pipe/simple/visible/universal/update_underlays()
	if(!check_icon_cache())
		return

	underlays.Cut()
	if(node1)
		universal_underlays(node1)
		if(node2)
			universal_underlays(node2)
		else
			var/node1_dir = get_dir(node1,src)
			universal_underlays(direction = node1_dir)
	else if(node2)
		universal_underlays(node2)
	else
		universal_underlays(direction = dir)
		universal_underlays(direction = turn(dir, -180))

