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
