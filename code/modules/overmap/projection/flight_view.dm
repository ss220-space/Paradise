/obj/overmap/entity/proc/in_free_flight()
	return shuttle && !is_jumping() && status == OVERMAP_STATUS_OVERMAP && isturf(loc) && !is_physically_docked()

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
	return !!relay_jump_from
