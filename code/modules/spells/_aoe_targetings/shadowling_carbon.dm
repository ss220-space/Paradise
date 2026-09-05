/datum/aoe_targeting/shadowling_carbon/get_targets(atom/center, aoe_radius)
	var/list/targets = list()
	for(var/mob/living/carbon/human/target in range(aoe_radius, center))
		if(is_shadow_or_thrall(target))
			continue
		targets += target
	return targets
