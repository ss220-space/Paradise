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
	var/low_x = max(bounds[1], chunk_x * OVERMAP_RADAR_CHUNK)
	var/low_y = max(bounds[2], chunk_y * OVERMAP_RADAR_CHUNK)
	var/width = min(bounds[3], (chunk_x + 1) * OVERMAP_RADAR_CHUNK - 1) - low_x + 1
	var/height = min(bounds[4], (chunk_y + 1) * OVERMAP_RADAR_CHUNK - 1) - low_y + 1
	var/stride = width + 1
	var/list/prefix = new /list(stride * (height + 1))
	for(var/row in 1 to height)
		var/sum = 0
		for(var/column in 1 to width)
			var/turf/spot = locate(low_x + column - 1, low_y + row - 1, bubble_z)
			sum += !!is_solid(spot)
			prefix[row * stride + column + 1] = sum + (prefix[(row - 1) * stride + column + 1] || 0)
	cached = list(width, height, low_x, low_y, prefix)
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

/datum/overmap_navigation_grid/proc/point_clear(list/point)
	if(!density || QDELETED(space))
		return FALSE
	if(!overmap_nav_inside(point, limits) || !overmap_nav_clear(point, point, boxes))
		return FALSE
	var/list/local = space.to_bubble(point[1], point[2])
	var/low_x = max(space.bounds[1], CEILING(local[1] + footprint[1], 1))
	var/low_y = max(space.bounds[2], CEILING(local[2] + footprint[2], 1))
	var/high_x = min(space.bounds[3], FLOOR(local[1] + footprint[3], 1))
	var/high_y = min(space.bounds[4], FLOOR(local[2] + footprint[4], 1))
	if(low_x > high_x || low_y > high_y)
		return TRUE
	for(var/chunk_x in FLOOR(low_x / OVERMAP_RADAR_CHUNK, 1) to FLOOR(high_x / OVERMAP_RADAR_CHUNK, 1))
		for(var/chunk_y in FLOOR(low_y / OVERMAP_RADAR_CHUNK, 1) to FLOOR(high_y / OVERMAP_RADAR_CHUNK, 1))
			var/list/chunk = space.navigation_chunk(density, chunk_x, chunk_y)
			var/x1 = max(1, low_x - chunk[3] + 1)
			var/y1 = max(1, low_y - chunk[4] + 1)
			var/x2 = min(chunk[1], high_x - chunk[3] + 1)
			var/y2 = min(chunk[2], high_y - chunk[4] + 1)
			var/list/prefix = chunk[5]
			var/stride = chunk[1] + 1
			if(prefix[y2 * stride + x2 + 1] - prefix[(y1 - 1) * stride + x2 + 1] - prefix[y2 * stride + x1] + prefix[(y1 - 1) * stride + x1])
				return FALSE
	return TRUE

/datum/overmap_navigation_grid/proc/segment_clear(list/start, list/end)
	if(!overmap_nav_clear(start, end, boxes))
		return FALSE
	var/dx = end[1] - start[1]
	var/dy = end[2] - start[2]
	var/count = max(1, CEILING(sqrt(dx ** 2 + dy ** 2) * 2, 1))
	for(var/index in 0 to count)
		if(!point_clear(list(start[1] + dx * index / count, start[2] + dy * index / count)))
			return FALSE
	return TRUE

/datum/overmap_navigation_grid/proc/find_path(list/start)
	if(!density || !point_clear(finish))
		return null
	if(segment_clear(start, finish))
		return list(finish)
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
		for(var/direction in GLOB.alldirs)
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
			var/list/point = list(finish[1] + x * step, finish[2] + y * step)
			if(!segment_clear(from, point))
				continue
			costs[next_key] = cost
			parents[next_key] = list(key, node[2], node[3])
			overmap_nav_heap_push(heap, list(next_key, x, y, cost + sqrt(x ** 2 + y ** 2), cost))
		CHECK_TICK
		if(QDELETED(navigation) || revision != navigation.revision || QDELETED(space))
			return null
	return null
