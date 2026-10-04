/datum/aoe_targeting/vamp_thralls/get_targets(atom/center, aoe_radius)
	var/list/thralls = list()
	for(var/mob/living/carbon/human/thrall in range(aoe_radius, center))
		if(!isvampirethrall(thrall))
			continue
		thralls += thrall
	return thralls
