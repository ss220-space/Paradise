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
	severity = 1

/datum/symptom/moan/Activate(datum/disease/advance/A)
	..()
	if(prob(SYMPTOM_ACTIVATION_PROB * 2))
		var/mob/living/M = A.affected_mob
		switch(A.stage)
			if(1, 2, 3)
				to_chat(M, span_notice("Your muscles spasm, making you want to moan"))
			else
				M.emote("moan")
				if(prob(1))
					M.emote("blush")
				var/obj/item/I = M.get_active_hand()
				if(I && I.w_class == 1)
					M.drop_from_active_hand()
	return
