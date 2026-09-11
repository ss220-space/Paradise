/datum/aoe_targeting/living_in_sight/get_targets(atom/center, aoe_radius)
	var/list/valid_targets = list()
	var/list/mobs_in_view = owner.get_visible_mobs()

	for(var/mob/living/M in mobs_in_view)
		if(M?.mind)
			if(M == owner)
				continue
			valid_targets += M
	return valid_targets
