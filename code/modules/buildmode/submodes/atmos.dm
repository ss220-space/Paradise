/datum/buildmode_mode/atmos
	key = "atmos"

	use_corner_selection = TRUE
	var/pressure = ONE_ATMOSPHERE
	var/temperature = T20C
	var/oxygen = O2STANDARD
	var/nitrogen = N2STANDARD
	var/plasma = 0
	var/cdiox = 0
	var/nitrox = 0
	var/agentbx = 0

/datum/buildmode_mode/atmos/show_help(mob/user)
	to_chat(user, span_purple(chat_box_examine(
		"[span_bold("Select corner")] -> Left Mouse Button on turf\n\
		[span_bold("Set 'base atmos conditions' for space turfs in region")] -> Left Mouse Button + Ctrl on turf\n\
		[span_bold("Adjust target atmos")] -> Right Mouse Button on buildmode button\n\
		\n\
		Starts out with standard breathable/liveable defaults."))
	)

// FIXME this is a little tedious, something where you don't have to fill in each field would be cooler
// maybe some kind of stat panel thing?
/datum/buildmode_mode/atmos/change_settings(mob/user)
	pressure = tgui_input_number(user, "Atmospheric Pressure", "Input", ONE_ATMOSPHERE, round_value = FALSE)
	temperature = tgui_input_number(user, "Temperature", "Input", T20C, round_value = FALSE)
	oxygen = tgui_input_number(user, "Oxygen ratio", "Input", O2STANDARD, round_value = FALSE)
	nitrogen = tgui_input_number(user, "Nitrogen ratio", "Input", N2STANDARD, round_value = FALSE)
	plasma = tgui_input_number(user, "Plasma ratio", "Input", 0, round_value = FALSE)
	cdiox = tgui_input_number(user, "CO2 ratio", "Input", 0, round_value = FALSE)
	nitrox = tgui_input_number(user, "N2O ratio", "Input", 0, round_value = FALSE)
	agentbx = tgui_input_number(user, "Agent B ratio", "Input", 0, round_value = FALSE)

/datum/buildmode_mode/atmos/proc/ppratio_to_moles(ppratio)
	// ideal gas equation: Pressure * Volume = Moles * r * Temperature
	// air datum fields are in moles, we have partial pressure ratios
	// Moles = (Pressure * Volume) / (r * Temperature)
	return ((ppratio * pressure) * CELL_VOLUME) / (temperature * R_IDEAL_GAS_EQUATION)

/datum/buildmode_mode/atmos/handle_selected_area(mob/user, params)
	var/list/modifiers = params2list(params)

	var/ctrl_click = LAZYACCESS(modifiers, CTRL_CLICK)

	if(LAZYACCESS(modifiers, LEFT_CLICK))
		for(var/turf/T in block(cornerA,cornerB))
			if(issimulatedturf(T))
				// fill the turf with the appropriate gasses
				// this feels slightly icky
				var/turf/simulated/S = T
				if(S.air)
					S.air.temperature = temperature
					S.air.oxygen = ppratio_to_moles(oxygen)
					S.air.nitrogen = ppratio_to_moles(nitrogen)
					S.air.toxins = ppratio_to_moles(plasma)
					S.air.carbon_dioxide = ppratio_to_moles(cdiox)
					S.air.sleeping_agent = ppratio_to_moles(nitrox)
					S.air.agent_b = ppratio_to_moles(agentbx)
					S.update_visuals()
					S.air_update_turf()
			else if(ctrl_click)
				T.temperature = temperature
				T.oxygen = ppratio_to_moles(oxygen)
				T.nitrogen = ppratio_to_moles(nitrogen)
				T.toxins = ppratio_to_moles(plasma)
				T.carbon_dioxide = ppratio_to_moles(cdiox)
				T.sleeping_agent = ppratio_to_moles(nitrox)
				T.agent_b = ppratio_to_moles(agentbx)
				T.air_update_turf()

		// admin log
		log_admin("Build Mode: [key_name(user)] changed the atmos of region [COORD(cornerA)] to [COORD(cornerB)]. T: [temperature], P: [pressure], Ox: [oxygen]%, N2: [nitrogen]%, Plsma: [plasma]%, CO2: [cdiox]%, N2O: [nitrox]%. [ctrl_click ? "Overwrote base space turf gases." : ""]")
