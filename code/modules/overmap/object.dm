/obj/overmap
	name = "map object"
	icon = OVERMAP_ICON_FILE
	icon_state = "object"
	anchored = TRUE
	layer = HIGH_OBJ_LAYER
	animate_movement = NO_STEPS
	glide_size = 0
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF
	color = "#fffffe"

	var/datum/overmap_sector/sector
	var/overmap_kind = OVERMAP_KIND_OTHER
	var/scannable = TRUE
	var/movable = FALSE
	var/list/speed = list(0, 0)
	var/list/position = list(0, 0)
	var/halted = FALSE
	var/wraparound = TRUE
	var/max_speed = 1 / (1 SECONDS)
	var/min_speed = 1 / (5 MINUTES)
	var/map_color = "#9bd"

	var/hidden_from_contacts = FALSE

	var/hidden_from_sensors = FALSE

	var/visible_without_scanner = FALSE

	var/scan_mass = 0

	var/overmap_hazard_immune = FALSE

	var/deny_pod_edge_dock = FALSE

	var/rotate_sprite_with_heading = FALSE
	var/last_overlay_heading = 0
	var/last_overlay_speed_band = 0

/obj/overmap/Initialize(mapload)
	. = ..()
	glide_size = 0
	max_speed = round(max_speed, OVERMAP_MOVE_RESOLUTION)
	min_speed = round(min_speed, OVERMAP_MOVE_RESOLUTION)
	update_overmap_pixel()
	apply_overmap_camera_visibility()
	if(scan_mass <= 0)
		scan_mass = rand(40, 400)

/obj/overmap/proc/apply_overmap_camera_visibility()
	if(visible_without_scanner)
		return
	invisibility = INVISIBILITY_OBSERVER
	vis_flags |= VIS_HIDE
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT

/obj/overmap/proc/update_overmap_pixel()
	pixel_x = round(position[1] * world.icon_size)
	pixel_y = round(position[2] * world.icon_size)
	sync_inspect_follow()

/obj/overmap/proc/sector_obstacle_box(span)
	return null

/obj/overmap/planet/sector_obstacle_box(span)
	return null

/obj/overmap/entity/sector_obstacle_box(span)
	if(!project_terrain || dock_host?.planet_landing || physical_space)
		return null
	if(!istype(src, /obj/overmap/entity/station) \
		&& !istype(src, /obj/overmap/entity/service_site) \
		&& !istype(src, /obj/overmap/entity/taipan_site) \
		&& !istype(src, /obj/overmap/entity/planet_station) \
		&& !istype(src, /obj/overmap/entity/feature/ruin))
		return null
	var/center_x = (x + position[1]) * span
	var/center_y = (y + position[2]) * span
	return list(
		center_x - span * 0.35,
		center_y - span * 0.35,
		center_x + span * 0.35,
		center_y + span * 0.35,
	)

/obj/overmap/proc/sync_inspect_follow()
	return

/obj/overmap/proc/on_overmap_loc_changed()
	return

/obj/overmap/Destroy()
	sector?.remove_object(src)
	return ..()

/obj/overmap/proc/get_overmap_turf()
	if(isturf(loc))
		return loc
	var/obj/overmap/holder = loc
	if(istype(holder))
		return holder.get_overmap_turf()
	return get_turf(src)

/obj/overmap/proc/shows_overmap_map_signature()
	return isturf(loc)

/obj/overmap/proc/get_speed()
	return round(sqrt(speed[1] ** 2 + speed[2] ** 2), OVERMAP_MOVE_RESOLUTION)

/obj/overmap/proc/is_moving()
	return speed[1] || speed[2]

/obj/overmap/proc/get_heading_angle()
	if(OVERMAP_SPEED_STOPPED(get_speed()))
		return 0
	return (round(ATAN2(speed[1], -speed[2]), 1) + 450) % 360

/obj/overmap/proc/is_overmap_visible()
	return TRUE

/obj/overmap/proc/get_overmap_display_name()
	return name

/obj/overmap/proc/get_scan_mass()
	return scan_mass

/obj/overmap/proc/announce_sensor_event(message, kind = "info")
	SSovermap?.relay_sensor_event(src, message, kind)

/obj/overmap/proc/refresh_heading_overlay()
	var/speed_band = OVERMAP_SPEED_STOPPED(get_speed()) ? 0 : 1
	var/heading = speed_band ? get_heading_angle() : 0
	if(rotate_sprite_with_heading)
		transform = speed_band ? matrix().Turn(heading + 180) : matrix()
	if(speed_band == last_overlay_speed_band && heading == last_overlay_heading)
		return
	last_overlay_speed_band = speed_band
	last_overlay_heading = heading
	update_icon(UPDATE_OVERLAYS)

/obj/overmap/proc/process_movement(elapsed)
	if(halted || !movable || !is_moving())
		update_overmap_pixel()
		refresh_heading_overlay()
		return
	if(!isturf(loc) || !sector)
		return

	var/list/deltas = list(0, 0)
	var/travel = sector.tile_travel || 1
	for(var/i in 1 to 2)
		if(!speed[i])
			continue
		position[i] += speed[i] * elapsed / travel
		if(position[i] >= OVERMAP_TILE_EDGE)
			deltas[i] = 1
			position[i] -= 1
			position[i] = min(position[i], OVERMAP_TILE_EDGE - OVERMAP_MOVE_RESOLUTION)
		else if(position[i] <= -OVERMAP_TILE_EDGE)
			deltas[i] = -1
			position[i] += 1
			position[i] = max(position[i], -OVERMAP_TILE_EDGE + OVERMAP_MOVE_RESOLUTION)

	refresh_heading_overlay()

	if(!deltas[1] && !deltas[2])
		update_overmap_pixel()
		return

	var/new_x = x + deltas[1]
	var/new_y = y + deltas[2]
	var/min_x = sector.origin_x + 1
	var/max_x = sector.origin_x + sector.size - 2
	var/min_y = sector.origin_y + 1
	var/max_y = sector.origin_y + sector.size - 2
	if(new_x < min_x || new_x > max_x || new_y < min_y || new_y > max_y)
		if(wraparound && sector.wraparound)
			handle_wraparound(new_x, new_y)
		else
			speed[1] = 0
			speed[2] = 0
			update_overmap_pixel()
		return
	var/turf/newloc = locate(new_x, new_y, z)
	if(newloc && loc != newloc)
		Move(newloc)
		setDir(SOUTH)
		update_overmap_pixel()
		on_overmap_loc_changed()
		return
	update_overmap_pixel()

/obj/overmap/proc/handle_wraparound(new_x, new_y)
	if(!sector)
		return
	var/unwrapped_x = new_x
	var/unwrapped_y = new_y
	var/low_x = sector.origin_x + 1
	var/high_x = sector.origin_x + sector.size - 2
	var/low_y = sector.origin_y + 1
	var/high_y = sector.origin_y + sector.size - 2
	if(new_x < low_x)
		new_x = high_x
	else if(new_x > high_x)
		new_x = low_x
	if(new_y < low_y)
		new_y = high_y
	else if(new_y > high_y)
		new_y = low_y
	var/turf/wrapped = locate(new_x, new_y, z)
	if(wrapped)
		forceMove(wrapped)
		on_sector_wrap(new_x - unwrapped_x, new_y - unwrapped_y)
		setDir(SOUTH)
		update_overmap_pixel()
		on_overmap_loc_changed()

/obj/overmap/proc/on_sector_wrap(delta_x, delta_y)
	return

/obj/overmap/update_overlays()
	. = ..()
	if(OVERMAP_SPEED_STOPPED(get_speed()))
		return
	var/mutable_appearance/arrow = mutable_appearance(icon, "heading_indicator", ABOVE_OBJ_LAYER)
	arrow.appearance_flags = RESET_COLOR | RESET_TRANSFORM | KEEP_APART
	arrow.dir = SOUTH
	arrow.transform = matrix().Turn(get_heading_angle() + 180)
	. += arrow

/obj/overmap/Click(location, control, params)
	var/obj/machinery/computer/sensors/sensors = overmap_open_sensor_console(usr)
	if(!istype(sensors))
		sensors = usr?.machine
	if(istype(sensors) && sensors.try_map_click(usr, src))
		return
	return ..()
