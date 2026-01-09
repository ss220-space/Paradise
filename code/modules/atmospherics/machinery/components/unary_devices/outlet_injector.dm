GLOBAL_LIST_EMPTY(air_injectors)

/obj/machinery/atmospherics/unary/outlet_injector
	name = "air injector"
	desc = "Has a valve and pump attached to it."
	icon = 'icons/obj/pipes_and_stuff/atmospherics/atmos/injector.dmi'
	icon_state = "map_injector"
	layer = GAS_PIPE_VISIBLE_LAYER + GAS_SCRUBBER_OFFSET
	layer_offset = GAS_SCRUBBER_OFFSET
	resistance_flags = FIRE_PROOF | UNACIDABLE | ACID_PROOF //really helpful in building gas chambers for xenomorphs
	can_unwrench = TRUE
	var/injecting = FALSE
	var/volume_rate = 50

/obj/machinery/atmospherics/unary/outlet_injector/on
	on = TRUE

/obj/machinery/atmospherics/unary/outlet_injector/Initialize(mapload)
	. = ..()
	GLOB.air_injectors += src

/obj/machinery/atmospherics/unary/outlet_injector/Destroy()
	GLOB.air_injectors -= src
	return ..()

/obj/machinery/atmospherics/unary/outlet_injector/examine(mob/user)
	. = ..()
	. += span_notice("Outputs the pipe's gas into the atmosphere, similar to an air vent. It can be controlled by a nearby atmospherics computer. A green light on it means it is on.")

/obj/machinery/atmospherics/unary/outlet_injector/update_icon_state()
	if(!powered())
		icon_state = "off"
	else
		icon_state = "[on ? "on" : "off"]"

/obj/machinery/atmospherics/unary/outlet_injector/update_underlays()
	if(..())
		underlays.Cut()
		var/turf/turf = get_turf(src)
		if(!istype(turf))
			return
		add_underlay(turf, node, dir)

/obj/machinery/atmospherics/unary/outlet_injector/power_change(forced = FALSE)
	if(!..())
		return
	update_icon()

/obj/machinery/atmospherics/unary/outlet_injector/process_atmos()
	. = ..()

	injecting = FALSE
	if(!on || stat & NOPOWER)
		return FALSE

	var/temperature = air_contents.temperature()
	if(temperature > 0)
		var/transfer_moles = (air_contents.return_pressure()) * volume_rate / (temperature * R_IDEAL_GAS_EQUATION)
		var/datum/gas_mixture/removed = air_contents.remove(transfer_moles)
		var/turf/turf = get_turf(src)
		turf.blind_release_air(removed)
		parent.update = TRUE

	return TRUE

/obj/machinery/atmospherics/unary/outlet_injector/multitool_act(mob/living/user, obj/item/item)
	if(!ismultitool(item))
		return

	var/obj/item/multitool/multitool = item
	multitool.buffer_uid = UID()
	to_chat(user, span_notice("You save [src] into [multitool]'s buffer"))
