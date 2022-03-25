/datum/disease/fake_gbs
	name = "ГБС"
	max_stages = 5
	spread_text = "Контактный"
	spread_flags = CONTACT_GENERAL
	cure_text = "Diphenhydramine & Sulfur"
	cures = list("diphenhydramine","sulfur")
	agent = "Гравитокинетический бипотенциал SADS−"
	viable_mobtypes = list(/mob/living/carbon/human, /mob/living/carbon/human/monkey)
	desc = "Если не вылечить, то наступит смерть."
	severity = BIOHAZARD

/datum/disease/fake_gbs/stage_act()
	..()
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
				to_chat(affected_mob, "<span class='danger'>Вы чувствуете навалившуюся слабость…</span>")
		if(4)
			if(prob(10))
				affected_mob.emote("cough")

		if(5)
			if(prob(10))
				affected_mob.emote("cough")
