/datum/disease/virus/nuclefication // YOU WILL NEVER ESCAPE
	name = "Supermatter Dysplasia Syndrome"
	agent = "Mutated Brain Cells"
	desc = "Oh no..."
	max_stages = 5
	spread_flags = NON_CONTAGIOUS
	cures = list() // NO WAY
	virus_heal_resistant = TRUE // YOU
	can_immunity = FALSE		// CAN'T
	ignore_immunity = TRUE		// ESCAPE
	severity = DANGEROUS
	stage_prob = 1
	//required_organs = list(/obj/item/organ/internal/brain/crystal)
	var/stage_message = 1

/datum/disease/virus/nuclefication/stage_act()
	if(!..())
		return FALSE

	if(isnucleation(affected_mob) || !ishuman(affected_mob))
		cure()
		return FALSE

	var/mob/living/carbon/H = affected_mob

	switch(stage)

		if(1)
			if(stage_message == 1)
				stage_message++

		if(2)
			if(stage_message == 2)
				stage_message++
				to_chat(H, span_notice("You feel sick."))
			if(prob(2))
				H.vomit()
			if(prob(25))
				H.adjustToxLoss(0.5)
				H.adjustFireLoss(0.5)

		if(3)
			if(stage_message == 3)
				stage_message++
			if(prob(10))
				to_chat(H, span_userdanger("You feel terrible unbearable pain. AAAHHH!"))
				H.emote("scream")
				H.Weaken(5 SECONDS)
				H.do_jitter_animation(500, 30)
			if(prob(1))
				var/destiny = rand(1,3) // What is your destiny?

				switch(destiny)
					if(1)
						var/obj/item/organ/external/limb = check_available_limbs(H, FALSE)
						limb?.receive_damage(50)
						to_chat(H, span_danger("You feel like you're being torn apart from the inside!"))
					if(2)
						var/obj/item/organ/external/limb = check_available_limbs(H)
						limb?.fracture()
					if(3)
						var/obj/item/organ/internal/organ = check_available_organs(H)
						organ?.necrotize()
						to_chat(H, span_notice("It's a test message, your organ must be dead now."))

		if(4)
			H.AdjustJitter(5 SECONDS)
			if(stage_message == 4)
				to_chat(H, span_boldnotice("The pain has gone away.."))
				var/datum/species/mob = H.dna.species
				mob.species_traits |= NO_PAIN_FEEL
				stage_message++
			if(prob(1.5))
				var/destiny = rand(1,3) // What is your destiny now?

				switch(destiny)
					if(1)
						var/obj/item/organ/external/limb = check_available_limbs(H, FALSE)
						limb?.receive_damage(50, silent = TRUE)
					if(2)
						var/obj/item/organ/external/limb = check_available_limbs(H)
						limb?.fracture()
					if(3)
						var/obj/item/organ/internal/organ = check_available_organs(H)
						organ?.necrotize()
						to_chat(H, span_notice("It's a test message, your organ must be dead now."))
		if(5)
			H.visible_message(span_danger("[H] become a nucleation!"), span_userdanger("YOU TURN INTO A NUCLEATION AGAIN!"))
			var/mob/living/carbon/human/nucleat = H
			nucleat?.set_species(/datum/species/nucleation, retain_damage = TRUE, keep_missing_bodyparts = TRUE, transfer_special_internals = TRUE)

/datum/disease/virus/nuclefication/proc/check_available_limbs(mob/living/carbon/human/target, check_fracture = TRUE)
	var/list/obj/item/organ/external/O = target.bodyparts.Copy()
	while(length(O))
		var/obj/item/organ/external/limb_check = pick_n_take(O)
		if(check_fracture && (limb_check.has_fracture() || limb_check.cannot_break))
			continue
		return limb_check

/datum/disease/virus/nuclefication/proc/check_available_organs(mob/living/carbon/human/target)
	var/list/obj/item/organ/internal/I = target.internal_organs.Copy()
	while(length(I))
		var/obj/item/organ/internal/organ_check = pick_n_take(I)
		if(organ_check.vital || organ_check.status & ORGAN_DEAD)
			continue
		return organ_check
