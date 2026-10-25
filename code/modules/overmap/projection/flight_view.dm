#define OVERMAP_PARALLAX_SCROLL 1000

/obj/overmap/entity/proc/in_free_flight()
	return shuttle && !is_jumping() && !relay_jump_from && status == OVERMAP_STATUS_OVERMAP && isturf(loc) && !is_physically_docked()

/obj/overmap/entity/proc/set_free_flight_view(enabled)
	radar_epoch++
	free_flight_view = enabled
	if(enabled && undock_origin)
		place_at_undock_origin()
	if(enabled)
		map_hull()
		remember_pose()
	else
		clear_encounter_visuals()
	var/obj/docking_port/stationary/transit/pad = shuttle.get_docked()
	if(!istype(pad))
		return
	var/parallax_dir = enabled ? NONE : (shuttle.preferred_direction || SOUTH)
	for(var/area/shuttle/place as anything in shuttle.shuttle_areas)
		place.moving = TRUE
		place.parallax_movedir = parallax_dir
	for(var/turf/space/spot in pad.reserved_area?.reserved_turfs)
		if(!is_hyperspace_turf(spot))
			continue
		if(enabled)
			spot.icon_state = "space"
			spot.transform = matrix()
		else if(istype(spot, /turf/space/transit))
			spot.update_icon(UPDATE_ICON_STATE)
	refresh_shuttle_parallax()

/datum/controller/subsystem/overmap/proc/process_flight_views(elapsed)
	var/list/flying = list()
	flying_pods = list()
	var/list/flying_areas = list()
	for(var/obj/docking_port/mobile/port as anything in shuttle_vessels)
		var/obj/overmap/entity/vessel = shuttle_vessels[port]
		if(QDELETED(vessel) || QDELETED(port))
			continue
		var/in_flight = vessel.in_free_flight()
		if(in_flight != vessel.free_flight_view)
			vessel.set_free_flight_view(in_flight)
		if(!in_flight)
			continue
		flying += vessel
		for(var/area/place as anything in port.shuttle_areas)
			flying_areas[place] = vessel.docked_ship || vessel
	for(var/obj/spacepod/craft as anything in pod_vessels)
		var/obj/overmap/entity/pod/pod_vessel = pod_vessels[craft]
		if(QDELETED(pod_vessel) || QDELETED(craft))
			continue
		var/in_flight = pod_vessel.in_free_flight()
		if(in_flight != pod_vessel.free_flight_view)
			pod_vessel.set_free_flight_view(in_flight)
		if(in_flight)
			flying += pod_vessel
			flying_pods += pod_vessel
		if(pod_vessel.overmap_pod.is_in_own_pocket())
			flying_areas[pod_vessel.overmap_pod.pocket_area] = pod_vessel
	for(var/obj/overmap/entity/virtual_structure/structure as anything in GLOB.overmap_virtual_structures)
		if(!QDELETED(structure) && structure.sector && isturf(structure.loc))
			flying += structure
	flying_vessels = flying
	prepare_bubble_space()
	var/list/watched = list()
	var/list/eyes = list()

	client_eyes = list()
	if(length(flying) || length(bubbles))
		for(var/client/viewer as anything in GLOB.clients)
			var/turf/eye_turf = get_turf(viewer.eye || viewer.mob)
			if(!eye_turf)
				continue
			eyes += eye_turf
			var/list/spots = list(eye_turf)

			var/obj/overmap/entity/inside_vessel = flying_areas[eye_turf.loc]
			if(inside_vessel?.local_space)
				var/list/virtual_eye_world = inside_vessel.hull_to_world(eye_turf.x, eye_turf.y)
				var/turf/virtual_eye = inside_vessel.local_space.turf_at(virtual_eye_world[1], virtual_eye_world[2])
				if(virtual_eye)
					eyes += virtual_eye
					spots += virtual_eye
			client_eyes[viewer] = spots
			var/datum/eye_frame = frame_owner(eye_turf)
			if(eye_frame)
				watched[eye_frame] = TRUE
	process_encounters(flying, elapsed, watched, eyes)
	var/drifting_bubble = FALSE
	for(var/datum/overmap_bubble/bubble as anything in bubbles)
		if(bubble.speed_x || bubble.speed_y)
			drifting_bubble = TRUE
			break
	if(!length(flying_areas) && !drifting_bubble && !length(drifting_viewers))
		return
	for(var/client/viewer as anything in drifting_viewers)
		if(QDELETED(viewer))
			drifting_viewers -= viewer
	for(var/client/viewer as anything in GLOB.clients)
		if(!viewer.parallax_rock?.displaying_layers)
			if(viewer in drifting_viewers)
				stop_drifting(viewer)
			continue
		var/turf/eye_turf = get_turf(viewer.eye)
		var/obj/overmap/entity/vessel = flying_areas[eye_turf?.loc]
		var/datum/overmap_bubble/bubble = bubbles_by_reservation[SSmapping.used_turfs[eye_turf]]
		if(vessel)
			drift_viewer(viewer, vessel.speed[1], vessel.speed[2], vessel.get_facing(), elapsed)
		else if(bubble && (bubble.speed_x || bubble.speed_y))
			drift_viewer(viewer, bubble.speed_x, bubble.speed_y, 0, elapsed)
		else if(viewer in drifting_viewers)
			stop_drifting(viewer)

/datum/controller/subsystem/overmap/proc/drift_viewer(client/viewer, speed_x, speed_y, facing, elapsed)
	drifting_viewers |= viewer
	var/scroll = OVERMAP_PARALLAX_SCROLL * elapsed
	for(var/atom/movable/screen/parallax_layer/layer as anything in viewer.parallax_rock.parallax_layers)
		if(!layer.absolute)
			layer.set_ship_drift(speed_x * scroll, speed_y * scroll, facing, elapsed)

/datum/controller/subsystem/overmap/proc/stop_drifting(client/viewer)
	drifting_viewers -= viewer
	for(var/atom/movable/screen/parallax_layer/layer as anything in viewer.parallax_rock?.parallax_layers)
		layer.clear_ship_drift()
	viewer.parallax_movedir = NONE
	if(viewer.parallax_rock?.displaying_layers)
		viewer.mob?.hud_used?.update_parallax()

/obj/overmap/entity/proc/is_jumping()
	return jump_spool_end || jump_start_time

/obj/overmap/entity/proc/start_jump()
	if(is_jumping())
		return "Прыжок уже идёт."
	if(!in_free_flight())
		return "Прыжок возможен только в открытом космосе."
	if(docked_ship || length(docked_guests))
		return "Сначала расстыкуйтесь."
	if(!flight?.has_working_engines())
		return "Двигатели не отвечают."
	var/turf/target = sector?.get_turf_at(flight.autopilot_x, flight.autopilot_y)
	if(!target)
		return "Отметьте цель прыжка на карте."
	var/span = OVERMAP_TILE_SPAN * sector.tile_travel
	jump_target = local_arrival_point(list(target.x * span, target.y * span), list(get_world_x(), get_world_y()))
	jump_spool_end = world.time + OVERMAP_JUMP_SPOOL
	flight.release_pilot()
	flight.set_autopilot(FALSE)
	play_shuttle_sound('sound/effects/hyperspace_begin.ogg')
	shake_shuttle(OVERMAP_JUMP_SPOOL, 1)
	flicker_shuttle_lights()
	announce_sensor_event("Гиперпрыжок: [get_overmap_display_name()] набирает заряд", "jump")
	return TRUE

/obj/overmap/entity/proc/process_jump()
	if(jump_spool_end)
		if(!in_free_flight())
			jump_spool_end = 0
			jump_target = null
			return
		if(world.time < jump_spool_end)
			return
		jump_spool_end = 0
		jump_origin = list(get_world_x(), get_world_y())
		var/distance = sqrt((jump_target[1] - jump_origin[1]) ** 2 + (jump_target[2] - jump_origin[2]) ** 2)
		jump_duration = max(OVERMAP_JUMP_MIN_TIME, distance / OVERMAP_JUMP_SPEED)
		jump_start_time = world.time
		speed[1] = 0
		speed[2] = 0
		local_space = null
		status = OVERMAP_STATUS_TRANSIT
		play_shuttle_sound('sound/effects/hyperspace_progress.ogg')
		return
	var/progress = min((world.time - jump_start_time) / jump_duration, 1)
	set_world_position(jump_origin[1] + (jump_target[1] - jump_origin[1]) * progress, jump_origin[2] + (jump_target[2] - jump_origin[2]) * progress)
	if(progress < 1)
		return
	jump_start_time = 0
	jump_origin = null
	jump_target = null
	local_space = SSovermap.local_space_at(sector, get_world_x(), get_world_y())
	status = OVERMAP_STATUS_OVERMAP
	play_shuttle_sound('sound/effects/hyperspace_end.ogg')
	shake_shuttle(3, 2)
	flicker_shuttle_lights()
	announce_sensor_event("Гиперпрыжок завершён: [get_overmap_display_name()]", "jump")
	var/obj/overmap/portal/portal = locate() in get_overmap_turf()
	if(portal && can_use_portal(portal))
		portal.transit_vessel(src)
	else if(can_hyperrelay_jump())
		begin_hyperrelay_jump()

#undef OVERMAP_PARALLAX_SCROLL
