/datum/disease/critical/dehydration
	name = "Dehydration"
	form = "Medical Emergency"
	max_stages = 3
	spread_flags = SPECIAL
	spread_text = "The patient has low water levels."
	cure_text = "Providing any form of non-ethanol drinkable liquids."
	viable_mobtypes = list(/mob/living/carbon/human)
	stage_prob = 1
	severity = DANGEROUS
	disease_flags = CURABLE
	bypasses_immunity = TRUE
	virus_heal_resistant = TRUE

/datum/disease/critical/dehydration/has_cure()
	if(ishuman(affected_mob))
		var/mob/living/carbon/human/H = affected_mob
		if((NO_THIRST in H.dna.species.species_traits) || affected_mob.mind?.vampire)
			return TRUE
		if(ismachineperson(H))
			return TRUE
	return ..()

/datum/disease/critical/dehydration/stage_act()
	if(..())
		if(isLivingSSD(affected_mob)) // We don't want AFK people dying from this.
			return
		if(affected_mob.hydration > HYDRATION_LEVEL_INEFFICIENT)
			to_chat(affected_mob, "<span class='notice'>You feel a lot better!</span>")
			cure()
			return
		switch(stage)
			if(1)
				if(prob(4))
					to_chat(affected_mob, "<span class='warning'>You feel thirsty!</span>")
				if(prob(2))
					to_chat(affected_mob, "<span class='warning'>You have a headache!</span>")
				if(prob(2))
					to_chat(affected_mob, "<span class='warning'>You feel [pick("anxious", "depressed")]!</span>")
			if(2)
				if(prob(4))
					to_chat(affected_mob, "<span class='warning'>You feel like everything is wrong with your life!</span>")
				if(prob(5))
					affected_mob.Slowed(rand(4, 16))
					to_chat(affected_mob, "<span class='warning'>You feel [pick("tired", "exhausted", "sluggish")].</span>")
				if(prob(5))
					affected_mob.Weaken(6)
					affected_mob.Stuttering(10)
					to_chat(affected_mob, "<span class='warning'>You feel [pick("numb", "confused", "dizzy", "lightheaded")].</span>")
					affected_mob.emote("collapse")
			if(3)
				if(prob(1))
					var/datum/disease/D = new /datum/disease/critical/shock
					affected_mob.ForceContractDisease(D)
				if(prob(12))
					affected_mob.Weaken(6)
					affected_mob.Stuttering(10)
					to_chat(affected_mob, "<span class='warning'>You feel [pick("numb", "confused", "dizzy", "lightheaded")].</span>")
					affected_mob.emote("collapse")
				if(prob(12))
					to_chat(affected_mob, "<span class='warning'>You feel [pick("tired", "exhausted", "sluggish")].</span>")
					affected_mob.Slowed(rand(4, 16))
