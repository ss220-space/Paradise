/obj/machinery/camera
	name = "security camera"
	desc = "It's used to monitor rooms."
	icon = 'icons/obj/machines/monitors.dmi'
	blocks_emissive = EMISSIVE_BLOCK_GENERIC
	icon_state = "camera"
	use_power = ACTIVE_POWER_USE
	idle_power_usage = 5
	active_power_usage = 10
	layer = WALL_OBJ_LAYER
	resistance_flags = FIRE_PROOF
	damage_deflection = 12
	armor = list("melee" = 50, "bullet" = 20, "laser" = 20, "energy" = 20, "bomb" = 0, "bio" = 0, "rad" = 0, "fire" = 90, "acid" = 50)
	var/datum/wires/camera/wires = null // Wires datum
	max_integrity = 100
	integrity_failure = 50
	var/list/network = list("SS13")
	var/c_tag = null
	var/c_tag_order = 999
	var/status = TRUE
	anchored = TRUE
	var/start_active = FALSE //If it ignores the random chance to start broken on round start
	var/invuln = null
	var/obj/item/camera_assembly/assembly = null
	var/list/computers_watched_by = list()

	//OTHER

	var/view_range = 7
	var/short_range = 2

	var/alarm_on = FALSE
	var/busy = FALSE

	var/in_use_lights = 0 // TO BE IMPLEMENTED
	var/toggle_sound = 'sound/items/wirecutter.ogg'

/obj/machinery/camera/Initialize(mapload, list/network, c_tag, obj/item/camera_assembly/input_assembly)
	. = ..()
	wires = new(src)
	if(input_assembly)
		assembly = input_assembly
	else
		assembly = new(src)
	assembly.state = 4
	assembly.set_anchored(TRUE)
	assembly.update_icon(UPDATE_ICON_STATE)
	if(network)
		src.network = network
	if(c_tag)
		src.c_tag = c_tag

	GLOB.cameranet.cameras += src
	for(var/obj/item/upgrade as anything in assembly.upgrades)
		upgrade.camera_upgrade(src)

	var/list/tempnetwork = difflist(src.network, GLOB.restricted_camera_networks)
	if(tempnetwork.len)
		GLOB.cameranet.addCamera(src)
	else
		GLOB.cameranet.removeCamera(src)
	if(isturf(loc))
		LAZYADD(myArea.cameras, UID())
	if(is_station_level(z) && prob(3) && !start_active)
		toggle_cam(null, FALSE)
		wires.cut_all()

/obj/machinery/camera/Destroy()
	SStgui.close_uis(wires)
	QDEL_NULL(assembly)
	QDEL_NULL(wires)
	GLOB.cameranet.removeCamera(src) //Will handle removal from the camera network and the chunks, so we don't need to worry about that
	GLOB.cameranet.cameras -= src
	if(isarea(myArea))
		LAZYREMOVE(myArea.cameras, UID())
	cancelCameraAlarm()
	cancelAlarm()
	LAZYCLEARLIST(computers_watched_by)
	return ..()

/obj/machinery/camera/emp_act(severity)
	if(!status)
		return
	if(!isEmpProof())
		if(prob(150/severity))
			stat |= EMPED
			set_light_on(FALSE)
			update_icon(UPDATE_ICON_STATE)

			GLOB.cameranet.removeCamera(src)

			addtimer(CALLBACK(src, PROC_REF(triggerCameraAlarm)), 10 SECONDS, TIMER_UNIQUE|TIMER_DELETE_ME)
			addtimer(CALLBACK(src, PROC_REF(restore_from_emp)), 90 SECONDS, TIMER_UNIQUE|TIMER_OVERRIDE|TIMER_DELETE_ME)
			..()

/obj/machinery/camera/proc/restore_from_emp()
	stat &= ~EMPED
	update_icon(UPDATE_ICON_STATE)

	if(can_use())
		GLOB.cameranet.addCamera(src)

	cancelCameraAlarm()

/obj/machinery/camera/tesla_act(power)//EMP proof upgrade also makes it tesla immune
	if(isEmpProof())
		return
	..()
	qdel(src)//to prevent bomb testing camera from exploding over and over forever

/obj/machinery/camera/ex_act(severity)
	if(invuln)
		return
	..()

/obj/machinery/camera/proc/setViewRange(num = 7)
	view_range = num
	GLOB.cameranet.updateVisibility(src, opacity_check = FALSE)

/obj/machinery/camera/singularity_pull(S, current_size)
	if (status && current_size >= STAGE_FIVE) // If the singulo is strong enough to pull anchored objects and the camera is still active, turn off the camera as it gets ripped off the wall.
		toggle_cam(null, 0)
	..()


/obj/machinery/camera/attackby(obj/item/I, mob/living/user, params)
	if(user.a_intent == INTENT_HARM)
		return ..()

	if(panel_open && is_type_in_list(I, assembly.possible_upgrades))
		if(is_type_in_list(I, assembly.upgrades))
			to_chat(user, span_notice("The camera already has that upgrade!"))
			return ATTACK_CHAIN_PROCEED
		if(isstack(I))
			if(!I.use(1))
				to_chat(user, span_warning("You need more of [I]."))
				return ATTACK_CHAIN_PROCEED
			var/obj/item/stack/new_stack = new(src, 1)
			assembly.upgrades += new_stack
			new_stack.camera_upgrade(src)
			to_chat(user, span_notice("You attach [new_stack] into the assembly inner circuits."))
			return ATTACK_CHAIN_PROCEED_SUCCESS
		if(!user.drop_transfer_item_to_loc(I, src))
			return ..()
		to_chat(user, span_notice("You attach [I] into the assembly inner circuits."))
		assembly.upgrades += I
		I.camera_upgrade(src)
		return ATTACK_CHAIN_BLOCKED_ALL

	// OTHER
	var/is_paper = istype(I, /obj/item/paper)
	if(is_paper || is_pda(I))
		if(!can_use())
			to_chat(user, span_warning("You can't show something to a disabled camera!"))
			return ATTACK_CHAIN_PROCEED

		var/itemname = ""
		var/info = ""
		if(is_paper)
			var/obj/item/paper/paper = I
			itemname = paper.name
			info = paper.info
		else
			var/obj/item/pda/PDA = I
			itemname = PDA.name
			var/datum/data/pda/app/notekeeper/notekeeper = PDA.find_program(/datum/data/pda/app/notekeeper)
			if(notekeeper)
				info = notekeeper.note

		to_chat(user, "You hold the [itemname] up to the camera ...")

		for(var/mob/living/silicon/ai/AI as anything in GLOB.ai_list)
			if(AI.control_disabled || (AI.stat == DEAD))
				continue
			if(user.name == "Unknown")
				to_chat(AI, "<b>[user]</b> holds <a href='byond://?_src_=usr;show_paper=1;'>the [itemname]</a> up to one of your cameras ...")
			else
				to_chat(AI, "<b><a href='byond://?src=[AI.UID()];track=[html_encode(user.name)]'>[user]</a></b> holds <a href='byond://?_src_=usr;show_paper=1;'>the [itemname]</a> up to one of your cameras ...")
			AI.last_paper_seen = {"<HTML><meta charset="UTF-8"><HEAD><TITLE>[itemname]</TITLE></HEAD><BODY><TT>[info]</TT></BODY></HTML>"}

		for(var/obj/machinery/computer/security/console as anything in computers_watched_by)
			for(var/uid_watcher as anything in console.watchers)
				var/watcher = locateUID(uid_watcher)
				to_chat(watcher, "[user] holds the [itemname] up to one of the cameras ...")
				watcher << browse(text({"<HTML><meta charset="UTF-8"><HEAD><TITLE>[]</TITLE></HEAD><BODY><TT>[]</TT></BODY></HTML>"}, itemname, info), text("window=[]", itemname))

		return ATTACK_CHAIN_PROCEED_SUCCESS

	if(istype(I, /obj/item/laser_pointer))
		var/obj/item/laser_pointer/laser = I
		laser.laser_act(src, user, params)
		return ATTACK_CHAIN_PROCEED_SUCCESS

	return ..()


/obj/machinery/camera/screwdriver_act(mob/user, obj/item/I)
	. = TRUE
	if(!I.use_tool(src, user, 0, volume = I.tool_volume))
		return
	panel_open = !panel_open
	to_chat(user, span_notice("You screw [src]'s panel [panel_open ? "open" : "closed"]."))

/obj/machinery/camera/wirecutter_act(mob/user, obj/item/I)
	. = TRUE
	if(!I.use_tool(src, user, 0, volume = 0))
		return
	if(panel_open)
		wires.Interact(user)

/obj/machinery/camera/multitool_act(mob/user, obj/item/I)
	. = TRUE
	if(!I.use_tool(src, user, 0, volume = 0))
		return
	if(panel_open)
		wires.Interact(user)

/obj/machinery/camera/welder_act(mob/user, obj/item/I)
	if(!panel_open || !wires.CanDeconstruct())
		return
	. = TRUE
	if(!I.tool_use_check(user, 0))
		return
	WELDER_ATTEMPT_WELD_MESSAGE
	if(I.use_tool(src, user, 100, volume = I.tool_volume))
		visible_message(span_warning("[user] unwelds [src], leaving it as just a frame bolted to the wall."),
						span_warning("You unweld [src], leaving it as just a frame bolted to the wall"))
		deconstruct(TRUE)

/obj/machinery/camera/run_obj_armor(damage_amount, damage_type, damage_flag = 0, attack_dir)
	if(stat & BROKEN)
		return damage_amount
	. = ..()

/// Camera upgrading stuff.
/obj/item/proc/camera_upgrade(obj/machinery/camera/target, power_use_update = FALSE)
	target.setPowerUsage()


/obj/item/analyzer/camera_upgrade(obj/machinery/camera/target, power_use_update = TRUE)
	..()
	target.update_icon(UPDATE_ICON_STATE)
	//Update what it can see.
	GLOB.cameranet.updateVisibility(target, opacity_check = FALSE)


/obj/item/assembly/prox_sensor/camera_upgrade(obj/machinery/camera/target, power_use_update = TRUE)
	..()
	if(target.name == initial(target.name))
		target.update_appearance(UPDATE_NAME)
	// Add it to machines that process
	START_PROCESSING(SSmachines, target)
	target.AddComponent(/datum/component/proximity_monitor, target.view_range, TRUE)

/obj/machinery/camera/update_name(updates)
	. = ..()
	if(isMotion())
		name = "motion-sensitive security camera"
	else
		name = "security camera"



/obj/machinery/camera/obj_break(damage_flag)
	if(status && !(obj_flags & NODECONSTRUCT))
		triggerCameraAlarm()
		toggle_cam(null, FALSE)
		wires.cut_all()

/obj/machinery/camera/deconstruct(disassembled = TRUE)
	if(!(obj_flags & NODECONSTRUCT))
		if(disassembled)
			if(!assembly)
				assembly = new()
			assembly.forceMove(drop_location())
			assembly.state = 1
			assembly.setDir(dir)
			assembly.update_icon(UPDATE_ICON_STATE)
			assembly = null
		else
			var/obj/item/I = new /obj/item/camera_assembly(loc)
			I.obj_integrity = I.max_integrity * 0.5
			new /obj/item/stack/cable_coil(loc, 2)
	qdel(src)


/obj/machinery/camera/update_icon_state()
	icon_state = isXRay() ? "xray[initial(icon_state)]" : initial(icon_state)
	if(!status)
		icon_state = "[icon_state]1"
	else if(stat & EMPED)
		icon_state = "[icon_state]emp"

/obj/machinery/camera/proc/toggle_cam(mob/user, displaymessage = TRUE)
	status = !status
	if(can_use())
		GLOB.cameranet.addCamera(src)
		if(isturf(loc))
			myArea = get_area(src)
			LAZYADD(myArea.cameras, UID())
		else
			myArea = null
	else
		set_light_on(FALSE)
		GLOB.cameranet.removeCamera(src)
		if(isarea(myArea))
			LAZYREMOVE(myArea.cameras, UID())
	// We are not guarenteed that the camera will be on a turf. account for that
	var/turf/our_turf = get_turf(src)
	GLOB.cameranet.updateChunk(our_turf.x, our_turf.y, our_turf.z)
	var/change_msg = "deactivates"
	if(status)
		change_msg = "reactivates"
		cancelCameraAlarm()
	else
		addtimer(CALLBACK(src, PROC_REF(triggerCameraAlarm)), 10 SECONDS, TIMER_DELETE_ME)
	if(displaymessage)
		if(user)
			visible_message(span_danger("[user] [change_msg] [src]!"))
			add_hiddenprint(user)
		else
			visible_message(span_danger("\The [src] [change_msg]!"))

		playsound(loc, toggle_sound, 100, 1)
	update_icon(UPDATE_ICON_STATE)

/obj/machinery/camera/proc/triggerCameraAlarm()
	if(status || alarm_on || (assembly && assembly.state == 1)) // checks if camera still off OR alarms already on OR camera disasembled
		return
	alarm_on = TRUE
	SSalarm.triggerAlarm("Camera", get_area(src), list(UID()), src)

/obj/machinery/camera/proc/cancelCameraAlarm()
	if (!alarm_on) // you don't have to turn off alarm twice
		return
	alarm_on = FALSE
	SSalarm.cancelAlarm("Camera", get_area(src), src)

/obj/machinery/camera/proc/can_use()
	if(!status)
		return 0
	if(stat & EMPED)
		return 0
	return 1

/obj/machinery/camera/proc/camera_see()
	var/list/see = null
	var/turf/pos = get_turf(src)
	var/turf/directly_above = GET_TURF_ABOVE(pos)
	var/check_lower = pos != get_lowest_turf(pos)
	var/check_higher = directly_above && directly_above.transparent_floor && (pos != get_highest_turf(pos))

	if(isXRay())
		see = range(view_range, pos)
	else
		see = hear(view_range, pos)
	if(check_lower || check_higher)
		for(var/turf/seen in see)
			if(check_lower)
				var/turf/visible = seen
				while(visible && visible.transparent_floor)
					var/turf/below = GET_TURF_BELOW(visible)
					for(var/turf/adjacent in range(1, below))
						see += adjacent
						see += adjacent.contents
					visible = below
			if(check_higher)
				var/turf/above = GET_TURF_ABOVE(seen)
				while(above && above.transparent_floor)
					for(var/turf/adjacent in range(1, above))
						see += adjacent
						see += adjacent.contents
					above = GET_TURF_ABOVE(above)
	return see

/obj/machinery/camera/proc/update_computers_watched_by()
	for(var/obj/machinery/computer/security/computer as anything in computers_watched_by)
		computer.update_camera_view()

/atom/proc/auto_turn()
	//Automatically turns based on nearby walls.
	var/turf/simulated/wall/T = null
	for(var/i = 1, i <= 8; i += i)
		T = get_ranged_target_turf(src, i, 1)
		if(istype(T))
			//If someone knows a better way to do this, let me know. -Giacom
			switch(i)
				if(NORTH)
					setDir(SOUTH)
				if(SOUTH)
					setDir(NORTH)
				if(WEST)
					setDir(EAST)
				if(EAST)
					setDir(WEST)
			break

//Return a working camera that can see a given mob
//or null if none
/proc/seen_by_camera(mob/M)
	for(var/obj/machinery/camera/C in oview(4, M))
		if(C.can_use())	// check if camera disabled
			return C
	return null

/proc/near_range_camera(mob/M)
	for(var/obj/machinery/camera/C in range(4, M))
		if(C.can_use())	// check if camera disabled
			return C
	return null

/obj/machinery/camera/proc/Togglelight(on = FALSE)
	for(var/mob/living/silicon/ai/A in GLOB.ai_list)
		for(var/obj/machinery/camera/cam in A.lit_cameras)
			if(cam == src)
				return
	if(on)
		set_light(AI_CAMERA_LUMINOSITY, l_on = TRUE)
	else
		set_light(0)

/obj/machinery/camera/proc/nano_structure()
	var/cam[0]
	var/turf/T = get_turf(src)
	cam["name"] = sanitize(c_tag)
	cam["deact"] = !can_use()
	cam["camera"] = "\ref[src]"
	if(T)
		cam["x"] = T.x
		cam["y"] = T.y
		cam["z"] = T.z
	else
		cam["x"] = 0
		cam["y"] = 0
		cam["z"] = 0
	return cam

/obj/machinery/camera/get_remote_view_fullscreens(mob/user)
	if(view_range == short_range) //unfocused
		user.overlay_fullscreen("remote_view", /atom/movable/screen/fullscreen/impaired, 2)

/obj/machinery/camera/update_remote_sight(mob/living/user)
	if(isXRay() && isAI(user))
		user.add_sight(SEE_TURFS|SEE_MOBS|SEE_OBJS)
		user.nightvision = max(user.nightvision, 8)
		user.lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_INVISIBLE
	else
		user.set_sight(initial(user.sight))
		user.nightvision = initial(user.nightvision)
		user.lighting_alpha = initial(user.lighting_alpha)

	..()
	return TRUE

/obj/machinery/camera/portable //Cameras which are placed inside of things, such as helmets.
	var/turf/prev_turf

/obj/machinery/camera/portable/Initialize(mapload, list/network, c_tag, obj/item/camera_assembly/input_assembly)
	. = ..()
	assembly.state = 0 //These cameras are portable, and so shall be in the portable state if removed.
	assembly.set_anchored(FALSE)
	assembly.update_icon(UPDATE_ICON_STATE)

/obj/machinery/camera/portable/process() //Updates whenever the camera is moved.
	if(GLOB.cameranet && get_turf(src) != prev_turf)
		GLOB.cameranet.updatePortableCamera(src)
		prev_turf = get_turf(src)

/obj/machinery/camera/portable/triggerCameraAlarm() // AI camera doesnt trigger alarm
	return
