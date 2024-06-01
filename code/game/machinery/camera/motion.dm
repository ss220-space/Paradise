/obj/machinery/camera
	var/list/localMotionTargets = list()
	var/detectTime = 0
	var/alarm_delay = 30 // Don't forget, there's another 3 seconds in queueAlarm()

/obj/machinery/camera/process()
	// motion camera event loop
	if(!isMotion())
		. = PROCESS_KILL
		return
	if(stat & (EMPED|NOPOWER))
		return
	if(detectTime > 0)
		var/elapsed = world.time - detectTime
		if(elapsed > alarm_delay)
			triggerAlarm()
	else if(detectTime == -1)
		for(var/thing in getTargetList())
			var/mob/target = locateUID(thing)
			if(QDELETED(target) || target.stat == DEAD || !can_see(target, view_range))
				//If not part of a monitored area and the camera is not in range or the target is dead
				lostTargetRef(thing)

/obj/machinery/camera/proc/getTargetList()
	return localMotionTargets

/obj/machinery/camera/proc/newTarget(mob/target)
	if(isAI(target))
		return FALSE
	if(detectTime == 0 && can_see(target, view_range))
		detectTime = world.time // start the clock
	var/list/targets = getTargetList()
	targets |= target.UID()
	return TRUE

/obj/machinery/camera/proc/lostTargetRef(uid)
	var/list/targets = getTargetList()
	if(length(targets))
		targets -= uid
		if(!length(targets))
			cancelAlarm()

/obj/machinery/camera/proc/cancelAlarm()
	if(detectTime == -1)
		if(status)
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
	var/steps = 1
	if(target.invisibility > SEE_INVISIBLE_LIVING || target.alpha == NINJA_ALPHA_INVISIBILITY)
		return 0
	if(isXRay())
		if(current != target_turf)
			current = get_step_towards(current, target_turf)
			while(current != target_turf)
				if(steps > length)
					return 0
				current = get_step_towards(current, target_turf)
				steps++
	else
		if(current != target_turf)
			current = get_step_towards(current, target_turf)
			while(current != target_turf)
				if(steps > length)
					return 0
				if(current.opacity)
					return 0
				for(var/thing in current)
					var/atom/A = thing
					if(A.opacity)
						return 0
				current = get_step_towards(current, target_turf)
				steps++

	return 1

/obj/machinery/camera/HasProximity(atom/movable/AM)
	// Motion cameras outside of an "ai monitored" area will use this to detect stuff.
	if(isliving(AM))
		newTarget(AM)

