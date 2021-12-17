/datum/world_topic_handler/playerlist_ext
	topic_key = "playerlist_ext"
	requires_commskey = TRUE

/datum/world_topic_handler/playerlist_ext/execute(list/input, key_valid)
	var/list/players = list()
	var/list/just_keys = list()
	world.log << "== playerlist_ext called =="

	world.log << "all clients:"
	for(var/client/C in GLOB.clients)
		var/ckey = C.ckey
		world.log << "+ [ckey]"
		players[ckey] += ckey
		just_keys += ckey

	world.log << "all minds:"
	for(var/datum/mind/M in SSticker.minds)
		var/ckey = ckey(M.key)
		if(!M.current)
			world.log << "[ckey] no current mob"
			continue
		if(M.current.client)
			world.log << "[ckey] has current client"
			continue
		if(M.current.player_ghosted)
			world.log << "[ckey] has player_ghosted"
			if(!players[ckey])
				world.log << "[ckey] dont have attached player client"
				continue
		if(players[ckey])
			world.log << "[ckey] already in list"
			continue

		world.log << "+ [ckey]"
		players[ckey] = ckey
		just_keys += ckey

	return json_encode(just_keys)
