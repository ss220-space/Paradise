/datum/component/overmap_shuttle
	dupe_mode = COMPONENT_DUPE_UNIQUE
	var/list/owned_dock_ids_cache
	var/owned_docks_dirty = TRUE

/datum/component/overmap_shuttle/Initialize()
	if(!istype(parent, /obj/overmap/entity))
		return COMPONENT_INCOMPATIBLE

/datum/component/overmap_shuttle/RegisterWithParent()
	var/obj/overmap/entity/token = parent
	token.overmap_shuttle = src

/datum/component/overmap_shuttle/UnregisterFromParent()
	var/obj/overmap/entity/token = parent
	if(token.overmap_shuttle == src)
		token.overmap_shuttle = null
	if(token.shuttle)
		UnregisterSignal(token.shuttle, COMSIG_SHUTTLE_DOCK)

/datum/component/overmap_shuttle/proc/bind(obj/docking_port/mobile/port)
	var/obj/overmap/entity/vessel = parent
	if(!port || vessel.shuttle == port)
		if(port)
			RegisterSignal(port, COMSIG_SHUTTLE_DOCK, PROC_REF(on_physical_shuttle_dock), override = TRUE)
		ensure_default_collar()
		recalculate_mass()
		return
	if(vessel.shuttle)
		UnregisterSignal(vessel.shuttle, COMSIG_SHUTTLE_DOCK)
	vessel.shuttle = port
	RegisterSignal(port, COMSIG_SHUTTLE_DOCK, PROC_REF(on_physical_shuttle_dock))
	owned_docks_dirty = TRUE
	ensure_default_collar()
	recalculate_mass()

/datum/component/overmap_shuttle/proc/recalculate_mass()
	var/obj/overmap/entity/vessel = parent
	if(!vessel.shuttle)
		if(vessel.overmap_kind == OVERMAP_KIND_STATION)
			vessel.vessel_mass = OVERMAP_MASS_STATION
		return
	var/turfs = 0
	for(var/area/place as anything in vessel.shuttle.shuttle_areas)
		for(var/turf/hull in place)
			turfs++
	vessel.vessel_mass = OVERMAP_MASS_BASE + turfs * OVERMAP_MASS_PER_TURF

/datum/component/overmap_shuttle/proc/play_area_sound(soundfile)
	var/obj/overmap/entity/vessel = parent
	if(!soundfile || !vessel.shuttle?.areaInstance)
		return
	SEND_SOUND(vessel.shuttle.areaInstance, sound(soundfile))

/datum/component/overmap_shuttle/proc/get_owned_dock_ids()
	var/obj/overmap/entity/vessel = parent
	if(!owned_docks_dirty && owned_dock_ids_cache)
		return owned_dock_ids_cache
	. = list()
	if(!vessel.shuttle)
		owned_dock_ids_cache = .
		owned_docks_dirty = FALSE
		return
	if(vessel.last_dock_id)
		.[vessel.last_dock_id] = TRUE
	if(vessel.selected_dock_id)
		.[vessel.selected_dock_id] = TRUE
	for(var/host_uid in vessel.custom_docks)
		var/obj/docking_port/stationary/custom_pad = vessel.custom_docks[host_uid]
		if(custom_pad?.id)
			.[custom_pad.id] = TRUE
	if(vessel.shuttle.roundstart_move)
		.[vessel.shuttle.roundstart_move] = TRUE
	if(vessel.shuttle.id)
		var/prefix = "[vessel.shuttle.id]_"
		for(var/obj/docking_port/stationary/pad as anything in SSshuttle.stationary)
			if(istype(pad, /obj/docking_port/stationary/transit))
				continue
			if(pad.id == vessel.shuttle.id || (pad.id && findtext(pad.id, prefix) == 1))
				.[pad.id] = TRUE
	owned_dock_ids_cache = .
	owned_docks_dirty = FALSE

/datum/component/overmap_shuttle/proc/is_owned_dock(obj/docking_port/stationary/pad)
	if(!pad)
		return FALSE
	return get_owned_dock_ids()[pad.id]

/datum/component/overmap_shuttle/proc/is_station_dock(obj/docking_port/stationary/pad)
	if(!pad || istype(pad, /obj/docking_port/stationary/transit))
		return FALSE
	return is_station_level(pad.z)

/datum/component/overmap_shuttle/proc/get_custom_dock(obj/overmap/entity/host)
	var/obj/overmap/entity/vessel = parent
	if(!host)
		host = vessel.get_dock_host()
	if(!host || !vessel.custom_docks)
		return null
	return vessel.custom_docks[host.UID()]

/datum/component/overmap_shuttle/proc/is_custom_dock(obj/docking_port/stationary/pad)
	var/obj/overmap/entity/vessel = parent
	if(!pad || !vessel.custom_docks)
		return FALSE
	for(var/host_uid in vessel.custom_docks)
		if(vessel.custom_docks[host_uid] == pad)
			return TRUE
	return FALSE

/datum/component/overmap_shuttle/proc/host_pads(obj/overmap/entity/host)
	. = list()
	var/obj/overmap/entity/vessel = parent
	if(!host)
		return
	for(var/obj/docking_port/stationary/pad as anything in SSshuttle.stationary)
		if(!pad || istype(pad, /obj/docking_port/stationary/transit))
			continue
		if(pad.hidden && !is_custom_dock(pad))
			continue
		if(!is_custom_dock(pad) && !istype(pad, /obj/docking_port/stationary/overmap) && !pad.dock_airlock)
			if(!is_owned_dock(pad))
				continue
		if(!vessel.pad_matches_host(pad, host))
			continue
		. += pad
	for(var/obj/machinery/landing_beacon/beacon as anything in GLOB.landing_beacons)
		if(QDELETED(beacon) || QDELETED(beacon.pad))
			continue
		if(beacon.pad in .)
			continue
		beacon.bind_pad_host()
		if(!vessel.pad_matches_host(beacon.pad, host))
			continue
		. += beacon.pad
	var/obj/docking_port/stationary/custom_pad = get_custom_dock(host)
	if(custom_pad && !(custom_pad in .))
		. += custom_pad

/datum/component/overmap_shuttle/proc/get_undock_pad()
	var/obj/overmap/entity/vessel = parent
	if(!vessel.shuttle)
		return null
	vessel.shuttle.overmap_sync_bounds(TRUE)
	var/obj/docking_port/mobile/port = vessel.shuttle
	var/obj/docking_port/stationary/transit/pad = port.assigned_transit
	if(pad && !QDELETED(pad) && pad.reserved_area)
		var/need_w = SHUTTLE_TRANSIT_BORDER * 2
		var/need_h = SHUTTLE_TRANSIT_BORDER * 2
		switch(pad.dir)
			if(NORTH, SOUTH)
				need_w += port.width
				need_h += port.height
			else
				need_w += port.height
				need_h += port.width
		if(pad.reserved_area.width >= need_w && pad.reserved_area.height >= need_h)
			var/list/origin = port.overmap_origin()
			if(!port.overmap_uses_area_hull() || pad.dir == origin[2])
				return pad
		port.assigned_transit = null
		qdel(pad, TRUE)
	return SSshuttle.generate_transit_dock(port)

/datum/component/overmap_shuttle/proc/get_selected_pad()
	var/obj/overmap/entity/vessel = parent
	var/obj/overmap/entity/host = vessel.get_dock_host()
	if(!host || !vessel.shuttle)
		return null
	if(vessel.selected_dock_id == OVERMAP_DOCK_ID_CUSTOM)
		return get_custom_dock(host)
	var/pad_id = vessel.selected_dock_id || vessel.last_dock_id
	var/obj/docking_port/stationary/pad
	if(pad_id)
		pad = SSshuttle.getDock(pad_id)
	if(pad && vessel.pad_matches_host(pad, host) && !istype(pad, /obj/docking_port/stationary/transit))
		return pad
	var/obj/docking_port/stationary/custom_pad = get_custom_dock(host)
	if(custom_pad && vessel.shuttle.canDock(custom_pad) == SHUTTLE_CAN_DOCK)
		return custom_pad
	for(var/obj/docking_port/stationary/candidate as anything in host_pads(host))
		if(vessel.shuttle.canDock(candidate) == SHUTTLE_CAN_DOCK)
			return candidate
	return null

/datum/component/overmap_shuttle/proc/set_selected_pad(pad_id)
	var/obj/overmap/entity/vessel = parent
	if(!pad_id)
		return FALSE
	var/obj/overmap/entity/host = vessel.get_dock_host()
	if(pad_id == OVERMAP_DOCK_ID_CUSTOM)
		if(!host || !host.dock_host?.allow_custom_landing)
			return FALSE
		var/obj/docking_port/stationary/existing = get_custom_dock(host)
		vessel.selected_dock_id = existing?.id || OVERMAP_DOCK_ID_CUSTOM
		return TRUE
	var/obj/docking_port/stationary/custom_pad = get_custom_dock(host)
	if(custom_pad && pad_id == custom_pad.id)
		vessel.selected_dock_id = pad_id
		return TRUE
	var/obj/docking_port/stationary/pad = SSshuttle.getDock(pad_id)
	if(!pad || istype(pad, /obj/docking_port/stationary/transit))
		return FALSE
	if(!vessel.pad_matches_host(pad, host))
		return FALSE
	vessel.selected_dock_id = pad_id
	return TRUE

/datum/component/overmap_shuttle/proc/dock_fail_text(status)
	switch(status)
		if(SHUTTLE_CAN_DOCK)
			return null
		if(SHUTTLE_LOCKED)
			return "Шаттл заблокирован."
		if(SHUTTLE_NOT_A_DOCKING_PORT)
			return "Это не площадка стыковки."
		if(SHUTTLE_DWIDTH_TOO_LARGE)
			return "Шаттл не подходит по размеру."
		if(SHUTTLE_WIDTH_TOO_LARGE)
			return "Шаттл не подходит по размеру."
		if(SHUTTLE_DHEIGHT_TOO_LARGE)
			return "Шаттл не подходит по размеру."
		if(SHUTTLE_HEIGHT_TOO_LARGE)
			return "Шаттл не подходит по размеру."
		if(SHUTTLE_ALREADY_DOCKED)
			return "Уже пристыкованы к этой площадке."
		if(SHUTTLE_SOMEONE_ELSE_DOCKED)
			return "Площадка занята."
		if(SHUTTLE_LANDING_BLOCKED)
			return "Невозможная точка стыковки."
	return "Стыковка невозможна."

/datum/component/overmap_shuttle/proc/pad_list_state(can_status, current)
	if(current)
		return "here"
	switch(can_status)
		if(SHUTTLE_CAN_DOCK)
			return "free"
		if(SHUTTLE_SOMEONE_ELSE_DOCKED)
			return "busy"
		if(SHUTTLE_DWIDTH_TOO_LARGE, SHUTTLE_WIDTH_TOO_LARGE, SHUTTLE_DHEIGHT_TOO_LARGE, SHUTTLE_HEIGHT_TOO_LARGE, SHUTTLE_LANDING_BLOCKED)
			return "small"
	return "busy"

/datum/component/overmap_shuttle/proc/build_dock_list()
	. = list()
	var/obj/overmap/entity/vessel = parent
	if(!vessel.shuttle)
		return
	var/obj/overmap/entity/host = vessel.get_dock_host()
	if(!host)
		return
	var/current_id = vessel.shuttle.getDockedId()
	var/chosen_id = vessel.selected_dock_id || vessel.last_dock_id
	var/obj/docking_port/stationary/custom_pad = get_custom_dock(host)
	if(host?.dock_host?.allow_custom_landing)
		. += list(list(
			"id" = OVERMAP_DOCK_ID_CUSTOM,
			"name" = "Произвольная точка ([host.name])",
			"selected" = chosen_id == OVERMAP_DOCK_ID_CUSTOM || (custom_pad && chosen_id == custom_pad.id),
			"current" = custom_pad && custom_pad.id == current_id,
			"can_dock" = TRUE,
			"state" = "free",
			"reason" = custom_pad ? "Точка отмечена. Можно стыковаться или выбрать заново." : "Отметьте клетку камерой посадки.",
		))
	var/list/here_rows = list()
	var/list/free_rows = list()
	var/list/busy_rows = list()
	var/list/small_rows = list()
	for(var/obj/docking_port/stationary/pad as anything in host_pads(host))
		if(is_custom_dock(pad))
			continue
		if(!pad.overmap_dock_label)
			pad.apply_overmap_dock_role()
		var/can_status = vessel.shuttle.canDock(pad)
		var/current = pad.id == current_id
		var/state = pad_list_state(can_status, current)
		var/pad_name = pad.overmap_dock_label || pad.name
		if(pad.overmap_dock_mode == OVERMAP_DOCK_RESERVED)
			pad_name = "Зарезервированная область"
		var/list/row = list(
			"id" = pad.id,
			"name" = pad_name,
			"selected" = pad.id == chosen_id,
			"current" = current,
			"can_dock" = can_status == SHUTTLE_CAN_DOCK,
			"state" = state,
			"reason" = is_custom_dock(pad) ? "Произвольная точка этого сектора" : (dock_fail_text(can_status) || "Свободна"),
		)
		switch(state)
			if("here")
				here_rows += list(row)
			if("free")
				free_rows += list(row)
			if("small")
				small_rows += list(row)
			else
				busy_rows += list(row)
	. += here_rows + free_rows + busy_rows + small_rows

/datum/component/overmap_shuttle/proc/shuttle_collars()
	. = list()
	var/obj/overmap/entity/vessel = parent
	if(!vessel.shuttle)
		return
	for(var/area/place as anything in vessel.shuttle.shuttle_areas)
		for(var/obj/machinery/door/airlock/external/docking/door in place)
			if(door.overmap_is_support)
				continue
			. += door

/datum/component/overmap_shuttle/proc/ensure_default_collar()
	var/obj/overmap/entity/vessel = parent
	if(!vessel.shuttle)
		return
	if(vessel.shuttle.overmap_collar && !QDELETED(vessel.shuttle.overmap_collar))
		return
	var/list/collars = shuttle_collars()
	if(!length(collars))
		return
	var/turf/port_turf = get_turf(vessel.shuttle)
	for(var/obj/machinery/door/airlock/external/docking/door as anything in collars)
		if(get_turf(door) == port_turf)
			vessel.shuttle.overmap_collar = door
			return
	vessel.shuttle.overmap_collar = collars[1]

/datum/component/overmap_shuttle/proc/set_selected_collar(collar_uid)
	var/obj/overmap/entity/vessel = parent
	if(!vessel.shuttle)
		return FALSE
	for(var/obj/machinery/door/airlock/external/docking/door as anything in shuttle_collars())
		if(door.UID() == collar_uid)
			vessel.shuttle.overmap_collar = door
			return TRUE
	return FALSE

/datum/component/overmap_shuttle/proc/select_collar_by_key(key)
	var/obj/overmap/entity/vessel = parent
	if(!vessel.shuttle || !key)
		return FALSE
	var/obj/machinery/door/airlock/external/docking/named
	for(var/obj/machinery/door/airlock/external/docking/door as anything in shuttle_collars())
		if(door.overmap_collar_id == key)
			vessel.shuttle.overmap_collar = door
			return TRUE
		if(!named && door.dock_name == key)
			named = door
	if(named)
		vessel.shuttle.overmap_collar = named
		return TRUE
	return FALSE

/datum/component/overmap_shuttle/proc/build_collar_list()
	. = list()
	var/obj/overmap/entity/vessel = parent
	ensure_default_collar()
	var/selected = vessel.shuttle?.overmap_collar
	for(var/obj/machinery/door/airlock/external/docking/door as anything in shuttle_collars())
		. += list(list(
			"id" = door.UID(),
			"name" = door.get_helm_label(),
			"selected" = door == selected,
			"dir" = dir2text(door.dir),
		))

/datum/component/overmap_shuttle/proc/begin_physical_undock(instant = FALSE)
	var/obj/overmap/entity/vessel = parent
	if(vessel.overmap_kind != OVERMAP_KIND_SHUTTLE)
		return "Судно уже в открытом космосе."
	if(!vessel.shuttle)
		vessel.release_to_overmap()
		return TRUE
	if(!vessel.hull_needs_transit_undock())
		vessel.release_to_overmap()
		return TRUE
	if(!instant && vessel.shuttle.mode != SHUTTLE_IDLE && vessel.shuttle.mode != SHUTTLE_RECHARGING)
		return "Шаттл уже выполняет манёвр."
	var/datum/overmap_programmed_profile/profile = vessel.programmed_profile()
	if(instant && profile?.block_if_canMove && !vessel.shuttle.canMove())
		return profile.block_move_message || "Шаттл не может перемещаться с текущим грузом."
	vessel.last_dock_id = vessel.shuttle.getDockedId()
	if(vessel.last_dock_id && is_station_dock(SSshuttle.getDock(vessel.last_dock_id)))
		vessel.selected_dock_id = vessel.last_dock_id
	var/obj/docking_port/stationary/undock_pad = get_undock_pad()
	if(!undock_pad)
		return "Гиперпространство ещё не готово."
	var/can_status = vessel.shuttle.canDock(undock_pad)
	if(can_status != SHUTTLE_CAN_DOCK && can_status != SHUTTLE_ALREADY_DOCKED)
		return dock_fail_text(can_status)
	if(instant)
		if(can_status != SHUTTLE_ALREADY_DOCKED)
			vessel.shuttle.overmap_force_dock = TRUE
			if(vessel.shuttle.dock(undock_pad, force = TRUE, transit = TRUE))
				vessel.shuttle.overmap_force_dock = FALSE
				return "Не удалось уйти с площадки."
			vessel.shuttle.overmap_force_dock = FALSE
		vessel.release_to_overmap()
		owned_docks_dirty = TRUE
		return TRUE
	if(vessel.shuttle.request(undock_pad))
		return "Не удалось уйти с площадки."
	var/obj/overmap/entity/host = vessel.docked_to
	play_area_sound('sound/effects/hyperspace_begin.ogg')
	vessel.announce_sensor_event("Отстыковка: [vessel.get_overmap_display_name()][host ? " от [host.name]" : ""]", "undock")
	owned_docks_dirty = TRUE
	return TRUE

/datum/component/overmap_shuttle/proc/begin_physical_dock(instant = FALSE)
	var/obj/overmap/entity/vessel = parent
	if(vessel.overmap_kind != OVERMAP_KIND_SHUTTLE)
		return "Объект слишком большой для стыковки."
	if(!vessel.shuttle)
		return "Нет физического шаттла."
	if(vessel.is_physically_docked())
		return "Сначала отстыкуйтесь."
	if(vessel.status != OVERMAP_STATUS_OVERMAP && vessel.status != OVERMAP_STATUS_TRANSIT)
		return "Сначала отстыкуйтесь."
	if(vessel.is_moving() && !OVERMAP_SPEED_STOPPED(vessel.get_speed()))
		return "Сначала остановитесь."
	var/obj/overmap/entity/host = vessel.get_dock_host()
	if(!host)
		return "Не к чему стыковаться."
	if(!instant && (vessel.shuttle.mode == SHUTTLE_IGNITING || vessel.shuttle.mode == SHUTTLE_CALL || vessel.shuttle.mode == SHUTTLE_RECALL))
		return TRUE
	var/obj/docking_port/stationary/pad = get_selected_pad()
	if(!pad && (vessel.selected_dock_id == OVERMAP_DOCK_ID_CUSTOM || host?.dock_host?.allow_custom_landing))
		if(vessel.selected_dock_id == OVERMAP_DOCK_ID_CUSTOM || vessel.selected_dock_id == get_custom_dock(host)?.id)
			return OVERMAP_DOCK_NEED_CUSTOM_PICK
		if(!length(host_pads(host)))
			return OVERMAP_DOCK_NEED_CUSTOM_PICK
	if(!pad)
		return "Выберите площадку или кастомную точку стыковки."
	if(!vessel.pad_matches_host(pad, host))
		return "Эта точка стыковки относится к другому сектору."
	var/can_status = vessel.shuttle.canDock(pad)
	if(can_status != SHUTTLE_CAN_DOCK)
		return dock_fail_text(can_status)
	if(instant)
		if(vessel.shuttle.dock(pad, force = TRUE))
			return "Не удалось начать стыковку."
		return TRUE
	if(vessel.shuttle.request(pad))
		return "Не удалось начать стыковку."
	play_area_sound('sound/effects/hyperspace_begin.ogg')
	vessel.announce_sensor_event("Стыковка начата: [vessel.get_overmap_display_name()]", "dock")
	return TRUE

/datum/component/overmap_shuttle/proc/on_physical_shuttle_dock(obj/docking_port/mobile/port, obj/docking_port/stationary/new_dock)
	SIGNAL_HANDLER
	var/obj/overmap/entity/vessel = parent
	if(port != vessel.shuttle || QDELETED(new_dock))
		return
	owned_docks_dirty = TRUE
	if(istype(new_dock, /obj/docking_port/stationary/transit))
		vessel.status = OVERMAP_STATUS_OVERMAP
		vessel.halted = FALSE
		if(!isturf(vessel.loc))
			vessel.release_to_overmap()
		return
	if(!istype(new_dock, /obj/docking_port/stationary/overmap/landing))
		salvage_transit_leftovers(port)
	vessel.last_dock_id = new_dock.id
	if(!vessel.selected_dock_id)
		vessel.selected_dock_id = new_dock.id
	var/obj/overmap/entity/host = SSovermap?.resolve_nest_host(vessel.shuttle, new_dock)
	if(host && host != vessel)
		var/was_nested = vessel.docked_to
		vessel.nest_inside(host)
		if(host.sector)
			vessel.sector = host.sector
			host.sector.objects |= vessel
		vessel.shuttle.overmap_force_dock = FALSE
		play_area_sound('sound/effects/hyperspace_end.ogg')
		if(host != was_nested)
			vessel.announce_sensor_event("Стыковка завершена: [vessel.get_overmap_display_name()] → [host.name]", "dock")
		recalculate_mass()
		return
	if(vessel.docked_to)
		vessel.release_to_overmap()
	vessel.status = OVERMAP_STATUS_DOCKED
	vessel.halted = TRUE
	vessel.speed[1] = 0
	vessel.speed[2] = 0
	vessel.shuttle.overmap_force_dock = FALSE

/datum/component/overmap_shuttle/proc/salvage_transit_leftovers(obj/docking_port/mobile/port)
	var/obj/docking_port/stationary/transit/pad = port?.assigned_transit
	if(QDELETED(pad) || QDELETED(pad.reserved_area))
		return
	var/list/hull = pad.return_coords()
	var/hull_min_x = min(hull[1], hull[3])
	var/hull_min_y = min(hull[2], hull[4])
	var/hull_max_x = max(hull[1], hull[3])
	var/hull_max_y = max(hull[2], hull[4])
	for(var/turf/spot as anything in pad.reserved_area.reserved_turfs)
		for(var/atom/movable/thing in spot)
			if(!thing.simulated || istype(thing, /obj/docking_port) || isobserver(thing))
				continue
			if(hyperspace_too_close_to_border(spot))
				if(isspacepod(thing))
					var/obj/spacepod/craft = thing
					if(craft.overmap_vessel?.overmap_pod?.enter_hyperspace())
						continue
				delete_lost_in_hyperspace(thing)
				continue
			var/dx = 0
			var/dy = 0
			if(spot.x < hull_min_x)
				dx = hull_min_x - spot.x
			else if(spot.x > hull_max_x)
				dx = spot.x - hull_max_x
			if(spot.y < hull_min_y)
				dy = hull_min_y - spot.y
			else if(spot.y > hull_max_y)
				dy = spot.y - hull_max_y
			if(max(dx, dy) > OVERMAP_HYPERSPACE_HULL_KEEP)
				if(isspacepod(thing))
					var/obj/spacepod/stray = thing
					if(stray.overmap_vessel?.overmap_pod?.enter_hyperspace())
						continue
				delete_lost_in_hyperspace(thing)
				continue
			var/turf/dest = locate(port.x + (thing.x - pad.x), port.y + (thing.y - pad.y), port.z)
			if(istype(dest, /turf/space/transit))
				dest = null
			if(!dest)
				var/turf/here = get_turf(port)
				if(isspaceturf(here) && !istype(here, /turf/space/transit))
					dest = nearest_real_space_turf(here)
			if(!dest)
				delete_lost_in_hyperspace(thing)
				continue
			thing.forceMove(dest)

/datum/component/overmap_shuttle/proc/dock_with(atom/target)
	var/obj/overmap/portal/portal = target
	if(istype(portal))
		return portal.transit_vessel(parent)
	return "Нечего стыковать на этой клетке."

/obj/overmap/entity/proc/bind_shuttle_signals()
	overmap_shuttle?.bind(shuttle)

/obj/overmap/entity/proc/recalculate_mass()
	if(overmap_shuttle)
		overmap_shuttle.recalculate_mass()
	else if(overmap_kind == OVERMAP_KIND_STATION)
		vessel_mass = OVERMAP_MASS_STATION

/obj/overmap/entity/proc/nest_inside(obj/overmap/entity/host)
	if(!host)
		return
	docked_to?.dock_host?.remove_nested(src)
	docked_to = host
	status = OVERMAP_STATUS_DOCKED
	halted = TRUE
	speed[1] = 0
	speed[2] = 0
	host.dock_host?.add_nested(src)
	forceMove(host)
	if(host.sector)
		sector = host.sector
		host.sector.objects |= src
	position = list(0, 0)
	update_overmap_pixel()
	hidden_from_contacts = TRUE
	update_overmap_visibility()
	SEND_SIGNAL(src, COMSIG_OVERMAP_NESTED, host)
	SEND_SIGNAL(src, COMSIG_OVERMAP_MOVED)

/obj/overmap/entity/proc/release_to_overmap(turf/open_turf)
	if(!open_turf)
		open_turf = docked_to?.get_overmap_turf() || get_overmap_turf()
	var/datum/overmap_sector/dest_sector = docked_to?.sector || sector || SSovermap?.sector_for_turf(open_turf) || SSovermap?.local_sector
	var/list/saved_position
	if(docked_to)
		saved_position = list(docked_to.position[1], docked_to.position[2])
	docked_to?.dock_host?.remove_nested(src)
	docked_to = null
	status = OVERMAP_STATUS_OVERMAP
	halted = FALSE
	hidden_from_contacts = FALSE
	if(!open_turf && dest_sector)
		open_turf = dest_sector.get_random_open_turf()
	if(open_turf)
		forceMove(open_turf)
	if(dest_sector && dest_sector != sector)
		sector?.remove_object(src)
		dest_sector.add_object(src, open_turf)
	else if(dest_sector)
		sector = dest_sector
		dest_sector.objects |= src
	if(saved_position)
		position = saved_position
		update_overmap_pixel()
	update_overmap_visibility()
	SEND_SIGNAL(src, COMSIG_OVERMAP_RELEASED)
	SEND_SIGNAL(src, COMSIG_OVERMAP_MOVED)

/obj/overmap/entity/proc/get_owned_dock_ids()
	return overmap_shuttle ? overmap_shuttle.get_owned_dock_ids() : list()

/obj/overmap/entity/proc/is_owned_dock(obj/docking_port/stationary/pad)
	return overmap_shuttle?.is_owned_dock(pad)

/obj/overmap/entity/proc/is_station_dock(obj/docking_port/stationary/pad)
	return overmap_shuttle?.is_station_dock(pad)

/obj/overmap/entity/proc/get_custom_dock(obj/overmap/entity/host)
	return overmap_shuttle?.get_custom_dock(host)

/obj/overmap/entity/proc/is_custom_dock(obj/docking_port/stationary/pad)
	return overmap_shuttle?.is_custom_dock(pad)

/obj/overmap/entity/proc/get_undock_pad()
	return overmap_shuttle?.get_undock_pad()

/obj/overmap/entity/proc/get_selected_pad()
	return overmap_shuttle?.get_selected_pad()

/obj/overmap/entity/proc/set_selected_pad(pad_id)
	if(overmap_pod)
		return overmap_pod.set_selected_pad(pad_id)
	return overmap_shuttle?.set_selected_pad(pad_id)

/obj/overmap/entity/proc/set_selected_collar(collar_uid)
	return overmap_shuttle?.set_selected_collar(collar_uid)

/obj/overmap/entity/proc/select_collar_by_key(key)
	return overmap_shuttle?.select_collar_by_key(key)

/obj/overmap/entity/proc/build_collar_list()
	return overmap_shuttle ? overmap_shuttle.build_collar_list() : list()

/obj/overmap/entity/proc/dock_fail_text(status)
	return overmap_shuttle ? overmap_shuttle.dock_fail_text(status) : "Стыковка невозможна."

/obj/overmap/entity/proc/build_dock_list()
	if(overmap_pod)
		return overmap_pod.build_dock_list()
	return overmap_shuttle ? overmap_shuttle.build_dock_list() : list()

/obj/overmap/entity/proc/begin_physical_undock(instant = FALSE)
	if(overmap_pod)
		return overmap_pod.begin_undock()
	return overmap_shuttle ? overmap_shuttle.begin_physical_undock(instant) : "Нет шаттла."

/obj/overmap/entity/proc/begin_physical_dock(instant = FALSE)
	if(overmap_pod)
		return overmap_pod.begin_dock()
	return overmap_shuttle ? overmap_shuttle.begin_physical_dock(instant) : "Нет шаттла."

/obj/overmap/entity/proc/dock_with(atom/target)
	if(overmap_shuttle)
		return overmap_shuttle.dock_with(target)
	var/obj/overmap/portal/portal = target
	if(istype(portal))
		return portal.transit_vessel(src)
	return "Нечего стыковать."

/obj/overmap/entity/proc/can_use_portal(obj/overmap/portal/portal)
	if(!portal.required_vessel_flags)
		return TRUE
	return (vessel_flags & portal.required_vessel_flags) == portal.required_vessel_flags
