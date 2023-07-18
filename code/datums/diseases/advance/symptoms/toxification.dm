/*
//////////////////////////////////////

Toxification syndrome

//////////////////////////////////////
*/

/datum/symptom/infection

	name = "Toxification syndrome"
	id = "infection"
	stealth = -1
	resistance = -3
	stage_speed = -4
	transmittable = -3
	level = 5

/datum/symptom/infection/Activate(datum/disease/advance/A)
	..()
	return
