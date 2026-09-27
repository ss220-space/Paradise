/datum/game_mode/thief
	name = "thief"
	config_tag = "thief"
	required_enemies = 1
	recommended_enemies = 3
	/// List of minds of soon to be thieves
	var/list/datum/mind/pre_thieves = list()

/datum/game_mode/thief/announce()
	to_chat(world, "<b>The current game mode is - thief!</b>")
	to_chat(world, "<b>На станции зафиксирована деятельность гильдии воров. Не допустите кражу дорогостоящего оборудования!</b>")

/datum/game_mode/thief/pre_setup()

	var/list/datum/mind/possible_thieves = get_players_for_role(ROLE_THIEF, list(SPECIES_VOX = 4))

	var/thieves_scale = 15
	if(CONFIG_GET(number/traitor_scaling))
		thieves_scale = CONFIG_GET(number/traitor_scaling)
	var/thieves_amount = 1 + round(num_players() / thieves_scale)
	add_game_logs("Number of  thieves chosen: [thieves_amount]")

	if(length(possible_thieves))
		for(var/i in 1 to thieves_amount)
			if(!length(possible_thieves))
				break
			var/datum/mind/thief = pick(possible_thieves)
			list_clear_duplicates(thief, possible_thieves)
			pre_thieves += thief
			thief.special_role = SPECIAL_ROLE_THIEF
			thief.restricted_roles = get_restricted_roles()
		..()
		return TRUE
	else
		return FALSE

/datum/game_mode/thief/post_setup()
	for(var/datum/mind/thief in pre_thieves)
		thief.add_antag_datum(/datum/antagonist/thief)
	..()


