// MARK: mass driver button
/obj/machinery/driver_button
	name = "mass driver button"
	desc = "A remote control switch for a mass driver."
	icon = 'icons/obj/objects.dmi'
	icon_state = "launcherbtt"
	anchored = TRUE
	armor = list(MELEE = 50, BULLET = 50, LASER = 50, ENERGY = 50, BOMB = 10, BIO = 100, RAD = 100, FIRE = 90, ACID = 70)
	idle_power_usage = 2
	active_power_usage = 4
	resistance_flags = LAVA_PROOF | FIRE_PROOF
	/// ID tag of the driver to hook to
	var/id_tag = "default"
	/// Are we active?
	var/active = FALSE
	/// Range of drivers + blast doors to hit
	var/range = 7

/obj/machinery/button/indestructible
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF

/obj/machinery/driver_button/Initialize(mapload, place_dir)
	. = ..()
	switch(place_dir)
		if(NORTH)
			pixel_y = 25
		if(SOUTH)
			pixel_y = -25
		if(EAST)
			pixel_x = 25
		if(WEST)
			pixel_x = -25

/obj/machinery/driver_button/update_icon_state()
	icon_state = active ? "launcheract" : "launcherbtt"

/obj/machinery/driver_button/attack_ai(mob/user)
	attack_hand(user)

/obj/machinery/driver_button/attack_ghost(mob/user)
	if(user.can_advanced_admin_interact())
		attack_hand(user)

/obj/machinery/driver_button/wrench_act(mob/user, obj/item/item)
	. = TRUE
	if(!item.use_tool(src, user, 3 SECONDS, volume = item.tool_volume))
		return

	WRENCH_UNANCHOR_WALL_MESSAGE
	new/obj/item/mounted/frame/driver_button(get_turf(src))
	qdel(src)

/obj/machinery/driver_button/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/detective_scanner))
		return ATTACK_CHAIN_PROCEED
	return ..()

/obj/machinery/driver_button/attack_hand(mob/user)
	if(stat & (NOPOWER|BROKEN))
		return

	if(active)
		return

	add_fingerprint(user)

	use_power(5)

	// Start us off
	launch_sequence()

/obj/machinery/driver_button/proc/launch_sequence()
	active = TRUE
	update_icon(UPDATE_ICON_STATE)

	// Time sequence
	// OPEN DOORS
	// Wait 2 seconds
	// LAUNCH
	// Wait 5 seconds
	// CLOSE
	// Then make not active

	for(var/obj/machinery/door/poddoor/door in range(src, range))
		if(door.id_tag == id_tag && !door.protected)
			INVOKE_ASYNC(door, TYPE_PROC_REF(/obj/machinery/door, open))

	// 2 seconds after previous invocation
	for(var/obj/machinery/mass_driver/driver in range(src, range))
		if(driver.id_tag == id_tag)
			addtimer(CALLBACK(driver, TYPE_PROC_REF(/obj/machinery/mass_driver, drive)), 2 SECONDS)

	// We want this 5 seconds after open, so the delay is 7 seconds from this proc
	for(var/obj/machinery/door/poddoor/door in range(src, range))
		if(door.id_tag == id_tag && !door.protected)
			addtimer(CALLBACK(door, TYPE_PROC_REF(/obj/machinery/door, close)), 7 SECONDS)

	// And rearm us
	addtimer(CALLBACK(src, PROC_REF(rearm)), 7 SECONDS)

/obj/machinery/driver_button/proc/rearm()
	active = FALSE
	update_icon(UPDATE_ICON_STATE)

/obj/machinery/driver_button/multitool_act(mob/user, obj/item/item)
	. = TRUE
	if(!item.use_tool(src, user, 0, volume = item.tool_volume))
		return

	if(!Adjacent(user))
		return

	var/new_tag = tgui_input_text("Enter a new ID tag", "ID Tag", id_tag, user)

	if(new_tag && Adjacent(user))
		id_tag = new_tag

// MARK: ignition switch
/obj/machinery/ignition_switch
	name = "ignition switch"
	desc = "A remote control switch for a mounted igniter."
	icon = 'icons/obj/objects.dmi'
	icon_state = "launcherbtt"
	anchored = TRUE
	idle_power_usage = 2
	active_power_usage = 4
	/// ID tag of the switch to hook to
	var/id_tag = null
	/// Are we active?
	var/active = FALSE

/obj/machinery/ignition_switch/attack_ai(mob/user)
	attack_hand(user)

/obj/machinery/ignition_switch/attack_ghost(mob/user)
	if(user.can_advanced_admin_interact())
		attack_hand(user)

/obj/machinery/ignition_switch/update_icon_state()
	icon_state = active ? "launcheract" : "launcherbtt"

/obj/machinery/ignition_switch/attack_hand(mob/user)
	if(stat & (NOPOWER|BROKEN))
		return
	if(active)
		return

	add_fingerprint(user)

	use_power(5)

	active = TRUE
	update_icon(UPDATE_ICON_STATE)

	for(var/obj/machinery/sparker/sparker in SSmachines.get_by_type(/obj/machinery/sparker))
		if(sparker.id_tag == id_tag)
			INVOKE_ASYNC(sparker, TYPE_PROC_REF(/obj/machinery/sparker, spark))

	for(var/obj/machinery/igniter/igniter in SSmachines.get_by_type(/obj/machinery/igniter))
		if(igniter.id_tag == id_tag)
			use_power(50)
			igniter.on = !igniter.on
			igniter.icon_state = "igniter[igniter.on]"

	addtimer(CALLBACK(src, PROC_REF(rearm)), 5 SECONDS)

/obj/machinery/ignition_switch/proc/rearm()
	active = FALSE
	update_icon(UPDATE_ICON_STATE)
