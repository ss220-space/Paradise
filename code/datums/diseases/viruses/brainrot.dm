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
	..()

	switch(stage)
		if(2)
			if(prob(2))
				affected_mob.emote("blink")
			if(prob(2))
				affected_mob.emote("yawn")
			if(prob(2))
				to_chat(affected_mob, "<span class='danger'>You don't feel like yourself.</span>")
			if(prob(5))
				affected_mob.adjustBrainLoss(1)
		if(3)
			if(prob(2))
				affected_mob.emote("stare")
			if(prob(2))
				affected_mob.emote("drool")
			if(prob(10) && affected_mob.getBrainLoss()<=98)//shouldn't brainpain you to death now
				affected_mob.adjustBrainLoss(2)
				if(prob(2))
					to_chat(affected_mob, "<span class='danger'>Your try to remember something important...but can't.</span>")

		if(4)
			if(prob(2))
				affected_mob.emote("stare")
			if(prob(2))
				affected_mob.emote("drool")
			if(prob(15) && affected_mob.getBrainLoss()<=98) //shouldn't brainpain you to death now
				affected_mob.adjustBrainLoss(3)
				if(prob(2))
					to_chat(affected_mob, "<span class='danger'>Strange buzzing fills your head, removing all thoughts.</span>")
			if(prob(3))
				to_chat(affected_mob, "<span class='danger'>You lose consciousness...</span>")
				affected_mob.visible_message("<span class='warning'>[affected_mob] suddenly collapses</span>")
				affected_mob.Paralyse(rand(10 SECONDS, 20 SECONDS))
				if(prob(1))
					affected_mob.emote("snore")
			if(prob(15))
				affected_mob.AdjustStuttering(6 SECONDS)

	return
