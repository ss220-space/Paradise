#define MIN_ZOOM 1
#define MAX_ZOOM 8
#define MIN_TAB_INDEX 0
#define MAX_TAB_INDEX 1

/datum/ui_module/crew_monitor
	name = "Монитор наблюдения за экипажем"
	/// The ID of the currently opened UI tab
	var/tab_index = CREW_VISION_COMMON
	/// The zoom level of the UI map view
	var/zoom = 1
	/// The X offset of the UI map
	var/offset_x = 0
	/// The Y offset of the UI map
	var/offset_y = 0
	/// A list of displayed names. Displayed names were intentionally chosen over ckeys,
	/// refs, or uids, because exposing any of the aforementioned to the client could allow
	/// an exploit to detect changelings on sensors.
	var/highlighted_names = list()

/datum/ui_module/crew_monitor/ui_act(action, params)
	if(..())
		return TRUE

	var/turf/T = get_turf(ui_host())
	if(!T || !is_level_reachable(T.z))
		to_chat(usr, span_danger("Удалённый сервер не отвечает на запросы") + ": база данных вне зоны досягаемости.")
		return FALSE

	switch(action)
		if("track")
			var/mob/living/carbon/human/human = locate(params["track"]) in GLOB.human_list
			if(isAI(usr))
				var/mob/living/silicon/ai/AI = usr
				if(hassensorlevel(human, SUIT_SENSOR_TRACKING))
					AI.ai_actual_track(human)
			if(isobserver(usr))
				var/mob/dead/observer/ghost = usr
				ghost.ManualFollow(human)
			return TRUE
		if("set_tab_index")
			var/new_tab_index = text2num(params["tab_index"])
			if(isnull(new_tab_index) || new_tab_index < MIN_TAB_INDEX || new_tab_index > MAX_TAB_INDEX)
				return
			tab_index = new_tab_index
		if("set_zoom")
			var/new_zoom = text2num(params["zoom"])
			if(isnull(new_zoom) || new_zoom < MIN_ZOOM || new_zoom > MAX_ZOOM)
				return
			zoom = new_zoom
		if("set_offset")
			var/new_offset_x = text2num(params["offset_x"])
			var/new_offset_y = text2num(params["offset_y"])
			if(isnull(new_offset_x) || isnull(new_offset_y))
				return
			offset_x = new_offset_x
			offset_y = new_offset_y
		if("add_highlighted_name")
			// Intentionally not sanitized as the name is not used for rendering
			var/name = params["name"]
			highlighted_names += list(name)
		if("remove_highlighted_name")
			// Intentionally not sanitized as the name is not used for rendering
			var/name = params["name"]
			highlighted_names -= list(name)
		if("clear_highlighted_names")
			highlighted_names = list()


/datum/ui_module/crew_monitor/ui_interact(mob/user, datum/tgui/ui = null)
	ui = SStgui.try_update_ui(user, src, ui)

	if(GLOB.communications_blackout)
		to_chat(user, span_warning("Монитор показывает странные символы. Разобрать в них что-то невозможно."))
		if(ui)
			ui.close()
		return

	if(!ui)
		ui = new(user, src, "CrewMonitor", name)
		ui.open()

/datum/ui_module/crew_monitor/ui_assets(mob/user)
	return list(
		get_asset_datum(/datum/asset/simple/nanomaps)
	)

/datum/ui_module/crew_monitor/ui_static_data(mob/user)
	var/list/static_data = list()
	var/list/station_level_numbers = list()
	var/list/station_level_names = list()
	for(var/z_level in levels_by_trait(STATION_LEVEL))
		station_level_numbers += z_level
		station_level_names += check_level_trait(z_level, STATION_LEVEL)
	static_data["stationLevelNum"] = station_level_numbers
	static_data["stationLevelName"] = station_level_names
	return static_data

/datum/ui_module/crew_monitor/ui_data(mob/user)
	var/list/data = list()
	var/turf/T = get_turf(ui_host())


	data["tabIndex"] = tab_index
	data["zoom"] = zoom
	data["offsetX"] = offset_x
	data["offsetY"] = offset_y

	data["isAI"] = isAI(user)
	data["isObserver"] = isobserver(user)
	data["crewmembers"] = GLOB.crew_repository.health_data(T)
	data["critThreshold"] = HEALTH_THRESHOLD_CRIT
	data["highlightedNames"] = highlighted_names
	switch(tab_index)
		if(CREW_VISION_COMMAND)
			data["isBS"] = 1
		if(CREW_VISION_SECURITY)
			data["isBP"] = 1
		if(CREW_VISION_MINING)
			data["isMM"] = TRUE
	return data

/datum/ui_module/crew_monitor/ghost/ui_state(mob/user)
	return GLOB.observer_state

#undef MIN_ZOOM
#undef MAX_ZOOM
#undef MIN_TAB_INDEX
#undef MAX_TAB_INDEX
