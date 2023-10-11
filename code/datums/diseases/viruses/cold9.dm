/datum/disease/virus/cold9
	name = "The Cold"
	agent = "ICE9-rhinovirus"
	desc = "If left untreated the subject will slow, as if partly frozen."
	max_stages = 3
	spread_flags = CONTACT
	//cure_text = "Common Cold Anti-bodies & Spaceacillin" //TODO: cure
	cures = list("spaceacillin")
	severity = MEDIUM

/datum/disease/virus/cold9/stage_act()
	..()
	switch(stage)
		if(2)
			affected_mob.bodytemperature -= 10
			if(prob(1) && prob(10))
				to_chat(affected_mob, "<span class='notice'>You feel better.</span>")
				cure()
				return
			if(prob(1))
				affected_mob.emote("sneeze")
			if(prob(1))
				affected_mob.emote("cough")
			if(prob(1))
				to_chat(affected_mob, "<span class='danger'>Your throat feels sore.</span>")
			if(prob(5))
				to_chat(affected_mob, "<span class='danger'>You feel stiff.</span>")
		if(3)
			affected_mob.bodytemperature -= 20
			if(prob(1))
				affected_mob.emote("sneeze")
			if(prob(1))
				affected_mob.emote("cough")
			if(prob(1))
				to_chat(affected_mob, "<span class='danger'>Your throat feels sore.</span>")
			if(prob(10))
				to_chat(affected_mob, "<span class='danger'>You feel stiff.</span>")
