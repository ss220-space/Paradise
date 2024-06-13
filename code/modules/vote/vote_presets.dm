// Crew transfer vote
/datum/vote/crew_transfer
	question = "End the shift"
	choices = list("Initiate Crew Transfer", "Continue The Round")
	vote_type_text = "crew transfer"

/datum/vote/crew_transfer/New()
	if(SSticker.current_state < GAME_STATE_PLAYING)
		CRASH("Attempted to call a shuttle vote before the game starts!")
	..()

/datum/vote/crew_transfer/handle_result(result)
	if(result == "Initiate Crew Transfer")
		init_shift_change(null, TRUE)

// Map vote
/datum/vote/map
	question = "Map Vote"
	vote_type_text = "map"

/datum/vote/map/New()
	if(!SSmapping.map_datum)
		CRASH("Map Vote triggered before the `map_datum` is defined!")
	..()
	no_dead_vote = FALSE

/datum/vote/map/generate_choices()
	var/list/map_pool = subtypesof(/datum/map)

	if(CONFIG_GET(string/map_vote_mode) == "nodoubles")
		map_pool -= SSmapping.map_datum.type

	for(var/datum/map/possible_map as anything in map_pool)
		if(initial(possible_map.admin_only))
			continue
		choices.Add("[initial(possible_map.station_name)] ([initial(possible_map.name)])")

/datum/vote/map/announce()
	..()
	for(var/mob/voter in GLOB.player_list)
		voter.throw_alert("Map Vote", /atom/movable/screen/alert/notify_mapvote, timeout_override = CONFIG_GET(number/vote_period))
		if(!voter.client?.prefs || voter.client?.prefs?.toggles2 & PREFTOGGLE_2_DISABLE_VOTE_POPUPS)
			continue
		voter.immediate_vote()

/datum/vote/map/handle_result(result)
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
	to_chat(world, "<b>Map for next round: [initial(top_voted_map.station_name)] ([initial(top_voted_map.name)])</b>")
	SSmapping.next_map = new top_voted_map

/datum/vote/gamemode
	question = "Gamemode Vote"
	vote_type_text = "gamemode"

/datum/vote/gamemode/New()
	..()
	no_dead_vote = FALSE

/datum/vote/gamemode/generate_choices()
	choices.Add(config.votable_modes)

/datum/vote/gamemode/handle_result(result)
	if(!result)
		return
	if(GLOB.master_mode != result)
		world.save_mode(result)
		if(SSticker && SSticker.mode)
			to_chat(world, "<font color='red'><b>Mode has been selected but round already started, it will be applied next round.</b></font>")
		else
			GLOB.master_mode = result
	if(!SSticker.ticker_going)
		SSticker.ticker_going = TRUE
		to_chat(world, "<font color='red'><b>The round will start soon.</b></font>")
