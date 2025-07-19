
/// Nothing will be filtered.
#define FILTER_NOTHING 			""
//very cleverly using the gas index defines so as to simplify a bunch of logic
#define FILTER_PLASMA			GAS_PL
#define FILTER_OXYGEN			GAS_O2
#define FILTER_NITROGEN			GAS_N2
#define FILTER_CARBONDIOXIDE	GAS_CO2
#define FILTER_NITROUSOXIDE		GAS_N2O

/obj/machinery/atmospherics/components/trinary/filter
	name = "gas filter"
	icon_state = "map_filter"
	can_unwrench = TRUE
	interaction_flags_click = NEED_HANDS | ALLOW_RESTING | ALLOW_SILICON_REACH
	/// The amount of pressure the filter wants to operate at.
	var/target_pressure = ONE_ATMOSPHERE
	/// The type of gas we want to filter. Valid values that go here are from the `FILTER` defines at the top of the file.
	var/filter_type = FILTER_PLASMA
	/// A list of available filter options. Used with `ui_data`.
	var/list/filter_list = list(
		"Nothing" = FILTER_NOTHING,
		"Plasma" = FILTER_PLASMA,
		"O2" = FILTER_OXYGEN,
		"N2" = FILTER_NITROGEN,
		"CO2" = FILTER_CARBONDIOXIDE,
		"N2O" = FILTER_NITROUSOXIDE
	)

/obj/machinery/atmospherics/components/trinary/filter/CtrlClick(mob/living/user)
	if(!ishuman(user) && !issilicon(user))
		return
	if(user.incapacitated() || HAS_TRAIT(user, TRAIT_HANDS_BLOCKED))
		to_chat(user, span_warning("You can't do that right now!"))
		return
	if(!in_range(src, user) && !issilicon(user))
		return
	toggle()

/obj/machinery/atmospherics/components/trinary/filter/AICtrlClick()
	toggle()
	return ..()

/obj/machinery/atmospherics/components/trinary/filter/click_alt(mob/living/user)
	set_max()
	return CLICK_ACTION_SUCCESS

/obj/machinery/atmospherics/components/trinary/filter/ai_click_alt()
	set_max()
	return ..()


/obj/machinery/atmospherics/components/trinary/filter/proc/set_max()
	if(powered())
		target_pressure = MAX_OUTPUT_PRESSURE
		update_icon()

/obj/machinery/atmospherics/components/trinary/filter/flipped
	icon_state = "mmap_filter"
	flipped = TRUE

/obj/machinery/atmospherics/components/trinary/filter/update_icon_state()
	..()

	if(flipped)
		icon_state = "m"
	else
		icon_state = ""

	if(!powered())
		icon_state += "filter_off"
	else if(NODE1 && NODE2 && NODE3)
		icon_state += on ? "filter_on" : "filter_off"
	else
		icon_state += "filter_off"
		on = FALSE

/obj/machinery/atmospherics/components/trinary/filter/update_underlays()
	if(..())
		underlays.Cut()
		var/turf/T = get_turf(src)
		if(!istype(T))
			return

		add_underlay(T, NODE1, turn(dir, -180))

		if(flipped)
			add_underlay(T, NODE2, turn(dir, 90))
		else
			add_underlay(T, NODE2, turn(dir, -90))

		add_underlay(T, NODE2, dir)

/obj/machinery/atmospherics/components/trinary/filter/power_change(forced = FALSE)
	if(!..())
		return
	update_icon()

/obj/machinery/atmospherics/components/trinary/filter/process_atmos()
	..()
	if(!on)
		return FALSE

	if(!(NODE1 && NODE1 && NODE3))
		return FALSE

	var/datum/gas_mixture/air1 = AIR1
	var/datum/gas_mixture/air2 = AIR2
	var/datum/gas_mixture/air3 = AIR3

	var/output_starting_pressure = air3.return_pressure()

	if(output_starting_pressure >= target_pressure || air2.return_pressure() >= target_pressure )
		//No need to mix if target is already full!
		return TRUE

	//Calculate necessary moles to transfer using PV=nRT

	var/pressure_delta = target_pressure - output_starting_pressure
	var/transfer_moles

	if(air1.temperature > 0)
		transfer_moles = pressure_delta*air3.volume/(air1.temperature * R_IDEAL_GAS_EQUATION)

	//Actually transfer the gas

	if(transfer_moles > 0)
		var/datum/gas_mixture/removed = air1.remove(transfer_moles)

		if(!removed)
			return
		var/datum/gas_mixture/filtered_out = new
		filtered_out.temperature = removed.temperature
		var/list/filtered_gases = filtered_out.gases
		var/list/removed_gases = removed.gases

		if(filter_type && removed_gases[filter_type])
			filtered_out.assert_gas(filter_type)
			filtered_gases[filter_type][MOLES] = removed_gases[filter_type][MOLES]
			removed_gases[filter_type][MOLES] = 0
			if(filter_type == FILTER_PLASMA && removed.gases[GAS_AGENT_B])
				filtered_out.assert_gas(GAS_AGENT_B)
				filtered_gases[GAS_AGENT_B][MOLES] = removed_gases[GAS_AGENT_B][MOLES]
				removed_gases[GAS_AGENT_B][MOLES] = 0
		else
			filtered_out = null


		air2.merge(filtered_out)
		air3.merge(removed)

	update_parents()

	return TRUE

/obj/machinery/atmospherics/components/trinary/filter/atmos_init()
	set_frequency(frequency)
	..()

/obj/machinery/atmospherics/components/trinary/filter/attack_ghost(mob/user)
	ui_interact(user)

/obj/machinery/atmospherics/components/trinary/filter/attack_hand(mob/user)
	if(..())
		return

	if(!allowed(user))
		to_chat(user, span_alert("Access denied."))
		return

	add_fingerprint(user)
	ui_interact(user)

/obj/machinery/atmospherics/components/trinary/filter/ui_interact(mob/user, datum/tgui/ui = null)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "AtmosFilter", name)
		ui.open()

/obj/machinery/atmospherics/components/trinary/filter/ui_data(mob/user)
	var/list/data = list(
		"on" = on,
		"pressure" = round(target_pressure),
		"max_pressure" = round(MAX_OUTPUT_PRESSURE),
		"filter_type" = filter_type
	)
	data["filter_type_list"] = list()
	for(var/label in filter_list)
		data["filter_type_list"] += list(list("label" = label, "gas_type" = filter_list[label]))

	return data

/obj/machinery/atmospherics/components/trinary/filter/ui_act(action, list/params)
	if(..())
		return

	switch(action)
		if("power")
			toggle()
			investigate_log("was turned [on ? "on" : "off"] by [key_name_log(usr)]", INVESTIGATE_ATMOS)
			return TRUE

		if("set_filter")
			filter_type = text2num(params["filter"])
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


/obj/machinery/atmospherics/components/trinary/filter/attackby(obj/item/I, mob/user, params)
	. = ..()

	if(ATTACK_CHAIN_CANCEL_CHECK(.))
		return .

	. |= ATTACK_CHAIN_SUCCESS
	rename_interactive(user, I)


#undef FILTER_NOTHING
#undef FILTER_PLASMA
#undef FILTER_OXYGEN
#undef FILTER_NITROGEN
#undef FILTER_CARBONDIOXIDE
#undef FILTER_NITROUSOXIDE
