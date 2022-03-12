/datum/disease/anxiety
	name = "Сильное беспокойство"
	form = "Infection"
	max_stages = 4
	spread_text = "On contact"
	spread_flags = CONTACT_GENERAL
	cure_text = "Этанол"
	cures = list("ethanol")
	agent = "Избыток лепидоптицидов"
	viable_mobtypes = list(/mob/living/carbon/human, /mob/living/carbon/human/monkey)
	desc = "Если не вылечить, то субъект будет откашливать бабочек."
	severity = MEDIUM

/datum/disease/anxiety/stage_act()
	..()
	switch(stage)
		if(2) //also changes say, see say.dm
			if(prob(5))
				to_chat(affected_mob, "<span class='notice'>Вы ощущаете беспокойство.</span>")
		if(3)
			if(prob(10))
				to_chat(affected_mob, "<span class='notice'>У вас сжимает живот.</span>")
			if(prob(5))
				to_chat(affected_mob, "<span class='notice'>Вы чувствуете панику.</span>")
			if(prob(2))
				to_chat(affected_mob, "<span class='danger'>Вас охватывает паника!</span>")
				affected_mob.AdjustConfused(rand(2,3))
		if(4)
			if(prob(10))
				to_chat(affected_mob, "<span class='danger'>Вы чувствуете, как у вас в животе порхают бабочки.</span>")
			if(prob(5))
				affected_mob.visible_message("<span class='danger'>[affected_mob] в панике запинается.</span>", \
												"<span class='userdanger'>У вас паническая атака!</span>")
				affected_mob.AdjustConfused(rand(6,8))
				affected_mob.AdjustJitter(rand(6,8))
			if(prob(2))
				affected_mob.visible_message("<span class='danger'>[affected_mob] кашляет бабочками!</span>", \
													"<span class='userdanger'>Вы кашляете бабочками!</span>")
				new /mob/living/simple_animal/butterfly(affected_mob.loc)
				new /mob/living/simple_animal/butterfly(affected_mob.loc)
	return
