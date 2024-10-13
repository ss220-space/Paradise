//Updates the mob's health from organs and mob damage variables
/mob/living/carbon/human/updatehealth(reason = "none given", should_log = FALSE)
	if(HAS_TRAIT(src, TRAIT_GODMODE))
		return ..()

	var/total_burn  = 0
	var/total_brute = 0

	for(var/obj/item/organ/external/bodypart as anything in bodyparts)	//hardcoded to streamline things a bit
		total_brute += bodypart.brute_dam //calculates health based on organ brute and burn
		total_burn += bodypart.burn_dam

	set_health(round(maxHealth - getOxyLoss() - getToxLoss() - getCloneLoss() - total_burn - total_brute, DAMAGE_PRECISION))
	update_stat("updatehealth([reason])", should_log)
	update_stamina()

	if(((maxHealth - total_burn) < HEALTH_THRESHOLD_DEAD) && stat == DEAD)
		ChangeToHusk()


/mob/living/carbon/human/update_stamina()
	. = ..()
	update_movespeed_damage_modifiers()


/mob/living/carbon/human/update_movespeed_damage_modifiers()
	if(HAS_TRAIT(src, TRAIT_IGNOREDAMAGESLOWDOWN))
		remove_movespeed_modifier(/datum/movespeed_modifier/damage_slowdown)
		remove_movespeed_modifier(/datum/movespeed_modifier/damage_slowdown_flying)
		return

	var/health_deficiency = max((maxHealth - health), staminaloss) - shock_reduction()
	if(health_deficiency >= 40)
		add_or_update_variable_movespeed_modifier(/datum/movespeed_modifier/damage_slowdown, multiplicative_slowdown = health_deficiency / 75)
		add_or_update_variable_movespeed_modifier(/datum/movespeed_modifier/damage_slowdown_flying, multiplicative_slowdown = health_deficiency / 25)
	else
		remove_movespeed_modifier(/datum/movespeed_modifier/damage_slowdown)
		remove_movespeed_modifier(/datum/movespeed_modifier/damage_slowdown_flying)


/mob/living/carbon/human/adjustBrainLoss(
	amount = 0,
	updating_health = TRUE,
	blocked = 0,
	forced = FALSE,
	used_weapon = null,
)
	if(HAS_TRAIT(src, TRAIT_GODMODE))
		return STATUS_UPDATE_NONE

	if(!forced && amount > 0)
		amount *= ((100 - clamp(blocked + get_blocking_resistance(amount, BRAIN, used_weapon = used_weapon), 0, 100)) / 100)
		amount *= get_incoming_damage_modifier(amount, BRAIN, used_weapon = used_weapon)
		if(amount <= 0)
			return STATUS_UPDATE_NONE

	if(dna.species.has_organ[INTERNAL_ORGAN_BRAIN])
		var/obj/item/organ/internal/brain/sponge = get_int_organ(/obj/item/organ/internal/brain)
		if(sponge)
			sponge.damage = clamp(round(sponge.damage + amount, DAMAGE_PRECISION), 0, 120)
			if(sponge.damage >= 120 && stat != DEAD)
				visible_message(span_alert("<B>[src]</B> goes limp, [p_their()] facial expression utterly blank."))
				death()
	if(updating_health)
		update_stat("adjustBrainLoss")
	return STATUS_UPDATE_STAT


/mob/living/carbon/human/setBrainLoss(amount, updating_health = TRUE)
	if(HAS_TRAIT(src, TRAIT_GODMODE))
		return STATUS_UPDATE_NONE

	if(dna.species.has_organ[INTERNAL_ORGAN_BRAIN])
		var/obj/item/organ/internal/brain/sponge = get_int_organ(/obj/item/organ/internal/brain)
		if(sponge)
			sponge.damage = clamp(round(amount, DAMAGE_PRECISION), 0, 120)
			if(sponge.damage >= 120 && stat != DEAD)
				visible_message(span_alert("<B>[src]</B> goes limp, [p_their()] facial expression utterly blank."))
				death()
	if(updating_health)
		update_stat("setBrainLoss")
	return STATUS_UPDATE_STAT


/mob/living/carbon/human/getBrainLoss()
	. = 0
	if(HAS_TRAIT(src, TRAIT_GODMODE))
		return .

	if(!dna.species.has_organ[INTERNAL_ORGAN_BRAIN])
		return .

	var/obj/item/organ/internal/brain/sponge = get_int_organ(/obj/item/organ/internal/brain)
	if(sponge)
		return min(sponge.damage, maxHealth * 2)

	if(ischangeling(src))
		// if a changeling has no brain, they have no brain damage.
		return 0

	return 200


/mob/living/carbon/human/adjustHeartLoss(amount, updating_health = TRUE)
	if(HAS_TRAIT(src, TRAIT_GODMODE))
		return STATUS_UPDATE_NONE

	if(dna.species.has_organ[INTERNAL_ORGAN_HEART])
		var/obj/item/organ/internal/heart/hearty = get_int_organ(/obj/item/organ/internal/heart)
		if(hearty)
			hearty.internal_receive_damage(amount)
	if(updating_health)
		update_stat("adjustHeartLoss")
	return STATUS_UPDATE_STAT


/mob/living/carbon/human/setHeartLoss(amount, updating_health = TRUE)
	if(HAS_TRAIT(src, TRAIT_GODMODE))
		return STATUS_UPDATE_NONE	//godmode

	if(dna.species.has_organ[INTERNAL_ORGAN_HEART])
		var/obj/item/organ/internal/heart/hearty = get_int_organ(/obj/item/organ/internal/heart)
		if(hearty)
			hearty.damage = clamp(round(amount, DAMAGE_PRECISION), 0, hearty.max_damage)
			if(hearty.damage >= hearty.max_damage)
				hearty.necrotize()
			else if(hearty.damage == 0)
				hearty.unnecrotize()
	if(updating_health)
		update_stat("setHeartLoss")
	return STATUS_UPDATE_STAT


/mob/living/carbon/human/getHeartLoss()
	. = 0
	if(HAS_TRAIT(src, TRAIT_GODMODE))
		return .

	if(!dna.species.has_organ[INTERNAL_ORGAN_HEART])
		return .

	var/obj/item/organ/internal/heart/hearty = get_int_organ(/obj/item/organ/internal/heart)
	if(hearty)
		return min(hearty.damage, maxHealth * 2)

	return 200


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
	. = 0
	if(HAS_TRAIT(src, TRAIT_GODMODE))
		return .
	for(var/obj/item/organ/external/bodypart as anything in bodyparts)
		. += bodypart.brute_dam


/mob/living/carbon/human/getFireLoss()
	. = 0
	if(HAS_TRAIT(src, TRAIT_GODMODE))
		return .
	for(var/obj/item/organ/external/bodypart as anything in bodyparts)
		. += bodypart.burn_dam


/mob/living/carbon/human/adjustBruteLoss(
	amount = 0,
	updating_health = TRUE,
	def_zone = null,
	blocked = 0,
	forced = FALSE,
	used_weapon = null,
	sharp = FALSE,
	silent = FALSE,
	affect_robotic = TRUE,
)
	. = STATUS_UPDATE_NONE
	if(amount > 0)
		. |= take_overall_damage(amount, 0, blocked, forced, updating_health, used_weapon, sharp, silent, affect_robotic)
	else
		. |= heal_overall_damage(amount, 0, updating_health, FALSE, affect_robotic)


/mob/living/carbon/human/adjustFireLoss(
	amount = 0,
	updating_health = TRUE,
	def_zone = null,
	blocked = 0,
	forced = FALSE,
	used_weapon = null,
	sharp = FALSE,
	silent = FALSE,
	affect_robotic = TRUE,
)
	. = STATUS_UPDATE_NONE
	if(amount > 0)
		. |= take_overall_damage(0, amount, blocked, forced, updating_health, used_weapon, sharp, silent, affect_robotic)
	else
		. |= heal_overall_damage(0, amount, updating_health, FALSE, affect_robotic)


/mob/living/carbon/human/setCloneLoss(amount, updating_health = TRUE)
	. = ..()
	if(!. || getCloneLoss() > 1)	//assuming cloneloss was set to 0
		return .
	for(var/obj/item/organ/external/bodypart as anything in bodyparts)
		bodypart.unmutate()


/mob/living/carbon/human/adjustCloneLoss(
	amount = 0,
	updating_health = TRUE,
	blocked = 0,
	forced = FALSE,
	used_weapon = null,
)
	. = ..()
	if(!.)
		return .

	var/new_cloneloss = getCloneLoss()
	if(new_cloneloss < 1)	//no cloneloss, fixes organs
		for(var/obj/item/organ/external/bodypart as anything in bodyparts)
			bodypart.unmutate()
		return .

	if(amount > 0) //cloneloss is being added
		if(prob(min(80, new_cloneloss + 10)))
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
		return .

	//cloneloss is being subtracted
	if(prob(max(0, 80 - new_cloneloss)))
		for(var/obj/item/organ/external/bodypart as anything in bodyparts)
			if(bodypart.unmutate())
				break


/mob/living/carbon/human/adjustOxyLoss(
	amount = 0,
	updating_health = TRUE,
	blocked = 0,
	forced = FALSE,
	used_weapon = null,
)
	if(HAS_TRAIT(src, TRAIT_NO_BREATH))
		var/old_oxyloss = getOxyLoss()
		oxyloss = 0
		if(old_oxyloss != 0)
			updatehealth("adjustOxyLoss")
		return STATUS_UPDATE_NONE
	return ..()


/mob/living/carbon/human/setOxyLoss(amount = 0, updating_health = TRUE)
	if(HAS_TRAIT(src, TRAIT_NO_BREATH))
		var/old_oxyloss = getOxyLoss()
		oxyloss = 0
		if(old_oxyloss != 0)
			updatehealth("setOxyLoss")
		return STATUS_UPDATE_NONE
	return ..()


/mob/living/carbon/human/adjustToxLoss(
	amount = 0,
	updating_health = TRUE,
	blocked = 0,
	forced = FALSE,
	used_weapon = null,
)
	. = ..()
	if(. == STATUS_UPDATE_NONE)
		return .

	if(TOX_VOMIT_THRESHOLD_REACHED(src, TOX_VOMIT_REQUIRED_TOXLOSS))
		apply_status_effect(STATUS_EFFECT_VOMIT)

	if(!mind)
		return . 

	for(var/datum/objective/pain_hunter/objective in GLOB.all_objectives)
		if(mind == objective.target)
			objective.take_damage(amount, TOX)

	return .

/mob/living/carbon/human/setToxLoss(amount, updating_health = TRUE)
	. = ..()
	if(. == STATUS_UPDATE_NONE)
		return .

	if(TOX_VOMIT_THRESHOLD_REACHED(src, TOX_VOMIT_REQUIRED_TOXLOSS))
		apply_status_effect(STATUS_EFFECT_VOMIT)

	return .

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


/mob/living/carbon/human/heal_organ_damage(
	brute = 0,
	burn = 0,
	updating_health = TRUE,
	internal = FALSE,
	affect_robotic = FALSE,
)
	. = STATUS_UPDATE_NONE
	var/obj/item/organ/external/picked = safepick(get_damaged_organs(brute, burn, flags = affect_robotic ? AFFECT_ALL_ORGANS : AFFECT_ORGANIC_ORGAN))
	if(!picked)
		return .
	var/brute_was = picked.brute_dam
	var/burn_was = picked.burn_dam
	if(picked.heal_damage(brute, burn, internal, affect_robotic, updating_health = FALSE))
		UpdateDamageIcon()
	if(picked.brute_dam != brute_was || picked.burn_dam != burn_was)
		. |= STATUS_UPDATE_HEALTH
		if(updating_health)
			updatehealth("heal organ damage")


/mob/living/carbon/human/take_organ_damage(
	brute = 0,
	burn = 0,
	blocked = 0,
	forced = FALSE,
	updating_health = TRUE,
	used_weapon = null,
	sharp = FALSE,
	silent = FALSE,
	affect_robotic = TRUE,
)
	if(HAS_TRAIT(src, TRAIT_GODMODE))
		return ..()
	. = STATUS_UPDATE_NONE
	var/obj/item/organ/external/picked = safepick(get_damageable_organs(affect_robotic))
	if(!picked)
		return .
	var/brute_was = picked.brute_dam
	var/burn_was = picked.burn_dam
	if(picked.external_receive_damage(brute, burn, blocked, sharp, used_weapon, forced = forced, updating_health = FALSE, silent = silent))
		UpdateDamageIcon()
	if(QDELETED(picked) || picked.loc != src || picked.brute_dam != brute_was || picked.burn_dam != burn_was)
		. |= STATUS_UPDATE_HEALTH
		if(updating_health)
			updatehealth("take organ damage")


/mob/living/carbon/human/heal_overall_damage(
	brute = 0,
	burn = 0,
	updating_health = TRUE,
	internal = FALSE,
	affect_robotic = FALSE,
)
	. = STATUS_UPDATE_NONE

	// treat negative args as positive
	brute = abs(brute)
	burn = abs(burn)

	var/list/obj/item/organ/external/parts = get_damaged_organs(brute, burn, flags = affect_robotic ? AFFECT_ALL_ORGANS : AFFECT_ORGANIC_ORGAN)

	var/should_update_health = FALSE
	var/update_damage_icon = NONE
	while(parts.len && (brute > 0 || burn > 0))
		var/obj/item/organ/external/picked = pick(parts)
		var/brute_per_part = round(brute/parts.len, DAMAGE_PRECISION)
		var/burn_per_part = round(burn/parts.len, DAMAGE_PRECISION)

		var/brute_was = picked.brute_dam
		var/burn_was = picked.burn_dam

		update_damage_icon |= picked.heal_damage(brute_per_part, burn_per_part, internal, affect_robotic, updating_health = FALSE)

		if(picked.brute_dam != brute_was || picked.burn_dam != burn_was)
			should_update_health = TRUE

		brute = max(brute - brute_per_part, 0)
		burn = max(burn - burn_per_part, 0)

		parts -= picked

	if(should_update_health)
		. |= STATUS_UPDATE_HEALTH
		if(updating_health)
			updatehealth("heal overall damage")

	if(update_damage_icon)
		UpdateDamageIcon()


/mob/living/carbon/human/take_overall_damage(
	brute = 0,
	burn = 0,
	blocked = 0,
	forced = FALSE,
	updating_health = TRUE,
	used_weapon = null,
	sharp = FALSE,
	silent = FALSE,
	affect_robotic = TRUE,
)
	if(HAS_TRAIT(src, TRAIT_GODMODE))
		return ..()	//godmode

	. = STATUS_UPDATE_NONE

	var/list/obj/item/organ/external/parts = get_damageable_organs(affect_robotic)
	if(!length(parts))
		return .

	// treat negative args as positive
	brute = abs(brute)
	burn = abs(burn)

	var/should_update_health = FALSE
	var/update_damage_icon = NONE
	while(parts.len && (brute > 0 || burn > 0))
		var/obj/item/organ/external/picked = pick(parts)
		var/brute_per_part = round(brute/parts.len, DAMAGE_PRECISION)
		var/burn_per_part = round(burn/parts.len, DAMAGE_PRECISION)

		var/brute_was = picked.brute_dam
		var/burn_was = picked.burn_dam

		update_damage_icon |= picked.external_receive_damage(brute_per_part, burn_per_part, blocked, sharp, used_weapon, forced = forced, updating_health = FALSE, silent = silent)

		if(QDELETED(picked) || picked.loc != src || picked.brute_dam != brute_was || picked.burn_dam != burn_was)
			should_update_health = TRUE

		brute = max(brute - brute_per_part, 0)
		burn = max(burn - burn_per_part, 0)

		parts -= picked

	if(should_update_health)
		. |= STATUS_UPDATE_HEALTH
		if(updating_health)
			updatehealth("take overall damage")

	if(update_damage_icon)
		UpdateDamageIcon()


////////////////////////////////////////////

/*
This function restores all organs.
*/
/mob/living/carbon/human/restore_all_organs()
	for(var/obj/item/organ/external/current_organ as anything in bodyparts)
		current_organ.rejuvenate()


/mob/living/carbon/human/get_organ(zone)
	if(!zone)
		zone = BODY_ZONE_CHEST
	if(zone in list(BODY_ZONE_PRECISE_EYES, BODY_ZONE_PRECISE_MOUTH))
		zone = BODY_ZONE_HEAD
	return bodyparts_by_name[zone]


/mob/living/carbon/human/apply_damage(
	damage = 0,
	damagetype = BRUTE,
	def_zone = null,
	blocked = 0,
	sharp = FALSE,
	used_weapon = null,
	spread_damage = FALSE,
	forced = FALSE,
	silent = FALSE,
	updating_health = TRUE,
	update_damage_icon = TRUE,
)
	// Spread damage should always have def zone be null
	if(spread_damage)
		def_zone = null

	// Otherwise if def zone is null, we'll get a random bodypart / zone to hit.
	// ALso we'll automatically covnert string def zones into bodyparts to pass into parent call.
	else if(!isexternalorgan(def_zone))
		var/random_zone = def_zone || ran_zone(def_zone)
		def_zone = get_organ(random_zone) || get_organ(BODY_ZONE_CHEST)
		if(!def_zone)
			CRASH("Human somehow has no chest bodypart.")

	. = ..()

	// Taking brute or burn to bodyparts gives a damage flash
	if(. && def_zone && (damagetype == BRUTE || damagetype == BURN))
		damageoverlaytemp = 20


/mob/living/carbon/human/apply_damages(
	brute = 0,
	burn = 0,
	tox = 0,
	oxy = 0,
	clone = 0,
	stamina = 0,
	brain = 0,
	def_zone = null,
	blocked = 0,
	sharp = FALSE,
	used_weapon = null,
	spread_damage = FALSE,
	forced = FALSE,
	silent = FALSE,
	updating_health = TRUE,
)
	if(spread_damage)
		def_zone = null

	else if(!isexternalorgan(def_zone))
		var/random_zone = def_zone || ran_zone(def_zone)
		def_zone = get_organ(random_zone) || get_organ(BODY_ZONE_CHEST)
		if(!def_zone)
			CRASH("Human somehow has no chest bodypart.")

	return ..()


/mob/living/carbon/human/get_blocking_resistance(
	damage = 0,
	damagetype = BRUTE,
	def_zone = null,
	sharp = FALSE,
	used_weapon = null,
)
	. = ..()
	// Add relevant DR modifiers into blocked value
	. += physiology.damage_resistance
	. += dna.species.damage_resistance


/mob/living/carbon/human/get_incoming_damage_modifier(
	damage = 0,
	damagetype = BRUTE,
	def_zone = null,
	sharp = FALSE,
	used_weapon = null,
)
	. = ..()

	switch(damagetype)
		if(BRUTE)
			. = . * dna.species.brute_mod * physiology.brute_mod
		if(BURN)
			. = . * dna.species.burn_mod * physiology.burn_mod
		if(TOX)
			. = . * dna.species.tox_mod * physiology.tox_mod
		if(OXY)
			. = . * dna.species.oxy_mod * physiology.oxy_mod
		if(CLONE)
			. = . * dna.species.clone_mod * physiology.clone_mod
		if(STAMINA)
			. = . * dna.species.stamina_mod * physiology.stamina_mod
		if(BRAIN)
			. = . * dna.species.brain_mod * physiology.brain_mod

