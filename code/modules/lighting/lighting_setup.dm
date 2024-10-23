/proc/create_all_lighting_objects()
	for(var/area/A as anything in GLOB.areas)
		if(!A.static_lighting)
			continue

		// I hate this so much dude. why do areas not track their turfs lummyyyyyyy
		for(var/turf/T in A)
			if(T.always_lit)
				continue
			new/atom/movable/lighting_object(T)
			CHECK_TICK
		CHECK_TICK
