/datum/disease/ectoplasmic
	name = "Ectoplasmic fever"
	agent = "Corrupted ectoplasm"
	desc = "Caused by a revenant, it slowly depletes organic life forms and can corrupt soul."
	cures = list("holywater")
	cure_prob = 50
	cure_text = "Holy water"
	discovered = TRUE
	severity = DANGEROUS
	can_immunity = FALSE
	ignore_immunity = TRUE
	visibility_flags = HIDDEN_PANDEMIC

/datum/disease/ectoplasmic/stage_act()
	if(!..())
		return FALSE
	var/create_effect = FALSE
	var/mob/living/carbon/human/human = affected_mob
	var/turf/turf = get_turf(human)
	switch(stage)
		if(3)
			if(prob(10))
				human.apply_damage(10, STAMINA)
				to_chat(human, span_danger("You feel weak!"))
				create_effect = TRUE
			if(prob(30))
				human.vomit(stun = 0.1 SECONDS)
				create_effect = TRUE
		if(4)
			if(prob(7))
				human.vomit(stun = 2 SECONDS)
				create_effect = TRUE
			if(prob(15))
				human.AdjustLoseBreath(5 SECONDS)
				to_chat(human, span_warning("Otherworld powers exhausts you!"))
				create_effect = TRUE
			if(prob(15))
				human.AdjustConfused(10 SECONDS, bound_lower = 0, bound_upper = 30 SECONDS)
				human.apply_damage(10, TOX)
				to_chat(human, span_warning("You feel totally disoriented!"))
				create_effect = TRUE
			if(prob(20))
				human.apply_damage(20, STAMINA)
				human.AdjustWeakened(1)
				to_chat(human, span_warning("You suddenly feel [pick("sick and tired", "nauseated", "dizzy", "stabbing pain in your head")]."))
				create_effect = TRUE	
		if(5)
			if(prob(70))
				human.apply_damage(80, STAMINA)
				to_chat(human, "You feel very tired, but disease left you.")
				create_effect = TRUE
				cure()
			if(prob(30))
				if(human.influenceSin())
					create_effect = TRUE
					to_chat(human, span_revenbignotice("You suddenly feel your soul become corrupted."))
					cure()
	if(create_effect && turf)
		new /obj/effect/temp_visual/revenant(turf)
