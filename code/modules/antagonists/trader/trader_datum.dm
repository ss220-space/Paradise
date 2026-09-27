/datum/antagonist/trader
	name = "Sol Trader"
	roundend_category = "Торговцами"
	show_in_roundend = FALSE
	job_rank = ROLE_TRADER
	special_role = SPECIAL_ROLE_TRADER
	antag_menu_name = "Торговец"
	give_objectives = FALSE
	replace_banned = FALSE
	greet_box_class = "green_box"

/datum/antagonist/trader/apply_innate_effects(mob/living/mob_override)
	. = ..()
	owner.offstation_role = TRUE

/datum/antagonist/trader/remove_innate_effects(mob/living/mob_override)
	. = ..()
	owner.offstation_role = FALSE

/datum/antagonist/trader/greet()
	var/list/messages = list()
	messages.Add(span_boldnotice("Вы — торговец!"))
	messages.Add(span_notice("В данный момент вы находитесь на [get_area(owner.current)]."))
	messages.Add(span_notice("Вам предстоит торговать со станцией [station_name()]."))
	return messages
