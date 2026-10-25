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
	vessel?.watch_radar(ui)

/obj/machinery/computer/helm/ui_close(mob/user)
	. = ..()
	if(!vessel?.overmap_pod && vessel?.flight?.pilot == user)
		vessel.flight.release_pilot()

/obj/machinery/computer/helm/ui_data(mob/user)
	overmap_watch_radar(src, user, vessel)
	var/list/data = list()
	data["linked"] = !!vessel
	if(!vessel)
		return data

	var/turf/here = vessel.get_overmap_turf()
	data["vessel_name"] = vessel.get_overmap_display_name()
	data["vessel_kind"] = vessel.overmap_kind
	data["weapons"] = weapon_data()
	data["status"] = vessel.get_helm_status_text()
	data["docked_to"] = vessel.docked_to?.name
	data["x"] = vessel.sector && here ? vessel.sector.coord_x(here) : here?.x
	data["y"] = vessel.sector && here ? vessel.sector.coord_y(here) : here?.y
	data["sector_name"] = vessel.sector?.name
	data["sector_size"] = vessel.sector?.size || OVERMAP_DEFAULT_SIZE

	data["cell_span"] = OVERMAP_TILE_SPAN * (vessel.sector?.tile_travel || 1)
	if(vessel.sector && here)
		data["self_pos"] = list(vessel.sector.coord_x(here) + vessel.position[1], vessel.sector.coord_y(here) + vessel.position[2])
	var/speed = vessel.get_speed()
	data["speed"] = round(OVERMAP_DISPLAY_SPEED(speed), 0.01)
	data["heading"] = vessel.get_heading_angle()
	data["facing"] = round(vessel.flight?.facing || 0)
	data["phase"] = flight_phase()
	data["piloting"] = vessel.flight?.pilot == user
	data["pilot_name"] = vessel.flight?.pilot?.name
	data["ship_docked_to"] = vessel.docked_ship?.get_overmap_display_name()
	data["ship_guests"] = length(vessel.docked_guests)
	data["can_jump"] = vessel.in_free_flight()
	data["local_space"] = !!vessel.local_space
	if(vessel.jump_spool_end)
		data["jump_left"] = round((vessel.jump_spool_end - world.time) / (1 SECONDS))
		data["jump_progress"] = round(100 * (1 - (vessel.jump_spool_end - world.time) / OVERMAP_JUMP_SPOOL))
		data["jump_spooling"] = TRUE
	else if(vessel.jump_start_time)
		data["jump_left"] = round((vessel.jump_start_time + vessel.jump_duration - world.time) / (1 SECONDS))
		data["jump_progress"] = round(100 * (world.time - vessel.jump_start_time) / vessel.jump_duration)
	data["radar_enabled"] = !!vessel.sector
	data["radar_reach"] = radar_reach
	data["accel"] = round(OVERMAP_DISPLAY_SPEED(vessel.get_effective_acceleration()), 0.01)
	var/datum/component/overmap_flight/nav = vessel.flight
	data["can_steer"] = vessel.can_steer() && !vessel.is_overmap_jammed() && !vessel.is_programmed_locked()
	data["autopilot"] = !!nav?.autopilot
	data["matching_velocity"] = !!nav?.matching_velocity
	data["navigation_target"] = nav?.navigation_target?.get_overmap_display_name()
	data["navigation_target_id"] = nav?.navigation_target?.UID()
	data["programmed_cancellable"] = !!vessel.programmed_mission?.cancellable
	data["max_speed"] = round(OVERMAP_DISPLAY_SPEED(nav ? (nav.navigation_speed_limited() ? nav.get_effective_cruise() : nav.cruise_speed) : 0), 0.1)
	data["engines_on"] = !!nav?.engines_state
	data["braking"] = !!nav?.held_brake
	data["thrust"] = vessel.get_total_thrust()
	data["mass"] = vessel.vessel_mass
	data["thrust_limit"] = round((nav?.thrust_limit || 0) * 100)
	if(nav)
		data["dampeners"] = nav.dampeners
		data["angular_dampeners"] = nav.angular_dampeners

		data["thrust_sides"] = list(
			nav.side_accel(nav.side_thrust(NORTH)),
			nav.side_accel(nav.side_thrust(EAST)),
			nav.side_accel(nav.side_thrust(SOUTH)),
			nav.side_accel(nav.side_thrust(WEST)),
		)
		data["turn_accel"] = round(nav.angular_accel(min(nav.torque_left, nav.torque_right)) * (1 SECONDS) * (1 SECONDS), 0.1)
		data["top_speed"] = round(OVERMAP_DISPLAY_SPEED(nav.top_speed()), 0.1)
		data["omni_thrust"] = nav.omni_thrust
		data["autopilot_status"] = nav.autopilot ? nav.autopilot_status : ""
		data["avoid_obstacles"] = nav.avoid_obstacles
		data["avoiding"] = length(nav.navigation?.path) > 1
		data["eta"] = vessel.autopilot_eta()
	data["power"] = vessel.ship_power_report()
	data["thrust_hint"] = vessel.thrust_diagnosis()

	data["sector_id"] = vessel.sector?.id

	data["sensor_short"] = vessel.has_working_sensor(OVERMAP_SENSOR_KIND_SHORT) && vessel.short_sensors_on
	data["sensor_long"] = (vessel.has_working_sensor(OVERMAP_SENSOR_KIND_LONG) && vessel.long_sensors_on) || vessel.sees_any_foreign_peel()
	var/list/engines = list()
	for(var/obj/machinery/ship_engine/engine as anything in vessel.engines)
		if(engine == vessel.virtual_engine)
			continue
		engines += list(list(
			"name" = engine.name,
			"ref" = engine.UID(),
			"on" = engine.on,
			"thrust" = engine.get_thrust(),
			"limit" = round(engine.thrust_limit * 100),
			"status" = engine.get_status(),
			"push" = engine.omnidirectional ? null : REVERSE_DIR(engine.dir),
		))
	data["engines"] = engines
	var/obj/machinery/transponder/beacon = vessel.transponder
	data["has_transponder"] = !!beacon
	data["transponder"] = beacon && !(beacon.stat & (NOPOWER|BROKEN)) ? beacon.transponder_data() : null
	data["helm_tab"] = helm_tab
	var/turf/target = nav?.autopilot_x && nav.autopilot_y && vessel.sector?.get_turf_at(nav.autopilot_x, nav.autopilot_y)
	if(target && here)
		data["dest"] = list(nav.autopilot_x, nav.autopilot_y)
		var/target_name = length(waypoints) && waypoints[1]
		var/list/mark = target_name && waypoints[target_name]
		data["dest_name"] = mark && mark["x"] == nav.autopilot_x && mark["y"] == nav.autopilot_y ? target_name : "Клетка [nav.autopilot_x]-[nav.autopilot_y]"
		if(nav.navigation_target)
			data["dest_name"] = nav.navigation_target.get_overmap_display_name()
		if(vessel.programmed_mission)
			data["dest_name"] = vessel.programmed_pad_label(vessel.programmed_mission.dock_id)
		data["dest_range"] = max(abs(vessel.sector.coord_x(here) - nav.autopilot_x), abs(vessel.sector.coord_y(here) - nav.autopilot_y))
		for(var/obj/overmap/entity/hyperrelay/relay in target)
			if(relay.paired && vessel.contact_identified(relay))
				data["dest_relay"] = relay.paired.sector?.name
		if(vessel.in_free_flight())
			var/span = OVERMAP_TILE_SPAN * vessel.sector.tile_travel
			var/distance = sqrt((target.x * span - vessel.get_world_x()) ** 2 + (target.y * span - vessel.get_world_y()) ** 2)
			data["dest_jump_time"] = round((OVERMAP_JUMP_SPOOL + max(OVERMAP_JUMP_MIN_TIME, distance / OVERMAP_JUMP_SPEED)) / (1 SECONDS))
	data["is_shuttle"] = !!vessel.overmap_shuttle
	data["is_pod"] = !!vessel.overmap_pod
	data["can_ship_undock"] = !!vessel.docked_ship || length(vessel.docked_guests)
	data["can_land"] = vessel.can_radar_land()
	data["can_stop"] = vessel.overmap_pod ? vessel.overmap_pod.can_physical_dock() : (vessel.in_free_flight() && vessel.local_space?.static_level)
	data["can_relay_jump"] = vessel.can_hyperrelay_jump()
	data["dock_ready"] = vessel.docking_approach?.ready()
	data["dock_in_range"] = vessel.docking_approach?.in_alignment_range()
	data["dock_aligning"] = vessel.docking_approach?.aligning
	data["can_undock"] = vessel.can_helm_undock()
	data["can_physical_dock"] = vessel.can_helm_physical_dock()
	data["can_edge_dock"] = vessel.can_helm_edge_dock()
	data["docks"] = vessel.build_dock_list()
	data["collars"] = vessel.build_collar_list()
	data["selected_dock"] = vessel.selected_dock_id
	for(var/list/pad as anything in data["docks"])
		if(pad["selected"] || pad["id"] == data["selected_dock"])
			data["selected_dock"] = pad["name"]
			break
	data["at_station"] = !!vessel.get_dock_host()
	data["host_name"] = vessel.get_dock_host()?.name
	data["distress"] = !!vessel.identity_distress
	data["broadcasting"] = !!vessel.is_overmap_visible()
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
	data["map_jammed"] = vessel.is_overmap_jammed()

	vessel.fill_radar_data(data, radar_reach)
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

	if(vessel.is_programmed_locked() && !(action in list("select_programmed", "execute_programmed", "relink", "helm_tab", "select_weapon", "weapon_auto")) && !(length(selected_weapons) && (action in list("radar_point", "set_dest"))))
		to_chat(usr, span_warning("Прямое управление заблокировано поставщиком услуг."))
		return TRUE

	if((vessel.is_jumping() || vessel.relay_jump_from) && (action in list("undock", "dock", "dock_edge", "dock_ship", "dock_station", "prepare_stop", "prepare_landing", "align_dock", "relay_jump", "hyperjump")))
		to_chat(usr, span_warning("Идёт гиперпрыжок."))
		return TRUE

	if(vessel.docking_approach?.aligning && (action in list("take_helm", "inspect", "undock", "dock", "dock_edge", "dock_ship", "dock_station", "hyperjump")))
		to_chat(usr, span_warning("Выполняется автодоводка. Сначала отмените стыковку."))
		return TRUE
	switch(action)
		if("select_weapon", "weapon_auto")
			weapon_action(action, params, usr)
			return TRUE
		if("prepare_landing")
			if(!vessel.can_radar_land())
				return TRUE
			if(vessel.set_selected_pad(params["id"]))
				var/result = vessel.overmap_pod ? vessel.begin_physical_dock() : vessel.prepare_landing(vessel.get_selected_pad())
				if(result != TRUE)
					to_chat(usr, span_warning("Посадочная область недоступна."))
			return TRUE
		if("select_radar_dock")
			vessel.select_radar_dock(params["id"])
			return TRUE
		if("prepare_stop")
			if(!vessel.prepare_stop())
				to_chat(usr, span_warning("Поблизости нет свободной области остановки."))
			return TRUE
		if("relay_jump")
			var/result = vessel.begin_hyperrelay_jump()
			if(result != TRUE)
				to_chat(usr, span_warning("[result]"))
			return TRUE
		if("align_dock")
			if(vessel.docking_approach && !vessel.docking_approach.aligning && !vessel.docking_approach.in_alignment_range())
				QDEL_NULL(vessel.docking_approach)
				return TRUE
			var/result = vessel.docking_approach?.start_alignment()
			if(result != TRUE)
				to_chat(usr, span_warning("[result || "Сначала выберите область стыковки."]"))
			return TRUE
		if("cancel_docking")
			if(!vessel.docking_approach?.aligning && !vessel.docking_approach?.in_alignment_range())
				QDEL_NULL(vessel.docking_approach)
			return TRUE
		if("select_programmed")
			vessel.programmed_selected_dock = params["id"]
			. = TRUE
		if("execute_programmed")
			var/result = vessel.start_programmed_route(params["id"] || vessel.programmed_selected_dock)
			if(result != TRUE)
				to_chat(usr, span_warning("[result]"))
			. = TRUE

		if("take_helm", "inspect")
			if(vessel.overmap_pod)
				return TRUE
			var/datum/component/overmap_flight/nav = vessel.flight
			if(!nav)
				return TRUE
			if(nav.pilot == usr)
				nav.release_pilot()
			else if(nav.pilot)
				to_chat(usr, span_warning("За штурвалом уже [nav.pilot.name]."))
			else if(!can_pilot(usr))
				to_chat(usr, span_warning("Нужно стоять у консоли."))
			else if(!vessel.can_steer())
				to_chat(usr, span_warning("Судно не может маневрировать."))
			else if(vessel.docked_ship)
				to_chat(usr, span_warning("Корабль пристыкован к [vessel.docked_ship.get_overmap_display_name()]."))
			else if(vessel.is_jumping())
				to_chat(usr, span_warning("Идёт гиперпрыжок."))
			else

				nav.take_pilot(usr, src)
			. = TRUE
		if("hyperjump")
			var/jump_result = vessel.start_jump()
			if(jump_result != TRUE)
				to_chat(usr, span_warning("[jump_result]"))
			. = TRUE
		if("dock_ship")
			if(vessel.docked_ship)
				vessel.undock_ship()
			else
				for(var/obj/overmap/entity/guest as anything in vessel.docked_guests.Copy())
					guest.undock_ship()
			. = TRUE
		if("brake")
			if(!vessel.set_held_brake(!vessel.flight?.held_brake))
				to_chat(usr, span_warning("Невозможно тормозить."))
			. = TRUE
		if("cut_engines")
			vessel.cut_engines()
			. = TRUE
		if("toggle_dampeners")
			if(vessel.flight)
				vessel.flight.dampeners = !vessel.flight.dampeners
			. = TRUE
		if("toggle_angular_dampeners")
			if(vessel.flight)
				vessel.flight.angular_dampeners = !vessel.flight.angular_dampeners
			. = TRUE
		if("toggle_avoidance")
			if(vessel.flight)
				vessel.flight.avoid_obstacles = !vessel.flight.avoid_obstacles
			. = TRUE
		if("helm_radar_reach")

			radar_reach = clamp(round(text2num(params["reach"])), 32, OVERMAP_RADAR_TERRAIN_MAX)
			. = TRUE
		if("set_thrust_limit")
			if(vessel.flight)
				vessel.flight.thrust_limit = clamp(text2num(params["value"]) / 100, 0, 1)
				for(var/obj/machinery/ship_engine/engine as anything in vessel.engines)
					engine.thrust_limit = vessel.flight.thrust_limit
			. = TRUE
		if("toggle_engine")
			var/obj/machinery/ship_engine/engine = locateUID(params["ref"])
			if(engine in vessel.engines)
				engine.toggle()
			. = TRUE
		if("set_engine_limit")
			var/obj/machinery/ship_engine/engine = locateUID(params["ref"])
			if(engine in vessel.engines)
				engine.thrust_limit = clamp(text2num(params["value"]) / 100, 0, 1)
			. = TRUE
		if("transponder")
			var/obj/machinery/transponder/beacon = vessel.transponder
			if(!beacon || (beacon.stat & (NOPOWER|BROKEN)))
				to_chat(usr, span_warning("Транспондер не отвечает."))
				return TRUE
			beacon.handle_action(params["op"], params, usr)
			. = TRUE
		if("set_dest", "radar_point")
			if(length(selected_weapons))
				var/target_x = text2num(params["x"])
				var/target_y = text2num(params["y"])
				if(action == "set_dest")
					var/obj/overmap/target = locateUID(params["id"])
					if(!target || target.sector != vessel.sector)
						return TRUE
					var/obj/overmap/entity/entity = target
					target_x = istype(entity) ? entity.get_world_x() : target.x * OVERMAP_TILE_SPAN * vessel.sector.tile_travel
					target_y = istype(entity) ? entity.get_world_y() : target.y * OVERMAP_TILE_SPAN * vessel.sector.tile_travel
				fire_weapons(target_x, target_y, usr)
				return TRUE
			if(!vessel.flight || !vessel.sector)
				return TRUE
			var/dest_x = text2num(params["x"])
			var/dest_y = text2num(params["y"])
			if(!isnum(dest_x) || !isnum(dest_y))
				return TRUE
			if(action == "radar_point" && vessel.sector)
				var/span = OVERMAP_TILE_SPAN * vessel.sector.tile_travel
				dest_x = dest_x / span - vessel.sector.origin_x + 1
				dest_y = dest_y / span - vessel.sector.origin_y + 1
			if(dest_x && dest_y)
				vessel.abort_cancellable_mission()
				vessel.flight.navigation_target = null
				var/obj/overmap/target = params["id"] ? locateUID(params["id"]) : null
				if(params["id"] && (!istype(target) || target == vessel || target.sector != vessel.sector))
					return TRUE
				if(istype(target))
					var/detected = vessel.iff_detects(target) || target.visible_without_scanner || vessel.object_visibility(target, vessel.get_overmap_turf(), vessel.sensor_reach_cells()) > OVERMAP_CHART_UNSEEN_ALPHA
					if(!detected && !vessel.short_knows(target))
						return TRUE
					if(detected && istype(target, /obj/overmap/entity))
						vessel.flight.navigation_target = target
					var/turf/contact = target.get_overmap_turf()
					dest_x = vessel.sector.coord_x(contact) + target.position[1]
					dest_y = vessel.sector.coord_y(contact) + target.position[2]
				if(vessel.sector)
					dest_x = clamp(dest_x, 1, vessel.sector.size)
					dest_y = clamp(dest_y, 1, vessel.sector.size)
				add_waypoint(strip_html(params["name"], MAX_NAME_LEN), dest_x, dest_y)
				vessel.set_autopilot(vessel.flight?.autopilot, dest_x, dest_y)
			. = TRUE
		if("clear_dest")
			waypoints.Cut()
			if(vessel.flight)
				vessel.flight.navigation_target = null
				vessel.flight.autopilot_x = null
				vessel.flight.autopilot_y = null
			vessel.set_autopilot(FALSE)
			. = TRUE
		if("cancel_programmed")
			vessel.abort_cancellable_mission()
			. = TRUE
		if("match_velocity")
			if(!vessel.flight?.toggle_velocity_matching())
				to_chat(usr, span_warning("Выберите доступный объект для сближения."))
			. = TRUE
		if("toggle_autopilot")
			if(!vessel.flight?.autopilot_x || !vessel.flight.autopilot_y)
				to_chat(usr, span_warning("Нет установленной цели автопилота."))
			else
				vessel.set_autopilot(!vessel.flight.autopilot, vessel.flight.autopilot_x, vessel.flight.autopilot_y)
			. = TRUE
		if("set_max_speed")
			if(vessel.flight)
				var/limit = vessel.flight.navigation_speed_limited() ? OVERMAP_PROGRAMMED_CRUISE : OVERMAP_CRUISE_MAX
				vessel.flight.cruise_speed = OVERMAP_FROM_DISPLAY(clamp(text2num(params["value"]), OVERMAP_CRUISE_MIN, limit))
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
			else
				to_chat(usr, span_notice("Шаттл выходит в гиперпространство."))
			. = TRUE
		if("dock")
			var/dock_result = vessel.overmap_pod ? vessel.begin_physical_dock() : (vessel.prepare_landing(vessel.get_selected_pad()) ? TRUE : "Посадочная область недоступна.")
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
			. = TRUE
		if("select_collar")
			if(!vessel.set_selected_collar(params["id"]))
				to_chat(usr, span_warning("Этот шлюз недоступен."))
			. = TRUE
		if("helm_tab")
			helm_tab = (params["tab"] == "dock") ? "dock" : "flight"
			. = TRUE
		if("pick_custom_dock")
			if(!open_custom_dock_picker(usr))
				. = TRUE
			else
				vessel.set_selected_pad(OVERMAP_DOCK_ID_CUSTOM)
			. = TRUE
		if("relink")
			link_vessel()
			. = TRUE

/proc/hazard_flavour(obj/overmap/feature/hazard/hazard)
	switch(hazard?.icon_state)
		if(OVERMAP_HAZARD_ICON_EMP)
			return "emp"
		if(OVERMAP_HAZARD_ICON_CARP)
			return "carp"
		if(OVERMAP_HAZARD_ICON_ASTEROID)
			return "asteroid"
	return null

/obj/machinery/computer/helm/proc/flight_phase()
	if(vessel.is_programmed_locked())
		return "route"
	if(vessel.is_jumping())
		return "jump"
	if(vessel.is_overmap_jammed())
		return "relay"
	if(vessel.can_helm_undock())
		return "docked"
	if(vessel.status == OVERMAP_STATUS_TRANSIT)
		return "transit"
	return "flight"

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
		SStgui.update_uis(src)
