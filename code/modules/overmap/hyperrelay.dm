/obj/overmap/entity/hyperrelay
	parent_type = /obj/overmap/entity/virtual_structure
	name = "Гипертранслятор"
	desc = "TEMP123TEMP"
	icon_state = "object"
	overmap_kind = OVERMAP_KIND_RELAY
	vessel_flags = NONE
	vessel_mass = 300
	map_color = "#c58cff"
	overmap_hazard_immune = TRUE
	var/obj/overmap/entity/hyperrelay/paired
	var/pair_id
	var/link_distance
	var/list/galaxy_route_points
	var/template_path = "_maps/map_files/overmap/hyperrelay.dmm"
	var/template_loaded = FALSE
	var/enabled = TRUE
	var/relay_facing = 0
	var/list/obj/effect/overmap_warp_portal/warp_portals = list()

/obj/overmap/entity/hyperrelay/proc/get_link_distance()
	if(!link_distance)
		link_distance = paired?.link_distance || rand(300, 1800)
	if(paired)
		paired.link_distance = link_distance
	return max(1, link_distance)

/obj/overmap/entity/hyperrelay/proc/update_destination_name()
	name = paired?.sector ? "[initial(name)] ([paired.sector.name])" : initial(name)
	identity_name = name

/obj/overmap/entity/proc/hyperrelay_jump_duration(obj/overmap/entity/hyperrelay/relay)
	return max(15 SECONDS, round(OVERMAP_HYPERRELAY_JUMP_TIME * relay.get_link_distance() / 1000))

/obj/overmap/entity/hyperrelay/Initialize(mapload)
	. = ..()
	if(. == INITIALIZE_HINT_QDEL)
		return
	return INITIALIZE_HINT_LATELOAD

/obj/overmap/entity/hyperrelay/LateInitialize()
	load_relay_template()
	if(!template_loaded)
		GLOB.overmap_virtual_structures -= src
	setup_virtual_iff()
	update_overmap_visibility()

/obj/overmap/entity/hyperrelay/Destroy()
	clear_warp_portals()
	SSovermap?.bump_galaxy()
	if(paired)
		if(paired.paired == src)
			paired.paired = null
		paired = null
	return ..()

/obj/overmap/entity/hyperrelay/add_overmap_components()
	return

/obj/overmap/entity/hyperrelay/get_overmap_display_name()
	return name

/obj/overmap/entity/hyperrelay/is_overmap_visible()
	return template_loaded

/obj/overmap/entity/hyperrelay/get_facing()
	return relay_facing

/obj/overmap/entity/hyperrelay/damage_cell(list/cell, damage)
	return

/obj/overmap/entity/hyperrelay/add_virtual_weapon(list/spec, x, y)
	return

/obj/overmap/entity/hyperrelay/in_free_flight()
	return template_loaded

/obj/overmap/entity/hyperrelay/sector_obstacle_box(span)
	return template_loaded ? ..() : null

/obj/overmap/entity/hyperrelay/proc/load_relay_template()
	var/path = template_path
	if(!fexists(path))
		path = "_maps/map_files/generic/hyperrelay.dmm"
	if(!fexists(path))
		path = "hyperrelay.dmm"
	if(!fexists(path))
		return FALSE
	var/datum/map_template/template = new(path, WRAP_FILE(path), name)
	template_loaded = load_template(template, FALSE)
	qdel(template)
	overmap_kind = OVERMAP_KIND_RELAY
	movable = FALSE
	halted = TRUE
	QDEL_LIST(virtual_iff_channels)
	if(!template_loaded)
		clear_warp_portals()
		QDEL_LIST_ASSOC_VAL(virtual_models)
		virtual_cells.Cut()
		hull_radius = 0
		return FALSE
	if(!length(warp_portals))
		var/portal_x
		var/portal_y
		var/nearest = INFINITY
		for(var/cell_x in 1 to template_width())
			for(var/cell_y in 1 to template_height())
				var/list/cell = virtual_cells["[cell_x],[cell_y]"]
				var/datum/overmap_virtual_model/model = cell?[3]
				var/distance = (cell_x - hull_center_x) ** 2 + (cell_y - hull_center_y) ** 2
				if(model?.solid || distance >= nearest)
					continue
				portal_x = cell_x
				portal_y = cell_y
				nearest = distance
		if(!isnull(portal_x))
			var/datum/overmap_virtual_model/model = new("/obj/effect/overmap_warp_portal,/turf/space")
			var/list/old_cell = virtual_cells["[portal_x],[portal_y]"]
			var/datum/overmap_virtual_model/old_model = old_cell?[3]
			if(old_model)
				model.visual.overlays += old_model.visual
			virtual_models["__relay_portal"] = model
			virtual_cells["[portal_x],[portal_y]"] = list(portal_x, portal_y, model, model.health)
			on_virtual_cell_loaded(model, portal_x, portal_y)
	set_enabled(enabled)
	return TRUE

/obj/overmap/entity/hyperrelay/proc/template_width()
	return round(hull_center_x * 2 - 1)

/obj/overmap/entity/hyperrelay/proc/template_height()
	return round(hull_center_y * 2 - 1)

/obj/overmap/entity/hyperrelay/on_virtual_cell_loaded(datum/overmap_virtual_model/model, cell_x, cell_y)
	if(model.warp_portal)
		warp_portals += new /obj/effect/overmap_warp_portal(null, src, cell_x, cell_y)

/obj/overmap/entity/hyperrelay/proc/clear_warp_portals()
	var/list/previous = warp_portals
	warp_portals = list()
	QDEL_LIST(previous)

/obj/overmap/entity/hyperrelay/proc/set_enabled(new_enabled)
	enabled = !!new_enabled
	for(var/obj/effect/overmap_warp_portal/portal as anything in warp_portals)
		portal.set_enabled(enabled)
	for(var/key, model_entry in virtual_models)
		var/datum/overmap_virtual_model/model = model_entry
		if(!model.warp_portal)
			continue
		model.visual.overlays -= model.warp_visual
		if(enabled)
			model.visual.overlays += model.warp_visual
	hull_version++

/obj/overmap/entity/hyperrelay/vv_edit_var(var_name, var_value)
	. = ..()
	if(. && var_name == NAMEOF(src, enabled))
		set_enabled(enabled)

/obj/overmap/entity/hyperrelay/proc/orient_to_sector_edge()
	if(!sector)
		return
	var/turf/spot = get_overmap_turf()
	var/local_x = sector.coord_x(spot)
	var/local_y = sector.coord_y(spot)
	var/list/distances = list(local_y - 1, sector.size - local_y, local_x - 1, sector.size - local_x)
	var/nearest = min(distances[1], distances[2], distances[3], distances[4])
	if(nearest == distances[1])
		relay_facing = 180
	else if(nearest == distances[2])
		relay_facing = 0
	else if(nearest == distances[3])
		relay_facing = 270
	else
		relay_facing = 90
	relay_facing = SIMPLIFY_DEGREES(relay_facing + rand(-20, 20))
	remember_pose()

/obj/overmap/entity/hyperrelay/proc/setup_virtual_iff()
	virtual_iff_channels = list(
		new /datum/overmap_iff_channel(OVERMAP_IFF_GLOBAL, overmap_iff_label_for_id(OVERMAP_IFF_GLOBAL), TRUE, FALSE, FALSE),
		new /datum/overmap_iff_channel(OVERMAP_IFF_CENTCOM, overmap_iff_label_for_id(OVERMAP_IFF_CENTCOM), TRUE, FALSE, TRUE),
		new /datum/overmap_iff_channel(OVERMAP_IFF_SYNDICATE, overmap_iff_label_for_id(OVERMAP_IFF_SYNDICATE), TRUE, FALSE, TRUE),
		new /datum/overmap_iff_channel(OVERMAP_IFF_HIJACK, overmap_iff_label_for_id(OVERMAP_IFF_HIJACK), TRUE, FALSE, TRUE),
	)

/obj/overmap/entity/hyperrelay/public/setup_virtual_iff()
	virtual_iff_channels = list(
		new /datum/overmap_iff_channel(OVERMAP_IFF_GLOBAL, overmap_iff_label_for_id(OVERMAP_IFF_GLOBAL), TRUE, TRUE, TRUE),
		new /datum/overmap_iff_channel(OVERMAP_IFF_CENTCOM, overmap_iff_label_for_id(OVERMAP_IFF_CENTCOM), TRUE, FALSE, TRUE),
		new /datum/overmap_iff_channel(OVERMAP_IFF_SYNDICATE, overmap_iff_label_for_id(OVERMAP_IFF_SYNDICATE), TRUE, FALSE, TRUE),
		new /datum/overmap_iff_channel(OVERMAP_IFF_HIJACK, overmap_iff_label_for_id(OVERMAP_IFF_HIJACK), TRUE, FALSE, TRUE),
	)

/obj/overmap/entity/proc/hyperrelay_on_tile()
	var/turf/here = get_overmap_turf()
	if(!here)
		return null
	var/obj/overmap/entity/hyperrelay/nested = loc
	if(istype(nested))
		return nested

	if(!sector)
		return null
	var/obj/overmap/entity/hyperrelay/nearest
	var/nearest_distance = max(OVERMAP_TILE_SPAN / 2, hull_radius + 12)
	for(var/obj/overmap/overmap_object as anything in sector.objects)
		var/obj/overmap/entity/hyperrelay/relay = overmap_object
		if(!istype(relay) || relay == src || QDELETED(relay))
			continue
		var/distance = sqrt((relay.get_world_x() - get_world_x()) ** 2 + (relay.get_world_y() - get_world_y()) ** 2)
		if(relay.paired && distance <= nearest_distance)
			nearest = relay
			nearest_distance = distance
	return nearest

/obj/overmap/entity/proc/can_hyperrelay_jump()
	if(overmap_kind != OVERMAP_KIND_SHUTTLE)
		return FALSE
	if(is_overmap_jammed())
		return FALSE
	if(is_jumping() || relay_capture || docking_approach?.aligning || docked_ship || length(docked_guests) || is_physically_docked())
		return FALSE
	if(!OVERMAP_SPEED_STOPPED(get_speed()))
		return FALSE
	if(status != OVERMAP_STATUS_OVERMAP && status != OVERMAP_STATUS_TRANSIT)
		return FALSE
	var/obj/overmap/entity/hyperrelay/relay = hyperrelay_on_tile()
	if(!relay?.enabled || relay.template_loaded || !relay.paired || QDELETED(relay.paired))
		return FALSE
	return iff_detects(relay) || contact_identified(relay)

/obj/overmap/entity/proc/begin_hyperrelay_jump(forced = FALSE, obj/effect/overmap_warp_portal/portal)
	var/obj/overmap/entity/hyperrelay/relay = portal ? portal.relay : hyperrelay_on_tile()
	if(portal)
		if(!portal.is_active() || !can_enter_relay(relay))
			return FALSE
	else if(forced)
		if(overmap_kind != OVERMAP_KIND_SHUTTLE || is_overmap_jammed())
			return "Прыжок недоступен."
		if(!OVERMAP_SPEED_STOPPED(get_speed()))
			return "Прыжок недоступен."
		if(status != OVERMAP_STATUS_OVERMAP && status != OVERMAP_STATUS_TRANSIT)
			return "Прыжок недоступен."
		if(!relay?.enabled || relay.template_loaded || !relay.paired || QDELETED(relay.paired))
			return "Прыжок недоступен."
	else if(!can_hyperrelay_jump())
		return "Прыжок недоступен."
	overmap_jam_was_halted = halted
	halted = TRUE
	speed[1] = 0
	speed[2] = 0
	flight?.set_autopilot(FALSE, manual = FALSE)
	flight?.release_pilot()
	QDEL_NULL(docking_approach)
	var/duration = hyperrelay_jump_duration(relay)
	relay_jump_from = relay
	relay_portal_jump = !!portal
	if(relay_portal_jump)
		relay_jump_origin = get_overmap_turf()
		relay_jump_was_hidden = hidden_from_contacts
		hidden_from_contacts = TRUE
		sector.objects -= src
		moveToNullspace()
	relay_jump_started = world.time
	relay_jump_ends = world.time + duration
	radar_epoch++
	overmap_jammed_until = relay_jump_ends
	for(var/obj/machinery/computer/ship_console/helm as anything in helms)
		if(!QDELETED(helm))
			SStgui.update_uis(helm)
	for(var/obj/machinery/computer/sensors/sensor as anything in sensors)
		if(!QDELETED(sensor))
			sensor.update_scan_info(TRUE)
			SStgui.update_uis(sensor)
	SEND_SIGNAL(SSovermap, COMSIG_OVERMAP_RELAY_TRANSIT, src, sector, relay.paired.sector, FALSE)
	start_hyperrelay_transit_fx(duration)
	addtimer(CALLBACK(src, PROC_REF(finish_hyperrelay_jump), relay), duration)
	return TRUE

/obj/overmap/entity/proc/finish_hyperrelay_jump(obj/overmap/entity/hyperrelay/from_relay)
	var/was_portal_jump = relay_portal_jump
	relay_portal_jump = FALSE
	if(was_portal_jump)
		hidden_from_contacts = relay_jump_was_hidden
		if(relay_jump_origin && sector)
			sector.add_object(src, relay_jump_origin)
		relay_jump_origin = null
	relay_jump_from = null
	relay_jump_started = 0
	relay_jump_ends = 0
	radar_epoch++
	overmap_jammed_until = 0
	halted = FALSE
	stop_hyperrelay_transit_fx()
	if(QDELETED(src))
		return
	var/obj/overmap/entity/hyperrelay/dest_relay = from_relay?.paired
	if(QDELETED(from_relay) || QDELETED(dest_relay))
		refresh_sensor_displays()
		return
	var/turf/dest = dest_relay.get_overmap_turf()
	if(!dest)
		refresh_sensor_displays()
		return
	var/datum/overmap_sector/source_sector = sector
	sector?.remove_object(src)
	dest_relay.sector?.add_object(src, dest)
	SEND_SIGNAL(SSovermap, COMSIG_OVERMAP_RELAY_TRANSIT, src, source_sector, sector, TRUE)
	position = list(0, 0)
	if(was_portal_jump)
		var/list/exit_point = dest_relay.relay_exit_position(src)
		set_world_position(exit_point[1], exit_point[2])
		flight?.set_facing(SIMPLIFY_DEGREES(dest_relay.get_facing() + 180))
		relay_arrival_cooldown = world.time + (5 SECONDS)
	remember_pose()
	QDEL_NULL(terrain_view)
	QDEL_LIST_ASSOC_VAL(neighbor_proxies)
	nearby_ships = list()
	update_overmap_pixel()
	flight?.set_autopilot(FALSE, manual = FALSE)
	refresh_sensor_displays()
	play_shuttle_sound('sound/effects/hyperspace_end.ogg')
	shake_shuttle(8, 2)
	shuttle_visible_message(span_warning("Корпус дёргается и снова становится неподвижным."))
	programmed_mission?.resume_after_relay()

/obj/overmap/entity/proc/play_shuttle_sound(soundfile, volume = 100)
	if(!soundfile || !shuttle)
		return
	var/sound/clip = sound(soundfile)
	clip.volume = volume
	if(shuttle.areaInstance)
		SEND_SOUND(shuttle.areaInstance, clip)
	for(var/area/place as anything in shuttle.shuttle_areas)
		if(place && place != shuttle.areaInstance)
			SEND_SOUND(place, clip)

/obj/overmap/entity/proc/shuttle_visible_message(text)
	if(!shuttle)
		return
	for(var/area/place as anything in shuttle.shuttle_areas)
		for(var/mob/passenger in place)
			if(passenger.stat == DEAD && !isobserver(passenger))
				continue
			to_chat(passenger, text)

/obj/overmap/entity/proc/shake_shuttle(duration, strength)
	if(!shuttle)
		return
	for(var/area/place as anything in shuttle.shuttle_areas)
		for(var/mob/living/passenger in place)
			if(passenger.client)
				shake_camera(passenger, duration, strength)

/obj/overmap/entity/proc/flicker_shuttle_lights()
	if(!shuttle)
		return
	for(var/area/place as anything in shuttle.shuttle_areas)
		for(var/obj/machinery/light/lamp in place)
			lamp.flicker(rand(6, 10))

/obj/overmap/entity/proc/refresh_shuttle_parallax()
	if(!shuttle)
		return
	for(var/area/place as anything in shuttle.shuttle_areas)
		for(var/mob/passenger in place)
			if(passenger.client)
				passenger.update_parallax_contents()

/obj/overmap/entity/proc/set_shuttle_hyperspace_visuals(enabled)
	if(!shuttle)
		return
	var/parallax_dir = enabled ? (shuttle.preferred_direction || SOUTH) : FALSE
	for(var/area/shuttle/place as anything in shuttle.shuttle_areas)
		place.moving = enabled
		place.parallax_movedir = parallax_dir
	if(shuttle.areaInstance)
		shuttle.areaInstance.moving = enabled
		if(is_area_shuttle(shuttle.areaInstance))
			var/area/shuttle/home = shuttle.areaInstance
			home.parallax_movedir = parallax_dir
	refresh_shuttle_parallax()

/obj/overmap/entity/proc/start_hyperrelay_transit_fx(duration = OVERMAP_HYPERRELAY_JUMP_TIME)
	set_shuttle_hyperspace_visuals(TRUE)
	play_shuttle_sound('sound/effects/hyperspace_begin.ogg')
	shuttle_visible_message(span_warning("Палуба вздрагивает, вы чувствуете странную вибрацию судна."))
	shake_shuttle(8, 2)
	flicker_shuttle_lights()
	addtimer(CALLBACK(src, PROC_REF(play_shuttle_sound), 'sound/effects/hyperspace_progress.ogg'), duration * 0.15)
	addtimer(CALLBACK(src, PROC_REF(shake_shuttle), 5, 1), duration * 0.25)
	addtimer(CALLBACK(src, PROC_REF(shake_shuttle), 5, 1), duration * 0.5)
	addtimer(CALLBACK(src, PROC_REF(shake_shuttle), 6, 1), duration * 0.75)
	addtimer(CALLBACK(src, PROC_REF(flicker_shuttle_lights)), duration * 0.5)

/obj/overmap/entity/proc/stop_hyperrelay_transit_fx()
	set_shuttle_hyperspace_visuals(FALSE)
