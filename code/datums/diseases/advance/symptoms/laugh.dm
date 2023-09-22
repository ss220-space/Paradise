/*
//////////////////////////////////////

Uncontrolled Laughter Effect

//////////////////////////////////////
*/

/datum/symptom/laugh

	name = "Uncontrolled Laughter Effect"
	id = "laugh"
	stealth = 0
	resistance = -3
	stage_speed = 3
	transmittable = -1
	level = 2
	severity = 1

/datum/symptom/laugh/Activate(datum/disease/advance/A)
	..()
	if(prob(SYMPTOM_ACTIVATION_PROB * 2))
		var/mob/living/M = A.affected_mob
		switch(A.stage)
			if(1, 2, 3)
				to_chat(M, span_notice(pick("He-he, that's a funny sight",\
					"You feel like laughing",\
					"It tickles!",\
					"Oh, yeah! That joke!"\
				)))
			else
				M.emote(pick("laugh", "giggle"))
				var/obj/item/I = M.get_active_hand()
				if(I && I.w_class == 1)
					M.drop_from_active_hand()
	return
