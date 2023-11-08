/datum/disease/virus/lycan
	name = "Lycancoughy"
	form = "Infection"
	agent = "Excess Snuggles"
	desc = "If left untreated subject will regurgitate... puppies."
	max_stages = 4
	spread_flags = CONTACT
	cures = list("ethanol")
	severity = DANGEROUS
	var/barklimit = 0

/datum/disease/virus/lycan/stage_act()
	if(!..())
		return FALSE

	switch(stage)
		if(2)
			if(prob(5))
				to_chat(affected_mob, span_notice("You itch."))
				affected_mob.emote("cough")
		if(3)
			if(prob(10))
				to_chat(affected_mob, span_notice("You hear faint barking."))
			if(prob(5))
				to_chat(affected_mob, span_notice("You crave meat."))
				affected_mob.emote("cough")
			if(prob(2))
				to_chat(affected_mob, span_danger("Your stomach growls!"))
		if(4)
			if(prob(10))
				to_chat(affected_mob, span_danger("Your stomach barks?!"))
			if(prob(5))
				affected_mob.visible_message(span_danger("[affected_mob] howls!"), \
												span_userdanger("You howl!"))
				affected_mob.AdjustConfused(rand(12 SECONDS, 16 SECONDS))
			if(prob(3) && barklimit <= 10)
				var/list/puppytype = list(
					/mob/living/simple_animal/pet/dog/corgi/puppy,
					/mob/living/simple_animal/pet/dog/pug,
					/mob/living/simple_animal/pet/dog/fox)

				var/mob/living/puppypicked = pick(puppytype)
				affected_mob.visible_message(span_danger("[affected_mob] coughs up [initial(puppypicked.name)]!"), \
													span_userdanger("You cough up [initial(puppypicked.name)]?!"))
				new puppypicked(affected_mob.loc)
				new puppypicked(affected_mob.loc)
				barklimit ++
			if(prob(1))
				var/list/plushtype = list(/obj/item/toy/plushie/orange_fox, /obj/item/toy/plushie/corgi, /obj/item/toy/plushie/robo_corgi, /obj/item/toy/plushie/pink_fox)
				var/obj/item/toy/plushie/coughfox = pick(plushtype)
				new coughfox(affected_mob.loc)
				affected_mob.visible_message(span_danger("[affected_mob] coughs up a [initial(coughfox.name)]!"), \
													span_userdanger("You cough [initial(coughfox.name)] up ?!"))
			if(prob(50))
				affected_mob.emote("cough")
			affected_mob.adjustBruteLoss(5)
	return
