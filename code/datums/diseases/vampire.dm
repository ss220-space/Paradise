/datum/disease/vampire
	name = "Grave Fever"
	max_stages = 3
	stage_prob = 5
	cures = list("spaceacillin")
	agent = "Grave Dust"
	cure_prob = 20
	severity = DANGEROUS
	can_immunity = FALSE

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
			to_chat(affected_mob, "<span class='danger'>You feel sickly and weak.</span>")
			affected_mob.Slowed(6 SECONDS)
		affected_mob.adjustToxLoss(toxdamage)

	if(prob(5))
		to_chat(affected_mob, "<span class='danger'>Your joints ache horribly!</span>")
		affected_mob.Weaken(stuntime STATUS_EFFECT_CONSTANT)
