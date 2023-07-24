/*
//////////////////////////////////////

Fragile Bones Syndrome

//////////////////////////////////////
*/

/datum/symptom/bones

	name = "Fragile Bones Syndrome"
	id = "bones"
	stealth = -3
	resistance = -4
	stage_speed = -4
	transmittable = -4
	level = 6
	var/bonefragility_multiplier = 2
	var/fragile_bones_chance = 3
	var/done = FALSE

/datum/symptom/bones/Activate(datum/disease/advance/A)
	..()
	var/mob/living/carbon/human/M = A.affected_mob
	switch(A.stage)
		if(1, 2, 3, 4)
			if(prob(SYMPTOM_ACTIVATION_PROB))
				to_chat(M, "<span class='warning'>[pick("")]</span>")
		else
			if(!done)
				M.dna.species.bonefragility *= bonefragility_multiplier
				M.dna.species.fragile_bones_chance += fragile_bones_chance
				done = TRUE
				to_chat(M, "<span class='userdanger'>!</span>")

	return

/datum/symptom/bones/End(datum/disease/advance/A)
	var/mob/living/carbon/human/M = A.affected_mob
	M.dna.species.bonefragility /= bonefragility_multiplier
	M.dna.species.fragile_bones_chance -= fragile_bones_chance
