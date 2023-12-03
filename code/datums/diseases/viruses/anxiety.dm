/datum/disease/virus/anxiety
	name = "Severe Anxiety"
	form = "Infection"
	agent = "Excess Lepidopticides"
	desc = "If left untreated subject will regurgitate butterflies."
	max_stages = 4
	spread_flags = CONTACT
	cures = list("ethanol")
	severity = MEDIUM
	possible_mutations = list(/datum/disease/virus/beesease)

/datum/disease/virus/anxiety/stage_act()
	if(!..())
		return FALSE
	switch(stage)
		if(2)
			if(prob(5))
				to_chat(affected_mob, span_notice("You feel anxious."))
			if(prob(5))
				affected_mob.AdjustJitter(5 SECONDS)
		if(3)
			if(prob(10))
				to_chat(affected_mob, span_notice("Your stomach flutters."))
			if(prob(5))
				to_chat(affected_mob, span_notice("You feel panicky."))
			if(prob(5))
				to_chat(affected_mob, span_danger("You're overtaken with panic!"))
				affected_mob.AdjustJitter(10 SECONDS, bound_upper = 20 SECONDS)
				affected_mob.AdjustStuttering(10 SECONDS, bound_upper = 20 SECONDS)
		if(4)
			if(prob(10))
				to_chat(affected_mob, span_danger("You feel butterflies in your stomach."))
			if(prob(5))
				affected_mob.visible_message(span_danger("[affected_mob] stumbles around in a panic."), \
												span_userdanger("You have a panic attack!"))
				affected_mob.AdjustConfused(rand(6 SECONDS, 12 SECONDS), bound_upper = 20 SECONDS)
				affected_mob.AdjustJitter(rand(20 SECONDS, 40 SECONDS), bound_upper = 50 SECONDS)
				affected_mob.AdjustStuttering(rand(20 SECONDS, 40 SECONDS), bound_upper = 50 SECONDS)
			if(prob(3))
				affected_mob.visible_message(span_danger("[affected_mob] coughs up butterflies!"), \
													span_userdanger("You cough up butterflies!"))
				affected_mob.Stun(rand(5 SECONDS, 10 SECONDS))
				new /mob/living/simple_animal/butterfly(affected_mob.loc)
				new /mob/living/simple_animal/butterfly(affected_mob.loc)
	return
