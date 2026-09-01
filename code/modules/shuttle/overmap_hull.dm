/obj/docking_port/mobile/proc/overmap_origin()
	if(overmap_collar && !QDELETED(overmap_collar) && !overmap_collar.overmap_is_support)
		var/turf/collar_turf = get_turf(overmap_collar)
		if(collar_turf)
			return list(collar_turf, REVERSE_DIR(overmap_collar.dir))
	return list(get_turf(src), dir)

/obj/docking_port/mobile/proc/overmap_restore_mapped_bounds()
	if(!mapped_width)
		return
	width = mapped_width
	height = mapped_height
	dwidth = mapped_dwidth
	dheight = mapped_dheight

/obj/docking_port/mobile/proc/overmap_uses_area_hull()
	if(SSovermap?.shuttle_vessels[src])
		return TRUE
	if(overmap_collar && !QDELETED(overmap_collar))
		return TRUE
	return areaInstance && (locate(/obj/machinery/door/airlock/external/docking) in areaInstance)

/obj/docking_port/mobile/proc/overmap_sync_bounds(force_area = FALSE)
	var/list/origin = overmap_origin()
	var/turf/origin_turf = origin[1]
	var/origin_dir = origin[2]
	if(!origin_turf)
		overmap_restore_mapped_bounds()
		return origin
	if(force_area || overmap_uses_area_hull())
		overmap_fit_bounds(origin_turf, origin_dir)
		return origin
	overmap_restore_mapped_bounds()
	return origin

/obj/docking_port/mobile/proc/overmap_is_hull_turf(turf/spot)
	if(!spot)
		return FALSE
	var/area/place = get_area(spot)
	if(!place || istype(place, /area/shuttle/transit))
		return FALSE
	if(place == areaInstance)
		return TRUE
	if(shuttle_areas && shuttle_areas[place])
		return TRUE
	if(!areaInstance || areaInstance.type == /area/shuttle)
		return FALSE
	return istype(place, areaInstance.type)

/obj/docking_port/mobile/proc/overmap_discover_shuttle_areas()
	if(!shuttle_areas)
		shuttle_areas = list()
	if(areaInstance)
		shuttle_areas[areaInstance] = TRUE
	for(var/turf/tile in return_turfs())
		if(!tile)
			continue
		var/area/place = get_area(tile)
		if(!place || istype(place, /area/shuttle/transit))
			continue
		if(place == areaInstance || (areaInstance && istype(place, areaInstance.type)) || shuttle_areas[place])
			shuttle_areas[place] = TRUE

/obj/docking_port/mobile/proc/overmap_collect_hull(turf/origin)
	. = list()
	if(!origin)
		return
	var/list/seen = list()
	var/list/areas = list()
	if(areaInstance)
		areas[areaInstance] = TRUE
	for(var/area/place as anything in shuttle_areas)
		areas[place] = TRUE
	for(var/area/place as anything in areas)
		if(!place || istype(place, /area/shuttle/transit))
			continue
		place.cannonize_contained_turfs_by_zlevel(origin.z)
		for(var/turf/tile as anything in place.get_turfs_by_zlevel(origin.z))
			if(!tile || seen[tile])
				continue
			seen[tile] = TRUE
			. += tile

/obj/docking_port/mobile/proc/overmap_dir_rotation(from_dir, to_dir)
	if(!from_dir || !to_dir || from_dir == to_dir)
		return 0
	var/angle = round((dir2angle(to_dir) - dir2angle(from_dir)) / 90, 1) * 90
	while(angle < 0)
		angle += 360
	while(angle >= 360)
		angle -= 360
	return angle

/obj/docking_port/mobile/proc/overmap_rotate_vec(dx, dy, rotation)
	while(rotation < 0)
		rotation += 360
	while(rotation >= 360)
		rotation -= 360
	switch(rotation)
		if(90)
			return list(dy, -dx)
		if(180)
			return list(-dx, -dy)
		if(270)
			return list(-dy, dx)
	return list(dx, dy)

/obj/docking_port/mobile/proc/overmap_dest_turf(obj/docking_port/stationary/S)
	if(istype(S, /obj/docking_port/stationary/overmap/landing))
		return get_turf(S)
	if(S?.dock_airlock)
		return get_step(S.dock_airlock, S.dock_airlock.dir) || get_turf(S)
	return get_turf(S)

/obj/docking_port/mobile/proc/overmap_hull_center(list/hull)
	if(!length(hull))
		return null
	var/sx = 0
	var/sy = 0
	var/turf/sample
	for(var/turf/tile as anything in hull)
		if(!tile)
			continue
		sx += tile.x
		sy += tile.y
		sample = tile
	if(!sample)
		return null
	return locate(round(sx / length(hull)), round(sy / length(hull)), sample.z)

/obj/docking_port/mobile/proc/overmap_dest_dir(obj/docking_port/stationary/S, origin_dir)
	if(istype(S, /obj/docking_port/stationary/transit) || istype(S, /obj/docking_port/stationary/overmap/landing))
		return origin_dir
	if(S?.dock_airlock)
		return S.dock_airlock.dir
	return S.dir

/obj/docking_port/mobile/proc/overmap_project_turf(turf/oldT, turf/origin, origin_dir, turf/dest, dest_dir)
	if(!oldT || !origin || !dest)
		return null
	var/rotation = overmap_dir_rotation(origin_dir, dest_dir)
	var/list/rot = overmap_rotate_vec(oldT.x - origin.x, oldT.y - origin.y, rotation)
	return locate(dest.x + rot[1], dest.y + rot[2], dest.z)

/obj/docking_port/mobile/proc/overmap_fit_bounds(turf/origin, origin_dir, list/hull)
	if(!hull)
		hull = overmap_collect_hull(origin)
	if(!length(hull))
		overmap_restore_mapped_bounds()
		return
	var/min_right
	var/max_right
	var/min_forward
	var/max_forward
	for(var/turf/tile as anything in hull)
		var/dx = tile.x - origin.x
		var/dy = tile.y - origin.y
		var/right
		var/forward
		switch(origin_dir)
			if(NORTH)
				right = dx
				forward = dy
			if(SOUTH)
				right = -dx
				forward = -dy
			if(EAST)
				right = -dy
				forward = dx
			if(WEST)
				right = dy
				forward = -dx
			else
				right = dx
				forward = dy
		if(isnull(min_right))
			min_right = right
			max_right = right
			min_forward = forward
			max_forward = forward
		else
			min_right = min(min_right, right)
			max_right = max(max_right, right)
			min_forward = min(min_forward, forward)
			max_forward = max(max_forward, forward)
		var/area/place = get_area(tile)
		if(place && shuttle_areas)
			shuttle_areas[place] = TRUE
	width = max_right - min_right + 1
	height = max_forward - min_forward + 1
	dwidth = -min_right
	dheight = -min_forward

/obj/docking_port/mobile/proc/overmap_move_pairs(obj/docking_port/stationary/S)
	. = list(list(), list())
	if(!S)
		return
	var/list/origin = overmap_origin()
	var/turf/origin_turf = origin[1]
	var/origin_dir = origin[2]
	if(!origin_turf)
		return
	var/list/hull = overmap_collect_hull(origin_turf)
	overmap_fit_bounds(origin_turf, origin_dir, hull)
	var/turf/proj_origin = origin_turf
	if(istype(S, /obj/docking_port/stationary/overmap/landing))
		var/turf/center = overmap_hull_center(hull)
		if(center)
			proj_origin = center
	var/dest_dir = overmap_dest_dir(S, origin_dir)
	var/turf/dest = overmap_dest_turf(S)
	var/list/old_turfs = .[1]
	var/list/new_turfs = .[2]
	for(var/turf/oldT as anything in hull)
		if(is_turf_blacklisted_for_transit(oldT))
			continue
		var/turf/newT = overmap_project_turf(oldT, proj_origin, origin_dir, dest, dest_dir)
		old_turfs += oldT
		new_turfs += newT

/obj/docking_port/mobile/proc/overmap_dest_turfs(obj/docking_port/stationary/S)
	var/list/pairs = overmap_move_pairs(S)
	return pairs[2]

/obj/docking_port/mobile/proc/overmap_hull_blocked(obj/docking_port/stationary/S)
	if(!S || istype(S, /obj/docking_port/stationary/transit))
		return FALSE
	var/list/pairs = overmap_move_pairs(S)
	var/list/old_turfs = pairs[1]
	var/list/new_turfs = pairs[2]
	if(!length(old_turfs))
		return TRUE
	for(var/i in 1 to length(old_turfs))
		var/turf/newT = new_turfs[i]
		if(overmap_dest_tile_blocked(newT, S))
			return TRUE
	return FALSE
