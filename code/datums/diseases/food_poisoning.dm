/datum/disease/food_poisoning
	name = "Food Poisoning"
	agent = "Salmonella"
	desc = "Nausea, sickness, and vomitting."
	max_stages = 3
	stage_prob = 5
	cure_text = "Proper diet & sleep"
	cures = list("chicken_soup")
	cure_prob = 100	//override in has_cure()
	severity = MINOR
	can_immunity = FALSE
	ignore_immunity = TRUE
	virus_heal_resistant = TRUE
	visibility_flags = HIDDEN_PANDEMIC
	possible_mutations = list(/datum/disease/virus/tuberculosis)

/datum/disease/food_poisoning/stage_act()
	if(!..())
		return FALSE

	switch(stage)
		if(1)
			if(prob(5))
				to_chat(affected_mob, span_danger("Your stomach feels weird."))
			if(prob(5))
				to_chat(affected_mob, span_danger("You feel queasy."))
		if(2)
			if(prob(10))
				affected_mob.emote("groan")
			if(prob(5))
				to_chat(affected_mob, span_danger("Your stomach aches."))
			if(prob(5))
				to_chat(affected_mob, span_danger("You feel nauseous."))
		if(3)
			if(prob(10))
				affected_mob.emote("moan")
			if(prob(10))
				affected_mob.emote("groan")
			if(prob(1))
				to_chat(affected_mob, span_danger("Your stomach hurts."))
			if(prob(1))
				to_chat(affected_mob, span_danger("You feel sick."))
			if(prob(5))
				if(affected_mob.nutrition > 10)
					affected_mob.visible_message(span_danger("[affected_mob] vomits on the floor profusely!"))
					affected_mob.fakevomit(no_text = 1)
					affected_mob.adjust_nutrition(-rand(3,5))
				else
					to_chat(affected_mob, span_danger("Your stomach lurches painfully!"))
					affected_mob.visible_message(span_danger("[affected_mob] gags and retches!"))
					affected_mob.Stun(rand(4 SECONDS, 8 SECONDS))
					affected_mob.Weaken(rand(4 SECONDS, 8 SECONDS))

/datum/disease/food_poisoning/has_cure()
	if(..())
		if(affected_mob.IsSleeping())
			return prob(80 - 15 * stage)
		return prob(8)
	else
		if(affected_mob.IsSleeping())
			return prob(30 - 7.5 * stage)
		return prob(1) && prob(50)
