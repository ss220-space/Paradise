/*
//////////////////////////////////////

Fragile Bones Syndrome

//////////////////////////////////////
*/

/datum/symptom/bones

	name = "Синдром ломких костей"
	id = "bones"
	stealth = -3
	resistance = -4
	stage_speed = -4
	transmittable = -4
	level = 6
	severity = 5
	var/bonefragility_multiplier = 2
	var/fragile_bones_chance = 3
	var/done = FALSE

/datum/symptom/bones/Activate(datum/disease/virus/advance/A)
	..()
	var/mob/living/carbon/human/M = A.affected_mob
	if(prob(SYMPTOM_ACTIVATION_PROB * 4))
		switch(A.stage)
			if(1, 2)
				to_chat(M, span_warning(pick("Вы слышите, как что-то хрустнуло.", "Кажется, что-то хрустнуло.", "Какое-то неприятное ощущение в [pick("ноге", "стопе", "руке", "кисти", "плече", "позвоночнике", "шее")].", "Кажется, мой палец согнулся неестественно.", span_italics("хрусь..."))))

			if(3, 4)
				switch(rand(1, 3))
					if(1)
						playsound(M, "bonebreak", 15, 1)
						M.visible_message(span_warning("Кажется, вы слышите хруст, исходящий от [M.declent_ru(GENITIVE)]."), span_warning("Вы слышите, как что-то хрустнуло внутри вас!"))
					if(2)
						to_chat(M, span_warning("Вы чувствуете ужасную боль в [pick("ноге", "стопе", "руке", "кисти", "плече", "позвоночнике", "шее")]."))
					if(3)
						M.Slowed(1 SECONDS)
						M.visible_message(span_warning("[capitalize(M.declent_ru(NOMINATIVE))] хрома[pluralize_ru(M.gender,"ет","ют")]."), span_warning("Ваша нога больше не держит форму!"))

			if(5)
				switch(rand(1, 2))
					if(1)
						to_chat(M, span_danger(pick("Вы чувствуете, как ваше тело разрушается!", "Что-то громко хрустнуло.", "Вы чувствуете ужасную боль в [pick("ноге", "стопе", "руке", "кисти", "плече", "позвоночнике", "шее")].", "Такое ощущение, будто вы растекаетесь по полу.")))
					if(2)
						playsound(M, "bonebreak", 50, 1)
						M.visible_message(span_userdanger(span_italics("ХРУСЬ")))

				if(!done)
					M.physiology.bone_fragility *= bonefragility_multiplier
					done = TRUE


/datum/symptom/bones/End(datum/disease/virus/advance/A)
	var/mob/living/carbon/human/M = A.affected_mob
	M.physiology.bone_fragility /= bonefragility_multiplier


/mob/living/proc/get_bones_symptom_prob()
	. = 0
	if(!LAZYLEN(diseases))
		return .
	for(var/datum/disease/virus/advance/disease in diseases)
		var/datum/symptom/bones/symptom = locate() in disease.symptoms
		if(symptom)
			return symptom.fragile_bones_chance

