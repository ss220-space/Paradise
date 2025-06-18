/*
//////////////////////////////////////
Vitiligo

	Extremely Noticable.
	Decreases resistance slightly.
	Reduces stage speed slightly.
	Reduces transmission.
	Critical Level.

BONUS
	Makes the mob lose skin pigmentation.

//////////////////////////////////////
*/

/datum/symptom/vitiligo

	name = "Витилиго"
	id = "vitiligo"
	stealth = -3
	resistance = -1
	stage_speed = -1
	transmittable = -2
	level = 4
	severity = 1

/datum/symptom/vitiligo/Activate(datum/disease/virus/advance/A)
	..()
	if(prob(SYMPTOM_ACTIVATION_PROB))
		var/mob/living/M = A.affected_mob
		if(ishuman(M))
			var/mob/living/carbon/human/H = M
			if(H.s_tone == -85)
				return
			switch(A.stage)
				if(5)
					H.s_tone = -85
					H.update_body()
				else
					H.visible_message(span_warning("[H] выгляд[pluralize_ru(H.gender,"ит","ят")] немного бледным...</span>"), span_notice("Ваша кожа внезапно становится светлее..."))

	return


/*
//////////////////////////////////////
Revitiligo

	Extremely Noticable.
	Decreases resistance slightly.
	Reduces stage speed slightly.
	Reduces transmission.
	Critical Level.

BONUS
	Makes the mob gain skin pigmentation.

//////////////////////////////////////
*/

/datum/symptom/revitiligo

	name = "Ревитилиго"
	id = "revitiligo"
	stealth = -3
	resistance = -1
	stage_speed = -1
	transmittable = -2
	level = 4
	severity = 1

/datum/symptom/revitiligo/Activate(datum/disease/virus/advance/A)
	..()
	if(prob(SYMPTOM_ACTIVATION_PROB))
		var/mob/living/M = A.affected_mob
		if(ishuman(M))
			var/mob/living/carbon/human/H = M
			if(H.s_tone == 85)
				return
			switch(A.stage)
				if(5)
					H.s_tone = 85
					H.update_body()
				else
					H.visible_message(span_warning("[H] выгляд[pluralize_ru(H.gender,"ит","ят")] немного темнее..."), span_warning("Ваша кожа внезапно становится темнее..."))

	return
