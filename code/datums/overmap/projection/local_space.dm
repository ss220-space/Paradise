/datum/overmap_bubble/proc/sync_host_region()
	if(!host)
		return

	if(!sector && host.sector)
		sector = host.sector
	origin_x = host.get_world_x()
	origin_y = host.get_world_y()
	region = null
	region_z = null
	ensure_region()

/datum/overmap_bubble/proc/terrain_chunk(chunk_x, chunk_y)
	var/key = "[chunk_x]_[chunk_y]"
	var/list/cached = terrain_chunks[key]
	if(cached && world.time < cached[1])
		return cached
	cached = list(world.time + 1 SECONDS)
	var/turf/low = locate(max(chunk_x * OVERMAP_RADAR_CHUNK, 1), max(chunk_y * OVERMAP_RADAR_CHUNK, 1), bubble_z)
	var/turf/high = locate(min(chunk_x * OVERMAP_RADAR_CHUNK + OVERMAP_RADAR_CHUNK - 1, world.maxx), min(chunk_y * OVERMAP_RADAR_CHUNK + OVERMAP_RADAR_CHUNK - 1, world.maxy), bubble_z)
	for(var/turf/spot as anything in block(low, high))
		if(covers(list(spot.x, spot.y), 0) && (!isspaceturf(spot) || (locate(/obj/structure) in spot)))
			cached += spot
	terrain_chunks[key] = cached
	return cached

/datum/overmap_bubble/proc/terrain_near(list/spot, reach)
	var/low_x = max(FLOOR(spot[1] - reach, 1), bounds[1])
	var/low_y = max(FLOOR(spot[2] - reach, 1), bounds[2])
	var/high_x = min(CEILING(spot[1] + reach, 1), bounds[3])
	var/high_y = min(CEILING(spot[2] + reach, 1), bounds[4])
	if(low_x > high_x || low_y > high_y)
		return FALSE
	for(var/turf/nearby as anything in block(locate(low_x, low_y, bubble_z), locate(high_x, high_y, bubble_z)))
		if(is_solid(nearby))
			return TRUE
	return FALSE

/datum/overmap_bubble/proc/radar_chunk(chunk_x, chunk_y)
	var/key = "[chunk_x]_[chunk_y]"
	var/list/cached = radar_chunks[key]
	if(cached && world.time < cached[OVERMAP_RADAR_EXPIRY])
		return cached
	var/static/list/wall_types = typecacheof(list(/obj/structure/window, /obj/structure/falsewall, /obj/machinery/door/airlock, /obj/machinery/door/poddoor, /obj/machinery/door/window))
	var/static/list/frame_types = typecacheof(list(/obj/structure/lattice, /obj/structure/grille, /obj/machinery/power/solar, /obj/machinery/power/tracker))
	var/list/runs = list(list(), list(), list())
	var/low_x = max(chunk_x * OVERMAP_RADAR_CHUNK, bounds[1])
	var/high_x = min(chunk_x * OVERMAP_RADAR_CHUNK + OVERMAP_RADAR_CHUNK - 1, bounds[3])
	for(var/row in max(chunk_y * OVERMAP_RADAR_CHUNK, bounds[2]) to min(chunk_y * OVERMAP_RADAR_CHUNK + OVERMAP_RADAR_CHUNK - 1, bounds[4]))
		var/run_kind = 0
		var/run_start = 0
		for(var/column in low_x to high_x + 1)
			var/kind = 0
			if(column <= high_x)
				var/turf/spot = locate(column, row, bubble_z)
				if(!isspaceturf(spot))
					kind = spot.density ? OVERMAP_RADAR_WALL : OVERMAP_RADAR_FLOOR
				for(var/atom/movable/thing as anything in spot)
					if(wall_types[thing.type])
						kind = OVERMAP_RADAR_WALL
						break
					if(!kind && frame_types[thing.type])
						kind = OVERMAP_RADAR_FRAME
			if(kind == run_kind)
				continue
			if(run_kind)
				var/list/target = runs[run_kind]
				target += run_start
				target += row
				target += column - run_start
			run_kind = kind
			run_start = column
	runs += world.time + OVERMAP_RADAR_CHUNK_REFRESH
	radar_chunks[key] = runs
	return runs
