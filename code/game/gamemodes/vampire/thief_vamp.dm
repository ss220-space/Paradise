/datum/game_mode/thief/vampire
	name = "vampire+thief"
	config_tag = "vampirethief"
	thieves_amount = 3 //hard limit on vampires if scaling is turned off
	restricted_jobs = list("AI", "Cyborg")
	required_players = 10
	required_enemies = 1	// how many of each type are required
	recommended_enemies = 3

/datum/game_mode/thief/vampire/announce()
	to_chat(world, "<B>The current game mode is - Vampire+Thief!</B>")
	to_chat(world, "<B>На станции зафиксирована деятельность гильдии воров и агентов Синдиката. Не дайте агентам Синдиката достичь успеха и не допустите кражу дорогостоящего оборудования!</B>")


/datum/game_mode/thief/vampire/pre_setup()
	if(config.protect_roles_from_antagonist)
		restricted_jobs += protected_jobs

	var/list/datum/mind/possible_thieves = get_players_for_role(ROLE_THIEF)

	for(var/mob/new_player/player in GLOB.player_list)
		if((player.mind in possible_thieves))
			possible_thieves -= player.mind

	if(possible_thieves.len > 0)
		var/datum/mind/thief = pick(possible_thieves)
		thieves += thief
		modePlayer += thieves
		thief.restricted_roles = restricted_jobs
		thief.special_role = SPECIAL_ROLE_THIEF
		return ..()
	else
		return 0

/datum/game_mode/thief/vampire/post_setup()
	for(var/datum/mind/thief in thieves)
		thief.special_role = SPECIAL_ROLE_THIEF
		forge_thief_objectives(thief)
		equip_thief(thief)
		update_thief_icons_added(thief)
		greet_thief(thief)
	..()
