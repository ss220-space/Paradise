/*
//////////////////////////////////////

Pacifist Syndrome

//////////////////////////////////////
*/

/datum/symptom/love

	name = "Pacifist Syndrome"
	id = "love"
	stealth = 2
	resistance = -2
	stage_speed = 1
	transmittable = 1
	level = 3
	severity = 0

/datum/symptom/love/Activate(datum/disease/advance/A)
	..()
	var/mob/living/M = A.affected_mob
	if(prob(SYMPTOM_ACTIVATION_PROB * 3))
		switch(A.stage)
			if(2, 3)
				to_chat(M, span_notice(pick("How beautiful the world is...", "You want to hug someone",\
						"You feel soooo good!", "You feel warm", "You want to smile to everyone around you")))
			if(4)
				to_chat(M, span_notice(pick("You feel love for the whole world!", "You don't want to hurt anyone",\
						"You want to share your feelings!", "You feel the desire to spread love!",\
						"You overfilled with love, and want to share it.")))
	if(A.stage > 4 && M.reagents.get_reagent_amount("love") < 4)
		M.reagents.add_reagent("love", 1)
	return
