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
	stealth = -1
	resistance = -1
	stage_speed = -2
	transmittable = -2
	level = 3
	severity = 3

/datum/symptom/weakness/Activate(datum/disease/advance/A)
	..()
	if(prob(SYMPTOM_ACTIVATION_PROB))
		var/mob/living/M = A.affected_mob
		switch(A.stage)
			if(1, 2)
				to_chat(M, "<span class='warning'>[pick("Вы ощущаете слабость.", "Вы чувствуете леность.")]</span>")
			if(3, 4)
				to_chat(M, "<span class='warning'><b>[pick("Вы очень ослабли.", "Кажется, вы сейчас упадёте в обморок.")]</span>")
				M.adjustStaminaLoss(15)
			else
				to_chat(M, "<span class='userdanger'>[pick("У вас заплетаются ноги!", "Ваше тело стонет от накатывающей усталости.")]</span>")
				M.adjustStaminaLoss(30)
				if(M.getStaminaLoss() > 60 && !M.stat)
					M.visible_message("<span class='warning'>[M] падает в обморок!</span>", "<span class='userdanger'>Вы падаете в обморок…</span>")
					M.AdjustSleeping(5)
	return
