/datum/antagonist/space_carp
	name = "\improper Space Carp"
	special_role = SPECIAL_ROLE_CARP
	/// The rift to protect
	var/obj/structure/carp_rift/rift


/datum/antagonist/space_carp/New(obj/structure/carp_rift/new_rift)
	. = ..()
	rift = new_rift


/datum/antagonist/space_carp/Destroy(force)
	rift = null
	return ..()


/datum/antagonist/space_carp/can_be_owned(datum/mind/new_owner)
	. = ..()
	if(!.)
		return FALSE

	var/datum/mind/tested = new_owner || owner
	if(!tested || !istype(tested.current, /mob/living/simple_animal/hostile/carp))
		log_admin("Failed to make Space Carp antagonist, owner is not a space carp!")
		return FALSE

	return TRUE


/datum/antagonist/space_carp/give_objectives()
	var/datum/objective/space_carp/objective = add_objective(/datum/objective/space_carp)
	objective.rift = rift


/datum/objective/space_carp
	explanation_text = "Защищайте разлом призыва карпов."
	needs_target = FALSE
	var/obj/structure/carp_rift/rift


/datum/objective/space_carp/check_completion()
	return rift

/proc/isspacecarp(datum/source)
	if(!source)
		return FALSE

	if(istype(source, /datum/mind))
		var/datum/mind/our_mind = source
		return our_mind.has_antag_datum(/datum/antagonist/space_carp)

	if(!ismob(source))
		return FALSE

	var/mob/mind_holder = source
	if(!mind_holder.mind)
		return FALSE

	return mind_holder.mind.has_antag_datum(/datum/antagonist/space_carp)
