
/datum/wires/alarm
	holder_type = /obj/machinery/alarm
	wire_count = 5
	window_x = 385
	window_y = 90
	proper_name = "Air alarm"

/datum/wires/alarm/New(atom/_holder)
	wires = list(
		WIRE_IDSCAN , WIRE_MAIN_POWER1 , WIRE_SIPHON,
		WIRE_AI_CONTROL, WIRE_AALARM
	)
	return ..()

/datum/wires/alarm/interactable(mob/user)
	var/obj/machinery/alarm/alarm = holder
	if(alarm.wiresexposed)
		return TRUE
	return FALSE

/datum/wires/alarm/get_status()
	. = ..()
	var/obj/machinery/alarm/alarm = holder
	. += "The Air Alarm is [alarm.locked ? "" : "un"]locked."
	. += "The Air Alarm is [(alarm.shorted || (alarm.stat & (NOPOWER|BROKEN))) ? "offline." : "working properly!"]"
	. += "The 'AI control allowed' light is [alarm.aidisabled ? "off" : "on"]."

/datum/wires/alarm/on_cut(wire, mend)
	var/obj/machinery/alarm/alarm = holder
	switch(wire)
		if(WIRE_IDSCAN)
			if(!mend)
				alarm.locked = TRUE

		if(WIRE_MAIN_POWER1)
			alarm.shock(usr, 50)
			alarm.shorted = !mend
			alarm.update_icon()

		if(WIRE_AI_CONTROL)
			alarm.aidisabled = !mend

		if(WIRE_SIPHON)
			if(!mend)
				alarm.mode = AALARM_MODE_PANIC
				alarm.apply_mode()

		if(WIRE_AALARM)
			alarm.alarm_area.atmosalert(ATMOS_ALARM_DANGER, alarm)
			alarm.update_icon()
	..()

/datum/wires/alarm/on_pulse(wire)
	var/obj/machinery/alarm/alarm = holder
	switch(wire)
		if(WIRE_IDSCAN)
			alarm.locked = !alarm.locked

		if(WIRE_MAIN_POWER1)
			if(!alarm.shorted)
				alarm.shorted = TRUE
				alarm.update_icon()
			addtimer(CALLBACK(alarm, TYPE_PROC_REF(/obj/machinery/alarm, unshort_callback)), 120 SECONDS)

		if(WIRE_AI_CONTROL)
			if(!alarm.aidisabled)
				alarm.aidisabled = TRUE
			alarm.updateDialog()
			addtimer(CALLBACK(alarm, TYPE_PROC_REF(/obj/machinery/alarm, enable_ai_control_callback)), 10 SECONDS)

		if(WIRE_SIPHON)
			if(alarm.mode == AALARM_MODE_FILTERING)
				alarm.mode = AALARM_MODE_PANIC
			else
				alarm.mode = AALARM_MODE_FILTERING
			alarm.apply_mode()

		if(WIRE_AALARM)
			alarm.alarm_area.atmosalert(ATMOS_ALARM_NONE, alarm)
			alarm.update_icon()
	..()
