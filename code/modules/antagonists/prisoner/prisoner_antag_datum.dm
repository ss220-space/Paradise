// Prisoner antag datum
/datum/antagonist/traitor/prisoner
	name = "Prisoner Traitor"
	job_rank = ROLE_PRISONER_TRAITOR
	wiki_page_name = "Prisoner Traitor"
	russian_wiki_name = "Заключенный Предатель"
	antag_menu_name = "Предатель заключенный"
	give_uplink = FALSE


/datum/antagonist/traitor/give_objectives()
	// Objective #1: Escape from prison
	add_objective(/datum/objective/prison_escape)
	// Objective #2: Kill one person
	add_objective(/datum/objective/maroon)
