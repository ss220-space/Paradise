/datum/game_mode
	var/syndies_didnt_escape = 0
	var/nuke_off_station = 0

/datum/game_mode/nuclear
	name = "nuclear emergency"
	config_tag = "nuclear"
	required_players = 30	// 30 players - 5 players to be the nuke ops = 25 players remaining
	required_enemies = NUKERS_COUNT
	recommended_enemies = NUKERS_COUNT

	var/list/datum/mind/syndicates = list()

	var/const/agents_possible = NUKERS_COUNT //If we ever need more syndicate agents.

/datum/game_mode/nuclear/announce()
	to_chat(world, "<b>The current game mode is - Nuclear Emergency!</b>")
	to_chat(world, "<b>A Syndicate Strike Force is approaching [station_name()]!</b>")
	to_chat(world, "A nuclear explosive was being transported by Nanotrasen to a military base. The transport ship mysteriously lost contact with Space Traffic Control (STC). About that time a strange disk was discovered around [station_name()]. It was identified by Nanotrasen as a nuclear authentication disk and now Syndicate Operatives have arrived to retake the disk and detonate SS13! There are most likely Syndicate starships are in the vicinity, so take care not to lose the disk!\n<b>Syndicate</b>: Reclaim the disk and detonate the nuclear bomb anywhere on SS13.\n<b>Personnel</b>: Hold the disk and <b>escape with the disk</b> on the shuttle!")

/datum/game_mode/nuclear/can_start()
	if(!..())
		return FALSE
	var/list/possible_syndicates = get_players_for_role(ROLE_OPERATIVE)
	var/agent_number = 0

	if(!length(possible_syndicates))
		return FALSE

	if(possible_syndicates.len > agents_possible)
		agent_number = agents_possible
	else
		agent_number = possible_syndicates.len

	var/n_players = num_players()
	if(agent_number > n_players)
		agent_number = n_players / 2

	while(agent_number > 0)
		var/datum/mind/new_syndicate = pick_n_take(possible_syndicates)
		syndicates += new_syndicate
		agent_number--

	return TRUE

/datum/game_mode/nuclear/pre_setup()
	for(var/datum/mind/synd_mind as anything in syndicates)
		synd_mind.assigned_role = SPECIAL_ROLE_NUKEOPS //So they aren't chosen for other jobs.
		synd_mind.special_role = SPECIAL_ROLE_NUKEOPS
	return TRUE


/datum/game_mode/nuclear/post_setup()
	var/spawnpos = 1

	var/datum/team/nuclear_team/team = new /datum/team/nuclear_team

	for(var/datum/mind/synd_mind as anything in syndicates)
		if(spawnpos > GLOB.nukespawn.len)
			spawnpos = 2
		synd_mind.current.loc = GLOB.nukespawn[spawnpos]
		create_syndicate(synd_mind)
		team.add_member(synd_mind)
		var/datum/antagonist/nuclear_operative/datum = synd_mind.has_antag_datum(/datum/antagonist/nuclear_operative)
		datum.equip()
		spawnpos++
	team.scale_telecrystals()
	team.share_telecrystals()

	return ..()
