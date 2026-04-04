/*
Every cycle, the pump uses the air in air_in to try and make air_out the perfect pressure.

node1, air1, network1 correspond to input
node2, air2, network2 correspond to output

Thus, the two variables affect pump operation are set in New():
	air1.volume
		This is the volume of gas available to the pump that may be transfered to the output
	air2.volume
		Higher quantities of this cause more air to be perfected later
			but overall network volume is also increased as this increases...
*/

/obj/machinery/atmospherics/binary/volume_pump
	icon = 'icons/obj/pipes_and_stuff/atmospherics/atmos/volume_pump.dmi'
	icon_state = "map_off"

	name = "volumetric gas pump"
	desc = "A volumetric pump"

	can_unwrench = TRUE
	interaction_flags_click = NEED_HANDS | ALLOW_RESTING | ALLOW_SILICON_REACH

	var/transfer_rate = 200

/obj/machinery/atmospherics/binary/volume_pump/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/usb_port, list(
		/obj/item/circuit_component/atmos_volume_pump,
	))

/obj/machinery/atmospherics/binary/volume_pump/CtrlClick(mob/living/user)
	if(!ishuman(user) && !issilicon(user))
		return
	if(user.incapacitated() || HAS_TRAIT(user, TRAIT_HANDS_BLOCKED))
		to_chat(user, span_warning("You can't do that right now!"))
		return
	if(!in_range(src, user) && !issilicon(user))
		return
	toggle()

/obj/machinery/atmospherics/binary/volume_pump/AICtrlClick()
	toggle()
	return ..()

/obj/machinery/atmospherics/binary/volume_pump/click_alt(mob/living/user)
	set_max()
	return CLICK_ACTION_SUCCESS

/obj/machinery/atmospherics/binary/volume_pump/ai_click_alt()
	set_max()
	return ..()

/obj/machinery/atmospherics/binary/volume_pump/proc/set_max()
	if(powered())
		transfer_rate = MAX_TRANSFER_RATE
		update_icon()

/obj/machinery/atmospherics/binary/volume_pump/on
	on = TRUE
	icon_state = "map_on"

/obj/machinery/atmospherics/binary/volume_pump/update_icon_state()
	..()

	if(!powered())
		icon_state = "off"
	else
		icon_state = "[on ? "on" : "off"]"

/obj/machinery/atmospherics/binary/volume_pump/update_underlays()
	if(..())
		underlays.Cut()
		var/turf/T = get_turf(src)
		if(!istype(T))
			return
		add_underlay(T, node1, turn(dir, -180))
		add_underlay(T, node2, dir)

/obj/machinery/atmospherics/binary/volume_pump/process_atmos(seconds)
	if((stat & (NOPOWER|BROKEN)) || !on)
		return FALSE

	// Pump mechanism just won't do anything if the pressure is too high/too low
	var/input_starting_pressure = air1.return_pressure()
	var/output_starting_pressure = air2.return_pressure()

	if((input_starting_pressure < 0.01) || (output_starting_pressure > 9000))
		return TRUE

	var/transfer_ratio = max(1, transfer_rate/air1.volume)

	var/datum/gas_mixture/removed = air1.remove_ratio(transfer_ratio)

	air2.merge(removed)

	parent1.update = TRUE
	parent2.update = TRUE

	return FALSE

/obj/machinery/atmospherics/binary/volume_pump/get_data()
	var/list/data = list(
		"name" = name,
		"machine_type" = "APV",
		"uid" = UID(),
		"power" = on,
		"transfer_rate" = transfer_rate,
	)
	return data

/obj/machinery/atmospherics/binary/volume_pump/update_params(list/params)
	var/old_on = on //for logging

	if("power" in params)
		on = params["power"]

	if("power_toggle" in params)
		on = !on

	if("set_transfer_rate" in params)
		transfer_rate = clamp(
			params["set_transfer_rate"],
			0,
			air1.volume
		)

	if(on != old_on)
		investigate_log("was turned [on ? "on" : "off"] by a remote signal", INVESTIGATE_ATMOS)

	update_appearance(UPDATE_ICON)

/obj/machinery/atmospherics/binary/volume_pump/attack_hand(mob/user)
	if(..())
		return

	if(!allowed(user))
		to_chat(user, span_alert("Access denied."))
		return

	add_fingerprint(user)
	ui_interact(user)

/obj/machinery/atmospherics/binary/volume_pump/attack_ghost(mob/user)
	ui_interact(user)

/obj/machinery/atmospherics/binary/volume_pump/ui_interact(mob/user, datum/tgui/ui = null)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "AtmosPump", name)
		ui.open()

/obj/machinery/atmospherics/binary/volume_pump/ui_data(mob/user)
	var/list/data = list(
		"on" = on,
		"rate" = round(transfer_rate),
		"max_rate" = round(MAX_TRANSFER_RATE),
		"gas_unit" = "L/s",
		"step" = 1 // This is for the TGUI <NumberInput> step. It's here since multiple pumps share the same UI, but need different values.
	)
	return data

/obj/machinery/atmospherics/binary/volume_pump/ui_act(action, list/params)
	if(..())
		return

	switch(action)
		if("power")
			toggle()
			investigate_log("was turned [on ? "on" : "off"] by [key_name_log(usr)]", INVESTIGATE_ATMOS)
			return TRUE

		if("max_rate")
			transfer_rate = MAX_TRANSFER_RATE
			. = TRUE

		if("min_rate")
			transfer_rate = 0
			. = TRUE

		if("custom_rate")
			transfer_rate = clamp(text2num(params["rate"]), 0 , MAX_TRANSFER_RATE)
			. = TRUE
	if(.)
		investigate_log("was set to [transfer_rate] L/s by [key_name_log(usr)]", INVESTIGATE_ATMOS)

/obj/machinery/atmospherics/binary/volume_pump/power_change(forced = FALSE)
	if(!..())
		return
	update_icon()

/obj/machinery/atmospherics/binary/volume_pump/attackby(obj/item/I, mob/user, params)
	. = ..()

	if(ATTACK_CHAIN_CANCEL_CHECK(.))
		return .

	. |= ATTACK_CHAIN_SUCCESS
	rename_interactive(user, I)

/obj/item/circuit_component/atmos_volume_pump
	display_name = "Объёмный атмосферный насос"
	desc = "Интерфейс для связи с объемным насосом."

	///Set the transfer rate of the pump
	var/datum/port/input/transfer_rate
	///Activate the pump
	var/datum/port/input/on
	///Deactivate the pump
	var/datum/port/input/off
	///Signals the circuit to retrieve the pump's current pressure and temperature
	var/datum/port/input/request_data

	///Pressure of the input port
	var/datum/port/output/input_pressure
	///Pressure of the output port
	var/datum/port/output/output_pressure
	///Temperature of the input port
	var/datum/port/output/input_temperature
	///Temperature of the output port
	var/datum/port/output/output_temperature

	///Whether the pump is currently active
	var/datum/port/output/is_active
	///Send a signal when the pump is turned on
	var/datum/port/output/turned_on
	///Send a signal when the pump is turned off
	var/datum/port/output/turned_off

	///The component parent object
	var/obj/machinery/atmospherics/binary/volume_pump/connected_pump

/obj/item/circuit_component/atmos_volume_pump/Destroy()
	if(connected_pump)
		unregister_usb_parent(connected_pump)
	transfer_rate = null
	on = null
	off = null
	request_data = null
	input_pressure = null
	output_pressure = null
	input_temperature = null
	output_temperature = null
	is_active = null
	turned_on = null
	turned_off = null
	. = ..()

/obj/item/circuit_component/atmos_volume_pump/populate_ports()
	transfer_rate = add_input_port("Новая скорость передачи", PORT_TYPE_NUMBER, trigger = PROC_REF(set_transfer_rate))
	on = add_input_port("Включить", PORT_TYPE_SIGNAL, trigger = PROC_REF(set_pump_on))
	off = add_input_port("Выключить", PORT_TYPE_SIGNAL, trigger = PROC_REF(set_pump_off))
	request_data = add_input_port("Запрос данных порта", PORT_TYPE_SIGNAL, trigger = PROC_REF(request_pump_data))

	input_pressure = add_output_port("Входное давление", PORT_TYPE_NUMBER)
	output_pressure = add_output_port("Выходное давление", PORT_TYPE_NUMBER)
	input_temperature = add_output_port("Входная температура", PORT_TYPE_NUMBER)
	output_temperature = add_output_port("Выходная температура", PORT_TYPE_NUMBER)

	is_active = add_output_port("Активный", PORT_TYPE_NUMBER)
	turned_on = add_output_port("Включено", PORT_TYPE_SIGNAL)
	turned_off = add_output_port("Выключено", PORT_TYPE_SIGNAL)

/obj/item/circuit_component/atmos_volume_pump/register_usb_parent(atom/movable/shell)
	. = ..()
	if(!istype(shell, /obj/machinery/atmospherics/binary/volume_pump))
		return

	connected_pump = shell
	RegisterSignal(connected_pump, COMSIG_ATMOS_MACHINE_SET_ON, PROC_REF(handle_pump_activation))

/obj/item/circuit_component/atmos_volume_pump/unregister_usb_parent(atom/movable/shell)
	UnregisterSignal(connected_pump, COMSIG_ATMOS_MACHINE_SET_ON)
	connected_pump = null
	return ..()

/obj/item/circuit_component/atmos_volume_pump/pre_input_received(datum/port/input/port)
	transfer_rate.set_value(clamp(transfer_rate.value, 0, MAX_TRANSFER_RATE))

/obj/item/circuit_component/atmos_volume_pump/proc/handle_pump_activation(datum/source, active)
	SIGNAL_HANDLER
	is_active.set_output(active)
	if(active)
		turned_on.set_output(COMPONENT_SIGNAL)
		return

	turned_off.set_output(COMPONENT_SIGNAL)

/obj/item/circuit_component/atmos_volume_pump/proc/set_transfer_rate()
	CIRCUIT_TRIGGER
	if(!connected_pump)
		return

	connected_pump.transfer_rate = transfer_rate.value

/obj/item/circuit_component/atmos_volume_pump/proc/set_pump_on()
	CIRCUIT_TRIGGER
	if(!connected_pump || connected_pump.on)
		return

	connected_pump.toggle()
	connected_pump.update_appearance()

/obj/item/circuit_component/atmos_volume_pump/proc/set_pump_off()
	CIRCUIT_TRIGGER
	if(!connected_pump || !connected_pump.on)
		return

	connected_pump.toggle()
	connected_pump.update_appearance()

/obj/item/circuit_component/atmos_volume_pump/proc/request_pump_data()
	CIRCUIT_TRIGGER
	if(!connected_pump)
		return

	var/datum/gas_mixture/air_input = connected_pump.air1
	var/datum/gas_mixture/air_output = connected_pump.air2
	input_pressure.set_output(air_input.return_pressure())
	output_pressure.set_output(air_output.return_pressure())
	input_temperature.set_output(air_input.temperature())
	output_temperature.set_output(air_output.temperature())

