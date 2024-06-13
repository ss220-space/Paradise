/obj/machinery/camera
	var/list/localMotionTargets = list()
	var/detectTime = 0
	var/alarm_delay = 30 // Don't forget, there's another 3 seconds in queueAlarm()

/obj/machinery/camera/process()
	// motion camera event loop
	if(!isMotion())
		. = PROCESS_KILL
		return
	if(!status || (stat & (EMPED|NOPOWER)))
		for(var/targer in localMotionTargets)
			lostTargetRef(targer)
		return
	if(detectTime > 0)
		var/elapsed = world.time - detectTime
		if(elapsed > alarm_delay)
			triggerAlarm()
	else if(detectTime == -1)
		for(var/thing in localMotionTargets)
			var/mob/target = locateUID(thing)
			if(QDELETED(target) || target.stat == DEAD || !can_see(target, view_range))
				//If not part of a monitored area and the camera is not in range or the target is dead
				lostTargetRef(thing)

/obj/machinery/camera/proc/newTarget(mob/target)
	if(target.lastarea != myArea)
		return FALSE
	if(isAI(target))
		return FALSE
	if(!can_see(target, view_range))
		return FALSE
	if(detectTime == 0)
		detectTime = world.time // start the clock
	localMotionTargets |= target.UID()
	return TRUE

/obj/machinery/camera/proc/lostTargetRef(uid)
	if(length(localMotionTargets))
		localMotionTargets -= uid
		if(!length(localMotionTargets))
			cancelAlarm()

/obj/machinery/camera/proc/cancelAlarm()
	if(detectTime == -1)
		SSalarm.cancelAlarm("Motion", get_area(src), src)
	detectTime = 0
	return TRUE

/obj/machinery/camera/proc/triggerAlarm()
	if(!detectTime)
		return FALSE
	if(status)
		SSalarm.triggerAlarm("Motion", get_area(src), list(UID()), src)
		visible_message(span_warning("A red light flashes on the [src]!"))
	detectTime = -1
	return TRUE

/// Returns TRUE if the camera can see the target.
/obj/machinery/camera/proc/can_see(atom/target, length=7) // I stole this from global and modified it to work with Xray cameras.
	var/turf/current = get_turf(src)
	var/turf/target_turf = get_turf(target)
	if(target.invisibility > SEE_INVISIBLE_LIVING || target.alpha == NINJA_ALPHA_INVISIBILITY)
		return FALSE
	if(get_dist(current, target_turf) > length)
		return FALSE
	if(current == target_turf || isXRay())
		return TRUE

	var/list/line_of_sight = get_line(src, target)
	line_of_sight = line_of_sight.Cut(1, 2)
	for(var/turf/current_turf as anything in line_of_sight)
		if(current_turf.opacity)
			return FALSE
		for(var/atom/movable/thing as anything in current_turf)
			if(thing.opacity)
				return FALSE
	return TRUE

/obj/machinery/camera/HasProximity(atom/movable/AM)
	if(isliving(AM))
		newTarget(AM)

