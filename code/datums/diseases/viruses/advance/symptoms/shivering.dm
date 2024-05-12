/*
//////////////////////////////////////

Shivering

	No change to hidden.
	Increases resistance.
	Increases stage speed.
	Little transmittable.
	Low level.

Bonus
	Cools down your body.

//////////////////////////////////////
*/

/datum/symptom/shivering

	name = "Shivering"
	id = "shivering"
	stealth = 0
	resistance = 2
	stage_speed = 2
	transmittable = 2
	level = 2
	severity = 2


/datum/symptom/shivering/Activate(datum/disease/virus/advance/A)
	..()
	if(prob(SYMPTOM_ACTIVATION_PROB))
		var/mob/living/carbon/M = A.affected_mob
		to_chat(M, span_warning(pick("You feel cold.", "You start shivering.")))
		if(M.bodytemperature > BODYTEMP_COLD_DAMAGE_LIMIT)
			var/get_cold = (sqrtor0(16+A.totalStealth()*2))+(sqrtor0(21+A.totalResistance()*2))
			M.adjust_bodytemperature(-(get_cold * A.stage))

