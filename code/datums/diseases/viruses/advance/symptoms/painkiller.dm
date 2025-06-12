/*
//////////////////////////////////////

Self-Respiration

	Lowers resistance.
	Decreases stage speed slightly.
	Decreases transmittablity.
	Fatal Level.

Bonus
	The body generates hydrocodone

//////////////////////////////////////
*/

/datum/symptom/painkiller

	name = "Нейронная блокада"
	id = "painkiller"
	stealth = -3
	resistance = -2
	stage_speed = -1
	transmittable = -2
	level = 6

/datum/symptom/painkiller/Activate(datum/disease/virus/advance/A)
	..()
	var/mob/living/M = A.affected_mob
	if(prob(SYMPTOM_ACTIVATION_PROB * 5))
		switch(A.stage)
			if(1)
				M.Confused(40 SECONDS)
			if(2, 3)
				M.Slowed(40 SECONDS)
				M.Confused(80 SECONDS)
				to_chat(M, span_danger(pick("Вы чувствуете, что с вашим телом что-то очень не так.", "Вам трудно контролировать собственное тело.", "Вы не чувствуете своё тело.")))
			if(4, 5)
				if(prob(10))
					to_chat(M, span_notice(pick("Ваше тело онемело.", "Вы понимаете, что не чувствуете ничего.", "Вы не чувствуете своё тело.")))
	if(M.reagents.get_reagent_amount("hydrocodone") < 2 && M.getToxLoss() < 13 && A.stage > 4)
		M.reagents.add_reagent("hydrocodone", 0.5)
	return
