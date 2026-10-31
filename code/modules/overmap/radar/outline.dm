/obj/overmap/entity/proc/radar_outline()
	if(!project_terrain || dock_host?.planet_landing)
		return null
	if(!radar_outline_busy && (radar_outline_version != hull_version || world.time >= radar_outline_until))
		radar_outline_busy = TRUE
		INVOKE_ASYNC(src, PROC_REF(build_radar_outline))
	return radar_outline_cache

/obj/overmap/entity/proc/build_radar_outline()
	var/version = hull_version
	var/list/occupied = list()
	var/step = hull_radius > 32 || physical_space ? 2 : 1
	if(istype(src, /obj/overmap/entity/virtual_structure))
		var/obj/overmap/entity/virtual_structure/structure = src
		for(var/key in structure.virtual_cells)
			var/list/cell = structure.virtual_cells[key]
			if(cell[4] > 0)
				occupied["[FLOOR((cell[1] - hull_center_x) / step, 1)],[FLOOR((cell[2] - hull_center_y) / step, 1)]"] = TRUE
	else if(length(hull_turfs))
		for(var/turf/spot as anything in hull_turfs)
			if(spot)
				occupied["[FLOOR((spot.x - hull_center_x) / step, 1)],[FLOOR((spot.y - hull_center_y) / step, 1)]"] = TRUE
	else if(physical_space)
		var/datum/overmap_bubble/space = physical_space
		for(var/turf/spot as anything in block(locate(space.bounds[1], space.bounds[2], space.bubble_z), locate(space.bounds[3], space.bounds[4], space.bubble_z)))
			if(!isspaceturf(spot) || (locate(/obj/structure) in spot))
				occupied["[FLOOR((spot.x - space.center_x) / step, 1)],[FLOOR((spot.y - space.center_y) / step, 1)]"] = TRUE
			CHECK_TICK
	var/list/path = list()
	for(var/key in occupied)
		var/list/coords = splittext(key, ",")
		var/x = text2num(coords[1])
		var/y = text2num(coords[2])
		var/px = x * step - 0.5
		var/py = y * step - 0.5
		if(!occupied["[x - 1],[y]"])
			path += "M[px] [py]v[step]"
		if(!occupied["[x + 1],[y]"])
			path += "M[px + step] [py]v[step]"
		if(!occupied["[x],[y - 1]"])
			path += "M[px] [py]h[step]"
		if(!occupied["[x],[y + 1]"])
			path += "M[px] [py + step]h[step]"
		CHECK_TICK
	if(!QDELETED(src) && version == hull_version)
		radar_outline_cache = jointext(path, " ")
		radar_outline_version = version
		radar_outline_until = world.time + (30 SECONDS)
	radar_outline_busy = FALSE
