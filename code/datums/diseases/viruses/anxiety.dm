/datum/disease/virus/anxiety
	name = "Сильное беспокойство"
	form = "Инфекция"
	agent = "Избыток лепидоптицидов"
	desc = "Если не лечить, заражённый начнёт отрыгивать бабочек."
	max_stages = 4
	spread_flags = CONTACT
	cures = list("ethanol")
	severity = MEDIUM
	possible_mutations = list(/datum/disease/virus/beesease)

/datum/disease/virus/anxiety/stage_act()
	if(!..())
		return FALSE
	switch(stage)
		if(2)
			if(prob(5))
				to_chat(affected_mob, span_notice("Вы чувствуете тревогу!"))
			if(prob(5))
				affected_mob.AdjustJitter(5 SECONDS)
		if(3)
			if(prob(10))
				to_chat(affected_mob, span_notice("Ваш желудок трепещет."))
			if(prob(5))
				to_chat(affected_mob, span_notice("Вы чувствуете панику!"))
			if(prob(5))
				to_chat(affected_mob, span_danger("Вас охватывает паника!"))
				affected_mob.AdjustJitter(10 SECONDS, bound_upper = 20 SECONDS)
				affected_mob.AdjustStuttering(10 SECONDS, bound_upper = 20 SECONDS)
		if(4)
			if(prob(10))
				to_chat(affected_mob, span_danger("Вы чувствуете бабочек в животе."))
			if(prob(5))
				affected_mob.visible_message(span_danger("[affected_mob] меч[pluralize_ru(affected_mob.gender,"ется","ются")] в панике."), span_userdanger("У вас паническая атака!"))
				affected_mob.AdjustConfused(rand(6 SECONDS, 12 SECONDS), bound_upper = 20 SECONDS)
				affected_mob.AdjustJitter(rand(20 SECONDS, 40 SECONDS), bound_upper = 50 SECONDS)
				affected_mob.AdjustStuttering(rand(20 SECONDS, 40 SECONDS), bound_upper = 50 SECONDS)
			if(prob(3))
				affected_mob.visible_message(span_danger("[affected_mob] откашлива[pluralize_ru(affected_mob.gender,"ет","ют")] бабочек!"), span_userdanger("Вы откашливаете бабочек!"))
				affected_mob.Stun(rand(5 SECONDS, 10 SECONDS))
				new /mob/living/simple_animal/butterfly(affected_mob.loc)
				new /mob/living/simple_animal/butterfly(affected_mob.loc)
	return
