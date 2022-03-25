/datum/disease/berserker
	name = "Берсерк"
	max_stages = 2
	stage_prob = 5
	spread_text = "Незаразно"
	spread_flags = SPECIAL
	cure_text = "Антипсихотические препараты"
	cures = list("haloperidol")
	agent = "Зубчатые кристаллы"
	cure_chance = 10
	viable_mobtypes = list(/mob/living/carbon/human)
	desc = "Брань, крики, неконтролируемое избиение окружающих."
	severity = DANGEROUS
	disease_flags = CURABLE
	spread_flags = NON_CONTAGIOUS

/datum/disease/berserker/stage_act()
	..()
	if(affected_mob.reagents.has_reagent("thc"))
		to_chat(affected_mob, "<span class='notice'>Вы успокаиваетесь.</span>")
		cure()
		return
	switch(stage)
		if(1)
			if(prob(5))
				affected_mob.emote(pick("twitch_s", "grumble"))
			if(prob(5))
				var/speak = pick("Гр-р…", "У-у…", "У-у, сука…", "Переебу…", "Ебать…", "Сука…", "Вьебу…", "Уебу…", "Тебе пиздец, сука…")
				affected_mob.say(speak)
		if(2)
			if(prob(5))
				affected_mob.emote(pick("twitch_s", "scream"))
			if(prob(5))
				var/speak = pick("АААРРГГХХХ!!!", "ААА!!!", "ГР-Р!!!", "УБЬЮ!!!", "ПИЗДА!!!", "СУКА! СУ-У-У-У-У-У-КА!!!", "ЁБАНЫЕ ГОВНОЕДЫ!!!", "ГОВНОЕД!")
				affected_mob.say(speak)
			if(prob(15))
				affected_mob.visible_message("<span class='danger'>[affected_mob] сильно дёргается!</span>")
				affected_mob.drop_l_hand()
				affected_mob.drop_r_hand()
			if(prob(33))
				if(affected_mob.incapacitated())
					affected_mob.visible_message("<span class='danger'>[affected_mob] дёргается и трясётся!</span>")
					return
				affected_mob.visible_message("<span class='danger'>[affected_mob] яростно мечется!</span>")
				for(var/mob/living/carbon/M in range(1, affected_mob))
					if(M == affected_mob)
						continue
					var/damage = rand(1, 5)
					if(prob(80))
						playsound(affected_mob.loc, "punch", 25, 1, -1)
						affected_mob.visible_message("<span class='danger'>[affected_mob] сильно бьёт [M]!</span>")
						M.adjustBruteLoss(damage)
					else
						playsound(affected_mob.loc, 'sound/weapons/punchmiss.ogg', 25, 1, -1)
						affected_mob.visible_message("<span class='danger'>[affected_mob] пытается ударить [M] и промахивается!</span>")
