/obj/overmap/entity/proc/watch_radar(datum/tgui/ui)
	if(!ui || ui.radar_source == src)
		return
	ui.radar_source?.unwatch_radar(ui)
	ui.radar_source = src
	radar_uis[ui] = new /datum/overmap_radar_subscription(ui)
	SSovermap.radar_vessels |= src
	RegisterSignal(ui, COMSIG_QDELETING, PROC_REF(unwatch_radar))

/obj/overmap/entity/proc/unwatch_radar(datum/tgui/ui)
	SIGNAL_HANDLER
	UnregisterSignal(ui, COMSIG_QDELETING)
	qdel(radar_uis[ui])
	radar_uis -= ui
	if(ui.radar_source == src)
		ui.radar_source = null
	if(!length(radar_uis))
		SSovermap.radar_vessels -= src

/datum/controller/subsystem/overmap/proc/push_radars()
	radar_frame_time = world.time
	for(var/obj/overmap/entity/vessel as anything in radar_vessels)
		if(QDELETED(vessel))
			radar_vessels -= vessel
			continue
		vessel.push_radar()

/obj/overmap/entity/proc/radar_object_positions()
	if(radar_cache.objects_sector != sector)
		return null
	. = list()
	for(var/obj/overmap/object as anything in radar_cache.object_sources)
		if(QDELETED(object) || object.sector != sector)
			continue
		var/turf/spot = object.get_overmap_turf()
		if(!spot)
			continue
		var/list/entry = list("id" = object.UID())
		var/list/position = object == src ? radar_sector_position() : list(sector.coord_x(spot) + object.position[1], sector.coord_y(spot) + object.position[2])
		entry["x"] = position[1]
		entry["y"] = position[2]
		var/obj/overmap/entity/contact = object
		if(istype(contact))
			entry["facing"] = (contact.free_flight_view || istype(contact, /obj/overmap/entity/virtual_structure)) ? contact.get_facing() : 0
		. += list(entry)

/obj/overmap/entity/proc/push_radar()
	if(radar_transitioning)
		return
	if(!length(radar_uis) || !sector)
		return
	var/has_viewer = FALSE
	for(var/datum/tgui/ui as anything in radar_uis)
		if(!QDELETED(ui) && !ui.closing && ui.initialized && ui.status >= UI_UPDATE)
			has_viewer = TRUE
			break
	if(!has_viewer)
		return
	var/list/scatter = radar_scatter_data()
	var/list/data = list("radar_tick" = SSovermap.radar_frame_time * 100, "radar_epoch" = radar_epoch, "radar_locked" = !!relay_jump_from, "radar_docked" = !!(docked_to || docked_ship || is_physically_docked()), "self_pos" = radar_sector_position(), "radar_docks" = radar_dock_targets(), "dock_ready" = docking_approach?.ready(), "dock_in_range" = docking_approach?.in_alignment_range(), "dock_aligning" = docking_approach?.aligning, "radar" = radar_contacts(), "radar_drifters" = radar_drifters(), "radar_engines" = radar_engines(), "facing" = free_flight_view ? get_facing() : 0, "radar_world" = radar_world_origin())
	if(scatter != radar_cache.pushed_scatter)
		data["radar_scatter"] = scatter
		radar_cache.pushed_scatter = scatter
	var/list/objects = radar_object_positions()
	if(objects)
		data["radar_poses"] = objects
	data["radar_projectiles"] = radar_projectiles()
	radar_cache.motion_frame = data
	radar_cache.motion_epoch = radar_epoch
	radar_cache.motion_sector = sector
	for(var/datum/tgui/ui as anything in radar_uis)
		if(QDELETED(ui) || ui.status < UI_UPDATE)
			continue
		ui.send_update(data)
