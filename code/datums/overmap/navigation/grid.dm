/datum/overmap_bubble/proc/navigation_density()
	if(!navigation_density_cache || world.time >= navigation_density_until)
		navigation_density_cache = list()
		navigation_density_until = world.time + (2 SECONDS)
	return navigation_density_cache

/datum/overmap_bubble/proc/navigation_chunk(list/snapshot, chunk_x, chunk_y)
	var/key = "[chunk_x],[chunk_y]"
	var/list/cached = snapshot[key]
	if(cached)
		return cached
	var/start_x = chunk_x * OVERMAP_RADAR_CHUNK
	var/start_y = chunk_y * OVERMAP_RADAR_CHUNK
	var/low_x = max(bounds[1], start_x)
	var/high_x = min(bounds[3], start_x + OVERMAP_RADAR_CHUNK - 1)
	cached = new /list(OVERMAP_RADAR_CHUNK)
	for(var/row in 1 to OVERMAP_RADAR_CHUNK)
		var/y = start_y + row - 1
		var/bits = 0
		if(y >= bounds[2] && y <= bounds[4])
			for(var/x in low_x to high_x)
				if(is_solid(locate(x, y, bubble_z)))
					bits |= 1 << (x - start_x)
		cached[row] = bits
	snapshot[key] = cached
	return cached

/datum/overmap_navigation_grid
	var/datum/overmap_navigation/navigation
	var/revision
	var/datum/overmap_bubble/space
	var/list/density
	var/list/footprint
	var/list/boxes
	var/list/limits
	var/list/finish
	var/step = 2
	var/path_precision = 0.5
	var/list/frame
	var/frame_time

/datum/overmap_navigation_grid/Destroy()
	navigation = null
	space = null
	density = null
	footprint = null
	boxes = null
	limits = null
	finish = null
	return ..()

/datum/overmap_navigation_grid/New(datum/overmap_navigation/owner, datum/overmap_bubble/host_space, list/obstacles, list/world_limits, list/goal)
	navigation = owner
	revision = owner.revision
	space = host_space
	boxes = obstacles
	limits = world_limits
	finish = goal
	density = space.navigation_density()
	if(QDELETED(owner) || revision != owner.revision || QDELETED(owner.flight) || QDELETED(owner.flight.parent) || QDELETED(space))
		density = null
		return
	var/obj/overmap/entity/vessel = owner.flight.parent
	var/heading = isnull(owner.flight.navigation_facing) ? vessel.get_facing() : owner.flight.navigation_facing
	var/min_x = INFINITY
	var/min_y = INFINITY
	var/max_x = -INFINITY
	var/max_y = -INFINITY
	for(var/turf/tile as anything in vessel.hull_turfs)
		var/dx = tile.x - vessel.hull_center_x
		var/dy = tile.y - vessel.hull_center_y
		var/x = dx * cos(heading) + dy * sin(heading)
		var/y = dy * cos(heading) - dx * sin(heading)
		min_x = min(min_x, x)
		max_x = max(max_x, x)
		min_y = min(min_y, y)
		max_y = max(max_y, y)
	if(min_x == INFINITY)
		min_x = min_y = -vessel.hull_radius
		max_x = max_y = vessel.hull_radius
	var/pad = 0.49 * (abs(cos(heading)) + abs(sin(heading))) + 0.49
	footprint = list(min_x - pad, min_y - pad, max_x + pad, max_y + pad)

/datum/overmap_navigation_grid/proc/terrain_rows(chunk_x, chunk_y)
	return space.navigation_chunk(density, chunk_x, chunk_y)

/datum/overmap_navigation_grid/proc/clear_segments(list/start, list/ends)
	if(!density || QDELETED(space) || !overmap_nav_inside(start, limits))
		return 0
	var/has_candidate = FALSE
	for(var/index in 1 to length(ends))
		var/list/end = ends[index]
		if(!end)
			continue
		if(overmap_nav_inside(end, limits) && overmap_nav_clear(start, end, boxes))
			has_candidate = TRUE
		else
			ends[index] = null
	if(!has_candidate)
		return 0
	if(!frame || frame_time != world.time)
		var/list/region = space.ensure_region()
		frame = region ? list(0, 0, region[1], region[2], space.region_z[1], space.region_z[2]) : list(space.center_x, space.center_y, space.origin_x, space.origin_y, -space.drift_x(), -space.drift_y())
		frame_time = world.time
	return RUSTLIB_CALL(overmap_grid_segments, src, start, ends, space.bounds, footprint, frame)

/datum/overmap_navigation_grid/proc/point_clear(list/point)
	return clear_segments(point, list(point))

/datum/overmap_navigation_grid/proc/segment_clear(list/start, list/end)
	return clear_segments(start, list(end))

/datum/overmap_navigation_grid/proc/find_path(list/start)
	if(!density || !point_clear(finish))
		return null
	if(segment_clear(start, finish))
		return list(finish)
	if(!point_clear(start))
		if(navigation.flight.navigation_ignore_collisions && overmap_nav_clear(start, start, boxes))
			for(var/axis in 1 to 2)
				var/offset = abs(start[axis] - finish[axis])
				if(!offset || offset > path_precision)
					continue
				var/list/aligned = start.Copy()
				aligned[axis] = finish[axis]
				if(overmap_nav_clear(start, aligned, boxes) && segment_clear(aligned, finish))
					path_precision = 0.01
					return list(aligned, finish)
		return null
	var/start_x = round((start[1] - finish[1]) / step)
	var/start_y = round((start[2] - finish[2]) / step)
	var/start_key = "start"
	var/list/heap = list()
	var/list/costs = list()
	var/list/parents = list()
	var/list/closed = list()
	costs[start_key] = 0
	overmap_nav_heap_push(heap, list(start_key, start_x, start_y, 0, 0))
	var/visited = 0
	while(length(heap) && visited++ < 30000)
		var/list/node = overmap_nav_heap_pop(heap)
		var/key = node[1]
		if(closed[key])
			continue
		closed[key] = TRUE
		var/list/from = key == start_key ? start : list(finish[1] + node[2] * step, finish[2] + node[3] * step)
		if(key != start_key && !node[2] && !node[3])
			if(!segment_clear(from, finish))
				return null
			var/list/path = list(finish)
			while(key != start_key)
				var/list/previous = parents[key]
				key = previous[1]
				if(key != start_key)
					path.Insert(1, list(list(finish[1] + previous[2] * step, finish[2] + previous[3] * step)))
			var/list/result = list()
			var/list/anchor = start
			var/list/previous = path[1]
			for(var/index in 2 to length(path))
				var/list/point = path[index]
				if(!segment_clear(anchor, point))
					result += list(previous)
					anchor = previous
				previous = point
				CHECK_TICK
			result += list(finish)
			return result
		var/list/ends = new /list(length(GLOB.alldirs))
		var/list/neighbors = new /list(length(GLOB.alldirs))
		for(var/index in 1 to length(GLOB.alldirs))
			var/direction = GLOB.alldirs[index]
			var/dx = (direction & EAST) ? 1 : ((direction & WEST) ? -1 : 0)
			var/dy = (direction & NORTH) ? 1 : ((direction & SOUTH) ? -1 : 0)
			var/x = node[2] + dx
			var/y = node[3] + dy
			var/next_key = "[x],[y]"
			if(closed[next_key])
				continue
			var/cost = node[5] + ((dx && dy) ? 1.414214 : 1)
			if(!isnull(costs[next_key]) && costs[next_key] <= cost)
				continue
			ends[index] = list(finish[1] + x * step, finish[2] + y * step)
			neighbors[index] = list(next_key, x, y, cost + sqrt(x ** 2 + y ** 2), cost)
		var/clear = clear_segments(from, ends)
		for(var/index in 1 to length(neighbors))
			if(!(clear & (1 << (index - 1))))
				continue
			var/list/neighbor = neighbors[index]
			costs[neighbor[1]] = neighbor[5]
			parents[neighbor[1]] = list(key, node[2], node[3])
			overmap_nav_heap_push(heap, neighbor)
		CHECK_TICK
		if(QDELETED(navigation) || revision != navigation.revision || QDELETED(space))
			return null
	return null
