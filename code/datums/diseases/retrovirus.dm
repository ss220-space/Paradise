/datum/disease/dna_retrovirus
	name = "Ретровирус"
	max_stages = 4
	spread_text = "Контактный"
	spread_flags = CONTACT_GENERAL
	cure_text = "Отдых, либо инъекция mutadone"
	cure_chance = 6
	agent = ""
	viable_mobtypes = list(/mob/living/carbon/human)
	desc = "Изменяющий ДНК ретровирус, постоянно меняющий структурные и уникальные ферменты носителя."
	severity = DANGEROUS
	permeability_mod = 0.4
	stage_prob = 2
	var/SE
	var/UI
	var/restcure = 0


/datum/disease/dna_retrovirus/New()
	..()
	agent = "Вирус класса [pick("А","Б","В","Г","Д","Е")][pick("А","Б","В","Г","Д","Е")]-[rand(50,300)]"
	if(prob(40))
		cures = list("mutadone")
	else
		restcure = 1


/datum/disease/dna_retrovirus/stage_act()
	..()
	switch(stage)
		if(1)
			if(restcure)
				if(affected_mob.lying && prob(30))
					to_chat(affected_mob, "<span class='notice'>Вам становится лучше.</span>")
					cure()
					return
			if(prob(8))
				to_chat(affected_mob, "<span class='danger'>У вас болит голова.</span>")
			if(prob(9))
				to_chat(affected_mob, "Вы чувствуете покалывание в груди.")
			if(prob(9))
				to_chat(affected_mob, "<span class='danger'>Вы чувствуете злость.</span>")
		if(2)
			if(restcure)
				if(affected_mob.lying && prob(20))
					to_chat(affected_mob, "<span class='notice'>Вам становится лучше.</span>")
					cure()
					return
			if(prob(8))
				to_chat(affected_mob, "<span class='danger'>Ваша кожа обвисает.</span>")
			if(prob(10))
				to_chat(affected_mob, "Вы чувствуете себя очень странно.")
			if(prob(4))
				to_chat(affected_mob, "<span class='danger'>У вас раскалывается голова!</span>")
				affected_mob.Paralyse(2)
			if(prob(4))
				to_chat(affected_mob, "<span class='danger'>У вас бурчит в животе.</span>")
		if(3)
			if(restcure)
				if(affected_mob.lying && prob(20))
					to_chat(affected_mob, "<span class='notice'>Вам становится лучше.</span>")
					cure()
					return
			if(prob(10))
				to_chat(affected_mob, "<span class='danger'>Всё ваше тело дрожит.</span>")

			if(prob(35))
				if(prob(50))
					scramble(1, affected_mob, rand(15, 45))
				else
					scramble(0, affected_mob, rand(15, 45))

		if(4)
			if(restcure)
				if(affected_mob.lying && prob(5))
					to_chat(affected_mob, "<span class='notice'>Вам становится лучше.</span>")
					cure()
					return
			if(prob(60))
				if(prob(50))
					scramble(1, affected_mob, rand(15, 45))
				else
					scramble(0, affected_mob, rand(15, 45))
