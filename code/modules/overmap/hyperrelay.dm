/obj/overmap/entity/hyperrelay
	name = "Гипертранслятор"
	desc = "Стационарный гиперпространственный ретранслятор."
	icon_state = "object"
	movable = FALSE
	halted = TRUE
	overmap_kind = OVERMAP_KIND_RELAY
	vessel_flags = NONE
	vessel_mass = 300
	map_color = "#c58cff"
	overmap_hazard_immune = TRUE
	var/obj/overmap/entity/hyperrelay/paired
	var/pair_id
	var/link_distance

/obj/overmap/entity/hyperrelay/proc/get_link_distance()
	if(!link_distance)
		link_distance = paired?.link_distance || rand(300, 1800)
	if(paired)
		paired.link_distance = link_distance
	return max(1, link_distance)

/obj/overmap/entity/proc/hyperrelay_jump_duration(obj/overmap/entity/hyperrelay/relay)
	return max(15 SECONDS, round(OVERMAP_HYPERRELAY_JUMP_TIME * relay.get_link_distance() / 1000))

/obj/overmap/entity/hyperrelay/Initialize(mapload)
	. = ..()
	setup_virtual_iff()
	update_overmap_visibility()

/obj/overmap/entity/hyperrelay/Destroy()
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
	return FALSE

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

/datum/controller/subsystem/overmap/proc/spawn_hyperrelays()
	if(!station_sector || !service_sector)
		return
	var/turf/service_spot = pick_hyperrelay_turf(service_sector, TRUE)
	var/turf/station_spot = pick_hyperrelay_turf(station_sector, FALSE)
	if(!service_spot || !station_spot)
		log_world("Overmap: failed to place hyperrelay pair.")
		return
	var/obj/overmap/entity/hyperrelay/service_relay = new(service_spot)
	var/obj/overmap/entity/hyperrelay/station_relay = new(station_spot)
	service_relay.pair_id = "station_service"
	station_relay.pair_id = "station_service"
	service_relay.paired = station_relay
	station_relay.paired = service_relay
	service_sector.add_object(service_relay, service_spot)
	station_sector.add_object(station_relay, station_spot)
	SSovermap.bump_galaxy()

/datum/controller/subsystem/overmap/proc/spawn_station_wilderness_relays()
	if(!station_sector || !wilderness_sector)
		return
	var/turf/station_spot = pick_hyperrelay_edge_turf(station_sector, TRUE)
	var/turf/wilderness_spot = pick_hyperrelay_edge_turf(wilderness_sector, FALSE)
	if(!station_spot || !wilderness_spot)
		log_world("Overmap: failed to place station↔wilderness hyperrelay pair.")
		return
	var/obj/overmap/entity/hyperrelay/station_relay = new /obj/overmap/entity/hyperrelay/public(station_spot)
	var/obj/overmap/entity/hyperrelay/wild_relay = new /obj/overmap/entity/hyperrelay/public(wilderness_spot)
	station_relay.pair_id = "station_wilderness"
	wild_relay.pair_id = "station_wilderness"
	station_relay.paired = wild_relay
	wild_relay.paired = station_relay
	station_sector.add_object(station_relay, station_spot)
	wilderness_sector.add_object(wild_relay, wilderness_spot)
	SSovermap.bump_galaxy()

/datum/controller/subsystem/overmap/proc/pick_hyperrelay_edge_turf(datum/overmap_sector/sector, at_top)
	if(!sector)
		return null
	var/low_x = sector.origin_x + OVERMAP_EDGE
	var/low_y = sector.origin_y + OVERMAP_EDGE
	var/high_x = sector.origin_x + sector.size - OVERMAP_EDGE - 1
	var/high_y = sector.origin_y + sector.size - OVERMAP_EDGE - 1
	var/list/candidates = list()
	for(var/turf/open_turf as anything in block(locate(low_x, low_y, sector.z_level), locate(high_x, high_y, sector.z_level)))
		if(sector.turf_occupied(open_turf))
			continue
		if(locate(/obj/overmap/entity/hyperrelay) in range(2, open_turf))
			continue
		var/local_y = sector.coord_y(open_turf)
		var/edge_dist = at_top ? (sector.size - local_y) : (local_y - 1)
		if(edge_dist < 2 || edge_dist > 4)
			continue
		candidates += open_turf
	if(length(candidates))
		return pick(candidates)
	return sector.get_random_open_turf()

/datum/controller/subsystem/overmap/proc/pick_hyperrelay_turf(datum/overmap_sector/sector, on_right)
	if(!sector)
		return null
	var/local_x
	if(on_right)
		local_x = sector.size - OVERMAP_EDGE - 1
		var/local_y = round(sector.size / 2)
		var/turf/center = sector.locate_local(local_x, local_y)
		if(center && !sector.turf_occupied(center))
			return center
		for(var/offset in 1 to 6)
			var/turf/up = sector.locate_local(local_x, clamp(local_y + offset, OVERMAP_EDGE + 1, sector.size - OVERMAP_EDGE))
			if(up && !sector.turf_occupied(up))
				return up
			var/turf/down = sector.locate_local(local_x, clamp(local_y - offset, OVERMAP_EDGE + 1, sector.size - OVERMAP_EDGE))
			if(down && !sector.turf_occupied(down))
				return down
		return sector.get_random_open_turf()
	local_x = OVERMAP_EDGE + rand(1, 2)
	var/list/candidates = list()
	for(var/local_y in (OVERMAP_EDGE + 1) to (sector.size - OVERMAP_EDGE))
		var/turf/spot = sector.locate_local(local_x, local_y)
		if(spot && !sector.turf_occupied(spot))
			candidates += spot
	if(length(candidates))
		return pick(candidates)
	return sector.get_random_open_turf()

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
	if(relay_jump_from || is_jumping() || docking_approach?.aligning || docked_ship || length(docked_guests) || is_physically_docked())
		return FALSE
	if(!OVERMAP_SPEED_STOPPED(get_speed()))
		return FALSE
	if(status != OVERMAP_STATUS_OVERMAP && status != OVERMAP_STATUS_TRANSIT)
		return FALSE
	var/obj/overmap/entity/hyperrelay/relay = hyperrelay_on_tile()
	if(!relay?.paired || QDELETED(relay.paired))
		return FALSE
	return iff_detects(relay) || contact_identified(relay)

/obj/overmap/entity/proc/begin_hyperrelay_jump(forced = FALSE)
	var/obj/overmap/entity/hyperrelay/relay = hyperrelay_on_tile()
	if(forced)
		if(overmap_kind != OVERMAP_KIND_SHUTTLE || is_overmap_jammed())
			return "Прыжок недоступен."
		if(!OVERMAP_SPEED_STOPPED(get_speed()))
			return "Прыжок недоступен."
		if(status != OVERMAP_STATUS_OVERMAP && status != OVERMAP_STATUS_TRANSIT)
			return "Прыжок недоступен."
		if(!relay?.paired || QDELETED(relay.paired))
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
	relay_jump_started = world.time
	relay_jump_ends = world.time + duration
	radar_epoch++
	overmap_jammed_until = relay_jump_ends
	for(var/obj/machinery/computer/helm/helm as anything in helms)
		if(!QDELETED(helm))
			SStgui.update_uis(helm)
	for(var/obj/machinery/computer/sensors/sensor as anything in sensors)
		if(!QDELETED(sensor))
			sensor.update_scan_info(TRUE)
			SStgui.update_uis(sensor)
	start_hyperrelay_transit_fx(duration)
	addtimer(CALLBACK(src, PROC_REF(finish_hyperrelay_jump), relay), duration)
	return TRUE

/obj/overmap/entity/proc/finish_hyperrelay_jump(obj/overmap/entity/hyperrelay/from_relay)
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
	sector?.remove_object(src)
	dest_relay.sector?.add_object(src, dest)
	position = list(0, 0)
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

/datum/controller/subsystem/overmap/proc/bump_galaxy()
	galaxy_revision++
	galaxy_positions = null

/datum/controller/subsystem/overmap/proc/sector_neighbours(datum/overmap_sector/sector)
	. = list()
	if(!sector)
		return
	for(var/obj/overmap/entity/hyperrelay/relay in sector.objects)
		var/datum/overmap_sector/other = relay.paired?.sector
		if(!other || other == sector || (other in .))
			continue
		. += other

/datum/controller/subsystem/overmap/proc/galaxy_positions()
	if(galaxy_positions)
		return galaxy_positions
	galaxy_positions = list()
	if(station_sector)
		galaxy_positions[station_sector.id] = list(0, 0)
	for(var/datum/overmap_sector/sector as anything in sector_order)
		if(galaxy_positions[sector.id])
			continue
		var/list/center = list(0, 0)
		var/distance = 1000
		for(var/obj/overmap/entity/hyperrelay/relay in sector.objects)
			var/datum/overmap_sector/neighbor = relay.paired?.sector
			if(neighbor && galaxy_positions[neighbor.id])
				center = galaxy_positions[neighbor.id]
				distance = relay.get_link_distance()
				break
		galaxy_positions[sector.id] = galaxy_random_position(center, 1.5 + sqrt(distance / 1000) * 2)
	for(var/pass in 1 to 40)
		for(var/datum/overmap_sector/sector as anything in sector_order)
			if(sector == station_sector)
				continue
			var/list/spot = galaxy_positions[sector.id]
			for(var/obj/overmap/entity/hyperrelay/relay in sector.objects)
				var/datum/overmap_sector/neighbor = relay.paired?.sector
				var/list/other = neighbor && galaxy_positions[neighbor.id]
				if(!other)
					continue
				var/dx = spot[1] - other[1]
				var/dy = spot[2] - other[2]
				var/actual = max(sqrt(dx * dx + dy * dy), 0.01)
				var/desired = 1.5 + sqrt(relay.get_link_distance() / 1000) * 2
				var/change = (desired - actual) / actual * 0.08
				spot[1] += dx * change
				spot[2] += dy * change
	return galaxy_positions

/datum/controller/subsystem/overmap/proc/galaxy_random_position(list/center, radius = 2)
	while(TRUE)
		for(var/attempt in 1 to 24)
			var/angle = rand(0, 35999) / 100
			var/distance = rand(100, 180) / 100 * radius
			var/x = center[1] + cos(angle) * distance
			var/y = center[2] + sin(angle) * distance
			if(galaxy_slot_free(x, y))
				return list(x, y)
		radius += 1

/datum/controller/subsystem/overmap/proc/galaxy_slot_free(x, y)
	for(var/id, spot_entry in galaxy_positions)
		var/list/spot = spot_entry
		if((spot[1] - x) ** 2 + (spot[2] - y) ** 2 < 2.25)
			return FALSE
	for(var/list/entry as anything in galaxy_unknown)
		if((entry["x"] - x) ** 2 + (entry["y"] - y) ** 2 < 2.25)
			return FALSE
	return TRUE

/datum/controller/subsystem/overmap/proc/galaxy_unknown()
	if(galaxy_unknown)
		return galaxy_unknown
	galaxy_positions()
	galaxy_unknown = list()
	for(var/index in 1 to 10)
		var/list/spot = galaxy_random_position(list(0, 0))
		galaxy_unknown += list(list(
			"id" = "unknown_[index]",
			"name" = "Неизвестный сектор",
			"kind" = "unknown",
			"x" = spot[1],
			"y" = spot[2],
			"links" = list(),
			"contacts" = 0,
			"distress" = FALSE,
			"unknown" = TRUE,
		))
	return galaxy_unknown

/datum/controller/subsystem/overmap/proc/galaxy_map(obj/overmap/entity/viewer)
	. = list("revision" = galaxy_revision, "center" = station_sector?.id, "sectors" = list(), "transits" = list())
	var/list/positions = galaxy_positions()
	var/slot = 0
	for(var/datum/overmap_sector/sector as anything in sector_order)
		if(!sector)
			continue
		var/list/spot = positions[sector.id]
		if(!spot)

			slot++
			spot = list(0, 6 + slot * 2)
			positions[sector.id] = spot
		var/list/links = list()
		var/list/signal_links = list()
		var/list/distances = list()
		for(var/datum/overmap_sector/neighbour as anything in sector_neighbours(sector))
			links += neighbour.id
		for(var/obj/overmap/entity/hyperrelay/relay in sector.objects)
			if(relay.paired?.sector)
				distances[relay.paired.sector.id] = relay.get_link_distance()
			if(relay.paired?.sector && (!viewer || (viewer.sector == sector && viewer.iff_detects(relay))))
				signal_links |= relay.paired.sector.id
		var/contacts = 0
		var/distress = FALSE
		for(var/obj/overmap/entity/vessel in sector.objects)
			contacts++
			if(vessel.identity_distress)
				distress = TRUE
		.["sectors"] += list(list(
			"id" = sector.id,
			"name" = sector.name,
			"kind" = sector.sector_kind,
			"x" = spot[1],
			"y" = spot[2],
			"links" = links,
			"signal_links" = signal_links,
			"distances" = distances,
			"contacts" = contacts,
			"distress" = distress,
			"unknown" = FALSE,
		))
	for(var/list/entry as anything in galaxy_unknown())
		.["sectors"] += list(entry)
	for(var/obj/overmap/entity/vessel as anything in vessels)
		var/obj/overmap/entity/hyperrelay/relay = vessel.relay_jump_from
		if(!relay?.paired?.sector || vessel.relay_jump_ends <= world.time)
			continue
		.["transits"] += list(list("id" = vessel.UID(), "from" = relay.sector.id, "to" = relay.paired.sector.id, "progress" = clamp((world.time - vessel.relay_jump_started) / max(1, vessel.relay_jump_ends - vessel.relay_jump_started), 0, 1), "remaining" = (vessel.relay_jump_ends - world.time) * 100, "own" = vessel == viewer))
