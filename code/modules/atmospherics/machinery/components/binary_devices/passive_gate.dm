// Tries to achieve target pressure at output (like a normal pump) except
// Uses no power but can not transfer gases from a low pressure area to a high pressure area
/obj/machinery/atmospherics/binary/passive_gate
	name = "passive gate"
	desc = "A one-way air valve that does not require power."
	icon = 'icons/obj/pipes_and_stuff/atmospherics/atmos/passive_gate.dmi'
	icon_state = "map"
	can_unwrench = TRUE
	target_pressure = ONE_ATMOSPHERE
	var/id = null

/obj/machinery/atmospherics/binary/passive_gate/examine(mob/user)
	. = ..()
	. += span_notice("This is a one-way regulator, allowing gas to flow only at a specific pressure and flow rate. If the light is green, gas is flowing.")

/obj/machinery/atmospherics/binary/passive_gate/CtrlClick(mob/living/user)
	if(!ishuman(user) && !issilicon(user))
		return

	if(user.incapacitated() || HAS_TRAIT(user, TRAIT_HANDS_BLOCKED))
		to_chat(user, span_warning("You can't do that right now!"))
		return

	if(!in_range(src, user) && !issilicon(user))
		return

	toggle(user)
	investigate_log("was turned [on ? "on" : "off"] by [key_name(user)]", INVESTIGATE_ATMOS)

/obj/machinery/atmospherics/binary/passive_gate/update_icon_state()
	icon_state = "[on ? "on" : "off"]"

/obj/machinery/atmospherics/binary/passive_gate/update_underlays()
	if(..())
		underlays.Cut()
		var/turf/turf = get_turf(src)
		if(!istype(turf))
			return
		add_underlay(turf, node1, turn(dir, 180))
		add_underlay(turf, node2, dir)

/obj/machinery/atmospherics/binary/passive_gate/process_atmos()
	if(!on)
		return FALSE

	var/output_starting_pressure = air2.return_pressure()
	var/input_starting_pressure = air1.return_pressure()

	if(output_starting_pressure >= min(target_pressure,input_starting_pressure-10))
		//No need to pump gas if target is already reached or input pressure is too low
		//Need at least 10 KPa difference to overcome friction in the mechanism
		return TRUE

	//Calculate necessary moles to transfer using PV = nRT
	if((air1.total_moles() > 0) && (air1.temperature() > 0))
		var/pressure_delta = min(target_pressure - output_starting_pressure, (input_starting_pressure - output_starting_pressure)/2)
		//Can not have a pressure delta that would cause output_pressure > input_pressure

		var/transfer_moles = pressure_delta * air2.volume / (air1.temperature() * R_IDEAL_GAS_EQUATION)

		//Actually transfer the gas
		var/datum/gas_mixture/removed = air1.remove(transfer_moles)
		air2.merge(removed)

		parent1.update = TRUE

		parent2.update = TRUE

	return TRUE

/obj/machinery/atmospherics/binary/passive_gate/attack_hand(mob/user)
	if(..())
		return

	if(!allowed(user))
		to_chat(user, span_alert("Access denied."))
		return

	add_fingerprint(user)
	ui_interact(user)

/obj/machinery/atmospherics/binary/passive_gate/attack_ghost(mob/user)
	ui_interact(user)

/obj/machinery/atmospherics/binary/passive_gate/ui_interact(mob/user, datum/tgui/ui = null)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "AtmosPump", name)
		ui.open()

/obj/machinery/atmospherics/binary/passive_gate/ui_data(mob/user)
	var/list/data = list(
		"on" = on,
		"rate" = round(target_pressure),
		"max_rate" = MAX_OUTPUT_PRESSURE,
		"gas_unit" = "kPa",
		"step" = 10 // This is for the TGUI <NumberInput> step. It's here since multiple pumps share the same UI, but need different values.
	)
	return data

/obj/machinery/atmospherics/binary/passive_gate/ui_act(action, list/params)
	if(..())
		return

	switch(action)
		if("power")
			toggle()
			investigate_log("was turned [on ? "on" : "off"] by [key_name_log(usr)]", INVESTIGATE_ATMOS)
			return TRUE

		if("max_rate")
			target_pressure = MAX_OUTPUT_PRESSURE
			. = TRUE

		if("min_rate")
			target_pressure = 0
			. = TRUE

		if("custom_rate")
			target_pressure = clamp(text2num(params["rate"]), 0 , MAX_OUTPUT_PRESSURE)
			. = TRUE
	if(.)
		investigate_log("was set to [target_pressure] kPa by [key_name_log(usr)]", INVESTIGATE_ATMOS)

/obj/machinery/atmospherics/binary/passive_gate/wrench_act(mob/living/user, obj/item/I)
	if(on)
		to_chat(user, span_warning("You cannot unwrench [src], turn it off first."))
		return TRUE
	return ..()
