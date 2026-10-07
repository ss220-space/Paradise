/datum/aoe_targeting/vamp_glare/get_targets(atom/center, aoe_radius)
	var/list/targets = list()
	for(var/mob/living/target in range(aoe_radius, center))
		if(target == owner || isnull(target.mind) || target.stat == DEAD || !target.affects_vampire(owner))
			continue
		targets += target
	return targets
