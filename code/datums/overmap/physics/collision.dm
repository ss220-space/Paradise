/datum/overmap_bubble/proc/is_solid(turf/spot)
	return overmap_turf_blocked(spot)

/datum/overmap_bubble/proc/solid_turf_at(world_x, world_y)
	var/turf/spot = turf_at(world_x, world_y)
	return is_solid(spot) ? spot : null

/datum/overmap_bubble/proc/solid_face(turf/spot)
	var/face_x = 0
	var/face_y = 0
	for(var/direction in GLOB.cardinal)
		if(is_solid(get_step(spot, direction)))
			continue
		face_x += (direction & EAST) ? 1 : ((direction & WEST) ? -1 : 0)
		face_y += (direction & NORTH) ? 1 : ((direction & SOUTH) ? -1 : 0)
	return list(face_x, face_y)
