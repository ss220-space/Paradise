/*
//////////////////////////////////////

Confusion

	Little bit hidden.
	Lowers resistance.
	Decreases stage speed.
	Not very transmittable.
	Intense Level.

Bonus
	Makes the affected mob be confused for short periods of time.

//////////////////////////////////////
*/

/datum/symptom/confusion

	name = "Topographical Cretinism"
	id = "confusion"
	stealth = -1
	resistance = 1
	stage_speed = -4
	transmittable = 2
	level = 3
	severity = 2


/datum/symptom/confusion/Activate(datum/disease/virus/advance/A)
	..()
	var/mob/living/carbon/M = A.affected_mob
	switch(A.stage)
		if(1, 2, 3, 4)
			if(prob(SYMPTOM_ACTIVATION_PROB))
				to_chat(M, span_warning(pick("Your head hurts.", "Your mind blanks for a moment.")))
		else
			if(prob(SYMPTOM_ACTIVATION_PROB * 3))
				to_chat(M, span_userdanger("You can't think straight!"))
				M.AdjustConfused(20 SECONDS, bound_lower = 0, bound_upper = 200 SECONDS)
				M.Disoriented(1)

	return
