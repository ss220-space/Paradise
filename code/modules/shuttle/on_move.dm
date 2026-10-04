// Shuttle on-movement //
/atom/movable/proc/beforeShuttleMove(turf/newT, rotation, obj/docking_port/mobile/moving_dock)
	return TRUE

/atom/movable/proc/onShuttleMove(turf/oldT, turf/T1, rotation, mob/requester)
	if(light && light_system == COMPLEX_LIGHT)
		update_light()

	if(rotation)
		shuttleRotate(rotation)

	forceMove(T1)
	//SSdemo.mark_dirty(src)

	return TRUE

/obj/effect/landmark/shuttle_import/onShuttleMove()
	// Used for marking where to preview/load shuttles
	return FALSE

/obj/docking_port/onShuttleMove()
	// Stationary ports shouldn't move, mobile ones move themselves
	return FALSE

/obj/machinery/door/airlock/onShuttleMove()
	. = ..()
	if(!.)
		return
	INVOKE_ASYNC(src, PROC_REF(close), 0, 1)
	for(var/obj/machinery/door/airlock/nearby in orange(1, src))
		INVOKE_ASYNC(nearby, PROC_REF(close), 0, 1)
	if(id_tag == "s_docking_airlock" || istype(src, /obj/machinery/door/airlock/external/docking))
		INVOKE_ASYNC(src, PROC_REF(lock))

/mob/onShuttleMove(turf/oldT, turf/T1, rotation)
	if(!move_on_shuttle)
		return 0
	. = ..()
	if(!.)
		return
	if(!client)
		return

	if(buckled)
		shake_camera(src, 2, 1) // turn it down a bit come on
	else
		shake_camera(src, 7, 1)

	update_parallax_contents()

/mob/living/carbon/onShuttleMove()
	. = ..()
	if(!.)
		return
	if(!buckled)
		Weaken(6 SECONDS)

// After docking //
/atom/proc/postDock(obj/docking_port/S1)
	if(smooth)
		QUEUE_SMOOTH(src)

/mob/postDock()
	update_parallax_contents()

/obj/machinery/door/airlock/postDock(obj/docking_port/stationary/S1)
	. = ..()
	if(!S1.lock_shuttle_doors && (id_tag == "s_docking_airlock" || istype(src, /obj/machinery/door/airlock/external/docking)))
		INVOKE_ASYNC(src, PROC_REF(unlock))

/obj/structure/ladder/onShuttleMove()
	if(resistance_flags & INDESTRUCTIBLE)
		// simply don't be moved
		return FALSE
	disconnect()
	LateInitialize()
	return ..()

// Holy shit go away
/obj/effect/abstract/z_holder/onShuttleMove()
	return FALSE
