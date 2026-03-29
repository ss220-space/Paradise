/obj/machinery/atmospherics/air_sensor
	icon_state = "gsensor1"
	name = "gas sensor"

	//multitool_menu_type = /datum/multitool_menu/idtag/freq/air_sensor
	frequency = ATMOS_TANKS_FREQ
	on = TRUE

	var/bolts = TRUE
	var/id_tag

	var/list/sensor_data = list()

	var/output = SENSOR_SCAN_PRESSURE|SENSOR_SCAN_TEMPERATURE

/obj/machinery/atmospherics/air_sensor/Initialize(mapload)
	. = ..()
	GLOB.gas_sensors += src
	SSair.atmos_machinery += src
	if(id_tag)
		register_id(id_tag, src, GLOB.sensors_by_tag)

/obj/machinery/atmospherics/air_sensor/Destroy()
	GLOB.gas_sensors -= src
	SSair.atmos_machinery -= src
	if(id_tag && weak_reference == GLOB.sensors_by_tag[id_tag])
		GLOB.sensors_by_tag -= id_tag
	return ..()

/obj/machinery/atmospherics/air_sensor/get_data()
	var/list/data = sensor_data.Copy()
	data["name"] = name
	return sensor_data

/obj/machinery/atmospherics/air_sensor/update_icon_state()
	icon_state = "gsensor[on]"

/obj/machinery/atmospherics/air_sensor/proc/toggle_out_flag(bitflag_value)
	if(!isnum(bitflag_value))
		return
	if(output & bitflag_value)
		output &= ~bitflag_value
	else
		output |= bitflag_value

/obj/machinery/atmospherics/air_sensor/proc/toggle_bolts()
	bolts = !bolts
	if(bolts)
		visible_message("You hear a quite click as the [src] bolts to the floor", "You hear a quite click")
	else
		visible_message("You hear a quite click as the [src]'s floor bolts raise", "You hear a quite click")
/*
/obj/machinery/atmospherics/air_sensor/multitool_act(mob/user, obj/item/I)
	. = TRUE
	multitool_menu_interact(user, I)
*/
/obj/machinery/atmospherics/air_sensor/wrench_act(mob/user, obj/item/I)
	. = TRUE
	if(bolts)
		to_chat(user, "[src] is bolted to the floor! You can't detach it like this.")
		return .
	to_chat(user, span_notice("You begin to unfasten [src]..."))
	if(!I.use_tool(src, user, 4 SECONDS, volume = I.tool_volume) || bolts)
		return .
	user.visible_message("[user] unfastens [src].", span_notice("You have unfastened [src]."), "You hear ratchet.")
	new /obj/item/pipe_gsensor(loc)
	qdel(src)

/obj/machinery/atmospherics/air_sensor/process_atmos()
	if(!on)
		return

	var/turf/location = get_turf(src)
	var/datum/gas_mixture/air_sample = location.get_readonly_air()
	var/list/gas_data = air_sample.get_interesting()

	if(output & SENSOR_SCAN_PRESSURE)
		sensor_data[TLV_PRESSURE] = round(air_sample.return_pressure(), 0.1)

	if(output & SENSOR_SCAN_TEMPERATURE)
		sensor_data[TLV_TEMPERATURE] = round(air_sample.temperature(), 0.1)

	if(output <= (SENSOR_SCAN_PRESSURE|SENSOR_SCAN_TEMPERATURE))
		return

	var/total_moles = air_sample.total_moles()
	sensor_data[TLV_TOTAL_MOLES] = total_moles

	if(total_moles <= 0)
		return

	var/list/gas_meta = GLOB.gas_meta

	for(var/gas_key, moles in gas_data)
		var/list/gas_meta_list = gas_meta[gas_key]
		if(output & gas_meta_list[META_GAS_SENSOR_FLAG])
			sensor_data[gas_key] = round(100 * moles / total_moles, 0.1)

/obj/machinery/atmospherics/air_sensor/o2
	output = parent_type::output|SENSOR_COMPOSITION_OXYGEN

/obj/machinery/atmospherics/air_sensor/n2
	output = parent_type::output|SENSOR_COMPOSITION_NITROGEN

/obj/machinery/atmospherics/air_sensor/pl
	output = parent_type::output|SENSOR_COMPOSITION_TOXINS

/obj/machinery/atmospherics/air_sensor/n2o
	output = parent_type::output|SENSOR_COMPOSITION_N2O

/obj/machinery/atmospherics/air_sensor/co2
	output = parent_type::output|SENSOR_COMPOSITION_CO2

/obj/machinery/atmospherics/air_sensor/all
	output = ALL


/obj/machinery/computer/general_air_control
	name = "Computer"
	icon_screen = "tank"
	icon_keyboard = "atmos_key"
	circuit = /obj/item/circuitboard/air_management
	req_access = list(ACCESS_ENGINE, ACCESS_ATMOSPHERICS)

	//multitool_menu_type = /datum/multitool_menu/idtag/freq/general_air_control

	var/show_sensors = TRUE
	var/list/sensors
	var/list/sensors_objects = list()

/obj/machinery/computer/general_air_control/Initialize(mapload)
	..()
	if(!sensors)
		sensors = list()
	initial_linkage()
	return INITIALIZE_HINT_LATELOAD

/obj/machinery/computer/general_air_control/LateInitialize()
	initial_linkage()
	. = ..()

/obj/machinery/computer/general_air_control/proc/initial_linkage()
	var/list/cached_sensors = GLOB.sensors_by_tag
	var/list/cached_sensors_objects = sensors_objects
	for(var/sensor_id in sensors)
		cached_sensors_objects[sensor_id] = cached_sensors[sensor_id]

/obj/machinery/computer/general_air_control/Destroy()
	LAZYCLEARLIST(sensors)
	return ..()

/obj/machinery/computer/general_air_control/attack_hand(mob/user)
	ui_interact(user)

/obj/machinery/computer/general_air_control/ui_state(mob/user)
	return GLOB.default_state

/obj/machinery/computer/general_air_control/ui_interact(mob/user, datum/tgui/ui = null)
	if(!isprocessing)
		START_PROCESSING(SSmachines, src)

	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		// We can use the same template here for sensors and for tanks with inlets/outlets with TGUI memes
		ui = new(user, src, "AtmosTankControl", name)
		ui.open()

/obj/machinery/computer/general_air_control/process()
	if(SStgui.update_uis(src))
		return

	return PROCESS_KILL

/obj/machinery/computer/general_air_control/ui_data(mob/user)
	var/list/data = ..()
	var/list/sensors = list()
	for(var/id, ref in sensors_objects)
		var/datum/weakref/object_ref = ref
		var/obj/machinery/atmospherics/air_sensor/sensor = object_ref.resolve()
		if(!sensor)
			continue
		var/list/sensor_data = sensor.get_data()
		sensor_data["name"] = src.sensors[id] || sensor_data["name"]
		sensors += list(sensor.get_data())
	data["sensors"] = sensors
	return data

/obj/machinery/computer/general_air_control/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	if(..())
		return


	if(action == "command")
		var/device_id = params["uid"]
		var/command = params["cmd"]
		var/value = params["val"]
		var/obj/machinery/atmospherics/machine = locateUID(device_id)
		if(machine && (machine.stat & (NOPOWER|BROKEN)))
			return
		var/list/result = list()
		if(value)
			result[command] = value
		else
			result += command
		machine.update_params(result)
		return TRUE

/*
/obj/machinery/computer/general_air_control/multitool_act(mob/user, obj/item/I)
	. = TRUE
	multitool_menu_interact(user, I)
*/

/obj/machinery/computer/general_air_control/large_tank_control
	circuit = /obj/item/circuitboard/large_tank_control
	req_access = list(ACCESS_ENGINE, ACCESS_ATMOSPHERICS)
	//multitool_menu_type = /datum/multitool_menu/idtag/freq/general_air_control/large_tank_control

	var/input_tag
	var/output_tag

	var/datum/weakref/input_ref

	var/datum/weakref/output_ref


	var/static/list/input_linkable = list(
		/obj/machinery/atmospherics/unary/outlet_injector,
		/obj/machinery/atmospherics/unary/vent_pump,
	)
	var/static/list/output_linkable = list(
		/obj/machinery/atmospherics/unary/vent_pump,
	)

	var/pressure_setting = ONE_ATMOSPHERE * 45

/obj/machinery/computer/general_air_control/large_tank_control/initial_linkage()
	. = ..()
	input_ref = GLOB.injectors_by_tag[input_tag]
	if(!input_ref)
		input_ref = GLOB.pumps_by_tag[input_tag]
	output_ref = GLOB.pumps_by_tag[output_tag]

/*
/obj/machinery/computer/general_air_control/large_tank_control/multitool_act(mob/user, obj/item/I)
	. = TRUE
	multitool_menu_interact(user, I)
*/

/obj/machinery/computer/general_air_control/large_tank_control/proc/can_link_to_input(obj/device_to_link)
	if(is_type_in_list(device_to_link, input_linkable))
		return TRUE
	return FALSE

/obj/machinery/computer/general_air_control/large_tank_control/proc/can_link_to_output(obj/device_to_link)
	if(is_type_in_list(device_to_link, output_linkable))
		return TRUE
	return FALSE

/obj/machinery/computer/general_air_control/large_tank_control/proc/link_input(obj/device_to_link)
	if(istype(device_to_link, /obj/machinery/atmospherics/unary/vent_pump))
		var/obj/machinery/atmospherics/unary/vent_pump/input_vent_pump = device_to_link
		input_ref = WEAKREF(input_vent_pump)
		input_vent_pump.update_params(list(
			"direction" = TRUE,
			"checks" = 0,
		))
		return TRUE
	else if(istype(device_to_link, /obj/machinery/atmospherics/unary/outlet_injector))
		var/obj/machinery/atmospherics/unary/vent_pump/input_outlet_injector = device_to_link
		input_ref = WEAKREF(input_outlet_injector)
		return TRUE

	return FALSE

/obj/machinery/computer/general_air_control/large_tank_control/proc/link_output(obj/device_to_link)
	if(istype(device_to_link, /obj/machinery/atmospherics/unary/vent_pump))
		var/obj/machinery/atmospherics/unary/vent_pump/output_vent_pump = device_to_link
		output_ref = WEAKREF(output_vent_pump)
		output_vent_pump.update_params(list(
			"direction" = FALSE,
			"checks" = ONLY_CHECK_INT_PRESSURE
		))
		return TRUE
	return FALSE

/obj/machinery/computer/general_air_control/large_tank_control/proc/unlink_input()
	input_ref = null

/obj/machinery/computer/general_air_control/large_tank_control/proc/unlink_output()
	output_ref = null

/obj/machinery/computer/general_air_control/large_tank_control/ui_data(mob/user)
	var/list/data = ..()
	var/list/inlets = list()
	var/list/outlets = list()

	var/obj/machinery/atmospherics/inlet = input_ref?.resolve()
	if(inlet)
		inlets += list(inlet.get_data())

	var/obj/machinery/atmospherics/outlet = output_ref?.resolve()
	if(outlet)
		outlets += list(outlet.get_data())

	data["inlets"] = inlets
	data["outlets"] = outlets
	return data

/obj/machinery/computer/general_air_control/fuel_injection
	icon_screen = "atmos"
	circuit = /obj/item/circuitboard/injector_control

	var/device_tag
	var/datum/weakref/device_ref

/obj/machinery/computer/general_air_control/fuel_injection/initial_linkage()
	device_ref = GLOB.injectors_by_tag[device_tag]

/obj/machinery/computer/general_air_control/fuel_injection/ui_data(mob/user)
	var/list/data = ..()
	var/list/inlets = list()

	var/obj/machinery/atmospherics/inlet = device_ref?.resolve()
	if(inlet)
		inlets += list(inlet.get_data())

	data["inlets"] = inlets
	return data
