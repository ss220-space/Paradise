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
	var/obj/effect/overmap_warp_portal/relay_route_portal
	var/relay_route_aligned = FALSE

/datum/overmap_programmed_mission/New(obj/overmap/entity/owner, target_dock, skip_windup, source_dock)
	vessel = owner
	RegisterSignal(owner, COMSIG_OVERMAP_NAVIGATION_ARRIVED, PROC_REF(on_navigation_arrived))
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
	if(vessel)
		UnregisterSignal(vessel, COMSIG_OVERMAP_NAVIGATION_ARRIVED)
	if(vessel?.programmed_mission == src)
		vessel.flight?.set_autopilot(FALSE, manual = FALSE)
		QDEL_NULL(vessel.docking_approach)
	if(vessel?.programmed_mission == src)
		vessel.programmed_mission = null
	vessel = null
	dest_host = null
	return ..()

/datum/overmap_programmed_mission/proc/on_navigation_arrived(datum/source)
	SIGNAL_HANDLER
	INVOKE_ASYNC(src, PROC_REF(navigation_arrived))

/datum/overmap_programmed_mission/proc/navigate_to(world_x, world_y, heading, obj/overmap/entity/host)
	vessel.flight.navigate_world(world_x, world_y, heading, host, arrival_range = 1, ignore_collisions = TRUE, known_obstacles_only = FALSE, entry_box = navigation_entry_box)

/datum/overmap_programmed_mission/proc/eta_string()
	if(QDELETED(vessel))
		return "00:00"
	var/left = max(0, vessel.estimate_programmed_trip(dock_id, src))
	var/seconds = round(left / 10)
	return "[add_zero(num2text(round(seconds / 60)), 2)]:[add_zero(num2text(seconds % 60), 2)]"

/datum/overmap_programmed_mission/proc/process_mission()
	set waitfor = FALSE
	if(processing || QDELETED(vessel) || QDELETED(src) || vessel.relay_capture)
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
		var/obj/overmap/entity/hyperrelay/portal_relay = route_relay()
		if(portal_relay?.template_loaded)
			navigate_relay_portal(portal_relay)
			return
		if(on_route_relay() && OVERMAP_SPEED_STOPPED(vessel.get_speed()))
			on_overmap_arrived()
			return
		var/turf/relay_turf = route_relay()?.get_overmap_turf()
		if(!relay_turf || !here || relay_turf.z != here.z)
			return
		if(vessel.flight)
			vessel.flight.cruise_speed = OVERMAP_FROM_DISPLAY(OVERMAP_PROGRAMMED_CRUISE)
		var/obj/overmap/entity/hyperrelay/relay = route_relay()
		navigate_to(relay.get_world_x(), relay.get_world_y())
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
