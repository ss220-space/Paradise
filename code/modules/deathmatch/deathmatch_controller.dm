/datum/deathmatch_controller
	/// Assoc list of all lobbies (ckey = lobby)
	var/list/datum/deathmatch_lobby/lobbies = list()
	/// All deathmatch map templates
	var/list/datum/lazy_template/deathmatch/maps = list()
	/// All loadouts
	var/list/datum/outfit/loadouts
	/// All modifiers
	var/list/datum/deathmatch_modifier/modifiers

/datum/deathmatch_controller/New()
	. = ..()
	if(GLOB.deathmatch_game)
		qdel(src)
		CRASH("A deathmatch controller already exists.")
	GLOB.deathmatch_game = src

	for(var/datum/lazy_template/deathmatch/template as anything in subtypesof(/datum/lazy_template/deathmatch))
		var/map_name = initial(template.name)
		maps[map_name] = new template
	loadouts = subtypesof(/datum/outfit/deathmatch_loadout)
	modifiers = sortTim(init_subtypes_w_path_keys(/datum/deathmatch_modifier), GLOBAL_PROC_REF(cmp_deathmatch_mods), associative = TRUE)

/datum/deathmatch_controller/proc/create_new_lobby(mob/host)
	lobbies[host.ckey] = new /datum/deathmatch_lobby(host)
	notify_ghosts("Было открыто новое лобби режима \"Deathmatch\".")

/datum/deathmatch_controller/proc/remove_lobby(ckey)
	var/lobby = lobbies[ckey]
	lobbies[ckey] = null
	lobbies.Remove(ckey)
	qdel(lobby)

/datum/deathmatch_controller/proc/passoff_lobby(host, new_host)
	lobbies[new_host] = lobbies[host]
	lobbies[host] = null
	lobbies.Remove(host)

/datum/deathmatch_controller/ui_state(mob/user)
	return GLOB.observer_state

/datum/deathmatch_controller/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, null)
	if(!ui)
		ui = new(user, src, "DeathmatchPanel")
		ui.open()

/datum/deathmatch_controller/ui_data(mob/user)
	. = ..()
	.["lobbies"] = list()
	.["hosting"] = FALSE
	.["admin"] = check_rights_for(user.client, R_ADMIN)
	var/target_ckey = user.ckey
	for(var/ckey, value in lobbies)
		var/datum/deathmatch_lobby/lobby = value
		if(target_ckey == ckey)
			.["hosting"] = TRUE
		if(target_ckey in (lobby.observers + lobby.players))
			.["playing"] = ckey
		.["lobbies"] += list(list(
			name = ckey,
			players = lobby.players.len,
			max_players = initial(lobby.map.max_players),
			map = initial(lobby.map.name),
			playing = lobby.playing
		))

/datum/deathmatch_controller/proc/find_lobby_by_user(ckey)
	for(var/lobbykey, value in lobbies)
		var/datum/deathmatch_lobby/lobby = value
		if(ckey in (lobby.players + lobby.observers))
			return lobby

/datum/deathmatch_controller/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(. || !isobserver(usr))
		return

	switch(action)
		if("host")
			if(lobbies[usr.ckey])
				return
			if(!SSticker.HasRoundStarted())
				tgui_alert(usr, "Раунд еще не начался!")
				return
			ui.close()
			create_new_lobby(usr)
		if("join")
			if(!lobbies[params["id"]])
				return
			var/datum/deathmatch_lobby/playing_lobby = find_lobby_by_user(usr.ckey)
			var/datum/deathmatch_lobby/chosen_lobby = lobbies[params["id"]]
			if(!isnull(playing_lobby) && playing_lobby != chosen_lobby)
				playing_lobby.leave(usr.ckey)

			if(isnull(playing_lobby))
				log_game("[usr.ckey] joined deathmatch lobby [params["id"]] as a player.")
				chosen_lobby.join(usr)

			chosen_lobby.ui_interact(usr)

		if("spectate")
			var/datum/deathmatch_lobby/playing_lobby = find_lobby_by_user(usr.ckey)
			if(!lobbies[params["id"]])
				return
			var/datum/deathmatch_lobby/chosen_lobby = lobbies[params["id"]]
			// if the player is in this lobby
			if(!isnull(playing_lobby) && playing_lobby != chosen_lobby)
				playing_lobby.leave(usr.ckey)
			else if(playing_lobby == chosen_lobby)
				chosen_lobby.ui_interact(usr)
				return
			// they werent in the lobby, lets add them
			if(!chosen_lobby.playing)
				chosen_lobby.add_observer(usr)
				chosen_lobby.ui_interact(usr)
			else
				chosen_lobby.spectate(usr)
			log_game("[usr.ckey] joined deathmatch lobby [params["id"]] as an observer.")
		if("admin")
			if(!check_rights(R_ADMIN))
				message_admins("[usr.key] has attempted to use admin functions in the deathmatch panel!")
				log_admin("[key_name(usr)] tried to use the deathmatch panel admin functions without authorization.")
				return
			var/lobby = params["id"]
			switch(params["func"])
				if("Закрыть лобби")
					remove_lobby(lobby)
					log_admin("[key_name(usr)] removed deathmatch lobby [lobby].")
				if("Просмотр")
					lobbies[lobby].ui_interact(usr)
