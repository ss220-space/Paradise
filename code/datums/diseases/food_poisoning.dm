/datum/disease/food_poisoning
	name = "Пищевое отравление"
	max_stages = 3
	stage_prob = 5
	spread_text = "Незаразно"
	spread_flags = SPECIAL
	cure_text = "Сон"
	agent = "Сальмонелла"
	cures = list("chicken_soup")
	cure_chance = 10
	viable_mobtypes = list(/mob/living/carbon/human)
	desc = "Тошнота, слабость, рвота."
	severity = MINOR
	disease_flags = CURABLE
	spread_flags = NON_CONTAGIOUS
	virus_heal_resistant = TRUE

/datum/disease/food_poisoning/stage_act()
	..()
	if(affected_mob.sleeping && prob(33))
		to_chat(affected_mob, "<span class='notice'>Вам становится лучше.</span>")
		cure()
		return
	switch(stage)
		if(1)
			if(prob(5))
				to_chat(affected_mob, "<span class='danger'>Ваш желудок ведёт себя необычно.</span>")
			if(prob(5))
				to_chat(affected_mob, "<span class='danger'>Вас подташнивает.</span>")
		if(2)
			if(affected_mob.sleeping && prob(40))
				to_chat(affected_mob, "<span class='notice'>Вам становится лучше.</span>")
				cure()
				return
			if(prob(1) && prob(10))
				to_chat(affected_mob, "<span class='notice'>Вам становится лучше.</span>")
				cure()
				return
			if(prob(10))
				affected_mob.emote("groan")
			if(prob(5))
				to_chat(affected_mob, "<span class='danger'>У вас ноет живот.</span>")
			if(prob(5))
				to_chat(affected_mob, "<span class='danger'>Вас тошнит.</span>")
		if(3)
			if(affected_mob.sleeping && prob(25))
				to_chat(affected_mob, "<span class='notice'>Вам становится лучше.</span>")
				cure()
				return
			if(prob(1) && prob(10))
				to_chat(affected_mob, "<span class='notice'>Вам становится лучше.</span>")
				cure()
				return
			if(prob(10))
				affected_mob.emote("moan")
			if(prob(10))
				affected_mob.emote("groan")
			if(prob(1))
				to_chat(affected_mob, "<span class='danger'>У вас болит живот.</span>")
			if(prob(1))
				to_chat(affected_mob, "<span class='danger'>Вы плохо себя чувствуете.</span>")
			if(prob(5))
				if(affected_mob.nutrition > 10)
					affected_mob.visible_message("<span class='danger'>[affected_mob] обильно заблёвывает пол!</span>")
					affected_mob.fakevomit(no_text = 1)
					affected_mob.adjust_nutrition(-rand(3,5))
				else
					to_chat(affected_mob, "<span class='danger'>У вас болезненно крутит живот!</span>")
					affected_mob.visible_message("<span class='danger'>[affected_mob] давится и рыгает!</span>")
					affected_mob.Stun(rand(2,4))
					affected_mob.Weaken(rand(2,4))
