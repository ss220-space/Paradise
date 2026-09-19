/datum/aoe_targeting/human_affects_vamp/get_targets(atom/center, aoe_radius)
	var/list/targets = list()
	for(var/mob/living/carbon/human/target in range(aoe_radius, center))
		if(!target.affects_vampire(owner) || target == owner)
			continue
		targets += target
	return targets
