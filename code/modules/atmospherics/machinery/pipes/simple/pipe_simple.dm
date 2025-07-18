/obj/machinery/atmospherics/pipe/simple
	icon = 'icons/obj/atmospherics/pipes/simple.dmi'
	icon_state = ""
	var/pipe_icon = "" //what kind of pipe it is and from which dmi is the icon manager getting its icons, "" for simple pipes, "hepipe" for HE pipes, "hejunction" for HE junctions
	name = "pipe"
	desc = "A one meter section of regular pipe"

	dir = SOUTH
	initialize_directions = SOUTH|NORTH

	device_type = BINARY

	var/minimum_temperature_difference = 300
	var/thermal_conductivity = 0 //WALL_HEAT_TRANSFER_COEFFICIENT No

	var/maximum_pressure = 70 * ONE_ATMOSPHERE
	var/fatigue_pressure = 55 * ONE_ATMOSPHERE
	alert_pressure = 55 * ONE_ATMOSPHERE


/obj/machinery/atmospherics/pipe/simple/New()
	..()
	// Pipe colors and icon states are handled by an image cache - so color and icon should
	//  be null. For mapping purposes color is defined in the object definitions.
	icon = null
	alpha = 255


/obj/machinery/atmospherics/pipe/simple/SetInitDirections()
	if(dir in GLOB.diagonals)
		initialize_directions = dir
	switch(dir)
		if(NORTH,SOUTH)
			initialize_directions = SOUTH|NORTH
		if(EAST,WEST)
			initialize_directions = EAST|WEST

/obj/machinery/atmospherics/pipe/simple/atmos_init()
	normalize_dir()
	. = ..()


/obj/machinery/atmospherics/pipe/simple/check_pressure(pressure)
	var/datum/gas_mixture/environment = loc.return_air()

	var/pressure_difference = pressure - environment.return_pressure()

	if(pressure_difference > maximum_pressure)
		burst()

	else if(pressure_difference > fatigue_pressure)
		//TODO: leak to turf, doing pfshhhhh
		if(prob(5))
			burst()

	else
		return TRUE

/obj/machinery/atmospherics/pipe/simple/proc/burst()
	src.visible_message(span_danger("\The [src] bursts!"))
	playsound(src.loc, 'sound/effects/bang.ogg', 25, 1)
	var/datum/effect_system/fluid_spread/smoke/smoke = new
	smoke.set_up(amount = 1, location = src.loc)
	smoke.start()
	qdel(src)

/obj/machinery/atmospherics/pipe/simple/proc/normalize_dir()
	if(dir==SOUTH)
		dir = NORTH
	else if(dir==WEST)
		dir = EAST


/obj/machinery/atmospherics/pipe/simple/update_overlays()
	. = ..()

	if(!check_icon_cache())
		return .

	alpha = 255

	if(NODE1 && NODE1)
		. += SSair.icon_manager.get_atmos_icon("pipe", color = pipe_color, state = pipe_icon + "intact" + icon_connect_type)
	else
		. += SSair.icon_manager.get_atmos_icon("pipe", color = pipe_color, state = pipe_icon + "exposed[NODE1? 1 : 0][NODE2? 1 : 0]" + icon_connect_type)


/obj/machinery/atmospherics/pipe/simple/update_underlays()
	return
