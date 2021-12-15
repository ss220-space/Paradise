/datum/world_topic_handler/playerlist_ext
	topic_key = "playerlist_ext"

/datum/world_topic_handler/playerlist_ext/execute(list/input, key_valid)
	var/list/players = list()
	var/list/just_keys = list()

	for(var/client/C in GLOB.clients)
		players[C.key] += C.key
		just_keys += C.key

	for(var/datum/mind/M in SSticker.minds)
		if(!M.current)
			continue
		if(M.current.client)
			continue
		if(M.current.player_ghosted)
			if(!players[M.key])
				continue

		players[M.key] = M.key
		just_keys += M.key

	return json_encode(just_keys)
