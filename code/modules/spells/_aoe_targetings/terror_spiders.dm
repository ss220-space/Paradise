/datum/aoe_targeting/terror_spiders/get_targets(atom/center, aoe_radius)
	var/list/targets = list()
	for(var/mob/living/simple_animal/hostile/poison/terror_spider/target in range(aoe_radius, center))
		targets += target
	return targets
