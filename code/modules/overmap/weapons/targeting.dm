/datum/controller/subsystem/overmap/proc/weapon_line_clear(datum/overmap_sector/sector, list/start, list/finish)
	var/dx = finish[1] - start[1]
	var/dy = finish[2] - start[2]
	var/distance = sqrt(dx ** 2 + dy ** 2)
	var/steps = max(1, CEILING(distance / 0.5, 1))
	for(var/obj/overmap/entity/vessel as anything in flying_vessels)
		if(vessel.sector != sector)
			continue
		var/origin_x = vessel.get_world_x()
		if(abs(origin_x - start[1]) > vessel.hull_radius + distance)
			continue
		var/origin_y = vessel.get_world_y()
		if(abs(origin_y - start[2]) > vessel.hull_radius + distance)
			continue
		var/facing = vessel.get_facing()
		if(istype(vessel, /obj/overmap/entity/virtual_structure))
			var/obj/overmap/entity/virtual_structure/structure = vessel
			var/list/pose = list(origin_x, origin_y, facing)
			for(var/step in 0 to steps - 1)
				if(structure.cell_at(start[1] + dx * step / steps, start[2] + dy * step / steps, TRUE, pose))
					return FALSE
		else if(length(vessel.hull_turfs) && vessel.hull_z)
			var/turf/previous
			for(var/step in 0 to steps - 1)
				var/turf/spot = vessel.hull_turf_at(start[1] + dx * step / steps, start[2] + dy * step / steps, origin_x, origin_y, facing)
				if(spot != previous && weapon_turf_opaque(spot))
					return FALSE
				previous = spot
	var/list/ray_bounds = list(min(start[1], finish[1]) - 1, min(start[2], finish[2]) - 1, max(start[1], finish[1]) + 1, max(start[2], finish[2]) + 1)
	var/list/sector_spaces = sector ? sector.bubbles : bubbles
	for(var/datum/overmap_bubble/space as anything in sector_spaces)
		if(!space.static_level || space.sector != sector)
			continue
		var/list/region = space.ensure_region()
		if(region && !regions_overlap(ray_bounds, region))
			continue
		var/turf/previous
		for(var/step in 0 to steps - 1)
			var/turf/spot = space.turf_at(start[1] + dx * step / steps, start[2] + dy * step / steps)
			if(spot != previous && weapon_turf_opaque(spot))
				return FALSE
			previous = spot
	return TRUE
