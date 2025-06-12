/*
//////////////////////////////////////

Pacifist Syndrome

//////////////////////////////////////
*/

/datum/symptom/love

	name = "Синдром пацифиста"
	id = "love"
	stealth = 2
	resistance = -2
	stage_speed = 1
	transmittable = 1
	level = 3
	severity = 0

/datum/symptom/love/Activate(datum/disease/virus/advance/A)
	..()
	var/mob/living/M = A.affected_mob
	if(prob(SYMPTOM_ACTIVATION_PROB * 3))
		switch(A.stage)
			if(2, 3)
				to_chat(M, span_notice(pick("Как прекрасен этот мир...", "Вам хочется обнять кого-нибудь.", "Вы чувствуете себя оооочень хорошо!", "Вам тепло.", "Вам хочется улыбнуться всем вокруг.")))
			if(4)
				to_chat(M, span_notice(pick("Вы чувствуете любовь ко всему миру!", "Вы не хотите причинять никому боль.", "Вам хочется поделиться своими чувствами!", "Вы чувствуете желание распространять любовь!", "Вы переполнены любовью и хотите поделиться ею.")))
	if(A.stage > 4 && M.reagents.get_reagent_amount("love") < 4)
		M.reagents.add_reagent("love", 1)
	return
