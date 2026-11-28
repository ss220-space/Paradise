/proc/weapon_turf_opaque(turf/spot)
	if(!spot)
		return FALSE
	if(spot.opacity)
		return TRUE
	for(var/atom/movable/object in spot)
		if(object.opacity && !QDELETED(object))
			return TRUE
	return FALSE
