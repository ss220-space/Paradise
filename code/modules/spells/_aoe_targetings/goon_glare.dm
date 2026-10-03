/datum/aoe_targeting/goon_glare/get_targets(atom/center, aoe_radius)
	var/list/targets = list()
	var/datum/spell_handler/vampire/handler = parent.custom_handler
	for(var/mob/living/carbon/target in range(aoe_radius, center))
		if(target == owner || !handler.affects(target, owner))
			continue
		targets += target
	return targets
