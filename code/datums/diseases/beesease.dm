/datum/disease/beesease
	name = "Пчелораза"
	form = "Инфекция"
	max_stages = 4
	spread_text = "Контактный"
	spread_flags = CONTACT_GENERAL
	cure_text = "Сахар"
	cures = list("sugar")
	agent = "Пчелиный вирус"
	viable_mobtypes = list(/mob/living/carbon/human, /mob/living/carbon/human/monkey)
	desc = "Если не вылечить, то субъект будет извергать пчёл."
	severity = DANGEROUS

/datum/disease/beesease/stage_act()
	..()
	switch(stage)
		if(2) //also changes say, see say.dm // no it doesn't, that's horrifyingly snowflakey
			if(prob(2))
				to_chat(affected_mob, "<span class='notice'>Вы чувствуете во рту привкус мёда.</span>")
		if(3)
			if(prob(10))
				to_chat(affected_mob, "<span class='notice'>У вас урчит в животе.</span>")
			if(prob(2))
				to_chat(affected_mob, "<span class='danger'>Вы ощущаете в животе жалящую боль.</span>")
				if(prob(20))
					affected_mob.adjustToxLoss(2)
		if(4)
			if(prob(10))
				affected_mob.visible_message("<span class='danger'>[affected_mob] жужжит.</span>", \
												"<span class='userdanger'>Ваш живот громко жужжит!</span>")
			if(prob(5))
				to_chat(affected_mob, "<span class='danger'>Вы чувствуете как что-то двигается у вас в горле!</span>")
			if(prob(1))
				affected_mob.visible_message("<span class='danger'>[affected_mob] выкашливает рой пчёл!</span>", \
													"<span class='userdanger'>Вы выкашливаете рой пчёл!</span>")
				new /mob/living/simple_animal/hostile/poison/bees(affected_mob.loc)
		//if(5)
		//Plus if you die, you explode into bees
	return
