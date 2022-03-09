/*
//////////////////////////////////////
Viral adaptation

	Moderate stealth boost.
	Major Increases to resistance.
	Reduces stage speed.
	No change to transmission
	Critical Level.

BONUS
	Extremely useful for buffing viruses

//////////////////////////////////////
*/
/datum/symptom/viraladaptation
	name = "Самоадаптация вируса"
	stealth = 3
	resistance = 5
	stage_speed = -3
	transmittable = 0
	level = 3

/datum/symptom/viraladaptation/Activate(datum/disease/advance/A)
	..()
	if(prob(SYMPTOM_ACTIVATION_PROB))
		var/mob/living/M = A.affected_mob
		switch(A.stage)
			if(1)
				to_chat(M, "<span class='notice'>Вам становится не по себе, но вы не замечаете никаких изменений.</span>")
			if(5)
				to_chat(M, "<span class='notice'>Вам становится лучше, но вы не понимаете — как именно.</span>")

/*
//////////////////////////////////////
Viral evolution

	Moderate stealth reductopn.
	Major decreases to resistance.
	increases stage speed.
	increase to transmission
	Critical Level.

BONUS
	Extremely useful for buffing viruses

//////////////////////////////////////
*/
/datum/symptom/viralevolution
	name = "Ускорение эволюции вируса"
	stealth = -2
	resistance = -3
	stage_speed = 5
	transmittable = 3
	level = 3

/datum/symptom/viraladaptation/Activate(datum/disease/advance/A)
	..()
	if(prob(SYMPTOM_ACTIVATION_PROB))
		var/mob/living/M = A.affected_mob
		switch(A.stage)
			if(1)
				to_chat(M, "<span class='notice'>Вам становится не по себе, но вы не замечаете никаких изменений.</span>")
			if(5)
				to_chat(M, "<span class='notice'>Вам становится лучше, но вы не понимаете — как именно.</span>")
