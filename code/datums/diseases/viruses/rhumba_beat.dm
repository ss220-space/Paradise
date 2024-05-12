//meme copy of GBS
/datum/disease/virus/rhumba_beat
	name = "The Rhumba Beat"
	agent = "Unknown"
	max_stages = 5
	spread_flags = CONTACT
	cure_text = "Chick Chicky Boom!"
	cures = list("plasma")
	severity = BIOHAZARD

/datum/disease/virus/rhumba_beat/stage_act()
	if(!..())
		return FALSE

	if(affected_mob.ckey == "rosham")
		cure()
		return

	switch(stage)
		if(2)
			if(prob(45))
				affected_mob.adjustToxLoss(5)
			if(prob(1))
				to_chat(affected_mob, span_danger("You feel strange..."))
		if(3)
			if(prob(5))
				to_chat(affected_mob, span_danger("You feel the urge to dance..."))
			else if(prob(5))
				affected_mob.emote("gasp")
			else if(prob(10))
				to_chat(affected_mob, span_danger("You feel the need to chick chicky boom..."))
		if(4)
			if(prob(10))
				affected_mob.emote("gasp")
				to_chat(affected_mob, span_danger("You feel a burning beat inside..."))
			if(prob(20))
				affected_mob.adjustToxLoss(5)
		if(5)
			to_chat(affected_mob, span_userdanger("Your body is unable to contain the Rhumba Beat..."))
			if(prob(50))
				affected_mob.gib()
