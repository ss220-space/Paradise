/obj/machinery/atmospherics/binary/dp_vent_pump
	icon = 'icons/obj/pipes_and_stuff/atmospherics/atmos/vent_pump.dmi'
	icon_state = "map_dp_vent"

	//node2 is output port
	//node1 is input port

	name = "dual-port air vent"
	desc = "Has a valve and pump attached to it. There are two ports."

	can_unwrench = TRUE

	level = 1

	connect_types = list(1,2,3) //connects to regular, supply and scrubbers pipes

	var/releasing = TRUE // FALSE = siphoning, TRUE = releasing

	var/external_pressure_bound = ONE_ATMOSPHERE
	var/input_pressure_min = 0
	var/output_pressure_max = 0

	var/pressure_checks = DONT_PASS_EXTERNAL_PRESURE_BOUND
	var/area/current_area

/obj/machinery/atmospherics/binary/dp_vent_pump/Initialize(mapload)
	. = ..()
	icon = null
	asign_new_area(get_area(src))

/obj/machinery/atmospherics/binary/dp_vent_pump/Destroy()
	return ..()

/obj/machinery/atmospherics/binary/dp_vent_pump/proc/asign_new_area(area/area)
	var/area/cached_current_area = current_area
	if(cached_current_area)
		cached_current_area.air_vents -= src
		current_area = null

	if(!area)
		return

	area.air_vents |= src
	current_area = area

/obj/machinery/atmospherics/binary/dp_vent_pump/high_volume
	name = "large dual port air vent"

/obj/machinery/atmospherics/binary/dp_vent_pump/high_volume/on
	on = TRUE

/obj/machinery/atmospherics/binary/dp_vent_pump/high_volume/Initialize(mapload)
	. = ..()
	air1.volume = 1000
	air2.volume = 1000

/obj/machinery/atmospherics/binary/dp_vent_pump/update_overlays()
	. = ..()

	if(!check_icon_cache())
		return

	var/vent_icon = "vent"

	var/turf/T = get_turf(src)
	if(!istype(T))
		return

	if(T.intact && node1 && node2 && node1.level == 1 && node2.level == 1 && istype(node1, /obj/machinery/atmospherics/pipe) && istype(node2, /obj/machinery/atmospherics/pipe))
		vent_icon += "h"

	if(!powered())
		vent_icon += "off"
	else
		vent_icon += "[on ? "[releasing ? "out" : "in"]" : "off"]"

	. += SSair.icon_manager.get_atmos_icon("device", state = vent_icon)
	update_pipe_image()

/obj/machinery/atmospherics/binary/dp_vent_pump/update_underlays()
	if(..())
		underlays.Cut()
		var/turf/T = get_turf(src)
		if(!istype(T))
			return
		if(T.intact && node1 && node2 && node1.level == 1 && node2.level == 1 && istype(node1, /obj/machinery/atmospherics/pipe) && istype(node2, /obj/machinery/atmospherics/pipe))
			return
		else
			if(node1)
				add_underlay(T, node1, turn(dir, -180), node1.icon_connect_type)
			else
				add_underlay(T, node1, turn(dir, -180))
			if(node2)
				add_underlay(T, node2, dir, node2.icon_connect_type)
			else
				add_underlay(T, node2, dir)

/obj/machinery/atmospherics/binary/dp_vent_pump/process_atmos(seconds)
	if(!on)
		return FALSE

	var/datum/milla_safe/dp_vent_pump_process/milla = new()
	milla.invoke_async(src)

/datum/milla_safe/dp_vent_pump_process

/datum/milla_safe/dp_vent_pump_process/on_run(obj/machinery/atmospherics/binary/dp_vent_pump/vent_pump)
	if(!vent_pump.on)
		return FALSE

	var/turf/turf = get_turf(vent_pump)

	var/datum/gas_mixture/environment = get_turf_air(turf)
	var/environment_pressure = environment.return_pressure()
	var/datum/gas_mixture/air1 = vent_pump.air1
	var/datum/gas_mixture/air2 = vent_pump.air2
	var/datum/pipeline/parent1 = vent_pump.parent1
	var/datum/pipeline/parent2 = vent_pump.parent2
	var/pressure_checks = vent_pump.pressure_checks
	var/external_pressure_bound = vent_pump.external_pressure_bound
	var/pressure_delta = 10000

	if(vent_pump.releasing) //input -> external
		if(pressure_checks & DONT_PASS_EXTERNAL_PRESURE_BOUND)
			pressure_delta = min(pressure_delta, (external_pressure_bound - environment_pressure))

		if(pressure_checks & DONT_PASS_INPUT_PRESURE_MIN)
			pressure_delta = min(pressure_delta, (air1.return_pressure() - vent_pump.input_pressure_min))

		if(pressure_delta > 0)
			if(air1.temperature() > 0)
				var/transfer_moles = pressure_delta*environment.volume/(air1.temperature() * R_IDEAL_GAS_EQUATION)
				var/datum/gas_mixture/removed = air1.remove(transfer_moles)
				environment.merge(removed)
				parent1.update = TRUE

	else //external -> output
		if(pressure_checks & DONT_PASS_EXTERNAL_PRESURE_BOUND)
			pressure_delta = min(pressure_delta, (environment_pressure - external_pressure_bound))

		if(pressure_checks & DONT_PASS_OUTPUT_PRESURE_MAX)
			pressure_delta = min(pressure_delta, (vent_pump.output_pressure_max - air2.return_pressure()))

		if(pressure_delta > 0)
			if(environment.temperature() > 0)
				var/transfer_moles = pressure_delta * air2.volume / (environment.temperature() * R_IDEAL_GAS_EQUATION)
				var/datum/gas_mixture/removed = air2.remove(transfer_moles)
				air2.merge(removed)
				parent2.update = TRUE

	return TRUE

/obj/machinery/atmospherics/binary/dp_vent_pump/get_data()
	var/list/data = list(
		"name" = name,
		"machine_type" = "ADVP",
		"uid" = UID(),
		"power" = on,
		"direction" = releasing? "release" : "siphon",
		"checks" = pressure_checks,
		"input" = input_pressure_min,
		"output" = output_pressure_max,
		"external" = external_pressure_bound,
	)

	return data

/obj/machinery/atmospherics/binary/dp_vent_pump/update_params(list/params)
	if("power" in params)
		on = params["power"]

	if("power_toggle" in params)
		on = !on

	if("direction" in params)
		releasing = params["direction"]

	if("checks" in params)
		pressure_checks = params["checks"]

	if("purge" in params)
		pressure_checks &= ~DONT_PASS_EXTERNAL_PRESURE_BOUND
		releasing = FALSE

	if("stabilize" in params)//the fact that this was "stabalize" shows how many fucks people give about these wonders, none
		pressure_checks |= DONT_PASS_EXTERNAL_PRESURE_BOUND
		releasing = TRUE

	if("set_input_pressure" in params)
		input_pressure_min = clamp(
			params["set_input_pressure"],
			0,
			ONE_ATMOSPHERE * 50
		)

	if("set_output_pressure" in params)
		output_pressure_max = clamp(
			params["set_output_pressure"],
			0,
			ONE_ATMOSPHERE * 50
		)

	if("set_external_pressure" in params)
		external_pressure_bound = clamp(
			params["set_external_pressure"],
			0,
			ONE_ATMOSPHERE * 50
		)
	update_appearance(UPDATE_ICON)

