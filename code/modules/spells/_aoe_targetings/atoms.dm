/datum/aoe_targeting/atoms/get_targets(atom/center, aoe_radius)
	var/list/thrownatoms = list()
	for(var/turf/T in range(center, aoe_radius))
		for(var/atom/movable/AM in T)
			thrownatoms += AM
	return thrownatoms
