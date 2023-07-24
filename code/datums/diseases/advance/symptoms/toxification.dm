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

/datum/symptom/infection/Activate(datum/disease/advance/A)
	..()
	var/mob/living/carbon/human/M = A.affected_mob
	if(prob(SYMPTOM_ACTIVATION_PROB))
		switch(A.stage)
			if(1, 2, 3, 4, 5)
				to_chat(M, "<span class='warning'>[pick("Tox  Message")]</span>")
	if(prob(A.stage - 2))
	//var/zone = "[hand ? "l" : "r"]_[pick("hand", "arm")]"
	//var/obj/item/organ/external/choosen_organ = M.get_organ(zone)

	return
