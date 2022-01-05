/datum/world_topic_handler/playerlist_ext
	topic_key = "playerlist_ext"
	requires_commskey = TRUE

/datum/world_topic_handler/playerlist_ext/execute(list/input, key_valid)
	var/list/players = list()
	var/list/just_keys = list()
	// world.log << "== playerlist_ext called =="

	// world.log << "all clients:"
	for(var/client/C as anything in GLOB.clients)
		var/ckey = C.ckey
		// world.log << "+ [ckey]"
		players[ckey] += ckey
		just_keys += ckey

	// world.log << "alive_mob_list:"
	for(var/mob/M in GLOB.alive_mob_list)
		// world.log << "next [M.ckey] [M.last_known_ckey] (mob [M.name])"
		if(!M.last_known_ckey)
			// world.log << "no ckey for mob [M.name]"
			continue
		var/ckey = ckey(M.last_known_ckey)
		if(!M.mind.current)
			// world.log << "[ckey] no current mob"
			continue
		if(M.mind.current.client)
			// world.log << "[ckey] (mob [M.name]) has current client"
			continue
		if(players[ckey])
			// world.log << "[ckey] (mob [M.name]) is already in list"
			continue

		// world.log << "+ [ckey]"
		players[ckey] = ckey
		just_keys += ckey

	return json_encode(just_keys)
