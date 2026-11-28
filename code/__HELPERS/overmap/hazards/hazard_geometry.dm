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
	var/list/fields = list()
	var/list/contributors = list()
	var/list/visited = list()
	var/flavour = hazard_flavour(seed)
	for(var/obj/overmap/feature/hazard/field as anything in group)
		fields += field.x
		fields += field.y
		for(var/x in field.x - 1 to field.x + 1)
			for(var/y in field.y - 1 to field.y + 1)
				var/turf/tile = locate(x, y, seed.z)
				if(!tile || visited[tile])
					continue
				visited[tile] = TRUE
				for(var/obj/overmap/feature/hazard/neighbor in tile)
					if(hazard_flavour(neighbor) == flavour)
						contributors += x
						contributors += y
		CHECK_TICK
	var/list/rings = RUSTLIB_CALL(overmap_hazard_rings, fields, contributors, sector.origin_x, sector.origin_y, OVERMAP_TILE_SPAN * (sector.tile_travel || 1))
	if(sector.hazard_shapes == cache)
		cache[key] = rings
	return rings
