/datum/antagonist/highlander
	name = "Highlander"
	roundend_category = "Хайлендерами"
	show_in_roundend = FALSE
	special_role = SPECIAL_ROLE_HIGHLANDER
	antag_menu_name = "Хайлендер"

/datum/antagonist/highlander/give_objectives()
	add_objective(/datum/objective/hijack)

/datum/antagonist/highlander/greet()
	return list("<b>You are a Highlander. Kill all other Highlanders. There can be only one.</b>")
