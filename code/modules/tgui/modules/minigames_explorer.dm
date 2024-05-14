/datum/minigames_explorer
	var/mob/dead/observer/owner

/datum/minigames_explorer/New(mob/dead/observer/new_owner)
	if(!istype(new_owner))
		qdel(src)
	owner = new_owner

/datum/minigames_explorer/ui_interact(mob/user, ui_key = "main", datum/tgui/ui = null, force_open = FALSE, datum/ui_state/state = GLOB.observer_state, datum/tgui/master_ui = null)
	ui = SStgui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "MiniGamesMenu", "Mini Games", 700, 600, master_ui, state = state)
		ui.open()

/datum/minigames_explorer/ui_data(mob/user)
	var/list/data = list()
	data["spawners"] = list()
	data["thunderdome_eligible"] = (ROLE_THUNDERDOME in owner.client?.prefs?.be_special)
	data["notifications_enabled"] = owner.client?.prefs?.minigames_notifications
	for(var/mini_game in GLOB.mini_games)
		var/list/this = list()
		this["name"] = mini_game
		this["desc"] = ""
		this["important_info"] = ""
		this["fluff"] = ""
		this["uids"] = list()
		for(var/minigame_obj in GLOB.mini_games[mini_game]) //each mini_game can contain multiple actual spawners, we use only one desc/info
			this["uids"] += "\ref[minigame_obj]"
			if(!this["desc"])	//haven't set descriptions yet
				var/obj/O = minigame_obj
				this["desc"] = O.desc
		this["amount_left"] = LAZYLEN(GLOB.mini_games[mini_game])
		data["spawners"] += list(this)
	return data

/datum/minigames_explorer/ui_act(action, params)
	if(..())
		return
	switch(action)
		if("toggle_minigames")
			if(jobban_isbanned(owner, ROLE_THUNDERDOME))
				return
			if(ROLE_THUNDERDOME in GLOB.special_roles)
				owner.client?.prefs?.be_special ^= ROLE_THUNDERDOME
				if(CONFIG_GET(flag/sql_enabled))
					owner.client?.prefs?.save_preferences(owner.client)
				return

		if("toggle_notifications")
			owner.client?.prefs?.minigames_notifications = !owner.client?.prefs?.minigames_notifications
			return

	var/spawners = replacetext(params["ID"], ",", ";")
	var/list/possible_spawners = params2list(spawners)
	var/obj/MS = locate(pick(possible_spawners))
	if(!MS || !MS.is_mob_spawnable())
		log_runtime(EXCEPTION("A ghost tried to interact with an invalid mini_game, or the mini_game didn't exist."))
		return
	switch(action)
		if("jump")
			owner.forceMove(get_turf(MS))
			. = TRUE
		if("spawn")
			MS.attack_ghost(owner)
			. = TRUE
