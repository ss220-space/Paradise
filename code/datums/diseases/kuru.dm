/datum/disease/kuru
	name = "Space Kuru"
	agent = "Prions"
	desc = "Uncontrollable laughing."
	max_stages = 4
	stage_prob = 5
	severity = BIOHAZARD
	visibility_flags = HIDDEN_PANDEMIC
	curable = FALSE
	can_immunity = FALSE
	ignore_immunity = TRUE //Kuru is a prion disorder, not a virus
	virus_heal_resistant = TRUE

/datum/disease/kuru/stage_act()
	if(!..())
		return FALSE

	switch(stage)
		if(1)
			if(prob(50))
				affected_mob.emote("laugh")
			if(prob(50))
				affected_mob.Jitter(50 SECONDS)
		if(2)
			if(prob(50))
				affected_mob.visible_message(span_danger("[affected_mob] laughs uncontrollably!"))
				affected_mob.Weaken(20 SECONDS)
				affected_mob.Jitter(500 SECONDS)
		if(3)
			if(prob(25))
				to_chat(affected_mob, span_danger("You feel like you are about to drop dead!"))
				to_chat(affected_mob, span_danger("Your body convulses painfully!"))
				affected_mob.apply_damages(brute = 5, oxy = 5, spread_damage = TRUE)
				affected_mob.Weaken(20 SECONDS)
				affected_mob.Jitter(500 SECONDS)
				affected_mob.visible_message(span_danger("[affected_mob] laughs uncontrollably!"))
		if(4)
			if(prob(25))
				to_chat(affected_mob, span_danger("You feel like you are going to die!"))
				affected_mob.apply_damages(brute = 75, oxy = 75, spread_damage = TRUE)
				affected_mob.Weaken(20 SECONDS)
				affected_mob.visible_message(span_danger("[affected_mob] laughs uncontrollably!"))
