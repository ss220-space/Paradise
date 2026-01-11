GLOBAL_LIST_EMPTY(gas_meters)

/obj/machinery/atmospherics/meter
	name = "gas flow meter"
	desc = "A meter used by experienced atmospheric technicians to determine pressure and temperature in a pipe."
	icon = 'icons/obj/pipes_and_stuff/atmospherics/meter.dmi'
	icon_state = "meterX"
	can_unwrench = TRUE
	layer = GAS_PIPE_VISIBLE_LAYER + GAS_PUMP_OFFSET
	layer_offset = GAS_PUMP_OFFSET
	max_integrity = 150
	armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 100, BOMB = 0, BIO = 100, RAD = 100, FIRE = 40, ACID = 0)
	idle_power_usage = 2
	active_power_usage = 5
	var/obj/machinery/atmospherics/pipe/target = null

/obj/machinery/atmospherics/meter/Initialize(mapload)
	. = ..()
	GLOB.gas_meters += src
	target = locate(/obj/machinery/atmospherics/pipe) in loc
	AddComponent(/datum/component/usb_port, list(
		/obj/item/circuit_component/atmos_meter,
	))

/obj/machinery/atmospherics/meter/Destroy()
	target = null
	GLOB.gas_meters -= src
	return ..()

/obj/machinery/atmospherics/meter/process_atmos()
	update_icon(UPDATE_ICON_STATE)

/obj/machinery/atmospherics/meter/update_icon_state()
	if(!target)
		icon_state = "meterX"
		return

	if(stat & (BROKEN|NOPOWER))
		icon_state = "meter0"
		return

	var/datum/gas_mixture/environment = target.return_obj_air()
	if(!environment)
		icon_state = "meterX"
		return

	var/env_pressure = environment.return_pressure()
	if(env_pressure <= 0.15 * ONE_ATMOSPHERE)
		icon_state = "meter0"
	else if(env_pressure <= 1.8 * ONE_ATMOSPHERE)
		var/val = round(env_pressure / (ONE_ATMOSPHERE * 0.3) + 0.5)
		icon_state = "meter1_[val]"
	else if(env_pressure <= 30 * ONE_ATMOSPHERE)
		var/val = round(env_pressure / (ONE_ATMOSPHERE * 5) - 0.35) + 1
		icon_state = "meter2_[val]"
	else if(env_pressure <= 59 * ONE_ATMOSPHERE)
		var/val = round(env_pressure / (ONE_ATMOSPHERE * 5) - 6) + 1
		icon_state = "meter3_[val]"
	else
		icon_state = "meter4"

/obj/machinery/atmospherics/meter/examine(mob/user)
	. = ..()
	. += span_notice("Measures the volume and temperature of the pipe under the meter.")
	if(get_dist(user, src) > 3 && !(istype(user, /mob/living/silicon/ai) || istype(user, /mob/dead)))
		. += span_boldnotice("You are too far away to read it.")

	else if(stat & (NOPOWER|BROKEN))
		. += span_danger("The display is off.")

	else if(target)
		var/datum/gas_mixture/environment = target.return_obj_air()
		if(environment)
			. += span_notice("The pressure gauge reads [round(environment.return_pressure(), 0.01)] kPa; [round(environment.temperature(), 0.01)]K ([round(environment.temperature() - T0C, 0.01)]&deg;C).")
		else
			. += span_warning("The sensor error light is blinking.")
	else
		. += span_warning("The connect error light is blinking.")

/obj/machinery/atmospherics/meter/Click()
	if(isAI(usr)) // ghosts can call ..() for examine
		usr.examinate(src)
		return TRUE

	return ..()

/obj/machinery/atmospherics/meter/deconstruct(disassembled = TRUE)
	if(!(obj_flags & NODECONSTRUCT))
		new /obj/item/pipe_meter(loc)
	qdel(src)

/obj/machinery/atmospherics/meter/singularity_pull(S, current_size)
	..()
	if(current_size >= STAGE_FIVE)
		deconstruct()

/obj/item/circuit_component/atmos_meter
	display_name = "Атмосферный измеритель"
	desc = "Позволяет считывать давление и температуру в трубопроводе."

	///Signals the circuit to retrieve the pipenet's current pressure and temperature
	var/datum/port/input/request_data

	///Pressure of the pipenet
	var/datum/port/output/pressure
	///Temperature of the pipenet
	var/datum/port/output/temperature

	///The component parent object
	var/obj/machinery/atmospherics/meter/connected_meter

/obj/item/circuit_component/atmos_meter/populate_ports()
	request_data = add_input_port("Запрос данных счётчика", PORT_TYPE_SIGNAL, trigger = PROC_REF(request_meter_data))

	pressure = add_output_port("Давление", PORT_TYPE_NUMBER)
	temperature = add_output_port("Температура", PORT_TYPE_NUMBER)

/obj/item/circuit_component/atmos_meter/register_usb_parent(atom/movable/shell)
	. = ..()
	if(!istype(shell, /obj/machinery/atmospherics/meter))
		return

	connected_meter = shell

/obj/item/circuit_component/atmos_meter/unregister_usb_parent(atom/movable/shell)
	connected_meter = null
	return ..()

/obj/item/circuit_component/atmos_meter/proc/request_meter_data()
	CIRCUIT_TRIGGER
	if(!connected_meter)
		return

	var/datum/gas_mixture/environment = connected_meter.target.return_obj_air()
	pressure.set_output(environment.return_pressure())
	temperature.set_output(environment.temperature())
