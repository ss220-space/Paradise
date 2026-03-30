/datum/buildmode_mode/atmos
	key = "atmos"

	use_corner_selection = TRUE
	var/pressure = ONE_ATMOSPHERE
	var/temperature = T20C
	var/list/gas_ratio = list()

/datum/buildmode_mode/atmos/New(datum/click_intercept/buildmode/newBM)
	for(var/gas_key in GLOB.gas_meta)
		gas_ratio[gas_key] = 0
	gas_ratio[TLV_O2] = O2STANDARD
	gas_ratio[TLV_N2] = N2STANDARD
	. = ..()

/datum/buildmode_mode/atmos/ui_data(mob/user)
	var/list/data = ..()
	data["temperature"] = temperature
	data["pressure"] = pressure
	data["gas_ratios"] = gas_ratio
	return data

/datum/buildmode_mode/atmos/ui_interact(mob/user, datum/tgui/ui = null)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "AtmosBuildMode", "Настройка атмос режима")
		ui.open()

/datum/buildmode_mode/atmos/ui_state(mob/user)
	return ADMIN_STATE(R_BUILDMODE)

/datum/buildmode_mode/atmos/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	switch(action)
		if("set_pressure")
			pressure = params["pressure"]

		if("set_temperature")
			temperature = params["temperature"]

		if("set_gas_ratio")
			gas_ratio[params["gas_id"]] = params["ratio"]

	return TRUE


/datum/buildmode_mode/atmos/show_help(mob/user)
	to_chat(user, span_purple(chat_box_examine(
		"[span_bold("Select corner")] -> Left Mouse Button on turf\n\
		[span_bold("Adjust target atmos")] -> Right Mouse Button on buildmode button\n\
		\n\
		Starts out with standard breathable/liveable defaults."))
	)

// FIXME this is a little tedious, something where you don't have to fill in each field would be cooler
// maybe some kind of stat panel thing?
/datum/buildmode_mode/atmos/change_settings(mob/user)
	ui_interact(user)

/datum/buildmode_mode/atmos/proc/ppratio_to_moles(ppratio)
	// ideal gas equation: Pressure * Volume = Moles * r * Temperature
	// air datum fields are in moles, we have partial pressure ratios
	// Moles = (Pressure * Volume) / (r * Temperature)
	return ((ppratio * pressure) * CELL_VOLUME) / (temperature * R_IDEAL_GAS_EQUATION)

/datum/buildmode_mode/atmos/handle_selected_area(mob/user, params)
	var/list/modifiers = params2list(params)

	var/ctrl_click = LAZYACCESS(modifiers, CTRL_CLICK)

	if(LAZYACCESS(modifiers, LEFT_CLICK))
		var/datum/gas_mixture/air = new()
		air.set_temperature(temperature)
		if(gas_ratio[TLV_O2] > 0)
			air.set_oxygen(ppratio_to_moles(gas_ratio[TLV_O2]))
		if(gas_ratio[TLV_N2] > 0)
			air.set_nitrogen(ppratio_to_moles(gas_ratio[TLV_N2]))
		if(gas_ratio[TLV_PL] > 0)
			air.set_toxins(ppratio_to_moles(gas_ratio[TLV_PL]))
		if(gas_ratio[TLV_CO2] > 0)
			air.set_carbon_dioxide(ppratio_to_moles(gas_ratio[TLV_CO2]))
		if(gas_ratio[TLV_N2O] > 0)
			air.set_sleeping_agent(ppratio_to_moles(gas_ratio[TLV_N2O]))
		if(gas_ratio[TLV_AGENT_B] > 0)
			air.set_agent_b(ppratio_to_moles(gas_ratio[TLV_AGENT_B]))
		if(gas_ratio[TLV_H2] > 0)
			air.set_hydrogen(ppratio_to_moles(gas_ratio[TLV_H2]))
		if(gas_ratio[TLV_H2O] > 0)
			air.set_water_vapor(ppratio_to_moles(gas_ratio[TLV_H2O]))
		if(gas_ratio[TLV_TRITIUM] > 0)
			air.set_tritium(ppratio_to_moles(gas_ratio[TLV_TRITIUM]))
		if(gas_ratio[TLV_BZ] > 0)
			air.set_bz(ppratio_to_moles(gas_ratio[TLV_BZ]))
		if(gas_ratio[TLV_PLUOXIUM] > 0)
			air.set_pluoxium(ppratio_to_moles(gas_ratio[TLV_PLUOXIUM]))
		if(gas_ratio[TLV_MIASMA] > 0)
			air.set_miasma(ppratio_to_moles(gas_ratio[TLV_MIASMA]))
		if(gas_ratio[TLV_FREON] > 0)
			air.set_freon(ppratio_to_moles(gas_ratio[TLV_FREON]))
		if(gas_ratio[TLV_NITRIUM] > 0)
			air.set_nitrium(ppratio_to_moles(gas_ratio[TLV_NITRIUM]))
		if(gas_ratio[TLV_HEALIUM] > 0)
			air.set_healium(ppratio_to_moles(gas_ratio[TLV_HEALIUM]))
		if(gas_ratio[TLV_PROTO_NITRATE] > 0)
			air.set_proto_nitrate(ppratio_to_moles(gas_ratio[TLV_PROTO_NITRATE]))
		if(gas_ratio[TLV_ZAUKER] > 0)
			air.set_zauker(ppratio_to_moles(gas_ratio[TLV_ZAUKER]))
		if(gas_ratio[TLV_HALON] > 0)
			air.set_halon(ppratio_to_moles(gas_ratio[TLV_HALON]))
		if(gas_ratio[TLV_HELIUM] > 0)
			air.set_helium(ppratio_to_moles(gas_ratio[TLV_HELIUM]))
		if(gas_ratio[TLV_ANTINOBLIUM] > 0)
			air.set_antinoblium(ppratio_to_moles(gas_ratio[TLV_ANTINOBLIUM]))
		if(gas_ratio[TLV_HYPERNOBLIUM] > 0)
			air.set_hyper_noblium(ppratio_to_moles(gas_ratio[TLV_HYPERNOBLIUM]))

		for(var/turf/turf in block(cornerA, cornerB))
			if(issimulatedturf(turf))
				// fill the turf with the appropriate gasses
				var/turf/simulated/simulated_turf = turf
				if(!simulated_turf.blocks_air)
					turf.blind_set_air(air)

		// admin log
		var/list/log_string = list("Build Mode: [key_name(user)] changed the atmos of region [COORD(cornerA)] to [COORD(cornerB)]. T: [temperature], P: [pressure]")
		for(var/gas_id, value in gas_ratio)
			if(value > 0)
				log_string += ", [gas_id]: [value]%"

		if(ctrl_click)
			log_string += ". Overwrote base space turf gases."

		log_admin(log_string.Join(""))
