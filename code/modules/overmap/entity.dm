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
	for(var/datum/tgui/ui as anything in radar_uis.Copy())
		unwatch_radar(ui)
	QDEL_NULL(programmed_mission)
	QDEL_NULL(docking_approach)
	if(docked_ship)
		undock_ship()
	for(var/obj/overmap/entity/guest as anything in docked_guests.Copy())
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
