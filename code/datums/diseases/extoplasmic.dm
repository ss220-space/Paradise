/datum/disease/extoplasmic
	name = "Extoplasmic fever"
	agent = "Corrupted extoplasm"
	desc = "Caused by a revenant, it slowly depletes organic life forms."
	cures = list("holywater")
	cure_prob = 50
	discovered = TRUE
	severity = DANGEROUS
	can_immunity = FALSE
	visibility_flags = HIDDEN_PANDEMIC

/datum/disease/extoplasmic/stage_act()
	if(!..())
		return FALSE
	var/mob/living/carbon/human/H = affected_mob
	var/turf/T = get_turf(H)
	switch(stage)
		if(3)
			if(prob(5))
				H.adjustStaminaLoss(7.5)
				to_chat(H, span_danger("You feel weak!"))
				new /obj/effect/temp_visual/revenant(T)
			if(prob(5))
				H.vomit(stun = 0.1 SECONDS)
				new /obj/effect/temp_visual/revenant(T)
		if(4, 5)
			if(prob(stage))
				H.vomit(stun = 1 SECONDS)
				new /obj/effect/temp_visual/revenant(T)
			if(prob(stage))
				H.AdjustConfused(10 SECONDS, bound_lower = 0, bound_upper = 30 SECONDS)
				to_chat(H, span_warning("You feel totally disoriented!"))
				new /obj/effect/temp_visual/revenant(T)
			if(prob(stage))
				H.adjustStaminaLoss(20)
				H.AdjustWeakened(1)
				to_chat(H, "<span class='warning'>You suddenly feel [pick("sick and tired", "nauseated", "dizzy", "stabbing pain in your head")].</span>")
				new /obj/effect/temp_visual/revenant(T)

