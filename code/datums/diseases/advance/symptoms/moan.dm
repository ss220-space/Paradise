/*
//////////////////////////////////////

Groaning Syndrome

//////////////////////////////////////
*/

/datum/symptom/moan

	name = "Groaning Syndrome"
	id = "moan"
	stealth = -4
	resistance = -3
	stage_speed = -1
	transmittable = 3
	level = 2

/datum/symptom/moan/Activate(datum/disease/advance/A)
	..()
	if(prob(SYMPTOM_ACTIVATION_PROB))
		var/mob/living/M = A.affected_mob
		switch(A.stage)
			if(1, 2, 3)
				to_chat(M, "<span notice='warning'>[pick("")]</span>")
			else
				M.emote("moan")
				var/obj/item/I = M.get_active_hand()
				if(I && I.w_class == 1)
					M.drop_from_active_hand()
	return
