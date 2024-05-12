/datum/disease/virus/fluspanish
	name = "Spanish Inquisition Flu"
	agent = "1nqu1s1t10n flu virion"
	desc = "If left untreated the subject will burn to death for being a heretic."
	max_stages = 3
	spread_flags = AIRBORNE
	cure_text = "Spaceacillin & Anti-bodies to the common flu"
	cures = list("spaceacillin")
	cure_prob = 10
	permeability_mod = 0.75
	severity = DANGEROUS

/datum/disease/virus/fluspanish/stage_act()
	if(!..())
		return FALSE

	switch(stage)
		if(2)
			affected_mob.adjust_bodytemperature(10)
			if(prob(5))
				affected_mob.emote("sneeze")
			if(prob(5))
				affected_mob.emote("cough")
			if(prob(1))
				to_chat(affected_mob, span_danger("You're burning in your own skin!"))
				affected_mob.take_organ_damage(0,5)

		if(3)
			affected_mob.adjust_bodytemperature(20)
			if(prob(5))
				affected_mob.emote("sneeze")
			if(prob(5))
				affected_mob.emote("cough")
			if(prob(5))
				to_chat(affected_mob, span_danger("You're burning in your own skin!"))
				affected_mob.take_organ_damage(0,5)
	return

/datum/disease/virus/fluspanish/has_cure()
	//if has spaceacillin
	if(..())
		if(LAZYIN(affected_mob.resistances, /datum/disease/virus/flu))
			return TRUE
		else
			return prob(1)
	//if not
	else
		return FALSE
