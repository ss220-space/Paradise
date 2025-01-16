/datum/antagonist/sintouched
	name = "Sintouched"
	special_role = SPECIAL_ROLE_SINTOUCHED

/datum/antagonist/sintouched/can_be_owned(datum/mind/new_owner)
	. = ..()
	if(!.)
		return FALSE

	var/datum/mind/tested = new_owner || owner
    
	if(!tested || !ishuman(tested.current))
		return FALSE

	return TRUE

/datum/antagonist/sintouched/give_objectives()
	var/list/sins = list()

	for(var/datum/objective/sintouched/sin as anything in subtypesof(/datum/objective/sintouched))
		if(!sin.explanation_text)
			continue
			
		LAZYADD(sins, sin)

	add_objective(pick(sins))

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
