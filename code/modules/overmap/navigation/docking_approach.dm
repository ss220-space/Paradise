/obj/overmap/entity/proc/dock_candidate(list/target, obj/overmap/entity/host)
	var/datum/overmap_docking_approach/approach = new(src, FALSE)
	approach.target = target
	approach.host = host
	if(!host)
		approach.pad = target[4]
		approach.space = local_space
		if(!approach.pad)
			var/obj/docking_port/stationary/overmap/pad = new(target[2])
			pad.setDir(target[3])
			pad.dock_airlock = target[1]
			approach.pad = pad
			approach.target = target.Copy()
			approach.target[4] = pad
			approach.owns_pad = TRUE
	approach.choose_collar()
	return approach

/obj/overmap/entity/proc/select_radar_dock(uid)
	if(!in_free_flight() || docked_ship || length(docked_guests) || docking_approach?.aligning)
		return FALSE
	if(select_own_radar_dock(uid))
		return TRUE
	var/datum/overmap_docking_approach/candidate
	if(local_space)
		for(var/list/target as anything in station_dock_targets(OVERMAP_APPROACH_RANGE, TRUE))
			var/atom/door = target[1]
			if(door.UID() == uid)
				candidate = dock_candidate(target)
				break
	if(!candidate)
		for(var/obj/overmap/entity/other as anything in nearby_ships)
			for(var/list/theirs as anything in other.hull_collars)
				var/turf/door_turf = theirs[1]
				var/obj/machinery/door/airlock/external/docking/door = locate() in door_turf
				if(door?.UID() == uid)
					candidate = dock_candidate(theirs, other)
					break
	if(!candidate)
		return FALSE
	if(!candidate.own || !candidate.available())
		qdel(candidate)
		return FALSE
	QDEL_NULL(docking_approach)
	docking_approach = candidate
	radar_docks_until = 0
	return TRUE

/obj/overmap/entity/proc/select_own_radar_dock(uid)
	if(!docking_approach?.target || docking_approach.aligning)
		return FALSE
	for(var/list/collar as anything in hull_collars)
		var/turf/tile = collar[1]
		var/obj/machinery/door/airlock/external/docking/door = locate() in tile
		if(door?.UID() != uid)
			continue
		var/list/previous = docking_approach.own
		docking_approach.own = collar
		if(!docking_approach.available())
			docking_approach.own = previous
			docking_approach.update_target()
			return FALSE
		radar_docks_until = 0
		return TRUE
	return FALSE

/obj/overmap/entity/proc/prepare_stop()
	if(!in_free_flight() || docked_ship || length(docked_guests) || !local_space?.static_level || docking_approach?.aligning)
		return FALSE
	var/list/center = local_space.to_bubble(get_world_x(), get_world_y())
	var/obj/docking_port/stationary/overmap/landing/pad = new(locate(round(center[1]), round(center[2]), local_space.bubble_z))
	pad.overmap_dock_label = "Остановка в космосе"
	pad.temporary_stop = TRUE
	var/stop_facing = SIMPLIFY_DEGREES(round(get_facing() / 90) * 90)
	var/list/origin = shuttle.overmap_origin()
	pad.setDir(angle2dir(dir2angle(origin[2]) + stop_facing))
	var/list/stop_hull = shuttle.overmap_collect_hull(get_turf(shuttle))
	for(var/radius in 0 to 12)
		for(var/direction in GLOB.cardinal)
			var/turf/spot = locate(round(center[1]) + (direction == EAST ? radius : (direction == WEST ? -radius : 0)), round(center[2]) + (direction == NORTH ? radius : (direction == SOUTH ? -radius : 0)), local_space.bubble_z)
			if(!spot || !local_space.covers(list(spot.x, spot.y), hull_radius))
				continue
			pad.forceMove(spot)
			var/clear = TRUE
			var/list/pairs = shuttle.overmap_move_pairs(pad, stop_hull)
			for(var/turf/tile as anything in pairs[2])
				if(!isspaceturf(tile) || tile.is_blocked_turf())
					clear = FALSE
					break
			if(!clear || shuttle.canDock(pad) != SHUTTLE_CAN_DOCK)
				continue
			QDEL_NULL(docking_approach)
			var/datum/overmap_docking_approach/approach = new(src)
			approach.pad = pad
			approach.space = local_space
			approach.target_facing = stop_facing
			approach.owns_pad = TRUE
			return approach.update_target()
	qdel(pad, TRUE)
	return FALSE

/obj/overmap/entity/proc/prepare_landing(obj/docking_port/stationary/pad)
	if(!in_free_flight() || docked_ship || length(docked_guests) || !pad || docking_approach?.aligning || shuttle.canDock(pad) != SHUTTLE_CAN_DOCK)
		return FALSE
	var/obj/overmap/entity/host = get_dock_host()
	if(!host || !pad_matches_host(pad, host))
		return FALSE
	QDEL_NULL(docking_approach)
	var/datum/overmap_docking_approach/approach = new(src)
	approach.pad = pad
	approach.space = host.physical_space
	var/list/origin = shuttle.overmap_origin()
	approach.target_facing = shuttle.overmap_dir_rotation(origin[2], shuttle.overmap_dest_dir(pad, origin[2]))
	approach.target_x = get_world_x()
	approach.target_y = get_world_y()
	if(in_station_docking_zone() && SSovermap.station_docking_zone.accepts_pad(pad))
		approach.space = null
	return approach.update_target()

/obj/overmap/entity/proc/radar_dock_targets()
	if(radar_docks_cache && world.time < radar_docks_until)
		for(var/list/dock as anything in radar_docks_cache)
			var/obj/overmap/entity/host = dock["host_id"] ? locateUID(dock["host_id"]) : null
			if(!QDELETED(host))
				var/list/point_world = host.hull_to_world(host.hull_center_x + dock["hull_x"], host.hull_center_y + dock["hull_y"])
				dock["x"] = point_world[1]
				dock["y"] = point_world[2]
		return radar_docks_cache
	. = list()
	if(local_space)
		for(var/list/target as anything in station_dock_targets(OVERMAP_RADAR_TERRAIN_RANGE, TRUE))
			var/atom/door = target[1]
			var/turf/tile = target[2]
			var/list/point_world = local_space.to_world(tile.x, tile.y)
			var/datum/overmap_docking_approach/probe = shuttle ? dock_candidate(target) : null
			. += list(list("id" = door.UID(), "name" = target[5], "x" = point_world[1], "y" = point_world[2], "available" = !!probe?.own))
			qdel(probe)
	for(var/obj/overmap/entity/other as anything in nearby_ships)
		for(var/list/collar as anything in other.hull_collars)
			var/turf/tile = collar[1]
			var/obj/machinery/door/airlock/external/docking/door = locate() in tile
			if(!door)
				continue
			var/list/point_world = other.hull_to_world(tile.x, tile.y)
			var/datum/overmap_docking_approach/probe = dock_candidate(collar, other)
			. += list(list("id" = door.UID(), "name" = other.get_overmap_display_name(), "x" = point_world[1], "y" = point_world[2], "host_id" = other.UID(), "hull_x" = tile.x - other.hull_center_x, "hull_y" = tile.y - other.hull_center_y, "available" = !!probe.own))
			qdel(probe)
	if(docking_approach?.target)
		var/list/previous = docking_approach.own
		for(var/list/collar as anything in hull_collars)
			var/turf/tile = collar[1]
			var/obj/machinery/door/airlock/external/docking/door = locate() in tile
			if(!door)
				continue
			docking_approach.own = collar
			var/valid = docking_approach.available()
			var/list/point_world = hull_to_world(tile.x, tile.y)
			. += list(list("id" = door.UID(), "name" = door.get_helm_label(), "x" = point_world[1], "y" = point_world[2], "host_id" = UID(), "hull_x" = tile.x - hull_center_x, "hull_y" = tile.y - hull_center_y, "own" = TRUE, "selected" = collar == previous, "available" = valid))
		docking_approach.own = previous
		docking_approach.update_target()
	radar_docks_cache = .
	radar_docks_until = world.time + (0.5 SECONDS)

/obj/overmap/entity/proc/can_radar_land()
	var/obj/overmap/entity/host = get_dock_host()
	return in_free_flight() && host && (in_station_docking_zone() || !host.project_terrain || host.dock_host?.planet_landing)
