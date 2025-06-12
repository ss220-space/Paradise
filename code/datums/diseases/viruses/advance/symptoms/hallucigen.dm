/*
//////////////////////////////////////

Hallucigen

	Very noticable.
	Lowers resistance considerably.
	Decreases stage speed.
	Reduced transmittable.
	Critical Level.

Bonus
	Makes the affected mob be hallucinated for short periods of time.

//////////////////////////////////////
*/

/datum/symptom/hallucigen

	name = "Галлюцинации"
	id = "hallucigen"
	stealth = -2
	resistance = -3
	stage_speed = -3
	transmittable = -1
	level = 5
	severity = 3

/datum/symptom/hallucigen/Activate(datum/disease/virus/advance/A)
	..()
	if(prob(SYMPTOM_ACTIVATION_PROB))
		var/mob/living/carbon/M = A.affected_mob
		switch(A.stage)
			if(1, 2)
				to_chat(M, span_warning(pick("Краем глаза вы замечаете что-то, что тут же исчезает.", "Вы слышите едва уловимый шёпот, но его источник неясен.", "Голова раскалывается.")))
			if(3, 4)
				to_chat(M, span_warning("<b>[pick("За вами кто-то следит.", "Вы чувствуете, что за вами наблюдают.", "Вы слышите шёпот у себя за спиной.", "Где-то рядом раздаются гулкие шаги.")]</b>"))
			else
				to_chat(M, span_userdanger(pick("Ох, голова...", "Голова пульсирует от боли.", "Они повсюду! Беги!", "Что-то скрывается в тенях...")))
				M.AdjustHallucinate(5 SECONDS)
				M.last_hallucinator_log = name

	return
