/datum/disease/virus/tuberculosis
	form = "Disease"
	name = "Fungal tuberculosis"
	agent = "Fungal Tubercle bacillus Cosmosis"
	desc = "A rare highly transmittable virulent virus. Few samples exist, rumoured to be carefully grown and cultured by clandestine bio-weapon specialists. Causes fever, blood vomiting, lung damage, weight loss, and fatigue."
	spread_flags = AIRBORNE
	cures = list("spaceacillin", "salbutamol")
	cure_prob = 5
	required_organs = list(/obj/item/organ/internal/lungs)
	severity = DANGEROUS
	ignore_immunity = TRUE

/datum/disease/virus/tuberculosis/stage_act()
	if(!..())
		return FALSE

	var/mob/living/carbon/human/H = affected_mob
	if(!istype(H))
		return
	switch(stage)
		if(2)
			if(prob(2))
				H.emote("cough")
				to_chat(H, "<span class='danger'>Your chest hurts.</span>")
			if(prob(2))
				to_chat(H, "<span class='danger'>Your stomach violently rumbles!</span>")
			if(prob(5))
				to_chat(H, "<span class='danger'>You feel a cold sweat form.</span>")
		if(4)
			if(prob(2))
				to_chat(H, "<span class='userdanger'>You see four of everything</span>")
				H.Dizzy(10 SECONDS)
			if(prob(2))
				to_chat(H, "<span class='danger'>You feel a sharp pain from your lower chest!</span>")
				H.adjustOxyLoss(5)
				H.emote("gasp")
			if(prob(10))
				to_chat(H, "<span class='danger'>You feel air escape from your lungs painfully.</span>")
				H.adjustOxyLoss(25)
				H.emote("gasp")
		if(5)
			if(prob(2))
				to_chat(H, "<span class='userdanger'>[pick("You feel your heart slowing...", "You relax and slow your heartbeat.")]</span>")
				H.adjustStaminaLoss(70)
			if(prob(10))
				H.adjustStaminaLoss(100)
				H.visible_message("<span class='warning'>[H] faints!</span>", "<span class='userdanger'>You surrender yourself and feel at peace...</span>")
				H.AdjustSleeping(10 SECONDS)
			if(prob(2))
				to_chat(H, "<span class='userdanger'>You feel your mind relax and your thoughts drift!</span>")
				H.AdjustConfused(16 SECONDS, bound_lower = 0, bound_upper = 200 SECONDS)
			if(prob(10))
				H.vomit(20)
			if(prob(3))
				to_chat(H, "<span class='warning'><i>[pick("Your stomach silently rumbles...", "Your stomach seizes up and falls limp, muscles dead and lifeless.", "You could eat a crayon")]</i></span>")
				H.overeatduration = max(H.overeatduration - 100, 0)
				H.adjust_nutrition(-100)
			if(prob(15))
				to_chat(H, "<span class='danger'>[pick("You feel uncomfortably hot...", "You feel like unzipping your jumpsuit", "You feel like taking off some clothes...")]</span>")
				H.bodytemperature += 40
	return
