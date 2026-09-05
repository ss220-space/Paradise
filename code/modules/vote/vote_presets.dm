#define CREW_TRANSFER_CHOICE "Инициировать трансфер экипажа"
#define CONTINUE_SHIFT_CHOICE "Продолжить смену"

// Crew transfer vote
/datum/vote/crew_transfer
	name = "Трансфер экипажа"
	override_question = "Завершение смены"
	default_choices = list(
		CREW_TRANSFER_CHOICE,
		CONTINUE_SHIFT_CHOICE,
	)
	no_offstation_vote = TRUE

/datum/vote/crew_transfer/finalize_vote(result)
	if(result == CREW_TRANSFER_CHOICE)
		init_shift_change(null, TRUE)

/datum/vote/crew_transfer/can_be_initiated(forced)
	. = ..()
	if(. != VOTE_AVAILABLE)
		return .

	if(forced)
		return .

	if(SSticker.current_state < GAME_STATE_PLAYING)
		return "Attempted to call a shuttle vote before the game starts!"

	return "Only admins can create crew transfer vote."

// Map vote
/datum/vote/map
	name = "Карта"
	default_message = "Голосование за карту в следующем раунде!"
	count_method = VOTE_COUNT_METHOD_MULTI
	allow_dead_vote = TRUE

/datum/vote/map/create_vote(mob/vote_creator)
	. = ..()
	var/list/map_pool = subtypesof(/datum/map)
	if(CONFIG_GET(string/map_vote_mode) == "nodoubles")
		map_pool -= SSmapping.map_datum.type

	if(CONFIG_GET(string/map_vote_mode) == "notriples")
		if(SSmapping.previous_maps && length(SSmapping.previous_maps))
			var/current_map = SSmapping.map_datum.type
			if(current_map == SSmapping.previous_maps[1])
				map_pool -= current_map

	for(var/datum/map/possible_map as anything in map_pool)
		if(initial(possible_map.admin_only))
			continue
		choices["[initial(possible_map.station_name)] ([initial(possible_map.name)])"] = 0

/datum/vote/map/is_accessible_vote()
	return TRUE

/datum/vote/map/can_be_initiated(forced)
	. = ..()
	if(. != VOTE_AVAILABLE)
		return .

	if(!SSmapping.map_datum)
		return "Map Vote triggered before the map config load!"

	if(!SSticker.current_state < GAME_STATE_PREGAME)
		return "Map Vote triggered before Lobby stage!"

/datum/vote/map/finalize_vote(result)
	// Find target map.
	if(!result)
		return
	var/datum/map/top_voted_map
	for(var/x in subtypesof(/datum/map))
		var/datum/map/M = x
		if(!initial(M.admin_only))
			// Set top voted map
			if(result == "[initial(M.station_name)] ([initial(M.name)])")
				top_voted_map = M
	to_chat(world, span_interface("<b>Map for next round: [initial(top_voted_map.station_name)] ([initial(top_voted_map.name)])</b>"))
	SSmapping.next_map = new top_voted_map

/datum/vote/map/toggle_votable()
	CONFIG_SET(flag/allow_vote_map, !CONFIG_GET(flag/allow_vote_map))

/datum/vote/map/is_config_enabled()
	return CONFIG_GET(flag/allow_vote_map)

/datum/vote/gamemode
	name = "Игровой режим"
	override_question = "Голосование за игровой режим режим"
	count_method = VOTE_COUNT_METHOD_MULTI
	allow_dead_vote = TRUE
	display_statistics = FALSE
	print_results = FALSE
	hide_winner = TRUE

/datum/vote/gamemode/create_vote(mob/vote_creator)
	. = ..()
	for(var/mode in config.votable_modes)
		choices[mode] = 0

/datum/vote/gamemode/finalize_vote(result)
	if(!result)
		return

	if(GLOB.master_mode != result)
		GLOB.master_mode = "secret"
		GLOB.secret_force_mode = result

	if(!SSticker.ticker_going)
		SSticker.ticker_going = TRUE
		to_chat(world, "<font color='red'><b>The round will start soon.</b></font>")

/datum/vote/gamemode/toggle_votable()
	CONFIG_SET(flag/allow_vote_gamemode, !CONFIG_GET(flag/allow_vote_gamemode))

/datum/vote/gamemode/is_config_enabled()
	return CONFIG_GET(flag/allow_vote_gamemode)

/datum/vote/gamemode/is_accessible_vote()
	return TRUE

/datum/vote/gamemode/can_be_initiated(forced)
	. = ..()
	if(. != VOTE_AVAILABLE)
		return .

	if(SSticker?.mode)
		return "Game mode triggered after the game mode selection!"

	if(!SSticker.current_state < GAME_STATE_PREGAME)
		return "Map Vote triggered before Lobby stage!"

#undef CREW_TRANSFER_CHOICE
#undef CONTINUE_SHIFT_CHOICE
