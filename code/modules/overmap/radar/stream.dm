/obj/overmap/entity/proc/watch_radar(datum/tgui/ui)
	if(!ui || ui.radar_source == src)
		return
	ui.radar_source?.unwatch_radar(ui)
	ui.radar_source = src
	radar_uis |= ui
	SSovermap.radar_vessels |= src
	RegisterSignal(ui, COMSIG_QDELETING, PROC_REF(unwatch_radar))

/obj/overmap/entity/proc/unwatch_radar(datum/tgui/ui)
	SIGNAL_HANDLER
	UnregisterSignal(ui, COMSIG_QDELETING)
	radar_uis -= ui
	if(ui.radar_source == src)
		ui.radar_source = null
	if(!length(radar_uis))
		SSovermap.radar_vessels -= src

/proc/overmap_watch_radar(atom/source, mob/user, obj/overmap/entity/vessel)
	for(var/datum/tgui/ui as anything in user?.tgui_open_uis)
		if(ui.src_object != source)
			continue
		if(vessel)
			vessel.watch_radar(ui)
		else
			ui.radar_source?.unwatch_radar(ui)

/datum/controller/subsystem/overmap/proc/push_radars()
	radar_frame_time = world.time
	for(var/obj/overmap/entity/vessel as anything in radar_vessels.Copy())
		if(QDELETED(vessel))
			radar_vessels -= vessel
			continue
		vessel.push_radar()

/obj/overmap/entity/proc/radar_object_positions()
	if(radar_objects_sector != sector)
		return null
	. = list()
	for(var/obj/overmap/object as anything in radar_object_sources)
		if(QDELETED(object) || object.sector != sector)
			continue
		var/turf/spot = object.get_overmap_turf()
		if(!spot)
			continue
		var/list/source = radar_object_sources[object]
		var/list/entry = source.Copy()
		var/list/position = object == src ? radar_sector_position() : list(sector.coord_x(spot) + object.position[1], sector.coord_y(spot) + object.position[2])
		entry["x"] = position[1]
		entry["y"] = position[2]
		var/obj/overmap/entity/contact = object
		if(istype(contact))
			entry["facing"] = contact.free_flight_view ? contact.get_facing() : 0
		. += list(entry)
