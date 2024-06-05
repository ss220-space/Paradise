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
	var/static/list/map_reference_list = list()

/datum/vote/map/New()
	if(!SSmapping.map_datum)
		CRASH("Map Vote triggered before the `map_datum` is defined!")
	..()
	no_dead_vote = FALSE

/datum/vote/map/proc/is_map_aviable(datum/map/possible_map)
	var/current_players = GLOB.player_list.len
	return possible_map.min_players <= current_players && current_players <= possible_map.max_players

/datum/vote/map/generate_choices()
	for(var/datum/map/possible_map as anything in (subtypesof(/datum/map) - SSmapping.map_datum.type))
		if(initial(possible_map.admin_only) || !is_map_aviable(possible_map))
			continue
		var/map_ref = "[initial(possible_map.station_name)] ([initial(possible_map.name)])"

		if(!map_reference_list[map_ref])
			map_reference_list[map_ref] = possible_map

		choices.Add(map_ref)

/datum/vote/map/announce()
	..()
	for(var/mob/M in GLOB.player_list)
		M.throw_alert("Map Vote", /atom/movable/screen/alert/notify_mapvote, timeout_override = CONFIG_GET(number/vote_period))

/datum/vote/map/result_corrections(list/results)
	var/list/deleted_maps
	for(var/result in results)
		var/datum/map/possible_map = map_reference_list[result]
		if(!is_map_aviable(possible_map))
			results -= result
			LAZYADD(deleted_maps, possible_map)
	var/deleted_number = LAZYLEN(deleted_maps)
	if(deleted_number)
		var/message
		while(deleted_maps.len)
			var/datum/map/deleted_map = deleted_maps[1]
			deleted_maps -= deleted_map
			message = "[message][deleted_map.station_name][deleted_maps.len ? ", " : ""]"
		to_chat(world, "<b>[message] [deleted_number > 1 ? "were" : "was"] removed from the vote due to the player limit.</b>")
	return results

/datum/vote/map/handle_result(result)
	if(!result)
		return
	var/winner_map = map_reference_list[result]
	to_chat(world, "<b>Map for next round: [result]</b>")
	SSmapping.next_map = new winner_map

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
