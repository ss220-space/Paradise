/*
//////////////////////////////////////

Weakness

	Slightly noticeable.
	Lowers resistance slightly.
	Decreases stage speed moderately.
	Decreases transmittablity moderately.
	Moderate Level.

Bonus
	Deals stamina damage to the host

//////////////////////////////////////
*/

/datum/symptom/weakness

	name = "Слабость"
	id = "weakness"
	stealth = -1
	resistance = -1
	stage_speed = -2
	transmittable = -2
	level = 3
	severity = 3

/datum/symptom/weakness/Activate(datum/disease/virus/advance/A)
	..()
	if(prob(SYMPTOM_ACTIVATION_PROB*2))
		var/mob/living/M = A.affected_mob
		switch(A.stage)
			if(1, 2)
				to_chat(M, span_warning(pick("Вы чувствуете слабость.", "Вы чувствуете лень.")))
			if(3, 4)
				to_chat(M, span_warning("<b>[pick("Вы чувствуете себя очень слабым.", "Вам кажется, что вы вот-вот упадёте в обморок.")]</b>"))
				M.adjustStaminaLoss(15)
			else
				to_chat(M, span_userdanger(pick("Вы чувствуете себя невероятно слабым!", "Ваше тело дрожит, а усталость окутывает вас.")))
				M.adjustStaminaLoss(30)
				if(M.getStaminaLoss() > 60 && !M.stat)
					M.visible_message(span_warning("[M] пада[pluralize_ru(M.gender,"ет","ют")] в обморок!</span>"), span_userdanger("Вы теряете сознание и падаете..."))
					M.AdjustSleeping(10 SECONDS)
	return
