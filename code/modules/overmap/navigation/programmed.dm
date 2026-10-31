/proc/build_overmap_programmed_profiles()
	. = list()
	for(var/path in subtypesof(/datum/overmap_programmed_profile))
		if(path == /datum/overmap_programmed_profile/escape_pod)
			continue
		var/datum/overmap_programmed_profile/profile = new path
		if(!profile.shuttle_id)
			continue
		.[profile.shuttle_id] = profile
	for(var/i in 1 to 4)
		var/datum/overmap_programmed_profile/escape_pod/pod_profile = new
		pod_profile.shuttle_id = "pod[i]"
		pod_profile.add_hidden_leg("pod[i]_away", null)
		.[pod_profile.shuttle_id] = pod_profile

/proc/build_overmap_programmed_shuttle_ids()
	. = list()
	for(var/shuttle_id in GLOB.overmap_programmed_profiles)
		.[shuttle_id] = TRUE

/proc/is_overmap_programmed_dock(dock_id)
	var/static/list/programmed_docks
	if(isnull(programmed_docks))
		programmed_docks = list()
		for(var/shuttle_id, profile_entry in GLOB.overmap_programmed_profiles)
			var/datum/overmap_programmed_profile/profile = profile_entry
			for(var/profile_dock in profile.dock_ids())
				programmed_docks[profile_dock] = TRUE
	return programmed_docks[dock_id]

GLOBAL_LIST_INIT(overmap_programmed_profiles, build_overmap_programmed_profiles())
GLOBAL_LIST_INIT(overmap_programmed_shuttle_ids, build_overmap_programmed_shuttle_ids())

/datum/overmap_programmed_leg
	var/dock_id
	var/collar_id
	var/hidden = FALSE

/datum/overmap_programmed_leg/New(target_dock, collar, hidden_leg = FALSE)
	dock_id = target_dock
	collar_id = collar
	hidden = hidden_leg

/datum/overmap_programmed_profile
	var/shuttle_id
	var/autostart_dock_id
	var/autostart_skip_windup = FALSE

	var/persist_until_dock = FALSE
	var/hazard_immune = FALSE
	var/skip_windup = FALSE
	var/instant_undock = FALSE
	var/block_if_canMove = FALSE
	var/block_move_message
	var/needs_virtual_engine = TRUE
	var/manual_helm = FALSE
	var/list/datum/overmap_programmed_leg/legs

/datum/overmap_programmed_profile/New()
	legs = list()
	setup_legs()

/datum/overmap_programmed_profile/proc/setup_legs()
	return

/datum/overmap_programmed_profile/proc/add_leg(dock_id, collar_id, hidden_leg = FALSE)
	legs += new /datum/overmap_programmed_leg(dock_id, collar_id, hidden_leg)

/datum/overmap_programmed_profile/proc/add_hidden_leg(dock_id, collar_id)
	add_leg(dock_id, collar_id, TRUE)

/datum/overmap_programmed_profile/proc/leg_for(dock_id)
	RETURN_TYPE(/datum/overmap_programmed_leg)
	for(var/datum/overmap_programmed_leg/leg as anything in legs)
		if(leg.dock_id == dock_id)
			return leg

/datum/overmap_programmed_profile/proc/dock_ids(include_hidden = TRUE)
	. = list()
	for(var/datum/overmap_programmed_leg/leg as anything in legs)
		if(!include_hidden && leg.hidden)
			continue
		. += leg.dock_id

/datum/overmap_programmed_profile/proc/has_visible_legs()
	return length(dock_ids(FALSE))

/datum/overmap_programmed_profile/proc/announce_depart(dock_id)
	return

/datum/overmap_programmed_profile/proc/announce_arrive(dock_id)
	return

/datum/overmap_programmed_profile/mining
	shuttle_id = "mining"
	manual_helm = TRUE

/datum/overmap_programmed_profile/mining/setup_legs()
	add_leg("mining_home", "mining_west")
	add_leg("mining_away", "mining_east")

/datum/overmap_programmed_profile/laborcamp
	shuttle_id = "laborcamp"
	manual_helm = TRUE

/datum/overmap_programmed_profile/laborcamp/setup_legs()
	add_leg("laborcamp_home", "labor_west")
	add_leg("laborcamp_away", "labor_east")

/datum/overmap_programmed_profile/supply
	shuttle_id = "supply"
	hazard_immune = TRUE
	skip_windup = TRUE
	instant_undock = TRUE
	block_if_canMove = TRUE
	block_move_message = "По соображениям безопасности шаттл снабжения не может перемещать живые организмы, ядерное оружие или маячки перемещения."

/datum/overmap_programmed_profile/supply/setup_legs()
	add_leg("supply_home", "supply_main")
	add_leg("supply_away", "supply_main")

/datum/overmap_programmed_profile/emergency
	shuttle_id = "emergency"
	persist_until_dock = TRUE
	hazard_immune = TRUE

/datum/overmap_programmed_profile/emergency/setup_legs()
	add_hidden_leg("emergency_home", "emergency_main")
	add_hidden_leg("emergency_away", "emergency_main")
	add_hidden_leg("emergency_syndicate", "emergency_main")

/datum/overmap_programmed_profile/gamma
	shuttle_id = "gamma_shuttle"
	persist_until_dock = TRUE
	hazard_immune = TRUE

/datum/overmap_programmed_profile/gamma/setup_legs()
	add_hidden_leg("gamma_home", "gamma_main")
	add_hidden_leg("gamma_away", "gamma_main")

/datum/overmap_programmed_profile/gamma/announce_depart(dock_id)
	if(dock_id == "gamma_home")
		GLOB.major_announcement.announce(
			message = "Центральное командование отправило оружейный шаттл уровня Гамма.",
			new_sound = 'sound/AI/gamma_deploy.ogg'
		)
		return
	GLOB.major_announcement.announce(
		message = "Центральное командование отозвало оружейный шаттл уровня Гамма.",
		new_sound = 'sound/AI/gamma_recall.ogg'
	)

/datum/overmap_programmed_profile/gamma/announce_arrive(dock_id)
	if(dock_id != "gamma_home")
		return
	GLOB.major_announcement.announce(
		message = "Оружейный шаттл уровня Гамма прибыл на станцию."
	)

/datum/overmap_programmed_profile/addition_goal
	shuttle_id = "addition_goal"
	hazard_immune = TRUE
	persist_until_dock = TRUE

/datum/overmap_programmed_profile/addition_goal/setup_legs()
	add_leg("addition_goal_dock", "additional_east")
	add_leg("graveyard_church", "additional_east")

/datum/overmap_programmed_profile/escape_pod
	persist_until_dock = TRUE
	hazard_immune = TRUE

/proc/is_overmap_programmed_shuttle(obj/docking_port/mobile/shuttle)
	if(!shuttle?.id)
		return FALSE
	if(GLOB.overmap_programmed_shuttle_ids[shuttle.id])
		return TRUE
	return istype(shuttle, /obj/docking_port/mobile/pod)

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
	if(profile?.needs_virtual_engine)
		ensure_virtual_engine()

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

/datum/overmap_programmed_mission
	var/obj/overmap/entity/vessel
	var/dock_id
	var/collar_id
	var/obj/overmap/entity/dest_host
	var/phase
	var/windup_end
	var/started_at
	var/home_dock
	var/next_dock_try = 0
	var/dock_tries = 0
	var/returning_home = FALSE
	var/next_nav_warn = 0
	var/persist_until_dock = FALSE
	var/cancellable = FALSE
	var/processing = FALSE
	var/list/obj/effect/landmark/overmap_navigation_beacon/navigation_beacons
	var/navigation_step = 0
	var/navigation_dock_prepared = FALSE
	var/navigation_entry_ready = FALSE
	var/list/navigation_entry_box
	var/departure_dock_id
	var/departure_pending = FALSE
	var/departure_step = 1
	var/obj/overmap/entity/departure_host
	var/list/departure_beacons

/datum/overmap_programmed_mission/New(obj/overmap/entity/owner, target_dock, skip_windup, source_dock)
	vessel = owner
	QDEL_NULL(owner.docking_approach)
	if(owner.flight)
		owner.flight.release_pilot()
		owner.flight.set_autopilot(FALSE, manual = FALSE)
		owner.flight.navigation_target = null
		owner.flight.held_brake = TRUE
	dock_id = target_dock
	var/datum/overmap_programmed_profile/profile = GLOB.overmap_programmed_profiles[owner.shuttle?.id]
	collar_id = profile?.leg_for(target_dock)?.collar_id
	dest_host = SSovermap?.host_for_pad(SSshuttle.getDock(target_dock, warn = FALSE), owner.shuttle)
	if(!dest_host)
		dest_host = SSovermap?.resolve_nest_host(owner.shuttle, SSshuttle.getDock(target_dock, warn = FALSE))
	started_at = world.time
	home_dock = owner.programmed_current_pad()
	departure_dock_id = source_dock
	departure_pending = !!source_dock
	persist_until_dock = profile?.persist_until_dock
	cancellable = !!profile?.manual_helm
	if(skip_windup)
		phase = OVERMAP_PROG_UNDOCK
		windup_end = world.time
	else
		phase = OVERMAP_PROG_WINDUP
		windup_end = world.time + OVERMAP_PROGRAMMED_WINDUP

/datum/overmap_programmed_mission/Destroy()
	if(vessel?.programmed_mission == src)
		vessel.flight?.set_autopilot(FALSE, manual = FALSE)
		QDEL_NULL(vessel.docking_approach)
	if(vessel?.programmed_mission == src)
		vessel.programmed_mission = null
	vessel = null
	dest_host = null
	return ..()

/datum/overmap_programmed_mission/proc/eta_string()
	if(QDELETED(vessel))
		return "00:00"
	var/left = max(0, vessel.estimate_programmed_trip(dock_id, src))
	var/seconds = round(left / 10)
	return "[add_zero(num2text(round(seconds / 60)), 2)]:[add_zero(num2text(seconds % 60), 2)]"

/datum/overmap_programmed_mission/proc/process_mission()
	set waitfor = FALSE
	if(processing || QDELETED(vessel) || QDELETED(src))
		return
	processing = TRUE
	advance_phase()
	processing = FALSE

/datum/overmap_programmed_mission/proc/advance_phase()
	if(vessel.is_overmap_jammed() && phase != OVERMAP_PROG_JUMP)
		return
	switch(phase)
		if(OVERMAP_PROG_WINDUP)
			if(world.time >= windup_end)
				phase = OVERMAP_PROG_UNDOCK
				try_undock()
		if(OVERMAP_PROG_UNDOCK)
			try_undock()
		if(OVERMAP_PROG_FLY)
			try_fly()
		if(OVERMAP_PROG_JUMP)
			try_jump()
		if(OVERMAP_PROG_DOCK)
			try_dock()

/datum/overmap_programmed_mission/proc/try_undock()
	if(vessel.hull_needs_transit_undock())
		if(!persist_until_dock && vessel.shuttle?.mode != SHUTTLE_IDLE && vessel.shuttle?.mode != SHUTTLE_RECHARGING)
			return
		var/undock_result = vessel.begin_physical_undock(persist_until_dock)
		if(undock_result != TRUE)
			vessel.announce_programmed("[undock_result]")
		return
	if(vessel.status == OVERMAP_STATUS_OVERMAP || vessel.status == OVERMAP_STATUS_TRANSIT)
		if(isturf(vessel.loc) || vessel.get_overmap_turf())
			phase = OVERMAP_PROG_FLY
			try_fly()
		return
	if(vessel.status != OVERMAP_STATUS_DOCKED)
		return
	vessel.release_to_overmap()
	phase = OVERMAP_PROG_FLY
	try_fly()

/datum/overmap_programmed_mission/proc/resolved_dest_host()
	RETURN_TYPE(/obj/overmap/entity)
	if(!QDELETED(dest_host))
		return dest_host
	dest_host = SSovermap?.host_for_pad(SSshuttle.getDock(dock_id, warn = FALSE), vessel.shuttle)
	return dest_host

/datum/overmap_programmed_mission/proc/needs_hyperrelay()
	var/obj/overmap/entity/host = resolved_dest_host()
	if(!host)
		return FALSE
	if(!host.sector || !vessel.sector)
		return FALSE
	return host.sector != vessel.sector

/datum/overmap_programmed_mission/proc/route_relay()
	RETURN_TYPE(/obj/overmap/entity/hyperrelay)
	return vessel.nearest_hyperrelay(resolved_dest_host()?.sector)

/datum/overmap_programmed_mission/proc/on_route_relay()
	var/obj/overmap/entity/hyperrelay/relay = route_relay()
	return relay && vessel.hyperrelay_on_tile() == relay

/datum/overmap_programmed_mission/proc/ensure_free_for_flight()
	if(QDELETED(vessel))
		return
	var/obj/docking_port/stationary/pad = vessel.shuttle?.get_docked()
	var/in_transit = istype(pad, /obj/docking_port/stationary/transit)
	if(in_transit && (vessel.status == OVERMAP_STATUS_DOCKED || !isturf(vessel.loc)))
		vessel.release_to_overmap()
	if(isturf(vessel.loc) && in_transit)
		vessel.status = OVERMAP_STATUS_OVERMAP
	vessel.halted = FALSE
	if(vessel.flight)
		vessel.flight.engines_state = TRUE
	if(!vessel.free_flight_view && vessel.in_free_flight())
		vessel.set_free_flight_view(TRUE)
	if(!isturf(vessel.loc) || !SSovermap)
		return
	var/datum/overmap_sector/here_sector = SSovermap.sector_for_turf(vessel.loc)
	if(!here_sector || vessel.sector == here_sector)
		return
	vessel.sector?.remove_object(vessel)
	here_sector.add_object(vessel, vessel.loc)

/datum/overmap_programmed_mission/proc/try_fly()
	if(QDELETED(src) || QDELETED(vessel))
		return
	if(vessel.is_overmap_jammed())
		return
	ensure_free_for_flight()
	if(vessel.status == OVERMAP_STATUS_DOCKED)
		return
	if(departure_pending && continue_departure())
		return
	var/turf/here = vessel.get_overmap_turf()
	if(needs_hyperrelay())
		if(on_route_relay() && OVERMAP_SPEED_STOPPED(vessel.get_speed()))
			on_overmap_arrived()
			return
		var/turf/relay_turf = route_relay()?.get_overmap_turf()
		if(!relay_turf || !here || relay_turf.z != here.z)
			return
		if(vessel.flight)
			vessel.flight.cruise_speed = OVERMAP_FROM_DISPLAY(OVERMAP_PROGRAMMED_CRUISE)
		var/obj/overmap/entity/hyperrelay/relay = route_relay()
		vessel.flight.navigate_world(relay.get_world_x(), relay.get_world_y())
		return
	continue_navigation()

/datum/overmap_programmed_mission/proc/on_overmap_arrived()
	if(phase != OVERMAP_PROG_FLY && phase != OVERMAP_PROG_JUMP)
		return
	if(needs_hyperrelay())
		if(!on_route_relay())
			phase = OVERMAP_PROG_FLY
			return
		phase = OVERMAP_PROG_JUMP
		try_jump()
		return
	phase = OVERMAP_PROG_DOCK
	try_dock()

/datum/overmap_programmed_mission/proc/try_jump()
	if(vessel.is_overmap_jammed())
		return
	var/obj/overmap/entity/dest = resolved_dest_host()
	if(dest?.sector && dest.sector == vessel.sector)
		phase = OVERMAP_PROG_FLY
		try_fly()
		return
	if(!needs_hyperrelay() || !on_route_relay())
		phase = OVERMAP_PROG_FLY
		return
	if(vessel.begin_hyperrelay_jump(TRUE) == TRUE)
		return
	phase = OVERMAP_PROG_FLY

/datum/overmap_programmed_mission/proc/try_dock()
	dock_from_navigation()

/datum/overmap_programmed_mission/proc/fail_dock(reason)
	dock_tries++
	next_dock_try = world.time + OVERMAP_PROGRAMMED_DOCK_RETRY
	var/text = reason || "Стыковка недоступна."
	if(persist_until_dock)
		vessel.announce_programmed("[text] Повторная стыковка через 15 секунд.")
		vessel.announce_sensor_event("[vessel.get_overmap_display_name()]: стыковка не удалась. [text] Повтор через 15 секунд.", "dock_fail")
		return
	if(returning_home || dock_tries >= OVERMAP_PROGRAMMED_DOCK_TRIES || !home_dock || home_dock == dock_id)
		vessel.announce_programmed("[text] Маршрут прерван.")
		vessel.announce_sensor_event("[vessel.get_overmap_display_name()]: стыковка не удалась. [text]", "dock_fail")
		var/obj/overmap/entity/owner = vessel
		var/back = home_dock
		var/give_up = returning_home || !back || back == dock_id
		qdel(src)
		if(!give_up)
			owner.announce_programmed("Возврат в исходный док.")
			owner.announce_sensor_event("[owner.get_overmap_display_name()]: возврат в исходный док.", "recall")
			if(owner.start_programmed_route(back, TRUE, TRUE) == TRUE)
				owner.programmed_mission?.returning_home = TRUE
		return
	vessel.announce_programmed("[text] Повторная стыковка через 15 секунд.")
	vessel.announce_sensor_event("[vessel.get_overmap_display_name()]: стыковка не удалась. [text] Повтор через 15 секунд.", "dock_fail")

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
			if(!istype(relay) || QDELETED(relay.paired) || !relay.paired.sector)
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
		if(!istype(relay) || QDELETED(relay.paired))
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
