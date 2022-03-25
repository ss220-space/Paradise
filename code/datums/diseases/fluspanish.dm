/datum/disease/fluspanish
	name = "Испанский инквизиционный грипп"
	max_stages = 3
	spread_text = "Аэрогенный"
	cure_text = "Spaceacillin & антитела к обычному гриппу"
	cures = list("spaceacillin")
	cure_chance = 10
	agent = "Вирион гриппа uHKBu3uLIu9I"
	viable_mobtypes = list(/mob/living/carbon/human)
	permeability_mod = 0.75
	desc = "Если не вылечить, то субъект сгорит заживо за свою ересь."
	severity = DANGEROUS

/datum/disease/fluspanish/stage_act()
	..()
	switch(stage)
		if(2)
			affected_mob.bodytemperature += 10
			if(prob(5))
				affected_mob.emote("sneeze")
			if(prob(5))
				affected_mob.emote("cough")
			if(prob(1))
				to_chat(affected_mob, "<span class='danger'>Вы горите заживо!</span>")
				affected_mob.take_organ_damage(0,5)

		if(3)
			affected_mob.bodytemperature += 20
			if(prob(5))
				affected_mob.emote("sneeze")
			if(prob(5))
				affected_mob.emote("cough")
			if(prob(5))
				to_chat(affected_mob, "<span class='danger'>Вы горите заживо!</span>")
				affected_mob.take_organ_damage(0,5)
	return
