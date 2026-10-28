/obj/overmap/entity
	name = "vessel"
	icon_state = "ship"
	movable = TRUE
	overmap_kind = OVERMAP_KIND_STATION
	map_color = "#7ec8e3"

	var/project_terrain = TRUE
	var/vessel_flags = OVERMAP_VESSEL_STATION
	var/status = OVERMAP_STATUS_OVERMAP
	var/vessel_mass = 10000
	var/list/obj/machinery/ship_engine/engines = list()
	var/obj/overmap/entity/docked_to
	var/obj/docking_port/mobile/shuttle
	var/list/obj/machinery/computer/helm/helms = list()

	var/list/obj/machinery/computer/engines/engine_consoles = list()
	var/list/obj/machinery/computer/sensors/sensors = list()
	var/list/obj/machinery/sensor_array/sensor_arrays = list()
	var/long_sensors_on = FALSE
	var/short_sensors_on = FALSE
	var/sensor_ping_until = 0
	var/sensor_next_ping = 0

	var/sensor_peel_at = 0

	var/short_peel_at = 0
	var/list/sensor_journal
	var/selected_dock_id
	var/last_dock_id

	var/list/obj/docking_port/stationary/custom_docks
	var/obj/machinery/transponder/transponder
	var/identity_name
	var/identity_color = COLOR_WHITE
	var/identity_icon
	var/identity_distress = FALSE
	var/identity_broadcasting = TRUE
	var/identity_locked = FALSE
	var/list/identity_iff_ids
	var/overmap_icon_preset = "station"
	var/overmap_icon_file = OVERMAP_ICON_FILE
	var/overmap_icon_moving_state
	var/overmap_icon_directional = FALSE
	var/datum/component/overmap_flight/flight
	var/datum/component/overmap_shuttle/overmap_shuttle
	var/datum/component/overmap_pod/overmap_pod
	var/datum/component/overmap_dock_host/dock_host
	var/datum/component/overmap_sensors/sensor_pack
	var/list/datum/overmap_iff_channel/virtual_iff_channels
	var/overmap_jammed_until = 0
	var/overmap_jam_was_halted = FALSE
	var/next_overmap_hazard_carp = 0
	var/next_overmap_hazard_hit = 0
	var/programmed = FALSE
	var/datum/overmap_programmed_mission/programmed_mission
	var/programmed_emag_until = 0
	var/programmed_emag_ready = 0
	var/programmed_emag_home_dock
	var/programmed_emag_dest_dock

	var/programmed_emag_resume_dock
	var/programmed_selected_dock
	var/programmed_has_routes = TRUE
	var/obj/machinery/ship_engine/virtual_engine
	var/admin_virtual_engine = FALSE
	var/free_flight_view = FALSE
	var/list/hull_turfs

	var/list/hull_area_turfs
	var/list/hull_watch
	var/hull_dirty = FALSE

	var/hull_version = 0

	var/next_hull_resync = 0
	var/list/hull_edge
	var/hull_inertia = 1
	var/hull_center_x
	var/hull_center_y
	var/hull_z
	var/hull_radius = 0
	var/list/flight_bounds
	var/list/datum/hull_proxy/neighbor_proxies = list()
	var/list/obj/overmap/entity/nearby_ships = list()
	var/next_moved_signal = 0
	var/list/obj/effect/abstract/hull_proxy_tile/drifter_mirrors = list()
	var/list/hull_collars
	var/list/radar_shape
	var/datum/turf_reservation/flight_reservation
	var/obj/overmap/entity/docked_ship
	var/list/obj/overmap/entity/docked_guests = list()
	var/dock_hull_x
	var/dock_hull_y
	var/dock_facing_offset
	var/dock_collar_angle
	var/turf/dock_host_collar
	var/list/undock_origin

	var/datum/overmap_bubble/physical_space

	var/obj/overmap/entity/undock_host
	var/datum/overmap_bubble/local_space
	var/datum/terrain_mirror/terrain_view
	var/last_world_x
	var/last_world_y
	var/last_facing = 0
	var/next_ram_effect = 0
	var/jump_spool_end = 0
	var/jump_start_time = 0
	var/jump_duration
	var/list/jump_origin
	var/list/jump_target
	var/list/obj/effect/abstract/dock_seal/dock_seals = list()
	var/obj/overmap/entity/hyperrelay/relay_jump_from
	var/relay_jump_started = 0
	var/relay_jump_ends = 0
	var/list/scatter_proxies = list()
	var/datum/fog_scene/scatter/scatter_fog
	var/list/scatter_candidates = list()
	var/list/radar_scatter = list()
	var/list/pushed_scatter
	var/scatter_radar_key
	var/obj/overmap/entity/station_docking_zone/undock_zone
	var/datum/overmap_docking_approach/docking_approach
	var/list/radar_docks_cache
	var/radar_docks_until = 0
	var/formation_transfer = FALSE
	var/obj/docking_port/stationary/overmap/formation/formation_pad
	var/next_ram_damage = 0
	var/list/radar_terrain_cache
	var/radar_terrain_key
	var/radar_terrain_until = 0
	var/radar_outline_cache
	var/radar_outline_version = -1
	var/radar_outline_until = 0
	var/radar_outline_busy = FALSE
	var/radar_snapshot_tick = -1
	var/radar_snapshot_epoch = -1
	var/list/radar_snapshots = list()
	var/turf/radar_docked_at
	var/radar_docked_dir
	var/radar_epoch = 0
	var/radar_transitioning = FALSE
	var/list/radar_uis = list()
	var/list/radar_motion_frame
	var/radar_motion_epoch
	var/datum/overmap_sector/radar_motion_sector
	var/list/radar_object_sources = list()
	var/datum/overmap_sector/radar_objects_sector
	var/list/ship_weapons_cache
	var/ship_weapons_until = 0

/obj/overmap/entity/shuttle
	name = "shuttle"
	icon_state = "shuttle_c"
	overmap_kind = OVERMAP_KIND_SHUTTLE
	vessel_flags = OVERMAP_VESSEL_SHUTTLE
	vessel_mass = 500 * OVERMAP_DYNAMIC_MASS_MULTIPLIER
	map_color = "#e3c56e"
	overmap_icon_preset = "shuttle_c"
	status = OVERMAP_STATUS_DOCKED
	hidden_from_contacts = TRUE

/obj/overmap/entity/pod
	name = "spacepod"
	icon_state = OVERMAP_ICON_POD
	overmap_kind = OVERMAP_KIND_POD
	vessel_flags = OVERMAP_VESSEL_POD
	vessel_mass = OVERMAP_POD_MASS
	map_color = "#c8d4a0"
	overmap_icon_preset = "pod"
	status = OVERMAP_STATUS_DOCKED
	hidden_from_contacts = TRUE
	rotate_sprite_with_heading = TRUE
	var/obj/spacepod/pod

/obj/overmap/entity/pod/add_overmap_components()
	AddComponent(/datum/component/overmap_sensors)
	AddComponent(/datum/component/overmap_flight)
	AddComponent(/datum/component/overmap_pod)

/obj/overmap/entity/pod/Destroy()
	if(pod)
		if(SSovermap?.pod_vessels && SSovermap.pod_vessels[pod] == src)
			SSovermap.pod_vessels -= pod
		if(pod.overmap_vessel == src)
			pod.overmap_vessel = null
		pod = null
	return ..()

/obj/overmap/entity/Initialize(mapload)
	. = ..()
	SSovermap.vessels += src
	add_overmap_components()
	update_overmap_visibility()
	RegisterSignal(src, COMSIG_OVERMAP_MANUAL_CONTROL, PROC_REF(on_manual_overmap_control))

/obj/overmap/entity/proc/add_overmap_components()
	AddComponent(/datum/component/overmap_sensors)
	AddComponent(/datum/component/overmap_dock_host, OVERMAP_DOCK_Z_STATION)

/obj/overmap/entity/station
	movable = FALSE
	halted = TRUE

/obj/overmap/entity/shuttle/add_overmap_components()
	AddComponent(/datum/component/overmap_sensors)
	AddComponent(/datum/component/overmap_flight)
	AddComponent(/datum/component/overmap_shuttle)

/obj/overmap/entity/Destroy()
	for(var/datum/tgui/ui as anything in radar_uis)
		unwatch_radar(ui)
	QDEL_NULL(programmed_mission)
	QDEL_NULL(docking_approach)
	if(docked_ship)
		undock_ship()
	for(var/obj/overmap/entity/guest as anything in docked_guests)
		guest.undock_ship()
	docked_guests.Cut()
	if(physical_space?.host == src)
		QDEL_NULL(physical_space)
	undock_host = null
	SSovermap.vessels -= src
	for(var/obj/machinery/ship_engine/engine as anything in engines)
		if(engine.vessel == src)
			engine.vessel = null
	engines.Cut()
	if(virtual_engine)
		QDEL_NULL(virtual_engine)
	for(var/obj/machinery/computer/helm/helm as anything in helms)
		if(helm.vessel == src)
			helm.vessel = null
	helms.Cut()
	for(var/obj/machinery/computer/sensors/sensor as anything in sensors)
		if(sensor.vessel == src)
			sensor.vessel = null
	sensors.Cut()
	for(var/obj/machinery/sensor_array/array as anything in sensor_arrays)
		if(array.vessel == src)
			array.vessel = null
	sensor_arrays.Cut()
	if(shuttle && SSovermap.shuttle_vessels[shuttle] == src)
		SSovermap.shuttle_vessels -= shuttle
	if(transponder?.vessel == src)
		transponder.vessel = null
	transponder = null
	QDEL_LIST(virtual_iff_channels)
	clear_encounter_visuals()
	return ..()

/obj/overmap/entity/proc/register_engine(obj/machinery/ship_engine/engine)
	engines |= engine
	engine.vessel = src

/obj/overmap/entity/proc/unregister_engine(obj/machinery/ship_engine/engine)
	engines -= engine
	flight?.engine_torques -= engine
	flight?.engine_vectors -= engine
	if(engine.vessel == src)
		engine.vessel = null

/obj/overmap/entity/get_overmap_display_name()
	return identity_name || name || OVERMAP_UNKNOWN_NAME

/obj/overmap/entity/get_scan_mass()
	return vessel_mass

/obj/overmap/entity/is_overmap_visible()
	if(identity_distress)
		return TRUE
	if(transponder && (transponder.stat & (NOPOWER|BROKEN)))
		return FALSE
	return identity_broadcasting

/obj/overmap/entity/proc/is_overmap_jammed()
	return world.time < overmap_jammed_until

/obj/overmap/entity/proc/get_iff_channels()
	if(transponder)
		transponder.ensure_iff_channels()
		return transponder.iff_channels
	return virtual_iff_channels

/obj/overmap/entity/proc/identity_channel_transmits(id)
	if(id == OVERMAP_IFF_GLOBAL)
		return identity_broadcasting
	if(isnull(identity_iff_ids?[id]))
		return TRUE
	return !!identity_iff_ids[id]

/obj/overmap/entity/proc/rebuild_identity_iff()
	QDEL_LIST(virtual_iff_channels)
	virtual_iff_channels = list()
	virtual_iff_channels += new /datum/overmap_iff_channel(OVERMAP_IFF_GLOBAL, overmap_iff_label_for_id(OVERMAP_IFF_GLOBAL), TRUE, TRUE, identity_broadcasting)
	for(var/id in identity_iff_ids)
		if(id == OVERMAP_IFF_GLOBAL)
			continue
		virtual_iff_channels += new /datum/overmap_iff_channel(id, overmap_iff_label_for_id(id), TRUE, TRUE, identity_channel_transmits(id))

/obj/overmap/entity/proc/apply_overmap_identity(new_name, new_color, new_icon, new_distress, new_broadcasting, list/iff_ids, locked)
	if(new_name)
		identity_name = new_name
	if(!isnull(new_color))
		identity_color = new_color
	if(new_icon)
		identity_icon = new_icon
	identity_distress = !!new_distress
	if(!isnull(new_broadcasting))
		identity_broadcasting = new_broadcasting
	identity_locked = !!locked
	if(iff_ids)
		identity_iff_ids = iff_ids.Copy()
	rebuild_identity_iff()
	sync_transponder()

/obj/overmap/entity/proc/capture_iff_from_transponder(obj/machinery/transponder/beacon)
	if(!beacon)
		return
	QDEL_LIST(virtual_iff_channels)
	virtual_iff_channels = list()
	identity_iff_ids = list()
	for(var/datum/overmap_iff_channel/channel as anything in beacon.iff_channels)
		virtual_iff_channels += new /datum/overmap_iff_channel(channel.id, channel.label, channel.permanent, channel.receive, channel.transmit)
		if(channel.id != OVERMAP_IFF_GLOBAL)
			identity_iff_ids[channel.id] = channel.transmit
	identity_broadcasting = beacon.broadcasting

/obj/overmap/entity/proc/iff_detects(obj/overmap/other)
	if(!other || other == src)
		return FALSE
	var/obj/overmap/entity/contact = other
	if(!istype(contact))
		return FALSE
	if(contact.transponder && (contact.transponder.stat & (NOPOWER|BROKEN)) && !contact.identity_distress)
		return FALSE
	var/list/ours = get_iff_channels()
	var/list/theirs = contact.get_iff_channels()
	if(!length(ours) || !length(theirs))
		return FALSE
	for(var/datum/overmap_iff_channel/theirs_ch as anything in theirs)
		if(!theirs_ch.transmit)
			continue
		for(var/datum/overmap_iff_channel/ours_ch as anything in ours)
			if(ours_ch.id == theirs_ch.id && ours_ch.receive)
				return TRUE
	return FALSE

/obj/overmap/entity/proc/register_transponder(obj/machinery/transponder/new_transponder)
	if(transponder && transponder != new_transponder)
		transponder.vessel = null
	transponder = new_transponder
	sync_transponder()

/obj/overmap/entity/proc/unregister_transponder(obj/machinery/transponder/old_transponder)
	if(transponder == old_transponder)
		capture_iff_from_transponder(old_transponder)
		transponder = null
	sync_transponder()

/obj/overmap/entity/proc/apply_icon_preset(preset)
	overmap_icon_directional = FALSE
	overmap_icon_moving_state = null
	overmap_icon_file = OVERMAP_ICON_FILE
	switch(preset)
		if("station")
			overmap_icon_preset = "station"
			icon_state = OVERMAP_ICON_STATION
		if("pod")
			overmap_icon_preset = "pod"
			icon_state = OVERMAP_ICON_POD
		if("event")
			overmap_icon_preset = "event"
			icon_state = "event"
		else
			overmap_icon_preset = "shuttle_c"
			icon_state = OVERMAP_ICON_SHUTTLE_C
	rotate_sprite_with_heading = (overmap_kind == OVERMAP_KIND_POD)
	icon = overmap_icon_file
	if(!rotate_sprite_with_heading)
		transform = matrix()
	else
		last_overlay_heading = -1
		refresh_heading_overlay()
	update_icon(UPDATE_ICON_STATE | UPDATE_OVERLAYS)

/obj/overmap/entity/proc/sync_transponder()
	name = get_overmap_display_name()
	color = identity_color || "#fffffe"
	map_color = identity_color || map_color
	var/preset = identity_icon
	if(!preset)
		if(overmap_kind == OVERMAP_KIND_STATION)
			preset = "station"
		else if(overmap_kind == OVERMAP_KIND_POD)
			preset = "pod"
		else if(overmap_kind == OVERMAP_KIND_RUIN)
			preset = overmap_icon_preset || "event"
		else
			preset = "shuttle_c"
	apply_icon_preset(preset)
	update_overmap_visibility()
	SEND_SIGNAL(src, COMSIG_OVERMAP_DISPLAY_CHANGED)

/obj/overmap/entity/sync_inspect_follow()
	if(world.time < next_moved_signal)
		return
	next_moved_signal = world.time + OVERMAP_SLOW_TICK
	SEND_SIGNAL(src, COMSIG_OVERMAP_MOVED)

/obj/overmap/entity/on_overmap_loc_changed()
	if(radar_transitioning)
		return
	SEND_SIGNAL(src, COMSIG_OVERMAP_MOVED)

/obj/overmap/entity/proc/update_overmap_visibility()

	invisibility = INVISIBILITY_OBSERVER
	vis_flags |= VIS_HIDE
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	if(!identity_distress)
		alpha = 255
	update_icon(UPDATE_ICON_STATE | UPDATE_OVERLAYS)

/obj/overmap/entity/proc/process_transponder_fx()
	if(identity_distress && is_overmap_visible())
		alpha = (alpha > 80) ? 15 : 255
	else if(is_overmap_visible())
		alpha = 255

/obj/overmap/entity/update_icon_state()
	. = ..()
	switch(overmap_icon_preset)
		if("station")
			icon_state = OVERMAP_ICON_STATION
		if("pod")
			icon_state = OVERMAP_ICON_POD
		if("event")
			icon_state = "event"
		else
			icon_state = OVERMAP_ICON_SHUTTLE_C

/obj/overmap/entity/hyperrelay/update_icon_state()
	icon_state = "object"

/obj/overmap/entity/proc/is_physically_docked()
	if(!shuttle)
		return FALSE
	var/obj/docking_port/stationary/pad = shuttle.get_docked()
	return pad && !istype(pad, /obj/docking_port/stationary/transit) && !istype(pad, /obj/docking_port/stationary/overmap/formation)

/obj/overmap/entity/proc/hull_needs_transit_undock()
	if(!shuttle)
		return FALSE
	var/obj/docking_port/stationary/pad = shuttle.get_docked()
	if(istype(pad, /obj/docking_port/stationary/transit))
		return FALSE
	var/turf/spot = get_turf(shuttle)
	if(!spot)
		return FALSE
	if(SSovermap?.sector_for_turf(spot))
		return FALSE
	return TRUE

/obj/overmap/entity/proc/on_manual_overmap_control()
	SIGNAL_HANDLER
	abort_cancellable_mission()

/obj/overmap/entity/shows_overmap_map_signature()
	if(!isturf(loc) || docked_to || is_physically_docked())
		return FALSE
	return TRUE

/obj/overmap/entity/proc/get_helm_status_text()
	if(is_physically_docked())
		return docked_to ? "Пристыкован: [docked_to.name]" : "Пристыкован"
	switch(status)
		if(OVERMAP_STATUS_DOCKED)
			return docked_to ? "Пристыкован: [docked_to.name]" : "Пристыкован"
		if(OVERMAP_STATUS_TRANSIT)
			if(!isturf(loc))
				return "Выход в гиперпространство"
			return "Гиперпространство"
	if(is_moving())
		return "В полёте"
	if(halted)
		return "Стоит"
	return "Дрейф"

/obj/overmap/entity/proc/can_helm_undock()
	if(overmap_pod)
		return overmap_pod.is_landed() && overmap_pod.can_undock_here()
	return overmap_shuttle && !overmap_shuttle.preparing_undock && !shuttle?.transfer_busy && is_physically_docked()

/obj/overmap/entity/proc/can_helm_physical_dock()
	if(overmap_pod)
		return overmap_pod.can_physical_dock()
	if(!overmap_shuttle || is_physically_docked() || !isturf(loc) || !get_dock_host())
		return FALSE
	return OVERMAP_SPEED_STOPPED(get_speed())

/obj/overmap/entity/proc/can_helm_edge_dock()
	return overmap_pod?.can_edge_dock() && overmap_pod.can_physical_dock()

/obj/overmap/entity/proc/ship_power_report()
	. = list(
		"apc_charge" = 0,
		"apc_max" = 0,
		"smes_charge" = 0,
		"smes_max" = 0,
		"sources" = 0,
	)
	if(!shuttle)
		return
	for(var/area/place as anything in shuttle.shuttle_areas)
		for(var/obj/machinery/power/apc/unit as anything in place.apc)
			var/obj/item/stock_parts/cell/cell = unit.cell
			if(!cell)
				continue
			.["sources"]++
			.["apc_charge"] += cell.charge
			.["apc_max"] += cell.maxcharge
		for(var/obj/machinery/power/smes/battery in place)
			.["sources"]++
			.["smes_charge"] += battery.charge
			.["smes_max"] += battery.capacity

/obj/overmap/entity/proc/autopilot_eta()
	var/datum/component/overmap_flight/nav = flight
	if(!nav || !nav.autopilot || isnull(nav.autopilot_x) || isnull(nav.autopilot_y) || !sector)
		return 0
	var/turf/here = get_overmap_turf()
	var/turf/target = sector.get_turf_at(nav.autopilot_x, nav.autopilot_y)
	if(!here || !target || here.z != target.z)
		return 0
	var/span = OVERMAP_TILE_SPAN * (sector.tile_travel || 1)
	var/distance = sqrt((target.x * span - get_world_x()) ** 2 + (target.y * span - get_world_y()) ** 2)
	var/speed = max(get_speed(), nav.cruise_speed) * span
	if(speed <= 0)
		return 0
	return round(distance / speed)

/obj/overmap/entity/proc/thrust_diagnosis()
	var/datum/component/overmap_flight/nav = flight
	if(!nav)
		return "нет полётного компонента"
	if(!length(engines))
		return "на борту нет двигателей"
	if(!nav.engines_state)
		return "двигатели заглушены"
	if(nav.thrust_limit <= 0)
		return "общий лимит тяги 0%"
	var/working = 0
	var/off = 0
	var/dead = 0
	for(var/obj/machinery/ship_engine/engine as anything in engines)
		if(!engine.on)
			off++
			continue
		if(engine.stat & (BROKEN|NOPOWER))
			dead++
			continue
		working++
	if(!working)
		if(off && dead)
			return "двигатели выключены, часть без питания или повреждена"
		if(off)
			return "все двигатели выключены"
		if(dead)
			return "двигатели без питания или повреждены"
		return "двигатели не дают тяги"
	if(!nav.omni_thrust && !nav.strongest_thrust())
		return "двигатели не дают тяги ни в одну сторону"
	return ""

/obj/overmap/entity/proc/get_dock_host()
	RETURN_TYPE(/obj/overmap/entity)
	if(docked_to)
		return docked_to
	if(in_station_docking_zone())
		return SSovermap.station_entity
	var/turf/here = get_overmap_turf()
	if(!here)
		return null
	for(var/datum/component/overmap_dock_host/host as anything in SSovermap.dock_hosts)
		if(QDELETED(host) || host.parent == src)
			continue
		var/obj/overmap/entity/token = host.parent
		if(token.get_overmap_turf() == here)
			return token
	for(var/obj/overmap/entity/other in here)
		if(other != src && other.dock_host)
			return other
	for(var/obj/overmap/planet/planet in sector?.objects)
		if(planet.outpost && planet.covers_turf(here))
			return planet.outpost
	return null

/obj/overmap/entity/proc/pad_matches_host(obj/docking_port/stationary/pad, obj/overmap/entity/host)
	if(!pad || !host)
		return FALSE
	if(host == SSovermap.station_entity && in_station_docking_zone() && !SSovermap.station_docking_zone.accepts_pad(pad))
		return FALSE
	if(istype(pad, /obj/docking_port/stationary/transit))
		return FALSE
	SSovermap?.host_for_pad(pad)
	if(pad.overmap_host_uid)
		return pad.overmap_host_uid == host.UID()
	return host.dock_host?.matches_pad(pad)

/obj/overmap/entity/proc/get_total_thrust()
	return flight ? flight.get_total_thrust() : 0

/obj/overmap/entity/proc/get_acceleration()
	return flight ? flight.get_acceleration() : 0

/obj/overmap/entity/proc/has_working_engines()
	return !!flight?.has_working_engines()

/obj/overmap/entity/proc/can_steer()
	return !!flight?.can_steer()

/obj/overmap/entity/proc/set_held_brake(enabled)
	return flight?.set_held_brake(enabled)

/obj/overmap/entity/proc/cut_engines()
	return flight?.cut_engines()

/obj/overmap/entity/proc/get_effective_acceleration()
	return get_acceleration()

/obj/overmap/entity/proc/get_brake_distance()
	return flight ? flight.get_brake_distance() : 0

/obj/overmap/entity/proc/set_autopilot(enabled, dest_x, dest_y)
	flight?.set_autopilot(enabled, dest_x, dest_y)

/obj/overmap/entity/proc/register_sensor(obj/machinery/computer/sensors/sensor)
	sensors |= sensor
	sensor.vessel = src

/obj/overmap/entity/proc/unregister_sensor(obj/machinery/computer/sensors/sensor)
	sensors -= sensor
	if(sensor.vessel == src)
		sensor.vessel = null

/obj/overmap/entity/proc/register_sensor_array(obj/machinery/sensor_array/array)
	sensor_arrays |= array
	array.vessel = src
	sensor_pack?.sync_sensor_array_power()

/obj/overmap/entity/proc/unregister_sensor_array(obj/machinery/sensor_array/array)
	sensor_arrays -= array
	if(array.vessel == src)
		array.vessel = null
	if(!has_working_sensor(OVERMAP_SENSOR_KIND_LONG))
		long_sensors_on = FALSE
	if(!has_working_sensor(OVERMAP_SENSOR_KIND_SHORT))
		short_sensors_on = FALSE
	sensor_pack?.sync_peel_sound()
	sensor_pack?.sync_sensor_array_power()
	sensor_pack?.refresh_sensor_displays()

/obj/overmap/entity/proc/has_working_sensor(kind)
	return sensor_pack?.has_working_sensor(kind)

/obj/overmap/entity/proc/sensor_ping_active()
	return sensor_pack?.sensor_ping_active()

/obj/overmap/entity/proc/signal_view_range()
	return sensor_pack ? sensor_pack.signal_view_range() : 0

/obj/overmap/entity/proc/sensor_journal_range()
	return sensor_pack ? sensor_pack.sensor_journal_range() : 0

/obj/overmap/entity/proc/can_receive_sensor_log()
	return sensor_pack?.can_receive_sensor_log()

/obj/overmap/entity/proc/add_sensor_journal(message, kind, turf/spot, display_name, tone, note)
	sensor_pack?.add_sensor_journal(message, kind, spot, display_name, tone, note)

/obj/overmap/entity/proc/senses_object(obj/overmap/other)
	return sensor_pack?.senses_object(other)

/obj/overmap/entity/proc/contact_map_alpha(obj/overmap/other)
	return sensor_pack ? sensor_pack.contact_map_alpha(other) : 0

/obj/overmap/entity/proc/contact_is_steady(obj/overmap/other)
	return sensor_pack?.contact_is_steady(other)

/obj/overmap/entity/proc/sees_foreign_peel(obj/overmap/other)
	return sensor_pack?.sees_foreign_peel(other)

/obj/overmap/entity/proc/sees_any_foreign_peel()
	return sensor_pack?.sees_any_foreign_peel()

/obj/overmap/entity/proc/is_sensor_peeling()
	if(!sensor_peel_at)
		return FALSE
	return (world.time - sensor_peel_at) <= (OVERMAP_SENSOR_TIME_DELAY * OVERMAP_SENSOR_LONG_VIEW)

/obj/overmap/entity/proc/contact_identified(obj/overmap/other)
	return sensor_pack ? sensor_pack.contact_identified(other) : iff_detects(other)

/obj/overmap/entity/proc/set_long_sensors(enabled)
	return sensor_pack?.set_long_sensors(enabled)

/obj/overmap/entity/proc/set_short_sensors(enabled)
	return sensor_pack?.set_short_sensors(enabled)

/obj/overmap/entity/proc/can_short_scan(obj/overmap/other)
	return sensor_pack?.can_short_scan(other)

/obj/overmap/entity/proc/short_knows(obj/overmap/other)
	return sensor_pack?.short_knows(other)

/obj/overmap/entity/proc/display_identified(obj/overmap/other, short_console = FALSE)
	return sensor_pack?.display_identified(other, short_console)

/obj/overmap/entity/proc/identify_short(obj/overmap/other)
	sensor_pack?.identify_short(other)

/obj/overmap/entity/proc/identify_short_many(list/others)
	sensor_pack?.identify_short_many(others)

/obj/overmap/entity/proc/export_short_dump()
	return sensor_pack?.export_short_dump() || list()

/obj/overmap/entity/proc/import_short_dump(list/uids, source_name)
	return sensor_pack?.import_short_dump(uids, source_name) || 0

/obj/overmap/entity/proc/play_being_scanned()
	if(!shuttle)
		return
	for(var/area/place as anything in shuttle.shuttle_areas)
		for(var/mob/listener in place)
			if(!listener.client)
				continue
			listener.playsound_local(get_turf(listener), OVERMAP_SENSOR_LOOP_SOUND, 40, FALSE)

/obj/overmap/entity/proc/start_sensor_ping()
	return sensor_pack?.start_sensor_ping()

/obj/overmap/entity/proc/sync_sensor_array_power()
	sensor_pack?.sync_sensor_array_power()

/obj/overmap/entity/proc/refresh_sensor_displays()
	sensor_pack?.refresh_sensor_displays()

/obj/overmap/entity/proc/process_sensors()
	sensor_pack?.process_sensors()

/obj/overmap/entity/proc/is_long_range_detectable()
	return sensor_pack?.is_long_range_detectable()

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
	if(free_flight_view)
		set_free_flight_view(FALSE)
	update_overmap_visibility()
	SEND_SIGNAL(src, COMSIG_OVERMAP_MOVED)

/obj/overmap/entity/proc/release_to_overmap(turf/open_turf, list/world_position, initial_facing = null)
	radar_transitioning = TRUE
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
	if(world_position)
		set_world_position(world_position[1], world_position[2])
		if(!isnull(initial_facing))
			flight?.set_facing(initial_facing)
	if(!free_flight_view && ((shuttle && undock_origin && in_free_flight()) || (overmap_pod && world_position)))
		set_free_flight_view(TRUE)
	radar_epoch++
	radar_transitioning = FALSE
	update_overmap_visibility()
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
