/obj/machinery/atmospherics/components/binary/valve
	icon = 'icons/atmospherics/valve.dmi'
	icon_state = "mvalve_map"

	name = "manual valve"
	desc = "A pipe valve."

	can_unwrench = TRUE

	var/open = FALSE
	var/animating = FALSE
	var/valve_type = "m" //lets us have a nice, clean, OOP update_icon_nopipes()


/obj/machinery/atmospherics/components/binary/valve/examine(mob/user)
	. = ..()
	. += "It is currently [open ? "open" : "closed"]."

/obj/machinery/atmospherics/components/binary/valve/open
	open = TRUE
	icon_state = "mvalve_map_on"

/obj/machinery/atmospherics/components/binary/valve/update_icon_state()
	..()
	if(animating)
		flick("[valve_type]valve[open][!open]",src)
	icon_state = "[valve_type]valve[open]"

/obj/machinery/atmospherics/components/binary/valve/proc/normalize_dir()
	if(dir==SOUTH)
		dir = NORTH
	else if(dir==WEST)
		dir = EAST

/obj/machinery/atmospherics/components/binary/valve/update_underlays()
	if(..())
		underlays.Cut()
		var/turf/T = get_turf(src)
		if(!istype(T))
			return
		var/obj/machinery/atmospherics/node1 = NODE1
		var/obj/machinery/atmospherics/node2 = NODE2
		add_underlay(T, node1, get_dir(src, node1))
		add_underlay(T, node2, get_dir(src, node2))

/obj/machinery/atmospherics/components/binary/valve/proc/open()
	open = TRUE
	update_icon(UPDATE_ICON_STATE)
	update_parents()
	var/datum/pipeline/parent1 = PARENT1
	parent1.reconcile_air()
	vent_movement |= VENTCRAWL_ALLOWED
	investigate_log("was opened by [usr ? key_name_log(usr) : "a remote signal"]", INVESTIGATE_ATMOS)
	return

/obj/machinery/atmospherics/components/binary/valve/proc/close()
	open =  FALSE
	update_icon(UPDATE_ICON_STATE)
	vent_movement &= ~VENTCRAWL_ALLOWED
	investigate_log("was closed by [usr ? key_name_log(usr) : "a remote signal"]", INVESTIGATE_ATMOS)
	return

/obj/machinery/atmospherics/components/binary/valve/attack_ai(mob/user)
	return

/obj/machinery/atmospherics/components/binary/valve/attack_ghost(mob/user)
	if(user.can_advanced_admin_interact())
		return attack_hand(user)

/obj/machinery/atmospherics/components/binary/valve/attack_hand(mob/user)
	add_fingerprint(usr)
	animating = TRUE
	update_icon(UPDATE_ICON_STATE)
	sleep(10)
	animating = FALSE
	to_chat(user, span_notice("You [!open ? "open" : "close"] [src]."))
	if(open)
		close()
		return
	open()

/obj/machinery/atmospherics/components/binary/valve/digital		// can be controlled by AI
	name = "digital valve"
	desc = "A digitally controlled valve."
	icon_state = "dvalve_map_off"

	req_access = list(ACCESS_ATMOSPHERICS, ACCESS_ENGINE)

	frequency = ATMOS_VENTSCRUB
	var/id_tag = null
	valve_type = "d"

/obj/machinery/atmospherics/components/binary/valve/digital/update_icon_state()
	if(!powered())
		normalize_dir()
		icon_state = "dvalve_nopower"
		return
	. = ..()

/obj/machinery/atmospherics/components/binary/valve/digital/attack_ai(mob/user)
	return attack_hand(user)

/obj/machinery/atmospherics/components/binary/valve/digital/attack_hand(mob/user)
	if(!powered())
		return
	if(!allowed(user) && !user.can_advanced_admin_interact())
		to_chat(user, span_alert("Access denied."))
		return
	..()

/obj/machinery/atmospherics/components/binary/valve/digital/open
	open = TRUE
	icon_state = "dvalve_map_on"

/obj/machinery/atmospherics/components/binary/valve/digital/power_change(forced = FALSE)
	if(!..())
		return
	update_icon(UPDATE_ICON_STATE)

/obj/machinery/atmospherics/components/binary/valve/digital/atmos_init()
	..()
	if(frequency)
		set_frequency(frequency)

/obj/machinery/atmospherics/components/binary/valve/digital/receive_signal(datum/signal/signal)
	if(!signal.data["tag"] || (signal.data["tag"] != id_tag))
		return FALSE

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
