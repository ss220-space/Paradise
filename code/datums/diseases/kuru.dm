/datum/disease/kuru
	form = "Болезнь"
	name = "Космический куру"
	max_stages = 4
	stage_prob = 5
	spread_text = "Незаразно"
	spread_flags = SPECIAL
	cure_text = "Incurable"
	agent = "Прионы"
	viable_mobtypes = list(/mob/living/carbon/human)
	desc = "Безудержный смех."
	severity = BIOHAZARD
	spread_flags = NON_CONTAGIOUS
	disease_flags = CAN_CARRY
	bypasses_immunity = TRUE //Kuru is a prion disorder, not a virus
	virus_heal_resistant = TRUE

/datum/disease/kuru/stage_act()
	..()
	switch(stage)
		if(1)
			if(prob(50))
				affected_mob.emote("laugh")
			if(prob(50))
				affected_mob.Jitter(25)
		if(2)
			if(prob(50))
				affected_mob.visible_message("<span class='danger'>[affected_mob] безудержно смеётся!</span>")
				affected_mob.Stun(10)
				affected_mob.Weaken(10)
				affected_mob.Jitter(250)
				affected_mob.drop_l_hand()
				affected_mob.drop_r_hand()
		if(3)
			if(prob(25))
				to_chat(affected_mob, "<span class='danger'>Вы вот-вот упадёте замертво!</span>")
				to_chat(affected_mob, "<span class='danger'>Вы содрогаетесь от боли!</span>")
				affected_mob.drop_l_hand()
				affected_mob.drop_r_hand()
				affected_mob.adjustBruteLoss(5)
				affected_mob.adjustOxyLoss(5)
				affected_mob.Stun(10)
				affected_mob.Weaken(10)
				affected_mob.Jitter(250)
				affected_mob.visible_message("<span class='danger'>[affected_mob] безудержно смеётся!</span>")
		if(4)
			if(prob(25))
				to_chat(affected_mob, "<span class='danger'>Вы, кажется, скоро умрёте!</span>")
				affected_mob.adjustOxyLoss(75)
				affected_mob.adjustBruteLoss(75)
				affected_mob.drop_l_hand()
				affected_mob.drop_r_hand()
				affected_mob.Stun(10)
				affected_mob.Weaken(10)
				affected_mob.visible_message("<span class='danger'>[affected_mob] безудержно смеётся!</span>")
