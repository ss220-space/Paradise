/datum/aoe_targeting/living/get_targets(atom/center, aoe_radius)
	var/list/things = list()
	for(var/mob/living/nearby_mob in range(aoe_radius, center))
		if(nearby_mob == owner || nearby_mob == center)
			continue

		things += nearby_mob

	return things
