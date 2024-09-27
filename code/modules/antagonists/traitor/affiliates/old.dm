/datum/affiliate/old
	name = "Unknown"
	desc = "О вашем нанимателе нет информации."
	can_take_bonus_objectives = FALSE

/datum/affiliate/old/get_weight(mob/living/carbon/human/H)
	return 0

/datum/affiliate/old/give_objectives(datum/mind/mind)
	var/datum/antagonist/traitor/traitor = mind?.has_antag_datum(/datum/antagonist/traitor)
	traitor.old_give_objectives()
