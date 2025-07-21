#define MIN_ZOOM 1
#define MAX_ZOOM 8
#define MIN_TAB_INDEX 0
#define MAX_TAB_INDEX 1

/datum/ui_module/sat_control
	name = "Управление спутниками"
	/// A notice to display to the user.
	var/notice = ""
	/// The color to use for the notice.
	var/notice_color = "white"
	/// Before world.time reaches this, the notice will not automatically update to show the testing status.
	var/freeze_notice_until = 0
	/// The X offset of the UI map
	var/offset_x = 0
	/// The Y offset of the UI map
	var/offset_y = 0
	/// The zoom of the UI map
	var/zoom = 1
	/// The ID of the currently opened UI tab
	var/tab_index = 0
	/// What are we in
	var/obj/object

/datum/ui_module/sat_control/ui_state(mob/user)
	return GLOB.default_state

/datum/ui_module/sat_control/ui_interact(mob/user, datum/tgui/ui = null)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "SatelliteControl", name)
		ui.open()

/datum/ui_module/sat_control/ui_assets(mob/user)
	return list(
		get_asset_datum(/datum/asset/simple/nanomaps)
	)

/datum/ui_module/sat_control/ui_data(mob/user)
	var/turf/obj_turf = get_turf(object)
	if(!obj_turf)
		log_runtime(EXCEPTION("No turf found underneath [object]."), src)
		return
	var/list/z_list = list()
	for(var/z in SSmapping.get_connected_levels(obj_turf))
		z_list += z

	var/list/data = list()

	data["satellites"] = list()
	for(var/obj/machinery/satellite/meteor_shield/sat in SSmachines.get_by_type(/obj/machinery/satellite))
		var/turf/sat_turf = get_turf(sat)
		if(!LAZYIN(z_list, sat_turf.z))
			continue
		else
			data["satellites"] += list(list(
				"id" = sat.id,
				"active" = sat.active,
				"mode" = sat.mode,
				"kill_range" = sat.kill_range,
				"x" = sat_turf.x,
				"y" = sat_turf.y,
				"z" = sat_turf.z,
			))
	update_notice()
	data["notice"] = notice
	data["notice_color"] = notice_color
	data["zoom"] = zoom
	data["offsetX"] = offset_x
	data["offsetY"] = offset_y
	data["tabIndex"] = tab_index


	var/datum/station_goal/station_shield/goal = locate() in SSticker.mode?.station_goals
	if(goal)
		data["coverage"] = goal.last_coverage
		data["coverage_goal"] = goal.coverage_goal
		data["max_meteor"] = goal.max_meteor
		data["testing"] = goal.is_testing
		data["thrown"] = goal.thrown
		data["defended"] = goal.defended
		data["collisions"] = goal.collisions
		var/list/fake_meteors = list()
		if(goal.is_testing)
			for(var/obj/effect/meteor/fake/meteor in GLOB.meteor_list)
				fake_meteors += list(list("x" = meteor.x, "y" = meteor.y, "z" = meteor.z))
		data["fake_meteors"] = fake_meteors
	data["has_goal"] = !!goal
	return data

/datum/ui_module/sat_control/ui_static_data(mob/user)
	var/list/static_data = list()
	var/list/station_level_numbers = list()
	var/list/station_level_names = list()
	for(var/z_level in levels_by_trait(STATION_LEVEL))
		station_level_numbers += z_level
		station_level_names += check_level_trait(z_level, STATION_LEVEL)
	static_data["stationLevelNum"] = station_level_numbers
	static_data["stationLevelName"] = station_level_names
	return static_data

/datum/ui_module/sat_control/ui_act(action, params)
	if(..())
		return

	switch(action)
		if("begin_test")
			var/datum/station_goal/station_shield/goal = locate() in SSticker.mode?.station_goals
			if(goal)
				goal.simulate_meteors()
		if("toggle")
			toggle(text2num(params["id"]))
			. = TRUE
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

/datum/ui_module/sat_control/proc/toggle(id)
	for(var/obj/machinery/satellite/sat in SSmachines.get_by_type(/obj/machinery/satellite))
		if(!(sat.id == id && are_zs_connected(object, sat)))
			continue

		if(sat.toggle())
			continue

		notice = "Вы можете активировать только спутники, находящиеся в космосе."
		notice_color = "red"
		freeze_notice_until = world.time + 5 SECONDS
		return

/datum/ui_module/sat_control/proc/update_notice()
	var/datum/station_goal/station_shield/goal = locate() in SSticker.mode?.station_goals
	if(!goal)
		return
	if(freeze_notice_until >= world.time)
		return

	if(goal.is_testing && goal.thrown < goal.max_meteor)
		notice = "Идёт симуляция метеорного шторма ([goal.thrown]/[goal.max_meteor])..."
		notice_color = "white"
		return

	var/total_meteors = length(goal.defended) + length(goal.collisions)
	if(total_meteors == 0)
		notice = "Симуляция не активирована."
		notice_color = "red"
		return

	if(goal.is_testing)
		notice = "Завершение симуляции метеорного шторма ([total_meteors]/[goal.max_meteor])..."
		notice_color = "white"
		return

	notice = "Симуляция завершена. [goal.max_meteor - goal.last_coverage] столкновений из [goal.max_meteor] метеоров. [goal.goal_completed ? ((goal.last_coverage > goal.coverage_goal) ? "Цель выполнена." : "Цель выполнена, но текущая симуляция провалена.") : "Симуляция провалена."]"
	notice_color = (goal.last_coverage > goal.coverage_goal) ? "blue" : "red"

/datum/ui_module/sat_control/Destroy(force)
	. = ..()
	tab_index = 0
	object = null

#undef MIN_ZOOM
#undef MAX_ZOOM
#undef MIN_TAB_INDEX
#undef MAX_TAB_INDEX
