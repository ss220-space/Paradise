//use this define to highlight docking port bounding boxes (ONLY FOR DEBUG USE)
// also uncomment the #undef at the bottom of the file
//#define DOCKING_PORT_HIGHLIGHT

//NORTH default dir
/obj/docking_port
	invisibility = INVISIBILITY_ABSTRACT
	icon = 'icons/obj/device.dmi'
	//icon = 'icons/dirsquare.dmi'
	icon_state = "pinonfar"

	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF
	anchored = TRUE

	var/id
	// this should point -away- from the dockingport door, ie towards the ship
	dir = NORTH
	///size of covered area, perpendicular to dir
	var/width = 0
	///size of covered area, parallel to dir
	var/height = 0
	///position relative to covered area, perpendicular to dir
	var/dwidth = 0
	///position relative to covered area, parallel to dir
	var/dheight = 0

	// A timid shuttle will not register itself with the shuttle subsystem
	// All shuttle templates are timid
	var/timid = FALSE

	var/list/ripples = list()
	///Are we invisible to shuttle navigation computers?
	var/hidden = FALSE

	//these objects are indestructible
/obj/docking_port/Destroy(force)
	// unless you assert that you know what you're doing. Horrible things
	// may result.
	if(force)
		..()
		return QDEL_HINT_QUEUE
	else
		return QDEL_HINT_LETMELIVE

/obj/docking_port/has_gravity(turf/T)
	return FALSE

/obj/docking_port/take_damage()
	return

/obj/docking_port/singularity_pull(atom/singularity, current_size)
	return

/obj/docking_port/singularity_act()
	return FALSE

/obj/docking_port/shuttleRotate()
	return //we don't rotate with shuttles via this code.

//returns a list(x0,y0, x1,y1) where points 0 and 1 are bounding corners of the projected rectangle
/obj/docking_port/proc/return_coords(_x, _y, _dir)
	if(_dir == null)
		_dir = dir
	if(_x == null)
		_x = x
	if(_y == null)
		_y = y

	//byond's sin and cos functions are inaccurate. This is faster and perfectly accurate
	var/cos = 1
	var/sin = 0
	switch(_dir)
		if(WEST)
			cos = 0
			sin = 1
		if(SOUTH)
			cos = -1
			sin = 0
		if(EAST)
			cos = 0
			sin = -1

	return list(
		_x + (-dwidth*cos) - (-dheight*sin),
		_y + (-dwidth*sin) + (-dheight*cos),
		_x + (-dwidth+width-1)*cos - (-dheight+height-1)*sin,
		_y + (-dwidth+width-1)*sin + (-dheight+height-1)*cos
		)

///returns turfs within our projected rectangle in no particular order
/obj/docking_port/proc/return_turfs()
	var/list/coords = return_coords()
	return block(
		coords[1], coords[2], z,
		coords[3], coords[4], z
	)

///returns turfs within our projected rectangle in a specific order.this ensures that turfs are copied over in the same order, regardless of any rotation
/obj/docking_port/proc/return_ordered_turfs(_x, _y, _z, _dir, area/A)
	if(!_dir)
		_dir = dir
	if(!_x)
		_x = x
	if(!_y)
		_y = y
	if(!_z)
		_z = z
	var/cos = 1
	var/sin = 0
	switch(_dir)
		if(WEST)
			cos = 0
			sin = 1
		if(SOUTH)
			cos = -1
			sin = 0
		if(EAST)
			cos = 0
			sin = -1

	. = list()

	var/xi
	var/yi
	for(var/dx=0, dx<width, ++dx)
		for(var/dy=0, dy<height, ++dy)
			xi = _x + (dx-dwidth)*cos - (dy-dheight)*sin
			yi = _y + (dy-dheight)*cos + (dx-dwidth)*sin
			var/turf/T = locate(xi, yi, _z)
			if(A)
				if(get_area(T) == A)
					. += T
				else
					. += null
			else
				. += T

#ifdef DOCKING_PORT_HIGHLIGHT

///Debug proc used to highlight bounding area
/obj/docking_port/proc/highlight(_color = "#f00")
	invisibility = 0
	SET_PLANE_IMPLICIT(src, GHOST_PLANE)
	var/list/coords = return_coords()
	for(var/turf/T in block(coords[1], coords[2], z, coords[3], coords[4], z))
		T.color = _color
		T.maptext = null
	if(_color)
		var/turf/T = locate(coords[1], coords[2], z)
		T.color = "#0f0"
		T = locate(coords[3], coords[4], z)
		T.color = "#00f"

#endif

//return first-found touching dockingport
/obj/docking_port/proc/get_docked()
	return locate(/obj/docking_port/stationary) in loc

/obj/docking_port/proc/getDockedId()
	var/obj/docking_port/P = get_docked()
	if(P)
		return P.id

/obj/docking_port/proc/register()
	return 0

/obj/docking_port/stationary
	name = "dock"

	var/turf_type = /turf/baseturf_bottom
	var/area_type = /area/space
	var/last_dock_time

	var/lock_shuttle_doors = FALSE

	var/overmap_dock_mode = OVERMAP_DOCK_MANUAL
	var/overmap_dock_label
	var/overmap_host_uid
	var/obj/machinery/door/airlock/external/docking/dock_airlock

// Preset for adding whiteship docks to ruins. Has widths preset which will auto-assign the shuttle
/obj/docking_port/stationary/whiteship
	dwidth = 8
	height = 31
	width = 17

/obj/docking_port/stationary/register()
	if(!SSshuttle)
		stack_trace("Docking port [src] could not initialize. SSshuttle doesnt exist!")
		return FALSE

	SSshuttle.stationary |= src
	if(!id)
		id = "[length(SSshuttle.stationary)]"
	if(SSshuttle.assoc_stationary[id] && SSshuttle.assoc_stationary[id] != src)
		stack_trace("Duplicate stationary dock id [id]")
	SSshuttle.assoc_stationary[id] = src
	if(name == "dock")
		name = "dock[length(SSshuttle.stationary)]"

	#ifdef DOCKING_PORT_HIGHLIGHT
	highlight("#f00")
	#endif
	apply_overmap_dock_role()
	return 1

/obj/docking_port/stationary/proc/apply_overmap_dock_role()
	if(dock_airlock)
		overmap_dock_mode = OVERMAP_DOCK_MANUAL
		if(!overmap_dock_label)
			overmap_dock_label = dock_airlock.dock_name || (name != "dock" && name) || id
		return
	if(istype(src, /obj/docking_port/stationary/overmap))
		if(!overmap_dock_label)
			overmap_dock_label = (name != "dock" && name) || id
		return
	overmap_dock_mode = OVERMAP_DOCK_RESERVED
	overmap_dock_label = "Зарезервированная область"

/obj/docking_port/stationary/Destroy(force)
	if(force)
		if(SSshuttle?.assoc_stationary[id] == src)
			SSshuttle.assoc_stationary -= id
		SSshuttle?.stationary -= src
	return ..()

//returns first-found touching shuttleport
/obj/docking_port/stationary/get_docked()
	return locate(/obj/docking_port/mobile) in loc

/obj/docking_port/stationary/proc/is_overmap_host_mobile(obj/docking_port/mobile/other)
	if(!other || !dock_airlock || QDELETED(dock_airlock))
		return FALSE
	if(other.overmap_collar == dock_airlock)
		return TRUE
	var/area/airlock_area = get_area(dock_airlock)
	if(airlock_area && (airlock_area == other.areaInstance || (other.shuttle_areas && other.shuttle_areas[airlock_area])))
		return TRUE
	return FALSE

/obj/docking_port/stationary/transit
	name = "In transit"
	turf_type = /turf/space/transit
	var/datum/turf_reservation/reserved_area
	var/area/shuttle/transit/assigned_area
	lock_shuttle_doors = TRUE
	var/obj/docking_port/mobile/owner

/obj/docking_port/stationary/transit/register()
	if(!..())
		return 0

	name = "In transit" //This looks weird, but- it means that the on-map instances can be named something actually usable to search for, but still appear correctly in terminals.

	SSshuttle.transit += src
	return 1

/obj/docking_port/stationary/transit/Destroy(force=FALSE)
	if(force)
		SSshuttle.transit -= src
		if(owner)
			if(owner.assigned_transit == src)
				owner.assigned_transit = null
			owner = null
		if(!QDELETED(reserved_area))
			qdel(reserved_area)
		reserved_area = null
	return ..()

/obj/docking_port/mobile
	icon_state = "mobile"
	name = "shuttle"
	icon_state = "pinonclose"

	var/area/shuttle/areaInstance
	var/list/shuttle_areas

	var/fly_sound = 'sound/effects/hyperspace_mini.ogg'

	var/timer						//used as a timer (if you want time left to complete move, use timeLeft proc)
	var/last_timer_length
	/// current shuttle state
	var/mode = SHUTTLE_IDLE
	/// force lock shuttle moving
	var/locked_move = FALSE
	/// time recharging before ready to launch again
	var/rechargeTime = 5 SECONDS
	/// time spent in transit (deciseconds)
	var/callTime = 5 SECONDS
	/// time spent "starting the engines". Also rate limits how often we try to reserve transit space if its ever full of transiting shuttles.
	/// DO NOT set under 3 seconds. We need to reserve space before we can launch the shuttle. Also it'll break launch sound(not by not playing. it'll be unsynced)
	var/ignitionTime = 3 SECONDS
	/// id of port to send shuttle to at roundstart
	var/roundstart_move
	/// can build new shuttle consoles for this one
	var/rebuildable = 0
	/// Doesn't throw runtimes if can't find the dock. Used by away shuttles(example ussp shuttle) which cannot get docks loaded in map.
	var/alone_shuttle = FALSE

	/// The direction the shuttle prefers to travel in, ie what direction the animation will cause it to appear to be traveling in
	var/preferred_direction = NORTH
	/// relative direction of the docking port from the front of the shuttle.
	/// Meaning, if port located at: front = NORTH, left side = WEST, right side = EAST, backside = SOUTH.
	var/port_direction = NORTH

	/// Who called the shuttle the last time
	var/mob/last_caller

	var/obj/docking_port/stationary/destination
	var/obj/docking_port/stationary/previous
	var/obj/docking_port/stationary/transit/assigned_transit
	var/overmap_force_dock = FALSE
	var/obj/machinery/door/airlock/external/docking/overmap_collar
	var/mapped_width
	var/mapped_height
	var/mapped_dwidth
	var/mapped_dheight
	var/shuttle_fit
	var/transfer_busy = FALSE

/obj/docking_port/mobile/Initialize(mapload)
	. = ..()

	var/area/A = get_area(src)
	if(is_area_shuttle(A))
		areaInstance = A

	if(!areaInstance)
		areaInstance = new()
		areaInstance.name = name
		areaInstance.contents += return_ordered_turfs()

	areaInstance.parallax_movedir = preferred_direction

	#ifdef DOCKING_PORT_HIGHLIGHT
	highlight("#0f0")
	#endif

	if(!timid)
		register()
	shuttle_areas = list()
	if(areaInstance)
		shuttle_areas[areaInstance] = TRUE
	var/obj/machinery/door/airlock/external/docking/door = locate() in loc
	if(door && !door.overmap_is_support)
		overmap_collar = door
	overmap_discover_shuttle_areas()
	if(overmap_collar)
		shuttle_fit = SHUTTLE_FIT_HULL
	mapped_width = width
	mapped_height = height
	mapped_dwidth = dwidth
	mapped_dheight = dheight
	return INITIALIZE_HINT_LATELOAD

/obj/docking_port/mobile/LateInitialize()
	. = ..()
	var/obj/machinery/door/airlock/external/docking/door = locate() in loc
	if(door && !door.overmap_is_support)
		overmap_collar = door
	else if(!overmap_collar || QDELETED(overmap_collar))
		if(areaInstance)
			for(var/obj/machinery/door/airlock/external/docking/airlock in areaInstance)
				if(airlock.overmap_is_support)
					continue
				overmap_collar = airlock
				break
	overmap_discover_shuttle_areas()
	if(overmap_collar)
		shuttle_fit = SHUTTLE_FIT_HULL

/obj/docking_port/mobile/register()
	if(!SSshuttle)
		CRASH("Docking port [src] could not initialize. SSshuttle doesnt exist!")

	SSshuttle.mobile += src
	if(!id)
		id = "[length(SSshuttle.mobile)]"
	if(SSshuttle.assoc_mobile[id] && SSshuttle.assoc_mobile[id] != src)
		stack_trace("Duplicate mobile shuttle id [id]")
	SSshuttle.assoc_mobile[id] = src
	if(name == "shuttle")
		name = "shuttle[length(SSshuttle.mobile)]"

	return 1

/obj/docking_port/mobile/Destroy(force)
	if(force)
		SSshuttle.mobile -= src
		if(SSshuttle.assoc_mobile[id] == src)
			SSshuttle.assoc_mobile -= id
		areaInstance = null
		destination = null
		previous = null
		QDEL_NULL(assigned_transit) //don't need it where we're goin'!
		shuttle_areas = null
	return ..()

//this is a hook for custom behaviour. Maybe at some point we could add checks to see if engines are intact
/obj/docking_port/mobile/proc/canMove()
	if(SEND_SIGNAL(src, COMSIG_SHUTTLE_SHOULD_MOVE) & BLOCK_SHUTTLE_MOVE)
		return FALSE
	return TRUE

/obj/docking_port/mobile/proc/uses_hull_fit()
	switch(shuttle_fit)
		if(SHUTTLE_FIT_AABB)
			return FALSE
		if(SHUTTLE_FIT_HULL)
			return TRUE
	return overmap_uses_area_hull()

/obj/docking_port/mobile/proc/canDock(obj/docking_port/stationary/S)
	if(locked_move)
		return SHUTTLE_LOCKED
	if(!istype(S))
		return SHUTTLE_NOT_A_DOCKING_PORT
	if(istype(S, /obj/docking_port/stationary/transit))
		return SHUTTLE_CAN_DOCK
	if(overmap_force_dock)
		if(S.get_docked() == src)
			return SHUTTLE_ALREADY_DOCKED
		return SHUTTLE_CAN_DOCK
	var/hull_fit = uses_hull_fit() || S.dock_airlock || istype(S, /obj/docking_port/stationary/overmap)
	if(!hull_fit)
		if(dwidth > S.dwidth)
			return SHUTTLE_DWIDTH_TOO_LARGE
		if(width-dwidth > S.width-S.dwidth)
			return SHUTTLE_WIDTH_TOO_LARGE
		if(dheight > S.dheight)
			return SHUTTLE_DHEIGHT_TOO_LARGE
		if(height-dheight > S.height-S.dheight)
			return SHUTTLE_HEIGHT_TOO_LARGE
	var/turf/pad_turf = get_turf(S)
	if(pad_turf)
		for(var/obj/docking_port/mobile/other in pad_turf)
			if(other == src)
				return SHUTTLE_ALREADY_DOCKED
			if(S.is_overmap_host_mobile(other))
				continue
			if(hull_fit)
				var/obj/docking_port/stationary/their_pad = other.get_docked()
				if(their_pad && their_pad != S)
					continue
			return SHUTTLE_SOMEONE_ELSE_DOCKED
	if(hull_fit || S.overmap_host_uid)
		if(overmap_hull_blocked(S))
			return SHUTTLE_LANDING_BLOCKED
	return SHUTTLE_CAN_DOCK

/obj/docking_port/mobile/proc/overmap_dest_tile_blocked(turf/newT, obj/docking_port/stationary/S)
	if(!newT || newT.x <= 1 || newT.y <= 1 || newT.x >= world.maxx || newT.y >= world.maxy)
		return TRUE
	if(shuttle_areas && shuttle_areas[newT.loc])
		return FALSE
	if(istype(S, /obj/docking_port/stationary/overmap/landing) && overmap_lavaland_landing_blocked(newT))
		return TRUE
	if(isclosedturf(newT))
		return TRUE
	var/area/dest_area = get_area(newT)
	if(is_area_shuttle(dest_area) && !(shuttle_areas && shuttle_areas[dest_area]))
		return TRUE
	for(var/obj/obstacle in newT)
		if(!obstacle.density || !obstacle.anchored)
			continue
		if(istype(obstacle, /obj/docking_port))
			continue
		if(istype(obstacle, /obj/machinery/landing_beacon))
			continue
		if(istype(obstacle, /obj/machinery/door/airlock))
			var/obj/machinery/door/airlock/dock_door = obstacle
			if(dock_door.id_tag == S.id)
				continue
		return TRUE
	return FALSE

/obj/docking_port/mobile/proc/check_dock(obj/docking_port/stationary/S)
	var/status = canDock(S)
	if(status == SHUTTLE_LOCKED)
		return FALSE
	if(status == SHUTTLE_CAN_DOCK)
		return TRUE
	else if(status == SHUTTLE_ALREADY_DOCKED)
		// We're already docked there, don't need to do anything.
		// Triggering shuttle movement code in place is weird
		return FALSE
	else if(overmap_force_dock)
		return TRUE
	else if(status == SHUTTLE_LANDING_BLOCKED || status == SHUTTLE_SOMEONE_ELSE_DOCKED)
		return FALSE
	else if(status == SHUTTLE_DWIDTH_TOO_LARGE || status == SHUTTLE_WIDTH_TOO_LARGE || status == SHUTTLE_DHEIGHT_TOO_LARGE || status == SHUTTLE_HEIGHT_TOO_LARGE)
		return FALSE
	else
		var/msg = "check_dock(): shuttle [src] cannot dock at [S], error: [status]"
		message_admins(msg)
		stack_trace(msg)
		return FALSE

/obj/docking_port/mobile/proc/transit_failure()
	message_admins("Shuttle [src] repeatedly failed to create transit zone.")

//call the shuttle to destination S
/obj/docking_port/mobile/proc/request(obj/docking_port/stationary/S, force = FALSE)
	if(locked_move)
		return FALSE

	if(force)
		overmap_force_dock = TRUE
	if(!check_dock(S))
		return TRUE

	switch(mode)
		if(SHUTTLE_CALL)
			if(S == destination)
				if(timeLeft(1) < callTime)
					setTimer(callTime)
			else
				destination = S
				setTimer(callTime)
		if(SHUTTLE_RECALL)
			if(S == destination)
				setTimer(callTime - timeLeft(1))
			else
				destination = S
				setTimer(callTime)
			mode = SHUTTLE_CALL
		if(SHUTTLE_IDLE, SHUTTLE_IGNITING, SHUTTLE_RECHARGING)
			destination = S
			mode = SHUTTLE_IGNITING
			SEND_SIGNAL(src, COMSIG_SHUTTLE_IGNITION)
			setTimer(ignitionTime)
	return FALSE

//recall the shuttle to where it was previously
/obj/docking_port/mobile/proc/cancel()
	if(mode != SHUTTLE_CALL)
		return

	invertTimer()
	mode = SHUTTLE_RECALL

/obj/docking_port/mobile/proc/enterTransit()
	. = FALSE
	previous = null
	var/obj/docking_port/stationary/S0 = get_docked()
	var/obj/docking_port/stationary/S1 = assigned_transit
	if(S1)
		if(dock(S1, transit = TRUE))
			WARNING("shuttle \"[id]\" could not enter transit space. Docked at [S0 ? S0.id : "null"]. Transit dock [S1 ? S1.id : "null"].")
		else
			previous = S0
			SEND_SIGNAL(src, COMSIG_SHUTTLE_TRANSIT, S1)
			return TRUE
	else
		WARNING("shuttle \"[id]\" could not enter transit space. S0=[S0 ? S0.id : "null"] S1=[S1 ? S1.id : "null"]")

/obj/docking_port/mobile/proc/jumpToNullSpace()
	// Destroys the docking port and the shuttle contents.
	// Not in a fancy way, it just ceases.
	var/obj/docking_port/stationary/S0 = get_docked()
	var/turf_type = /turf/space
	var/area_type = /area/space
	if(S0)
		if(S0.turf_type)
			turf_type = S0.turf_type
		if(S0.area_type)
			area_type = S0.area_type

	var/list/L0 = return_ordered_turfs(x, y, z, dir, areaInstance)

	//remove area surrounding docking port
	if(length(areaInstance.contents))
		var/area/A0 = locate(area_type)
		if(!A0)
			A0 = new area_type(null)
		for(var/turf/T0 in L0)
			A0.contents += T0

	for(var/i in L0)
		var/turf/T0 = i
		if(!T0)
			continue
		T0.empty(turf_type)

	qdel(src, force=TRUE)

/obj/docking_port/mobile/proc/create_ripples(obj/docking_port/stationary/S1)
	var/list/turfs = ripple_area(S1)
	for(var/i in turfs)
		ripples += new /obj/effect/temp_visual/ripple(i)

/obj/docking_port/mobile/proc/remove_ripples()
	if(length(ripples))
		for(var/i in ripples)
			qdel(i)
		ripples.Cut()

/obj/docking_port/mobile/proc/ripple_area(obj/docking_port/stationary/new_dock)
	var/list/old_turfs = return_ordered_turfs(x, y, z, dir, areaInstance)
	var/list/new_turfs = return_ordered_turfs(new_dock.x, new_dock.y, new_dock.z, new_dock.dir)

	var/list/ripple_turfs = list()

	for(var/i in 1 to length(old_turfs))
		var/turf/oldT = old_turfs[i]
		if(!oldT)
			continue
		var/turf/newT = new_turfs[i]
		if(!newT)
			continue
		if(oldT.type != oldT.baseturf)
			ripple_turfs += newT

	return ripple_turfs

/obj/docking_port/mobile/proc/is_turf_blacklisted_for_transit(turf/T)
	var/static/list/blacklisted_turf_types = typecacheof(GLOB.blacklisted_turf_types_for_transit)
	return is_type_in_typecache(T, blacklisted_turf_types)

/obj/docking_port/mobile/proc/findTransitDock()
	var/obj/docking_port/stationary/transit/T = SSshuttle.getDock("[id]_transit")
	if(T && check_dock(T))
		return T

/obj/docking_port/mobile/proc/findRoundstartDock()
	if(!roundstart_move)
		if(!alone_shuttle)
			WARNING("couldn't find roundstart dock for \"[name]\" with id: [id]")
		return
	var/obj/docking_port/stationary/S = SSshuttle.getDock(roundstart_move)
	if(S)
		return S
	if(!alone_shuttle)
		WARNING("couldn't find roundstart dock for \"[name]\" with id: [id]")

/obj/docking_port/mobile/proc/dockRoundstart()
	var/port = findRoundstartDock()
	if(port)
		return dock(port)

/obj/docking_port/mobile/proc/dock_id(id)
	var/port = SSshuttle.getDock(id)
	if(port)
		. = dock(port)
	else
		. = null

/obj/effect/landmark/shuttle_import
	name = "Shuttle Import"

//shuttle-door closing is handled in the dock() proc whilst looping through turfs
//this one closes the door where we are docked at, if there is one there.
/obj/docking_port/mobile/proc/closePortDoors(obj/docking_port/stationary/old_dock)
	if(!istype(old_dock) || isnull(old_dock.id))
		return
	for(var/obj/machinery/door/airlock/A as anything in GLOB.airlocks_by_id_tag[old_dock.id])
		A.close()
		A.lock()

/obj/docking_port/mobile/proc/unlockPortDoors(obj/docking_port/stationary/new_dock)
	if(!istype(new_dock) || isnull(new_dock.id))
		return
	for(var/obj/machinery/door/airlock/A as anything in GLOB.airlocks_by_id_tag[new_dock.id])
		if(A.locked)
			A.unlock(TRUE)

//used by shuttle subsystem to check timers
/obj/docking_port/mobile/proc/check()
	set waitfor = FALSE
	if(transfer_busy)
		return
	check_effects()

	if(mode == SHUTTLE_IGNITING)
		check_transit_zone()

	if(timeLeft(1) > 0)
		return
	// If we can't dock or we don't have a transit slot, wait for 20 ds,
	// then try again
	switch(mode)
		if(SHUTTLE_CALL)
			if(dock(destination, force = overmap_force_dock))
				setTimer(20)	//can't dock for some reason, try again in 2 seconds
				return
			if(rechargeTime)
				mode = SHUTTLE_RECHARGING
				setTimer(rechargeTime)
				return
		if(SHUTTLE_RECALL)
			if(dock(previous))
				setTimer(20)	//can't dock for some reason, try again in 2 seconds
				return
		if(SHUTTLE_IGNITING)
			if(enterTransit())
				if(destination == assigned_transit)
					mode = SHUTTLE_IDLE
					timer = 0
					destination = null
					return
				mode = SHUTTLE_CALL
				setTimer(callTime)
				return
	mode = SHUTTLE_IDLE
	timer = 0
	destination = null

/obj/docking_port/mobile/proc/check_effects()
	if(!length(ripples))
		if((mode == SHUTTLE_CALL) || (mode == SHUTTLE_RECALL))
			var/tl = timeLeft(1)
			if(tl <= SHUTTLE_RIPPLE_TIME)
				create_ripples(destination)
	var/obj/docking_port/stationary/S0 = get_docked()
	if(istype(S0, /obj/docking_port/stationary/transit) && timeLeft(1) <= PARALLAX_LOOP_TIME)
		if(istype(destination, /obj/docking_port/stationary/transit) || !destination)
			return
		for(var/place in shuttle_areas)
			var/area/shuttle/shuttle_area = place
			if(shuttle_area.parallax_movedir)
				parallax_slowdown()

/obj/docking_port/mobile/proc/parallax_slowdown()
	for(var/place in shuttle_areas)
		var/area/shuttle/shuttle_area = place
		shuttle_area.parallax_movedir = FALSE
	if(assigned_transit?.assigned_area)
		assigned_transit.assigned_area.parallax_movedir = FALSE
	var/list/L0 = return_ordered_turfs(x, y, z, dir)
	for(var/turf/T in L0)
		if(!T || !istype(T.loc, areaInstance.type))
			continue
		for(var/atom/movable/movable as anything in T)
			if(movable.client_mobs_in_contents)
				movable.update_parallax_contents()

/obj/docking_port/mobile/proc/check_transit_zone()
	if(assigned_transit)
		return TRANSIT_READY
	else
		SSshuttle.request_transit_dock(src)

/obj/docking_port/mobile/proc/setTimer(wait)
	timer = world.time + wait
	last_timer_length = wait

/obj/docking_port/mobile/proc/modTimer(multiple)
	var/time_remaining = timer - world.time
	if(time_remaining < 0 || !last_timer_length)
		return
	time_remaining *= multiple
	last_timer_length *= multiple
	setTimer(time_remaining)

/obj/docking_port/mobile/proc/invertTimer()
	if(!last_timer_length)
		return
	var/time_remaining = timer - world.time
	if(time_remaining > 0)
		var/time_passed = last_timer_length - time_remaining
		setTimer(time_passed)

//returns timeLeft
/obj/docking_port/mobile/proc/timeLeft(divisor)
	if(divisor <= 0)
		divisor = 10
	var/ds_remaining
	if(!timer)
		ds_remaining = callTime
	else
		ds_remaining = max(0, timer - world.time)

	. = round(ds_remaining / divisor, 1)

// returns 3-letter mode string, used by status screens and mob status panel
/obj/docking_port/mobile/proc/getModeStr()
	switch(mode)
		if(SHUTTLE_IGNITING)
			return "IGN"
		if(SHUTTLE_RECALL)
			return "RCL"
		if(SHUTTLE_CALL)
			return "ETA"
		if(SHUTTLE_DOCKED)
			return "ETD"
		if(SHUTTLE_ESCAPE)
			return "ESC"
		if(SHUTTLE_STRANDED)
			return "ERR"
	return ""

// returns 5-letter timer string, used by status screens and mob status panel
/obj/docking_port/mobile/proc/getTimerStr()
	if(mode == SHUTTLE_STRANDED)
		return "--:--"

	var/obj/overmap/entity/vessel = SSovermap?.shuttle_vessels[src]
	if(vessel?.programmed_mission)
		return vessel.programmed_mission.eta_string()

	var/timeleft = timeLeft()
	if(timeleft > 0)
		return "[add_zero(num2text((timeleft / 60) % 60),2)]:[add_zero(num2text(timeleft % 60), 2)]"
	else
		return "00:00"

/obj/docking_port/mobile/proc/getStatusText()
	var/obj/docking_port/stationary/dockedAt = get_docked()
	. = (dockedAt?.name) ? dockedAt.name : lowertext(UNKNOWN_STATUS_RUS)
	if(istype(dockedAt, /obj/docking_port/stationary/transit))
		var/obj/docking_port/stationary/dst
		if(mode == SHUTTLE_RECALL)
			dst = previous
		else
			dst = destination
		. = "В пути к [dst ? dst.name : lowertext(UNKNOWN_STATUS_RUS)]"
	else if(mode == SHUTTLE_RECHARGING)
		return "[dockedAt.name]"

/obj/machinery/computer/shuttle
	name = "Shuttle Console"
	icon_screen = "shuttle"
	icon_keyboard = "tech_key"
	req_access = list()
	circuit = /obj/item/circuitboard/shuttle
	var/destination
	var/shuttleId
	var/possible_destinations = ""
	var/admin_controlled
	var/lockdown_affected = FALSE
	var/max_connect_range = 7
	var/moved = FALSE	//workaround for nukie shuttle, hope I find a better way to do this...
	var/atom/movable/screen/map_view/camera/overmap_cam_screen
	var/datum/overmap_map_view/overmap_map_camera
	var/turf/overmap_last_map_turf
	var/overmap_map_zoom = 1
	var/list/atom/movable/screen/overmap_sensor_blip/overmap_contact_blips
	var/obj/overmap/entity/overmap_bound_vessel

/obj/machinery/computer/shuttle/Initialize(mapload, obj/item/circuitboard/shuttle/C)
	. = ..()
	if(istype(C))
		possible_destinations = C.possible_destinations
		shuttleId = C.shuttleId

	if(mapload)
		return INITIALIZE_HINT_LATELOAD

	connect()
	setup_programmed_overmap_console()

/obj/machinery/computer/shuttle/LateInitialize()
	connect()
	setup_programmed_overmap_console()

/obj/machinery/computer/shuttle/Destroy()
	GLOB.overmap_request_consoles -= src
	UnregisterSignal(SSdcs, COMSIG_GLOB_OVERMAP_VESSEL_REGISTERED)
	if(overmap_bound_vessel)
		UnregisterSignal(overmap_bound_vessel, list(COMSIG_OVERMAP_NOTICE, COMSIG_OVERMAP_MOVED, COMSIG_OVERMAP_DISPLAY_CHANGED))
		overmap_bound_vessel = null
	QDEL_LIST(overmap_contact_blips)
	QDEL_NULL(overmap_map_camera)
	QDEL_NULL(overmap_cam_screen)
	return ..()

/obj/machinery/computer/shuttle/ui_close(mob/user)
	. = ..()
	overmap_cam_screen?.hide_from(user)

/obj/machinery/computer/shuttle/proc/connect()
	var/obj/docking_port/mobile/mobile_docking_port
	if(!shuttleId)
		// find close shuttle that is ok to mess with
		if(!SSshuttle) //intentionally mapping shuttle consoles without actual shuttles IS POSSIBLE OH MY GOD WHO KNEW *glare*
			return
		for(var/obj/docking_port/mobile/D in SSshuttle.mobile)
			if(get_dist(src, D) <= max_connect_range && D.rebuildable)
				mobile_docking_port = D
				shuttleId = mobile_docking_port.id
				break
	else if(!possible_destinations && SSshuttle) //possible destinations should **not** always exist; so, if it's specifically set to null, don't make it exist
		mobile_docking_port = SSshuttle.getShuttle(shuttleId)

	if(mobile_docking_port && !possible_destinations)
		// find perfect fits
		possible_destinations = ""
		for(var/obj/docking_port/stationary/S in SSshuttle.stationary)
			if(!istype(S, /obj/docking_port/stationary/transit) && S.width == mobile_docking_port.width && S.height == mobile_docking_port.height && S.dwidth == mobile_docking_port.dwidth && S.dheight == mobile_docking_port.dheight && findtext(S.id, mobile_docking_port.id))
				possible_destinations += "[possible_destinations ? ";" : ""][S.id]"

/obj/machinery/computer/shuttle/attack_hand(mob/user)
	if(..(user))
		return
	if(!shuttleId)
		return
	connect()
	add_fingerprint(user)
	ui_interact(user)

/obj/machinery/computer/shuttle/ui_interact(mob/user, datum/tgui/ui = null)
	if(uses_overmap_programmed_ui())
		overmap_request_ui_interact(user, ui)
		return
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "ShuttleConsole", name)
		ui.open()

/obj/machinery/computer/shuttle/ui_data(mob/user)
	if(uses_overmap_programmed_ui())
		return overmap_request_ui_data(user)
	var/list/data = list()
	var/obj/docking_port/mobile/mobile_docking_port = SSshuttle.getShuttle(shuttleId)
	var/lockdown_check = lockdown_affected && GLOB.full_lockdown
	data["docked_location"] = mobile_docking_port ? mobile_docking_port.getStatusText() : lowertext(UNKNOWN_STATUS_RUS)
	data["timer_str"] = mobile_docking_port ? mobile_docking_port.getTimerStr() : "00:00"
	if(!mobile_docking_port)
		data["status"] = "Потерянный"
		return data
	if(admin_controlled)
		data["status"] = "Несанкционированный доступ"
	else if(lockdown_check)
		data["status"] = "Заблокирован"
	else
		switch(mobile_docking_port.mode)
			if(SHUTTLE_IGNITING)
				data["status"] = "Запуск"
			if(SHUTTLE_IDLE)
				data["status"] = "Ожидание"
			if(SHUTTLE_RECHARGING)
				data["status"] = "Зарядка"
			else
				data["status"] = "В пути"
	if(mobile_docking_port)
		data["shuttle"] = TRUE	//this should just be boolean, right?
		var/list/docking_ports = list()
		data["locations"] = docking_ports
		var/list/options = params2list(possible_destinations)
		for(var/obj/docking_port/stationary/S in SSshuttle.stationary)
			if(!options.Find(S.id))
				continue
			if(!mobile_docking_port.check_dock(S))
				continue
			docking_ports[++docking_ports.len] = list("name" = S.name, "id" = S.id)
		if(length(data["locations"]) > 1)
			data["destination"] = destination
		else if(length(data["locations"]) == 1)
			for(var/location in data["locations"])
				destination = location["id"]
				data["destination"] = destination
		else if(!length(data["locations"]))
			data["locked"] = TRUE
			data["status"] = "Заблокирован"
		data["docking_ports_len"] = docking_ports.len
		data["admin_controlled"] = admin_controlled || lockdown_check
	return data

/obj/machinery/computer/shuttle/ui_act(action, params)
	if(uses_overmap_programmed_ui())
		if(..())
			return TRUE
		return overmap_request_ui_act(action, params)
	if(..())	//we can't actually interact, so no action
		return TRUE
	if(!allowed(usr))
		to_chat(usr, span_danger("Доступ запрещён."))
		playsound(src, SFX_BUTTON_DENIED, 20)
		return	TRUE
	if(!can_call_shuttle(usr, action))
		return TRUE
	var/list/options = params2list(possible_destinations)
	if(action == "move")
		var/destination = params["shuttle_id"]
		if(!options.Find(destination))//figure out if this translation works
			message_admins("[span_boldannounceooc("EXPLOIT:")] [ADMIN_LOOKUPFLW(usr)] attempted to move [src] to an invalid location! [ADMIN_COORDJMP(src)]")
			return
		switch(SSshuttle.moveShuttle(shuttleId, destination, TRUE, usr))
			if(SHUTTLE_CONSOLE_RECHARGING)
				to_chat(usr, span_warning("Shuttle engines are not ready for use."))
				return
			if(0)
				atom_say("Шаттл отправляется! Пожалуйста, отойдите от шл+юзов.")
				add_misc_logs(usr, "used [src] to call the [shuttleId] shuttle")
				if(!moved)
					moved = TRUE
				add_fingerprint(usr)
				return TRUE
			if(1)
				to_chat(usr, span_warning("Invalid shuttle requested."))
			else
				to_chat(usr, span_notice("Unable to comply."))
	else if(action == "set_destination")
		var/target_destination = params["destination"]
		if(target_destination)
			destination = target_destination
			return TRUE

/obj/machinery/computer/shuttle/emag_act(mob/user)
	if(!emagged)
		add_attack_logs(user, src, "emagged")
		src.req_access = list()
		emagged = 1
		if(user)
			to_chat(user, span_notice("You fried the consoles ID checking system."))

//for restricting when the computer can be used, needed for some console subtypes.
/obj/machinery/computer/shuttle/proc/can_call_shuttle(mob/user, action)
	return TRUE

/obj/machinery/computer/shuttle/ferry
	name = "transport ferry console"
	circuit = /obj/item/circuitboard/ferry
	shuttleId = "ferry"
	possible_destinations = "ferry_home;ferry_away"

/obj/machinery/computer/shuttle/ferry/request
	name = "ferry console"
	circuit = /obj/item/circuitboard/ferry/request
	var/next_request	//to prevent spamming admins
	possible_destinations = "ferry_home"
	admin_controlled = TRUE
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | ACID_PROOF

/obj/machinery/computer/shuttle/ferry/request/ui_act(action, params)
	if(..())	// Note that the parent handels normal shuttle movement on top of security checks
		return
	if(action == "request")
		if(world.time < next_request)
			return
		next_request = world.time + 60 SECONDS	//1 minute cooldown
		to_chat(usr, span_notice("Your request has been received by Centcom."))
		log_admin("[key_name(usr)] requested to move the transport ferry to Centcom.")
		message_admins("<b>FERRY: <font color='#EB4E00'>[key_name_admin(usr)] (<a href='byond://?_src_=holder;secretsfun=moveferry'>Move Ferry</a>)</b> is requesting to move the transport ferry to Centcom.</font>")
		return TRUE

/obj/machinery/computer/shuttle/ruins_transport_shuttle // this shuttle made for station and listening post of ussp since they have lore connection between eachother, btw the shuttle existed before the change but was deleted for some reason.
	name = "Transport Shuttle Console"
	desc = "Используется для управления Транспортным шаттлом."
	circuit = /obj/item/circuitboard/ruins_transport_shuttle
	shuttleId = "ruins_transport_shuttle"
	possible_destinations = "ussp_dock;dj_post;sindiecake_dock;ussp_gorky17"

/obj/machinery/computer/shuttle/ruins_transport_shuttle/old_frame
	icon = 'icons/obj/machines/computer3.dmi'
	icon_state = "frame"
	icon_keyboard = "kb6"

/obj/machinery/computer/shuttle/ruins_civil_shuttle // made another shuttle, this one will fly between spacebar and twin nexus hotel. just another way to get to it.
	name = "Regular Civilian Shuttle Console"
	desc = "Используется для управления обычным гражданским шаттлом."
	circuit = /obj/item/circuitboard/ruins_civil_shuttle
	shuttleId = "ruins_civil_shuttle"
	possible_destinations = "spacebar;spacehotelv1;ntstation"

/obj/machinery/computer/shuttle/white_ship
	name = "White Ship Console"
	desc = "Используется для управления Белым кораблём."
	circuit = /obj/item/circuitboard/white_ship
	shuttleId = "whiteship"
	possible_destinations = null // Set at runtime

/obj/machinery/computer/shuttle/engineering
	name = "Engineering Shuttle Console"
	desc = "Используется для вызова и отправки инженерного шаттла."
	shuttleId = "engineering"
	possible_destinations = "engineering_home;engineering_away"

/obj/machinery/computer/shuttle/science
	name = "Science Shuttle Console"
	desc = "Используется для вызова и отправки научного шаттла."
	shuttleId = "science"
	possible_destinations = "science_home;science_away"

/obj/machinery/computer/shuttle/admin
	name = "admin shuttle console"
	req_access = list(ACCESS_CENT_GENERAL)
	shuttleId = "admin"
	possible_destinations = "admin_home;admin_away;admin_custom"
	resistance_flags = INDESTRUCTIBLE

/obj/machinery/computer/camera_advanced/shuttle_docker/admin
	name = "Admin shuttle navigation computer"
	desc = "Используется, чтобы указать точное местоположение для отправки админского шаттла."
	shuttleId = "admin"
	shuttlePortId = "admin_custom"
	view_range = 14
	resistance_flags = INDESTRUCTIBLE
	space_turfs_only = FALSE
	access_admin_zone = TRUE	//can we park on Admin z_lvls?
	access_mining = TRUE		//can we park on Lavaland z_lvl?
	access_taipan = TRUE		//can we park on Taipan z_lvl?
	access_away = TRUE		//can we park on Away_Mission z_lvl?
	access_derelict = TRUE		//can we park in Unexplored Space?

/obj/machinery/computer/shuttle/trade
	name = "Freighter Console"
	resistance_flags = INDESTRUCTIBLE

/obj/machinery/computer/shuttle/trade/sol
	req_access = list(ACCESS_TRADE_SOL)
	possible_destinations = "trade_sol_base;trade_dock"
	shuttleId = "trade_sol"

/obj/machinery/computer/shuttle/golem_ship
	name = "Golem Ship Console"
	desc = "Используется для управления шаттлом големов."
	circuit = /obj/item/circuitboard/shuttle/golem_ship
	shuttleId = "freegolem"
	possible_destinations = "freegolem_lavaland;freegolem_space;freegolem_ussp"

/obj/machinery/computer/shuttle/golem_ship/attack_hand(mob/user)
	if(!isgolem(user) && !isobserver(user))
		to_chat(user, span_notice("The console is unresponsive. Seems only golems can use it."))
		return
	..()

/obj/machinery/computer/shuttle/golem_ship/recall
	name = "golem ship recall terminal"
	desc = "Используется для отзыва шаттла големов."
	possible_destinations = "freegolem_lavaland"
	resistance_flags = INDESTRUCTIBLE

//#undef DOCKING_PORT_HIGHLIGHT

/turf/proc/copyTurf(turf/T)
	if(T.type != type)
		var/obj/O
		if(length(underlays))	//we have underlays, which implies some sort of transparency, so we want to a snapshot of the previous turf as an underlay
			O = new()
			O.underlays += T
		T.ChangeTurf(type, keep_icon = FALSE)
		if(length(underlays))
			T.underlays.Cut()
			T.underlays += O.underlays
	if(T.icon_state != icon_state)
		T.icon_state = icon_state
	if(T.icon != icon)
		T.icon = icon
	if(T.color != color)
		T.color = color
	if(T.dir != dir)
		T.dir = dir
	return T
