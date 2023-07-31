/*
//////////////////////////////////////

Toxification syndrome

//////////////////////////////////////
*/

/datum/symptom/infection

	name = "Toxification syndrome"
	id = "infection"
	stealth = -1
	resistance = -3
	stage_speed = -4
	transmittable = -3
	level = 5

/datum/symptom/infection/Start(datum/disease/advance/A)
	var/mob/living/carbon/human/H = A.affected_mob
	H.dna.species.germs_growth_rate *= 20

/datum/symptom/infection/Activate(datum/disease/advance/A)
	..()
	var/mob/living/carbon/human/M = A.affected_mob

	if(prob(SYMPTOM_ACTIVATION_PROB))
		switch(A.stage)
			if(1, 2, 3, 4, 5)
				to_chat(M, "<span class='warning'>[pick("Tox  Message")]</span>")

	if(prob((A.stage - 2) - M.count_of_infected_organs()/4))
		var/obj/item/organ/O = pick(M.internal_organs + M.bodyparts)
		O.germ_level = INFECTION_LEVEL_ONE
		to_chat(M, "<span class='warning'>Заражен орган: [O], germ_level: [O.germ_level]</span>")
	return

/datum/symptom/infection/End(datum/disease/advance/A)
	var/mob/living/carbon/human/H = A.affected_mob
	H.dna.species.germs_growth_rate /= 20
