/*
//////////////////////////////////////

Necrotizing Fasciitis (AKA Flesh-Eating Disease)

	Very very noticable.
	Lowers resistance tremendously.
	No changes to stage speed.
	Decreases transmittablity temrendously.
	Fatal Level.

Bonus
	Deals brute damage over time.

//////////////////////////////////////
*/

/datum/symptom/flesh_eating

	name = "Некротический фасциит"
	stealth = -3
	resistance = -4
	stage_speed = 0
	transmittable = -4
	level = 6
	severity = 5

/datum/symptom/flesh_eating/Activate(datum/disease/advance/A)
	..()
	if(prob(SYMPTOM_ACTIVATION_PROB))
		var/mob/living/M = A.affected_mob
		switch(A.stage)
			if(2,3)
				to_chat(M, "<span class='warning'>[pick("Вы чувствуете резкую боль во всём теле.", "На вашей кожей внезапно проступают капельки крови.")]</span>")
			if(4,5)
				to_chat(M, "<span class='userdanger'>[pick("Вы содрогаетесь от жуткой боли во всём теле.", "Ваше тело, кажется, пожирает само себя прямо внутри вас!", "ВАМ ОЧЕНЬ БОЛЬНО!")]</span>")
				Flesheat(M, A)
	return

/datum/symptom/flesh_eating/proc/Flesheat(mob/living/M, datum/disease/advance/A)
	var/get_damage = ((sqrtor0(16-A.totalStealth()))*5)
	M.adjustBruteLoss(get_damage)
	return 1
