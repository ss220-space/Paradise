/datum/aoe_targeting/goon_screech/get_targets(atom/center, aoe_radius)
	var/list/targets = list()
	var/datum/spell_handler/vampire/handler = parent.custom_handler
	for(var/mob/living/carbon/target in hearers(aoe_radius, center))
		if(target == owner || !handler.affects(target, owner))
			continue
		if(!ishuman(target))
			targets += target
			continue
		var/mob/living/carbon/human/h_target = target
		if(h_target.check_ear_prot() >= HEARING_PROTECTION_TOTAL)
			continue
		targets += h_target
	return targets
