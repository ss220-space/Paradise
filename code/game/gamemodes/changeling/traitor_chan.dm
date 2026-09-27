/datum/game_mode/traitor/changeling
	name = "traitor+changeling"
	config_tag = "traitorchan"
	traitors_possible = 3 //hard limit on traitors if scaling is turned off
	required_players = 10
	recommended_enemies = 3
	var/protected_species_changeling = list(SPECIES_MACHINEPERSON)

/datum/game_mode/traitor/changeling/announce()
	to_chat(world, "<b>The current game mode is - Traitor+Changeling!</b>")
	to_chat(world, "<b>There is an alien creature on the station along with some syndicate operatives out for their own gain! Do not let the changeling and the traitors succeed!</b>")

/datum/game_mode/traitor/changeling/pre_setup()
	var/list/datum/mind/possible_changelings = get_players_for_role(ROLE_CHANGELING)

	for(var/mob/new_player/player in GLOB.player_list)
		if((player.mind in possible_changelings) && (player.client.prefs.species in protected_species_changeling))
			possible_changelings -= player.mind

	if(length(possible_changelings))
		var/datum/mind/changeling = pick(possible_changelings)
		pre_changelings += changeling
		changeling.restricted_roles = get_restricted_roles()
		changeling.special_role = SPECIAL_ROLE_CHANGELING
		return ..()
	else
		return FALSE

/datum/game_mode/traitor/changeling/post_setup()
	for(var/datum/mind/changeling in pre_changelings)
		changeling.add_antag_datum(/datum/antagonist/changeling)
	..()

