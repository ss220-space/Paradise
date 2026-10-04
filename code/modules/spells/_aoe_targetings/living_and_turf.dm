/datum/aoe_targeting/living_and_turf/get_targets(atom/center, aoe_radius)
	var/things = list()
	for(var/mob/living/living in range(aoe_radius, center))
		if(living == owner)
			continue
		things += living
	for(var/turf/turf in orange(aoe_radius, center))
		things += turf
	return things
