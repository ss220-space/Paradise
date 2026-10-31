/datum/aoe_targeting/living_non_alien/get_targets(atom/center, aoe_radius)
	var/list/targets = list()
	for(var/mob/living/target in range(aoe_radius, center))
		if(target == owner || target == center)
			continue
		if(istype(target, /mob/living/carbon/alien))
			continue
		targets += target
	return targets
