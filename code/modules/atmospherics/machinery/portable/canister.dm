/obj/machinery/portable_atmospherics/canister
	name = "canister"
	icon = 'icons/map_icons/objects.dmi'
	icon_state = "/obj/machinery/portable_atmospherics/canister"
	post_init_icon_state = ""
	greyscale_config = /datum/greyscale_config/canister/hazard
	greyscale_colors = "#ffff00#000000"
	density = TRUE
	flags = CONDUCT
	armor = list(MELEE = 50, BULLET = 50, LASER = 50, ENERGY = 100, BOMB = 10, FIRE = 80, ACID = 50)
	integrity_failure = 100
	cares_about_temperature = TRUE
	volume = 1000
	interact_offline = TRUE
	pressure_resistance = 7 * ONE_ATMOSPHERE

	var/icon/canister_overlay_file = 'icons/obj/pipes_and_stuff/atmospherics/canisters.dmi'

	var/valve_open = FALSE
	var/release_pressure = ONE_ATMOSPHERE

	var/can_label = TRUE
	var/filled = 0.5
	var/temperature_resistance = 1000 + T0C
	///Window overlay showing the gas inside the canister
	var/image/window
	var/static/alpha_filter
	var/static/list/possible_configs = list(
		/datum/greyscale_config/canister,
		/datum/greyscale_config/canister/stripe,
		/datum/greyscale_config/canister/double_stripe,
		/datum/greyscale_config/canister/hazard,
	)

/obj/machinery/portable_atmospherics/canister/Initialize(mapload)
	if(!alpha_filter)
		alpha_filter = filter(type = "alpha", icon = icon(canister_overlay_file, "window-base"))
	if(!istext(possible_configs[1]))
		var/list/new_configs = list()
		for(var/config in possible_configs)
			new_configs += "[config]"
		possible_configs = new_configs

	. = ..()
	update_icon()
	RegisterSignal(SSdcs, COMSIG_GLOB_SUBSYSTEMS_INIT_ENDED, PROC_REF(on_subsystems_init_ended))

/obj/machinery/portable_atmospherics/canister/proc/on_subsystems_init_ended(datum/source)
	SIGNAL_HANDLER
	update_window()
	UnregisterSignal(SSdcs, COMSIG_GLOB_SUBSYSTEMS_INIT_ENDED)

/obj/machinery/portable_atmospherics/canister/update_overlays()
	. = ..()
	underlays.Cut()

	var/isBroken = stat & BROKEN
	///Function is used to actually set the overlays

	. += mutable_appearance(canister_overlay_file, "tier[valve_open? 3 : 1]")
	if(isBroken)
		. += mutable_appearance(canister_overlay_file, "broken")
	if(holding)
		. += mutable_appearance(canister_overlay_file, "can-open")
	if(connected_port)
		. += mutable_appearance(canister_overlay_file, "can-connector")

	var/pressure_light
	switch(air_contents.return_pressure())
		if((40 * ONE_ATMOSPHERE) to INFINITY)
			pressure_light = "can-3"
		if((10 * ONE_ATMOSPHERE) to (40 * ONE_ATMOSPHERE))
			pressure_light = "can-2"
		if((5 * ONE_ATMOSPHERE) to (10 * ONE_ATMOSPHERE))
			pressure_light = "can-1"
		if(0 to (5 * ONE_ATMOSPHERE))
			pressure_light = "can-0"

	. += mutable_appearance(canister_overlay_file, pressure_light)
	underlays += emissive_appearance(canister_overlay_file, pressure_light, src)
	update_window()

/obj/machinery/portable_atmospherics/canister/update_greyscale()
	. = ..()
	update_window()

/obj/machinery/portable_atmospherics/canister/proc/update_window()
	if(!air_contents)
		return

	if(!alpha_filter) // Gotta do this separate since the icon may not be correct at world init
		alpha_filter = filter(type="alpha", icon = icon(canister_overlay_file, "window-base"))

	cut_overlay(window)
	var/list/window_overlays = list()
	var/turf/tile = get_turf(src)

	if(!tile)
		return

	for(var/visual in air_contents.return_visuals(tile.z))
		var/image/new_visual = image(visual, layer = FLOAT_PLANE)
		new_visual.filters = alpha_filter
		window_overlays += new_visual

	if(length(window_overlays) == 0)
		return

	window = image(canister_overlay_file, icon_state = "window-base", layer = FLOAT_LAYER)
	window.overlays = window_overlays
	add_overlay(window)

/obj/machinery/portable_atmospherics/canister/temperature_expose(exposed_temperature, exposed_volume)
	..()
	if(exposed_temperature > temperature_resistance)
		take_damage(5, BURN, 0)

/obj/machinery/portable_atmospherics/canister/deconstruct(disassembled = TRUE)
	if(!(obj_flags & NODECONSTRUCT))
		if(!(stat & BROKEN))
			canister_break()
		if(disassembled)
			new /obj/item/stack/sheet/metal (loc, 10)
		else
			new /obj/item/stack/sheet/metal (loc, 5)
	qdel(src)

/obj/machinery/portable_atmospherics/canister/obj_break(damage_flag)
	if((stat & BROKEN) || (obj_flags & NODECONSTRUCT))
		return
	canister_break()

/obj/machinery/portable_atmospherics/canister/proc/canister_break()
	disconnect()
	var/datum/gas_mixture/expelled_gas = air_contents.remove(air_contents.total_moles())

	stat |= BROKEN
	set_density(FALSE)
	playsound(loc, 'sound/effects/spray.ogg', 10, TRUE, -3)
	update_icon()

	var/turf/turf = get_turf(src)
	if(holding)
		holding.forceMove(turf)
		holding = null
	turf.blind_release_air(expelled_gas)

	animate(src, 0.5 SECONDS, transform=turn(transform, rand(-179, 180)), easing=BOUNCE_EASING)


/obj/machinery/portable_atmospherics/canister/process_atmos()
	..()
	if(stat & BROKEN)
		return

	if(valve_open)
		var/datum/milla_safe/canister_release/milla = new()
		milla.invoke_async(src)

	if(air_contents.return_pressure() < 1)
		can_label = TRUE
	else
		can_label = FALSE

/datum/milla_safe/canister_release

/datum/milla_safe/canister_release/on_run(obj/machinery/portable_atmospherics/canister/canister)
	var/datum/gas_mixture/environment
	if(canister.holding)
		environment = canister.holding.air_contents
	else
		var/turf/turf = get_turf(canister)
		environment = get_turf_air(turf)

	var/env_pressure = environment.return_pressure()
	var/pressure_delta = min(canister.release_pressure - env_pressure, (canister.air_contents.return_pressure() - env_pressure) / 2)
	//Can not have a pressure delta that would cause environment pressure > tank pressure

	var/transfer_moles = 0
	if((canister.air_contents.temperature() > 0) && (pressure_delta > 0))
		transfer_moles = pressure_delta * environment.volume / (canister.air_contents.temperature() * R_IDEAL_GAS_EQUATION)

		//Actually transfer the gas
		var/datum/gas_mixture/removed = canister.air_contents.remove(transfer_moles)

		environment.merge(removed)
		canister.update_icon()

/obj/machinery/portable_atmospherics/canister/return_obj_air()
	RETURN_TYPE(/datum/gas_mixture)
	return air_contents

/obj/machinery/portable_atmospherics/canister/proc/return_temperature()
	var/datum/gas_mixture/mixture = return_obj_air()
	if(mixture && mixture.volume > 0)
		return mixture.temperature()
	return 0

/obj/machinery/portable_atmospherics/canister/proc/return_pressure()
	var/datum/gas_mixture/mixture = return_obj_air()
	if(mixture && mixture.volume > 0)
		return mixture.return_pressure()
	return 0

/obj/machinery/portable_atmospherics/canister/replace_tank(mob/living/user, close_valve)
	. = ..()
	if(!.)
		return

	if(close_valve)
		valve_open = FALSE
		update_icon()
		investigate_log("Valve was <b>closed</b> by [key_name_log(user)].", INVESTIGATE_ATMOS)
	else if(valve_open && holding)
		investigate_log("[key_name_log(user)] started a transfer into [holding].", INVESTIGATE_ATMOS)

/obj/machinery/portable_atmospherics/canister/welder_act(mob/user, obj/item/I)
	if(!(stat & BROKEN))
		return

	. = TRUE

	if(!I.tool_use_check(user, 0))
		return

	WELDER_ATTEMPT_SLICING_MESSAGE
	if(I.use_tool(src, user, 50, volume = I.tool_volume))
		to_chat(user, span_notice("You salvage whats left of [src]!"))
		new /obj/item/stack/sheet/metal(drop_location(), 3)
		qdel(src)

/obj/machinery/portable_atmospherics/canister/attack_ai(mob/user)
	return attack_hand(user)

/obj/machinery/portable_atmospherics/canister/attack_ghost(mob/user)
	return ui_interact(user)

/obj/machinery/portable_atmospherics/canister/attack_hand(mob/user)
	if(..())
		return TRUE

	add_fingerprint(user)
	return ui_interact(user)

/obj/machinery/portable_atmospherics/canister/ui_state(mob/user)
	return GLOB.physical_state

/obj/machinery/portable_atmospherics/canister/ui_interact(mob/user, datum/tgui/ui = null)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "Canister", name)
		ui.open()

/obj/machinery/portable_atmospherics/canister/ui_data()
	var/data = list()
	data["portConnected"] = connected_port ? 1 : 0
	data["tankPressure"] = round(air_contents.return_pressure() ? air_contents.return_pressure() : 0)
	data["releasePressure"] = round(release_pressure ? release_pressure : 0)
	data["defaultReleasePressure"] = ONE_ATMOSPHERE
	data["minReleasePressure"] = round(ONE_ATMOSPHERE / 10)
	data["maxReleasePressure"] = round(ONE_ATMOSPHERE * 10)
	data["valveOpen"] = valve_open ? 1 : 0
	data["name"] = name
	data["canLabel"] = can_label ? 1 : 0
	data["hasHoldingTank"] = holding ? 1 : 0
	if(holding)
		data["holdingTank"] = list("name" = holding.name, "tankPressure" = round(holding.air_contents.return_pressure()))

	if(!greyscale_colors)
		return data
	return data

/obj/machinery/portable_atmospherics/canister/ui_act(action, params)
	if(..())
		return
	var/can_min_release_pressure = round(ONE_ATMOSPHERE / 10)
	var/can_max_release_pressure = round(ONE_ATMOSPHERE * 10)
	. = TRUE
	switch(action)
		if("relabel")
			if(can_label)
				var/new_label = tgui_input_text(usr, "Choose canister label", "Name", name, max_length = MAX_NAME_LEN)
				if(can_label) //Exploit prevention
					if(new_label)
						name = new_label
					else
						name = "canister"
				else
					to_chat(usr, span_warning("As you attempted to rename it the pressure rose!"))
					. = FALSE
		if("pressure")
			var/pressure = params["pressure"]
			if(pressure == "reset")
				pressure = ONE_ATMOSPHERE
			else if(pressure == "min")
				pressure = can_min_release_pressure
			else if(pressure == "max")
				pressure = can_max_release_pressure
			else if(pressure == "input")
				pressure = tgui_input_number(usr, "New release pressure ([can_min_release_pressure]-[can_max_release_pressure] kPa):", name, release_pressure)
				if(isnull(pressure))
					. = FALSE
			else if(text2num(pressure) != null)
				pressure = text2num(pressure)
			if(.)
				release_pressure = clamp(round(pressure), can_min_release_pressure, can_max_release_pressure)
				investigate_log("was set to [release_pressure] kPa by [key_name_log(usr)].", INVESTIGATE_ATMOS)
		if("valve")
			var/logmsg
			valve_open = !valve_open
			if(valve_open)
				logmsg = "Valve was <b>opened</b> by [key_name_log(usr)], starting a transfer into [holding || "air"]."
				if(!holding)
					logmsg = "Valve was <b>opened</b> by [key_name_log(usr)], starting a transfer into the air."
					if(air_contents.toxins() > 0)
						message_admins("[key_name_admin(usr)] opened a canister that contains plasma in [ADMIN_VERBOSEJMP(src)]!")
						log_admin("[key_name(usr)] opened a canister that contains plasma at [AREACOORD(src)]")
					if(air_contents.sleeping_agent() > 0)
						message_admins("[key_name_admin(usr)] opened a canister that contains N2O in [ADMIN_VERBOSEJMP(src)]!")
						log_admin("[key_name(usr)] opened a canister that contains N2O at [AREACOORD(src)]")
					if(air_contents.sleeping_agent() > 0)
						message_admins("[key_name_admin(usr)] opened a canister that contains Hydrogen in [ADMIN_VERBOSEJMP(src)]!")
						log_admin("[key_name(usr)] opened a canister that contains Hydrogen at [AREACOORD(src)]")
			else
				logmsg = "Valve was <b>closed</b> by [key_name_log(usr)], stopping the transfer into the [holding || "air"]."
			investigate_log(logmsg, INVESTIGATE_ATMOS)
		if("eject")
			if(holding)
				if(valve_open)
					valve_open = FALSE
					investigate_log("Valve was <b>closed</b> by [key_name(usr)], stopping the transfer into the [holding]", INVESTIGATE_ATMOS)
				replace_tank(usr, FALSE)

		if("select_color")
			var/datum/greyscale_modify_menu/menu = new(
				src, usr, possible_configs,
				starting_icon_state = icon_state,
				starting_config = greyscale_config,
				starting_colors = greyscale_colors
			)
			menu.ui_interact(usr)

	add_fingerprint(usr)
	update_icon()

/obj/machinery/portable_atmospherics/canister/toxins
	name = "Canister \[Toxin (Plasma)\]"
	icon_state = "/obj/machinery/portable_atmospherics/canister/toxins"
	greyscale_colors = "#ff6100#000000"
	can_label = FALSE

/obj/machinery/portable_atmospherics/canister/oxygen
	name = "Canister: \[O2\]"
	icon_state = "/obj/machinery/portable_atmospherics/canister/oxygen"
	greyscale_config = /datum/greyscale_config/canister/stripe
	greyscale_colors = "#2786e5#e8fefe"
	can_label = FALSE

/obj/machinery/portable_atmospherics/canister/sleeping_agent
	name = "Canister: \[N2O\]"
	icon_state = "/obj/machinery/portable_atmospherics/canister/sleeping_agent"
	greyscale_config = /datum/greyscale_config/canister/double_stripe
	greyscale_colors = "#c63e3b#f7d5d3"
	can_label = FALSE

/obj/machinery/portable_atmospherics/canister/nitrogen
	name = "Canister: \[N2\]"
	icon_state = "/obj/machinery/portable_atmospherics/canister/nitrogen"
	greyscale_config = /datum/greyscale_config/canister
	greyscale_colors = "#d41010"
	can_label = FALSE

/obj/machinery/portable_atmospherics/canister/carbon_dioxide
	name = "Canister \[CO2\]"
	icon_state = "/obj/machinery/portable_atmospherics/canister/carbon_dioxide"
	greyscale_config = /datum/greyscale_config/canister
	greyscale_colors = "#4e4c48"
	can_label = FALSE

/obj/machinery/portable_atmospherics/canister/hydrogen
	name = "Canister \[H2\]"
	icon_state = "/obj/machinery/portable_atmospherics/canister/hydrogen"
	greyscale_config = /datum/greyscale_config/canister/stripe
	greyscale_colors = "#bdc2c0#ffffff"
	can_label = FALSE

/obj/machinery/portable_atmospherics/canister/water_vapor
	name = "Canister \[H2O\]"
	icon_state = "/obj/machinery/portable_atmospherics/canister/water_vapor"
	greyscale_config = /datum/greyscale_config/canister/double_stripe
	greyscale_colors = "#4c4e4d#f7d5d3"
	can_label = FALSE

/obj/machinery/portable_atmospherics/canister/air
	name = "Canister \[Air\]"
	icon_state = "/obj/machinery/portable_atmospherics/canister/air"
	greyscale_config = /datum/greyscale_config/canister
	greyscale_colors = "#c6c0b5"
	can_label = FALSE

/obj/machinery/portable_atmospherics/canister/custom_mix
	name = "Canister \[Custom\]"
	icon_state = "/obj/machinery/portable_atmospherics/canister/custom_mix"
	greyscale_config = /datum/greyscale_config/canister/double_stripe
	greyscale_colors = "#c6c0b5#a63131"
	can_label = FALSE

/obj/machinery/portable_atmospherics/canister/bz
	name = "Canister \[BZ\]"
	greyscale_config = /datum/greyscale_config/canister/double_stripe
	greyscale_colors = "#9b5d7f#d0d2a0"
	can_label = FALSE

/obj/machinery/portable_atmospherics/canister/freon
	name = "Canister \[Freon\]"
	filled = 1
	greyscale_config = /datum/greyscale_config/canister/double_stripe
	greyscale_colors = "#6696ee#fefb30"
	can_label = FALSE

/obj/machinery/portable_atmospherics/canister/halon
	name = "Canister \[Halon\]"
	filled = 1
	greyscale_config = /datum/greyscale_config/canister/double_stripe
	greyscale_colors = "#9b5d7f#368bff"
	can_label = FALSE

/obj/machinery/portable_atmospherics/canister/healium
	name = "Canister \[Healium\]"
	filled = 1
	greyscale_config = /datum/greyscale_config/canister/double_stripe
	greyscale_colors = "#009823#ff0e00"
	can_label = FALSE

/obj/machinery/portable_atmospherics/canister/helium
	name = "Canister \[Helium\]"
	filled = 1
	greyscale_config = /datum/greyscale_config/canister/double_stripe
	greyscale_colors = "#9b5d7f#368bff"
	can_label = FALSE

/obj/machinery/portable_atmospherics/canister/miasma
	name = "Canister \[Miasma\]"
	filled = 1
	greyscale_config = /datum/greyscale_config/canister/double_stripe
	greyscale_colors = "#009823#f7d5d3"
	can_label = FALSE

/obj/machinery/portable_atmospherics/canister/nitrium
	name = "Canister \[Nitrium\]"
	greyscale_config = /datum/greyscale_config/canister
	greyscale_colors = "#7b4732"
	can_label = FALSE

/obj/machinery/portable_atmospherics/canister/nob
	name = "Canister \[Hyper-noblium\]"
	greyscale_config = /datum/greyscale_config/canister/double_stripe
	greyscale_colors = "#6399fc#b2b2b2"
	can_label = FALSE

/obj/machinery/portable_atmospherics/canister/pluoxium
	name = "Canister \[Pluoxium\]"
	greyscale_config = /datum/greyscale_config/canister
	greyscale_colors = "#2786e5"
	can_label = FALSE

/obj/machinery/portable_atmospherics/canister/proto_nitrate
	name = "Canister \[Proto Nitrate\]"
	filled = 1
	greyscale_config = /datum/greyscale_config/canister/double_stripe
	greyscale_colors = "#008200#33cc33"
	can_label = FALSE

/obj/machinery/portable_atmospherics/canister/tritium
	name = "Canister \[Tritium\]"
	greyscale_colors = "#3fcd40#000000"
	can_label = FALSE

/obj/machinery/portable_atmospherics/canister/zauker
	name = "Canister \[Zauker\]"
	filled = 1
	greyscale_config = /datum/greyscale_config/canister/double_stripe
	greyscale_colors = "#009a00#006600"
	can_label = FALSE

/obj/machinery/portable_atmospherics/canister/antinoblium
	name = "Canister \[Antinoblium\]"
	filled = 1
	greyscale_config = /datum/greyscale_config/canister/double_stripe
	greyscale_colors = "#333333#fefb30"
	can_label = FALSE

/obj/machinery/portable_atmospherics/canister/toxins/init_internal_atmos()
	. = ..()
	air_contents.set_toxins((maximum_pressure * filled) * air_contents.volume / (R_IDEAL_GAS_EQUATION * air_contents.temperature()))

/obj/machinery/portable_atmospherics/canister/oxygen/init_internal_atmos()
	. = ..()
	air_contents.set_oxygen((maximum_pressure * filled) * air_contents.volume / (R_IDEAL_GAS_EQUATION * air_contents.temperature()))

/obj/machinery/portable_atmospherics/canister/sleeping_agent/init_internal_atmos()
	. = ..()
	air_contents.set_sleeping_agent((maximum_pressure * filled) * air_contents.volume / (R_IDEAL_GAS_EQUATION * air_contents.temperature()))

/obj/machinery/portable_atmospherics/canister/nitrogen/init_internal_atmos()
	. = ..()
	air_contents.set_nitrogen((maximum_pressure * filled) * air_contents.volume / (R_IDEAL_GAS_EQUATION * air_contents.temperature()))

/obj/machinery/portable_atmospherics/canister/carbon_dioxide/init_internal_atmos()
	. = ..()
	air_contents.set_carbon_dioxide((maximum_pressure * filled) * air_contents.volume / (R_IDEAL_GAS_EQUATION * air_contents.temperature()))

/obj/machinery/portable_atmospherics/canister/hydrogen/init_internal_atmos()
	. = ..()
	air_contents.set_hydrogen((maximum_pressure * filled) * air_contents.volume / (R_IDEAL_GAS_EQUATION * air_contents.temperature()))

/obj/machinery/portable_atmospherics/canister/water_vapor/init_internal_atmos()
	. = ..()
	air_contents.set_water_vapor((maximum_pressure * filled) * air_contents.volume / (R_IDEAL_GAS_EQUATION * air_contents.temperature()))

/obj/machinery/portable_atmospherics/canister/air/init_internal_atmos()
	. = ..()
	air_contents.set_oxygen((O2STANDARD * maximum_pressure * filled) * air_contents.volume / (R_IDEAL_GAS_EQUATION * air_contents.temperature()))
	air_contents.set_nitrogen((N2STANDARD * maximum_pressure * filled) * air_contents.volume / (R_IDEAL_GAS_EQUATION * air_contents.temperature()))

/obj/machinery/portable_atmospherics/canister/bz/init_internal_atmos()
	. = ..()
	air_contents.set_bz((maximum_pressure * filled) * air_contents.volume / (R_IDEAL_GAS_EQUATION * air_contents.temperature()))

/obj/machinery/portable_atmospherics/canister/freon/init_internal_atmos()
	. = ..()
	air_contents.set_freon((maximum_pressure * filled) * air_contents.volume / (R_IDEAL_GAS_EQUATION * air_contents.temperature()))

/obj/machinery/portable_atmospherics/canister/healium/init_internal_atmos()
	. = ..()
	air_contents.set_healium((maximum_pressure * filled) * air_contents.volume / (R_IDEAL_GAS_EQUATION * air_contents.temperature()))

/obj/machinery/portable_atmospherics/canister/helium/init_internal_atmos()
	. = ..()
	air_contents.set_helium((maximum_pressure * filled) * air_contents.volume / (R_IDEAL_GAS_EQUATION * air_contents.temperature()))

/obj/machinery/portable_atmospherics/canister/miasma/init_internal_atmos()
	. = ..()
	air_contents.set_miasma((maximum_pressure * filled) * air_contents.volume / (R_IDEAL_GAS_EQUATION * air_contents.temperature()))

/obj/machinery/portable_atmospherics/canister/nitrium/init_internal_atmos()
	. = ..()
	air_contents.set_nitrium((maximum_pressure * filled) * air_contents.volume / (R_IDEAL_GAS_EQUATION * air_contents.temperature()))

/obj/machinery/portable_atmospherics/canister/nob/init_internal_atmos()
	. = ..()
	air_contents.set_hypernoblium((maximum_pressure * filled) * air_contents.volume / (R_IDEAL_GAS_EQUATION * air_contents.temperature()))

/obj/machinery/portable_atmospherics/canister/pluoxium/init_internal_atmos()
	. = ..()
	air_contents.set_pluoxium((maximum_pressure * filled) * air_contents.volume / (R_IDEAL_GAS_EQUATION * air_contents.temperature()))

/obj/machinery/portable_atmospherics/canister/proto_nitrate/init_internal_atmos()
	. = ..()
	air_contents.set_proto_nitrate((maximum_pressure * filled) * air_contents.volume / (R_IDEAL_GAS_EQUATION * air_contents.temperature()))

/obj/machinery/portable_atmospherics/canister/tritium/init_internal_atmos()
	. = ..()
	air_contents.set_tritium((maximum_pressure * filled) * air_contents.volume / (R_IDEAL_GAS_EQUATION * air_contents.temperature()))

/obj/machinery/portable_atmospherics/canister/zauker/init_internal_atmos()
	. = ..()
	air_contents.set_zauker((maximum_pressure * filled) * air_contents.volume / (R_IDEAL_GAS_EQUATION * air_contents.temperature()))

/obj/machinery/portable_atmospherics/canister/antinoblium/init_internal_atmos()
	. = ..()
	air_contents.set_antinoblium((maximum_pressure * filled) * air_contents.volume / (R_IDEAL_GAS_EQUATION * air_contents.temperature()))

/obj/machinery/portable_atmospherics/canister/halon/init_internal_atmos()
	air_contents.set_halon((maximum_pressure * filled) * air_contents.volume / (R_IDEAL_GAS_EQUATION * air_contents.temperature()))
