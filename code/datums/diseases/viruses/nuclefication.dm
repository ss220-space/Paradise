/datum/disease/virus/nuclefication // YOU WILL NEVER ESCAPE
	name = "Supermatter Dysplasia Syndrome"
	agent = "Mutated Brain Cells"
	desc = "Oh no..."
	max_stages = 5
	spread_flags = NON_CONTAGIOUS
	cures = list()              // YOU
	virus_heal_resistant = TRUE // CAN'T
	can_immunity = FALSE		// ESCAPE
	severity = DANGEROUS
	stage_prob = 5
	can_contract_dead = TRUE
	cure_text = null
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
				ADD_TRAIT(H, TRAIT_NO_SCAN, name)
				stage_message++

		if(2)
			if(stage_message == 2)
				stage_prob = 1
				stage_message++
				to_chat(H, span_notice("You feel sick."))
			if(prob(2))
				H.vomit()

			radiate(H)

		if(3)
			if(stage_message == 3)
				stage_message++
				to_chat(H, span_userdanger("You feel agony!"))
			if(prob(1))
				destiny(H, FALSE)

			radiate(H, 4, 70)

		if(4)
			H.AdjustJitter(2 SECONDS)
			if(stage_message == 4)
				to_chat(H, span_boldnotice("The pain has gone away.."))
				ADD_TRAIT(H, TRAIT_NO_PAIN, name)
				ADD_TRAIT(H, TRAIT_NO_PAIN_HUD, name)
				H.update_damage_hud()
				H.update_health_hud()
				stage_message++
			if(prob(1.5))
				destiny(H, TRUE)

			radiate(H, 6, 93)

		if(5)
			H.visible_message(span_danger("[H] become a nucleation!"), span_userdanger("YOU TURN INTO A NUCLEATION AGAIN!"))
			H.setOxyLoss(0)
			H.SetJitter(0)
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
		if(organ_check.vital || organ_check.is_dead())
			continue
		return organ_check

/datum/disease/virus/nuclefication/proc/radiate(mob/living/carbon/H, rad_ammount = 2, rad_threshold = 47)
	if(H.radiation < rad_threshold)
		H.apply_effect(rad_ammount, IRRADIATE, negate_armor = TRUE)
	if(H.getarmor(attack_flag = RAD) >= 100)
		return
	for(var/mob/living/carbon/L in range(1, H))
		if(L == H)
			continue
		var/rad_block = L.getarmor(attack_flag = RAD)
		if(rad_block >= 100)
			continue
		if(!rad_block)
			to_chat(L, span_danger("You are enveloped by a soft green glow emanating from [H]."))
		L.apply_effect(rad_ammount, IRRADIATE, rad_block)

/datum/disease/virus/nuclefication/proc/destiny(mob/living/carbon/H, silenced = FALSE)
	var/destiny = rand(1,3) // What is your destiny?
	switch(destiny)
		if(1)
			var/obj/item/organ/external/limb = check_available_limbs(H, FALSE)
			if(limb)
				H.apply_damage(50, def_zone = limb, silent = silenced)
				if(!silenced)
					to_chat(H, span_danger("You feel like you're being torn apart from the inside!"))
		if(2)
			var/obj/item/organ/external/limb = check_available_limbs(H)
			limb?.fracture()
		if(3)
			var/obj/item/organ/internal/organ = check_available_organs(H)
			organ?.necrotize()
