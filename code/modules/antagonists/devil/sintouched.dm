/datum/antagonist/sintouched
	name = "Sintouched"
	antag_menu_name = "Грешник"
	roundend_category = "sintouched"
	special_role = SPECIAL_ROLE_SINTOUCHED
	antag_hud_type = ANTAG_HUD_SINTOUCHED
	antag_hud_name = "hudsintouched"

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


/datum/antagonist/sintouched/roundend_report()
	var/text
	var/traitorwin = TRUE
	text += "<br>[owner.get_display_key()] был [owner.name]("
	if(owner.current)
		if(owner.current.stat == DEAD)
			text += "умер"
			traitorwin = FALSE
		else
			text += "жив"
	else
		text += "тело уничтожено"
		traitorwin = FALSE
	text += ")"

	var/list/all_objectives = owner.get_all_objectives()

	if(length(all_objectives))
		var/count = 1
		for(var/datum/objective/objective in all_objectives)
			if(objective.check_completion())
				text += "<br><b>Цель #[count]</b>: [objective.explanation_text] <b>[span_fontcolor_green("Успех!")]</b>"
				SSblackbox.record_feedback("nested tally", "sintouched_objective", 1, list("[objective.type]", "SUCCESS"))
			else
				text += "<br><b>Цель #[count]</b>: [objective.explanation_text] [span_fontcolor_red("Провал!")]"
				SSblackbox.record_feedback("nested tally", "sintouched_objective", 1, list("[objective.type]", "FAIL"))
				traitorwin = FALSE
			count++

	if(traitorwin)
		text += span_fontcolor_green("<br><b>Грешник был успешен!</b>")
		SSblackbox.record_feedback("tally", "sintouched_success", 1, "SUCCESS")
	else
		text += span_fontcolor_red("<br><b>Грешник провалился!</b>")
		SSblackbox.record_feedback("tally", "sintouched_success", 1, "FAIL")

	return text
