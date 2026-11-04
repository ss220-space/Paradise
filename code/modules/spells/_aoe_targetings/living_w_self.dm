/datum/aoe_targeting/living_w_self/get_targets(atom/center, aoe_radius)
	var/list/things = list()
	for(var/mob/living/nearby_mob in range(aoe_radius, center))
		things += nearby_mob
	return things
