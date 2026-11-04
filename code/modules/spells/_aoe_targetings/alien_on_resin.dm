/datum/aoe_targeting/alien_on_resin/get_targets(atom/center, aoe_radius)
	var/list/targets = list()
	for(var/mob/living/carbon/alien/target in range(aoe_radius, center))
		var/turf/target_turf = get_turf(target)
		if(!target_turf || !locate(/obj/structure/alien/weeds) in target_turf)
			continue
		targets += target
	return targets
