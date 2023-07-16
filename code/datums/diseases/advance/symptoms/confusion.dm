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


/datum/symptom/confusion/Activate(datum/disease/advance/A)
	..()
	var/mob/living/carbon/M = A.affected_mob
	switch(A.stage)
		if(1, 2, 3, 4)
			if(prob(SYMPTOM_ACTIVATION_PROB))
				to_chat(M, "<span class='warning'>[pick("Your head hurts.", "Your mind blanks for a moment.")]</span>")
		else
			M.AdjustConfused(2, set_disoriented = TRUE)
			if(prob(SYMPTOM_ACTIVATION_PROB * 3))
				M.AdjustConfused(5, set_disoriented = TRUE)
				to_chat(M, "<span class='userdanger'>You can't think straight!</span>")
	return
