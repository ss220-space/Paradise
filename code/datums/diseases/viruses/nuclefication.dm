#define IRRADIATION_PROB 30

/datum/disease/virus/nuclefication // YOU WILL NEVER ESCAPE
	name = "Синдром дисплазии суперматерии"
	agent = "Мутировавшие клетки мозга"
	desc = "О нет..."
	cures = list()              // YOU
	virus_heal_resistant = TRUE // CAN'T
	can_immunity = FALSE		// ESCAPE
	severity = DISEASE_SEVERITY_BIOHAZARD
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
				to_chat(H, span_notice("Вы чувствуете себя больным."))
			if(prob(2))
				H.vomit()

			radiate(H)

		if(3)
			if(stage_message == 3)
				stage_message++
				to_chat(H, span_userdanger("Вы чувствуете агонию!"))
			if(prob(1))
				destiny(H, FALSE)

			radiate(H)

		if(4)
			H.AdjustJitter(2 SECONDS)
			if(stage_message == 4)
				to_chat(H, span_boldnotice("Боль ушла..."))
				ADD_TRAIT(H, TRAIT_NO_PAIN, name)
				ADD_TRAIT(H, TRAIT_NO_PAIN_HUD, name)
				H.update_damage_hud()
				H.update_health_hud()
				stage_message++
			if(prob(1.5))
				destiny(H, TRUE)

			radiate(H)

		if(5)
			H.visible_message(span_danger("[H.declent_ru(NOMINATIVE)] превраща[PLUR_ET_YUT(affected_mob)]ся в нуклеацию!"), span_userdanger("ВЫ ПРЕВРАЩАЕТЕСЬ В НУКЛЕАЦИЮ. ОПЯТЬ!"))
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

/datum/disease/virus/nuclefication/proc/radiate(mob/living/carbon/human)
	if(prob(IRRADIATION_PROB))
		SSradiation.irradiate(human)
	radiation_pulse(
		source = human,
		max_range = 1,
		chance = IRRADIATION_PROB,
	)


/datum/disease/virus/nuclefication/proc/destiny(mob/living/carbon/H, silenced = FALSE)
	var/destiny = rand(1, 3) // What is your destiny?
	switch(destiny)
		if(1)
			var/obj/item/organ/external/limb = check_available_limbs(H, FALSE)
			if(limb)
				H.apply_damage(50, def_zone = limb, silent = silenced)
				if(!silenced)
					to_chat(H, span_danger("Вы чувствуете, будто вас разрывает изнутри!"))
		if(2)
			var/obj/item/organ/external/limb = check_available_limbs(H)
			limb?.fracture()
		if(3)
			var/obj/item/organ/internal/organ = check_available_organs(H)
			organ?.necrotize()

#undef IRRADIATION_PROB
