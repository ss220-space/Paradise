/////////////////////////////////////////////////////////////////////////////////////////
// Research
/////////////////////////////////////////////////////////////////////////////////////////

// MAXIMUM SCIENCE
/datum/ambition_objective/further_research
	completion_payment = 5
	per_unit = 1

/datum/ambition_objective/further_research/get_description()
	var/desc = "Изучить уровни технологий, и доставить их шаттлом снабжения на ЦК. ТЕСТ 1"
	desc += "(сделано [units_completed])."
	return desc

/datum/ambition_objective/maximize_research/check_for_completion()
	for(var/tech in SSshuttle.techLevels)
		if(SSshuttle.techLevels[tech] > 0)
			return 1
	return 0

/////////////////////////////////////////////////////////////////////////////////////////
// Robotics
/////////////////////////////////////////////////////////////////////////////////////////

//Cyborgs
/datum/ambition_objective/make_cyborg
	completion_payment = 100
	per_unit = 1

/datum/ambition_objective/make_cyborg/get_description()
	var/desc = "Построить киборга. ТЕСТ 2"
	desc += "(построено [units_completed])."
	return desc



//RIPLEY's
/datum/ambition_objective/make_ripley
	completion_payment = 600
	per_unit = 1

/datum/ambition_objective/make_ripley/get_description()
	var/desc = "Построить АТМЕ «Рипли» или «Огнеборца». Тест 3"
	desc += "(построено [units_completed])."
	return desc
