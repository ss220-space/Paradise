/obj/machinery/computer/shuttle/proc/uses_overmap_programmed_ui()
	if(!shuttleId || !GLOB.overmap_programmed_shuttle_ids[shuttleId])
		return FALSE
	var/datum/overmap_programmed_profile/profile = GLOB.overmap_programmed_profiles[shuttleId]
	return !!profile?.has_visible_legs()

/obj/machinery/computer/shuttle/proc/setup_programmed_overmap_console()
	if(!uses_overmap_programmed_ui())
		return
	GLOB.overmap_request_consoles |= src
	RegisterSignal(SSdcs, COMSIG_GLOB_OVERMAP_VESSEL_REGISTERED, PROC_REF(on_overmap_vessel_registered), override = TRUE)
	if(!overmap_cam_screen)
		var/map_name = "overmap_shuttle_[src.UID()]_map"
		overmap_cam_screen = new
		overmap_cam_screen.generate_view(map_name)
		overmap_map_camera = new(overmap_cam_screen)
		overmap_contact_blips = list()
	bind_overmap_notices()

/obj/machinery/computer/shuttle/proc/on_overmap_vessel_registered(datum/source, obj/overmap/entity/vessel)
	SIGNAL_HANDLER
	if(vessel?.shuttle?.id == shuttleId)
		bind_overmap_notices()

/obj/machinery/computer/shuttle/proc/bind_overmap_notices()
	var/obj/overmap/entity/vessel = shuttle_vessel()
	if(overmap_bound_vessel && overmap_bound_vessel != vessel)
		UnregisterSignal(overmap_bound_vessel, list(COMSIG_OVERMAP_NOTICE, COMSIG_OVERMAP_MOVED, COMSIG_OVERMAP_DISPLAY_CHANGED))
		overmap_bound_vessel = null
	if(!vessel)
		return
	overmap_bound_vessel = vessel
	RegisterSignal(vessel, COMSIG_OVERMAP_NOTICE, PROC_REF(on_overmap_notice), override = TRUE)
	RegisterSignal(vessel, COMSIG_OVERMAP_MOVED, PROC_REF(on_overmap_request_moved), override = TRUE)
	RegisterSignal(vessel, COMSIG_OVERMAP_DISPLAY_CHANGED, PROC_REF(on_overmap_display_changed), override = TRUE)

/obj/machinery/computer/shuttle/proc/on_overmap_notice(datum/source, text)
	SIGNAL_HANDLER
	if(text)
		atom_say(text)

/obj/machinery/computer/shuttle/proc/on_overmap_request_moved()
	SIGNAL_HANDLER
	update_overmap_request_map()

/obj/machinery/computer/shuttle/proc/on_overmap_display_changed()
	SIGNAL_HANDLER
	update_overmap_request_map(TRUE)
	SStgui.update_uis(src)

/obj/machinery/computer/shuttle/proc/shuttle_vessel()
	if(!shuttleId || !SSovermap)
		return null
	var/obj/docking_port/mobile/shuttle = SSshuttle.getShuttle(shuttleId)
	if(!shuttle)
		return null
	return SSovermap.get_or_register_shuttle(shuttle)

/obj/machinery/computer/shuttle/proc/update_overmap_request_map(force = FALSE)
	if(!overmap_map_camera)
		return
	var/obj/overmap/entity/vessel = shuttle_vessel()
	if(!vessel?.sector || vessel.is_overmap_jammed())
		overmap_map_camera.clear()
		overmap_last_map_turf = null
		overmap_contact_blips = overmap_paint_sensor_ghosts(null, overmap_contact_blips, null, null, null, 0, open_uis)
		return
	overmap_map_camera.refresh_rect(vessel, OVERMAP_VIEW_WIDTH, OVERMAP_VIEW_HEIGHT, force)
	overmap_map_zoom = overmap_map_camera.fit_zoom(OVERMAP_CONSOLE_MAP_PX_W, OVERMAP_CONSOLE_MAP_PX_H)
	overmap_last_map_turf = overmap_map_camera.last_center
	var/view_range = max(round((OVERMAP_VIEW_WIDTH - 1) / 2), round((OVERMAP_VIEW_HEIGHT - 1) / 2))
	overmap_contact_blips = overmap_paint_sensor_ghosts(
		vessel,
		overmap_contact_blips,
		overmap_cam_screen?.assigned_map,
		overmap_map_camera.map_view_min_x,
		overmap_map_camera.map_view_min_y,
		view_range,
		open_uis,
	)

/obj/machinery/computer/shuttle/proc/overmap_request_ui_interact(mob/user, datum/tgui/ui)
	if(!user.client)
		return
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "OvermapShuttleRemote", name)
		ui.open()
		overmap_cam_screen?.display_to(user, ui.window)
		if(ui.window)
			RegisterSignal(ui.window, COMSIG_TGUI_WINDOW_VISIBLE, PROC_REF(on_overmap_request_window_visible), override = TRUE)
	update_overmap_request_map()

/obj/machinery/computer/shuttle/proc/on_overmap_request_window_visible(datum/tgui_window/window, client/show_to)
	SIGNAL_HANDLER
	update_overmap_request_map(TRUE)
	if(show_to)
		overmap_cam_screen?.display_to(show_to.mob, window)

/obj/machinery/computer/shuttle/proc/overmap_request_ui_data(mob/user)
	var/list/data = list()
	var/obj/overmap/entity/vessel = shuttle_vessel()
	data["linked"] = !!vessel
	data["mapRef"] = overmap_cam_screen?.assigned_map
	data["map_zoom"] = overmap_map_zoom
	if(!vessel)
		return data
	vessel.fill_programmed_ui(data, params2list(possible_destinations))
	var/turf/here = vessel.get_overmap_turf()
	data["vessel_name"] = vessel.get_overmap_display_name()
	data["status"] = vessel.get_helm_status_text()
	data["x"] = vessel.sector && here ? vessel.sector.coord_x(here) : here?.x
	data["y"] = vessel.sector && here ? vessel.sector.coord_y(here) : here?.y
	data["sector_name"] = vessel.sector?.name
	data["map_jammed"] = vessel.is_overmap_jammed()
	data["map_tiles_x"] = OVERMAP_VIEW_WIDTH
	data["map_tiles_y"] = OVERMAP_VIEW_HEIGHT
	data["map_px_w"] = OVERMAP_CONSOLE_MAP_PX_W
	data["map_px_h"] = OVERMAP_CONSOLE_MAP_PX_H
	return data

/obj/machinery/computer/shuttle/proc/overmap_request_ui_act(action, list/params)
	if(length(req_access) && !allowed(usr))
		to_chat(usr, span_danger("Доступ запрещён."))
		playsound(src, SFX_BUTTON_DENIED, 20)
		return TRUE
	if(lockdown_affected && GLOB.full_lockdown)
		to_chat(usr, span_warning("Консоль заблокирована режимом полной изоляции."))
		return TRUE
	var/obj/overmap/entity/vessel = shuttle_vessel()
	if(!vessel)
		return TRUE
	if(vessel.is_programmed_emagged())
		to_chat(usr, span_warning("Шаттл слушается только штурвал."))
		return TRUE
	switch(action)
		if("select_programmed")
			vessel.programmed_selected_dock = params["id"]
			. = TRUE
		if("execute_programmed")
			var/result = vessel.start_programmed_route(params["id"] || vessel.programmed_selected_dock, FALSE, FALSE, params2list(possible_destinations))
			if(result != TRUE)
				to_chat(usr, span_warning("[result]"))
			. = TRUE

/obj/machinery/computer/shuttle/process()
	. = ..()
	if(!uses_overmap_programmed_ui())
		return
	if(shuttle_vessel())
		update_overmap_request_map()
	SStgui.update_uis(src)

/obj/machinery/computer/shuttle/mining
	name = "Mining Shuttle Console"
	desc = "Вызов и отправка шахтёрского шаттла по запрограммированному маршруту."
	circuit = /obj/item/circuitboard/mining_shuttle
	shuttleId = "mining"
	possible_destinations = "mining_home;mining_away"
	lockdown_affected = TRUE

/obj/machinery/computer/shuttle/mining/get_ru_names()
	return alist(
		NOMINATIVE = "консоль управления шахтёрским шаттлом",
		GENITIVE = "консоли управления шахтёрским шаттлом",
		DATIVE = "консоли управления шахтёрским шаттлом",
		ACCUSATIVE = "консоль управления шахтёрским шаттлом",
		INSTRUMENTAL = "консолью управления шахтёрским шаттлом",
		PREPOSITIONAL = "консоли управления шахтёрским шаттлом",
	)

/obj/machinery/computer/shuttle/labor
	name = "labor shuttle console"
	desc = "Вызов и отправка шаттла каторги. Станция и Лаваленд."
	circuit = /obj/item/circuitboard/labor_shuttle
	shuttleId = "laborcamp"
	possible_destinations = "laborcamp_home;laborcamp_away"
	lockdown_affected = TRUE
	req_access = list(ACCESS_BRIG)

/obj/machinery/computer/shuttle/labor/get_ru_names()
	return alist(
		NOMINATIVE = "консоль управления шаттлом каторги",
		GENITIVE = "консоли управления шаттлом каторги",
		DATIVE = "консоли управления шаттлом каторги",
		ACCUSATIVE = "консоль управления шаттлом каторги",
		INSTRUMENTAL = "консолью управления шаттлом каторги",
		PREPOSITIONAL = "консоли управления шаттлом каторги",
	)

/obj/machinery/computer/shuttle/labor/one_way
	name = "prisoner shuttle console"
	desc = "Консоль шаттла каторги без требования доступа. Можно вызвать на станцию и отправить на Лаваленд."
	circuit = /obj/item/circuitboard/labor_shuttle/one_way
	req_access = list()
	lockdown_affected = FALSE

/obj/machinery/computer/shuttle/labor/one_way/get_ru_names()
	return alist(
		NOMINATIVE = "консоль управления заключёнными каторги",
		GENITIVE = "консоли управления заключёнными каторги",
		DATIVE = "консоли управления заключёнными каторги",
		ACCUSATIVE = "консоль управления заключёнными каторги",
		INSTRUMENTAL = "консолью управления заключёнными каторги",
		PREPOSITIONAL = "консоли управления заключёнными каторги",
	)

/obj/machinery/computer/navmap
	name = "overmap monitor"
	desc = "Настенный пассивный монитор овермапы. Управление курсом недоступно."
	icon_state = "telescreen_console"
	icon_keyboard = null
	icon_screen = "telescreen"
	density = FALSE
	light_color = LIGHT_COLOR_CYAN
	circuit = /obj/item/circuitboard/navmap
	var/obj/overmap/entity/vessel
	var/atom/movable/screen/map_view/camera/cam_screen
	var/datum/overmap_map_view/map_camera
	var/turf/last_map_turf
	var/map_zoom = 1
	var/list/atom/movable/screen/overmap_sensor_blip/contact_blips

/obj/machinery/computer/navmap/get_ru_names()
	return alist(
		NOMINATIVE = "монитор овермапы",
		GENITIVE = "монитора овермапы",
		DATIVE = "монитору овермапы",
		ACCUSATIVE = "монитор овермапы",
		INSTRUMENTAL = "монитором овермапы",
		PREPOSITIONAL = "мониторе овермапы",
	)

/obj/machinery/computer/navmap/Initialize(mapload)
	. = ..()
	GLOB.navmap_computers += src
	if(!pixel_x && !pixel_y)
		set_pixel_offsets_from_dir(32, -32, 32, -32)
	var/map_name = "overmap_monitor_[src.UID()]_map"
	cam_screen = new
	cam_screen.generate_view(map_name)
	map_camera = new(cam_screen)
	contact_blips = list()
	if(SSovermap?.initialized)
		link_vessel()

/obj/machinery/computer/navmap/Destroy()
	GLOB.navmap_computers -= src
	if(vessel)
		UnregisterSignal(vessel, list(COMSIG_OVERMAP_MOVED, COMSIG_OVERMAP_DISPLAY_CHANGED))
	vessel = null
	QDEL_LIST(contact_blips)
	QDEL_NULL(map_camera)
	QDEL_NULL(cam_screen)
	return ..()

/obj/machinery/computer/navmap/proc/link_vessel()
	var/obj/overmap/entity/resolved = SSovermap?.resolve_vessel(src)
	if(vessel && vessel != resolved)
		UnregisterSignal(vessel, list(COMSIG_OVERMAP_MOVED, COMSIG_OVERMAP_DISPLAY_CHANGED))
	vessel = resolved
	if(vessel)
		RegisterSignal(vessel, COMSIG_OVERMAP_MOVED, PROC_REF(on_overmap_moved), override = TRUE)
		RegisterSignal(vessel, COMSIG_OVERMAP_DISPLAY_CHANGED, PROC_REF(on_overmap_display_changed), override = TRUE)
	update_map_view()

/obj/machinery/computer/navmap/proc/on_overmap_moved()
	SIGNAL_HANDLER
	update_map_view()

/obj/machinery/computer/navmap/proc/on_overmap_display_changed()
	SIGNAL_HANDLER
	update_map_view(TRUE)
	SStgui.update_uis(src)

/obj/machinery/computer/navmap/proc/update_map_view(force = FALSE)
	if(!map_camera)
		return
	if(!vessel?.sector || vessel.is_overmap_jammed())
		map_camera.clear()
		last_map_turf = null
		contact_blips = overmap_paint_sensor_ghosts(null, contact_blips, null, null, null, 0, open_uis)
		return
	map_camera.refresh_rect(vessel, OVERMAP_VIEW_WIDTH, OVERMAP_VIEW_HEIGHT, force)
	map_zoom = map_camera.fit_zoom(OVERMAP_CONSOLE_MAP_PX_W, OVERMAP_CONSOLE_MAP_PX_H)
	last_map_turf = map_camera.last_center
	var/view_range = max(round((OVERMAP_VIEW_WIDTH - 1) / 2), round((OVERMAP_VIEW_HEIGHT - 1) / 2))
	contact_blips = overmap_paint_sensor_ghosts(
		vessel,
		contact_blips,
		cam_screen?.assigned_map,
		map_camera.map_view_min_x,
		map_camera.map_view_min_y,
		view_range,
		open_uis,
	)

/obj/machinery/computer/navmap/attack_hand(mob/user)
	if(..())
		return
	ui_interact(user)

/obj/machinery/computer/navmap/attack_ai(mob/user)
	ui_interact(user)

/obj/machinery/computer/navmap/ui_interact(mob/user, datum/tgui/ui = null)
	if(!user.client)
		return
	if(!vessel)
		link_vessel()
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "OvermapMonitor", name)
		ui.open()
		cam_screen.display_to(user, ui.window)
		if(ui.window)
			RegisterSignal(ui.window, COMSIG_TGUI_WINDOW_VISIBLE, PROC_REF(on_monitor_window_visible), override = TRUE)
	update_map_view()

/obj/machinery/computer/navmap/proc/on_monitor_window_visible(datum/tgui_window/window, client/show_to)
	SIGNAL_HANDLER
	update_map_view(TRUE)
	if(show_to)
		cam_screen.display_to(show_to.mob, window)

/obj/machinery/computer/navmap/ui_close(mob/user)
	. = ..()
	cam_screen?.hide_from(user)

/obj/machinery/computer/navmap/ui_status(mob/user, datum/ui_state/state)
	if(stat & (NOPOWER|BROKEN))
		return UI_CLOSE
	if(user.incapacitated())
		return UI_CLOSE
	if(!user.Adjacent(src) && !user.has_unlimited_silicon_privilege)
		return UI_CLOSE
	return UI_INTERACTIVE

/obj/machinery/computer/navmap/ui_data(mob/user)
	var/list/data = list()
	data["linked"] = !!vessel
	data["mapRef"] = cam_screen?.assigned_map
	data["map_zoom"] = map_zoom
	if(!vessel)
		return data
	var/turf/here = vessel.get_overmap_turf()
	data["vessel_name"] = vessel.get_overmap_display_name()
	data["status"] = vessel.get_helm_status_text()
	data["x"] = vessel.sector && here ? vessel.sector.coord_x(here) : here?.x
	data["y"] = vessel.sector && here ? vessel.sector.coord_y(here) : here?.y
	data["sector_name"] = vessel.sector?.name
	data["map_jammed"] = vessel.is_overmap_jammed()
	data["map_tiles_x"] = OVERMAP_VIEW_WIDTH
	data["map_tiles_y"] = OVERMAP_VIEW_HEIGHT
	data["map_px_w"] = OVERMAP_CONSOLE_MAP_PX_W
	data["map_px_h"] = OVERMAP_CONSOLE_MAP_PX_H
	return data

/obj/machinery/computer/navmap/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	if(..())
		return
	if(action == "relink")
		link_vessel()
		. = TRUE

/obj/machinery/computer/navmap/process()
	if(..())
		if(!vessel)
			link_vessel()
		else
			update_map_view()
		SStgui.update_uis(src)
