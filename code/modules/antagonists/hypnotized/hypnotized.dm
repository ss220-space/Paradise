/datum/antagonist/hypnotized
	name = "Hypnotized Victim"
	roundend_category = "hypnotized victims"
	antag_menu_name = "Загипнотизированный"
	show_in_orbit = FALSE
	var/datum/brain_trauma/hypnosis/trauma
	var/hypnotic_phrase

/datum/antagonist/hypnotized/New(hypnotic_phrase)
	src.hypnotic_phrase = hypnotic_phrase
	..()

/datum/antagonist/hypnotized/Destroy(force)
	QDEL_NULL(trauma)
	return ..()

/datum/antagonist/hypnotized/give_objectives()
	add_objective(/datum/objective/hypnotized_fixation, hypnotic_phrase)

/datum/objective/hypnotized_fixation
	antag_menu_name = "Навязчивая идея"
	needs_target = FALSE
	completed = TRUE

/datum/antagonist/hypnotized/greet()
	return

/datum/antagonist/hypnotized/farewell()
	return
