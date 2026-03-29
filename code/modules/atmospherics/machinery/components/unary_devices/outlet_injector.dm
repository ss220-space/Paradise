/obj/machinery/atmospherics/unary/outlet_injector
	name = "air injector"
	desc = "Has a valve and pump attached to it"
	icon = 'icons/obj/pipes_and_stuff/atmospherics/atmos/injector.dmi'
	icon_state = "map_injector"
	layer = GAS_PIPE_VISIBLE_LAYER + GAS_SCRUBBER_OFFSET
	layer_offset = GAS_SCRUBBER_OFFSET
	resistance_flags = FIRE_PROOF | UNACIDABLE | ACID_PROOF //really helpful in building gas chambers for xenomorphs
	can_unwrench = TRUE
	var/injecting = 0
	var/volume_rate = 50
	var/id

/obj/machinery/atmospherics/unary/outlet_injector/on
	on = TRUE

/obj/machinery/atmospherics/unary/outlet_injector/Initialize(mapload)
	. = ..()
	if(id)
		register_id(id, src, GLOB.injectors_by_tag)

/obj/machinery/atmospherics/unary/outlet_injector/Destroy()
	if(id && weak_reference == GLOB.injectors_by_tag[id])
		GLOB.injectors_by_tag -= id
	. = ..()

/obj/machinery/atmospherics/unary/outlet_injector/update_icon_state()
	if(!powered())
		icon_state = "off"
	else
		icon_state = "[on ? "on" : "off"]"

/obj/machinery/atmospherics/unary/outlet_injector/update_underlays()
	if(..())
		underlays.Cut()
		var/turf/T = get_turf(src)
		if(!istype(T))
			return
		add_underlay(T, node, dir)

/obj/machinery/atmospherics/unary/outlet_injector/power_change(forced = FALSE)
	if(!..())
		return
	update_icon()

/obj/machinery/atmospherics/unary/outlet_injector/process_atmos(seconds)
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

/obj/machinery/atmospherics/unary/outlet_injector/proc/inject()
	if(on || injecting)
		return FALSE

	injecting = TRUE

	var/temperature = air_contents.temperature()

	if(temperature > 0)
		var/transfer_moles = (air_contents.return_pressure()) * volume_rate / (temperature * R_IDEAL_GAS_EQUATION)

		var/datum/gas_mixture/removed = air_contents.remove(transfer_moles)

		var/turf/turf = get_turf(src)
		turf.blind_release_air(removed)

		parent.update = TRUE
	flick("inject", src)

/obj/machinery/atmospherics/unary/outlet_injector/get_data()
	var/list/data = list(
		"name" = name,
		"machine_type" = "AO",
		"uid" = UID(),
		"power" = on,
		"volume_rate" = volume_rate
	)

	return data

/obj/machinery/atmospherics/unary/outlet_injector/update_params(list/params)

	if("power" in params)
		on = params["power"]

	if("power_toggle" in params)
		on = !on


	if("inject" in params)
		INVOKE_ASYNC(src, PROC_REF(inject))
		return

	if("set_volume_rate" in params)
		var/number = params["set_volume_rate"]
		volume_rate = clamp(number, 0, air_contents.volume)

	update_appearance(UPDATE_ICON)


/obj/machinery/atmospherics/unary/outlet_injector/hide(i)
	update_underlays()
