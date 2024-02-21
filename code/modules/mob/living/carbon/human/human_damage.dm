//Updates the mob's health from organs and mob damage variables
/mob/living/carbon/human/updatehealth(reason = "none given", should_log = FALSE)
	if(status_flags & GODMODE)
		return ..()

	var/total_burn  = 0
	var/total_brute = 0

	for(var/obj/item/organ/external/bodypart as anything in bodyparts)	//hardcoded to streamline things a bit
		total_brute += bodypart.brute_dam //calculates health based on organ brute and burn
		total_burn += bodypart.burn_dam

	health = maxHealth - getOxyLoss() - getToxLoss() - getCloneLoss() - total_burn - total_brute

	//TODO: fix husking
	if(((maxHealth - total_burn) < HEALTH_THRESHOLD_DEAD) && stat == DEAD)
		ChangeToHusk()
	update_stat("updatehealth([reason])", should_log)

/mob/living/carbon/human/adjustBrainLoss(amount, updating_health = TRUE, use_brain_mod = TRUE)
	if(status_flags & GODMODE)
		return STATUS_UPDATE_NONE	//godmode

	if(dna.species && dna.species.has_organ[INTERNAL_ORGAN_BRAIN])
		var/obj/item/organ/internal/brain/sponge = get_int_organ(/obj/item/organ/internal/brain)
		if(sponge)
			if(dna.species && amount > 0)
				if(use_brain_mod)
					amount = amount * (dna.species.brain_mod + get_vampire_bonus(BRAIN))
			sponge.damage = clamp(sponge.damage + amount, 0, 120)
			if(sponge.damage >= 120 && stat != DEAD)
				visible_message("<span class='alert'><B>[src]</B> goes limp, [p_their()] facial expression utterly blank.</span>")
				death()
	if(updating_health)
		update_stat("adjustBrainLoss")
	return STATUS_UPDATE_STAT

/mob/living/carbon/human/setBrainLoss(amount, updating_health = TRUE, use_brain_mod = TRUE)
	if(status_flags & GODMODE)
		return STATUS_UPDATE_NONE	//godmode

	if(dna.species && dna.species.has_organ[INTERNAL_ORGAN_BRAIN])
		var/obj/item/organ/internal/brain/sponge = get_int_organ(/obj/item/organ/internal/brain)
		if(sponge)
			if(dna.species && amount > 0)
				if(use_brain_mod)
					amount = amount * (dna.species.brain_mod + get_vampire_bonus(BRAIN))
			sponge.damage = clamp(amount, 0, 120)
			if(sponge.damage >= 120 && stat != DEAD)
				visible_message("<span class='alert'><B>[src]</B> goes limp, [p_their()] facial expression utterly blank.</span>")
				death()
	if(updating_health)
		update_stat("setBrainLoss")
	return STATUS_UPDATE_STAT

/mob/living/carbon/human/getBrainLoss()
	if(status_flags & GODMODE)
		return 0	//godmode

	if(dna.species && dna.species.has_organ[INTERNAL_ORGAN_BRAIN])
		var/obj/item/organ/internal/brain/sponge = get_int_organ(/obj/item/organ/internal/brain)
		if(sponge)
			return min(sponge.damage,maxHealth*2)
		else
			if(ischangeling(src))
				// if a changeling has no brain, they have no brain damage.
				return 0

			return 200
	else
		return 0


/mob/living/carbon/human/adjustHeartLoss(amount, updating_health = TRUE)
	if(status_flags & GODMODE)
		return STATUS_UPDATE_NONE	//godmode

	if(dna.species && dna.species.has_organ[INTERNAL_ORGAN_HEART])
		var/obj/item/organ/internal/heart/hearty = get_int_organ(/obj/item/organ/internal/heart)
		if(hearty)
			hearty.damage = clamp(hearty.damage + amount, 0, 60)
	if(updating_health)
		update_stat("adjustHeartLoss")
	return STATUS_UPDATE_STAT

/mob/living/carbon/human/setHeartLoss(amount, updating_health = TRUE)
	if(status_flags & GODMODE)
		return STATUS_UPDATE_NONE	//godmode

	if(dna.species && dna.species.has_organ[INTERNAL_ORGAN_HEART])
		var/obj/item/organ/internal/heart/hearty = get_int_organ(/obj/item/organ/internal/heart)
		if(hearty)
			hearty.damage = clamp(amount, 0, 60)
	if(updating_health)
		update_stat("setHeartLoss")
	return STATUS_UPDATE_STAT

/mob/living/carbon/human/getHeartLoss()
	if(status_flags & GODMODE)
		return 0	//godmode

	if(dna.species && dna.species.has_organ[INTERNAL_ORGAN_HEART])
		var/obj/item/organ/internal/heart/hearty = get_int_organ(/obj/item/organ/internal/heart)
		if(hearty)
			return min(hearty.damage,maxHealth*2)
		else
			return 200
	else
		return 0

/mob/living/carbon/human/proc/check_brain_for_complex_interactions()
	if(getBrainLoss() >= 60 || prob(getBrainLoss()))
		return FALSE
	var/datum/disease/virus/advance/A = locate(/datum/disease/virus/advance) in diseases
	if(istype(A))
		var/datum/symptom/headache/S = locate(/datum/symptom/headache) in A.symptoms
		if(istype(S))
			return FALSE
	return TRUE

//These procs fetch a cumulative total damage from all organs
/mob/living/carbon/human/getBruteLoss()
	if(status_flags & GODMODE)
		return 0
	var/amount = 0
	for(var/obj/item/organ/external/O as anything in bodyparts)
		amount += O.brute_dam
	return amount

/mob/living/carbon/human/getFireLoss()
	if(status_flags & GODMODE)
		return 0
	var/amount = 0
	for(var/obj/item/organ/external/O as anything in bodyparts)
		amount += O.burn_dam
	return amount

/mob/living/carbon/human/adjustBruteLoss(amount, updating_health = TRUE, damage_source = null, robotic = FALSE)
	if(amount > 0)
		if(dna.species)
			amount = amount * (dna.species.brute_mod + get_vampire_bonus(BRUTE))
		take_overall_damage(amount, 0, updating_health, used_weapon = damage_source)
	else
		heal_overall_damage(-amount, 0, updating_health, FALSE, robotic)
	// brainless default for now
	return STATUS_UPDATE_HEALTH

/mob/living/carbon/human/adjustFireLoss(amount, updating_health = TRUE, damage_source = null, robotic = FALSE)
	if(amount > 0)
		if(dna.species)
			amount = amount * (dna.species.burn_mod + get_vampire_bonus(BURN))
		take_overall_damage(0, amount, updating_health, used_weapon = damage_source)
	else
		heal_overall_damage(0, -amount, updating_health, FALSE, robotic)
	// brainless default for now
	return STATUS_UPDATE_HEALTH

/mob/living/carbon/human/proc/adjustBruteLossByPart(amount, organ_name, obj/damage_source = null, updating_health = TRUE)
	if(dna.species && amount > 0)
		amount = amount * (dna.species.brute_mod + get_vampire_bonus(BRUTE))
	if(organ_name in bodyparts_by_name)
		var/obj/item/organ/external/O = get_organ(organ_name)

		if(amount > 0)
			O.receive_damage(amount, 0, sharp=is_sharp(damage_source), used_weapon=damage_source, forbidden_limbs = list(), ignore_resists=FALSE, updating_health=updating_health)
		else
			//if you don't want to heal robot organs, they you will have to check that yourself before using this proc.
			O.heal_damage(-amount, 0, internal = FALSE, robo_repair = O.is_robotic(), updating_health = updating_health)
	return STATUS_UPDATE_HEALTH

/mob/living/carbon/human/proc/adjustFireLossByPart(amount, organ_name, obj/damage_source = null, updating_health = TRUE)
	if(dna.species && amount > 0)
		amount = amount * (dna.species.burn_mod + get_vampire_bonus(BURN))

	if(organ_name in bodyparts_by_name)
		var/obj/item/organ/external/O = get_organ(organ_name)

		if(amount > 0)
			O.receive_damage(0, amount, sharp=is_sharp(damage_source), used_weapon=damage_source, forbidden_limbs = list(), ignore_resists = FALSE, updating_health = updating_health)
		else
			//if you don't want to heal robot organs, they you will have to check that yourself before using this proc.
			O.heal_damage(0, -amount, internal = FALSE, robo_repair = O.is_robotic(), updating_health = updating_health)
	return STATUS_UPDATE_HEALTH

/mob/living/carbon/human/setCloneLoss(amount, updating_health)
	. = ..()
	if(getCloneLoss() < 1) //assuming cloneloss was set to 0
		for(var/obj/item/organ/external/bodypart as anything in bodyparts)
			bodypart.unmutate()

/mob/living/carbon/human/adjustCloneLoss(amount, updating_health)
	if(dna.species && amount > 0)
		amount = amount * (dna.species.clone_mod + get_vampire_bonus(CLONE))
	. = ..()

	var/heal_prob = max(0, 80 - getCloneLoss())
	var/mut_prob = min(80, getCloneLoss() + 10)
	if(amount > 0) //cloneloss is being added
		if(prob(mut_prob))
			var/list/obj/item/organ/external/candidates = list() //TYPECASTED LISTS ARE NOT A FUCKING THING WHAT THE FUCK
			for(var/obj/item/organ/external/bodypart as anything in bodyparts)
				if(bodypart.is_robotic())
					continue
				if(!bodypart.is_mutated())
					candidates += bodypart

			var/obj/item/organ/external/chosen_bodypart = safepick(candidates)
			if(chosen_bodypart)
				chosen_bodypart.mutate()
				chosen_bodypart.add_autopsy_data("Mutation", amount)
				return

	else //cloneloss is being subtracted
		if(prob(heal_prob))
			for(var/obj/item/organ/external/bodypart as anything in bodyparts)
				if(bodypart.unmutate())
					return


	if(getCloneLoss() < 1) //no cloneloss, fixes organs
		for(var/obj/item/organ/external/bodypart as anything in bodyparts)
			bodypart.unmutate()


// Defined here solely to take species flags into account without having to recast at mob/living level.
/mob/living/carbon/human/adjustOxyLoss(amount, updating_health)
	if(NO_BREATHE in dna.species.species_traits)
		oxyloss = 0
		return FALSE
	if(dna.species && amount > 0)
		amount = amount * (dna.species.oxy_mod + get_vampire_bonus(OXY))
	. = ..()

/mob/living/carbon/human/setOxyLoss(amount, updating_health)
	if(NO_BREATHE in dna.species.species_traits)
		oxyloss = 0
		return FALSE
	if(dna.species && amount > 0)
		amount = amount * (dna.species.oxy_mod + get_vampire_bonus(OXY))
	. = ..()

/mob/living/carbon/human/adjustToxLoss(amount, updating_health)
	if(dna.species && amount > 0)
		amount = amount * (dna.species.tox_mod + get_vampire_bonus(TOX))
	. = ..()

	if(amount > 0 && mind)
		for(var/datum/objective/pain_hunter/objective in GLOB.all_objectives)
			if (mind == objective.target)
				objective.take_damage(amount, TOX)

/mob/living/carbon/human/setToxLoss(amount, updating_health)
	if(dna.species && amount > 0)
		amount = amount * (dna.species.tox_mod + get_vampire_bonus(TOX))
	. = ..()

/mob/living/carbon/human/adjustStaminaLoss(amount, updating_health)
	if(dna.species && amount > 0)
		amount = amount * (dna.species.stamina_mod + get_vampire_bonus(STAMINA))
	. = ..()

/mob/living/carbon/human/setStaminaLoss(amount, updating_health)
	if(dna.species && amount > 0)
		amount = amount * (dna.species.stamina_mod + get_vampire_bonus(STAMINA))
	. = ..()

////////////////////////////////////////////

//Returns a list of damaged organs
/mob/living/carbon/human/proc/get_damaged_organs(brute, burn, flags = AFFECT_ALL_ORGANS)
	var/list/obj/item/organ/external/parts = list()
	for(var/obj/item/organ/external/bodypart as anything in bodyparts)
		if((brute && bodypart.brute_dam) || (burn && bodypart.burn_dam))
			if(!(flags & AFFECT_ROBOTIC_ORGAN) && bodypart.is_robotic())
				continue
			if(!(flags & AFFECT_ORGANIC_ORGAN) && !bodypart.is_robotic())
				continue
			parts += bodypart
	return parts

//Returns a list of damageable organs
/mob/living/carbon/human/proc/get_damageable_organs(affect_robotic = TRUE)
	var/list/obj/item/organ/external/parts = list()
	for(var/obj/item/organ/external/bodypart as anything in bodyparts)
		if(!affect_robotic && bodypart.is_robotic())
			continue
		if(bodypart.brute_dam + bodypart.burn_dam < bodypart.max_damage)
			parts += bodypart
	return parts

//Heals ONE external organ, organ gets randomly selected from damaged ones.
//It automatically updates damage overlays if necesary
//It automatically updates health status
/mob/living/carbon/human/heal_organ_damage(brute, burn, updating_health = TRUE)
	var/obj/item/organ/external/picked = safepick(get_damaged_organs(brute, burn))
	if(picked?.heal_damage(brute, burn, updating_health = updating_health))
		UpdateDamageIcon()

//Damages ONE external organ, organ gets randomly selected from damagable ones.
//It automatically updates damage overlays if necesary
//It automatically updates health status
/mob/living/carbon/human/take_organ_damage(brute, burn, updating_health = TRUE, sharp = 0, edge = 0)
	if(status_flags & GODMODE)
		return ..()
	var/list/obj/item/organ/external/parts = get_damageable_organs()
	if(!parts.len)
		return
	var/obj/item/organ/external/picked = pick(parts)
	if(picked.receive_damage(brute, burn, sharp, updating_health))
		UpdateDamageIcon()


//Heal MANY external organs, in random order
/mob/living/carbon/human/heal_overall_damage(brute, burn, updating_health = TRUE, internal = FALSE, robotic = FALSE)
	var/list/obj/item/organ/external/parts = get_damaged_organs(brute,burn)

	var/update = 0
	while(length(parts) && (brute > 0 || burn > 0))
		var/obj/item/organ/external/picked = pick(parts)

		var/brute_was = picked.brute_dam
		var/burn_was = picked.burn_dam

		update |= picked.heal_damage(brute,burn, internal, robotic, updating_health = FALSE)

		brute -= (brute_was-picked.brute_dam)
		burn -= (burn_was-picked.burn_dam)

		parts -= picked

	if(updating_health)
		updatehealth("heal overall damage")

	if(update)
		UpdateDamageIcon()


// damage MANY external organs, in random order
/mob/living/carbon/human/take_overall_damage(brute, burn, updating_health = TRUE, used_weapon = null, sharp = 0, edge = 0, affect_robotic = 1)
	if(status_flags & GODMODE)
		return ..()	//godmode
	var/list/obj/item/organ/external/parts = get_damageable_organs(affect_robotic)

	var/update = 0
	while(parts.len && (brute>0 || burn>0) )
		var/obj/item/organ/external/picked = pick(parts)
		var/brute_per_part = brute/parts.len
		var/burn_per_part = burn/parts.len

		var/brute_was = picked.brute_dam
		var/burn_was = picked.burn_dam


		update |= picked.receive_damage(brute_per_part, burn_per_part, sharp, used_weapon, list(), FALSE, FALSE)

		brute	-= (picked.brute_dam - brute_was)
		burn	-= (picked.burn_dam - burn_was)

		parts -= picked

	if(updating_health)
		updatehealth("take overall damage")

	if(update)
		UpdateDamageIcon()


////////////////////////////////////////////

/*
This function restores all organs.
*/
/mob/living/carbon/human/restore_all_organs()
	for(var/obj/item/organ/external/current_organ as anything in bodyparts)
		current_organ.rejuvenate()

/mob/living/carbon/human/proc/HealDamage(zone, brute, burn)
	var/obj/item/organ/external/E = get_organ(zone)
	if(istype(E, /obj/item/organ/external))
		if(E.heal_damage(brute, burn))
			UpdateDamageIcon()
	else
		return 0


/mob/living/carbon/human/get_organ(zone)
	if(!zone)
		zone = BODY_ZONE_CHEST
	if(zone in list(BODY_ZONE_PRECISE_EYES, BODY_ZONE_PRECISE_MOUTH))
		zone = BODY_ZONE_HEAD
	return bodyparts_by_name[zone]


/mob/living/carbon/human/apply_damage(damage = 0, damagetype = BRUTE, def_zone = null, blocked = 0, sharp = 0, obj/used_weapon = null)
	SEND_SIGNAL(src, COMSIG_MOB_APPLY_DAMAGE, damage, damagetype, def_zone)
	//Handle other types of damage
	if((damagetype != BRUTE) && (damagetype != BURN))
		..(damage, damagetype, def_zone, blocked)
		return 1

	//Handle species apply_damage procs
	return dna.species.apply_damage(damage, damagetype, def_zone, blocked, src, sharp, used_weapon)
