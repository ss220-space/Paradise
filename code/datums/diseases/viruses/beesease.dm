/datum/disease/virus/beesease
	name = "Beesease"
	form = "Infection"
	agent = "Apidae Infection"
	desc = "If left untreated subject will regurgitate bees."
	max_stages = 4
	stage_prob = 2
	spread_flags = CONTACT
	cures = list("sugar")
	severity = DANGEROUS
	possible_mutations = list(/datum/disease/virus/lycan)

/datum/disease/virus/beesease/stage_act()
	if(!..())
		return FALSE

	switch(stage)
		if(2)
			if(prob(10))
				to_chat(affected_mob, span_notice("You taste honey in your mouth."))
			if(prob(1))
				bee_stinging()
		if(3)
			if(prob(10))
				to_chat(affected_mob, span_danger("Your stomach rumbles."))
				affected_mob.adjustBruteLoss(2)
			if(prob(10))
				bee_stinging()
		if(4)
			if(prob(10))
				affected_mob.visible_message(span_danger("[affected_mob] buzzes."), \
												span_userdanger("Your stomach buzzes violently!"))
			if(prob(5))
				to_chat(affected_mob, span_danger("You feel something moving in your throat."))
			if(prob(15))
				bee_stinging()
			if(prob(2))
				affected_mob.visible_message(span_danger("[affected_mob] coughs up a swarm of bees!"), \
													span_userdanger("You cough up a swarm of bees!"))
				affected_mob.adjustBruteLoss(3)
				new /mob/living/simple_animal/hostile/poison/bees(affected_mob.loc)
				new /mob/living/simple_animal/hostile/poison/bees(affected_mob.loc)
				new /mob/living/simple_animal/hostile/poison/bees(affected_mob.loc)
	if(prob(5 * stage))
		playsound(get_turf(affected_mob.loc), pick('sound/creatures/bee3.ogg', 'sound/creatures/bee4.ogg'), (stage*stage)*6.25, 1)

/datum/disease/virus/beesease/proc/bee_stinging()
	to_chat(affected_mob, span_danger("Your stomach stings painfully."))
	affected_mob.Slowed(3 SECONDS, 10)
	var/datum/reagent/bee_venom/R = new
	R.volume = rand(1,3)
	affected_mob.reagents.add_reagent(R.id, R.volume)
