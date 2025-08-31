/datum/disease/virus/flu
	name = "Грипп"
	agent = "Вирион гриппа H13N1"
	desc = "Если не лечить, заражённый будет чувствовать себя очень плохо."
	max_stages = 3
	spread_flags = AIRBORNE
	visibility_flags = HIDDEN_HUD
	cure_text = "Отдых и Космоциллин"
	cures = list("spaceacillin")
	cure_prob = 30
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
				to_chat(affected_mob, span_danger("Ваши мышцы болят."))
				affected_mob.take_organ_damage(1)
			if(prob(stage))
				to_chat(affected_mob, span_danger("Ваш желудок болит."))
				affected_mob.adjustToxLoss(1)
	return

/datum/disease/virus/flu/has_cure()
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

