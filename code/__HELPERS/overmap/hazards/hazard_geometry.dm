/proc/overmap_hazard_contours(datum/overmap_sector/sector, list/group)
	LAZYINITLIST(sector.hazard_shapes)
	var/obj/overmap/feature/hazard/seed = group[1]
	var/key = seed.UID()
	if(isnull(sector.hazard_shapes[key]))
		sector.hazard_shapes[key] = list()
		INVOKE_ASYNC(GLOBAL_PROC, GLOBAL_PROC_REF(build_overmap_hazard_contours), sector, group)
	return sector.hazard_shapes[key]

/proc/build_overmap_hazard_contours(datum/overmap_sector/sector, list/group)
	LAZYINITLIST(sector.hazard_shapes)
	var/list/cache = sector.hazard_shapes
	var/obj/overmap/feature/hazard/seed = group[1]
	var/key = seed.UID()
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
	if(sector.hazard_shapes == cache)
		cache[key] = rings
	return rings

/proc/overmap_cloud_edge(list/edges, x, y, to_x, to_y)
	var/key = "[x],[y]"
	LAZYADD(edges[key], list(list(x, y, to_x, to_y)))
