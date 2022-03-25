/datum/disease/cold9
	name = "Простуда"
	max_stages = 3
	spread_text = "Контактный"
	spread_flags = CONTACT_GENERAL
	cure_text = "Обычные антитела к простуде + Spaceacillin"
	cures = list("spaceacillin")
	agent = "Риновирус ЛЁД9"
	viable_mobtypes = list(/mob/living/carbon/human)
	desc = "Если не вылечить, субъект станет заторможенным, как будто он частично замёрз."
	severity = MEDIUM

/datum/disease/cold9/stage_act()
	..()
	switch(stage)
		if(2)
			affected_mob.bodytemperature -= 10
			if(prob(1) && prob(10))
				to_chat(affected_mob, "<span class='notice'>Вам становится лучше.</span>")
				cure()
				return
			if(prob(1))
				affected_mob.emote("sneeze")
			if(prob(1))
				affected_mob.emote("cough")
			if(prob(1))
				to_chat(affected_mob, "<span class='danger'>У вас першит в горле.</span>")
			if(prob(5))
				to_chat(affected_mob, "<span class='danger'>Ваше тело теряет гибкость.</span>")
		if(3)
			affected_mob.bodytemperature -= 20
			if(prob(1))
				affected_mob.emote("sneeze")
			if(prob(1))
				affected_mob.emote("cough")
			if(prob(1))
				to_chat(affected_mob, "<span class='danger'>У вас першит в горле.</span>")
			if(prob(10))
				to_chat(affected_mob, "<span class='danger'>Ваше тело теряет гибкость.</span>")
