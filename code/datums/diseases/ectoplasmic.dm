/datum/disease/ectoplasmic
	name = "Эктоплазменная лихорадка"
	agent = "Искажённая эктоплазма"
	desc = "Вызвана ревенантом, она медленно истощает органические формы жизни и может искажать душу."
	cures = list("holywater")
	cure_prob = 50
	cure_text = "Святая вода"
	discovered = TRUE
	severity = DANGEROUS
	can_immunity = FALSE
	ignore_immunity = TRUE
	visibility_flags = HIDDEN_PANDEMIC

/datum/disease/ectoplasmic/stage_act()
	if(!..())
		return FALSE

	var/create_effect = FALSE
	var/mob/living/carbon/human/human = affected_mob

	switch(stage)
		if(3)
			if(prob(10))
				human.apply_damage(10, STAMINA)
				to_chat(human, span_danger("Вы чувствуете слабость!"))
				create_effect = TRUE
			if(prob(30))
				human.vomit(stun = 0.1 SECONDS)
				create_effect = TRUE
		if(4)
			if(prob(7))
				human.vomit(stun = 2 SECONDS)
				create_effect = TRUE
			if(prob(15))
				human.AdjustLoseBreath(5 SECONDS)
				to_chat(human, span_warning("Силы иного мира истощают вас!"))
				create_effect = TRUE
			if(prob(15))
				human.AdjustConfused(10 SECONDS, bound_lower = 0, bound_upper = 30 SECONDS)
				human.apply_damage(10, TOX)
				to_chat(human, span_warning("Вы чувствуете полную дезориентацию!"))
				create_effect = TRUE
			if(prob(20))
				human.apply_damage(20, STAMINA)
				human.AdjustWeakened(1)
				to_chat(human, span_warning("Вы внезапно чувствуете [pick("тошноту и усталость", "тошноту", "головокружение", "острую боль в голове")]."))
				create_effect = TRUE
		if(5)
			if(prob(SYMPTOM_ACTIVATION_PROB * 10))
				human.mind?.add_antag_datum(/datum/antagonist/sintouched)
				to_chat(human, span_revenbignotice("Вы внезапно чувствуете, как ваша душа искажается."))
			else
				human.apply_damage(80, STAMINA)
				to_chat(human, "Вы чувствуете сильную усталость, но болезнь покинула вас.")

			create_effect = TRUE
			cure()

	if(create_effect && isturf(human.loc))
		new /obj/effect/temp_visual/revenant(human.loc)
