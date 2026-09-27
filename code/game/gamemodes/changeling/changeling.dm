/datum/game_mode/changeling
	name = "changeling"
	config_tag = "changeling"
	protected_species = SPECIES_BLOCKED_FOR_CHANGELING
	required_players = 15
	required_enemies = 1
	recommended_enemies = 4
	/// The total number of changelings allowed to be picked.
	var/changeling_amount = 4

/datum/game_mode/changeling/Destroy(force)
	pre_changelings.Cut()
	return ..()

/datum/game_mode/changeling/announce()
	to_chat(world, "<b>The current game mode is - Changeling!</b>")
	to_chat(world, "<b>There are alien changelings on the station. Do not let the changelings succeed!</b>")

/datum/game_mode/changeling/pre_setup()
	var/list/datum/mind/possible_changelings = get_players_for_role(ROLE_CHANGELING)

	var/changeling_scale = 10
	if(CONFIG_GET(number/traitor_scaling))
		changeling_scale = CONFIG_GET(number/traitor_scaling)
	changeling_amount = 1 + round(num_players() / changeling_scale)
	add_game_logs("Number of changelings chosen: [changeling_amount]")

	for(var/i in 1 to changeling_amount)
		if(!length(possible_changelings))
			break
		var/datum/mind/changeling = pick_n_take(possible_changelings)
		pre_changelings += changeling
		changeling.restricted_roles = get_restricted_roles()
		changeling.special_role = SPECIAL_ROLE_CHANGELING

	if(!length(pre_changelings))
		return FALSE

	return TRUE

/datum/game_mode/changeling/post_setup()
	for(var/datum/mind/changeling as anything in pre_changelings)
		changeling.add_antag_datum(/datum/antagonist/changeling)
		pre_changelings -= changeling
	..()


