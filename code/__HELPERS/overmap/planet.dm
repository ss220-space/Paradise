/proc/overmap_lavaland_landing_blocked(turf/spot)
	if(!spot)
		return TRUE
	if(spot.density)
		return TRUE
	if(islava(spot) || ischasm(spot) || isopenspaceturf(spot))
		return TRUE
	if(ismineralturf(spot))
		return TRUE
	if(locate(/obj/structure/spawner/lavaland) in spot)
		return TRUE
	for(var/mob/living/simple_animal/hostile/megafauna/fauna in spot)
		if(!QDELETED(fauna) && fauna.stat != DEAD)
			return TRUE
	return FALSE
