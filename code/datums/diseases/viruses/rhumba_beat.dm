//meme copy of GBS
/datum/disease/virus/rhumba_beat
	name = "Румба-бит"
	agent = UNKNOWN_STATUS_RUS
	max_stages = 5
	spread_flags = CONTACT
	cure_text = "Чики-чики БУМ!"
	cures = list("plasma")
	severity = BIOHAZARD

/datum/disease/virus/rhumba_beat/stage_act()
	if(!..())
		return FALSE

	if(affected_mob.ckey == "rosham")
		cure()
		return

	switch(stage)
		if(2)
			if(prob(45))
				affected_mob.adjustToxLoss(5)
			if(prob(1))
				to_chat(affected_mob, span_danger("Вы чувствуете себя странно..."))
		if(3)
			if(prob(5))
				to_chat(affected_mob, span_danger("Вы чувствуете непреодолимое желание танцевать..."))
			else if(prob(5))
				affected_mob.emote("gasp")
			else if(prob(10))
				to_chat(affected_mob, span_danger("Вам хочется чик-чики-бум..."))
		if(4)
			if(prob(10))
				affected_mob.emote("gasp")
				to_chat(affected_mob, span_danger("Вы чувствуете горячий ритм внутри..."))
			if(prob(20))
				affected_mob.adjustToxLoss(5)
		if(5)
			to_chat(affected_mob, span_userdanger("Ваше тело не может сдержать ритм румбы..."))
			if(prob(50))
				affected_mob.gib()
