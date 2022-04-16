/datum/disease/brainrot
	name = "Мозговая гниль"
	max_stages = 4
	spread_text = "Контактный"
	spread_flags = CONTACT_GENERAL
	cure_text = "Mannitol"
	cures = list("mannitol")
	agent = "Криптококк космозис"
	viable_mobtypes = list(/mob/living/carbon/human)
	cure_chance = 15 // higher chance to cure, since two reagents are required
	desc = "Эта болезнь разрушает клетки мозга, провоцируя его воспаление и последующий некроз."
	required_organs = list(/obj/item/organ/internal/brain)
	severity = DANGEROUS

/datum/disease/brainrot/stage_act() // Removed toxloss because damaging diseases are pretty horrible. Last round it killed the entire station because the cure didn't work -- Urist -ACTUALLY Removed rather than commented out, I don't see it returning - RR
	..()

	switch(stage)
		if(2)
			if(prob(2))
				affected_mob.emote("blink")
			if(prob(2))
				affected_mob.emote("yawn")
			if(prob(2))
				to_chat(affected_mob, "<span class='danger'>Кажется, будто вы — кто-то другой.</span>")
			if(prob(5))
				affected_mob.adjustBrainLoss(1)
		if(3)
			if(prob(2))
				affected_mob.emote("stare")
			if(prob(2))
				affected_mob.emote("drool")
			if(prob(10) && affected_mob.getBrainLoss()<=98) // shouldn't brainpain you to death now
				affected_mob.adjustBrainLoss(2)
				if(prob(2))
					to_chat(affected_mob, "<span class='danger'>Вы пытаетесь вспомнить что-то важное… но не можете.</span>")

		if(4)
			if(prob(2))
				affected_mob.emote("stare")
			if(prob(2))
				affected_mob.emote("drool")
			if(prob(15) && affected_mob.getBrainLoss()<=98) // shouldn't brainpain you to death now
				affected_mob.adjustBrainLoss(3)
				if(prob(2))
					to_chat(affected_mob, "<span class='danger'>Голову наполняет странное жужжание, поглощая все мысли…</span>")
			if(prob(3))
				to_chat(affected_mob, "<span class='danger'>Вы теряете сознание…</span>")
				affected_mob.visible_message("<span class='warning'>[affected_mob] внезапно падает.</span>")
				affected_mob.Paralyse(rand(5,10))
				if(prob(1))
					affected_mob.emote("snore")
			if(prob(15))
				affected_mob.stuttering += 3

	return
