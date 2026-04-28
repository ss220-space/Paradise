#define AALARM_PRESET_HUMAN 1 // Default
#define AALARM_PRESET_VOX 2 // Support Vox
#define AALARM_PRESET_COLDROOM 3 // Kitchen coldroom
#define AALARM_PRESET_SERVER 4 // Server coldroom

#define AALARM_REPORT_TIMEOUT 100

#define RCON_NO 1
#define RCON_AUTO 2
#define RCON_YES 3

/// 1000 joules equates to about 1 degree every 2 seconds for a single tile of air.
#define MAX_ENERGY_CHANGE 1000

#define MAX_TEMPERATURE 363.15 // 90C
#define MIN_TEMPERATURE 233.15 // -40C

// Air alarm build stages
#define AIR_ALARM_BUILD_NO_CIRCUIT 0
#define AIR_ALARM_BUILD_CIRCUIT 1
#define AIR_ALARM_WIRED 2

GLOBAL_LIST_INIT(aalarm_modes, list(
	"[AALARM_MODE_FILTERING]" = "Filtering",
	"[AALARM_MODE_DRAUGHT]" = "Draught",
	"[AALARM_MODE_PANIC]" = "Panic",
	"[AALARM_MODE_CYCLE]" = "Cycle",
	"[AALARM_MODE_SIPHON]" = "Siphon",
	"[AALARM_MODE_CONTAMINATED]" = "Contaminated",
	"[AALARM_MODE_REFILL]" = "Refill",
	"[AALARM_MODE_CUSTOM]" = "Custom",
	"[AALARM_MODE_OFF]" = "Off",
	"[AALARM_MODE_FLOOD]" = "Flood",
))

GLOBAL_LIST_INIT(human_tlv, list(
		TLV_O2 = new /datum/tlv/oxygen(),
		TLV_N2 = new /datum/tlv/nitrogen(),
		TLV_CO2 = new /datum/tlv/carbon_dioxide(),
		TLV_PL = new /datum/tlv/dangerous(),
		TLV_N2O = new /datum/tlv/dangerous(),
		TLV_H2 = new /datum/tlv/dangerous(),
		TLV_H2O = new /datum/tlv/water_vapor(),
		TLV_TRITIUM = new /datum/tlv/dangerous(),
		TLV_BZ = new /datum/tlv/dangerous(),
		TLV_PLUOXIUM = new /datum/tlv/ignore(),
		TLV_MIASMA = new /datum/tlv/dangerous(),
		TLV_FREON = new /datum/tlv/dangerous(),
		TLV_NITRIUM = new /datum/tlv/dangerous(),
		TLV_HEALIUM = new /datum/tlv/dangerous(),
		TLV_PROTO_NITRATE = new /datum/tlv/dangerous(),
		TLV_ZAUKER = new /datum/tlv/dangerous(),
		TLV_HALON = new /datum/tlv/dangerous(),
		TLV_HELIUM = new /datum/tlv/ignore(),
		TLV_ANTINOBLIUM = new /datum/tlv/ignore(),
		TLV_HYPERNOBLIUM = new /datum/tlv/ignore(),
		TLV_OTHER = new /datum/tlv/other_gas(),
		TLV_PRESSURE = new /datum/tlv/pressure(),
		TLV_TEMPERATURE = new /datum/tlv/temperature()
	))


/obj/machinery/alarm
	name = "air alarm"
	icon = 'icons/obj/machines/monitors.dmi'
	icon_state = "alarm0"
	anchored = TRUE
	idle_power_usage = 4
	active_power_usage = 8
	power_channel = ENVIRON
	req_access = list(ACCESS_ATMOSPHERICS, ACCESS_ENGINE_EQUIP)
	max_integrity = 250
	integrity_failure = 80
	armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 100, BOMB = 0, BIO = 100, FIRE = 90, ACID = 30)
	resistance_flags = FIRE_PROOF
	siemens_strength = 1
	frequency = ATMOS_VENTSCRUB
	/// Which MILLA tick were we initialized at?
	var/init_tick
	var/alarm_id = null
	//var/skipprocess = 0 //Experimenting
	var/alarm_frequency = ATMOS_FIRE_FREQ
	var/remote_control = TRUE
	var/rcon_setting = RCON_AUTO
	var/rcon_time = 0
	var/locked = 1
	var/datum/wires/alarm/wires = null
	var/wiresexposed = FALSE // If it's been screwdrivered open.
	var/aidisabled = 0
	var/AAlarmwires = 31
	var/shorted = 0

	var/mode = AALARM_MODE_FILTERING
	var/preset = AALARM_PRESET_HUMAN
	var/area/alarm_area
	var/danger_level = ATMOS_ALARM_NONE
	var/alarmActivated = 0 // Manually activated (independent from danger level)

	var/buildstage = AIR_ALARM_WIRED

	var/target_temperature = T20C
	var/regulating_temperature = 0
	var/thermostat_state = FALSE

	var/list/TLV = list()

	var/report_danger_level = TRUE


/obj/machinery/alarm/monitor
	report_danger_level = FALSE

/obj/machinery/alarm/syndicate //general syndicate access
	report_danger_level = FALSE
	remote_control = FALSE
	req_access = list(ACCESS_SYNDICATE)

/obj/machinery/alarm/syndicate/pirate // alarm for admin spawn map
	req_access = list(160)

/obj/machinery/alarm/monitor/server
	preset = AALARM_PRESET_SERVER

/obj/machinery/alarm/server
	preset = AALARM_PRESET_SERVER

/obj/machinery/alarm/vox
	preset = AALARM_PRESET_VOX

/obj/machinery/alarm/kitchen_cold_room
	preset = AALARM_PRESET_COLDROOM

/obj/machinery/alarm/proc/apply_preset(no_cycle_after=0)
	// Propogate settings.
	for(var/obj/machinery/alarm/AA in alarm_area.machinery_cache)
		if(!(AA.stat & (NOPOWER|BROKEN)) && !AA.shorted && AA.preset != src.preset)
			AA.preset = preset
			apply_preset(1) // Only this air alarm should send a cycle.

	var/list/tlv_config = GLOB.human_tlv.Copy()

	switch(preset)
		if(AALARM_PRESET_VOX)
			tlv_config[TLV_O2] = new /datum/tlv/vox_oxygen()
			tlv_config[TLV_N2] = new /datum/tlv/oxygen()
			tlv_config[TLV_TEMPERATURE] = new /datum/tlv/vox_temperature()

		if(AALARM_PRESET_COLDROOM)
			tlv_config[TLV_H2] = new /datum/tlv/dangerous()
			tlv_config[TLV_PRESSURE] = new /datum/tlv/cold_room_pressure()
			tlv_config[TLV_TEMPERATURE] = new /datum/tlv/cold_room_temperature()

		if(AALARM_PRESET_SERVER)
			for(var/key in tlv_config)
				tlv_config[key] = new /datum/tlv/ignore()
			tlv_config[TLV_TEMPERATURE] = new /datum/tlv/server_temperature()

	TLV = tlv_config
	if(!no_cycle_after)
		mode = AALARM_MODE_CYCLE
		apply_mode()

/obj/machinery/alarm/Initialize(mapload, direction, building = FALSE)
	. = ..()
	GLOB.air_alarms += src
	GLOB.air_alarms = sortAtom(GLOB.air_alarms)

	wires = new(src)

	if(building)
		if(direction)
			setDir(direction)
		buildstage = AIR_ALARM_BUILD_NO_CIRCUIT
		wiresexposed = TRUE
		set_pixel_offsets_from_dir(23, -23, 23, -23)

	first_run()
	alarm_area.air_alarms += src
	init_tick = SSair.milla_tick
	set_frequency(frequency)
	if(is_taipan(z)) // Синдидоступ при сборке на тайпане
		req_access = list(ACCESS_SYNDICATE)
	update_icon()

/obj/machinery/alarm/Destroy()
	SStgui.close_uis(wires)
	GLOB.air_alarms -= src
	alarm_area?.air_alarms -= src
	if(SSradio)
		SSradio.remove_object(src, frequency)
	radio_connection = null
	GLOB.air_alarm_repository.update_cache(src)
	QDEL_NULL(wires)
	alarm_area = null
	return ..()

/obj/machinery/alarm/proc/first_run()
	alarm_area = get_area(src)
	if(name == initial(name))
		name = "[alarm_area.name] Air Alarm"
	apply_preset(1) // Don't cycle.
	GLOB.air_alarm_repository.update_cache(src)

/obj/machinery/alarm/process()
	if((stat & (NOPOWER|BROKEN)) || shorted || buildstage != AIR_ALARM_WIRED || init_tick == SSair.milla_tick)
		return

	var/turf/simulated/location = loc
	if(!istype(location))
		return 0

	if(thermostat_state)
		var/datum/milla_safe/airalarm_heat_cool/milla = new()
		milla.invoke_async(src)

	var/datum/gas_mixture/environment = location.get_readonly_air()
	var/list/gas_data = environment.get_interesting()
	var/GET_PP = R_IDEAL_GAS_EQUATION * environment.temperature() / environment.volume
	var/datum/tlv/cur_tlv

	cur_tlv = TLV[TLV_PRESSURE]
	var/environment_pressure = environment.return_pressure()
	var/environment_temperature = environment.temperature()
	var/pressure_dangerlevel = cur_tlv.get_danger_level(environment_pressure)
	if(environment_pressure < cur_tlv.min2 && mode == AALARM_MODE_FILTERING)
		mode = AALARM_MODE_OFF
		apply_mode()
		var/area/area = location.loc
		area.firealert(src)

	if(mode == AALARM_MODE_REFILL && environment_pressure >= cur_tlv.min1)
		mode = AALARM_MODE_FILTERING
		apply_mode()

	var/list/danger_levels = list()

	for(var/gas_key, moles in gas_data)
		var/partial_pressure = moles * GET_PP
		cur_tlv = TLV[gas_key]
		if(cur_tlv)
			danger_levels += cur_tlv.get_danger_level(partial_pressure)

	cur_tlv = TLV[TLV_TEMPERATURE]
	var/temperature_dangerlevel = cur_tlv.get_danger_level(environment_temperature)
	danger_levels += pressure_dangerlevel
	danger_levels += temperature_dangerlevel

	var/old_danger_level = danger_level
	danger_level = max(danger_levels)

	if(old_danger_level != danger_level)
		apply_danger_level()

	cur_tlv = TLV[TLV_PRESSURE]
	if(mode == AALARM_MODE_CYCLE && environment_pressure < cur_tlv.min2 * 0.05)
		mode = AALARM_MODE_REFILL
		apply_mode()

/datum/milla_safe/airalarm_heat_cool

/datum/milla_safe/airalarm_heat_cool/on_run(obj/machinery/alarm/alarm)
	var/turf/location = get_turf(alarm)
	var/datum/gas_mixture/environment = get_turf_air(location)

	var/datum/tlv/cur_tlv = alarm.TLV[TLV_TEMPERATURE]
	//Handle temperature adjustment here.
	if(environment.temperature() < alarm.target_temperature - 2 || environment.temperature() > alarm.target_temperature + 2 || alarm.regulating_temperature)
		//If it goes too far, we should adjust ourselves back before stopping.
		if(!cur_tlv.get_danger_level(alarm.target_temperature))
			var/datum/gas_mixture/gas = environment.remove(0.25 * environment.total_moles())
			if(!gas)
				return
			if(!alarm.regulating_temperature && alarm.thermostat_state)
				alarm.regulating_temperature = TRUE
				alarm.visible_message("\The [alarm] clicks as it starts [environment.temperature() > alarm.target_temperature ? "cooling" : "heating"] the room.", "You hear a click and a faint electronic hum.")

			if(alarm.target_temperature > MAX_TEMPERATURE)
				alarm.target_temperature = MAX_TEMPERATURE

			if(alarm.target_temperature < MIN_TEMPERATURE)
				alarm.target_temperature = MIN_TEMPERATURE

			var/heat_capacity = gas.heat_capacity()
			var/energy_used = max(abs(heat_capacity * (gas.temperature() - alarm.target_temperature) ), MAX_ENERGY_CHANGE)

			//Use power.  Assuming that each power unit represents 1000 watts....
			alarm.use_power(energy_used / 1000, ENVIRON)

			//We need to cool ourselves.
			if(heat_capacity)
				if(environment.temperature() > alarm.target_temperature)
					gas.set_temperature(gas.temperature() - energy_used / heat_capacity)
				else
					gas.set_temperature(gas.temperature() + energy_used / heat_capacity)

			if(abs(environment.temperature() - alarm.target_temperature) <= 0.5)
				alarm.regulating_temperature = FALSE
				alarm.visible_message("[alarm] clicks quietly as it stops [environment.temperature() > alarm.target_temperature ? "cooling" : "heating"] the room.", "You hear a click as a faint electronic humming stops.")

			environment.merge(gas)

/obj/machinery/alarm/update_icon_state()
	if(wiresexposed)
		switch(buildstage)
			if(AIR_ALARM_BUILD_NO_CIRCUIT)
				icon_state = "alarm_b1"
			if(AIR_ALARM_BUILD_CIRCUIT)
				icon_state = "alarm_b2"
			if(AIR_ALARM_WIRED)
				icon_state = "alarmx"
		return

	if((stat & (NOPOWER|BROKEN)) || shorted)
		icon_state = "alarmp"
		return

	if(!alarm_area) // We wont have our alarm_area if we aint initialised
		return

	switch(max(danger_level, alarm_area.atmosalm - 1))
		if(ATMOS_ALARM_NONE)
			icon_state = "alarm0"
		if(ATMOS_ALARM_WARNING)
			icon_state = "alarm2" //yes, alarm2 is yellow alarm
		if(ATMOS_ALARM_DANGER)
			icon_state = "alarm1"

/obj/machinery/alarm/update_overlays()
	. = ..()
	underlays.Cut()

	if(stat & NOPOWER || buildstage != AIR_ALARM_WIRED || wiresexposed || shorted)
		return

	underlays += emissive_appearance(icon, "alarm_lightmask", src)


/obj/machinery/alarm/set_frequency(new_frequency)
	SSradio.remove_object(src, frequency)
	frequency = new_frequency
	radio_connection = SSradio.add_object(src, frequency, RADIO_TO_AIRALARM)

/obj/machinery/alarm/proc/send_signal(target, list/command)//sends signal 'command' to 'target'. Returns 0 if no radio connection, 1 otherwise
	if(!radio_connection)
		return 0

	var/datum/signal/signal = new
	signal.transmission_method = 1 //radio signal
	signal.source = src

	signal.data = command
	signal.data["tag"] = target
	signal.data["sigtype"] = "command"

	radio_connection.post_signal(src, signal, RADIO_FROM_AIRALARM)
	return TRUE

// TODO refactor radio signals
/obj/machinery/alarm/proc/apply_mode()
	var/datum/tlv/pressure_tlv = TLV[TLV_PRESSURE]
	switch(mode)
		if(AALARM_MODE_FILTERING)
			for(var/obj/machinery/atmospherics/machine as anything in alarm_area.air_scrubs)
				machine.update_params(list(
					"power" = TRUE,
					"scrub" = SCRUB_CO2|((preset == AALARM_PRESET_VOX)? SCRUB_O2 : NONE),
					"scrubbing" = TRUE,
					"widenet" = FALSE,
				))

			for(var/obj/machinery/atmospherics/machine as anything in alarm_area.air_vents)
				machine.update_params(list(
					"power" = TRUE,
					"checks" = ONLY_CHECK_EXT_PRESSURE,
					"set_external_pressure" = (pressure_tlv.min1 + pressure_tlv.max1) / 2
				))

		if(AALARM_MODE_CONTAMINATED)
			for(var/obj/machinery/atmospherics/machine as anything in alarm_area.air_scrubs)
				machine.update_params(list(
					"power" = TRUE,
					"scrub" = SCRUB_ALL_GASES,
					"scrubbing" = TRUE,
					"widenet" = TRUE,
				))

			for(var/obj/machinery/atmospherics/machine as anything in alarm_area.air_vents)
				machine.update_params(list(
					"power" = TRUE,
					"checks" = ONLY_CHECK_EXT_PRESSURE,
					"set_external_pressure" = (pressure_tlv.min1 + pressure_tlv.max1) / 2
				))

		if(AALARM_MODE_DRAUGHT)
			for(var/obj/machinery/atmospherics/machine as anything in alarm_area.air_scrubs)
				machine.update_params( list(
					"power" = TRUE,
					"widenet" = FALSE,
					"scrubbing" = FALSE
				))

			for(var/obj/machinery/atmospherics/machine as anything in alarm_area.air_vents)
				machine.update_params(list(
					"power"= TRUE,
					"checks"= ONLY_CHECK_EXT_PRESSURE,
					"set_external_pressure" = pressure_tlv.max1
				))

		if(AALARM_MODE_REFILL)
			for(var/obj/machinery/atmospherics/machine as anything in alarm_area.air_scrubs)
				machine.update_params(list(
					"power" = TRUE,
					"scrub" = SCRUB_CO2,
					"scrubbing" = TRUE,
					"widenet" = FALSE,
				))

			for(var/obj/machinery/atmospherics/machine as anything in alarm_area.air_vents)
				machine.update_params(list(
					"power" = TRUE,
					"checks" = ONLY_CHECK_EXT_PRESSURE,
					"set_external_pressure" = (pressure_tlv.min1 + pressure_tlv.max1) / 2
				))

		if(AALARM_MODE_PANIC, AALARM_MODE_CYCLE)
			for(var/obj/machinery/atmospherics/machine as anything in alarm_area.air_scrubs)
				machine.update_params(list(
					"power" = TRUE,
					"widenet" = TRUE,
					"scrubbing" = FALSE
				))

			for(var/obj/machinery/atmospherics/machine as anything in alarm_area.air_vents)
				machine.update_params(list(
					"power" = FALSE
				))

		if(AALARM_MODE_SIPHON)
			for(var/obj/machinery/atmospherics/machine as anything in alarm_area.air_scrubs)
				machine.update_params(list(
					"power" = TRUE,
					"widenet" = FALSE,
					"scrubbing" = FALSE
				))

			for(var/obj/machinery/atmospherics/machine as anything in alarm_area.air_vents)
				machine.update_params(list(
					"power" = FALSE
				))

		if(AALARM_MODE_OFF)
			for(var/obj/machinery/atmospherics/machine as anything in alarm_area.air_scrubs)
				machine.update_params(list(
					"power" = TRUE
				))

			for(var/obj/machinery/atmospherics/machine as anything in alarm_area.air_vents)
				machine.update_params(list(
					"power" = FALSE
				))

		if(AALARM_MODE_FLOOD)
			for(var/obj/machinery/atmospherics/machine as anything in alarm_area.air_scrubs)
				machine.update_params(list(
					"power" = FALSE
				))

			for(var/obj/machinery/atmospherics/machine as anything in alarm_area.air_vents)
				machine.update_params(list(
					"power" = TRUE,
					"checks" = 0,
				))


/obj/machinery/alarm/proc/apply_danger_level()
	var/new_area_danger_level = ATMOS_ALARM_NONE
	for(var/obj/machinery/alarm/AA in alarm_area.machinery_cache)
		if(!(AA.stat & (NOPOWER|BROKEN)) && !AA.shorted)
			new_area_danger_level = max(new_area_danger_level, AA.danger_level)
	if(alarm_area.atmosalert(new_area_danger_level, src)) //if area was in normal state or if area was in alert state
		post_alert(new_area_danger_level)

	update_icon()

/obj/machinery/alarm/proc/post_alert(alert_level)
	if(!report_danger_level)
		return
	var/datum/radio_frequency/frequency = SSradio.return_frequency(alarm_frequency)

	if(!frequency)
		return

	var/datum/signal/alert_signal = new
	alert_signal.source = src
	alert_signal.transmission_method = 1
	alert_signal.data["zone"] = get_area_name(src, TRUE)
	alert_signal.data["type"] = "Atmospheric"

	if(alert_level == ATMOS_ALARM_DANGER)
		alert_signal.data["alert"] = "severe"
	else if(alert_level == ATMOS_ALARM_WARNING)
		alert_signal.data["alert"] = "minor"
	else if(alert_level == ATMOS_ALARM_NONE)
		alert_signal.data["alert"] = "clear"

	frequency.post_signal(src, alert_signal)

/obj/machinery/alarm/proc/post_mode(mode)
	if(!mode)
		return
	var/datum/radio_frequency/frequency = SSradio.return_frequency(alarm_frequency)

	if(!frequency)
		return

	var/datum/signal/mode_signal = new
	mode_signal.source = src
	mode_signal.transmission_method = 1
	mode_signal.data["zone"] = get_area_name(src, TRUE)
	mode_signal.data["mode"] = mode

	frequency.post_signal(src, mode_signal)

///////////////
//END HACKING//
///////////////

/obj/machinery/alarm/attack_ai(mob/user)
	if(buildstage != AIR_ALARM_WIRED)
		return

	add_hiddenprint(user)
	return ui_interact(user)

/obj/machinery/alarm/attack_ghost(mob/user)
	return interact(user)

/obj/machinery/alarm/attack_hand(mob/user)
	. = ..()
	if(.)
		return
	return interact(user)

/obj/machinery/alarm/interact(mob/user)
	if(buildstage != AIR_ALARM_WIRED)
		return

	if(wiresexposed)
		wires.Interact(user)

	if(!shorted)
		ui_interact(user)

/obj/machinery/alarm/proc/ui_air_status()
	var/turf/location = get_turf(src)
	if(!istype(location))
		return

	var/datum/gas_mixture/environment = location.get_readonly_air()
	var/list/gas_data = gas_mixture_parser_faster(environment)

	var/total = gas_data[TLV_TOTAL_MOLES] || 1
	var/GET_PP = R_IDEAL_GAS_EQUATION * gas_data[TLV_TEMPERATURE] / environment.return_volume()

	var/list/percentages = list()
	var/list/danger = list()
	var/list/danger_levels = list()

	var/environment_pressure = gas_data[TLV_PRESSURE]
	var/datum/tlv/pressure_tlv = TLV[TLV_PRESSURE]
	var/pressure_danger = pressure_tlv.get_danger_level(environment_pressure)
	danger_levels += pressure_danger

	for(var/gas_key in GLOB.gas_meta)
		var/moles = gas_data[gas_key] || 0
		var/percent = moles / total * 100
		var/partial_pressure = moles * GET_PP
		var/datum/tlv/cur_tlv = TLV[gas_key]
		var/danger_level = cur_tlv ? cur_tlv.get_danger_level(partial_pressure) : 0

		percentages[gas_key] = percent
		danger[gas_key] = danger_level
		danger_levels += danger_level

	var/datum/tlv/temp_tlv = TLV[TLV_TEMPERATURE]
	var/temperature = gas_data[TLV_TEMPERATURE]
	var/temperature_danger = temp_tlv.get_danger_level(temperature)
	danger_levels += temperature_danger
	danger[TLV_TEMPERATURE] = temperature_danger

	var/list/data = list()
	data[TLV_PRESSURE] = environment_pressure
	data[TLV_TEMPERATURE] = temperature

	danger["overall"] = max(danger_levels)

	data["temperature_c"] = round(temperature - T0C, 0.1)
	data["thermostat_state"] = thermostat_state
	data["contents"] = percentages
	data["danger"] = danger

	return data

/obj/machinery/alarm/proc/has_rcon_access(mob/user)
	return user && (isAI(user) || allowed(user) || emagged || rcon_setting == RCON_YES)

// Intentional nulls here
/obj/machinery/alarm/ui_data(mob/user)
	var/list/data = list()

	data["name"] = sanitize(name)
	data["air"] = ui_air_status()
	data["alarmActivated"] = alarmActivated || danger_level == ATMOS_ALARM_DANGER
	data["thresholds"] = generate_thresholds_menu()

	// Locked when:
	//   Not sent from atmos console AND
	//   Not silicon AND locked.
	var/datum/tgui/active_ui = SStgui.get_open_ui(user, src, "main")
	data["locked"] = !is_authenticated(user, active_ui)
	data["rcon"] = rcon_setting
	data["target_temp"] = target_temperature - T0C
	data["atmos_alarm"] = alarm_area.atmosalm
	data["emagged"] = emagged
	data["modes"] = list(
		"mode[AALARM_MODE_FILTERING]"		= list("name" = GLOB.aalarm_modes["[AALARM_MODE_FILTERING]"],	"desc" = "Scrubs out contaminants. Will shut off and drop firelocks if pressure drops too low.", "id" = AALARM_MODE_FILTERING),
		"mode[AALARM_MODE_DRAUGHT]"			= list("name" = GLOB.aalarm_modes["[AALARM_MODE_DRAUGHT]"],			"desc" = "Siphons out air while replacing", "id" = AALARM_MODE_DRAUGHT),
		"mode[AALARM_MODE_PANIC]"			= list("name" = GLOB.aalarm_modes["[AALARM_MODE_PANIC]"],				"desc" = "Siphons air out of the room quickly", "id" = AALARM_MODE_PANIC),
		"mode[AALARM_MODE_CYCLE]"			= list("name" = GLOB.aalarm_modes["[AALARM_MODE_CYCLE]"],				"desc" = "Siphons air before replacing", "id" = AALARM_MODE_CYCLE),
		"mode[AALARM_MODE_SIPHON]"			= list("name" = GLOB.aalarm_modes["[AALARM_MODE_SIPHON]"],			"desc" = "Siphons air out of the room", "id" = AALARM_MODE_SIPHON),
		"mode[AALARM_MODE_CONTAMINATED]"	= list("name" = GLOB.aalarm_modes["[AALARM_MODE_CONTAMINATED]"],		"desc" = "Scrubs out all contaminants quickly", "id" = AALARM_MODE_CONTAMINATED),
		"mode[AALARM_MODE_REFILL]"			= list("name" = GLOB.aalarm_modes["[AALARM_MODE_REFILL]"],			"desc" = "Refills a room to normal pressure, then switches to Filtering.", "id" = AALARM_MODE_REFILL),
		"mode[AALARM_MODE_CUSTOM]"			= list("name" = GLOB.aalarm_modes["[AALARM_MODE_CUSTOM]"],			"desc" = "Custom settings with no automatic mode switching.", "id" = AALARM_MODE_CUSTOM),
		"mode[AALARM_MODE_OFF]"				= list("name" = GLOB.aalarm_modes["[AALARM_MODE_OFF]"],				"desc" = "Shuts off vents and scrubbers", "id" = AALARM_MODE_OFF),
		"mode[AALARM_MODE_FLOOD]"			= list("name" = GLOB.aalarm_modes["[AALARM_MODE_FLOOD]"],				"desc" = "Shuts off scrubbers and opens vents", 	"emagonly" = TRUE, "id" = AALARM_MODE_FLOOD)
	)
	data["mode"] = mode
	data["presets"] = list(
		AALARM_PRESET_HUMAN		= list("name"="Human",    	 "desc"="Checks for oxygen and nitrogen", "id" = AALARM_PRESET_HUMAN),\
		AALARM_PRESET_VOX		= list("name"="Vox",      	 "desc"="Checks for nitrogen only", "id" = AALARM_PRESET_VOX),\
		AALARM_PRESET_COLDROOM	= list("name"="Coldroom",	 "desc"="For freezers", "id" = AALARM_PRESET_COLDROOM),\
		AALARM_PRESET_SERVER	= list("name"="Server Room", "desc"="For server rooms", "id" = AALARM_PRESET_SERVER)
	)
	data["preset"] = preset

	var/list/vents = list()
	for(var/obj/machinery/atmospherics/machine as anything in alarm_area.air_vents)
		vents += list(machine.get_data())

	data["vents"] = vents

	var/list/scrubbers = list()
	for(var/obj/machinery/atmospherics/machine as anything in alarm_area.air_scrubs)
		scrubbers += list(machine.get_data())
	data["scrubbers"] = scrubbers
	return data

/obj/machinery/alarm/proc/get_console_data(mob/user)
	var/list/data = list()
	data["name"] = readd_quote(sanitize(name))
	data["ref"] = UID()
	data["danger"] = max(danger_level, alarm_area.atmosalm)
	var/area/A = get_area(src)
	data["area"] = readd_quote(sanitize(A.name))
	var/turf/T = get_turf(src)
	data["x"] = T.x
	data["y"] = T.y
	data["z"] = T.z
	return data

/obj/machinery/alarm/proc/generate_thresholds_menu()
	var/datum/tlv/selected
	var/list/thresholds = list()

	for(var/gas_id, meta_list in GLOB.gas_meta)
		var/list/gas_info = meta_list
		thresholds += list(list("name" = gas_info[META_GAS_NAME], "settings" = list()))
		selected = TLV[gas_id]
		thresholds[length(thresholds)]["settings"] += list(list("env" = gas_id, "val" = "min2", "selected" = selected.min2))
		thresholds[length(thresholds)]["settings"] += list(list("env" = gas_id, "val" = "min1", "selected" = selected.min1))
		thresholds[length(thresholds)]["settings"] += list(list("env" = gas_id, "val" = "max1", "selected" = selected.max1))
		thresholds[length(thresholds)]["settings"] += list(list("env" = gas_id, "val" = "max2", "selected" = selected.max2))

	selected = TLV[TLV_PRESSURE]
	thresholds += list(list("name" = "Pressure", "settings" = list()))
	thresholds[length(thresholds)]["settings"] += list(list("env" = "pressure", "val" = "min2", "selected" = selected.min2))
	thresholds[length(thresholds)]["settings"] += list(list("env" = "pressure", "val" = "min1", "selected" = selected.min1))
	thresholds[length(thresholds)]["settings"] += list(list("env" = "pressure", "val" = "max1", "selected" = selected.max1))
	thresholds[length(thresholds)]["settings"] += list(list("env" = "pressure", "val" = "max2", "selected" = selected.max2))

	selected = TLV[TLV_TEMPERATURE]
	thresholds += list(list("name" = "Temperature", "settings" = list()))
	thresholds[length(thresholds)]["settings"] += list(list("env" = "temperature", "val" = "min2", "selected" = selected.min2))
	thresholds[length(thresholds)]["settings"] += list(list("env" = "temperature", "val" = "min1", "selected" = selected.min1))
	thresholds[length(thresholds)]["settings"] += list(list("env" = "temperature", "val" = "max1", "selected" = selected.max1))
	thresholds[length(thresholds)]["settings"] += list(list("env" = "temperature", "val" = "max2", "selected" = selected.max2))

	return thresholds

/obj/machinery/alarm/ui_interact(mob/user, datum/tgui/ui = null)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "AirAlarm", name)
		ui.open()

/obj/machinery/alarm/proc/is_authenticated(mob/user, datum/tgui/ui=null)
	// Return true if they are connecting with a remote console
	// lol this is a wank hack, please don't shoot me
	for(var/obj/machinery/computer/atmoscontrol/control in orange(1, user))
		return TRUE
	if(user.can_admin_interact())
		return TRUE
	else if(isAI(user) || (isrobot(user) || emagged || user.has_unlimited_silicon_privilege) && !iscogscarab(user))
		return TRUE
	else
		return !locked

/obj/machinery/alarm/ui_status(mob/user, datum/ui_state/state)
	if(buildstage != AIR_ALARM_WIRED)
		return UI_CLOSE

	if(aidisabled && (isAI(user) || isrobot(user)))
		to_chat(user, span_warning("AI control for \the [src] interface has been disabled."))
		return UI_CLOSE

	. = shorted ? UI_DISABLED : UI_INTERACTIVE

	return min(..(), .)

// TODO: Refactor these utter pieces of garbage
/obj/machinery/alarm/ui_act(action, list/params)
	if(..())
		return

	add_fingerprint(usr)

	. = TRUE

	// Used for rcon auth
	var/datum/tgui/active_ui = SStgui.get_open_ui(usr, src, "main")
	switch(action)
		if("set_rcon")
			var/attempted_rcon_setting = params["rcon"]
			switch(attempted_rcon_setting)
				if(RCON_NO)
					rcon_setting = RCON_NO
				if(RCON_AUTO)
					rcon_setting = RCON_AUTO
				if(RCON_YES)
					rcon_setting = RCON_YES
		if("command")
			if(!is_authenticated(usr, active_ui))
				return

			var/device_uid = params["uid"]
			var/command = params["cmd"]
			var/value = params["val"]
			mode = AALARM_MODE_CUSTOM
			var/obj/machinery/atmospherics/machine = locateUID(device_uid)

			if(machine && (machine.stat & (NOPOWER|BROKEN)))
				return

			var/list/result = list()
			if(value)
				result[command] = value
			else
				result += command

			machine.update_params(result)
			return TRUE

		if("set_threshold")
			var/env = params["env"]
			var/varname = params["var"]
			var/datum/tlv/tlv = TLV[env]
			var/newval = tgui_input_number(usr, "Enter [varname] for [env]", "Alarm triggers", tlv.vars[varname], round_value = FALSE)

			if(isnull(newval) || ..()) // No setting if you walked away
				return
			if(newval < 0)
				tlv.vars[varname] = -1.0
			else if(env == "temperature" && newval > 5000)
				tlv.vars[varname] = 5000
			else if(env == "pressure" && newval > 50 * ONE_ATMOSPHERE)
				tlv.vars[varname] = 50 * ONE_ATMOSPHERE
			else if(env != "temperature" && env != "pressure" && newval > 200)
				tlv.vars[varname] = 200
			else
				newval = round(newval, 0.01)
				tlv.vars[varname] = newval

		if("atmos_alarm")
			if(alarm_area.atmosalert(ATMOS_ALARM_DANGER, src))
				post_alert(ATMOS_ALARM_DANGER)
			alarmActivated = TRUE
			update_icon()

		if("atmos_reset")
			if(alarm_area.atmosalert(ATMOS_ALARM_NONE, src, TRUE))
				post_alert(ATMOS_ALARM_NONE)
			alarmActivated = FALSE
			update_icon()

		if("mode")
			if(!is_authenticated(usr, active_ui))
				return

			mode = params["mode"]
			apply_mode()

		if("preset")
			if(!is_authenticated(usr, active_ui))
				return

			preset = params["preset"]
			apply_preset()

		if("temperature")
			var/datum/tlv/selected = TLV[TLV_TEMPERATURE]
			var/max_temperature = selected.max1 >= 0 ? min(selected.max1, MAX_TEMPERATURE) : max(selected.max1, MAX_TEMPERATURE)
			var/min_temperature = max(selected.min1, MIN_TEMPERATURE)
			var/max_temperature_c = max_temperature - T0C
			var/min_temperature_c = min_temperature - T0C
			var/input_temperature = tgui_input_number(usr, "What temperature would you like the system to maintain? (Capped between [min_temperature_c]C and [max_temperature_c]C)", "Thermostat Controls", target_temperature - T0C, max_temperature_c, min_temperature_c)
			if(isnull(input_temperature) || ..()) // No temp setting if you walked away
				return
			input_temperature = input_temperature + T0C
			if(input_temperature > max_temperature || input_temperature < min_temperature)
				to_chat(usr, span_warning("Temperature must be between [min_temperature_c]C and [max_temperature_c]C"))
			else
				target_temperature = input_temperature

		if("thermostat_state")
			thermostat_state = !thermostat_state

/obj/machinery/alarm/ui_state(mob/user)
	if(issilicon(user))
		if(isAI(user))
			var/mob/living/silicon/ai/AI = user
			if(!AI.lacks_power() || AI.apc_override)
				return GLOB.always_state
		if(isrobot(user))
			return GLOB.always_state

	else if(ishuman(user))
		for(var/obj/machinery/computer/atmoscontrol/AC in range(1, user))
			if(!AC.stat)
				return GLOB.always_state

	return GLOB.default_state

/obj/machinery/alarm/emag_act(mob/user)
	if(!emagged)
		emagged = TRUE
		if(user)
			user.visible_message(span_warning("Sparks fly out of the [src]!"), span_notice("You emag the [src], disabling its safeties."))
		playsound(src.loc, 'sound/effects/sparks4.ogg', 50, TRUE)
		return

/obj/machinery/alarm/attackby(obj/item/I, mob/user, params)
	if(user.a_intent == INTENT_HARM)
		return ..()

	switch(buildstage)
		if(AIR_ALARM_WIRED)
			if(I.GetID() || is_pda(I)) // trying to unlock the interface
				togglelock(user)
				return ATTACK_CHAIN_PROCEED

		if(AIR_ALARM_BUILD_CIRCUIT)
			if(iscoil(I))
				add_fingerprint(user)
				var/obj/item/stack/cable_coil/coil = I
				if(!coil.use(5))
					to_chat(user, span_notice("Недостаточно проводов!"))
					return ATTACK_CHAIN_PROCEED
				to_chat(user, "Проводка установлена")
				playsound(get_turf(src), coil.usesound, 50, TRUE)
				buildstage = AIR_ALARM_WIRED
				wiresexposed = TRUE
				update_icon()
				first_run()
				return ATTACK_CHAIN_PROCEED_SUCCESS

		if(AIR_ALARM_BUILD_NO_CIRCUIT)
			if(istype(I, /obj/item/airalarm_electronics))
				add_fingerprint(user)
				if(!user.drop_transfer_item_to_loc(I, src))
					return ..()
				to_chat(user, span_notice("Плата установлена"))
				playsound(get_turf(src), I.usesound, 50, TRUE)
				qdel(I)
				buildstage = AIR_ALARM_BUILD_CIRCUIT
				update_icon(UPDATE_ICON_STATE)
				return ATTACK_CHAIN_BLOCKED_ALL

	return ..()

/obj/machinery/alarm/crowbar_act(mob/user, obj/item/I)
	if(buildstage != AIR_ALARM_BUILD_CIRCUIT)
		return
	. = TRUE
	if(!I.tool_start_check(src, user, 0))
		return
	CROWBAR_ATTEMPT_PRY_CIRCUIT_MESSAGE
	if(!I.use_tool(src, user, 20, volume = I.tool_volume))
		return
	if(buildstage != AIR_ALARM_BUILD_CIRCUIT)
		return
	CROWBAR_PRY_CIRCUIT_SUCCESS_MESSAGE
	new /obj/item/airalarm_electronics(user.drop_location())
	buildstage = AIR_ALARM_BUILD_NO_CIRCUIT
	update_icon(UPDATE_ICON_STATE)

/obj/machinery/alarm/multitool_act(mob/user, obj/item/I)
	if(buildstage != AIR_ALARM_WIRED)
		return
	. = TRUE
	if(!I.use_tool(src, user, 0, volume = I.tool_volume))
		return
	if(wiresexposed)
		attack_hand(user)

/obj/machinery/alarm/screwdriver_act(mob/user, obj/item/I)
	if(buildstage != AIR_ALARM_WIRED)
		return
	. = TRUE
	if(!I.use_tool(src, user, 0, volume = I.tool_volume))
		return
	wiresexposed = !wiresexposed
	update_icon()
	if(wiresexposed)
		SCREWDRIVER_OPEN_PANEL_MESSAGE
	else
		SCREWDRIVER_CLOSE_PANEL_MESSAGE

/obj/machinery/alarm/wirecutter_act(mob/user, obj/item/I)
	if(buildstage != AIR_ALARM_WIRED)
		return
	. = TRUE
	if(!I.use_tool(src, user, 0, volume = I.tool_volume))
		return
	if(wires.is_all_cut()) // all wires cut
		new /obj/item/stack/cable_coil(user.drop_location(), 5)
		buildstage = AIR_ALARM_BUILD_CIRCUIT
		update_icon(UPDATE_ICON_STATE)
	if(wiresexposed)
		wires.Interact(user)

/obj/machinery/alarm/wrench_act(mob/user, obj/item/item)
	if(buildstage != AIR_ALARM_BUILD_NO_CIRCUIT)
		return
	. = TRUE
	if(!item.use_tool(src, user, 0, volume = item.tool_volume))
		return
	new /obj/item/mounted/frame/alarm_frame(user.drop_location())
	WRENCH_UNANCHOR_WALL_MESSAGE
	qdel(src)

/obj/machinery/alarm/power_change(forced = FALSE)
	. = ..()
	if(.)
		update_icon()

/obj/machinery/alarm/obj_break(damage_flag)
	..()
	update_icon()

/obj/machinery/alarm/deconstruct(disassembled = TRUE)
	if(!(obj_flags & NODECONSTRUCT))
		new /obj/item/stack/sheet/metal(loc, 2)
		var/obj/item/I = new /obj/item/airalarm_electronics(loc)
		if(!disassembled)
			I.update_integrity(I.max_integrity * 0.5)
		new /obj/item/stack/cable_coil(loc, 3)
	qdel(src)

/obj/machinery/alarm/examine(mob/user)
	. = ..()
	switch(buildstage)
		if(AIR_ALARM_BUILD_NO_CIRCUIT)
			. += span_notice("Каркас <b>прикручен</b> к стене, но в нём отсутствует <i>электронная плата</i>.")
		if(AIR_ALARM_BUILD_CIRCUIT)
			. += span_notice("Систему контроля необходимо <i>подключить</i>, а плату можно <b>вытащить</b>.")
		if(AIR_ALARM_WIRED)
			if(wiresexposed)
				. += span_notice("Система контроля <b>подключёна</b>, а сервисная панель <i>открыта</i>.")

/obj/machinery/alarm/proc/togglelock(mob/living/user)
	add_fingerprint(user)
	if(stat & (NOPOWER|BROKEN))
		to_chat(user, span_warning("It does nothing!"))
		return
	if(allowed(user) && !wires.is_cut(WIRE_IDSCAN))
		locked = !locked
		to_chat(user, span_notice("You [ locked ? "lock" : "unlock"] the Air Alarm interface."))
		SStgui.update_uis(src)
		return
	to_chat(user, span_warning("Access denied."))

/obj/machinery/alarm/click_alt(mob/living/carbon/human/user)
	if(!istype(user))
		return NONE
	var/obj/item/card/id/card = user.get_id_card()
	if(!istype(card))
		return NONE
	togglelock(user)
	return CLICK_ACTION_SUCCESS

/obj/machinery/alarm/proc/unshort_callback()
	if(shorted)
		shorted = FALSE
		update_icon()

/obj/machinery/alarm/proc/enable_ai_control_callback()
	if(aidisabled)
		aidisabled = FALSE

/obj/machinery/alarm/all_access
	name = "all-access air alarm"
	desc = "This particular atmos control unit appears to have no access restrictions."
	locked = FALSE
	req_access = null

/obj/machinery/alarm/all_access/monitor
	report_danger_level = FALSE

/*
AIR ALARM CIRCUIT
Just an object used in constructing air alarms
*/
/obj/item/airalarm_electronics
	name = "air alarm electronics"
	icon = 'icons/obj/doors/door_assembly.dmi'
	icon_state = "door_electronics"
	desc = "Looks like a circuit. Probably is."
	w_class = WEIGHT_CLASS_SMALL
	materials = list(MAT_METAL=50, MAT_GLASS=50)
	origin_tech = "engineering=2;programming=1"
	usesound = 'sound/items/deconstruct.ogg'

//for oldstation

/obj/machinery/alarm/old
	name = "old air alarm"
	desc = "This atmos control unit is too old, that it no longer requires access."
	report_danger_level = FALSE
	remote_control = FALSE
	req_access = null

#undef AALARM_PRESET_HUMAN
#undef AALARM_PRESET_VOX
#undef AALARM_PRESET_COLDROOM
#undef AALARM_PRESET_SERVER
#undef AALARM_REPORT_TIMEOUT
#undef RCON_NO
#undef RCON_AUTO
#undef RCON_YES
#undef MAX_ENERGY_CHANGE
#undef MAX_TEMPERATURE
#undef MIN_TEMPERATURE
#undef AIR_ALARM_BUILD_NO_CIRCUIT
#undef AIR_ALARM_BUILD_CIRCUIT
#undef AIR_ALARM_WIRED

// MARK: Mapping Dir Helpers
MAPPING_DIRECTIONAL_HELPERS(/obj/machinery/alarm, 23, 23)
MAPPING_DIRECTIONAL_HELPERS(/obj/machinery/alarm/all_access, 23, 23)
MAPPING_DIRECTIONAL_HELPERS(/obj/machinery/alarm/all_access/monitor, 23, 23)
MAPPING_DIRECTIONAL_HELPERS(/obj/machinery/alarm/kitchen_cold_room, 23, 23)
MAPPING_DIRECTIONAL_HELPERS(/obj/machinery/alarm/monitor, 23, 23)
MAPPING_DIRECTIONAL_HELPERS(/obj/machinery/alarm/monitor/server, 23, 23)
MAPPING_DIRECTIONAL_HELPERS(/obj/machinery/alarm/old, 23, 23)
MAPPING_DIRECTIONAL_HELPERS(/obj/machinery/alarm/server, 23, 23)
MAPPING_DIRECTIONAL_HELPERS(/obj/machinery/alarm/syndicate, 23, 23)
MAPPING_DIRECTIONAL_HELPERS(/obj/machinery/alarm/syndicate/pirate, 23, 23)
MAPPING_DIRECTIONAL_HELPERS(/obj/machinery/alarm/vox, 23, 23)
