/*
//////////////////////////////////////

Self-Respiration

	Slightly hidden.
	Lowers resistance significantly.
	Decreases stage speed significantly.
	Decreases transmittablity tremendously.
	Fatal Level.

Bonus
	The body generates salbutamol.

//////////////////////////////////////
*/

/datum/symptom/oxygen

	name = "Автодыхание"
	stealth = 1
	resistance = -3
	stage_speed = -3
	transmittable = -4
	level = 6

/datum/symptom/oxygen/Activate(datum/disease/advance/A)
	..()
	if(prob(SYMPTOM_ACTIVATION_PROB * 5))
		var/mob/living/M = A.affected_mob
		switch(A.stage)
			if(4, 5)
				if(M.reagents.get_reagent_amount("salbutamol") < 20)
					M.reagents.add_reagent("salbutamol", 20)
			else
				if(prob(SYMPTOM_ACTIVATION_PROB * 5))
					to_chat(M, "<span class='notice'>[pick("Вам очень легко дышится.", "Вы понимаете, что вам больше не обязательно дышать.", "Вы больше не ощущаете потребности в дыхании.")]</span>")
	return
