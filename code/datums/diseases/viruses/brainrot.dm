/datum/disease/virus/brainrot
	name = "Brainrot"
	agent = "Cryptococcus Cosmosis"
	desc = "This disease destroys the braincells, causing brain fever, brain necrosis and general intoxication."
	max_stages = 4
	spread_flags = CONTACT
	cures = list("mannitol")
	cure_prob = 15
	required_organs = list(/obj/item/organ/internal/brain)
	severity = DANGEROUS
	mutation_reagents = list("mutagen", "neurotoxin2")
	possible_mutations = list(/datum/disease/kuru, /datum/disease/virus/advance/preset/mind_restoration, /datum/disease/virus/transformation/jungle_fever)

/datum/disease/virus/brainrot/stage_act()
	if(!..())
		return FALSE

	switch(stage)
		if(2)
			if(prob(3))
				affected_mob.emote("blink")
			if(prob(4))
				affected_mob.emote("yawn")
			if(prob(7))
				to_chat(affected_mob, span_danger("You don't feel like yourself."))
			if(prob(15) && affected_mob.getBrainLoss()<=98)
				affected_mob.adjustBrainLoss(1)
		if(3)
			if(prob(5))
				affected_mob.emote("stare")
			if(prob(5))
				affected_mob.emote("drool")
			if(prob(7))
				to_chat(affected_mob, span_danger("You don't feel like yourself."))
			if(prob(25) && affected_mob.getBrainLoss()<=97)
				affected_mob.adjustBrainLoss(2)
				to_chat(affected_mob, span_danger("Your try to remember something important...but can't."))

		if(4)
			if(prob(7))
				affected_mob.emote("stare")
			if(prob(7))
				affected_mob.emote("drool")
			if(prob(30) && affected_mob.getBrainLoss()<=97)
				affected_mob.adjustBrainLoss(2)
				if(prob(30))
					to_chat(affected_mob, span_danger("Strange buzzing fills your head, removing all thoughts."))
			if(prob(4))
				affected_mob.visible_message(span_warning("[affected_mob] suddenly collapses"), span_danger("You lose consciousness..."))
				affected_mob.Paralyse(rand(10 SECONDS, 20 SECONDS))
			if(prob(10))
				affected_mob.AdjustStuttering(30 SECONDS, bound_upper = 30 SECONDS)
