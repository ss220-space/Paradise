/obj/machinery/atmospherics/components/unary/passive_vent
	icon = 'icons/obj/pipes_and_stuff/atmospherics/atmos/vent_pump.dmi'
	icon_state = "map_vent"
	layer = GAS_PIPE_VISIBLE_LAYER + GAS_SCRUBBER_OFFSET
	layer_offset = GAS_SCRUBBER_OFFSET
	name = "passive vent"
	desc = "A large air vent"
	vent_movement = VENTCRAWL_ALLOWED|VENTCRAWL_CAN_SEE|VENTCRAWL_ENTRANCE_ALLOWED

	can_unwrench = TRUE

	var/volume = 250

/obj/machinery/atmospherics/components/unary/passive_vent/high_volume
	name = "large passive vent"
	volume = 1000

/obj/machinery/atmospherics/components/unary/passive_vent/New()
	..()
	var/datum/gas_mixture/air_contents = AIR1
	air_contents.volume = volume
	AIR1 = air_contents

/obj/machinery/atmospherics/components/unary/passive_vent/update_overlays()
	. = ..()
	SET_PLANE_IMPLICIT(src, FLOOR_PLANE)
	if(!check_icon_cache())
		return

	var/vent_icon = "vent"

	var/turf/T = get_turf(src)
	if(!istype(T))
		return

	var/obj/machinery/atmospherics/node = NODE1

	var/hide = T.intact && node && node.level == 1 && istype(node, /obj/machinery/atmospherics/pipe)

	if(welded)
		vent_icon += "_weld"
	else
		vent_icon += "_off"

	. += SSair.icon_manager.get_atmos_icon("device", state = vent_icon)

	if(!hide)
		. += SSair.icon_manager.get_atmos_icon("device", state = "vent_cap")

	update_pipe_image()

/obj/machinery/atmospherics/components/unary/passive_vent/process_atmos()
	..()

	if(!NODE1)
		return FALSE

	var/datum/gas_mixture/air_contents = AIR1

	var/datum/gas_mixture/environment = loc.return_air()

	var/pressure_delta = air_contents.return_pressure() - environment.return_pressure()

	// based on pressure_pump to equalize pressure
	// already equalized
	if(abs(pressure_delta) < 0.01)
		return 1

	if(pressure_delta > 0)
		// transfer from pipe air to environment
		if((air_contents.total_moles() > 0) && (air_contents.temperature > 0))
			var/transfer_moles = pressure_delta * environment.volume / (air_contents.temperature * R_IDEAL_GAS_EQUATION)
			transfer_moles = min(transfer_moles, volume)

			var/datum/gas_mixture/removed = air_contents.remove(transfer_moles)
			loc.assume_air(removed)
			air_update_turf()
	else
		// transfer from environment to pipe air
		pressure_delta = -pressure_delta
		if((environment.total_moles() > 0) && (environment.temperature > 0))
			var/transfer_moles = pressure_delta * air_contents.volume / (environment.temperature * R_IDEAL_GAS_EQUATION)
			transfer_moles = min(transfer_moles, volume)

			var/datum/gas_mixture/removed = loc.remove_air(transfer_moles)
			air_contents.merge(removed)
			air_update_turf()

	update_parents()
	return TRUE

/obj/machinery/atmospherics/components/unary/passive_vent/update_underlays()
	if(..())
		underlays.Cut()
		var/turf/T = get_turf(src)
		if(!istype(T))
			return
		add_underlay(T, NODE1, dir)
