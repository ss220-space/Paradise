
/*
Acts like a normal vent, but has an input AND output.
*/
#define EXT_BOUND	1
#define INPUT_MIN	2
#define OUTPUT_MAX	4

/obj/machinery/atmospherics/components/binary/dp_vent_pump
	icon = 'icons/obj/atmospherics/unary_devices.dmi'
	icon_state = "map_dp_vent"

	//node2 is output port
	//node1 is input port

	name = "dual-port air vent"
	desc = "Has a valve and pump attached to it. There are two ports."

	can_unwrench = TRUE

	level = 1

	connect_types = list(1,2,3) //connects to regular, supply and scrubbers pipes

	on = FALSE
	var/releasing = TRUE // FALSE = siphoning, TRUE = releasing

	var/external_pressure_bound = ONE_ATMOSPHERE
	var/input_pressure_min = 0
	var/output_pressure_max = 0

	frequency = ATMOS_VENTSCRUB
	var/id_tag = null

	var/pressure_checks = EXT_BOUND
	//1: Do not pass external_pressure_bound
	//2: Do not pass input_pressure_min
	//4: Do not pass output_pressure_max

	multitool_menu_type = /datum/multitool_menu/idtag/freq/dp_vent_pump

/obj/machinery/atmospherics/components/binary/dp_vent_pump/New()
	..()
	if(!id_tag)
		assign_uid()
		id_tag = num2text(uid)
	icon = null

/obj/machinery/atmospherics/components/binary/dp_vent_pump/atmos_init()
	..()
	if(frequency)
		set_frequency(frequency)
	broadcast_status()

/obj/machinery/atmospherics/components/binary/dp_vent_pump/high_volume
	name = "large dual port air vent"

/obj/machinery/atmospherics/components/binary/dp_vent_pump/high_volume/on
	on = TRUE

/obj/machinery/atmospherics/components/binary/dp_vent_pump/high_volume/New()
	..()
	var/datum/gas_mixture/air1 = AIR1
	air1.volume = 1000
	var/datum/gas_mixture/air2 = AIR2
	air2.volume = 1000

/obj/machinery/atmospherics/components/binary/dp_vent_pump/update_overlays()
	. = ..()

	if(!check_icon_cache())
		return

	var/vent_icon = "vent"

	var/turf/T = get_turf(src)
	if(!istype(T))
		return

	var/obj/machinery/atmospherics/node1 = NODE1
	var/obj/machinery/atmospherics/node2 = NODE2

	var/hide = T.intact && node1 && node2 && node1.level == 1 && node2.level == 1 && istype(node1, /obj/machinery/atmospherics/pipe) && istype(node2, /obj/machinery/atmospherics/pipe)

	if(welded)
		vent_icon += "_weld"
	else if(!powered())
		vent_icon += "_off"
	else
		vent_icon += "[on ? "[releasing ? "_out" : "_in"]" : "_off"]"

	. += SSair.icon_manager.get_atmos_icon("device", state = vent_icon)
	if(!hide)
		. += SSair.icon_manager.get_atmos_icon("device", state = "dpvent_cap")
	update_pipe_image()


/obj/machinery/atmospherics/components/binary/dp_vent_pump/update_underlays()
	if(..())
		underlays.Cut()
		var/turf/T = get_turf(src)
		if(!istype(T))
			return
		var/obj/machinery/atmospherics/node1 = NODE1
		var/obj/machinery/atmospherics/node2 = NODE2
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

/obj/machinery/atmospherics/components/binary/dp_vent_pump/process_atmos()
	..()
	if(!on)
		return FALSE

	var/datum/gas_mixture/air1 = AIR1
	var/datum/gas_mixture/air2 = AIR2

	var/datum/gas_mixture/environment = loc.return_air()
	var/environment_pressure = environment.return_pressure()

	if(releasing) //input -> external
		var/pressure_delta = 10000

		if(pressure_checks & EXT_BOUND)
			pressure_delta = min(pressure_delta, (external_pressure_bound - environment_pressure))
		if(pressure_checks & INPUT_MIN)
			pressure_delta = min(pressure_delta, (air1.return_pressure() - input_pressure_min))

		if(pressure_delta > 0)
			if(air1.temperature > 0)
				var/transfer_moles = pressure_delta*environment.volume/(air1.temperature * R_IDEAL_GAS_EQUATION)

				var/datum/gas_mixture/removed = air1.remove(transfer_moles)

				loc.assume_air(removed)
				air_update_turf()
				var/datum/pipeline/parent1 = PARENT1
				parent1.update = 1
	else //external -> output
		var/pressure_delta = 10000

		if(pressure_checks & EXT_BOUND)
			pressure_delta = min(pressure_delta, (environment_pressure - external_pressure_bound))
		if(pressure_checks & INPUT_MIN)
			pressure_delta = min(pressure_delta, (output_pressure_max - air2.return_pressure()))

		if(pressure_delta > 0)
			if(environment.temperature > 0)
				var/transfer_moles = pressure_delta*air2.volume/(environment.temperature * R_IDEAL_GAS_EQUATION)

				var/datum/gas_mixture/removed = loc.remove_air(transfer_moles)

				air2.merge(removed)
				air_update_turf()
				var/datum/pipeline/parent2 = PARENT2
				parent2.update = 1
	return TRUE

/obj/machinery/atmospherics/components/binary/dp_vent_pump/proc/broadcast_status()
	if(!radio_connection)
		return FALSE

	var/datum/signal/signal = new
	signal.transmission_method = 1 //radio signal
	signal.source = src

	signal.data = list(
		"tag" = id_tag,
		"device" = "ADVP",
		"power" = on,
		"direction" = releasing?("release"):("siphon"),
		"checks" = pressure_checks,
		"input" = input_pressure_min,
		"output" = output_pressure_max,
		"external" = external_pressure_bound,
		"sigtype" = "status"
	)
	radio_connection.post_signal(src, signal, filter = RADIO_ATMOSIA)

	return 1

/obj/machinery/atmospherics/components/binary/dp_vent_pump/receive_signal(datum/signal/signal)
	if(!signal.data["tag"] || (signal.data["tag"] != id_tag) || (signal.data["sigtype"]!="command"))
		return 0
	if(signal.data["power"] != null)
		on = text2num(signal.data["power"])

	if(signal.data["power_toggle"] != null)
		on = !on

	if(signal.data["direction"] != null)
		releasing = text2num(signal.data["direction"])

	if(signal.data["checks"] != null)
		pressure_checks = text2num(signal.data["checks"])

	if(signal.data["purge"])
		pressure_checks &= ~1
		releasing = FALSE

	if(signal.data["stabilize"])//the fact that this was "stabalize" shows how many fucks people give about these wonders, none
		pressure_checks |= 1
		releasing = TRUE

	if(signal.data["set_input_pressure"] != null)
		input_pressure_min = clamp(
			text2num(signal.data["set_input_pressure"]),
			0,
			ONE_ATMOSPHERE * 50
		)

	if(signal.data["set_output_pressure"] != null)
		output_pressure_max = clamp(
			text2num(signal.data["set_output_pressure"]),
			0,
			ONE_ATMOSPHERE * 50
		)

	if(signal.data["set_external_pressure"] != null)
		external_pressure_bound = clamp(
			text2num(signal.data["set_external_pressure"]),
			0,
			ONE_ATMOSPHERE * 50
		)

	if(signal.data["status"])
		spawn(2)
			broadcast_status()
		return //do not update_icon

	spawn(2)
		broadcast_status()
	update_icon()

/obj/machinery/atmospherics/components/binary/dp_vent_pump/multitool_act(mob/user, obj/item/I)
	. = TRUE
	multitool_menu_interact(user, I)

#undef EXT_BOUND
#undef INPUT_MIN
#undef OUTPUT_MAX
