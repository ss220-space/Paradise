/obj/machinery/door_control
	name = "remote door-control"
	desc = "A remote control-switch for a door."
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "doorctrl"
	power_channel = ENVIRON
	var/id = null
	var/safety_z_check = TRUE
	var/normaldoorcontrol = FALSE
	var/desiredstate = FALSE // FALSE is closed, TRUE is open.
	var/specialfunctions = 1
	/*
	Bitflag, 	1= open
				2= idscan,
				4= bolts
				8= shock
				16= door safties

	*/

	var/exposedwires = FALSE
	var/ai_control = TRUE
	anchored = TRUE
	use_power = IDLE_POWER_USE
	idle_power_usage = 2
	active_power_usage = 4

/obj/machinery/door_control/attack_ai(mob/user)
	if(ai_control)
		return attack_hand(user)
	else
		to_chat(user, "Error, no route to host.")

/obj/machinery/door_control/attackby(obj/item/W, mob/user, params)
	if(istype(W, /obj/item/detective_scanner))
		return
	return ..()

/obj/machinery/door_control/emag_act(user as mob)
	if(!emagged)
		emagged = TRUE
		req_access = list()
		playsound(src, "sparks", 100, TRUE, SHORT_RANGE_SOUND_EXTRARANGE)

/obj/machinery/door_control/attack_ghost(mob/user)
	if(user.can_advanced_admin_interact())
		return attack_hand(user)

/obj/machinery/door_control/Initialize(mapload)
    . = ..()
    if(!istype(id, /list))
        id = list(id)

/obj/machinery/door_control/proc/do_main_action(mob/user)
	if(normaldoorcontrol)
		for(var/obj/machinery/door/airlock/D in GLOB.airlocks)
			if(safety_z_check && D.z != z || !(D.id_tag in id))
				continue
			if(specialfunctions & OPEN)
				if(D.density)
					spawn(0)
						D.open()
				else
					spawn(0)
						D.close()
			if(desiredstate)
				if(specialfunctions & IDSCAN)
					D.aiDisabledIdScanner = TRUE
				if(specialfunctions & BOLTS)
					D.lock()
				if(specialfunctions & SHOCK)
					D.electrify(-1)
				if(specialfunctions & SAFE)
					D.safe = FALSE
			else
				if(specialfunctions & IDSCAN)
					D.aiDisabledIdScanner = FALSE
				if(specialfunctions & BOLTS)
					D.unlock()
				if(specialfunctions & SHOCK)
					D.electrify(0)
				if(specialfunctions & SAFE)
					D.safe = TRUE

	else
		for(var/obj/machinery/door/poddoor/M in GLOB.airlocks)
			if(safety_z_check && M.z != z || !(M.id_tag in id))
				continue
			if(M.density)
				spawn(0)
					M.open()
			else
				spawn(0)
					M.close()

	desiredstate = !desiredstate

/obj/machinery/door_control/attack_hand(mob/user)
	add_fingerprint(user)
	if(stat & (NOPOWER|BROKEN))
		return

	if(!allowed(user) && !user.can_advanced_admin_interact())
		to_chat(user, span_warning("Access Denied."))
		flick("[initial(icon_state)]-denied",src)
		playsound(src, pick('sound/machines/button.ogg', 'sound/machines/button_alternate.ogg', 'sound/machines/button_meloboom.ogg'), 20)
		return

	use_power(5)
	icon_state = "[initial(icon_state)]-inuse"

	do_main_action(user)

	addtimer(CALLBACK(src, PROC_REF(update_icon)), 15)

/obj/machinery/door_control/power_change()
	..()
	update_icon()

/obj/machinery/door_control/update_icon()
	if(stat & NOPOWER)
		icon_state = "[initial(icon_state)]-p"
	else
		icon_state = initial(icon_state)

/obj/machinery/door_control/secure //Use icon_state = "altdoorctrl" if you just want cool icon for your button on map. This button is created for Admin-zones.
	icon_state = "altdoorctrl"
	ai_control = FALSE

/obj/machinery/door_control/secure/emag_act(user)
	to_chat(user, span_notice("The electronic systems in this device are far too advanced for your primitive hacking peripherals."))
	return
