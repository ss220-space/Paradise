/datum/disease/virus/beesease
	name = "Beesease"
	form = "Infection"
	agent = "Apidae Infection"
	desc = "If left untreated subject will turn into a beehive."
	max_stages = 4
	stage_prob = 2
	can_progress_in_dead = TRUE
	discovery_threshold = 0.9
	spread_flags = CONTACT
	cures = list("sugar")
	severity = DANGEROUS
	possible_mutations = list(/datum/disease/virus/lycan)
	var/bees_spawned = 0

/datum/disease/virus/beesease/stage_act()
	if(!..())
		return FALSE
	if(affected_mob.stat != DEAD)
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
				if(prob(7))
					bee_stinging()
			if(4)
				if(prob(10))
					affected_mob.visible_message(span_danger("[affected_mob] buzzes."), \
													span_userdanger("Your stomach buzzes violently!"))
				if(prob(5))
					to_chat(affected_mob, span_danger("You feel something moving in your throat."))
				if(prob(12))
					bee_stinging()

	if(prob(5 * stage))
		playsound(get_turf(affected_mob.loc), pick('sound/creatures/bee3.ogg', 'sound/creatures/bee4.ogg'), (stage*stage)*6.25, 1)

	if(stage == max_stages && prob(3) && bees_spawned < 10)
		affected_mob.visible_message(span_danger("Swarm of bees flies out of a [affected_mob]'s mouth!"),
											span_userdanger("Swarm of bees flies out of your mouth!"))
		affected_mob.adjustBruteLoss(3)
		for(var/i = 0, i < 3, i++)
			var/mob/living/simple_animal/hostile/poison/bees/new_bee = new(affected_mob.loc)
			new_bee.beegent = new /datum/reagent/bee_venom_beesease

		bees_spawned++

/datum/disease/virus/beesease/proc/bee_stinging()
	to_chat(affected_mob, span_danger("Your stomach stings painfully."))
	affected_mob.Slowed(3 SECONDS, 10)
	var/datum/reagent/bee_venom_beesease/R = new
	R.volume = 5
	affected_mob.reagents.add_reagent(R.id, R.volume)
