/datum/disease/virus/cold
	name = "The Cold"
	agent = "XY-rhinovirus"
	desc = "If left untreated the subject will contract the flu."
	max_stages = 3
	spread_flags = AIRBORNE
	visibility_flags = HIDDEN_HUD
	cure_text = "Rest & Spaceacillin"
	cures = list("spaceacillin")
	cure_prob = 30
	permeability_mod = 0.5
	severity = MINOR

/datum/disease/virus/cold/stage_act()
	if(!..())
		return FALSE

	switch(stage)
		if(2, 3)
			if(prob(stage))
				affected_mob.emote("sneeze")
			if(prob(stage))
				affected_mob.emote("cough")
			if(prob(stage))
				to_chat(affected_mob, span_danger("Your throat feels sore."))
			if(prob(stage))
				to_chat(affected_mob, span_danger("Mucous runs down the back of your throat."))
		if(3)
			if(prob(1) && prob(50))
				if(!LAZYIN(affected_mob.resistances, /datum/disease/virus/flu))
					var/datum/disease/virus/flu/Flu = new
					Flu.Contract(affected_mob)
					cure()

/datum/disease/virus/cold/has_cure()
	//if has spaceacillin
	if(..())
		if(affected_mob.IsSleeping())
			return TRUE
		if(affected_mob.body_position == LYING_DOWN)
			return prob(33)
		return prob(1)
	//if not
	else
		if(affected_mob.IsSleeping())
			return prob(20)
		if(affected_mob.body_position == LYING_DOWN)
			return prob(7)
		return FALSE
