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

/obj/overmap/entity/proc/is_jumping()
	return jump_spool_end || jump_start_time

/obj/overmap/entity/proc/start_jump()
	if(sector?.sector_kind == OVERMAP_SECTOR_KIND_SERVICE)
		return "Недоступно."
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
