/obj/machinery/door_control
	name = "remote door-control"
	desc = "A remote control-switch for a door."
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "doorctrl"
	base_icon_state = "doorctrl"
	power_channel = ENVIRON

	anchored = TRUE
	use_power = IDLE_POWER_USE
	idle_power_usage = 2
	active_power_usage = 4

	var/exposedwires = FALSE
	var/ai_control = TRUE
	var/is_animating = FALSE

	var/obj/item/assembly/device

	/// The button controls things that have matching id tag. Can be a list to control multiple ids.
	var/id = null
	/// Should it only work on the same z-level
	var/safety_z_check = TRUE
	/// FALSE- poddoor control, TRUE- airlock control
	var/normaldoorcontrol = FALSE
	/// FALSE is closed, TRUE is open.
	var/desiredstate = FALSE
	/**
	Bitflag, 	1= open
				2= idscan,
				4= bolts
				8= shock
				16= door safties
	*/
	var/specialfunctions = OPEN


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
	build_device()

/obj/machinery/door_control/Destroy()
	QDEL_NULL(device)
	return ..()

/obj/machinery/door_control/proc/build_device()
	if(normaldoorcontrol)
		var/obj/item/assembly/control/airlock/airlock_device = new(src)
		airlock_device.specialfunctions = specialfunctions
		airlock_device.desiredstate = desiredstate
		device = airlock_device
	else
		var/obj/item/assembly/control/poddoor/poddoor_device = new(src)
		device = poddoor_device

	var/obj/item/assembly/control/my_device = device
	my_device.ids = get_ids()
	my_device.safety_z_check = safety_z_check

/obj/machinery/door_control/proc/get_ids()
	if(isnull(id))
		return list()
	else if(!islist(id))
		return list(id)
	else
		return id

/obj/machinery/door_control/attack_hand(mob/user)
	add_fingerprint(user)
	if(stat & (NOPOWER|BROKEN))
		return
	if(device?.cooldown > 0)
		return

	if(!allowed(user) && !user.can_advanced_admin_interact())
		to_chat(user, span_warning("Access Denied."))
		flick("[base_icon_state]-denied",src)
		playsound(src, pick('sound/machines/button.ogg', 'sound/machines/button_alternate.ogg', 'sound/machines/button_meloboom.ogg'), 20)
		return

	use_power(5)
	animate_activation()

	if(device)
		INVOKE_ASYNC(device, TYPE_PROC_REF(/obj/item/assembly, activate))


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

