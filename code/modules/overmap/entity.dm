/obj/overmap/entity
	name = "vessel"
	icon_state = "ship"
	movable = TRUE
	overmap_kind = OVERMAP_KIND_STATION
	map_color = "#7ec8e3"

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
	/// Faction IFF ids. `list(OVERMAP_IFF_SYNDICATE)` = listen+TX. Assoc FALSE = key loaded, TX off. Global TX is identity_broadcasting.
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

/obj/overmap/entity/shuttle
	name = "shuttle"
	icon_state = "shuttle_c"
	overmap_kind = OVERMAP_KIND_SHUTTLE
	vessel_flags = OVERMAP_VESSEL_SHUTTLE
	vessel_mass = 500
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
	overmap_kind = OVERMAP_KIND_STATION
	vessel_flags = OVERMAP_VESSEL_STATION

/obj/overmap/entity/shuttle/add_overmap_components()
	AddComponent(/datum/component/overmap_sensors)
	AddComponent(/datum/component/overmap_flight)
	AddComponent(/datum/component/overmap_shuttle)

/obj/overmap/entity/Destroy()
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
	for(var/obj/machinery/computer/engines/console as anything in engine_consoles)
		if(console.vessel == src)
			console.vessel = null
	engine_consoles.Cut()
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
	return ..()

/obj/overmap/entity/proc/register_engine(obj/machinery/ship_engine/engine)
	engines |= engine
	engine.vessel = src

/obj/overmap/entity/proc/unregister_engine(obj/machinery/ship_engine/engine)
	engines -= engine
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
	SEND_SIGNAL(src, COMSIG_OVERMAP_MOVED)

/obj/overmap/entity/on_overmap_loc_changed()
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
	return pad && !istype(pad, /obj/docking_port/stationary/transit)

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

/obj/overmap/entity/proc/get_shuttle_phase_text()
	if(!shuttle)
		return null
	switch(shuttle.mode)
		if(SHUTTLE_IDLE)
			return "Готов"
		if(SHUTTLE_IGNITING)
			return "Зажигание двигателей"
		if(SHUTTLE_CALL)
			return "В пути"
		if(SHUTTLE_DOCKED)
			return "На площадке"
		if(SHUTTLE_RECHARGING)
			return "Перезарядка"
		if(SHUTTLE_RECALL)
			return "Возврат"
		if(SHUTTLE_ENDGAME)
			return "Конец"
		if(SHUTTLE_ESCAPE)
			return "Эвакуация"
		if(SHUTTLE_STRANDED)
			return "Заблокирован"
	return shuttle.mode

/obj/overmap/entity/proc/can_helm_undock()
	if(overmap_pod)
		return overmap_pod.is_landed() && overmap_pod.can_undock_here()
	return overmap_shuttle && is_physically_docked()

/obj/overmap/entity/proc/can_helm_physical_dock()
	if(overmap_pod)
		return overmap_pod.can_physical_dock()
	if(!overmap_shuttle || is_physically_docked() || !isturf(loc) || !get_dock_host())
		return FALSE
	return OVERMAP_SPEED_STOPPED(get_speed())

/obj/overmap/entity/proc/can_helm_edge_dock()
	return overmap_pod?.can_edge_dock() && overmap_pod.can_physical_dock()

/obj/overmap/entity/proc/can_helm_custom_dock()
	return overmap_shuttle && shuttle && allows_custom_landing()
