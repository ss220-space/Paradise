/datum/disease/virus/flu
	name = "The Flu"
	agent = "H13N1 flu virion"
	desc = "If left untreated the subject will feel quite unwell."
	max_stages = 3
	spread_flags = AIRBORNE
	visibility_flags = HIDDEN_HUD
	cure_text = "Rest & Spaceacillin"
	cures = list("spaceacillin")
	cure_prob = 30
	cured_message = "You feel better"
	permeability_mod = 0.75
	severity = MEDIUM

/datum/disease/virus/flu/stage_act()
	if(!..())
		return FALSE

	switch(stage)
		if(2, 3)
			if(prob(stage))
				affected_mob.emote("sneeze")
			if(prob(stage))
				affected_mob.emote("cough")
			if(prob(stage))
				to_chat(affected_mob, span_danger("Your muscles ache"))
				affected_mob.take_organ_damage(1)
			if(prob(stage))
				to_chat(affected_mob, "<span class='danger'>Your stomach hurts.</span>")
				affected_mob.adjustToxLoss(1)
	return

/datum/disease/virus/flu/has_cure()
	//if has spaceacillin
	if(..())
		if(affected_mob.IsSleeping())
			return TRUE
		if(affected_mob.lying)
			return prob(33)
		return prob(1)
	//if not
	else
		if(affected_mob.IsSleeping())
			return prob(20)
		if(affected_mob.lying)
			return prob(7)
		return FALSE

