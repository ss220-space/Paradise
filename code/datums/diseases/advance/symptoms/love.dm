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

/datum/symptom/love/Activate(datum/disease/advance/A)
	..()
	var/mob/living/M = A.affected_mob
	if(prob(SYMPTOM_ACTIVATION_PROB * 3))
		switch(A.stage)
			if(2, 3)
				to_chat(M, "<span class='danger'>[pick("", "", "")]</span>")
			if(4)
				to_chat(M, "<span class='danger'>[pick("", "", "")]</span>")
	if(A.stage > 4 && M.reagents.get_reagent_amount("love") < 4)
		M.reagents.add_reagent("love", 1)
	return
