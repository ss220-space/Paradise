/proc/overmap_hazard_clusters(datum/overmap_sector/sector)
	. = list()
	if(!sector)
		return
	if(sector.hazard_clusters)
		return sector.hazard_clusters
	var/list/all = list()
	var/list/by_cell = list()
	for(var/obj/overmap/feature/hazard/hazard in sector.objects)
		var/turf/spot = hazard.loc
		if(!isturf(spot))
			continue
		all += hazard
		var/cell_key = "[spot.x],[spot.y]"
		var/list/bucket = by_cell[cell_key]
		if(!bucket)
			bucket = list()
			by_cell[cell_key] = bucket
		bucket += hazard
	var/list/taken = list()
	for(var/obj/overmap/feature/hazard/seed as anything in all)
		if(taken[seed])
			continue
		taken[seed] = TRUE
		var/list/group = list(seed)
		var/index = 1
		while(index <= length(group))
			var/obj/overmap/feature/hazard/current = group[index]
			index++
			var/turf/here = current.loc
			if(!isturf(here))
				continue
			for(var/offset_x in -1 to 1)
				for(var/offset_y in -1 to 1)
					var/list/bucket = by_cell["[here.x + offset_x],[here.y + offset_y]"]
					if(!bucket)
						continue
					for(var/obj/overmap/feature/hazard/other as anything in bucket)
						if(taken[other] || other.icon_state != seed.icon_state)
							continue
						taken[other] = TRUE
						group += other
		. += list(group)
	sector.hazard_clusters = .

/proc/overmap_hazard_cluster_density(list/group)
	if(!length(group))
		return 0
	var/total = 0
	for(var/obj/overmap/feature/hazard/point as anything in group)
		total += point.hazard_density
	return round(total / length(group))

/proc/overmap_hazard_cluster_of(datum/overmap_sector/sector, obj/overmap/feature/hazard/hazard)
	if(!sector || !hazard)
		return list()
	for(var/list/group as anything in overmap_hazard_clusters(sector))
		if(hazard in group)
			return group
	return list()

/proc/overmap_hazard_spawn_blocked(datum/overmap_sector/sector, turf/spot)
	if(!sector || !spot)
		return TRUE
	if(sector.turf_occupied(spot))
		return TRUE
	if(SSovermap.lavaland_planet?.covers_turf(spot))
		return TRUE
	if(locate(/obj/overmap/feature/hazard) in spot)
		return TRUE
	if(locate(/obj/overmap/portal) in spot)
		return TRUE
	var/obj/overmap/entity/station = SSovermap?.station_entity
	if(station?.loc && max(abs(spot.x - station.loc.x), abs(spot.y - station.loc.y)) <= 1)
		return TRUE
	return FALSE

/proc/overmap_hazard_edge_weight(datum/overmap_sector/sector, turf/spot)
	var/center_x = sector.origin_x + round(sector.size / 2)
	var/center_y = sector.origin_y + round(sector.size / 2)
	var/dist = max(abs(spot.x - center_x), abs(spot.y - center_y))
	var/max_dist = max(1, round(sector.size / 2) - OVERMAP_EDGE)
	var/ratio = clamp(dist / max_dist, 0, 1)
	return 0.14 + 0.86 * ratio * ratio

/proc/overmap_hazard_pick_start(datum/overmap_sector/sector)
	var/low_x = sector.origin_x + OVERMAP_EDGE
	var/low_y = sector.origin_y + OVERMAP_EDGE
	var/high_x = sector.origin_x + sector.size - OVERMAP_EDGE - 1
	var/high_y = sector.origin_y + sector.size - OVERMAP_EDGE - 1
	var/list/bag = list()
	for(var/turf/spot as anything in block(locate(low_x, low_y, sector.z_level), locate(high_x, high_y, sector.z_level)))
		if(overmap_hazard_spawn_blocked(sector, spot))
			continue
		var/weight = overmap_hazard_edge_weight(sector, spot)
		bag[spot] = max(1, round(weight * 100))
	if(!length(bag))
		return null
	return pickweight(bag)

/proc/overmap_hazard_place(hazard_type, datum/overmap_sector/sector, turf/spot)
	if(overmap_hazard_spawn_blocked(sector, spot))
		return null
	var/obj/overmap/feature/hazard/hazard = new hazard_type(spot)
	hazard.hazard_density = overmap_hazard_cluster_fill(spot, hazard)
	sector.add_object(hazard, spot)
	return hazard

/proc/overmap_hazard_cluster_fill(turf/spot, obj/overmap/feature/hazard/hazard)
	for(var/turf/neighbour in orange(1, spot))
		if(neighbour.z != spot.z)
			continue
		for(var/obj/overmap/feature/hazard/other in neighbour)
			if(other.icon_state == hazard.icon_state)
				return other.hazard_density
	return hazard.roll_density()

/proc/overmap_hazard_paint_line(hazard_type, datum/overmap_sector/sector, turf/start, length, dir, wobble = FALSE)
	var/placed_count = 0
	var/turf/cursor = start
	for(var/i in 1 to length)
		if(!cursor)
			break
		if(overmap_hazard_place(hazard_type, sector, cursor))
			placed_count++
		if(wobble && prob(35))
			var/turf/side = get_step(cursor, turn(dir, pick(-90, 90)))
			if(side && !overmap_hazard_spawn_blocked(sector, side))
				overmap_hazard_place(hazard_type, sector, side)
				placed_count++
		cursor = get_step(cursor, dir)
		if(!cursor || cursor.z != sector.z_level)
			break
		if(cursor.x < sector.origin_x + OVERMAP_EDGE || cursor.x > sector.origin_x + sector.size - OVERMAP_EDGE - 1)
			break
		if(cursor.y < sector.origin_y + OVERMAP_EDGE || cursor.y > sector.origin_y + sector.size - OVERMAP_EDGE - 1)
			break
	return placed_count

/proc/overmap_hazard_paint_blob(hazard_type, datum/overmap_sector/sector, turf/start, size)
	var/placed_count = 0
	var/list/open = list(start)
	var/list/seen = list()
	while(length(open) && placed_count < size)
		var/turf/cursor = pick_n_take(open)
		if(seen[cursor])
			continue
		seen[cursor] = TRUE
		if(overmap_hazard_place(hazard_type, sector, cursor))
			placed_count++
		for(var/dir in GLOB.cardinal)
			var/turf/next = get_step(cursor, dir)
			if(!next || seen[next] || overmap_hazard_spawn_blocked(sector, next))
				continue
			if(next.x < sector.origin_x + OVERMAP_EDGE || next.x > sector.origin_x + sector.size - OVERMAP_EDGE - 1)
				continue
			if(next.y < sector.origin_y + OVERMAP_EDGE || next.y > sector.origin_y + sector.size - OVERMAP_EDGE - 1)
				continue
			open += next
	return placed_count

/proc/overmap_hazard_paint_arc(hazard_type, datum/overmap_sector/sector, turf/start, length, dir)
	var/placed_count = 0
	var/turf/cursor = start
	var/heading = dir
	for(var/i in 1 to length)
		if(!cursor)
			break
		if(overmap_hazard_place(hazard_type, sector, cursor))
			placed_count++
		if(prob(40))
			heading = turn(heading, pick(-45, 45))
			if(!heading)
				heading = dir
		cursor = get_step(cursor, heading)
		if(!cursor || cursor.z != sector.z_level)
			break
		if(cursor.x < sector.origin_x + OVERMAP_EDGE || cursor.x > sector.origin_x + sector.size - OVERMAP_EDGE - 1)
			break
		if(cursor.y < sector.origin_y + OVERMAP_EDGE || cursor.y > sector.origin_y + sector.size - OVERMAP_EDGE - 1)
			break
	return placed_count

/proc/overmap_hazard_paint_ring(hazard_type, datum/overmap_sector/sector, turf/start, radius, count)
	var/placed_count = 0
	if(!start)
		return placed_count
	var/list/ring = list()
	for(var/turf/spot in orange(radius, start))
		if(get_dist(start, spot) != radius)
			continue
		if(spot.z != sector.z_level)
			continue
		if(spot.x < sector.origin_x + OVERMAP_EDGE || spot.x > sector.origin_x + sector.size - OVERMAP_EDGE - 1)
			continue
		if(spot.y < sector.origin_y + OVERMAP_EDGE || spot.y > sector.origin_y + sector.size - OVERMAP_EDGE - 1)
			continue
		ring += spot
	if(!length(ring))
		return overmap_hazard_paint_blob(hazard_type, sector, start, count)
	for(var/i in 1 to min(count, length(ring)))
		var/turf/spot = pick_n_take(ring)
		if(overmap_hazard_place(hazard_type, sector, spot))
			placed_count++
	return placed_count

/proc/overmap_hazard_paint_scatter(hazard_type, datum/overmap_sector/sector, turf/start, count, spread)
	var/placed_count = 0
	if(!start)
		return placed_count
	var/list/pool = list(start)
	for(var/turf/spot in orange(spread, start))
		if(spot.z != sector.z_level)
			continue
		if(spot.x < sector.origin_x + OVERMAP_EDGE || spot.x > sector.origin_x + sector.size - OVERMAP_EDGE - 1)
			continue
		if(spot.y < sector.origin_y + OVERMAP_EDGE || spot.y > sector.origin_y + sector.size - OVERMAP_EDGE - 1)
			continue
		pool += spot
	for(var/i in 1 to count)
		if(!length(pool))
			break
		var/turf/spot = pick_n_take(pool)
		if(overmap_hazard_place(hazard_type, sector, spot))
			placed_count++
	return placed_count

/proc/overmap_hazard_paint_elbow(hazard_type, datum/overmap_sector/sector, turf/start, length, dir)
	var/placed_count = overmap_hazard_paint_line(hazard_type, sector, start, max(2, round(length / 2)), dir, FALSE)
	var/turf/corner = start
	for(var/i in 1 to max(1, round(length / 2)))
		corner = get_step(corner, dir)
		if(!corner)
			return placed_count
	placed_count += overmap_hazard_paint_line(hazard_type, sector, corner, max(2, length - round(length / 2)), turn(dir, pick(-90, 90)), TRUE)
	return placed_count

/proc/overmap_hazard_paint_random(hazard_type, datum/overmap_sector/sector, turf/start)
	if(!start)
		return 0
	var/list/line_dirs = list(NORTH, SOUTH, EAST, WEST, NORTHEAST, NORTHWEST, SOUTHEAST, SOUTHWEST)
	switch(rand(1, 6))
		if(1)
			return overmap_hazard_paint_line(hazard_type, sector, start, rand(4, 9), pick(line_dirs), TRUE)
		if(2)
			return overmap_hazard_paint_line(hazard_type, sector, start, rand(5, 10), pick(line_dirs), FALSE)
		if(3)
			return overmap_hazard_paint_blob(hazard_type, sector, start, rand(4, 8))
		if(4)
			return overmap_hazard_paint_arc(hazard_type, sector, start, rand(5, 9), pick(line_dirs))
		if(5)
			return overmap_hazard_paint_ring(hazard_type, sector, start, rand(2, 3), rand(5, 9))
		else
			if(prob(50))
				return overmap_hazard_paint_scatter(hazard_type, sector, start, rand(4, 7), rand(2, 3))
			return overmap_hazard_paint_elbow(hazard_type, sector, start, rand(5, 8), pick(line_dirs))

/proc/spawn_static_overmap_hazards(datum/overmap_sector/sector)
	if(!sector || sector.hazard_spawn_weight <= 0)
		return
	var/scale = sector.hazard_spawn_weight * (sector.size / OVERMAP_DEFAULT_SIZE)
	var/list/types = list("asteroids" = /obj/overmap/feature/hazard/asteroid, "emp" = /obj/overmap/feature/hazard/emp, "carp" = /obj/overmap/feature/hazard/carp)
	for(var/key in types)
		var/weight = sector.galaxy_generation?[key]
		if(!isnum(weight))
			weight = 1
		if(weight <= 0)
			continue
		var/base_count = key == "asteroids" ? rand(2, 3) : rand(1, 2)
		scatter_overmap_hazard_type(sector, types[key], min(30, max(1, round(base_count * scale * weight))))

/proc/scatter_overmap_hazard_type(datum/overmap_sector/sector, hazard_type, amount)
	for(var/i in 1 to amount)
		var/turf/start = overmap_hazard_pick_start(sector)
		if(!start)
			break
		overmap_hazard_paint_random(hazard_type, sector, start)
