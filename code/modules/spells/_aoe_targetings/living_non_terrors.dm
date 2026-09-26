/datum/aoe_targeting/living_non_terrors/get_targets(atom/center, aoe_radius)
	var/list/targets = list()
	for(var/mob/living/target in range(aoe_radius, center))
		if(isterrorspider(target))
			continue
		targets += target
	return targets
