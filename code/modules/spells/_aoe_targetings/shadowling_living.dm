/datum/aoe_targeting/shadowling_living/get_targets(atom/center, aoe_radius)
	var/list/targets = list()
	for(var/mob/living/target in view(aoe_radius, center))
		if(target == owner || target.stat || is_shadow_or_thrall(target))
			continue
		targets += target
	return targets
