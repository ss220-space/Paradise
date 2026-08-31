/obj/machinery/computer/helm/attack_hand(mob/user)
	if(stat & (BROKEN|NOPOWER))
		return
	if(..())
		return TRUE
	add_fingerprint(user)
	ui_interact(user)

/obj/machinery/computer/helm/attack_ai(mob/user)
	attack_hand(user)

/obj/machinery/computer/helm/ui_interact(mob/user, datum/tgui/ui = null)
	if(!user.client)
		return
	link_vessel()
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "OvermapHelm", name)
		ui.open()
		cam_screen.display_to(user, ui.window)
		if(ui.window)
			RegisterSignal(ui.window, COMSIG_TGUI_WINDOW_VISIBLE, PROC_REF(on_helm_window_visible), override = TRUE)
	update_map_view()
	register_map_overlays(user)

/obj/machinery/computer/helm/proc/on_helm_window_visible(datum/tgui_window/window, client/show_to)
	SIGNAL_HANDLER
	update_map_view(TRUE)
	if(show_to?.mob)
		register_map_overlays(show_to.mob)

/obj/machinery/computer/helm/ui_close(mob/user)
	. = ..()
	cam_screen?.hide_from(user)
	if(viewing_overmap(user))
		unlook(user)

/obj/machinery/computer/helm/ui_status(mob/user, datum/ui_state/state)
	if(stat & (NOPOWER|BROKEN))
		return UI_CLOSE
	if(user.incapacitated())
		return UI_CLOSE
	if(!user.Adjacent(src) && !user.has_unlimited_silicon_privilege)
		return UI_CLOSE
	return UI_INTERACTIVE

/obj/machinery/computer/helm/ui_data(mob/user)
	var/list/data = list()
	data["linked"] = !!vessel
	data["mapRef"] = cam_screen?.assigned_map
	if(!vessel)
		return data

	var/turf/here = vessel.get_overmap_turf()
	data["vessel_name"] = vessel.get_overmap_display_name()
	data["vessel_kind"] = vessel.overmap_kind
	data["status"] = vessel.get_helm_status_text()
	data["docked_to"] = vessel.docked_to?.name
	data["x"] = vessel.sector && here ? vessel.sector.coord_x(here) : here?.x
	data["y"] = vessel.sector && here ? vessel.sector.coord_y(here) : here?.y
	data["sector_name"] = vessel.sector?.name
	data["sector_size"] = vessel.sector?.size || OVERMAP_DEFAULT_SIZE
	var/speed = vessel.get_speed()
	data["speed"] = round(OVERMAP_DISPLAY_SPEED(speed), 0.01)
	data["speed_slow"] = speed < SHIP_SPEED_SLOW
	data["speed_fast"] = speed > SHIP_SPEED_FAST
	data["heading"] = vessel.get_heading_angle()
	data["accel"] = round(OVERMAP_DISPLAY_SPEED(vessel.get_effective_acceleration()), 0.01)
	var/datum/component/overmap_flight/nav = vessel.flight
	data["stick_x"] = nav?.held_thrust_nx
	data["stick_y"] = nav?.held_thrust_ny
	data["stick_power"] = round((nav?.held_thrust_power || 0) * 100)
	data["can_steer"] = vessel.can_steer() && !vessel.is_overmap_jammed() && !vessel.is_programmed_locked()
	data["autopilot"] = !!nav?.autopilot
	data["dest_x"] = nav?.autopilot_x
	data["dest_y"] = nav?.autopilot_y
	data["max_speed"] = round(OVERMAP_DISPLAY_SPEED(nav?.cruise_speed || 0), 0.1)
	data["engines_on"] = !!nav?.engines_state
	data["thrusting"] = nav?.held_thrust_dir
	data["braking"] = !!nav?.held_brake
	data["thrust"] = vessel.get_total_thrust()
	data["mass"] = vessel.vessel_mass
	data["inspecting"] = viewing_overmap(user)
	data["map_zoom"] = map_zoom
	data["eta"] = speed ? "[round(vessel.ETA() / 10)] с" : "N/A"
	data["dest_range"] = null
	data["dest_bearing"] = null
	if(nav?.autopilot_x && nav.autopilot_y && here)
		var/here_x = vessel.sector ? vessel.sector.coord_x(here) : here.x
		var/here_y = vessel.sector ? vessel.sector.coord_y(here) : here.y
		data["dest_range"] = max(abs(here_x - nav.autopilot_x), abs(here_y - nav.autopilot_y))
		var/dx = nav.autopilot_x - here_x
		var/dy = nav.autopilot_y - here_y
		if(dx || dy)
			data["dest_bearing"] = (round(ATAN2(dx, -dy), 1) + 450) % 360
	data["is_shuttle"] = !!vessel.overmap_shuttle
	data["is_pod"] = !!vessel.overmap_pod
	data["can_undock"] = vessel.can_helm_undock()
	data["can_physical_dock"] = vessel.can_helm_physical_dock()
	data["can_edge_dock"] = vessel.can_helm_edge_dock()
	data["can_custom_dock"] = vessel.can_helm_custom_dock()
	data["docks"] = vessel.build_dock_list()
	data["collars"] = vessel.build_collar_list()
	data["shuttle_mode"] = vessel.get_shuttle_phase_text()
	data["selected_dock"] = vessel.selected_dock_id || vessel.last_dock_id
	for(var/list/pad as anything in data["docks"])
		if(pad["selected"] || pad["id"] == data["selected_dock"])
			data["selected_dock"] = pad["name"]
			break
	data["at_station"] = !!vessel.get_dock_host()
	data["host_name"] = vessel.get_dock_host()?.name
	data["distress"] = !!vessel.transponder?.distress
	data["broadcasting"] = !!vessel.transponder?.is_transmitting()
	var/pads = data["docks"]
	var/pad_free = 0
	for(var/list/pad as anything in pads)
		if(pad["can_dock"])
			pad_free++
	data["pad_total"] = length(pads)
	data["pad_free"] = pad_free
	data["near_planet"] = FALSE
	if(!data["at_station"] && SSovermap.lavaland_planet?.covers_turf(here))
		data["near_planet"] = TRUE

	var/obj/overmap/portal/portal = here ? locate(/obj/overmap/portal) in here : null
	data["can_portal"] = !!portal && !vessel.overmap_pod && (vessel.status == OVERMAP_STATUS_OVERMAP || vessel.status == OVERMAP_STATUS_TRANSIT) && !vessel.is_moving() && !vessel.is_overmap_jammed()
	data["can_hyperrelay"] = vessel.can_hyperrelay_jump()
	data["dock_name"] = portal?.name
	if(!portal)
		var/obj/overmap/entity/hyperrelay/relay = vessel.hyperrelay_on_tile()
		if(relay && vessel.contact_identified(relay))
			data["dock_name"] = "Гипертранслятор"
	data["map_jammed"] = vessel.is_overmap_jammed()

	var/list/objects = list()
	var/view_range = map_view_range()
	if(vessel.sector)
		for(var/obj/overmap/overmap_object as anything in vessel.sector.objects)
			var/turf/object_turf = overmap_object.get_overmap_turf()
			if(!object_turf)
				continue
			if(here && max(abs(here.x - object_turf.x), abs(here.y - object_turf.y)) > view_range)
				continue
			var/is_self = overmap_object == vessel
			if(!is_self && !vessel.senses_object(overmap_object))
				continue
			if(!is_self && overmap_object.hidden_from_contacts)
				continue
			var/identified = vessel.display_identified(overmap_object)
			var/obj/overmap/entity/contact = overmap_object
			var/is_entity = istype(contact)
			objects += list(list(
				"name" = is_self || identified ? overmap_object.get_overmap_display_name() : OVERMAP_UNKNOWN_NAME,
				"kind" = identified || is_self ? overmap_object.overmap_kind : "unknown",
				"x" = vessel.sector.coord_x(object_turf),
				"y" = vessel.sector.coord_y(object_turf),
				"color" = identified ? overmap_object.map_color : "#fffffe",
				"is_self" = is_self,
				"nested" = !isturf(overmap_object.loc),
				"speed" = round(OVERMAP_DISPLAY_SPEED(overmap_object.get_speed()), 0.01),
				"heading" = overmap_object.get_heading_angle(),
				"status" = is_entity ? contact.get_helm_status_text() : overmap_object.overmap_kind,
				"distress" = is_entity && contact.transponder?.distress,
				"identified" = identified || is_self,
				"docked_to" = is_entity ? contact.docked_to?.name : null,
			))
	data["objects"] = objects
	var/list/saved_waypoints = list()
	for(var/waypoint_name in preset_waypoints)
		saved_waypoints += list(list(
			"name" = waypoint_name,
			"x" = preset_waypoints[waypoint_name]["x"],
			"y" = preset_waypoints[waypoint_name]["y"],
		))
	for(var/waypoint_name in waypoints)
		saved_waypoints += list(list(
			"name" = waypoint_name,
			"x" = waypoints[waypoint_name]["x"],
			"y" = waypoints[waypoint_name]["y"],
		))
	data["waypoints"] = saved_waypoints
	vessel.fill_programmed_ui(data)
	return data

/obj/machinery/computer/helm/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	if(..())
		return
	if(!vessel)
		link_vessel()
		if(!vessel)
			return TRUE

	if(vessel.is_programmed_locked() && !(action in list("select_programmed", "execute_programmed", "relink", "helm_tab")))
		to_chat(usr, span_warning("Прямое управление заблокировано поставщиком услуг."))
		return TRUE

	switch(action)
		if("select_programmed")
			vessel.programmed_selected_dock = params["id"]
			. = TRUE
		if("execute_programmed")
			var/result = vessel.start_programmed_route(params["id"] || vessel.programmed_selected_dock)
			if(result != TRUE)
				to_chat(usr, span_warning("[result]"))
			. = TRUE
		if("thrust")
			var/direction = text2num(params["dir"])
			if(direction && !vessel.set_held_thrust(direction))
				to_chat(usr, span_warning("Судно не может маневрировать."))
			. = TRUE
		if("stick")
			if(!vessel.set_held_vector(params["x"], params["y"], params["power"]))
				to_chat(usr, span_warning("Судно не может маневрировать."))
			return FALSE
		if("brake")
			if(!vessel.set_held_brake(!vessel.flight?.held_brake))
				to_chat(usr, span_warning("Невозможно тормозить."))
			. = TRUE
		if("cut_engines")
			vessel.cut_engines()
			. = TRUE
		if("set_dest")
			var/dest_x = text2num(params["x"])
			var/dest_y = text2num(params["y"])
			if(dest_x && dest_y)
				if(vessel.sector)
					dest_x = clamp(dest_x, 1, vessel.sector.size)
					dest_y = clamp(dest_y, 1, vessel.sector.size)
				vessel.set_autopilot(vessel.flight?.autopilot, dest_x, dest_y)
				update_nav_marker()
			. = TRUE
		if("toggle_autopilot")
			if(!vessel.flight?.autopilot_x || !vessel.flight.autopilot_y)
				to_chat(usr, span_warning("Нет установленной цели автопилота."))
			else
				var/turf/here = vessel.get_overmap_turf()
				var/turf/mark = vessel.sector?.get_turf_at(vessel.flight.autopilot_x, vessel.flight.autopilot_y)
				if(!vessel.flight.autopilot && here && mark && here == mark)
					to_chat(usr, span_warning("Установленная цель уже достигнута."))
				else
					vessel.set_autopilot(!vessel.flight.autopilot, vessel.flight.autopilot_x, vessel.flight.autopilot_y)
			. = TRUE
		if("set_max_speed")
			if(vessel.flight)
				vessel.flight.cruise_speed = OVERMAP_FROM_DISPLAY(clamp(text2num(params["value"]), OVERMAP_CRUISE_MIN, OVERMAP_CRUISE_MAX))
			. = TRUE
		if("inspect")
			if(vessel.is_overmap_jammed())
				to_chat(usr, span_warning("Потеря сигнала."))
			else if(viewing_overmap(usr))
				unlook(usr)
			else
				look(usr)
			. = TRUE
		if("remove_waypoint")
			var/waypoint_name = params["name"]
			waypoints -= waypoint_name
			. = TRUE
		if("undock")
			var/undock_result = vessel.begin_physical_undock()
			if(undock_result != TRUE)
				to_chat(usr, span_warning("[undock_result]"))
			else if(vessel.overmap_pod)
				to_chat(usr, span_notice("Челнок выходит в гиперпространство."))
				update_map_view()
			else
				to_chat(usr, span_notice("Шаттл выходит в гиперпространство."))
				update_map_view()
			. = TRUE
		if("dock")
			var/dock_result = vessel.begin_physical_dock()
			if(dock_result == OVERMAP_DOCK_NEED_CUSTOM_PICK)
				if(!open_custom_dock_picker(usr))
					to_chat(usr, span_warning("Произвольная точка недоступна."))
				else
					to_chat(usr, span_notice("Отметьте произвольную точку на [vessel.get_dock_host()?.name || "объекте"]."))
			else if(dock_result != TRUE)
				to_chat(usr, span_warning("[dock_result]"))
			else if(vessel.overmap_pod)
				to_chat(usr, span_notice("Челнок выходит из гиперпространства."))
			else
				to_chat(usr, span_notice("Стыковка начата. Шаттл направляется к выбранной площадке."))
			. = TRUE
		if("dock_edge")
			if(!vessel.overmap_pod)
				to_chat(usr, span_warning("Судно слишком большое для такого манёвра."))
			else
				vessel.set_selected_pad(OVERMAP_DOCK_ID_EDGE)
				var/edge_result = vessel.overmap_pod.begin_dock(TRUE)
				if(edge_result != TRUE)
					to_chat(usr, span_warning("[edge_result]"))
				else
					to_chat(usr, span_notice("Челнок выходит к краю сектора объекта."))
			. = TRUE
		if("select_dock")
			if(!vessel.set_selected_pad(params["id"]))
				to_chat(usr, span_warning("Нельзя выбрать эту площадку."))
			else if(params["id"] == OVERMAP_DOCK_ID_CUSTOM && !vessel.get_custom_dock(vessel.get_dock_host()))
				open_custom_dock_picker(usr)
			update_map_view(TRUE)
			. = TRUE
		if("select_collar")
			if(!vessel.set_selected_collar(params["id"]))
				to_chat(usr, span_warning("Этот шлюз недоступен."))
			update_map_view(TRUE)
			. = TRUE
		if("helm_tab")
			helm_tab = (params["tab"] == "dock") ? "dock" : "flight"
			update_map_view(TRUE)
			. = TRUE
		if("pick_custom_dock")
			if(!open_custom_dock_picker(usr))
				. = TRUE
			else
				vessel.set_selected_pad(OVERMAP_DOCK_ID_CUSTOM)
			. = TRUE
		if("portal")
			var/turf/here = vessel.get_overmap_turf()
			var/obj/overmap/portal/portal = here ? locate(/obj/overmap/portal) in here : null
			var/result
			if(portal)
				result = vessel.dock_with(portal)
			else
				result = vessel.begin_hyperrelay_jump()
			if(result != TRUE)
				to_chat(usr, span_warning(portal ? "[result]" : "Прыжок недоступен."))
			else if(portal)
				to_chat(usr, span_notice("Прыжок через гипертранслятор выполнен."))
			update_map_view(TRUE)
			. = TRUE
		if("relink")
			link_vessel()
			. = TRUE

/obj/machinery/computer/helm/emag_act(mob/user)
	if(!vessel)
		link_vessel()
	if(!vessel?.programmed)
		return
	if(vessel.emag_programmed(user))
		if(user)
			to_chat(user, span_notice("Навигационные ограничители сняты."))
		return TRUE

/obj/machinery/computer/helm/process()
	if(..())
		if(vessel)
			var/turf/here = vessel.get_overmap_turf()
			if(here != last_map_turf)
				update_map_view()
			else if(length(viewers))
				refresh_inspect_positions()
			if(vessel.is_moving())
				sync_inspect_camera_pixels()
		SStgui.update_uis(src)
