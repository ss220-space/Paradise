/obj/machinery/atmospherics/components/unary/portables_connector
	icon_state = "map_connector"

	name = "connector port"
	desc = "For connecting portables devices related to atmospherics control."

	can_unwrench = TRUE
	layer = GAS_PIPE_VISIBLE_LAYER + GAS_FILTER_OFFSET
	layer_offset = GAS_FILTER_OFFSET

	var/obj/machinery/portable_atmospherics/connected_device

	on = FALSE
	use_power = FALSE
	level = 0

/obj/machinery/atmospherics/components/unary/portables_connector/visible
	level = 2

/obj/machinery/atmospherics/components/unary/portables_connector/New()
	..()
	var/datum/gas_mixture/air_contents = AIR1

	air_contents.volume = 0

/obj/machinery/atmospherics/components/unary/portables_connector/Destroy()
	if(connected_device)
		connected_device.disconnect()
	return ..()

/obj/machinery/atmospherics/components/unary/portables_connector/update_icon_state()
	icon_state = "connector"


/obj/machinery/atmospherics/components/unary/portables_connector/update_underlays()
	if(..())
		underlays.Cut()
		var/turf/T = get_turf(src)
		if(!istype(T))
			return
		add_underlay(T, NODE1, dir)

/obj/machinery/atmospherics/components/unary/portables_connector/process_atmos()
	..()
	if(!connected_device)
		return FALSE
	if(PARENT1)
		update_parents()


/obj/machinery/atmospherics/components/unary/portables_connector/wrench_act(mob/living/user, obj/item/I)
	if(connected_device)
		to_chat(user, span_warning("You cannot unwrench [src], detach [connected_device] first."))
		return TRUE
	return ..()


/obj/machinery/atmospherics/components/unary/portables_connector/portableConnectorReturnAir()
	return connected_device.portableConnectorReturnAir()

/obj/proc/portableConnectorReturnAir()
