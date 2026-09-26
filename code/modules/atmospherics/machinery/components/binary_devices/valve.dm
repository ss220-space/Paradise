/obj/machinery/atmospherics/binary/valve
	icon = 'icons/obj/pipes_and_stuff/atmospherics/atmos/valve.dmi'
	icon_state = "map_valve0"

	name = "manual valve"
	desc = "A pipe valve."

	can_unwrench = TRUE

	var/open = FALSE
	var/animating = FALSE

/obj/machinery/atmospherics/binary/valve/examine(mob/user)
	. = ..()
	. += "It is currently [open ? "open" : "closed"]."
	. += span_notice("Click this to turn the valve. If perpendicular, the pipes on each end are separated. If parallel, they are connected.")

/obj/machinery/atmospherics/binary/valve/open
	open = 1
	icon_state = "map_valve1"

/obj/machinery/atmospherics/binary/valve/update_icon_state()
	..()
	if(animating)
		flick("valve[open][!open]",src)
	else
		icon_state = "valve[open]"

/obj/machinery/atmospherics/binary/valve/update_underlays()
	if(..())
		underlays.Cut()
		var/turf/T = get_turf(src)
		if(!istype(T))
			return
		add_underlay(T, node1, get_dir(src, node1))
		add_underlay(T, node2, get_dir(src, node2))

/obj/machinery/atmospherics/binary/valve/proc/open()
	open = TRUE
	update_icon(UPDATE_ICON_STATE)
	parent1.update = 0
	parent2.update = 0
	parent1.reconcile_air()
	vent_movement |= VENTCRAWL_ALLOWED
	investigate_log("was opened by [usr ? key_name_log(usr) : "a remote signal"]", INVESTIGATE_ATMOS)
	return

/obj/machinery/atmospherics/binary/valve/proc/close()
	open =  FALSE
	update_icon(UPDATE_ICON_STATE)
	vent_movement &= ~VENTCRAWL_ALLOWED
	investigate_log("was closed by [usr ? key_name_log(usr) : "a remote signal"]", INVESTIGATE_ATMOS)
	return

/obj/machinery/atmospherics/binary/valve/attack_ai(mob/user)
	return

/obj/machinery/atmospherics/binary/valve/attack_ghost(mob/user)
	if(user.can_advanced_admin_interact())
		return attack_hand(user)

/obj/machinery/atmospherics/binary/valve/attack_hand(mob/user)
	add_fingerprint(usr)
	animating = TRUE
	update_icon(UPDATE_ICON_STATE)
	sleep(10)
	animating = FALSE
	if(open)
		close()
	else
		open()
	to_chat(user, span_notice("You [open ? "open" : "close"] [src]."))

/obj/machinery/atmospherics/binary/valve/digital		// can be controlled by AI
	name = "digital valve"
	desc = "A digitally controlled valve."
	icon = 'icons/obj/pipes_and_stuff/atmospherics/atmos/digital_valve.dmi'

	req_access = list(ACCESS_ATMOSPHERICS,ACCESS_ENGINE)

	frequency = ATMOS_VENTSCRUB
	var/id_tag = null

/obj/machinery/atmospherics/binary/valve/digital/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/usb_port, list(
		/obj/item/circuit_component/digital_valve
	))

/obj/machinery/atmospherics/binary/valve/digital/Destroy()
	if(SSradio)
		SSradio.remove_object(src, frequency)
	radio_connection = null
	return ..()

/obj/machinery/atmospherics/binary/valve/digital/attack_ai(mob/user)
	return attack_hand(user)

/obj/machinery/atmospherics/binary/valve/digital/attack_hand(mob/user)
	if(!powered())
		return
	if(!allowed(user) && !user.can_advanced_admin_interact())
		to_chat(user, span_alert("Access denied."))
		return
	..()

/obj/machinery/atmospherics/binary/valve/digital/open
	open = 1
	icon_state = "map_valve1"

/obj/machinery/atmospherics/binary/valve/digital/power_change(forced = FALSE)
	if(!..())
		return
	update_icon(UPDATE_ICON_STATE)

/obj/machinery/atmospherics/binary/valve/digital/update_icon_state()
	if(!powered())
		icon_state = "valve[open]nopower"
		return
	..()

/obj/machinery/atmospherics/binary/valve/digital/atmos_init()
	..()
	if(frequency)
		set_frequency(frequency)

/obj/machinery/atmospherics/binary/valve/digital/receive_signal(datum/signal/signal)
	if(!signal.data["tag"] || (signal.data["tag"] != id_tag))
		return 0

	switch(signal.data["command"])
		if("valve_open")
			if(!open)
				open()

		if("valve_close")
			if(open)
				close()

		if("valve_toggle")
			if(open)
				close()
			else
				open()
		if("valve_set")
			if(signal.data["valve_set"] == 1)
				if(!open)
					open()
			else
				if(open)
					close()

/obj/item/circuit_component/digital_valve
	display_name = "Цифровой клапан"
	desc = "Интерфейс для связи с цифровым клапаном."

	var/obj/machinery/atmospherics/binary/valve/digital/attached_valve

	/// Opens the digital valve
	var/datum/port/input/open
	/// Closes the digital valve
	var/datum/port/input/close

	/// Whether the valve is currently open
	var/datum/port/output/is_open
	/// Sent when the valve is opened
	var/datum/port/output/opened
	/// Sent when the valve is closed
	var/datum/port/output/closed

/obj/item/circuit_component/digital_valve/Destroy()
	if(attached_valve)
		unregister_usb_parent(attached_valve)
	open = null
	close = null
	is_open = null
	opened = null
	closed = null
	. = ..()

/obj/item/circuit_component/digital_valve/populate_ports()
	open = add_input_port("Открыть", PORT_TYPE_SIGNAL)
	close = add_input_port("Закрыть", PORT_TYPE_SIGNAL)

	is_open = add_output_port("Открыто", PORT_TYPE_NUMBER)
	opened = add_output_port("Открыт", PORT_TYPE_SIGNAL)
	closed = add_output_port("Закрыт", PORT_TYPE_SIGNAL)

/obj/item/circuit_component/digital_valve/register_usb_parent(atom/movable/shell)
	. = ..()
	if(!istype(shell, /obj/machinery/atmospherics/binary/valve/digital))
		return

	attached_valve = shell
	RegisterSignal(attached_valve, COMSIG_VALVE_SET_OPEN, PROC_REF(handle_valve_toggled))

/obj/item/circuit_component/digital_valve/unregister_usb_parent(atom/movable/shell)
	UnregisterSignal(attached_valve, COMSIG_VALVE_SET_OPEN)
	attached_valve = null
	return ..()

/obj/item/circuit_component/digital_valve/proc/handle_valve_toggled(datum/source, on)
	SIGNAL_HANDLER
	is_open.set_output(on)
	if(on)
		opened.set_output(COMPONENT_SIGNAL)
		return

	closed.set_output(COMPONENT_SIGNAL)

/obj/item/circuit_component/digital_valve/input_received(datum/port/input/port)
	if(!attached_valve)
		return

	if(COMPONENT_TRIGGERED_BY(open, port) && !attached_valve.on)
		attached_valve.toggle()

	if(COMPONENT_TRIGGERED_BY(close, port) && attached_valve.on)
		attached_valve.toggle()

