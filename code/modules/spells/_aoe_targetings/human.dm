/datum/aoe_targeting/human/get_targets(atom/center, aoe_radius)
	var/list/targets = list()
	for(var/mob/living/carbon/human/human in range(aoe_radius, center))
		if(!human.mind || human == owner)
			continue
		targets += human
	return targets
