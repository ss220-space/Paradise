/datum/controller/subsystem/overmap/proc/weapon_line_clear(datum/overmap_sector/sector, list/start, list/finish)
	var/dx = finish[1] - start[1]
	var/dy = finish[2] - start[2]
	var/distance = sqrt(dx ** 2 + dy ** 2)
	var/list/nearby = list()
	for(var/obj/overmap/entity/vessel as anything in flying_vessels)
		if(vessel.sector == sector && abs(vessel.get_world_x() - start[1]) <= vessel.hull_radius + distance && abs(vessel.get_world_y() - start[2]) <= vessel.hull_radius + distance)
			nearby += vessel
	var/steps = max(1, CEILING(distance / 0.5, 1))
	for(var/step in 0 to steps - 1)
		var/x = start[1] + dx * step / steps
		var/y = start[2] + dy * step / steps
		for(var/obj/overmap/entity/vessel as anything in nearby)
			if(istype(vessel, /obj/overmap/entity/virtual_structure))
				var/obj/overmap/entity/virtual_structure/structure = vessel
				if(structure.cell_at(x, y, TRUE))
					return FALSE
				continue
			if(weapon_turf_opaque(vessel.hull_turf_at(x, y)))
				return FALSE
		for(var/datum/overmap_bubble/space as anything in bubbles)
			if(space.static_level && space.sector == sector && weapon_turf_opaque(space.turf_at(x, y)))
				return FALSE
	return TRUE
