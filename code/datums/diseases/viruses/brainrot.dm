/datum/disease/virus/brainrot
	name = "Мозговая гниль"
	agent = "Криптококк космозис"
	desc = "Эта болезнь разрушает клетки мозга, вызывая его воспаление, некроз и общую интоксикацию."
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
				to_chat(affected_mob, span_danger("Вы чувствуете себя не в своей тарелке."))
			if(prob(15) && affected_mob.getBrainLoss()<=98)
				affected_mob.adjustBrainLoss(1)
		if(3)
			if(prob(5))
				affected_mob.emote("stare")
			if(prob(5))
				affected_mob.emote("drool")
			if(prob(7))
				to_chat(affected_mob, span_danger("Вы чувствуете себя не в своей тарелке."))
			if(prob(25) && affected_mob.getBrainLoss()<=97)
				affected_mob.adjustBrainLoss(2)
				to_chat(affected_mob, span_danger("Вы пытаетесь вспомнить что-то важное... но не можете."))

		if(4)
			if(prob(7))
				affected_mob.emote("stare")
			if(prob(7))
				affected_mob.emote("drool")
			if(prob(30) && affected_mob.getBrainLoss()<=97)
				affected_mob.adjustBrainLoss(2)
				if(prob(30))
					to_chat(affected_mob, span_danger("Странное жужжание заполняет вашу голову, вытесняя все мысли."))
			if(prob(4))
				affected_mob.visible_message(span_warning("[affected_mob] внезапно пада[pluralize_ru(affected_mob.gender,"ет","ют")]"), span_danger("Вы теряете сознание..."))
				affected_mob.Paralyse(rand(10 SECONDS, 20 SECONDS))
			if(prob(10))
				affected_mob.AdjustStuttering(30 SECONDS, bound_upper = 30 SECONDS)
