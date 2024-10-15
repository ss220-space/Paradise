/datum/antagonist/sintouched
	name = "Sintouched"

/datum/antagonist/sintouched/can_be_owned(datum/mind/new_owner)
	. = ..()
	if(!.)
		return FALSE

	var/datum/mind/tested = new_owner || owner
    
	if(!tested || !ishuman(tested.current))
		return FALSE

	return TRUE

/datum/antagonist/sintouched/give_objectives()
	switch(rand(1, 7)) // traditional seven deadly sins... except lust.
		if(1) // acedia
			add_objective(/datum/objective/sintouched/acedia)
		if(2) // Gluttony
			add_objective(/datum/objective/sintouched/gluttony)
		if(3) // Greed
			add_objective(/datum/objective/sintouched/greed)
		if(4) // sloth
			add_objective(/datum/objective/sintouched/sloth)
		if(5) // Wrath
			add_objective(/datum/objective/sintouched/wrath)
		if(6) // Envy
			add_objective(/datum/objective/sintouched/envy)
		if(7) // Pride
			add_objective(/datum/objective/sintouched/pride)

/datum/antagonist/sintouched/add_owner_to_gamemode()
	LAZYADD(SSticker.mode.sintouched, owner)

/datum/antagonist/sintouched/remove_owner_from_gamemode()
	LAZYREMOVE(SSticker.mode.sintouched, owner)

/datum/antagonist/sintouched/apply_innate_effects(mob/living/mob_override)
	. = ..()

	var/mob/living/carbon/human/human = mob_override || owner.current

	for(var/datum/objective/sintouched/sin_objective in owner.objectives)
		sin_objective.init_sin(human)
    
/datum/antagonist/sintouched/on_body_transfer(mob/living/old_body, mob/living/new_body)
    return // No.
