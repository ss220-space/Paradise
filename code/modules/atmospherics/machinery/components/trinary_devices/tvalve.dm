#define TVALVE_STATE_STRAIGHT 0
#define TVALVE_STATE_SIDE 1

/obj/machinery/atmospherics/components/trinary/tvalve
	icon_state = "map_tvalve0"

	name = "manual switching valve"
	desc = "A pipe valve."

	can_unwrench = TRUE

	var/state = TVALVE_STATE_STRAIGHT
	var/animation = FALSE
	var/prefix = ""

/obj/machinery/atmospherics/components/trinary/tvalve/bypass
	icon_state = "map_tvalve1"
	state = TVALVE_STATE_SIDE

/obj/machinery/atmospherics/components/trinary/tvalve/flipped
	icon_state = "map_tvalvem0"
	flipped = 1

/obj/machinery/atmospherics/components/trinary/tvalve/flipped/bypass
	icon_state = "map_tvalvem1"
	flipped = 1
	state = TVALVE_STATE_SIDE

/obj/machinery/atmospherics/components/trinary/tvalve/update_icon_state()
	..()
	var/flipstate = ""
	if(flipped)
		flipstate = "m"
	if(animation)
		flick("t[prefix]valve[flipstate][state][!state]", src)
	else
		icon_state = "t[prefix]valve[flipstate][state]"

/obj/machinery/atmospherics/components/trinary/tvalve/update_underlays()
	if(..())
		underlays.Cut()
		var/turf/T = get_turf(src)
		if(!istype(T))
			return

		add_underlay(T, NODE1, turn(dir, -180))

		if(flipped)
			add_underlay(T, NODE2, turn(dir, 90))
		else
			add_underlay(T, NODE2, turn(dir, -90))

		add_underlay(T, NODE3, dir)

/obj/machinery/atmospherics/components/trinary/tvalve/proc/switch_side()
	if(state == TVALVE_STATE_STRAIGHT)
		go_to_side()
	else
		go_straight()

/obj/machinery/atmospherics/components/trinary/tvalve/proc/go_to_side()
	if(state == TVALVE_STATE_SIDE)
		return FALSE

	state = TVALVE_STATE_SIDE
	update_icon()
	var/datum/pipeline/parent1 = PARENT1
	var/datum/pipeline/parent2 = PARENT2
	var/datum/pipeline/parent3 = PARENT3
	parent1.update = 0
	parent2.update = 0
	parent3.update = 0
	parent1.reconcile_air()

	investigate_log("was set to side by [usr ? key_name_log(usr) : "a remote signal"]", INVESTIGATE_ATMOS)
	return TRUE

/obj/machinery/atmospherics/components/trinary/tvalve/proc/go_straight()
	if(state == TVALVE_STATE_STRAIGHT)
		return FALSE

	state = TVALVE_STATE_STRAIGHT
	update_icon()

	var/datum/pipeline/parent1 = PARENT1
	var/datum/pipeline/parent2 = PARENT2
	var/datum/pipeline/parent3 = PARENT3

	parent1.update = 0
	parent2.update = 0
	parent3.update = 0
	parent1.reconcile_air()

	investigate_log("was set to straight by [usr ? key_name_log(usr) : "a remote signal"]", INVESTIGATE_ATMOS)
	return TRUE

/obj/machinery/atmospherics/components/trinary/tvalve/attack_ai(mob/user)
	return

/obj/machinery/atmospherics/components/trinary/tvalve/attack_ghost(mob/user)
	if(user.can_advanced_admin_interact())
		return attack_hand(user)

/obj/machinery/atmospherics/components/trinary/tvalve/attack_hand(mob/usermob)
	add_fingerprint(usr)
	animation = TRUE
	update_icon(UPDATE_ICON_STATE)
	sleep(10)
	animation = FALSE
	switch_side()

/obj/machinery/atmospherics/components/trinary/tvalve/digital		// can be controlled by AI
	name = "digital switching valve"
	desc = "A digitally controlled valve."

	var/id = null
	prefix = "d"

/obj/machinery/atmospherics/components/trinary/tvalve/digital/bypass
	icon_state = "map_tdvalve1"
	state = TVALVE_STATE_SIDE

/obj/machinery/atmospherics/components/trinary/tvalve/digital/flipped
	icon_state = "map_tdvalvem0"
	flipped = TRUE

/obj/machinery/atmospherics/components/trinary/tvalve/digital/flipped/bypass
	icon_state = "map_tdvalvem1"
	flipped = TRUE
	state = TVALVE_STATE_SIDE

/obj/machinery/atmospherics/components/trinary/tvalve/digital/power_change(forced = FALSE)
	if(!..())
		return
	update_icon(UPDATE_ICON_STATE)

/obj/machinery/atmospherics/components/trinary/tvalve/digital/update_icon_state()
	..()
	if(powered())
		return
	icon_state = "tdvalve[flipped? "m" : ""]nopower"

/obj/machinery/atmospherics/components/trinary/tvalve/digital/attack_ai(mob/user)
	return attack_hand(user)

/obj/machinery/atmospherics/components/trinary/tvalve/digital/attack_hand(mob/user)
	if(!powered())
		return
	if(!allowed(user) && !user.can_advanced_admin_interact())
		to_chat(user, span_alert("Access denied."))
		return
	..()

/obj/machinery/atmospherics/components/trinary/tvalve/digital/atmos_init()
	..()
	if(frequency)
		set_frequency(frequency)

/obj/machinery/atmospherics/components/trinary/tvalve/digital/receive_signal(datum/signal/signal)
	if(!signal.data["tag"] || (signal.data["tag"] != id))
		return 0

	switch(signal.data["command"])
		if("valve_open")
			go_to_side()

		if("valve_close")
			go_straight()

		if("valve_toggle")
			switch_side()

#undef TVALVE_STATE_STRAIGHT
#undef TVALVE_STATE_SIDE
