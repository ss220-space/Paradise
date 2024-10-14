/obj/item/implanter/mini_traitor
	name = "bio-chip implanter (Modified Mindslave)"
	desc = "На боку едва заметная гравировка \"Cybersun Industries\"."
	imp = /obj/item/implant/mini_traitor

/obj/item/implant/mini_traitor // looks like normal but doesn't make you normal after removing
	name = "Mindslave Bio-chip"
	implant_state = "implant-syndicate"
	origin_tech = "programming=4;biotech=4;syndicate=7" // As original, but - 1 level of every tech
	activated = BIOCHIP_ACTIVATED_PASSIVE
	implant_data = /datum/implant_fluff/traitor


/obj/item/implant/mini_traitor/implant(mob/living/carbon/human/mindslave_target, mob/living/carbon/human/user, force = FALSE)
	if(implanted == BIOCHIP_USED || !ishuman(mindslave_target) || !ishuman(user)) // Both the target and the user need to be human.
		return FALSE

	// If the target is catatonic or doesn't have a mind, don't let them use it
	if(!mindslave_target.mind)
		to_chat(user, span_warning("<i>Это существо не разумно!</i>"))
		return FALSE

	// Fails if they're already a mindslave of someone, or if they're mindshielded.
	if(ismindslave(mindslave_target) || ismindshielded(mindslave_target) || isvampirethrall(mindslave_target))
		mindslave_target.visible_message(
			span_warning("[mindslave_target] seems to resist the bio-chip!"),
			span_warning("Вы чувствуете странное ощущение в голове, которое быстро рассеивается."),
		)
		qdel(src)
		return FALSE

	var/datum/mind/mind = mindslave_target.mind

	if(!mind.has_antag_datum(/datum/antagonist/traitor))
		var/datum/antagonist/traitor/traitor_datum = new /datum/antagonist/traitor
		//traitor_datum.give_objectives = FALSE
		// traitor_datum.give_uplink = FALSE
		traitor_datum.gen_affiliate = FALSE
		mind.add_antag_datum(traitor_datum)

	log_admin("[key_name_admin(user)] has made [key_name_admin(mindslave_target)] new traitor.")

	var/datum/antagonist/traitor/T = user.mind.has_antag_datum(/datum/antagonist/traitor)
	if(!T)
		return ..()

	for(var/datum/objective/new_mini_traitor/objective in T.objectives)
		if(mindslave_target.mind == objective.target)
			objective.made = TRUE

	return ..()
