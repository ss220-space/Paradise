#define STATE_FULL (1<<0)
#define STATE_OPENED (1<<1)
#define STATE_BLOODY (1<<2)
#define STATE_WORKING (1<<3)
#define STATE_PANEL (1<<4)
#define STATE_HACKED (1<<5)
#define STATE_DISABLED (1<<6)
#define STATE_SHOCKED (1<<7)

/datum/wires/washing_machine
	proper_name = "Washing machine"
	holder_type = /obj/machinery/washing_machine
	wire_count = 8
	window_x = 340
	window_y = 75


/datum/wires/washing_machine/New(atom/_holder)
	wires = list(WIRE_ELECTRIFY, WIRE_WASHER_HACK, WIRE_WASHER_DISABLE)
	return ..()


/datum/wires/washing_machine/get_status()
	. = ..()
	var/obj/machinery/washing_machine/washer = holder
	. += "The red light is [(washer.state & STATE_DISABLED) ? "off" : "on"]."
	. += "The green light is [(washer.state & STATE_SHOCKED) ? "off" : "on"]."
	. += "The blue light is [(washer.state & STATE_HACKED) ? "off" : "on"]."


/datum/wires/washing_machine/interactable(mob/user)
	var/obj/machinery/washing_machine/washer = holder
	if((washer.state & STATE_SHOCKED) && iscarbon(user) && washer.Adjacent(user) && washer.shock(user, 100))
		return FALSE
	if(washer.state & STATE_WORKING)
		return FALSE
	if(washer.state & STATE_PANEL)
		return TRUE
	return FALSE


/datum/wires/washing_machine/on_cut(wire, mend)
	var/obj/machinery/washing_machine/washer = holder
	switch(wire)
		if(WIRE_ELECTRIFY)
			if((mend && (washer.state & STATE_SHOCKED)) || (!mend && !(washer.state & STATE_SHOCKED)))
				washer.toggle_state(STATE_SHOCKED)
		if(WIRE_WASHER_HACK)
			if((mend && (washer.state & STATE_HACKED)) || (!mend && !(washer.state & STATE_HACKED)))
				washer.toggle_state(STATE_HACKED)
		if(WIRE_WASHER_DISABLE)
			if((mend && (washer.state & STATE_DISABLED)) || (!mend && !(washer.state & STATE_DISABLED)))
				washer.toggle_state(STATE_DISABLED)


/datum/wires/washing_machine/on_pulse(wire)
	if(is_cut(wire))
		return
	var/obj/machinery/washing_machine/washer = holder
	var/state_to_remove
	switch(wire)
		if(WIRE_ELECTRIFY)
			if(!(washer.state & STATE_SHOCKED))
				washer.toggle_state(STATE_SHOCKED)
				state_to_remove = STATE_SHOCKED
		if(WIRE_WASHER_HACK)
			if(!(washer.state & STATE_HACKED))
				washer.toggle_state(STATE_HACKED)
				state_to_remove = STATE_HACKED
		if(WIRE_WASHER_DISABLE)
			if(!(washer.state & STATE_DISABLED))
				washer.toggle_state(STATE_DISABLED)
				state_to_remove = STATE_DISABLED
	if(state_to_remove)
		addtimer(CALLBACK(washer, TYPE_PROC_REF(/obj/machinery/washing_machine, pulsed_callback), wire, state_to_remove), 10 SECONDS, TIMER_UNIQUE|TIMER_OVERRIDE)


#undef STATE_FULL
#undef STATE_OPENED
#undef STATE_BLOODY
#undef STATE_WORKING
#undef STATE_PANEL
#undef STATE_HACKED
#undef STATE_DISABLED
#undef STATE_SHOCKED

