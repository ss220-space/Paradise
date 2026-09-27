/datum/antagonist/abductor
	name = "Abductor Agent"
	roundend_category = "Абдукторами"
	job_rank = ROLE_ABDUCTOR
	special_role = SPECIAL_ROLE_ABDUCTOR_AGENT
	antag_hud_type = ANTAG_HUD_ABDUCTOR
	antag_hud_name = "abductor"
	antag_menu_name = "Абдуктор"
	wiki_page_name = "Abductor"
	russian_wiki_name = "Абдуктор"
	var/team_name
	var/greet_name = "an agent"
	var/role_hint = "Use your stealth technology and equipment to incapacitate humans for your scientist to retrieve."

/datum/antagonist/abductor/apply_innate_effects(mob/living/mob_override)
	. = ..()
	owner.offstation_role = TRUE

/datum/antagonist/abductor/remove_innate_effects(mob/living/mob_override)
	. = ..()
	owner.offstation_role = FALSE

/datum/antagonist/abductor/give_objectives()
	add_objective(/datum/objective/stay_hidden)

/datum/antagonist/abductor/greet()
	var/list/messages = list()
	messages.Add(span_notice("You are [greet_name][team_name ? " of [team_name]" : ""]!"))
	messages.Add(span_notice("With the help of your teammate, kidnap and experiment on station crew members!"))
	messages.Add(span_notice(role_hint))
	return messages

/datum/antagonist/abductor/farewell()
	if(issilicon(owner.current))
		to_chat(owner.current, span_userdanger("You have been turned into a robot! You are no longer an abductor."))
	else
		to_chat(owner.current, span_userdanger("You have been brainwashed! You are no longer an abductor."))


/datum/antagonist/abductor/scientist
	name = "Abductor Scientist"
	special_role = SPECIAL_ROLE_ABDUCTOR_SCIENTIST
	greet_name = "a scientist"
	role_hint = "Use your tool and ship consoles to support the agent and retrieve human specimens."


/datum/antagonist/abductee
	name = "Abductee"
	roundend_category = "Жертвами абдукторов"
	special_role = SPECIAL_ROLE_ABDUCTEE
	antag_hud_type = ANTAG_HUD_ABDUCTOR
	antag_hud_name = "abductee"
	antag_menu_name = "Жертва абдукторов"
	replace_banned = FALSE

/datum/antagonist/abductee/give_objectives()
	add_objective(pick(subtypesof(/datum/objective/abductee)))

/datum/antagonist/abductee/greet()
	return span_warning("<b>Your mind snaps!</b>")
