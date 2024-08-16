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

	name = "Viral Hematopoiesis"
	id = "blood"
	stealth = -2
	resistance = -2
	stage_speed = -4
	transmittable = -1
	level = 5
	var/check = FALSE

/datum/symptom/blood/Activate(datum/disease/virus/advance/A)
	..()
	var/mob/living/M = A.affected_mob
	if(prob(SYMPTOM_ACTIVATION_PROB))
		switch(A.stage)
			if(3,4)
				to_chat(M, span_notice("You feel hungry"))
			if(5)
				if(prob(10))
					to_chat(M, span_notice("You can hear own heartbeat"))
				check = TRUE
	if(check == TRUE && (M.blood_volume < BLOOD_VOLUME_NORMAL) && !(NO_BLOOD in M.dna.species.species_traits) && !isdiona(M))
		M.blood_volume += 0.4
		M.adjust_nutrition(-2)
	return

