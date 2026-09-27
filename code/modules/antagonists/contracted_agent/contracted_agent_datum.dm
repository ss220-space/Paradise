/datum/antagonist/contracted_agent
	name = "Contracted Agent"
	roundend_category = "Наёмными агентами"
	show_in_roundend = FALSE
	job_rank = ROLE_TRAITOR
	special_role = SPECIAL_ROLE_CONTRACTED_AGENT
	antag_menu_name = "Наёмный агент"
	antag_hud_type = ANTAG_HUD_TRAITOR
	antag_hud_name = "hudsyndicate"
	replace_banned = FALSE
	var/datum/mind/contract_target
	var/lethal = TRUE

/datum/antagonist/contracted_agent/Destroy(force)
	contract_target = null
	return ..()

/datum/antagonist/contracted_agent/give_objectives()
	var/mob/living/victim = contract_target.current
	if(lethal)
		add_objective(/datum/objective/assassinate, "Kill [victim.real_name], the [contract_target.assigned_role].", contract_target)
		return
	add_objective(/datum/objective/protect, "Protect [victim.real_name], the [contract_target.assigned_role].", contract_target)

/datum/antagonist/contracted_agent/greet()
	var/mob/living/victim = contract_target.current
	var/list/messages = list()
	messages.Add("[span_danger("ATTENTION:")] You are now on a mission!")
	messages.Add("<b>Goal: [span_danger("[lethal ? "MURDER" : "PROTECT"] [victim.real_name]")], currently in [get_area(victim)].</b>")
	if(lethal)
		messages.Add("<b>If you kill [victim.p_them()], [victim.p_they()] cannot be revived.</b>")
	return messages
