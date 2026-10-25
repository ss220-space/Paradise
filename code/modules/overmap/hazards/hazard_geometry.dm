/datum/overmap_sector
	var/list/hazard_shapes

/obj/overmap/feature/hazard/proc/cloud_strength(world_x, world_y)
	var/span = OVERMAP_TILE_SPAN * (sector?.tile_travel || 1)
	var/cx = world_x / span
	var/cy = world_y / span
	var/strength = 0
	var/flavour = hazard_flavour(src)
	for(var/ix in round(cx) - 1 to round(cx) + 1)
		for(var/iy in round(cy) - 1 to round(cy) + 1)
			var/turf/cell = locate(ix, iy, z)
			for(var/obj/overmap/feature/hazard/other in cell)
				if(hazard_flavour(other) != flavour)
					continue
				strength += max(0, 1 - ((cx - other.x) ** 2 + (cy - other.y) ** 2) / 0.8)
	var/noise = sin(cx * 361 + cy * 173) * 0.08 + sin(cx * 719 - cy * 431) * 0.05
	return max(0, strength - 0.42 + noise)

/obj/overmap/feature/hazard/proc/cloud_owns_point(world_x, world_y)
	var/span = OVERMAP_TILE_SPAN * (sector?.tile_travel || 1)
	var/cx = world_x / span
	var/cy = world_y / span
	var/obj/overmap/feature/hazard/nearest
	var/distance = INFINITY
	var/flavour = hazard_flavour(src)
	for(var/ix in round(cx) - 1 to round(cx) + 1)
		for(var/iy in round(cy) - 1 to round(cy) + 1)
			var/turf/cell = locate(ix, iy, z)
			for(var/obj/overmap/feature/hazard/other in cell)
				if(hazard_flavour(other) != flavour)
					continue
				var/offset = (cx - other.x) ** 2 + (cy - other.y) ** 2
				if(offset < distance)
					nearest = other
					distance = offset
	return nearest == src

/proc/overmap_hazard_contours(datum/overmap_sector/sector, list/group)
	LAZYINITLIST(sector.hazard_shapes)
	var/obj/overmap/feature/hazard/seed = group[1]
	var/key = seed.UID()
	if(sector.hazard_shapes[key])
		return sector.hazard_shapes[key]
	var/list/samples = list()
	var/list/visited = list()
	var/span = OVERMAP_TILE_SPAN * (sector.tile_travel || 1)
	for(var/obj/overmap/feature/hazard/field as anything in group)
		for(var/ix in field.x * 8 - 7 to field.x * 8 + 6)
			for(var/iy in field.y * 8 - 7 to field.y * 8 + 6)
				var/sample_key = "[ix],[iy]"
				if(visited[sample_key])
					continue
				visited[sample_key] = TRUE
				if(seed.cloud_strength((ix + 0.5) * span / 8, (iy + 0.5) * span / 8) > 0)
					samples[sample_key] = list(ix, iy)
		CHECK_TICK
	var/list/edges = list()
	for(var/sample_key in samples)
		var/list/point = samples[sample_key]
		var/x = point[1]
		var/y = point[2]
		if(!samples["[x],[y - 1]"])
			overmap_cloud_edge(edges, x, y, x + 1, y)
		if(!samples["[x + 1],[y]"])
			overmap_cloud_edge(edges, x + 1, y, x + 1, y + 1)
		if(!samples["[x],[y + 1]"])
			overmap_cloud_edge(edges, x + 1, y + 1, x, y + 1)
		if(!samples["[x - 1],[y]"])
			overmap_cloud_edge(edges, x, y + 1, x, y)
	var/list/rings = list()
	while(length(edges))
		var/start = edges[1]
		var/cursor = start
		var/list/ring = list()
		while(edges[cursor])
			var/list/outgoing = edges[cursor]
			var/list/edge = outgoing[length(outgoing)]
			outgoing.len--
			if(!length(outgoing))
				edges -= cursor
			ring += (edge[1] / 8 - sector.origin_x + 1)
			ring += (edge[2] / 8 - sector.origin_y + 1)
			cursor = "[edge[3]],[edge[4]]"
			if(cursor == start)
				break
		if(length(ring) >= 6)
			rings += list(ring)
	sector.hazard_shapes[key] = rings
	return rings

/proc/overmap_cloud_edge(list/edges, x, y, to_x, to_y)
	var/key = "[x],[y]"
	LAZYADD(edges[key], list(list(x, y, to_x, to_y)))
