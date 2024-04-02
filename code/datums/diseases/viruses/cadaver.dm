/datum/disease/virus/cadaver
	name = "Cadaveric fever"
	form = "Заболевание"
	agent = "Cadaveric microbes"
	desc = "A terrible disease caused by rotting corpses"
	cures = list("calomel")
	cure_prob = 6
	stage_prob = 0.8
	max_stages = 5
	spread_flags = BLOOD
	severity = DANGEROUS
	discovery_threshold = 0.3 // 2 stage is visible

/datum/disease/virus/cadaver/stage_act()
	if(!..())
		return FALSE

	var/mob/living/carbon/human/H = affected_mob
	if(!istype(H))
		return

	switch(stage)
		if(2)
			if(prob(2))
				H.vomit(stun = 0.1 SECONDS)
			if(prob(7))
				H.adjust_bodytemperature(30, max_temp = H.dna.species.heat_level_1 + 10)
				to_chat(H, span_warning("You feel hot!"))
		if(3, 4)
			if(prob(3))
				H.vomit(stun = 0.1 SECONDS)
			if(prob(7))
				H.adjust_bodytemperature(30, max_temp = H.dna.species.heat_level_1 + 30)
				to_chat(H, span_warning("You feel very hot!"))
			if(prob(2))
				to_chat(H, span_warning("You feel a stabbing pain!"))
				H.emote("moan")
				H.Stun(1 SECONDS)
				H.Slowed(15 SECONDS, 5)
			if(prob(5))
				H.emote("moan")
		if(5)
			if(prob(4))
				to_chat(H, span_warning("You feel a stabbing pain!"))
				H.damageoverlaytemp = max(30, H.damageoverlaytemp)
				H.emote("moan")
				H.Stun(1 SECONDS)
				H.Slowed(20 SECONDS, 8)
				H.adjustBruteLoss(10)
			if(prob(4))
				H.emote(pick("moan", "cry"))

