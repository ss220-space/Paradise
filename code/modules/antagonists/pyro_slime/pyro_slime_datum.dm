/datum/antagonist/pyro_slime
	name = "Pyroclastic Anomaly Slime"
	roundend_category = "Слаймами атмосферной аномалии"
	show_in_roundend = FALSE
	job_rank = ROLE_SENTIENT
	special_role = SPECIAL_ROLE_PYROCLASTIC_SLIME
	antag_menu_name = "Слайм атмосферной аномалии"
	replace_banned = FALSE

/datum/antagonist/pyro_slime/give_objectives()
	add_objective(/datum/objective/pyro_slime)

/datum/antagonist/pyro_slime/greet()
	return list(span_userdanger("Вы — порождение атмосферной аномалии. Тепло живых существ питает вас, холод и вода несут смерть."))


/datum/objective/pyro_slime
	explanation_text = "Согревайтесь чужим теплом и жгите всё, до чего дотянетесь."
	needs_target = FALSE
	antag_menu_name = "Выжить и жечь"

/datum/objective/pyro_slime/check_completion()
	return owner.current && owner.current.stat != DEAD
