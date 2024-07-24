/datum/event/abductor
	var/for_players = 30 		//Количество людей для спавна доп. команды
	var/datum/game_mode/abduction/game_mode_ref

/datum/event/abductor/start()
	//spawn abductor team
	processing = 0 //so it won't fire again in next tick
	if(!makeAbductorTeam())
		message_admins("Abductor event failed to find players. Retrying in 30s.")
		spawn(300)
			makeAbductorTeam()

/datum/event/abductor/proc/get_teams_num()
	return min(round(num_station_players() / for_players) + 1, game_mode_ref.max_teams)

/datum/event/abductor/proc/makeAbductorTeam()
	var/list/mob/dead/observer/candidates = SSghost_spawns.poll_candidates("Вы хотите занять роль Абдуктора?", ROLE_ABDUCTOR, TRUE)

	if(length(candidates) < 2)
		return FALSE

	if(SSticker.mode.config_tag == "abduction")
		game_mode_ref = SSticker.mode
	else
		game_mode_ref = new

	var/num_teams = get_teams_num()
	for(var/i in 1 to num_teams)
		if(length(candidates) < 2)
			break

		var/number =  SSticker.mode.abductor_teams + 1
		var/agent_mind = pick_n_take(candidates)
		var/scientist_mind = pick_n_take(candidates)

		var/mob/living/carbon/human/agent = makeBody(agent_mind)
		var/mob/living/carbon/human/scientist = makeBody(scientist_mind)

		agent_mind = agent.mind
		scientist_mind = scientist.mind

		game_mode_ref.scientists.len = number
		game_mode_ref.agents.len = number
		game_mode_ref.abductors.len = 2 * number
		game_mode_ref.team_objectives.len = number
		game_mode_ref.team_names.len = number
		game_mode_ref.scientists[number] = scientist_mind
		game_mode_ref.agents[number] = agent_mind
		game_mode_ref.abductors |= list(agent_mind,scientist_mind)
		game_mode_ref.make_abductor_team(number,preset_scientist=scientist_mind,preset_agent=agent_mind)
		game_mode_ref.post_setup_team(number)

		SSticker.mode.abductor_teams++

	if(SSticker.mode.config_tag != "abduction")
		SSticker.mode.abductors |= game_mode_ref.abductors
	processing = 1
	return TRUE

/datum/event/abductor/one_crew/get_teams_num()
	return 1
