/datum/disease/appendicitis
	form = "Condition"
	name = "Appendicitis"
	max_stages = 3
	cure_text = "Surgery"
	agent = "Shitty Appendix"
	desc = "If left untreated the subject will become very weak, and may vomit often."
	severity = "Dangerous!"
	curable = FALSE
	spread_flags = NON_CONTAGIOUS
	visibility_flags = HIDDEN_PANDEMIC
	required_organs = list(/obj/item/organ/internal/appendix)
	ignore_immunity = TRUE
	virus_heal_resistant = TRUE

/datum/disease/appendicitis/stage_act()
	..()
	var/mob/living/carbon/human/H = affected_mob
	if(!istype(H))
		return
	switch(stage)
		if(1)
			if(prob(5))
				H.emote("cough")
		if(2)
			var/obj/item/organ/internal/appendix/A = H.get_int_organ(/obj/item/organ/internal/appendix)
			if(A)
				A.inflamed = 1
				A.update_icon()
			if(prob(3))
				to_chat(H, "<span class='warning'>You feel a stabbing pain in your abdomen!</span>")
				H.Stun(rand(4 SECONDS, 6 SECONDS))
				H.adjustToxLoss(1)
		if(3)
			if(prob(1))
				H.vomit(95)
