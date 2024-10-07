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

	var/ai_control = TRUE
	var/is_animating = FALSE

	var/obj/item/assembly/device
	var/obj/item/access_control/access_electronics

	/// Was it constructed by players
	var/constructed = FALSE
	/// Is panel open
	var/open = FALSE

	/// The button controls things that have matching id tag. Can be a list to control multiple ids.
	var/id = null
	/// Should it only work on the same z-level
	var/safety_z_check = FALSE
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


/obj/machinery/door_control/Initialize(mapload, direction = null, building = FALSE)
	. = ..()
	if(building)
		open = TRUE
		constructed = TRUE
		setDir(direction)
		set_pixel_offsets_from_dir(26, -26, 26, -26)
	update_icon()


/obj/machinery/door_control/attack_ai(mob/user)
	if(open)
		return
	if(ai_control)
		return attack_hand(user)
	else
		to_chat(user, "Error, no route to host.")


/obj/machinery/door_control/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/detective_scanner))
		return ATTACK_CHAIN_PROCEED

	if(!open || user.a_intent == INTENT_HARM)
		return ..()

	if(is_pen(I))
		rename_interactive(user, I)
		return ATTACK_CHAIN_PROCEED_SUCCESS

	if(isassembly(I))
		add_fingerprint(user)
		if(device)
			to_chat(user, span_warning("There is already [device.name] installed."))
			return ATTACK_CHAIN_PROCEED
		if(!user.drop_transfer_item_to_loc(I, src))
			return ..()
		playsound(loc, I.usesound, 100, TRUE)
		user.visible_message(
			span_notice("[user] installs [I] into the button frame."),
			span_notice("You install [I] into the button frame."),
		)
		device = I
		// ignore "readiness" of the assembly to not confuse players with multiple assembly states
		if(!device.secured)
			device.toggle_secure()
		update_icon(UPDATE_OVERLAYS)
		return ATTACK_CHAIN_BLOCKED_ALL

	if(istype(I, /obj/item/access_control))
		add_fingerprint(user)
		var/obj/item/access_control/control = I
		if(access_electronics)
			to_chat(user, span_warning("The [name] already has [access_electronics] installed."))
			return ATTACK_CHAIN_PROCEED
		if(control.emagged)
			to_chat(user, span_warning("The [control.name] is broken."))
			return ATTACK_CHAIN_PROCEED
		if(!user.drop_transfer_item_to_loc(I, src))
			return ..()
		playsound(loc, I.usesound, 100, TRUE)
		user.visible_message(
			span_notice("[user] installs [I] into the button frame."),
			span_notice("You install [I] into the button frame."),
		)
		access_electronics = I
		if(emagged)
			emagged = FALSE
		update_icon(UPDATE_OVERLAYS)
		return ATTACK_CHAIN_BLOCKED_ALL

	return ..()


/obj/machinery/door_control/screwdriver_act(mob/living/user, obj/item/I)
	. = TRUE
	if(!(open || allowed(user)))
		to_chat(user, span_warning("Access Denied. The cover plate will not open."))
		return
	if(!I.use_tool(src, user, delay = 3 SECONDS, volume = I.tool_volume))
		return

	// Close the panel
	if(open)
		SCREWDRIVER_CLOSE_PANEL_MESSAGE
		open = FALSE
		update_access()
		update_icon()
		return

	// Open the panel
	if(!constructed)
		if(!device)
			build_device()
		if(!access_electronics)
			build_access_electronics()
	SCREWDRIVER_OPEN_PANEL_MESSAGE
	open = TRUE
	constructed = TRUE
	update_icon()

/obj/machinery/door_control/wrench_act(mob/living/user, obj/item/I)
	if(!open)
		return
	. = TRUE

	if(device || access_electronics)
		to_chat(user, "You must take out the electronics first.")
		return

	if(!I.use_tool(src, user, delay = 3 SECONDS, volume = I.tool_volume))
		return
	WRENCH_UNANCHOR_WALL_MESSAGE
	new /obj/item/mounted/frame/door_control(get_turf(user))
	qdel(src)

/obj/machinery/door_control/emag_act(mob/user)
	if(!emagged)
		emagged = TRUE
		req_access = list()
		playsound(src, "sparks", 100, TRUE, SHORT_RANGE_SOUND_EXTRARANGE)

/obj/machinery/door_control/attack_ghost(mob/user)
	if(open)
		return
	if(user.can_advanced_admin_interact())
		return attack_hand(user)

/obj/machinery/door_control/Destroy()
	QDEL_NULL(device)
	QDEL_NULL(access_electronics)
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

/obj/machinery/door_control/proc/build_access_electronics()
	access_electronics = new /obj/item/access_control(src)
	access_electronics.selected_accesses = length(req_access) ? req_access : list()
	access_electronics.one_access = check_one_access

/obj/machinery/door_control/proc/update_access()
	if(access_electronics && !emagged)
		req_access = access_electronics.selected_accesses
		check_one_access = access_electronics.one_access
	else
		req_access = list()

/obj/machinery/door_control/proc/get_ids()
	if(isnull(id))
		return list()
	else if(!islist(id))
		return list(id)
	else
		return id

/obj/machinery/door_control/attack_hand(mob/user)
	if(open)
		if(!(device || access_electronics))
			return

		if(device)
			device.forceMove_turf()
			user.put_in_hands(device, ignore_anim = FALSE)
			device.add_fingerprint(user)
			device = null
		if(access_electronics)
			access_electronics.forceMove_turf()
			user.put_in_hands(access_electronics, ignore_anim = FALSE)
			access_electronics.add_fingerprint(user)
			if(emagged)
				access_electronics.emag_act()
			access_electronics = null

		user.visible_message("[user] takes out the electronics from the button frame.", "You take out the electronics from the button frame.")

		add_fingerprint(user)
		update_icon(UPDATE_OVERLAYS)
		return

	add_fingerprint(user)
	if(stat & (NOPOWER|BROKEN))
		return

	if(!(device || constructed))
		build_device()

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
	. = ..()
	if(.)
		update_icon()


/obj/machinery/door_control/update_icon_state()
	if(open)
		icon_state = "doorctrl-panel"
		return
	if(stat & NOPOWER)
		icon_state = "[base_icon_state]-p"
		return
	icon_state = is_animating ? "[base_icon_state]-inuse" : base_icon_state


/obj/machinery/door_control/update_overlays()
	. = ..()
	underlays.Cut()
	if(open)
		// access_board overlay
		if(access_electronics)
			. += "doorctrl-overlay-board"

		// device overlay
		if(issignaler(device))
			. += "doorctrl-overlay-signaler"
		else if(device)
			. += "doorctrl-overlay-device"

	if(open || (stat & NOPOWER))
		return

	underlays += emissive_appearance(icon, "[base_icon_state]_lightmask", src)


/obj/machinery/door_control/secure //Use icon_state = "altdoorctrl" if you just want cool icon for your button on map. This button is created for Admin-zones.
	icon_state = "altdoorctrl"
	base_icon_state = "altdoorctrl"
	ai_control = FALSE

/obj/machinery/door_control/secure/emag_act(user)
	if(user)
		to_chat(user, span_notice("The electronic systems in this device are far too advanced for your primitive hacking peripherals."))

/obj/machinery/door_control/secure/screwdriver_act(mob/living/user, obj/item/I)
	. = TRUE
	to_chat(user, span_notice("[src] is highly secured. You cannot open the cover plate."))


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

/obj/machinery/door_control/mimic/screwdriver_act(mob/living/user, obj/item/I)
	return
