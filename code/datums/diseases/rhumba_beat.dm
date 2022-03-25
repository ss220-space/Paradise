/datum/disease/rhumba_beat
	name = "Румба-бит"
	max_stages = 5
	spread_text = "Контактный"
	spread_flags = CONTACT_GENERAL
	cure_text = "Чик-чики-бум!"
	cures = list("plasma")
	agent = "Неизвестен"
	viable_mobtypes = list(/mob/living/carbon/human)
	permeability_mod = 1
	severity = BIOHAZARD

/datum/disease/rhumba_beat/stage_act()
	..()
	if(affected_mob.ckey == "rosham")
		cure()
		return
	switch(stage)
		if(2)
			if(prob(45))
				affected_mob.adjustToxLoss(5)
			if(prob(1))
				to_chat(affected_mob, "<span class='danger'>Вы странно себя чувствуете…</span>")
		if(3)
			if(prob(5))
				to_chat(affected_mob, "<span class='danger'>Вам нужно танцевать!</span>")
				affected_mob.emote("dance")
			else if(prob(5))
				affected_mob.emote("gasp")
			else if(prob(10))
				to_chat(affected_mob, "<span class='danger'>Вам нужно чик-чики-бум!</span>")
				affected_mob.emote("dance")
		if(4)
			if(prob(10))
				affected_mob.emote("gasp")
				to_chat(affected_mob, "<span class='danger'>Вы чувствуете внутри пылающий бит…</span>")
			if(prob(20))
				affected_mob.adjustToxLoss(5)
		if(5)
			to_chat(affected_mob, "<span class='danger'>Ваше тело уже больше не может вмещать столько румба-бита…</span>")
			if(prob(50))
				affected_mob.gib()
