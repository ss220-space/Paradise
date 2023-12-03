/datum/disease/vampire
	name = "Grave Fever"
	agent = "Grave Dust"
	max_stages = 4
	stage_prob = 5
	//TODO: Something with chaplain & cure
	cures = list("garlic")
	cure_prob = 8
	severity = DANGEROUS
	can_immunity = FALSE
	visibility_flags = HIDDEN_PANDEMIC

/datum/disease/vampire/stage_act()
	if(!..())
		return FALSE

	var/toxdamage = stage * 2
	var/stuntime = stage * 2

	if(prob(10))
		affected_mob.emote(pick("cough","groan", "gasp"))
		affected_mob.AdjustLoseBreath(2 SECONDS)

	if(prob(15))
		if(prob(33))
			to_chat(affected_mob, span_danger("You feel sickly and weak."))
			affected_mob.Slowed(6 SECONDS)
		affected_mob.adjustToxLoss(toxdamage)

	if(prob(5))
		to_chat(affected_mob, span_danger("Your joints ache horribly!"))
		affected_mob.Weaken(stuntime STATUS_EFFECT_CONSTANT)
