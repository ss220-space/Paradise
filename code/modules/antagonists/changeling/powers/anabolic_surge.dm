/datum/action/changeling/anabolic_surge
	name = "Анаболический всплеск"
	desc = "Значительно увеличивает силу пользователя, за счёт уменьшения выработки химикатов на 50%."
	helptext = "Увеличивает силу до сверхчеловеческого уровня."
	button_icon_state = "anabolic_surge"
	power_type = CHANGELING_PURCHASABLE_POWER
	dna_cost = 1
	var/chemical_synthesis_modifier = -0.5
	/// Maintain the original level of strength
	var/datum/strength_level/backup_strength_level
	/// We save the original strength points
	var/backup_strength_points = 0

/datum/action/changeling/anabolic_surge/Remove(mob/user)
	if(active)
		deactivate(user)
	return ..()

/datum/action/changeling/anabolic_surge/sting_action(mob/living/user)
	if(!iscarbon(user))
		return FALSE

	if(active)
		deactivate(user)
		user.balloon_alert(user, "сила уменьшеается")
	else
		activate(user)
		user.balloon_alert(user, "сила нарастает")

	SSblackbox.record_feedback("nested tally", "changeling_powers", 1, list("[name]", "[active]"))
	return TRUE

/datum/action/changeling/anabolic_surge/proc/activate(mob/living/carbon/user)
	if(!ishuman(user))
		to_chat(user, span_warning("Эта способность работает только в человеческой форме!"))
		return FALSE

	var/mob/living/carbon/human/human = user

	var/datum/component/muscles/muscles = human.GetComponent(/datum/component/muscles)
	if(!muscles)
		muscles = human.AddComponent(/datum/component/muscles)
		if(!muscles)
			to_chat(user, span_warning("Не удалось активировать!"))
			return FALSE

	// Save the current power level and points
	backup_strength_level = muscles.real_strength_level
	backup_strength_points = muscles.strength_points
	ADD_TRAIT(human, TRAIT_STRONG_MUSCLES, CHANGELING_TRAIT)

	muscles.real_strength_level = new STRENGTH_LEVEL_SUPERHUMAN()
	muscles.strength_points = 0

	// Update the appearance
	human.update_body(TRUE)

// Apply the chemical synthesis modifier
	var/datum/antagonist/changeling/changeling = human.mind?.has_antag_datum(/datum/antagonist/changeling)
	if(changeling)
		changeling.add_chem_rate_modifier(src, chemical_synthesis_modifier)


	active = TRUE
	button_icon_state = "anabolic_surge_active"
	UpdateButtonIcon()

	return TRUE

/datum/action/changeling/anabolic_surge/proc/deactivate(mob/living/carbon/user)
	var/datum/antagonist/changeling/changeling = user.mind?.has_antag_datum(/datum/antagonist/changeling)
	if(changeling)
		changeling.remove_chem_rate_modifier(src)

	if(ishuman(user))
		var/mob/living/carbon/human/human = user
		REMOVE_TRAIT(human, TRAIT_STRONG_MUSCLES, CHANGELING_TRAIT)

		var/datum/component/muscles/muscles = human.GetComponent(/datum/component/muscles)
		if(muscles)
			if(backup_strength_level)
				muscles.real_strength_level = backup_strength_level
				muscles.strength_points = backup_strength_points
			else
				muscles.real_strength_level = new STRENGTH_LEVEL_DEFAULT()
				muscles.strength_points = 0
			human.update_body(TRUE)

	active = FALSE
	button_icon_state = "anabolic_surge"
	UpdateButtonIcon()
	return TRUE
