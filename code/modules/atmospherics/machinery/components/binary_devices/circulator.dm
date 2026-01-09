#define CIRC_LEFT WEST

/obj/machinery/atmospherics/binary/circulator
	name = "circulator/heat exchanger"
	desc = "A gas circulator pump and heat exchanger. Its input port is on the south side, and its output port is on the north side."
	icon = 'icons/obj/pipes_and_stuff/atmospherics/circulator.dmi'
	icon_state = "circ8-off"
	vent_movement = VENTCRAWL_CAN_SEE
	density = TRUE
	can_unwrench = TRUE

	var/side = CIRC_LEFT
	var/side_inverted = FALSE

	var/last_pressure_delta = 0

	/// The Thermo-Electric Generator this circulator is connected to
	var/obj/machinery/power/teg/generator

	var/light_range_on = 1
	var/light_power_on = 0.1 //just dont want it to be culled by byond.

/obj/machinery/atmospherics/binary/circulator/examine(mob/user)
	. = ..()
	. += span_notice("This generates electricity, depending on the difference in temperature between each side of the machine. \
		The meter in the center of the machine gives an indicator of how much electricity is being generated.")

// Creating a custom circulator pipe subtype to be delivered through cargo
/obj/item/pipe/circulator
	name = "circulator/heat exchanger fitting"

/obj/item/pipe/circulator/Initialize(mapload, pipe_type, dir, obj/machinery/atmospherics/make_from)
	. = ..(make_from = new /obj/machinery/atmospherics/binary/circulator(null))

/obj/machinery/atmospherics/binary/circulator/Destroy()
	if(generator && generator.cold_circ == src)
		generator.cold_circ = null

	else if(generator && generator.hot_circ == src)
		generator.hot_circ = null

	return ..()

/obj/machinery/atmospherics/binary/circulator/proc/return_transfer_air()
	var/datum/gas_mixture/inlet = get_inlet_air()
	var/datum/gas_mixture/outlet = get_outlet_air()
	var/output_starting_pressure = outlet.return_pressure()
	var/input_starting_pressure = inlet.return_pressure()

	if(output_starting_pressure >= input_starting_pressure - 10)
		//Need at least 10 KPa difference to overcome friction in the mechanism
		last_pressure_delta = 0
		update_icon()
		return null

	//Calculate necessary moles to transfer using PV = nRT
	if(inlet.temperature() > 0)
		var/pressure_delta = (input_starting_pressure - output_starting_pressure) / 2

		var/transfer_moles = pressure_delta * outlet.volume / (inlet.temperature() * R_IDEAL_GAS_EQUATION)

		if(last_pressure_delta != pressure_delta)
			last_pressure_delta = pressure_delta
			update_icon()

		//Actually transfer the gas
		var/datum/gas_mixture/removed = inlet.remove(transfer_moles)

		parent1.update = 1
		parent2.update = 1

		return removed

	else
		last_pressure_delta = 0
		update_icon()

/obj/machinery/atmospherics/binary/circulator/proc/get_inlet_air()
	return side_inverted ? air1 : air2

/obj/machinery/atmospherics/binary/circulator/proc/get_outlet_air()
	return side_inverted ? air2 : air1

/obj/machinery/atmospherics/binary/circulator/proc/get_inlet_side()
	if(dir & (SOUTH|NORTH))
		return side_inverted ? "North" : "South"

/obj/machinery/atmospherics/binary/circulator/proc/get_outlet_side()
	if(dir & (SOUTH|NORTH))
		return side_inverted ? "South" : "North"

/obj/machinery/atmospherics/binary/circulator/multitool_act(mob/user, obj/item/item)
	. = TRUE
	if(!item.use_tool(src, user, 0, volume = item.tool_volume))
		return
	side_inverted = !side_inverted
	to_chat(user, span_notice("You reverse the circulator's valve settings. The inlet of the circulator is now on the [get_inlet_side(dir)] side."))
	update_appearance(UPDATE_DESC|UPDATE_ICON)

/obj/machinery/atmospherics/binary/circulator/update_desc(updates = ALL)
	. = ..()
	desc = "A gas circulator pump and heat exchanger. Its input port is on the [get_inlet_side(dir)] side, and its output port is on the [get_outlet_side(dir)] side."

/obj/machinery/atmospherics/binary/circulator/update_icon() //this gets called everytime atmos is updated in the circulator (alot)
	..()
	underlays.Cut()
	cut_overlays()

	if(stat & (BROKEN|NOPOWER))
		icon_state = "circ[side]-p"
		return

	if(last_pressure_delta > 0)
		if(last_pressure_delta > ONE_ATMOSPHERE)
			icon_state = "circ[side]-run"
			underlays += emissive_appearance(icon,"emit[side]-run", src)
		else
			icon_state = "circ[side]-slow"
			underlays += emissive_appearance(icon,"emit[side]-slow", src)
	else
		icon_state = "circ[side]-off"
		underlays += emissive_appearance(icon,"emit[side]-off", src)

#undef CIRC_LEFT

/obj/machinery/atmospherics/binary/circulator/power_change()
	. = ..()
	if(stat & (BROKEN|NOPOWER))
		set_light(0)
	else
		set_light(light_range_on, light_power_on)
	update_icon()

/obj/machinery/atmospherics/binary/circulator/update_underlays()
	. = ..()
	update_icon()
