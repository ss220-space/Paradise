/datum/game_mode/traitor/thief/changeling
	name = "traitor+thief+changeling"
	config_tag = "traitorthiefchan"
	required_players = 25
	var/protected_species_changeling = list(SPECIES_MACHINEPERSON)

/datum/game_mode/traitor/thief/changeling/announce()
	to_chat(world, "<b>The current game mode is - Traitor+Thief+Changeling!</b>")
	to_chat(world, "<b>На станции зафиксирована деятельность гильдии воров, генокрадов и агентов \"Синдиката\". Не дайте агентам \"Синдиката\" и Генокрадам достичь успеха и скрыться, и не допустите кражу дорогостоящего оборудования!</b>")

/datum/game_mode/traitor/thief/changeling/pre_setup()
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

/datum/game_mode/traitor/thief/changeling/post_setup()
	for(var/datum/mind/changeling in pre_changelings)
		changeling.add_antag_datum(/datum/antagonist/changeling)
	..()

