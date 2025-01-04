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
	var/width = 0	//size of covered area, perpendicular to dir
	var/height = 0	//size of covered area, parallel to dir
	var/dwidth = 0	//position relative to covered area, perpendicular to dir
	var/dheight = 0	//position relative to covered area, parallel to dir

	// A timid shuttle will not register itself with the shuttle subsystem
	// All shuttle templates are timid
	var/timid = FALSE

	var/list/ripples = list()
	var/hidden = FALSE //are we invisible to shuttle navigation computers?

	//these objects are indestructible
/obj/docking_port/Destroy(force)
	if(force)
		..()
		. = QDEL_HINT_HARDDEL_NOW
	else

		return QDEL_HINT_LETMELIVE

/obj/docking_port/has_gravity(turf/T)
	return FALSE

/obj/docking_port/take_damage()
	return

/obj/docking_port/singularity_pull()
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

//returns turfs within our projected rectangle in no particular order
/obj/docking_port/proc/return_turfs()
	var/list/L = return_coords()
	return block(L[1], L[2], z, L[3], L[4], z)

//returns turfs within our projected rectangle in a specific order.
//this ensures that turfs are copied over in the same order, regardless of any rotation
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
//Debug proc used to highlight bounding area
/obj/docking_port/proc/highlight(_color)
	SET_PLANE_IMPLICIT(src, GHOST_PLANE)
	var/list/L = return_coords()
	for(var/turf/T in block(L[1], L[2], z, L[3], L[4], z))
		T.color = _color
		T.maptext = null
	if(_color)
		var/turf/T = locate(L[1], L[2], z)
		T.color = "#0f0"
		T = locate(L[3], L[4], z)
		T.color = "#00f"
#endif

//return first-found touching dockingport
/obj/docking_port/proc/get_docked()
	return locate(/obj/docking_port/stationary) in loc

/obj/docking_port/proc/getDockedId()
	var/obj/docking_port/P = get_docked()
	if(P) return P.id

/obj/docking_port/proc/register()
	return 0

/obj/docking_port/stationary
	name = "dock"

	var/turf_type = /turf/baseturf_bottom
	var/area_type = /area/space
	var/last_dock_time

	var/lock_shuttle_doors = FALSE

// Preset for adding whiteship docks to ruins. Has widths preset which will auto-assign the shuttle
/obj/docking_port/stationary/whiteship
	dwidth = 8
	height = 31
	width = 17

/obj/docking_port/stationary/register()
	if(!SSshuttle)
		throw EXCEPTION("docking port [src] could not initialize.")
		return 0

	SSshuttle.stationary |= src
	if(!id)
		id = "[SSshuttle.stationary.len]"
	if(name == "dock")
		name = "dock[SSshuttle.stationary.len]"

	#ifdef DOCKING_PORT_HIGHLIGHT
	highlight("#f00")
	#endif
	return 1

//returns first-found touching shuttleport
/obj/docking_port/stationary/get_docked()
	return locate(/obj/docking_port/mobile) in loc

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

	var/mob/last_caller				// Who called the shuttle the last time

	var/obj/docking_port/stationary/destination
	var/obj/docking_port/stationary/previous
	var/obj/docking_port/stationary/transit/assigned_transit

/obj/docking_port/mobile/New()
	..()

	var/area/A = get_area(src)
	if(istype(A, /area/shuttle))
		areaInstance = A

	if(!areaInstance)
		areaInstance = new()
		areaInstance.name = name
		areaInstance.contents += return_ordered_turfs()

	areaInstance.parallax_movedir = preferred_direction

	#ifdef DOCKING_PORT_HIGHLIGHT
	highlight("#0f0")
	#endif

/obj/docking_port/mobile/Initialize()
	if(!timid)
		register()
	shuttle_areas = list()
	var/list/all_turfs = return_ordered_turfs(x, y, z, dir)
	for(var/i in 1 to all_turfs.len)
		var/turf/curT = all_turfs[i]
		var/area/cur_area = curT.loc
		if(istype(cur_area, areaInstance))
			shuttle_areas[cur_area] = TRUE
	. = ..()

/obj/docking_port/mobile/register()
	if(!SSshuttle)
		throw EXCEPTION("docking port [src] could not initialize.")
		return 0

	SSshuttle.mobile += src

	if(!id)
		id = "[SSshuttle.mobile.len]"
	if(name == "shuttle")
		name = "shuttle[SSshuttle.mobile.len]"

	return 1

/obj/docking_port/mobile/Destroy(force)
	if(force)
		SSshuttle.mobile -= src
		areaInstance = null
		destination = null
		previous = null
		QDEL_NULL(assigned_transit) //don't need it where we're goin'!
		shuttle_areas = null
	return ..()

//this is a hook for custom behaviour. Maybe at some point we could add checks to see if engines are intact
/obj/docking_port/mobile/proc/canMove()
	return 0	//0 means we can move // FALSE should've mean YOU CAN'T MOVE WTF

//this is to check if this shuttle can physically dock at dock S
/obj/docking_port/mobile/proc/canDock(obj/docking_port/stationary/S)
	if(!istype(S))
		return SHUTTLE_NOT_A_DOCKING_PORT
	if(istype(S, /obj/docking_port/stationary/transit))
		return SHUTTLE_CAN_DOCK
	//check dock is big enough to contain us
	if(dwidth > S.dwidth)
		return SHUTTLE_DWIDTH_TOO_LARGE
	if(width-dwidth > S.width-S.dwidth)
		return SHUTTLE_WIDTH_TOO_LARGE
	if(dheight > S.dheight)
		return SHUTTLE_DHEIGHT_TOO_LARGE
	if(height-dheight > S.height-S.dheight)
		return SHUTTLE_HEIGHT_TOO_LARGE
	//check the dock isn't occupied
	var/currently_docked = S.get_docked()
	if(currently_docked)
		// by someone other than us
		if(currently_docked != src)
			return SHUTTLE_SOMEONE_ELSE_DOCKED
		else
		// This isn't an error, per se, but we can't let the shuttle code
		// attempt to move us where we currently are, it will get weird.
			return SHUTTLE_ALREADY_DOCKED
	return SHUTTLE_CAN_DOCK

/obj/docking_port/mobile/proc/check_dock(obj/docking_port/stationary/S)
	var/status = canDock(S)
	if(status == SHUTTLE_CAN_DOCK)
		return TRUE
	else if(status == SHUTTLE_ALREADY_DOCKED)
		// We're already docked there, don't need to do anything.
		// Triggering shuttle movement code in place is weird
		return FALSE
	else
		var/msg = "check_dock(): shuttle [src] cannot dock at [S], error: [status]"
		message_admins(msg)
		return FALSE

/obj/docking_port/mobile/proc/transit_failure()
	message_admins("Shuttle [src] repeatedly failed to create transit zone.")

//call the shuttle to destination S
/obj/docking_port/mobile/proc/request(obj/docking_port/stationary/S)

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
		if(SHUTTLE_IDLE, SHUTTLE_IGNITING)
			destination = S
			mode = SHUTTLE_IGNITING
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
			log_runtime(EXCEPTION("shuttle \"[id]\" could not enter transit space. Docked at [S0 ? S0.id : "null"]. Transit dock [S1 ? S1.id : "null"]."))
		else
			previous = S0
			return TRUE
	else
		log_runtime(EXCEPTION("shuttle \"[id]\" could not enter transit space. S0=[S0 ? S0.id : "null"] S1=[S1 ? S1.id : "null"]"))



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
	if(areaInstance.contents.len)
		var/area/A0 = locate("[area_type]")
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
	if(ripples.len)
		for(var/i in ripples)
			qdel(i)
		ripples.Cut()


/obj/docking_port/mobile/proc/ripple_area(obj/docking_port/stationary/new_dock)
	var/list/old_turfs = return_ordered_turfs(x, y, z, dir, areaInstance)
	var/list/new_turfs = return_ordered_turfs(new_dock.x, new_dock.y, new_dock.z, new_dock.dir)

	var/list/ripple_turfs = list()

	for(var/i in 1 to old_turfs.len)
		var/turf/oldT = old_turfs[i]
		if(!oldT)
			continue
		var/turf/newT = new_turfs[i]
		if(!newT)
			continue
		if(oldT.type != oldT.baseturf)
			ripple_turfs += newT

	return ripple_turfs

/// this is the main proc. It instantly moves our mobile port to stationary port S1
/// it handles all the generic behaviour, such as sanity checks, closing doors on the shuttle, stunning mobs, etc
/obj/docking_port/mobile/proc/dock(obj/docking_port/stationary/new_dock, force = FALSE, transit = FALSE)
	// Crashing this ship with NO SURVIVORS
	if(new_dock.get_docked() == src)
		remove_ripples()
		return DOCKING_SUCCESS

	if(!force)
		if(!check_dock(new_dock))
			return DOCKING_BLOCKED

		if(canMove())
			remove_ripples()
			return DOCKING_IMMOBILIZED

	var/obj/docking_port/stationary/old_dock = get_docked()
	var/turf_type = old_dock?.turf_type || /turf/space
	var/area_type = old_dock?.area_type || /area/space

	//close and lock the dock's airlocks
	closePortDoors(old_dock)

	var/list/old_turfs = return_ordered_turfs(x, y, z, dir, areaInstance)
	var/list/new_turfs = return_ordered_turfs(new_dock.x, new_dock.y, new_dock.z, new_dock.dir)

	var/rotation = 0
	if(new_dock.dir != dir) //Even when the dirs are the same rotation is coming out as not 0 for some reason
		rotation = dir2angle(new_dock.dir)-dir2angle(dir)
		if ((rotation % 90) != 0)
			rotation += (rotation % 90) //diagonal rotations not allowed, round up
		rotation = SIMPLIFY_DEGREES(rotation)

	//remove area surrounding docking port
	if(areaInstance.contents.len)
		var/area/A0 = locate("[area_type]")
		if(!A0)
			A0 = new area_type(null)
		for(var/turf/oldT in old_turfs)
			A0.contents += oldT

	// Removes ripples
	remove_ripples()

	//move or squish anything in the way ship at destination
	shuttle_smash(old_turfs, new_turfs, new_dock.dir)

	// begin transition
	for(var/i in 1 to old_turfs.len)
		/* CHECKING */
		var/turf/oldT = old_turfs[i] //old turf
		if(!oldT)
			continue
		var/turf/newT = new_turfs[i] //new turf
		if(!newT)
			continue

		areaInstance.contents += newT

		/* TAKEOFF */
		var/should_transit = !is_turf_blacklisted_for_transit(oldT)
		if(should_transit) // Only move over stuff if the transfer actually happened
			oldT.copyTurf(newT)

			//copy over air
			if(issimulatedturf(newT))
				var/turf/simulated/Ts1 = newT
				Ts1.copy_air_with_tile(oldT)

			//move mobile to new location
			for(var/atom/movable/AM in oldT)
				AM.onShuttleMove(oldT, newT, rotation, last_caller)

			//rotate turf
			if(rotation)
				newT.shuttleRotate(rotation)
		/* END TAKEOFF */

		/* GIVE CEILING */
		var/turf/new_ceiling = GET_TURF_ABOVE(newT) // Do it before atmos readjust.
		if(new_ceiling && (isspaceturf(new_ceiling) || isopenspaceturf(new_ceiling))) //Check for open one, not wall
			// generate ceiling
			new_ceiling.ChangeTurf(/turf/simulated/floor/engine/hull/ceiling)

		// Always do this stuff as it ensures that the destination turfs still behave properly with the rest of the shuttle transit
		/* UPDATE ATMOS & LIGHT */
		SSair.remove_from_active(newT)
		newT.CalculateAdjacentTurfs()
		SSair.add_to_active(newT, 1)
		newT.lighting_build_overlay()

		if(!should_transit)
			continue // Don't want to actually change the skipped turf

		/* REMOVE OLD CEILING */
		var/turf/old_ceiling = GET_TURF_ABOVE(oldT)
		if(old_ceiling && istype(old_ceiling, /turf/simulated/floor/engine/hull/ceiling)) // check if a ceiling was generated previously
			// remove old ceiling
			var/turf/simulated/floor/engine/hull/ceiling/old_shuttle_ceiling = old_ceiling
			old_shuttle_ceiling.ChangeTurf(old_shuttle_ceiling.old_turf_type)

		/* RESTORE OLD TURF */
		oldT.ChangeTurf(turf_type, keep_icon = FALSE)
		SSair.remove_from_active(oldT)
		oldT.CalculateAdjacentTurfs()
		SSair.add_to_active(oldT, 1)
	// end transition

	areaInstance.moving = transit
	for(var/A1 in new_turfs)
		var/turf/newT = A1
		newT.postDock(new_dock)
		for(var/atom/movable/mobile_docking_port in newT)
			mobile_docking_port.postDock(new_dock)

	loc = new_dock.loc
	dir = new_dock.dir

	// Update mining and labor shuttle ash storm audio
	if(id in list("mining", "laborcamp") && !CONFIG_GET(flag/disable_lavaland))
		var/mining_zlevel = level_name_to_num(MINING)
		var/datum/weather/ash_storm/W = SSweather.get_weather(mining_zlevel, /area/lavaland/surface/outdoors)
		if(W)
			W.update_eligible_areas()
			W.update_audio()

	unlockPortDoors(new_dock)

/obj/docking_port/mobile/proc/is_turf_blacklisted_for_transit(turf/T)
	var/static/list/blacklisted_turf_types = typecacheof(GLOB.blacklisted_turf_types_for_transit)
	return is_type_in_typecache(T, blacklisted_turf_types)

/obj/docking_port/mobile/proc/findTransitDock()
	var/obj/docking_port/stationary/transit/T = SSshuttle.getDock("[id]_transit")
	if(T && check_dock(T))
		return T


/obj/docking_port/mobile/proc/findRoundstartDock()
	for(var/obj/docking_port/stationary/S in SSshuttle.stationary)
		if(S.id == roundstart_move)
			return S
	if(!alone_shuttle)
		log_runtime(EXCEPTION("couldn't find roundstart dock for \"[name]\" with id: [id]"))

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

	for(var/obj/machinery/door/airlock/A in GLOB.airlocks)
		if(A.id_tag == old_dock.id)
			A.close()
			A.lock()

/obj/docking_port/mobile/proc/unlockPortDoors(obj/docking_port/stationary/new_dock)
	if(!istype(new_dock) || isnull(new_dock.id))
		return

	for(var/obj/machinery/door/airlock/A in GLOB.airlocks)
		if(A.id_tag == new_dock.id)
			if(A.locked)
				A.unlock()


//used by shuttle subsystem to check timers
/obj/docking_port/mobile/proc/check()
	check_ripples()

	if(mode == SHUTTLE_IGNITING)
		check_transit_zone()

	if(timeLeft(1) > 0)
		return
	// If we can't dock or we don't have a transit slot, wait for 20 ds,
	// then try again
	switch(mode)
		if(SHUTTLE_CALL)
			if(dock(destination))
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
				mode = SHUTTLE_CALL
				setTimer(callTime)
				return
	mode = SHUTTLE_IDLE
	timer = 0
	destination = null

/obj/docking_port/mobile/proc/check_ripples()
	if(!ripples.len)
		if((mode == SHUTTLE_CALL) || (mode == SHUTTLE_RECALL))
			var/tl = timeLeft(1)
			if(tl <= SHUTTLE_RIPPLE_TIME)
				create_ripples(destination)

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

	var/timeleft = timeLeft()
	if(timeleft > 0)
		return "[add_zero(num2text((timeleft / 60) % 60),2)]:[add_zero(num2text(timeleft % 60), 2)]"
	else
		return "00:00"

/obj/docking_port/mobile/proc/getStatusText()
	var/obj/docking_port/stationary/dockedAt = get_docked()
	. = (dockedAt && dockedAt.name) ? dockedAt.name : "unknown"
	if(istype(dockedAt, /obj/docking_port/stationary/transit))
		var/obj/docking_port/stationary/dst
		if(mode == SHUTTLE_RECALL)
			dst = previous
		else
			dst = destination
		. += " towards [dst ? dst.name : "unknown location"] ([timeLeft(600)]mins)"
	else if(mode == SHUTTLE_RECHARGING)
		return "[dockedAt.name], recharging [getTimerStr()]"

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
	var/max_connect_range = 7
	var/moved = FALSE	//workaround for nukie shuttle, hope I find a better way to do this...

/obj/machinery/computer/shuttle/New(location, obj/item/circuitboard/shuttle/C)
	..()
	if(istype(C))
		possible_destinations = C.possible_destinations
		shuttleId = C.shuttleId

/obj/machinery/computer/shuttle/Initialize(mapload)
	. = ..()
	if(mapload)
		return INITIALIZE_HINT_LATELOAD

	connect()

/obj/machinery/computer/shuttle/LateInitialize()
	connect()

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
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "ShuttleConsole", name)
		ui.open()

/obj/machinery/computer/shuttle/ui_data(mob/user)
	var/list/data = list()
	var/obj/docking_port/mobile/mobile_docking_port = SSshuttle.getShuttle(shuttleId)
	data["docked_location"] = mobile_docking_port ? mobile_docking_port.getStatusText() : "Unknown"
	data["timer_str"] = mobile_docking_port ? mobile_docking_port.getTimerStr() : "00:00"
	if(!mobile_docking_port)
		data["status"] = "Missing"
		return data
	if(admin_controlled)
		data["status"] = "Unauthorized Access"
	else
		switch(mobile_docking_port.mode)
			if(SHUTTLE_IGNITING)
				data["status"] = "Igniting"
			if(SHUTTLE_IDLE)
				data["status"] = "Idle"
			if(SHUTTLE_RECHARGING)
				data["status"] = "Recharging"
			else
				data["status"] = "In Transit"
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
			data["status"] = "Locked"
		data["docking_ports_len"] = docking_ports.len
		data["admin_controlled"] = admin_controlled
	return data

/obj/machinery/computer/shuttle/ui_act(action, params)
	if(..())	//we can't actually interact, so no action
		return TRUE
	if(!allowed(usr))
		to_chat(usr, "<span class='danger'>Access denied.</span>")
		playsound(src, pick('sound/machines/button.ogg', 'sound/machines/button_alternate.ogg', 'sound/machines/button_meloboom.ogg'), 20)
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
				to_chat(usr, "<span class='warning'>Invalid shuttle requested.</span>")
			else
				to_chat(usr, "<span class='notice'>Unable to comply.</span>")
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
			to_chat(user, "<span class='notice'>You fried the consoles ID checking system.</span>")

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
		to_chat(usr, "<span class='notice'>Your request has been recieved by Centcom.</span>")
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
	icon_screen = "navigation"
	icon_keyboard = "med_key"
	shuttleId = "admin"
	shuttlePortId = "admin_custom"
	view_range = 14
	x_offset = 0
	y_offset = 0
	resistance_flags = INDESTRUCTIBLE
	space_turfs_only = FALSE
	access_admin_zone = TRUE	//can we park on Admin z_lvls?
	access_mining = TRUE		//can we park on Lavaland z_lvl?
	access_taipan = TRUE 		//can we park on Taipan z_lvl?
	access_away = TRUE 		//can we park on Away_Mission z_lvl?
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
		to_chat(user, "<span class='notice'>The console is unresponsive. Seems only golems can use it.</span>")
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
		if(underlays.len)	//we have underlays, which implies some sort of transparency, so we want to a snapshot of the previous turf as an underlay
			O = new()
			O.underlays += T
		T.ChangeTurf(type, keep_icon = FALSE)
		if(underlays.len)
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
