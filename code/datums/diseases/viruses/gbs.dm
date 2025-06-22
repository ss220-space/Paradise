/datum/disease/virus/gbs
	name = "ГБС"
	agent = "Гравитокинетический Бипотенциальный SADS+"
	spread_flags = CONTACT
	cures = list("diphenhydramine", "sulfur")
	cure_prob = 15
	severity = BIOHAZARD

/datum/disease/virus/gbs/stage_act()
	if(!..())
		return FALSE

	switch(stage)
		if(2)
			if(prob(45))
				affected_mob.adjustToxLoss(5)
			if(prob(1))
				affected_mob.emote("sneeze")
		if(3)
			if(prob(5))
				affected_mob.emote("cough")
			else if(prob(5))
				affected_mob.emote("gasp")
			if(prob(10))
				to_chat(affected_mob, span_danger("Вы начинаете чувствовать себя очень слабым..."))
		if(4)
			if(prob(10))
				affected_mob.emote("cough")
			affected_mob.adjustToxLoss(5)
		if(5)
			to_chat(affected_mob, span_userdanger("Ваше тело будто пытается разорваться изнутри..."))
			if(prob(50))
				affected_mob.delayed_gib()

/datum/disease/virus/gbs/non_con
	name = "Незаразный ГБС"
	agent = "Гиббис"
	spread_flags = NON_CONTAGIOUS
	cures = list("cryoxadone")
	cure_prob = 10
	can_immunity = FALSE

/datum/disease/virus/fake_gbs
	name = "ГБС"
	desc = "Если не лечить, наступит смерть."
	agent = "Гравитокинетический Бипотенциальный SADS-"
	spread_flags = CONTACT
	cures = list("diphenhydramine", "sulfur")
	cure_prob = 15
	severity = BIOHAZARD

/datum/disease/virus/fake_gbs/stage_act()
	if(!..())
		return FALSE

	switch(stage)
		if(2)
			if(prob(1))
				affected_mob.emote("sneeze")
		if(3)
			if(prob(5))
				affected_mob.emote("cough")
			else if(prob(5))
				affected_mob.emote("gasp")
			if(prob(10))
				to_chat(affected_mob, span_danger("Вы начинаете чувствовать себя очень слабым..."))
		if(4, 5)
			if(prob(10))
				affected_mob.emote("cough")
