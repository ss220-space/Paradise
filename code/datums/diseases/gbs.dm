/datum/disease/gbs
	name = "ГБС"
	max_stages = 5
	spread_text = "Контактный"
	spread_flags = CONTACT_GENERAL
	cure_text = "Diphenhydramine & Sulfur"
	cures = list("diphenhydramine","sulfur")
	cure_chance = 15//higher chance to cure, since two reagents are required
	agent = "Гравитокинетический бипотенциал SADS+"
	viable_mobtypes = list(/mob/living/carbon/human)
	disease_flags = CAN_CARRY|CAN_RESIST|CURABLE
	permeability_mod = 1
	severity = BIOHAZARD

/datum/disease/gbs/stage_act()
	..()
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
				to_chat(affected_mob, "<span class='danger'>Вы чувствуете навалившуюся слабость…</span>")
		if(4)
			if(prob(10))
				affected_mob.emote("cough")
			affected_mob.adjustToxLoss(5)
		if(5)
			to_chat(affected_mob, "<span class='danger'>Ваше тело будто пытается вывернуться наизнанку…</span>")
			if(prob(50))
				affected_mob.delayed_gib()
		else
			return

/datum/disease/gbs/curable
	name = "Незаразный ГБС"
	stage_prob = 5
	spread_text = "Незаразно"
	spread_flags = SPECIAL
	cure_text = "Cryoxadone"
	cures = list("cryoxadone")
	cure_chance = 10
	agent = "гиббис"
	spread_flags = NON_CONTAGIOUS
	disease_flags = CURABLE
