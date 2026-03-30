
/// Nothing will be filtered.
#define FILTER_NOTHING -1

/obj/machinery/atmospherics/trinary/filter
	name = "gas filter"
	icon = 'icons/obj/pipes_and_stuff/atmospherics/atmos/filter.dmi'
	icon_state = "map"
	can_unwrench = TRUE
	interaction_flags_click = NEED_HANDS | ALLOW_RESTING | ALLOW_SILICON_REACH
	/// The amount of pressure the filter wants to operate at.
	var/target_pressure = ONE_ATMOSPHERE
	/// The type of gas we want to filter. Valid values that go here are from the `FILTER` defines at the top of the file.
	var/filter_type = TLV_PL

/obj/machinery/atmospherics/trinary/filter/CtrlClick(mob/living/user)
	if(!ishuman(user) && !issilicon(user))
		return
	if(user.incapacitated() || HAS_TRAIT(user, TRAIT_HANDS_BLOCKED))
		to_chat(user, span_warning("You can't do that right now!"))
		return
	if(!in_range(src, user) && !issilicon(user))
		return
	toggle()

/obj/machinery/atmospherics/trinary/filter/AICtrlClick()
	toggle()
	return ..()

/obj/machinery/atmospherics/trinary/filter/click_alt(mob/living/user)
	set_max()
	return CLICK_ACTION_SUCCESS

/obj/machinery/atmospherics/trinary/filter/ai_click_alt()
	set_max()
	return ..()

/obj/machinery/atmospherics/trinary/filter/proc/set_max()
	if(powered())
		target_pressure = MAX_OUTPUT_PRESSURE
		update_icon()

/obj/machinery/atmospherics/trinary/filter/Destroy()
	if(SSradio)
		SSradio.remove_object(src, frequency)
	radio_connection = null
	return ..()

/obj/machinery/atmospherics/trinary/filter/flipped
	icon_state = "mmap"
	flipped = 1

/obj/machinery/atmospherics/trinary/filter/update_icon_state()
	..()

	if(flipped)
		icon_state = "m"
	else
		icon_state = ""

	if(!powered())
		icon_state += "off"
	else if(node2 && node3 && node1)
		icon_state += on ? "on" : "off"
	else
		icon_state += "off"
		on = FALSE

/obj/machinery/atmospherics/trinary/filter/update_underlays()
	if(..())
		underlays.Cut()
		var/turf/T = get_turf(src)
		if(!istype(T))
			return

		add_underlay(T, node1, turn(dir, -180))

		if(flipped)
			add_underlay(T, node2, turn(dir, 90))
		else
			add_underlay(T, node2, turn(dir, -90))

		add_underlay(T, node3, dir)

/obj/machinery/atmospherics/trinary/filter/power_change(forced = FALSE)
	if(!..())
		return
	update_icon()

#define FILTER_GAS(tag, gas) \
	if(tag) { \
		filtered_out.set_##gas(removed.gas()); \
		removed.set_##gas(0) \
	}

/obj/machinery/atmospherics/trinary/filter/process_atmos(seconds)
	if(!on)
		return FALSE

	var/output_starting_pressure = air3.return_pressure()

	if(output_starting_pressure >= target_pressure || air2.return_pressure() >= target_pressure)
		//No need to mix if target is already full!
		return TRUE

	//Calculate necessary moles to transfer using PV=nRT

	var/pressure_delta = target_pressure - output_starting_pressure
	var/transfer_moles

	if(air1.temperature() > 0)
		transfer_moles = pressure_delta * air3.volume / (air1.temperature() * R_IDEAL_GAS_EQUATION)

	//Actually transfer the gas

	if(transfer_moles > 0)
		var/datum/gas_mixture/removed = air1.remove(transfer_moles)

		if(!removed)
			return
		var/datum/gas_mixture/filtered_out = new
		filtered_out.set_temperature(removed.temperature())

		switch(filter_type)
			FILTER_GAS(TLV_PL, toxins)
			FILTER_GAS(TLV_AGENT_B, agent_b)
			FILTER_GAS(TLV_O2, oxygen)
			FILTER_GAS(TLV_N2, nitrogen)
			FILTER_GAS(TLV_CO2, carbon_dioxide)
			FILTER_GAS(TLV_N2O, sleeping_agent)
			FILTER_GAS(TLV_H2, hydrogen)
			FILTER_GAS(TLV_H2O, water_vapor)
			FILTER_GAS(TLV_TRITIUM, tritium)
			FILTER_GAS(TLV_BZ, bz)
			FILTER_GAS(TLV_PLUOXIUM, pluoxium)
			FILTER_GAS(TLV_MIASMA, miasma)
			FILTER_GAS(TLV_FREON, freon)
			FILTER_GAS(TLV_NITRIUM, nitrium)
			FILTER_GAS(TLV_HEALIUM, healium)
			FILTER_GAS(TLV_PROTO_NITRATE, proto_nitrate)
			FILTER_GAS(TLV_ZAUKER, zauker)
			FILTER_GAS(TLV_HALON, halon)
			FILTER_GAS(TLV_HELIUM, helium)
			FILTER_GAS(TLV_ANTINOBLIUM, antinoblium)
			FILTER_GAS(TLV_HYPERNOBLIUM, hyper_noblium)
			else
				filtered_out = null

		air2.merge(filtered_out)
		air3.merge(removed)

	if(!QDELETED(parent1))
		parent1.update = TRUE

	if(!QDELETED(parent2))
		parent2.update = TRUE

	if(!QDELETED(parent3))
		parent3.update = TRUE

	return TRUE

#undef FILTER_GAS

/obj/machinery/atmospherics/trinary/filter/attack_ghost(mob/user)
	ui_interact(user)

/obj/machinery/atmospherics/trinary/filter/attack_hand(mob/user)
	if(..())
		return

	if(!allowed(user))
		to_chat(user, span_alert("Access denied."))
		return

	add_fingerprint(user)
	ui_interact(user)

/obj/machinery/atmospherics/trinary/filter/ui_interact(mob/user, datum/tgui/ui = null)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "AtmosFilter", name)
		ui.open()

/obj/machinery/atmospherics/trinary/filter/ui_data(mob/user)
	var/list/data = list(
		"on" = on,
		"pressure" = round(target_pressure),
		"max_pressure" = round(MAX_OUTPUT_PRESSURE),
		"filter_type" = filter_type
	)
	data["filter_type_list"] = list()

	return data

/obj/machinery/atmospherics/trinary/filter/ui_act(action, list/params)
	if(..())
		return

	switch(action)
		if("power")
			toggle()
			investigate_log("was turned [on ? "on" : "off"] by [key_name_log(usr)]", INVESTIGATE_ATMOS)
			return TRUE

		if("set_filter")
			filter_type = params["filter"]
			investigate_log("was set to filter [filter_type] by [key_name_log(usr)]", INVESTIGATE_ATMOS)
			return TRUE

		if("max_pressure")
			target_pressure = MAX_OUTPUT_PRESSURE
			. = TRUE

		if("min_pressure")
			target_pressure = 0
			. = TRUE

		if("custom_pressure")
			target_pressure = clamp(text2num(params["pressure"]), 0, MAX_OUTPUT_PRESSURE)
			. = TRUE
	if(.)
		investigate_log("was set to [target_pressure] kPa by [key_name_log(usr)]", INVESTIGATE_ATMOS)

/obj/machinery/atmospherics/trinary/filter/attackby(obj/item/I, mob/user, params)
	. = ..()

	if(ATTACK_CHAIN_CANCEL_CHECK(.))
		return .

	. |= ATTACK_CHAIN_SUCCESS
	rename_interactive(user, I)

//FROM MAPS

/obj/machinery/atmospherics/trinary/filter/o2
	filter_type = TLV_O2

/obj/machinery/atmospherics/trinary/filter/n2o
	filter_type = TLV_N2O

/obj/machinery/atmospherics/trinary/filter/co2
	filter_type = TLV_CO2

/obj/machinery/atmospherics/trinary/filter/n2
	filter_type = TLV_N2

/obj/machinery/atmospherics/trinary/filter/flipped/n2o
	filter_type = TLV_N2O

/obj/machinery/atmospherics/trinary/filter/flipped/co2
	filter_type = TLV_CO2

/obj/machinery/atmospherics/trinary/filter/flipped/o2
	filter_type = TLV_O2

/obj/machinery/atmospherics/trinary/filter/flipped/n2
	filter_type = TLV_N2

/obj/machinery/atmospherics/trinary/filter/flipped/none
	filter_type = FILTER_NOTHING

#undef FILTER_NOTHING
