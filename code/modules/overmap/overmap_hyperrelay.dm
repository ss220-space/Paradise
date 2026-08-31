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
	overmap_icon_preset = "station"
	status = OVERMAP_STATUS_OVERMAP
	overmap_hazard_immune = TRUE
	var/obj/overmap/entity/hyperrelay/paired
	var/pair_id

/obj/overmap/entity/hyperrelay/Initialize(mapload)
	. = ..()
	setup_virtual_iff()
	update_overmap_visibility()

/obj/overmap/entity/hyperrelay/Destroy()
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
	log_world("Overmap: hyperrelay pair at service [service_spot.x],[service_spot.y] and station [station_spot.x],[station_spot.y].")

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

	for(var/atom/thing as anything in here.contents)
		var/obj/overmap/entity/hyperrelay/relay = thing
		if(istype(relay) && relay != src && !QDELETED(relay))
			return relay
	if(!sector)
		return null
	for(var/obj/overmap/overmap_object as anything in sector.objects)
		var/obj/overmap/entity/hyperrelay/relay = overmap_object
		if(!istype(relay) || relay == src || QDELETED(relay))
			continue
		if(relay.get_overmap_turf() == here)
			return relay
	return null

/obj/overmap/entity/proc/can_hyperrelay_jump()
	if(overmap_kind != OVERMAP_KIND_SHUTTLE)
		return FALSE
	if(is_overmap_jammed())
		return FALSE
	if(!OVERMAP_SPEED_STOPPED(get_speed()))
		return FALSE
	if(status != OVERMAP_STATUS_OVERMAP && status != OVERMAP_STATUS_TRANSIT)
		return FALSE
	var/obj/overmap/entity/hyperrelay/relay = hyperrelay_on_tile()
	if(!relay?.paired || QDELETED(relay.paired))
		return FALSE
	return contact_identified(relay)

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
	set_autopilot(FALSE)
	overmap_jammed_until = world.time + OVERMAP_HYPERRELAY_JUMP_TIME
	for(var/obj/machinery/computer/helm/helm as anything in helms)
		if(QDELETED(helm))
			continue
		for(var/mob/viewer as anything in helm.viewers.Copy())
			helm.unlook(viewer)
		helm.update_map_view(TRUE)
	for(var/obj/machinery/computer/sensors/sensor as anything in sensors)
		if(!QDELETED(sensor))
			sensor.update_map_view(TRUE)
	start_hyperrelay_transit_fx()
	addtimer(CALLBACK(src, PROC_REF(finish_hyperrelay_jump), relay), OVERMAP_HYPERRELAY_JUMP_TIME)
	return TRUE

/obj/overmap/entity/proc/finish_hyperrelay_jump(obj/overmap/entity/hyperrelay/from_relay)
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
	update_overmap_pixel()
	set_autopilot(FALSE)
	refresh_sensor_displays()
	for(var/obj/machinery/computer/helm/helm as anything in helms)
		if(!QDELETED(helm))
			helm.update_map_view(TRUE)
	play_shuttle_sound('sound/effects/hyperspace_end.ogg')
	shake_shuttle(8, 2)
	shuttle_visible_message(span_warning("Корпус дёргается и снова становится неподвижным."))
	programmed_mission?.try_fly()

/obj/overmap/entity/proc/play_shuttle_sound(soundfile)
	if(!soundfile || !shuttle)
		return
	var/sound/clip = sound(soundfile)
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
		if(istype(shuttle.areaInstance, /area/shuttle))
			var/area/shuttle/home = shuttle.areaInstance
			home.parallax_movedir = parallax_dir
	refresh_shuttle_parallax()

/obj/overmap/entity/proc/start_hyperrelay_transit_fx()
	set_shuttle_hyperspace_visuals(TRUE)
	play_shuttle_sound('sound/effects/hyperspace_begin.ogg')
	shuttle_visible_message(span_warning("Палуба вздрагивает, за иллюминаторами вспыхивает белый шум."))
	shake_shuttle(8, 2)
	flicker_shuttle_lights()
	addtimer(CALLBACK(src, PROC_REF(play_shuttle_sound), 'sound/effects/hyperspace_progress.ogg'), 1.5 SECONDS)
	addtimer(CALLBACK(src, PROC_REF(shake_shuttle), 5, 1), 2.5 SECONDS)
	addtimer(CALLBACK(src, PROC_REF(shake_shuttle), 5, 1), 5 SECONDS)
	addtimer(CALLBACK(src, PROC_REF(shake_shuttle), 6, 1), 7.5 SECONDS)
	addtimer(CALLBACK(src, PROC_REF(flicker_shuttle_lights)), 5 SECONDS)

/obj/overmap/entity/proc/stop_hyperrelay_transit_fx()
	set_shuttle_hyperspace_visuals(FALSE)
