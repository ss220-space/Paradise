/*
//////////////////////////////////////

Weight Loss

	Very Very Noticable.
	Decreases resistance.
	Decreases stage speed.
	Reduced Transmittable.
	High level.

Bonus
	Decreases the weight of the mob,
	forcing it to be skinny.

//////////////////////////////////////
*/

/datum/symptom/weight_loss

	name = "Потеря веса"
	stealth = -3
	resistance = -2
	stage_speed = -2
	transmittable = -2
	level = 3
	severity = 1

/datum/symptom/weight_loss/Activate(datum/disease/advance/A)
	..()
	if(prob(SYMPTOM_ACTIVATION_PROB))
		var/mob/living/M = A.affected_mob
		switch(A.stage)
			if(1, 2, 3, 4)
				to_chat(M, "<span class='warning'>[pick("Вам хочется есть.", "Вы истосковались по еде.")]</span>")
			else
				to_chat(M, "<span class='warning'><i>[pick("Так хочется есть…", "Вы бы убили за кусочек еды…", "Вас потрясывает от голода…")]</i></span>")
				M.overeatduration = max(M.overeatduration - 100, 0)
				M.adjust_nutrition(-100)
