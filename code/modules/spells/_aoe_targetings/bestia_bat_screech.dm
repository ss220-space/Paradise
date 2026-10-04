/datum/aoe_targeting/bestia_bat_screech/get_targets(atom/center, aoe_radius)
	var/list/targets = list()
	for(var/mob/living/victim in hearers(aoe_radius, owner))
		if(!victim.affects_vampire(owner))
			continue
		if(victim.stat == DEAD)
			continue

		if(ishuman(victim))
			var/mob/living/carbon/human/h_victim = victim
			if(h_victim.check_ear_prot() >= HEARING_PROTECTION_TOTAL)
				continue
		if(victim == owner)
			continue
		targets += victim
		return targets
