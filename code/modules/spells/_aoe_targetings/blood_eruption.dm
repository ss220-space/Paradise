/datum/aoe_targeting/blood_eruption/get_targets(atom/center, aoe_radius)
	var/list/targets = list()
	for(var/mob/living/target in range(aoe_radius, center))
		if(!locate(/obj/effect/decal/cleanable/blood) in get_turf(target))
			continue
		if(target == owner)
			continue
		targets += target
	return targets
