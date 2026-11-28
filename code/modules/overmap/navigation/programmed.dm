/obj/overmap/entity/proc/programmed_pad_label(pad_id)
	var/obj/docking_port/stationary/pad = SSshuttle.getDock(pad_id, warn = FALSE)
	if(!pad)
		return pad_id
	if(!pad.overmap_dock_label)
		pad.apply_overmap_dock_role()
	var/label = pad.overmap_dock_label || pad.name || pad_id
	var/obj/overmap/entity/host = SSovermap.host_for_pad(pad)
	var/area/location = get_area(pad)
	return host ? "[label] ([host.get_overmap_display_name()])" : "[label] ([location.name])"

/obj/overmap/entity/proc/programmed_profile()
	RETURN_TYPE(/datum/overmap_programmed_profile)
	if(!shuttle?.id)
		return null
	return GLOB.overmap_programmed_profiles[shuttle.id]

/obj/overmap/entity/proc/setup_programmed_defaults()
	if(!shuttle)
		return
	var/datum/overmap_programmed_profile/profile = programmed_profile()
	if(profile?.hazard_immune)
		overmap_hazard_immune = TRUE
	if(!is_overmap_programmed_shuttle(shuttle))
		return
	programmed = TRUE
	if(flight)
		flight.cruise_speed = OVERMAP_FROM_DISPLAY(OVERMAP_PROGRAMMED_CRUISE)
	programmed_has_routes = !!profile?.has_visible_legs()

/obj/overmap/entity/proc/is_programmed_locked()
	if(!programmed || programmed_profile()?.manual_helm)
		return FALSE
	return world.time >= programmed_emag_until

/obj/overmap/entity/proc/is_programmed_emagged()
	return programmed && world.time < programmed_emag_until

/obj/overmap/entity/proc/programmed_current_pad()
	if(!shuttle)
		return null
	if(status == OVERMAP_STATUS_DOCKED)
		return shuttle.getDockedId()
	return last_dock_id

/obj/overmap/entity/proc/programmed_route_list(list/allowed_ids)
	. = list()
	if(!shuttle || !programmed_has_routes)
		return
	var/current_id = status == OVERMAP_STATUS_DOCKED ? shuttle.getDockedId() : null
	var/datum/overmap_programmed_profile/profile = GLOB.overmap_programmed_profiles[shuttle.id]
	var/list/pads = profile?.dock_ids(FALSE)
	if(!pads)
		return
	for(var/pad_id in pads)
		if(pad_id == current_id)
			continue
		if(length(allowed_ids) && !(pad_id in allowed_ids))
			continue
		var/obj/docking_port/stationary/pad = SSshuttle.getDock(pad_id, warn = FALSE)
		if(!pad || istype(pad, /obj/docking_port/stationary/transit))
			continue
		. += list(list(
			"id" = pad.id,
			"name" = programmed_pad_label(pad.id),
			"selected" = FALSE,
		))
	var/valid = FALSE
	for(var/list/entry as anything in .)
		if(entry["id"] == programmed_selected_dock)
			valid = TRUE
			break
	if(!valid && length(.))
		programmed_selected_dock = .[1]["id"]
	for(var/list/entry as anything in .)
		entry["selected"] = entry["id"] == programmed_selected_dock

/obj/overmap/entity/proc/programmed_ui_payload()
	. = list()
	.["programmed"] = programmed
	.["programmed_locked"] = is_programmed_locked()
	.["programmed_emagged"] = is_programmed_emagged()
	.["programmed_has_routes"] = programmed_has_routes
	.["programmed_selected"] = programmed_selected_dock
	.["programmed_busy"] = !!programmed_mission
	.["programmed_phase"] = programmed_mission?.phase
	.["programmed_eta"] = programmed_mission?.eta_string()
	.["programmed_windup"] = 0
	if(programmed_mission?.phase == OVERMAP_PROG_WINDUP)
		.["programmed_windup"] = max(0, round((programmed_mission.windup_end - world.time) / 10))
	.["programmed_routes"] = programmed_route_list()

/obj/overmap/entity/proc/fill_programmed_ui(list/data, list/allowed_ids)
	var/list/payload = programmed_ui_payload()
	if(allowed_ids)
		payload["programmed_routes"] = programmed_route_list(allowed_ids)
	for(var/key in payload)
		data[key] = payload[key]

/obj/overmap/entity/proc/start_programmed_route(dock_id, skip_windup = FALSE, force = FALSE, list/allowed_ids)
	if(!programmed)
		return "Маршрут недоступен."
	if(is_programmed_emagged() && !force)
		return "Маршрут недоступен."
	if(programmed_mission)
		return "Маршрут недоступен."
	if(!shuttle)
		return "Маршрут недоступен."
	var/datum/overmap_programmed_profile/profile = programmed_profile()
	if(profile?.block_if_canMove && !shuttle.canMove())
		return profile.block_move_message || "Маршрут недоступен."
	var/datum/overmap_programmed_leg/leg = profile?.leg_for(dock_id)
	if(!force)
		if(!programmed_has_routes)
			return "Маршрут недоступен."
		if(leg?.hidden)
			return "Маршрут недоступен."
		var/list/pads = profile?.dock_ids(FALSE)
		if(!pads)
			return "Маршрут недоступен."
		if(status == OVERMAP_STATUS_DOCKED && dock_id == shuttle.getDockedId())
			return "Шаттл уже на этой площадке."
		if(!dock_id || !(dock_id in pads) || (length(allowed_ids) && !(dock_id in allowed_ids)))
			var/list/routes = programmed_route_list(allowed_ids)
			if(!length(routes))
				return "Маршрут недоступен."
			dock_id = routes[1]["id"]
			leg = profile?.leg_for(dock_id)
	else if(dock_id && dock_id == shuttle.getDockedId() && status == OVERMAP_STATUS_DOCKED)
		snap_physical_redock()
		return TRUE
	var/obj/docking_port/stationary/pad = SSshuttle.getDock(dock_id, warn = FALSE)
	if(!pad)
		return "Маршрут недоступен."
	if(profile?.skip_windup)
		skip_windup = TRUE
	var/departure_dock = hull_needs_transit_undock() ? programmed_current_pad() : null
	if(profile?.instant_undock && status == OVERMAP_STATUS_DOCKED)
		var/undock_result = begin_physical_undock(TRUE)
		if(undock_result != TRUE)
			return undock_result
	programmed_selected_dock = dock_id
	apply_programmed_collar(dock_id)
	if(flight)
		flight.cruise_speed = OVERMAP_FROM_DISPLAY(OVERMAP_PROGRAMMED_CRUISE)
	programmed_mission = new(src, dock_id, skip_windup, departure_dock)
	if(profile?.persist_until_dock)
		programmed_mission.persist_until_dock = TRUE
	if(status != OVERMAP_STATUS_DOCKED && (profile?.skip_windup || skip_windup))
		programmed_mission.phase = OVERMAP_PROG_FLY
		programmed_mission.try_fly()
	if(skip_windup)
		announce_programmed("Маршрут принят. Исполнение.")
	else
		announce_programmed("Маршрут принят. Отправление через 10 секунд.")
	profile?.announce_depart(dock_id)
	return TRUE

/obj/overmap/entity/proc/start_request_route(dock_id)
	if(!programmed_profile()?.leg_for(dock_id))
		return "Запрограммированный маршрут отсутствует."
	return start_programmed_route(dock_id)

/obj/overmap/entity/proc/abort_programmed_mission()
	QDEL_NULL(programmed_mission)
	if(flight)
		flight.set_autopilot(FALSE, manual = FALSE)

/obj/overmap/entity/proc/abort_cancellable_mission()
	if(!programmed_mission?.cancellable)
		return FALSE
	abort_programmed_mission()
	announce_programmed("Автопилот отменён.")
	return TRUE

/obj/overmap/entity/proc/announce_programmed(text)
	SEND_SIGNAL(src, COMSIG_OVERMAP_NOTICE, text)

/obj/overmap/entity/proc/emag_programmed(mob/user)
	if(!programmed || programmed_profile()?.manual_helm)
		return FALSE
	if(world.time < programmed_emag_ready)
		to_chat(user, span_warning("Навигация ещё в защитном цикле."))
		return FALSE
	if(is_programmed_emagged())
		return FALSE
	programmed_emag_home_dock = shuttle?.getDockedId() || last_dock_id
	programmed_emag_dest_dock = programmed_mission?.dock_id
	if(status == OVERMAP_STATUS_DOCKED)
		programmed_emag_resume_dock = programmed_emag_home_dock
	else
		programmed_emag_resume_dock = programmed_emag_dest_dock || programmed_emag_home_dock
	abort_programmed_mission()
	var/emag_time = OVERMAP_PROGRAMMED_EMAG_TIME
	programmed_emag_until = world.time + emag_time
	addtimer(CALLBACK(src, PROC_REF(finish_programmed_emag)), emag_time)
	var/obj/docking_port/mobile/emergency/evac = shuttle
	if(istype(evac))
		evac.on_nav_emag()
	if(shuttle?.id == "emergency")
		var/shuttle_name = shuttle?.name || name
		GLOB.major_announcement.announce(
			message = "Обнаружен взлом систем навигации шаттла «[shuttle_name]». Возможны отклонения от установленного маршрута.",
			new_title = ANNOUNCE_PRIORITY_RU,
			new_sound = 'sound/misc/announce_syndi.ogg'
		)
	announce_programmed("Прямое управление разблокировано.")
	return TRUE

/obj/overmap/entity/proc/finish_programmed_emag()
	if(QDELETED(src) || !programmed)
		return
	programmed_emag_until = 0
	programmed_emag_ready = world.time + OVERMAP_PROGRAMMED_EMAG_CD
	if(flight)
		flight.cruise_speed = OVERMAP_FROM_DISPLAY(OVERMAP_PROGRAMMED_CRUISE)
		flight.held_brake = FALSE
		flight.engines_state = TRUE
	halted = FALSE
	announce_programmed("Прямое управление заблокировано поставщиком. Возврат на маршрут.")
	var/obj/docking_port/mobile/emergency/evac = shuttle
	if(istype(evac))
		evac.on_nav_emag_end()
	if(shuttle?.id == "emergency" && shuttle.getDockedId() == "emergency_syndicate")
		return
	var/resume_dock = programmed_emag_resume_dock
	if(!resume_dock)
		return
	if(status == OVERMAP_STATUS_DOCKED && shuttle?.getDockedId() == resume_dock)
		return
	var/result = start_programmed_route(resume_dock, TRUE, TRUE)
	if(result != TRUE)
		announce_programmed("[result]")
		return
	if(!programmed_mission?.resolved_dest_host())
		announce_programmed("Навигация не видит цель маршрута.")

/obj/overmap/entity/proc/apply_programmed_collar(dock_id)
	var/datum/overmap_programmed_profile/profile = GLOB.overmap_programmed_profiles[shuttle?.id]
	var/datum/overmap_programmed_leg/leg = profile?.leg_for(dock_id)
	if(!leg?.collar_id)
		return FALSE
	return select_collar_by_key(leg.collar_id)

/obj/overmap/entity/proc/nearest_hyperrelay(datum/overmap_sector/goal_sector)
	RETURN_TYPE(/obj/overmap/entity/hyperrelay)
	if(!sector || !goal_sector || goal_sector == sector)
		return null
	var/list/hops_to_goal = list()
	hops_to_goal[goal_sector] = 0
	var/list/queue = list(goal_sector)
	while(length(queue))
		var/datum/overmap_sector/current = popleft(queue)
		for(var/obj/overmap/overmap_object as anything in current.objects)
			var/obj/overmap/entity/hyperrelay/relay = overmap_object
			if(!istype(relay) || !relay.enabled || QDELETED(relay.paired) || !relay.paired.sector)
				continue
			if(!isnull(hops_to_goal[relay.paired.sector]))
				continue
			hops_to_goal[relay.paired.sector] = hops_to_goal[current] + 1
			queue += relay.paired.sector
	var/turf/here = get_overmap_turf()
	var/obj/overmap/entity/hyperrelay/best
	var/best_hops = INFINITY
	var/best_dist = INFINITY
	for(var/obj/overmap/overmap_object as anything in sector.objects)
		var/obj/overmap/entity/hyperrelay/relay = overmap_object
		if(!istype(relay) || !relay.enabled || QDELETED(relay.paired))
			continue
		var/hops = hops_to_goal[relay.paired.sector]
		if(isnull(hops))
			continue
		var/turf/there = relay.get_overmap_turf()
		if(!there || !here)
			continue
		var/dist = max(abs(here.x - there.x), abs(here.y - there.y))
		if(hops < best_hops || (hops == best_hops && dist < best_dist))
			best_hops = hops
			best_dist = dist
			best = relay
	return best

/obj/overmap/entity/proc/estimate_overmap_leg(turf/start, turf/finish, datum/overmap_sector/on_sector)
	if(!start || !finish || start.z != finish.z)
		return 0
	var/dist = max(abs(start.x - finish.x), abs(start.y - finish.y))
	if(dist <= 0)
		return 0
	var/speed = OVERMAP_FROM_DISPLAY(OVERMAP_PROGRAMMED_CRUISE)
	if(flight)
		speed = max(speed, flight.cruise_speed)
	if(get_speed() > speed)
		speed = get_speed()
	if(speed <= 0)
		speed = OVERMAP_FROM_DISPLAY(OVERMAP_PROGRAMMED_CRUISE)
	var/travel = on_sector?.tile_travel || 1
	return CEILING((dist * travel) / speed, 1)

/obj/overmap/entity/proc/estimate_programmed_trip(dock_id, datum/overmap_programmed_mission/mission)
	var/trip_time = 0
	if(mission)
		switch(mission.phase)
			if(OVERMAP_PROG_WINDUP)
				trip_time += max(0, mission.windup_end - world.time)
			if(OVERMAP_PROG_UNDOCK)
				trip_time += 8 SECONDS
			if(OVERMAP_PROG_JUMP)
				trip_time += max(0, overmap_jammed_until - world.time)
			if(OVERMAP_PROG_DOCK)
				trip_time += 8 SECONDS
				return trip_time
	else
		trip_time += OVERMAP_PROGRAMMED_WINDUP + 8 SECONDS
	var/obj/overmap/entity/host = SSovermap?.host_for_pad(SSshuttle.getDock(dock_id, warn = FALSE), shuttle)
	if(!host && mission)
		host = mission.dest_host
	var/turf/here = get_overmap_turf()
	if(!here || !host)
		trip_time += 90 SECONDS
		return trip_time
	if(sector && host.sector && sector != host.sector)
		var/obj/overmap/entity/hyperrelay/relay = nearest_hyperrelay(host.sector)
		var/turf/relay_turf = relay?.get_overmap_turf()
		if(relay_turf)
			trip_time += estimate_overmap_leg(here, relay_turf, sector)
		if(mission?.phase != OVERMAP_PROG_JUMP)
			trip_time += relay ? hyperrelay_jump_duration(relay) : OVERMAP_HYPERRELAY_JUMP_TIME
		var/turf/dest = host.get_overmap_turf()
		var/turf/other_relay = relay?.paired?.get_overmap_turf()
		if(dest && other_relay)
			trip_time += estimate_overmap_leg(other_relay, dest, host.sector)
		trip_time += 8 SECONDS
		return trip_time
	var/turf/dest = host.get_overmap_turf()
	if(dest && here != dest)
		trip_time += estimate_overmap_leg(here, dest, sector || host.sector)
	trip_time += 8 SECONDS
	return trip_time
