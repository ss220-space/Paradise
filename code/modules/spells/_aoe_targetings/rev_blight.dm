/datum/aoe_targeting/rev_blight/get_targets(atom/center, aoe_radius)
	var/list/targets = list()
	for(var/mob/living/carbon/human/target in range(aoe_radius, center))
		if(!target.mind)
			continue

		if(target.mind in SSticker.mode.sintouched)
			continue

		if(locate(/datum/disease/ectoplasmic) in target.diseases)
			continue
		targets += target
	return targets
