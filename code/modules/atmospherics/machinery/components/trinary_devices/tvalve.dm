#define TVALVE_STATE_STRAIGHT 0
#define TVALVE_STATE_SIDE 1

/obj/machinery/atmospherics/trinary/tvalve
	name = "manual switching valve"
	desc = "A pipe valve."
	icon = 'icons/obj/pipes_and_stuff/atmospherics/atmos/tvalve.dmi'
	icon_state = "map_tvalve0"
	can_unwrench = TRUE
	var/state = TVALVE_STATE_STRAIGHT
	var/animation = FALSE

/obj/machinery/atmospherics/trinary/tvalve/examine(mob/user)
	. = ..()
	. += span_notice("Click this to toggle the mode. The direction with the dot is where the gas will flow to. The gas flows from the opposite side or the one with the uninterrupted line.")

/obj/machinery/atmospherics/trinary/tvalve/bypass
	icon_state = "map_tvalve1"
	state = TVALVE_STATE_SIDE

/obj/machinery/atmospherics/trinary/tvalve/flipped
	icon_state = "map_tvalvem0"
	flipped = TRUE

/obj/machinery/atmospherics/trinary/tvalve/flipped/bypass
	icon_state = "map_tvalvem1"
	state = TVALVE_STATE_SIDE

/obj/machinery/atmospherics/trinary/tvalve/update_icon_state()
	var/flipstate = ""
	if(flipped)
		flipstate = "m"
	if(animation)
		flick("tvalve[flipstate][state][!state]", src)
	else
		icon_state = "tvalve[flipstate][state]"
	..()

/obj/machinery/atmospherics/trinary/tvalve/update_underlays()
	if(..())
		underlays.Cut()
		var/turf/T = get_turf(src)
		if(!istype(T))
			return

		add_underlay(T, node1, turn(dir, -180))

		if(flipped)
			add_underlay(T, node2, turn(dir, 90))
		else
			add_underlay(T, node2, turn(dir, -90))

		add_underlay(T, node3, dir)

/obj/machinery/atmospherics/trinary/tvalve/proc/switch_side()
	if(state == TVALVE_STATE_STRAIGHT)
		go_to_side()
	else
		go_straight()

/obj/machinery/atmospherics/trinary/tvalve/proc/go_to_side()
	if(state == TVALVE_STATE_SIDE)
		return FALSE

	state = TVALVE_STATE_SIDE
	update_icon()

	parent1.update = FALSE
	parent2.update = FALSE
	parent3.update = FALSE
	parent1.reconcile_air()

	investigate_log("was set to side by [usr ? key_name_log(usr) : "a remote signal"]", INVESTIGATE_ATMOS)
	return TRUE

/obj/machinery/atmospherics/trinary/tvalve/proc/go_straight()
	if(state == TVALVE_STATE_STRAIGHT)
		return FALSE

	state = TVALVE_STATE_STRAIGHT
	update_icon()

	parent1.update = FALSE
	parent2.update = FALSE
	parent3.update = FALSE
	parent1.reconcile_air()

	investigate_log("was set to straight by [usr ? key_name_log(usr) : "a remote signal"]", INVESTIGATE_ATMOS)
	return TRUE

/obj/machinery/atmospherics/trinary/tvalve/attack_hand(mob/usermob)
	add_fingerprint(usr)
	animation = TRUE
	update_icon(UPDATE_ICON_STATE)

	addtimer(CALLBACK(src, PROC_REF(finish_animation_and_switch), usermob), 1 SECONDS)

/obj/machinery/atmospherics/trinary/tvalve/proc/finish_animation_and_switch(mob/user)
	animation = FALSE
	switch_side(user)

/obj/machinery/atmospherics/trinary/tvalve/attack_ai(mob/user)
	return

/obj/machinery/atmospherics/trinary/tvalve/attack_ghost(mob/user)
	if(user.can_advanced_admin_interact())
		attack_hand(user)

/obj/machinery/atmospherics/trinary/tvalve/digital		// can be controlled by AI
	name = "digital switching valve"
	desc = "A digitally controlled valve."
	icon = 'icons/obj/pipes_and_stuff/atmospherics/atmos/digital_tvalve.dmi'

	var/id = null

/obj/machinery/atmospherics/trinary/tvalve/digital/bypass
	icon_state = "map_tvalve1"
	state = TVALVE_STATE_SIDE

/obj/machinery/atmospherics/trinary/tvalve/digital/flipped
	icon_state = "map_tvalvem0"
	flipped = TRUE

/obj/machinery/atmospherics/trinary/tvalve/digital/flipped/bypass
	icon_state = "map_tvalvem1"
	state = TVALVE_STATE_SIDE

/obj/machinery/atmospherics/trinary/tvalve/digital/power_change(forced = FALSE)
	if(!..())
		return
	update_icon(UPDATE_ICON_STATE)

/obj/machinery/atmospherics/trinary/tvalve/digital/update_icon_state()
	var/flipstate = ""

	if(flipped)
		flipstate = "m"

	if(!powered())
		icon_state = "tvalve[flipstate]nopower"
		return
	..()

/obj/machinery/atmospherics/trinary/tvalve/digital/attack_ai(mob/user)
	return attack_hand(user)

/obj/machinery/atmospherics/trinary/tvalve/digital/attack_hand(mob/user)
	if(!powered())
		return
	if(!allowed(user) && !user.can_advanced_admin_interact())
		to_chat(user, span_alert("Access denied."))
		return
	..()

/obj/machinery/atmospherics/trinary/tvalve/digital/receive_signal(datum/signal/signal)
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
