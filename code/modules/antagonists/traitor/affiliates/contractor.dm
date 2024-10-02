/datum/affiliate/contractor
	name = "Contractor"
	affil_info = list("Преимущества: -",
					"Недостатки: -",
					"Стандартные цели:",
					"Похитить нескольких членов экипажа",
					"Убить нескольких членов экипажа",
					"Украсть несколько ценных предметов")
	can_take_bonus_objectives = TRUE

/datum/affiliate/contractor/get_weight(mob/living/carbon/human/H)
	return 0

/datum/affiliate/contractor/give_objectives(datum/mind/mind)
	var/datum/antagonist/traitor/traitor = mind?.has_antag_datum(/datum/antagonist/traitor)
	if(!traitor)
		return

	traitor.old_give_objectives()

	var/datum/antagonist/contractor/contractor_datum = new()
	mind.add_antag_datum(contractor_datum)
