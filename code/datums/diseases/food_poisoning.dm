/datum/disease/food_poisoning
	name = "Пищевое отравление"
	agent = "Сальмонелла"
	desc = "Тошнота, недомогание и рвота."
	max_stages = 3
	stage_prob = 5
	cure_text = "Правильное питание и сон"
	cures = list("chicken_soup")
	cure_prob = 100	//override in has_cure()
	severity = MINOR
	can_immunity = FALSE
	ignore_immunity = TRUE
	virus_heal_resistant = TRUE
	visibility_flags = HIDDEN_PANDEMIC
	possible_mutations = list(/datum/disease/virus/tuberculosis)

/datum/disease/food_poisoning/stage_act()
	if(!..())
		return FALSE

	switch(stage)
		if(1)
			if(prob(5))
				to_chat(affected_mob, span_danger("Вы чувствуете неприятное ощущение в животе."))
			if(prob(5))
				to_chat(affected_mob, span_danger("Вас мутит."))
		if(2)
			if(prob(10))
				affected_mob.emote("groan")
			if(prob(5))
				to_chat(affected_mob, span_danger("Ваш желудок болит."))
			if(prob(5))
				to_chat(affected_mob, span_danger("Вас тошнит."))
		if(3)
			if(prob(10))
				affected_mob.emote("moan")
			if(prob(10))
				affected_mob.emote("groan")
			if(prob(1))
				to_chat(affected_mob, span_danger("Ваш желудок болит."))
			if(prob(1))
				to_chat(affected_mob, span_danger("Вы чувствуете себя больным."))
			if(prob(5))
				if(affected_mob.nutrition > 10)
					affected_mob.visible_message(span_danger("[affected_mob] обильно рвёт на пол!"))
					affected_mob.fakevomit(no_text = 1)
					affected_mob.adjust_nutrition(-rand(3,5))
				else
					to_chat(affected_mob, span_danger("Ваш желудок болезненно сводит!"))
					affected_mob.visible_message(span_danger("[affected_mob] сдержива[pluralize_ru(affected_mob.gender,"ет","ют")] рвотный позыв, и выгляд[pluralize_ru(affected_mob.gender,"ит","ят")] очень бледным."))
					affected_mob.Stun(rand(4 SECONDS, 8 SECONDS))
					affected_mob.Weaken(rand(4 SECONDS, 8 SECONDS))

/datum/disease/food_poisoning/has_cure()
	if(..())
		if(affected_mob.IsSleeping())
			return prob(80 - 15 * stage)
		return prob(8)
	else
		if(affected_mob.IsSleeping())
			return prob(30 - 7.5 * stage)
		return prob(1) && prob(50)
