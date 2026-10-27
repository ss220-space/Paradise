/obj/docking_port/stationary/overmap/formation
	name = "ship docking collar"
	turf_type = /turf/space
	area_type = /area/shuttle/transit

/obj/overmap/entity/proc/formation_capacity()
	return length(flight_reservation?.reserved_turfs)

/obj/overmap/entity/proc/finish_ship_dock(obj/overmap/entity/host, list/own, list/theirs)
	if(!dock_to_ship(host, own, theirs))
		shuttle_visible_message(span_warning("Стыковка отменена: недостаточно места или проход занят."))

/obj/overmap/entity/proc/transfer_formation(obj/docking_port/stationary/pad, obj/overmap/entity/host)
	formation_transfer = TRUE
	host.formation_transfer = TRUE
	var/result
	try
		result = shuttle.dock(pad, force = TRUE, transit = TRUE)
	catch(var/exception/error)
		formation_transfer = FALSE
		host.formation_transfer = FALSE
		throw error
	formation_transfer = FALSE
	host.formation_transfer = FALSE
	return result

/obj/overmap/entity/proc/formation_landing_valid(obj/docking_port/stationary/pad, obj/overmap/entity/host)
	if(!shuttle || !host?.flight_reservation || shuttle.transfer_busy || host.shuttle?.transfer_busy)
		return FALSE
	var/list/pairs = shuttle.overmap_move_pairs(pad)
	var/list/destinations = pairs[2]
	if(!length(destinations))
		return FALSE
	var/list/bounds = host.flight_bounds
	for(var/turf/destination as anything in destinations)
		if(!destination || SSmapping.used_turfs[destination] != host.flight_reservation || !isspaceturf(destination))
			return FALSE
		if(destination.x <= bounds[1] || destination.y <= bounds[2] || destination.x >= bounds[3] || destination.y >= bounds[4])
			return FALSE
		for(var/atom/movable/obstacle in destination)
			if(obstacle.simulated && (obstacle.density || isliving(obstacle)))
				return FALSE
	return TRUE

/obj/overmap/entity/proc/dock_physical_ship(obj/overmap/entity/host, list/own, list/theirs)
	if(formation_transfer || host.formation_transfer || length(docked_guests))
		return FALSE
	if(formation_capacity() > host.formation_capacity())
		if(length(host.docked_guests))
			return FALSE
		return host.dock_physical_ship(src, theirs, own)
	var/turf/own_door_turf = own[1]
	var/turf/host_door_turf = theirs[1]
	var/obj/machinery/door/airlock/external/docking/own_door = locate() in own_door_turf
	var/obj/machinery/door/airlock/external/docking/host_door = locate() in host_door_turf
	if(!own_door || !host_door || !shuttle.assigned_transit)
		return FALSE
	var/obj/machinery/door/airlock/external/docking/previous_collar = shuttle.overmap_collar
	shuttle.overmap_collar = own_door
	var/obj/docking_port/stationary/overmap/formation/pad = new(theirs[2])
	pad.dock_airlock = host_door
	var/list/origin = shuttle.overmap_origin()
	var/rotation = SIMPLIFY_DEGREES(theirs[3] + 180 - own[3])
	pad.setDir(angle2dir(dir2angle(origin[2]) + rotation))
	if(!formation_landing_valid(pad, host))
		shuttle.overmap_collar = previous_collar
		qdel(pad, TRUE)
		return FALSE
	flight.release_pilot()
	flight.set_autopilot(FALSE, manual = FALSE)
	var/result = transfer_formation(pad, host)
	if(result != DOCKING_SUCCESS)
		shuttle.overmap_collar = previous_collar
		qdel(pad, TRUE)
		return FALSE
	formation_pad = pad
	docked_ship = host
	dock_host_collar = get_turf(host_door)
	dock_collar_angle = SIMPLIFY_DEGREES(own[3] + rotation)
	dock_facing_offset = 0
	host.docked_guests |= src
	map_hull()
	dock_hull_x = hull_center_x
	dock_hull_y = hull_center_y
	flight.set_facing(host.get_facing())
	follow_host()
	host.remap_hull()
	remember_pose()
	for(var/obj/overmap/entity/joined as anything in list(src, host))
		joined.radar_epoch++
		joined.play_shuttle_sound('sound/effects/clang.ogg')
		joined.shake_shuttle(3, 1)
	announce_sensor_event("Стыковка: [get_overmap_display_name()] → [host.get_overmap_display_name()]", "dock")
	return TRUE

/obj/overmap/entity/proc/leave_physical_formation()
	var/obj/overmap/entity/host = docked_ship
	var/obj/docking_port/stationary/transit/home = shuttle?.assigned_transit
	if(!host || !formation_pad || !home || formation_transfer || host.formation_transfer)
		return FALSE
	var/list/origin = shuttle.overmap_origin()
	var/rotation = shuttle.overmap_dir_rotation(origin[2], shuttle.overmap_transit_dir(origin[2]))
	var/new_facing = get_facing() - rotation
	var/result = transfer_formation(home, host)
	if(result != DOCKING_SUCCESS)
		return FALSE
	var/obj/docking_port/stationary/old_pad = formation_pad
	formation_pad = null
	host.docked_guests -= src
	docked_ship = null
	dock_host_collar = null
	flight.set_facing(new_facing)
	map_hull()
	host.remap_hull()
	remember_pose()
	radar_epoch++
	qdel(old_pad, TRUE)
	return TRUE
