/// Just dont use this virus :)
/datum/disease/virus/dna_retrovirus
	name = "Ретровирус"
	agent = ""
	desc = "Ретровирус, изменяющий ДНК, который постоянно нарушает структуру и уникальные ферменты носителя."
	stage_prob = 2
	max_stages = 4
	spread_flags = CONTACT
	cure_text = "Отдых или инъекция мутадона"
	cure_prob = 6
	severity = DANGEROUS
	permeability_mod = 0.4


/datum/disease/virus/dna_retrovirus/New()
	..()
	agent = "Вирус класса [pick("A", "B", "C", "D", "E", "F")][pick("A", "B", "C", "D", "E", "F")]-[rand(50,300)]"
	//else cure is rest
	if(prob(40))
		cures = list("mutadone")


/datum/disease/virus/dna_retrovirus/stage_act()
	if(!..())
		return FALSE

	switch(stage)
		if(1)
			if(prob(8))
				to_chat(affected_mob, span_danger("У вас болит голова."))
			if(prob(9))
				to_chat(affected_mob, span_notice("Вы чувствуете покалывание в груди."))
			if(prob(9))
				to_chat(affected_mob, span_danger("Вы чувствуете злость."))

		if(2)
			if(prob(8))
				to_chat(affected_mob, span_danger("Ваша кожа кажется дряблой."))
			if(prob(10))
				to_chat(affected_mob, span_danger("Вы чувствуете себя очень странно."))
			if(prob(4))
				to_chat(affected_mob, span_danger("Вы чувствуете острую боль в голове!"))
				affected_mob.Paralyse(4 SECONDS)
			if(prob(4))
				to_chat(affected_mob, span_danger("Ваш желудок сводит."))

		if(3)
			if(prob(10))
				to_chat(affected_mob, span_danger("Всё ваше тело вибрирует."))

			if(prob(35))
				scramble(pick(0,1), affected_mob, rand(15, 45))

		if(4)
			if(prob(60))
				scramble(pick(0,1), affected_mob, rand(15, 45))

/datum/disease/virus/dna_retrovirus/has_cure()
	if(cures.len)
		return ..()
	else
		if(affected_mob.IsSleeping())
			return TRUE
		if(affected_mob.body_position == LYING_DOWN)
			return prob(33)
		return FALSE


