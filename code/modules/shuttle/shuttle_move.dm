/**
 * Turf transfer for docking_port/mobile.
 * dock() waits for MILLA(atmos), then runs collect > preflight > takeoff > restore > postflight.
 */

/obj/docking_port/mobile/proc/dock(obj/docking_port/stationary/new_dock, force = FALSE, transit = FALSE)
	if(new_dock.get_docked() == src)
		remove_ripples()
		SEND_SIGNAL(src, COMSIG_SHUTTLE_DOCK, new_dock)
		return DOCKING_SUCCESS

	if(transfer_busy)
		return DOCKING_IMMOBILIZED

	if(!force)
		if(!check_dock(new_dock))
			return DOCKING_BLOCKED
		if(!canMove())
			remove_ripples()
			return DOCKING_IMMOBILIZED

	SEND_SIGNAL(src, COMSIG_SHUTTLE_PRE_DOCK, new_dock)

	transfer_busy = TRUE
	var/datum/milla_safe_must_sleep/docking_port_dock/job = new()
	job.invoke_async(src, new_dock, force, transit)
	if(!job.finished && Master?.current_runlevel)
		var/deadline = world.time + 2 MINUTES
		UNTIL(job.finished || world.time > deadline)
	transfer_busy = FALSE
	if(!job.finished)
		job.finished = TRUE
		job.result = DOCKING_IMMOBILIZED
	return job.result

/datum/milla_safe_must_sleep/docking_port_dock
	var/finished = FALSE
	var/result = DOCKING_SUCCESS

/datum/milla_safe_must_sleep/docking_port_dock/on_run(obj/docking_port/mobile/mobile_port, obj/docking_port/stationary/new_dock, force, transit)
	result = DOCKING_BLOCKED
	if(!QDELETED(mobile_port) && !QDELETED(new_dock))
		result = mobile_port.run_dock_transfer(src, new_dock, force, transit)
	finished = TRUE

/obj/docking_port/mobile/proc/run_dock_transfer(datum/milla_safe_must_sleep/docking_port_dock/job, obj/docking_port/stationary/new_dock, force, transit)
	if(new_dock.get_docked() == src)
		remove_ripples()
		SEND_SIGNAL(src, COMSIG_SHUTTLE_DOCK, new_dock)
		return DOCKING_SUCCESS
	if(!force)
		if(!check_dock(new_dock))
			return DOCKING_BLOCKED
		if(!canMove())
			remove_ripples()
			return DOCKING_IMMOBILIZED

	var/obj/docking_port/stationary/old_dock = get_docked()
	var/list/move_data = collect_move_pairs(new_dock)
	if(!move_data)
		return DOCKING_NULL_DESTINATION

	var/list/old_turfs = move_data["old_turfs"]
	var/list/new_turfs = move_data["new_turfs"]
	if(!length(old_turfs))
		return DOCKING_AREA_EMPTY
	var/has_dest = FALSE
	for(var/turf/newT as anything in new_turfs)
		if(newT)
			has_dest = TRUE
			break
	if(!has_dest)
		return DOCKING_NULL_DESTINATION

	closePortDoors(old_dock)
	if(old_dock)
		SEND_SIGNAL(src, COMSIG_SHUTTLE_UNDOCK, old_dock)

	remove_ripples()
	shuttle_smash(old_turfs, new_turfs, move_data["move_dir"], move_data["use_hull"])

	var/list/touched = takeoff_turfs(job, old_turfs, new_turfs, move_data)
	restore_origin_turfs(old_turfs, old_dock, touched)
	job.flush_shuttle_atmos(touched)
	postflight_dock(new_dock, new_turfs, move_data, transit)
	return DOCKING_SUCCESS

/obj/docking_port/mobile/proc/collect_move_pairs(obj/docking_port/stationary/new_dock)
	. = list()
	var/use_hull = uses_hull_fit()
	var/list/origin = overmap_origin()
	var/turf/origin_turf = origin[1]
	var/origin_dir = origin[2]
	if(!origin_turf)
		origin_turf = get_turf(src)
		origin_dir = dir

	var/list/old_turfs
	var/list/new_turfs
	var/rotation = 0
	var/move_dir = new_dock.dir
	if(use_hull)
		var/list/pairs = overmap_move_pairs(new_dock)
		old_turfs = pairs[1]
		new_turfs = pairs[2]
		move_dir = overmap_dest_dir(new_dock, origin_dir)
		rotation = overmap_dir_rotation(origin_dir, move_dir)
	else
		old_turfs = return_ordered_turfs(origin_turf.x, origin_turf.y, origin_turf.z, origin_dir, areaInstance)
		new_turfs = return_ordered_turfs(new_dock.x, new_dock.y, new_dock.z, new_dock.dir)
		if(new_dock.dir != origin_dir)
			rotation = overmap_dir_rotation(origin_dir, new_dock.dir)

	.["use_hull"] = use_hull
	.["old_turfs"] = old_turfs
	.["new_turfs"] = new_turfs
	.["rotation"] = rotation
	.["move_dir"] = move_dir
	.["origin_dir"] = origin_dir

/obj/docking_port/mobile/proc/takeoff_turfs(datum/milla_safe_must_sleep/docking_port_dock/job, list/old_turfs, list/new_turfs, list/move_data)
	. = list()
	var/use_hull = move_data["use_hull"]
	var/rotation = move_data["rotation"]
	var/area_type = get_docked()?.area_type || /area/space
	var/area/fallback_area
	if(length(areaInstance?.contents) || use_hull)
		fallback_area = locate(area_type)
		if(!fallback_area)
			fallback_area = new area_type(null)
		if(!use_hull)
			for(var/turf/oldT in old_turfs)
				if(oldT)
					fallback_area.contents += oldT

	for(var/i in 1 to length(old_turfs))
		var/turf/oldT = old_turfs[i]
		if(!oldT)
			continue
		if(use_hull && !overmap_is_hull_turf(oldT))
			continue
		var/turf/newT = new_turfs[i]
		if(!newT)
			continue

		if(use_hull)
			var/area/old_place = get_area(oldT)
			if(fallback_area && old_place && old_place != fallback_area)
				oldT.change_area(old_place, fallback_area)
			var/area/new_place = get_area(newT)
			if(areaInstance && new_place != areaInstance)
				newT.change_area(new_place, areaInstance)
		else if(areaInstance)
			areaInstance.contents += newT

		var/should_transit = !is_turf_blacklisted_for_transit(oldT)
		if(should_transit)
			for(var/mob/living/mob in oldT)
				if(mob.leaned_object)
					mob.stop_leaning()
			oldT.copyTurf(newT)
			if(issimulatedturf(newT))
				job.get_turf_air(newT).copy_from(job.get_turf_air(oldT))
			for(var/atom/movable/moving as anything in oldT)
				if(!moving.beforeShuttleMove(newT, rotation, src))
					continue
				moving.onShuttleMove(oldT, newT, rotation, last_caller)
			SEND_SIGNAL(oldT, COMSIG_TURF_ON_SHUTTLE_MOVE, newT)
			if(rotation)
				newT.shuttleRotate(rotation)

		var/turf/new_ceiling = GET_TURF_ABOVE(newT)
		if(new_ceiling && (isspaceturf(new_ceiling) || isopenspaceturf(new_ceiling)))
			new_ceiling.ChangeTurf(/turf/simulated/floor/engine/hull/ceiling)
			.[new_ceiling] = TRUE

		.[newT] = TRUE
		if(should_transit)
			.[oldT] = TRUE
		old_turfs[i] = should_transit ? oldT : null

/obj/docking_port/mobile/proc/restore_origin_turfs(list/old_turfs, obj/docking_port/stationary/old_dock, list/touched)
	var/turf_type = old_dock?.turf_type || /turf/space
	for(var/i in 1 to length(old_turfs))
		var/turf/oldT = old_turfs[i]
		if(!oldT)
			continue
		var/turf/old_ceiling = GET_TURF_ABOVE(oldT)
		if(old_ceiling && istype(old_ceiling, /turf/simulated/floor/engine/hull/ceiling))
			var/turf/simulated/floor/engine/hull/ceiling/old_shuttle_ceiling = old_ceiling
			old_shuttle_ceiling.ChangeTurf(old_shuttle_ceiling.old_turf_type)
			touched[old_ceiling] = TRUE
		oldT.ChangeTurf(turf_type, keep_icon = FALSE)
		touched[oldT] = TRUE

/datum/milla_safe_must_sleep/docking_port_dock/proc/flush_shuttle_atmos(list/turfs)
	for(var/turf/spot as anything in turfs)
		if(!spot)
			continue
		spot.lighting_build_overlay()
		var/list/connectivity = spot.private_unsafe_recalculate_atmos_connectivity()
		set_tile_airtight(spot, connectivity[1])
		reset_superconductivity(spot)
		reduce_superconductivity(spot, connectivity[2])

/obj/docking_port/mobile/proc/postflight_dock(obj/docking_port/stationary/new_dock, list/new_turfs, list/move_data, transit)
	var/in_hyperspace = transit || istype(new_dock, /obj/docking_port/stationary/transit)
	for(var/area/shuttle/place as anything in shuttle_areas)
		place.moving = in_hyperspace
		if(in_hyperspace)
			place.parallax_movedir = preferred_direction
	if(areaInstance)
		areaInstance.moving = in_hyperspace
		areaInstance.parallax_movedir = preferred_direction
	for(var/turf/newT as anything in new_turfs)
		if(!newT)
			continue
		newT.postDock(new_dock)
		for(var/atom/movable/thing in newT)
			thing.postDock(new_dock)

	loc = new_dock.loc
	dir = move_data["move_dir"]
	#ifndef SKIP_LAVALAND
	if((id in list("mining", "laborcamp")) && !CONFIG_GET(flag/disable_lavaland) && !(SSmapping.map_datum.disables & DISABLE_LAVALAND))
		var/mining_zlevel = level_name_to_num(MINING)
		var/datum/weather/ash_storm/storm = SSweather.get_weather(mining_zlevel, /area/lavaland/surface/outdoors)
		if(storm)
			storm.update_eligible_areas()
			storm.update_audio()
	#endif
	unlockPortDoors(new_dock)
	SEND_SIGNAL(src, COMSIG_SHUTTLE_DOCK, new_dock)
