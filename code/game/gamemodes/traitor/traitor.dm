/datum/game_mode/traitor
	name = "traitor"
	config_tag = "traitor"
	required_enemies = 1
	recommended_enemies = 4
	/// Same as above for malf AI.
	var/datum/mind/pre_malf_AI
	/// Hard limit on traitors if scaling is turned off.
	var/traitors_possible = 4

/datum/game_mode/traitor/announce()
	to_chat(world, "<b>The current game mode is - Traitor!</b>")
	to_chat(world, "<b>There is a syndicate traitor on the station. Do not let the traitor succeed!</b>")

/datum/game_mode/traitor/pre_setup()
	. = FALSE

	var/list/possible_traitors = get_players_for_role(ROLE_TRAITOR)
	var/list/possible_malfs = get_players_for_role(ROLE_MALF_AI, req_job_rank = JOB_TITLE_AI)

	var/malf_AI_candidate
	if(length(possible_malfs))
		malf_AI_candidate = pick(possible_malfs)
		possible_traitors |= malf_AI_candidate

	if(!length(possible_traitors))
		return

	. = TRUE

	var/num_traitors = 1
	var/num_players = num_players()

	if(CONFIG_GET(number/traitor_scaling))
		num_traitors = max(1, round(num_players / CONFIG_GET(number/traitor_scaling)) + 1)
	else
		num_traitors = max(1, min(num_players, traitors_possible))

	add_game_logs("Number of traitors chosen: [num_traitors]")

	for(var/i in 1 to num_traitors)
		if(!length(possible_traitors))
			break
		var/datum/mind/traitor = pick_n_take(possible_traitors)
		traitor.special_role = SPECIAL_ROLE_TRAITOR
		if(traitor == malf_AI_candidate)
			if((ROLE_TRAITOR in traitor.current.client.prefs.be_special) && prob(50))	// If traitor is also enabled its 50/50 chance.
				pre_traitors += traitor
				traitor.restricted_roles = get_restricted_roles()
			else
				pre_malf_AI = traitor
				traitor.special_role = SPECIAL_ROLE_MALFAI
				SSjobs.forced_occupations[traitor] = JOB_TITLE_AI
		else
			pre_traitors += traitor
			traitor.restricted_roles = get_restricted_roles()

/datum/game_mode/traitor/post_setup()
	for(var/datum/mind/traitor in pre_traitors)
		var/datum/antagonist/traitor/new_antag = new
		new_antag.contractor_pending = new(traitor)
		addtimer(CALLBACK(traitor, TYPE_PROC_REF(/datum/mind, add_antag_datum), new_antag), rand(1 SECONDS, 10 SECONDS))
	if(pre_malf_AI)
		addtimer(CALLBACK(pre_malf_AI, TYPE_PROC_REF(/datum/mind, add_antag_datum), /datum/antagonist/malf_ai), rand(1 SECONDS, 10 SECONDS))
	if(!exchange_blue)
		exchange_blue = -1 //Block latejoiners from getting exchange objectives
	..()

/datum/game_mode/traitor/declare_completion()
	..()
	return//Traitors will be checked as part of check_extra_completion. Leaving this here as a reminder.

/datum/game_mode/traitor/process()
	// Make sure all objectives are processed regularly, so that objectives
	// which can be checked mid-round are checked mid-round.
	for(var/datum/mind/traitor_mind in get_antag_minds(/datum/antagonist/traitor))
		for(var/datum/objective/objective in traitor_mind.get_all_objectives())
			objective.check_completion()
	return FALSE

