/datum/game_mode/abduction
	name = "abduction"
	config_tag = "abduction"
	recommended_enemies = 2
	required_players = 15
	var/max_teams = 4
	abductor_teams = 1
	var/list/datum/mind/pre_abductors = list()
	var/list/datum/mind/scientists = list()
	var/list/datum/mind/agents = list()
	var/list/datum/objective/team_objectives = list()
	var/list/team_names = list()
	var/finished = 0
	var/list/datum/mind/possible_abductors = list()

/datum/game_mode/abduction/announce()
	to_chat(world, "<b>The current game mode is - Abduction!</b>")
	to_chat(world, "There are alien <b>abductors</b> sent to [station_name()] to perform nefarious experiments!")
	to_chat(world, "<b>Abductors</b> - kidnap the crew and replace their organs with experimental ones.")
	to_chat(world, "<b>Crew</b> - don't get abducted and stop the abductors.")

/datum/game_mode/abduction/pre_setup()
	possible_abductors = get_players_for_role(ROLE_ABDUCTOR)

	if(!length(possible_abductors))
		return 0

	abductor_teams = max(1, min(max_teams,round(num_players()/15)))
	var/possible_teams = max(1,round(length(possible_abductors) / 2))
	abductor_teams = min(abductor_teams,possible_teams)

	pre_abductors.len = 2*abductor_teams
	scientists.len = abductor_teams
	agents.len = abductor_teams
	team_objectives.len = abductor_teams
	team_names.len = abductor_teams

	for(var/i=1,i<=abductor_teams,i++)
		if(!make_abductor_team(i))
			return 0
	..()
	return 1

/datum/game_mode/abduction/proc/make_abductor_team(team_number,preset_agent=null,preset_scientist=null)
	//Team Name
	team_names[team_number] = "Mothership [pick(GLOB.possible_changeling_IDs)]" //TODO Ensure unique and actual alieny names
	//Team Objective
	var/datum/objective/experiment/team_objective = new
	team_objective.abductor_team_number = team_number
	team_objectives[team_number] = team_objective
	//Team Members

	if(!preset_agent || !preset_scientist)
		if(length(possible_abductors) <=2)
			return 0

	var/datum/mind/scientist
	var/datum/mind/agent

	if(!preset_scientist)
		scientist = pick(possible_abductors)
		possible_abductors -= scientist
	else
		scientist = preset_scientist

	if(!preset_agent)
		agent = pick(possible_abductors)
		possible_abductors -= agent
	else
		agent = preset_agent

	scientist.assigned_role = SPECIAL_ROLE_ABDUCTOR_SCIENTIST
	add_game_logs("has been selected as an abductor team [team_number] scientist.", scientist)

	agent.assigned_role = SPECIAL_ROLE_ABDUCTOR_AGENT
	add_game_logs("has been selected as an abductor team [team_number] agent.", agent)

	pre_abductors |= agent
	pre_abductors |= scientist
	scientists[team_number] = scientist
	agents[team_number] = agent
	return 1

/datum/game_mode/abduction/post_setup()
	for(var/team_number=1,team_number<=abductor_teams,team_number++)
		post_setup_team(team_number)
	return ..()

//Used for create antag buttons
/datum/game_mode/abduction/proc/post_setup_team(team_number)
	var/list/obj/effect/landmark/abductor/agent_landmarks = list()
	var/list/obj/effect/landmark/abductor/scientist_landmarks = list()
	agent_landmarks.len = max_teams
	scientist_landmarks.len = max_teams
	for(var/obj/effect/landmark/abductor/A in GLOB.landmarks_list)
		if(istype(A,/obj/effect/landmark/abductor/agent))
			agent_landmarks[text2num(A.team)] = A
		else if(istype(A,/obj/effect/landmark/abductor/scientist))
			scientist_landmarks[text2num(A.team)] = A

	var/team_name = team_names[team_number]

	var/datum/mind/agent
	var/obj/effect/landmark/L
	var/datum/mind/scientist
	var/mob/living/carbon/human/H
	var/datum/species/abductor/S

	team_name = team_names[team_number]
	agent = agents[team_number]
	H = agent.current
	L = agent_landmarks[team_number]
	H.forceMove(get_turf(L))
	H.body_accessory = null
	H.set_species(/datum/species/abductor)
	S = H.dna.species
	S.team = team_number
	H.real_name = team_name + " Agent"
	H.cleanSE() //No fat/blind/colourblind/epileptic/whatever ayys.
	H.overeatduration = 0
	H.flavor_text = null
	H.equipOutfit(/datum/outfit/abductor/agent)
	give_abductor_datum(agent, /datum/antagonist/abductor, team_number)

	scientist = scientists[team_number]
	H = scientist.current
	L = scientist_landmarks[team_number]
	H.forceMove(get_turf(L))
	H.body_accessory = null
	H.set_species(/datum/species/abductor)
	S = H.dna.species
	S.scientist = TRUE
	S.team = team_number
	H.real_name = team_name + " Scientist"
	H.cleanSE() //No fat/blind/colourblind/epileptic/whatever ayys.
	H.overeatduration = 0
	H.flavor_text = null
	H.equipOutfit(/datum/outfit/abductor/scientist)
	give_abductor_datum(scientist, /datum/antagonist/abductor/scientist, team_number)

/datum/game_mode/abduction/proc/give_abductor_datum(datum/mind/abductor, datum_type, team_number)
	abductor.objectives += team_objectives[team_number]
	var/datum/antagonist/abductor/abductor_datum = new datum_type
	abductor_datum.team_name = team_names[team_number]
	abductor.add_antag_datum(abductor_datum)
	log_game("[abductor] has become [abductor_datum.name].")

/datum/game_mode/abduction/proc/get_team_console(team_number)
	for(var/obj/machinery/abductor/console/C in SSmachines.get_by_type(/obj/machinery/abductor/console))
		if(C.team == team_number)
			return C

/datum/game_mode/abduction/check_finished()
	if(!finished)
		for(var/team_number=1,team_number<=abductor_teams,team_number++)
			var/obj/machinery/abductor/console/con = get_team_console(team_number)
			var/datum/objective/objective = team_objectives[team_number]
			if(con.experiment.points >= objective.target_amount)
				SSshuttle.emergency.request(null, 0.5, reason = " Выявлено множество аномальных моделей мышления. Весь экипаж будет направлен на обязательное обследование и реабилитацию для восстановления полноценной работоспособности.")
				SSshuttle.emergency.canRecall = FALSE
				finished = 1
				return ..()
	return ..()

/datum/game_mode/abduction/declare_completion()
	for(var/team_number=1,team_number<=abductor_teams,team_number++)
		var/obj/machinery/abductor/console/console = get_team_console(team_number)
		var/datum/objective/objective = team_objectives[team_number]
		var/team_name = team_names[team_number]
		if(console.experiment.points >= objective.target_amount)
			to_chat(world, span_greenannounce("[team_name] team fulfilled its mission!"))
		else
			to_chat(world, span_boldannounceooc("[team_name] team failed its mission."))
	..()
	return 1

/obj/effect/landmark/abductor
	icon_state = "abductor_agent"
	var/team = 1

/obj/effect/landmark/abductor/agent
/obj/effect/landmark/abductor/scientist

// OBJECTIVES
/datum/objective/experiment
	needs_target = FALSE
	target_amount = 6
	/// Which abductor team number does this belong to.
	var/abductor_team_number
	antag_menu_name = "Провести эксперимент"

/datum/objective/stay_hidden

/datum/objective/stay_hidden/New()
	explanation_text = "Ограничьте контакты со своими целями, за исключением проведения экспериментов и похищений."
	completed = TRUE
//No check completion, it defaults to being completed unless an admin sets it to failed.

/datum/objective/experiment/New()
	explanation_text = "Проведите эксперимент на [target_amount] гуманоид[declension_ru(target_amount, "е", "ах", "ах")]."

/datum/objective/experiment/check_completion()
	var/ab_team = abductor_team_number
	for(var/datum/mind/player in get_owners())
		if(!player.current || !ishuman(player.current) || !isabductor(player.current))
			return FALSE

		var/mob/living/carbon/human/human_owner = player.current
		var/datum/species/abductor/abductor = human_owner.dna.species
		ab_team = abductor.team

	for(var/obj/machinery/abductor/experiment/experiment in SSmachines.get_by_type(/obj/machinery/abductor/experiment))
		if(experiment.team == ab_team)
			if(experiment.points >= target_amount)
				return TRUE
			else
				return FALSE

	return FALSE

/datum/game_mode/proc/remove_abductor(datum/mind/abductor_mind)
	if(!abductor_mind?.has_antag_datum(/datum/antagonist/abductor))
		return
	add_conversion_logs(abductor_mind.current, "No longer abductor")
	abductor_mind.remove_antag_datum(/datum/antagonist/abductor)
