/*
//////////////////////////////////////

Fever

	No change to hidden.
	Increases resistance.
	Increases stage speed.
	Little transmittable.
	Low level.

Bonus
	Heats up your body.

//////////////////////////////////////
*/

/datum/symptom/fever

	name = "Fever"
	id = "fever"
	stealth = 0
	resistance = 3
	stage_speed = 3
	transmittable = 2
	level = 2
	severity = 2


/datum/symptom/fever/Activate(datum/disease/virus/advance/A)
	..()
	if(prob(SYMPTOM_ACTIVATION_PROB))
		var/mob/living/carbon/M = A.affected_mob
		to_chat(M, span_warning(pick("You feel hot.", "You feel like you're burning.")))
		if(M.bodytemperature < BODYTEMP_HEAT_DAMAGE_LIMIT)
			var/get_heat = (sqrtor0(21+A.totalTransmittable()*2))+(sqrtor0(20+A.totalStageSpeed()*3))
			M.adjust_bodytemperature(get_heat * A.stage)

