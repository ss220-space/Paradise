/*
//////////////////////////////////////

Viral hematopoiesis

	Lowers resistance .
	Decreases stage tremendously.
	Decreases transmittablity slightly.

Bonus
	Restores blood at the cost of saturation

//////////////////////////////////////
*/

/datum/symptom/blood

	name = "Вирусное кроветворение"
	id = "blood"
	stealth = -2
	resistance = -2
	stage_speed = -4
	transmittable = -1
	level = 5


/datum/symptom/blood/Activate(datum/disease/virus/advance/virus)
	if(!prob(SYMPTOM_ACTIVATION_PROB))
		return
	var/mob/living/affected = virus.affected_mob
	switch(virus.stage)
		if(3, 4)
			to_chat(affected, span_notice("Вы чувствуете голод."))
		if(5)
			if(prob(10))
				to_chat(affected, span_notice("Вы слышите собственное сердцебиение."))
			if(!HAS_TRAIT(affected, TRAIT_NO_BLOOD) && !HAS_TRAIT(affected, TRAIT_NO_BLOOD_RESTORE) && affected.blood_volume < BLOOD_VOLUME_NORMAL)
				affected.AdjustBlood(0.4)
				affected.adjust_nutrition(-2)

