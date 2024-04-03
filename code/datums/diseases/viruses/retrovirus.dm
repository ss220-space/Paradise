/// Just dont use this virus :)
/datum/disease/virus/dna_retrovirus
	name = "Retrovirus"
	agent = ""
	desc = "A DNA-altering retrovirus that scrambles the structural and unique enzymes of a host constantly."
	stage_prob = 2
	max_stages = 4
	spread_flags = CONTACT
	cure_text = "Rest or an injection of mutadone"
	cure_prob = 6
	severity = DANGEROUS
	permeability_mod = 0.4


/datum/disease/virus/dna_retrovirus/New()
	..()
	agent = "Virus class [pick("A","B","C","D","E","F")][pick("A","B","C","D","E","F")]-[rand(50,300)]"
	//else cure is rest
	if(prob(40))
		cures = list("mutadone")


/datum/disease/virus/dna_retrovirus/stage_act()
	if(!..())
		return FALSE

	switch(stage)
		if(1)
			if(prob(8))
				to_chat(affected_mob, span_danger("Your head hurts."))
			if(prob(9))
				to_chat(affected_mob, span_notice("You feel a tingling sensation in your chest."))
			if(prob(9))
				to_chat(affected_mob, span_danger("You feel angry."))

		if(2)
			if(prob(8))
				to_chat(affected_mob, span_danger("Your skin feels loose."))
			if(prob(10))
				to_chat(affected_mob, span_danger("You feel very strange."))
			if(prob(4))
				to_chat(affected_mob, span_danger("You feel a stabbing pain in your head!"))
				affected_mob.Paralyse(4 SECONDS)
			if(prob(4))
				to_chat(affected_mob, span_danger("Your stomach churns."))

		if(3)
			if(prob(10))
				to_chat(affected_mob, span_danger("Your entire body vibrates."))

			if(prob(35))
				scramble(pick(0,1), affected_mob, rand(15, 45))

		if(4)
			if(prob(60))
				scramble(pick(0,1), affected_mob, rand(15, 45))

/datum/disease/virus/dna_retrovirus/has_cure()
	if(cures.len)
		return ..()
	else
		if(affected_mob.IsSleeping())
			return TRUE
		if(affected_mob.lying_angle)
			return prob(33)
		return FALSE


