/obj/machinery/door_control
	name = "remote door-control"
	desc = "A remote control-switch for a door."
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "doorctrl"
	base_icon_state = "doorctrl"
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
	var/is_animating = FALSE
	anchored = TRUE
	use_power = IDLE_POWER_USE
	idle_power_usage = 2
	active_power_usage = 4


/obj/machinery/door_control/Initialize(mapload)
	. = ..()
	power_change(forced = TRUE)


/obj/machinery/door_control/attack_ai(mob/user)
	if(ai_control)
		return attack_hand(user)
	else
		to_chat(user, "Error, no route to host.")

/obj/machinery/door_control/attackby(obj/item/W, mob/user, params)
	if(istype(W, /obj/item/detective_scanner))
		return
	return ..()

/obj/machinery/door_control/emag_act(mob/user)
	if(!emagged)
		emagged = TRUE
		req_access = list()
		playsound(src, "sparks", 100, TRUE, SHORT_RANGE_SOUND_EXTRARANGE)

/obj/machinery/door_control/attack_ghost(mob/user)
	if(user.can_advanced_admin_interact())
		return attack_hand(user)

/obj/machinery/door_control/Initialize(mapload)
    . = ..()
    if(!islist(id))
        id = list(id)

/obj/machinery/door_control/proc/do_main_action(mob/user)
	if(normaldoorcontrol)
		for(var/obj/machinery/door/airlock/airlock in GLOB.airlocks)
			if(safety_z_check && airlock.z != z || !(airlock.id_tag in id))
				continue
			if(specialfunctions & OPEN)
				if(airlock.density)
					INVOKE_ASYNC(airlock, TYPE_PROC_REF(/obj/machinery/door, open))
				else
					INVOKE_ASYNC(airlock, TYPE_PROC_REF(/obj/machinery/door, close))
			if(desiredstate)
				if(specialfunctions & IDSCAN)
					airlock.aiDisabledIdScanner = TRUE
				if(specialfunctions & BOLTS)
					airlock.lock()
				if(specialfunctions & SHOCK)
					airlock.electrify(-1)
				if(specialfunctions & SAFE)
					airlock.safe = FALSE
			else
				if(specialfunctions & IDSCAN)
					airlock.aiDisabledIdScanner = FALSE
				if(specialfunctions & BOLTS)
					airlock.unlock()
				if(specialfunctions & SHOCK)
					airlock.electrify(0)
				if(specialfunctions & SAFE)
					airlock.safe = TRUE

	else
		for(var/obj/machinery/door/poddoor/poddoor in GLOB.airlocks)
			if(safety_z_check && poddoor.z != z || !(poddoor.id_tag in id))
				continue
			if(poddoor.density)
				INVOKE_ASYNC(poddoor, TYPE_PROC_REF(/obj/machinery/door, open))
			else
				INVOKE_ASYNC(poddoor, TYPE_PROC_REF(/obj/machinery/door, close))

	desiredstate = !desiredstate

/obj/machinery/door_control/attack_hand(mob/user)
	add_fingerprint(user)
	if(stat & (NOPOWER|BROKEN))
		return

	if(!allowed(user) && !user.can_advanced_admin_interact())
		to_chat(user, span_warning("Access Denied."))
		flick("[base_icon_state]-denied",src)
		playsound(src, pick('sound/machines/button.ogg', 'sound/machines/button_alternate.ogg', 'sound/machines/button_meloboom.ogg'), 20)
		return

	use_power(5)
	animate_activation()
	do_main_action(user)


/obj/machinery/door_control/proc/animate_activation()
	if(is_animating)
		return
	is_animating = TRUE
	update_icon(UPDATE_ICON_STATE)
	addtimer(CALLBACK(src, PROC_REF(finish_animation)), 1.5 SECONDS)


/obj/machinery/door_control/proc/finish_animation()
	is_animating = FALSE
	update_icon(UPDATE_ICON_STATE)


/obj/machinery/door_control/power_change(forced = FALSE)
	if(!..())
		return
	if(stat & NOPOWER)
		set_light_on(FALSE)
	else
		set_light(1, LIGHTING_MINIMUM_POWER)
	update_icon()


/obj/machinery/door_control/update_icon_state()
	if(stat & NOPOWER)
		icon_state = "[base_icon_state]-p"
		return
	icon_state = is_animating ? "[base_icon_state]-inuse" : base_icon_state


/obj/machinery/door_control/update_overlays()
	. = ..()
	underlays.Cut()

	if(stat & NOPOWER)
		return

	underlays += emissive_appearance(icon, "[base_icon_state]_lightmask")


/obj/machinery/door_control/secure //Use icon_state = "altdoorctrl" if you just want cool icon for your button on map. This button is created for Admin-zones.
	icon_state = "altdoorctrl"
	base_icon_state = "altdoorctrl"
	ai_control = FALSE

/obj/machinery/door_control/secure/emag_act(user)
	if(user)
		to_chat(user, span_notice("The electronic systems in this device are far too advanced for your primitive hacking peripherals."))


// hidden mimic button
/obj/machinery/door_control/mimic
	icon = 'icons/obj/lighting.dmi'
	icon_state = "lantern"


/obj/machinery/door_control/mimic/animate_activation()
	audible_message("Something clicked.", hearing_distance = 1)


/obj/machinery/door_control/mimic/update_icon_state()
	return


/obj/machinery/door_control/mimic/update_overlays()
	. = list()


/obj/machinery/door_control/mimic/power_change(forced = FALSE)
	if(powered(power_channel))
		stat &= ~NOPOWER
	else
		stat |= NOPOWER

