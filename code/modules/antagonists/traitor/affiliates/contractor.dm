/datum/affiliate/contractor
	name = "Contractor"
	desc = "Вы были отправлены на станцию NanoTrasen чтобы похитить нескольких членов экипажа интересующих ваших нанимателей.\n\
			Стандартные цели: Похитить нескольких членов экипажа. Убить нескольких членов экипажа. Украсть несколько ценных предметов."
	can_take_bonus_objectives = TRUE

/datum/affiliate/contractor/get_weight(mob/living/carbon/human/H)
	return 1

/datum/affiliate/contractor/give_objectives(datum/mind/mind)
	var/datum/antagonist/traitor/traitor = mind?.has_antag_datum(/datum/antagonist/traitor)
	if(!traitor)
		return

	traitor.old_give_objectives()

	var/datum/antagonist/contractor/contractor_datum = new()
	mind.add_antag_datum(contractor_datum)
