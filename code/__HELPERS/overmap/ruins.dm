/proc/overmap_clear_tile_for_feature(turf/spot)
	if(!spot)
		return
	for(var/obj/overmap/feature/hazard/hazard in spot)
		qdel(hazard)
