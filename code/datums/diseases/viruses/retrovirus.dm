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
	var/SE
	var/UI
	var/restcure = 0


/datum/disease/virus/dna_retrovirus/New()
	..()
	agent = "Virus class [pick("A","B","C","D","E","F")][pick("A","B","C","D","E","F")]-[rand(50,300)]"
	if(prob(40))
		cures = list("mutadone")
	else
		restcure = 1


/datum/disease/virus/dna_retrovirus/stage_act()
	if(!..())
		return FALSE

	switch(stage)
		if(1)
			if(restcure)
				if(affected_mob.lying && prob(30))
					to_chat(affected_mob, "<span class='notice'>You feel better.</span>")
					cure()
					return
			if(prob(8))
				to_chat(affected_mob, "<span class='danger'>Your head hurts.</span>")
			if(prob(9))
				to_chat(affected_mob, "You feel a tingling sensation in your chest.")
			if(prob(9))
				to_chat(affected_mob, "<span class='danger'>You feel angry.</span>")
		if(2)
			if(restcure)
				if(affected_mob.lying && prob(20))
					to_chat(affected_mob, "<span class='notice'>You feel better.</span>")
					cure()
					return
			if(prob(8))
				to_chat(affected_mob, "<span class='danger'>Your skin feels loose.</span>")
			if(prob(10))
				to_chat(affected_mob, "You feel very strange.")
			if(prob(4))
				to_chat(affected_mob, "<span class='danger'>You feel a stabbing pain in your head!</span>")
				affected_mob.Paralyse(4 SECONDS)
			if(prob(4))
				to_chat(affected_mob, "<span class='danger'>Your stomach churns.</span>")
		if(3)
			if(restcure)
				if(affected_mob.lying && prob(20))
					to_chat(affected_mob, "<span class='notice'>You feel better.</span>")
					cure()
					return
			if(prob(10))
				to_chat(affected_mob, "<span class='danger'>Your entire body vibrates.</span>")

			if(prob(35))
				if(prob(50))
					scramble(1, affected_mob, rand(15, 45))
				else
					scramble(0, affected_mob, rand(15, 45))

		if(4)
			if(restcure)
				if(affected_mob.lying && prob(5))
					to_chat(affected_mob, "<span class='notice'>You feel better.</span>")
					cure()
					return
			if(prob(60))
				if(prob(50))
					scramble(1, affected_mob, rand(15, 45))
				else
					scramble(0, affected_mob, rand(15, 45))
