/datum/canister_icons
	var
		possiblemaincolor = list( //these lists contain the possible colors of a canister
			list("name" = "\[N2O\]", "icon" = "redws"),
			list("name" = "\[N2\]", "icon" = "red"),
			list("name" = "\[O2\]", "icon" = "blue"),
			list("name" = "\[Toxin (Bio)\]", "icon" = "orange"),
			list("name" = "\[CO2\]", "icon" = "black"),
			list("name" = "\[Air\]", "icon" = "grey"),
			list("name" = "\[CAUTION\]", "icon" = "yellow"),
			list("name" = "\[SPECIAL\]", "icon" = "whiters")
			)
		possibleseccolor = list( // no point in having the N2O and "whiters" ones in these lists
			list("name" = "\[None\]", "icon" = "none"),
			list("name" = "\[N2\]", "icon" = "red-c"),
			list("name" = "\[O2\]", "icon" = "blue-c"),
			list("name" = "\[Toxin (Bio)\]", "icon" = "orange-c"),
			list("name" = "\[CO2\]", "icon" = "black-c"),
			list("name" = "\[Air\]", "icon" = "grey-c"),
			list("name" = "\[CAUTION\]", "icon" = "yellow-c")
			)
		possibletertcolor = list(
			list("name" = "\[None\]", "icon" = "none"),
			list("name" = "\[N2\]", "icon" = "red-c-1"),
			list("name" = "\[O2\]", "icon" = "blue-c-1"),
			list("name" = "\[Toxin (Bio)\]", "icon" = "orange-c-1"),
			list("name" = "\[CO2\]", "icon" = "black-c-1"),
			list("name" = "\[Air\]", "icon" = "grey-c-1"),
			list("name" = "\[CAUTION\]", "icon" = "yellow-c-1")
			)
		possiblequartcolor = list(
			list("name" = "\[None\]", "icon" = "none"),
			list("name" = "\[N2\]", "icon" = "red-c-2"),
			list("name" = "\[O2\]", "icon" = "blue-c-2"),
			list("name" = "\[Toxin (Bio)\]", "icon" = "orange-c-2"),
			list("name" = "\[CO2\]", "icon" = "black-c-2"),
			list("name" = "\[Air\]", "icon" = "grey-c-2"),
			list("name" = "\[CAUTION\]", "icon" = "yellow-c-2")
			)
GLOBAL_DATUM_INIT(canister_icon_container, /datum/canister_icons, new())

/obj/machinery/portable_atmospherics/canister
	name = "canister"
	icon = 'icons/obj/pipes_and_stuff/atmospherics/atmos.dmi'
	icon_state = "yellow"
	density = TRUE
	flags = CONDUCT
	armor = list(MELEE = 50, BULLET = 50, LASER = 50, ENERGY = 100, BOMB = 10, RAD = 100, FIRE = 80, ACID = 50)
	max_integrity = 250
	integrity_failure = 100

	var/valve_open = FALSE
	var/release_pressure = ONE_ATMOSPHERE

	/// Variable that stores colours
	var/list/canister_color
	/// List which stores tgui color indexes for the recoloring options, to enable previously-set colors to show up right
	var/list/color_index

	/// Lists for check_change()
	var/list/old_color

	/// Passed to the ui to render the color lists
	var/list/colorcontainer

	var/can_label = TRUE
	var/filled = 0.5
	pressure_resistance = 7 * ONE_ATMOSPHERE
	var/temperature_resistance = 1000 + T0C
	volume = 1000
	use_power = NO_POWER_USE
	interact_offline = TRUE
	var/update_flag = NONE


/obj/machinery/portable_atmospherics/canister/Initialize(mapload)
	. = ..()

	canister_color = list(
		"prim" = "yellow",
		"sec" = "none",
		"ter" = "none",
		"quart" = "none",
	)

	old_color = list()

	colorcontainer = list(
		"prim" = list(
			"options" = GLOB.canister_icon_container.possiblemaincolor,
			"name" = "Primary color",
		),
		"sec" = list(
			"options" = GLOB.canister_icon_container.possibleseccolor,
			"name" = "Secondary color",
		),
		"ter" = list(
			"options" = GLOB.canister_icon_container.possibletertcolor,
			"name" = "Tertiary color",
		),
		"quart" = list(
			"options" = GLOB.canister_icon_container.possiblequartcolor,
			"name" = "Quaternary color",
		)
	)

	color_index = list()
	update_icon()


#define HOLDING_TANK 1
#define CONNECTED_PORT 2
#define LOW_PRESSURE 4
#define NORMAL_PRESSURE 8
#define HIGH_PRESSURE 16
#define EXTREME_PRESSURE 32
#define NEW_COLOR 64
#define RESET 68

/obj/machinery/portable_atmospherics/canister/proc/check_change()
	var/old_flag = update_flag

	update_flag = NONE
	if(holding)
		update_flag |= HOLDING_TANK
	if(connected_port)
		update_flag |= CONNECTED_PORT

	var/tank_pressure = air_contents.return_pressure()
	if(tank_pressure < 10)
		update_flag |= LOW_PRESSURE
	else if(tank_pressure < ONE_ATMOSPHERE)
		update_flag |= NORMAL_PRESSURE
	else if(tank_pressure < 15*ONE_ATMOSPHERE)
		update_flag |= HIGH_PRESSURE
	else
		update_flag |= EXTREME_PRESSURE

	if(list2params(old_color) != list2params(canister_color))
		update_flag |= NEW_COLOR
		old_color = canister_color.Copy()

	return update_flag != old_flag


/obj/machinery/portable_atmospherics/canister/update_icon_state()
/*
(note: colors has to be applied every icon update)
*/
	if(stat & BROKEN)
		icon_state = "[canister_color["prim"]]-1"//yes, I KNOW the colours don't reflect when the can's borked, whatever.
		return

	if(icon_state != canister_color["prim"])
		icon_state = canister_color["prim"]

	check_change()


/obj/machinery/portable_atmospherics/canister/update_overlays()
	. = ..()

	if(stat & BROKEN)
		return

	for(var/C in canister_color)
		if(C == "prim")
			continue
		if(canister_color[C] == "none")
			continue
		. += canister_color[C]

	if(update_flag & HOLDING_TANK)
		. += "can-open"
	if(update_flag & CONNECTED_PORT)
		. += "can-connector"
	if(update_flag & LOW_PRESSURE)
		. += "can-o0"
	if(update_flag & NORMAL_PRESSURE)
		. += "can-o1"
	else if(update_flag & HIGH_PRESSURE)
		. += "can-o2"
	else if(update_flag & EXTREME_PRESSURE)
		. += "can-o3"

	update_flag &= ~RESET //the flag NEW_COLOR represents change, not states. As such, we have to reset them to be able to detect a change on the next go.

#undef HOLDING_TANK
#undef CONNECTED_PORT
#undef LOW_PRESSURE
#undef NORMAL_PRESSURE
#undef HIGH_PRESSURE
#undef EXTREME_PRESSURE
#undef NEW_COLOR
#undef RESET


/obj/machinery/portable_atmospherics/canister/temperature_expose(datum/gas_mixture/air, exposed_temperature, exposed_volume)
	..()
	if(exposed_temperature > temperature_resistance)
		take_damage(5, BURN, 0)

/obj/machinery/portable_atmospherics/canister/deconstruct(disassembled = TRUE)
	if(!(flags & NODECONSTRUCT))
		if(!(stat & BROKEN))
			canister_break()
		if(disassembled)
			new /obj/item/stack/sheet/metal (loc, 10)
		else
			new /obj/item/stack/sheet/metal (loc, 5)
	qdel(src)

/obj/machinery/portable_atmospherics/canister/obj_break(damage_flag)
	if((stat & BROKEN) || (flags & NODECONSTRUCT))
		return
	canister_break()

/obj/machinery/portable_atmospherics/canister/proc/canister_break()
	disconnect()
	var/datum/gas_mixture/expelled_gas = air_contents.remove(air_contents.total_moles())
	var/turf/T = get_turf(src)
	T.assume_air(expelled_gas)
	air_update_turf()

	stat |= BROKEN
	density = FALSE
	playsound(loc, 'sound/effects/spray.ogg', 10, TRUE, -3)
	update_icon()

	if(holding)
		holding.forceMove(T)
		holding = null


/obj/machinery/portable_atmospherics/canister/process_atmos()
	if(stat & BROKEN)
		return

	..()

	if(valve_open)
		var/datum/gas_mixture/environment
		if(holding)
			environment = holding.air_contents
		else
			environment = loc.return_air()

		var/env_pressure = environment.return_pressure()
		var/pressure_delta = min(release_pressure - env_pressure, (air_contents.return_pressure() - env_pressure)/2)
		//Can not have a pressure delta that would cause environment pressure > tank pressure

		var/transfer_moles = 0
		if((air_contents.temperature > 0) && (pressure_delta > 0))
			transfer_moles = pressure_delta * environment.volume / (air_contents.temperature * R_IDEAL_GAS_EQUATION)

			//Actually transfer the gas
			var/datum/gas_mixture/removed = air_contents.remove(transfer_moles)

			if(holding)
				environment.merge(removed)
			else
				loc.assume_air(removed)
				air_update_turf()
			update_icon()


	if(air_contents.return_pressure() < 1)
		can_label = TRUE
	else
		can_label = FALSE


/obj/machinery/portable_atmospherics/canister/return_air()
	return air_contents

/obj/machinery/portable_atmospherics/canister/proc/return_temperature()
	var/datum/gas_mixture/GM = return_air()
	if(GM && GM.volume>0)
		return GM.temperature
	return 0

/obj/machinery/portable_atmospherics/canister/proc/return_pressure()
	var/datum/gas_mixture/GM = return_air()
	if(GM && GM.volume>0)
		return GM.return_pressure()
	return 0

/obj/machinery/portable_atmospherics/canister/replace_tank(mob/living/user, close_valve)
	. = ..()
	if(.)
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


/obj/machinery/portable_atmospherics/canister/attack_ai(var/mob/user)
	return attack_hand(user)

/obj/machinery/portable_atmospherics/canister/attack_ghost(var/mob/user)
	return ui_interact(user)

/obj/machinery/portable_atmospherics/canister/attack_hand(var/mob/user)
	if(..())
		return TRUE

	add_fingerprint(user)
	return ui_interact(user)

/obj/machinery/portable_atmospherics/canister/ui_interact(mob/user, ui_key = "main", datum/tgui/ui = null, force_open = TRUE, datum/tgui/master_ui = null, datum/ui_state/state = GLOB.physical_state)
	ui = SStgui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "Canister", name, 600, 350, master_ui, state)
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
	data["colorContainer"] = colorcontainer.Copy()
	data["color_index"] = color_index
	data["hasHoldingTank"] = holding ? 1 : 0
	if(holding)
		data["holdingTank"] = list("name" = holding.name, "tankPressure" = round(holding.air_contents.return_pressure()))
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
				var/T = sanitize(copytext_char(input("Choose canister label", "Name", name) as text|null, 1, MAX_NAME_LEN))
				if(can_label) //Exploit prevention
					if(T)
						name = T
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
				pressure = input("New release pressure ([can_min_release_pressure]-[can_max_release_pressure] kPa):", name, release_pressure) as num|null
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
					if(air_contents.toxins > 0)
						message_admins("[key_name_admin(usr)] opened a canister that contains plasma in [ADMIN_VERBOSEJMP(src)]!")
						log_admin("[key_name(usr)] opened a canister that contains plasma at [AREACOORD(src)]")
					if(air_contents.sleeping_agent > 0)
						message_admins("[key_name_admin(usr)] opened a canister that contains N2O in [ADMIN_VERBOSEJMP(src)]!")
						log_admin("[key_name(usr)] opened a canister that contains N2O at [AREACOORD(src)]")
			else
				logmsg = "Valve was <b>closed</b> by [key_name_log(usr)], stopping the transfer into the [holding || "air"]."
			investigate_log(logmsg, INVESTIGATE_ATMOS)
		if("eject")
			if(holding)
				if(valve_open)
					valve_open = FALSE
					investigate_log("Valve was <b>closed</b> by [key_name(usr)], stopping the transfer into the [holding]", INVESTIGATE_ATMOS)
				replace_tank(usr, FALSE)
		if("recolor")
			if(can_label)
				var/ctype = params["ctype"]
				var/cnum = text2num(params["nc"])
				if(isnull(colorcontainer[ctype]))
					message_admins("[key_name_admin(usr)] passed an invalid ctype var to a canister.")
					return
				var/newcolor = sanitize_integer(cnum, 0, length(colorcontainer[ctype]["options"]))
				color_index[ctype] = newcolor
				newcolor++ // javascript starts arrays at 0, byond (for some reason) starts them at 1, this converts JS values to byond values
				canister_color[ctype] = colorcontainer[ctype]["options"][newcolor]["icon"]
	add_fingerprint(usr)
	update_icon()


/obj/machinery/portable_atmospherics/canister/toxins
	name = "Canister \[Toxin (Plasma)\]"
	icon_state = "orange" //See Initialize()
	can_label = FALSE
/obj/machinery/portable_atmospherics/canister/oxygen
	name = "Canister: \[O2\]"
	icon_state = "blue" //See Initialize()
	can_label = FALSE
/obj/machinery/portable_atmospherics/canister/sleeping_agent
	name = "Canister: \[N2O\]"
	icon_state = "redws" //See Initialize()
	can_label = FALSE
/obj/machinery/portable_atmospherics/canister/nitrogen
	name = "Canister: \[N2\]"
	icon_state = "red" //See Initialize()
	can_label = FALSE
/obj/machinery/portable_atmospherics/canister/carbon_dioxide
	name = "Canister \[CO2\]"
	icon_state = "black" //See Initialize()
	can_label = FALSE
/obj/machinery/portable_atmospherics/canister/air
	name = "Canister \[Air\]"
	icon_state = "grey" //See Initialize()
	can_label = FALSE
/obj/machinery/portable_atmospherics/canister/custom_mix
	name = "Canister \[Custom\]"
	icon_state = "whiters" //See Initialize()
	can_label = FALSE


/obj/machinery/portable_atmospherics/canister/toxins/Initialize(mapload)
	. = ..()
	canister_color["prim"] = "orange"
	air_contents.toxins = (maximum_pressure * filled) * air_contents.volume / (R_IDEAL_GAS_EQUATION * air_contents.temperature)
	update_icon()


/obj/machinery/portable_atmospherics/canister/oxygen/Initialize(mapload)
	. = ..()
	canister_color["prim"] = "blue"
	air_contents.oxygen = (maximum_pressure * filled) * air_contents.volume / (R_IDEAL_GAS_EQUATION * air_contents.temperature)
	update_icon()


/obj/machinery/portable_atmospherics/canister/sleeping_agent/Initialize(mapload)
	. = ..()
	canister_color["prim"] = "redws"
	air_contents.sleeping_agent = (maximum_pressure * filled) * air_contents.volume / (R_IDEAL_GAS_EQUATION * air_contents.temperature)
	update_icon()


/obj/machinery/portable_atmospherics/canister/nitrogen/Initialize(mapload)
	. = ..()
	canister_color["prim"] = "red"
	air_contents.nitrogen = (maximum_pressure * filled) * air_contents.volume / (R_IDEAL_GAS_EQUATION * air_contents.temperature)
	update_icon()


/obj/machinery/portable_atmospherics/canister/carbon_dioxide/Initialize(mapload)
	. = ..()
	canister_color["prim"] = "black"
	air_contents.carbon_dioxide = (maximum_pressure * filled) * air_contents.volume / (R_IDEAL_GAS_EQUATION * air_contents.temperature)
	update_icon()


/obj/machinery/portable_atmospherics/canister/air/Initialize(mapload)
	. = ..()
	canister_color["prim"] = "grey"
	air_contents.oxygen = (O2STANDARD * maximum_pressure * filled) * air_contents.volume / (R_IDEAL_GAS_EQUATION * air_contents.temperature)
	air_contents.nitrogen = (N2STANDARD * maximum_pressure * filled) * air_contents.volume / (R_IDEAL_GAS_EQUATION * air_contents.temperature)
	update_icon()


/obj/machinery/portable_atmospherics/canister/custom_mix/Initialize(mapload)
	. = ..()
	canister_color["prim"] = "whiters"
	update_icon() // Otherwise new canisters do not have their icon updated with the pressure light, likely want to add this to the canister class constructor, avoiding at current time to refrain from screwing up code for other canisters. --DZD

