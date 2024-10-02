/datum/affiliate/contractor
	name = "Unknown"
	affil_info = list("О вашем нанимателе нет информации.",
			"Преимущества: -",
			"Недостатки: -",
			"Стандартные цели: -")
	can_take_bonus_objectives = FALSE

/datum/affiliate/contractor/get_weight(mob/living/carbon/human/H)
	return 0
