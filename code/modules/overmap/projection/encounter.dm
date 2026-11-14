/obj/overmap/entity/proc/map_hull(keep_center = FALSE)
	unwatch_hull()
	hull_dirty = FALSE

	hull_version++
	hull_turfs = list()

	hull_area_turfs = list()
	hull_watch = list()
	var/min_x = world.maxx
	var/max_x = 1
	var/min_y = world.maxy
	var/max_y = 1

	var/list/occupied = list()
	var/list/claimed = list()
	var/list/parts = list(src)
	if(!docked_ship)
		parts += docked_guests
	for(var/obj/overmap/entity/part as anything in parts)
		for(var/turf/hull_turf as anything in part.shuttle.overmap_collect_hull(get_turf(part.shuttle)))
			if(!hull_turf)
				continue
			occupied[hull_turf] = TRUE
			if(part.shuttle.shuttle_areas[get_area(hull_turf)])
				claimed[hull_turf] = TRUE
	var/list/owned = length(claimed) ? claimed : occupied
	for(var/turf/hull_turf as anything in owned)
		hull_area_turfs[hull_turf] = TRUE
		hull_watch += hull_turf
		RegisterSignal(hull_turf, COMSIG_TURF_CHANGE, PROC_REF(on_hull_turf_changed))
		if(isspaceturf(hull_turf))
			continue
		hull_turfs[hull_turf] = TRUE
		min_x = min(min_x, hull_turf.x)
		max_x = max(max_x, hull_turf.x)
		min_y = min(min_y, hull_turf.y)
		max_y = max(max_y, hull_turf.y)
	if(!keep_center)
		hull_center_x = (min_x + max_x) / 2
		hull_center_y = (min_y + max_y) / 2
	hull_edge = list()
	var/spread = 0
	for(var/turf/hull_turf as anything in hull_turfs)
		spread += (hull_turf.x - hull_center_x) ** 2 + (hull_turf.y - hull_center_y) ** 2
		for(var/direction in GLOB.cardinal)
			if(!hull_turfs[get_step(hull_turf, direction)])
				hull_edge += hull_turf
				break
	hull_inertia = max(spread / max(length(hull_turfs), 1), 1)
	hull_z = shuttle.z
	hull_collars = list()
	for(var/obj/machinery/door/airlock/external/docking/door as anything in overmap_shuttle?.shuttle_collars())
		var/turf/door_turf = get_turf(door)
		var/turf/preferred_outside = get_step(door_turf, door.dir)
		if(preferred_outside && !hull_turfs[preferred_outside])
			hull_collars += list(list(door_turf, preferred_outside, dir2angle(door.dir)))
			continue
		for(var/direction in GLOB.cardinal)
			var/turf/outside = get_step(door_turf, direction)
			if(outside && !hull_turfs[outside])
				hull_collars += list(list(door_turf, outside, dir2angle(direction)))
				break
	var/list/radar_tiles = list()
	for(var/turf/hull_turf as anything in hull_turfs)
		radar_tiles += (hull_turf.x - hull_center_x) * 2
		radar_tiles += (hull_turf.y - hull_center_y) * 2
	var/list/radar_collars = list()
	for(var/list/collar as anything in hull_collars)
		var/turf/door_turf = collar[1]
		radar_collars += (door_turf.x - hull_center_x) * 2
		radar_collars += (door_turf.y - hull_center_y) * 2
	radar_shape = list("tiles" = radar_tiles, "collars" = radar_collars)
	hull_radius = sqrt(max(abs(min_x - hull_center_x), abs(max_x - hull_center_x)) ** 2 + max(abs(min_y - hull_center_y), abs(max_y - hull_center_y)) ** 2) + 1
	var/obj/docking_port/stationary/transit/pad = shuttle.get_docked()
	flight_bounds = (istype(pad) && hyperspace_reservation_bounds(pad.reserved_area)) || list(1, 1, world.maxx, world.maxy)
	if(SSovermap.flight_reservations[flight_reservation] == src)
		SSovermap.flight_reservations -= flight_reservation
	flight_reservation = null
	if(istype(pad) && pad.reserved_area)
		flight_reservation = pad.reserved_area
		SSovermap.flight_reservations[flight_reservation] = src
	else if(formation_pad && docked_ship)
		flight_reservation = docked_ship.flight_reservation
		flight_bounds = docked_ship.flight_bounds

/obj/overmap/entity/proc/on_hull_turf_changed()
	SIGNAL_HANDLER
	hull_dirty = TRUE

/obj/overmap/entity/proc/unwatch_hull()
	for(var/turf/watched as anything in hull_watch)
		UnregisterSignal(watched, COMSIG_TURF_CHANGE)
	hull_watch = null

/obj/overmap/entity/proc/remap_hull()
	map_hull(keep_center = TRUE)
	for(var/obj/overmap/entity/other as anything in SSovermap.flying_vessels)
		if(other.neighbor_proxies[src])
			qdel(other.neighbor_proxies[src])
			other.neighbor_proxies -= src
	for(var/datum/overmap_bubble/bubble as anything in SSovermap.bubbles)
		if(bubble.ship_proxies[src])
			qdel(bubble.ship_proxies[src])
			bubble.ship_proxies -= src

/obj/overmap/entity/proc/clear_encounter_visuals()
	SSovermap_visuals.remove(src)
	scatter_candidates = list()
	QDEL_LIST_ASSOC_VAL(scatter_proxies)
	QDEL_NULL(scatter_fog)
	QDEL_NULL(docking_approach)
	unwatch_hull()
	undock_ship()
	QDEL_NULL(terrain_view)
	for(var/obj/overmap/entity/guest as anything in docked_guests)
		guest.undock_ship()
	QDEL_LIST_ASSOC_VAL(neighbor_proxies)
	QDEL_LIST_ASSOC_VAL(drifter_mirrors)
	nearby_ships = list()
	for(var/obj/overmap/entity/other as anything in SSovermap.flying_vessels)
		other.nearby_ships -= src
		if(other.neighbor_proxies[src])
			qdel(other.neighbor_proxies[src])
			other.neighbor_proxies -= src
	for(var/datum/overmap_bubble/bubble as anything in SSovermap.bubbles)
		bubble.ships -= src
		if(bubble.ship_proxies[src])
			qdel(bubble.ship_proxies[src])
			bubble.ship_proxies -= src
	if(SSovermap.flight_reservations[flight_reservation] == src)
		SSovermap.flight_reservations -= flight_reservation
	flight_reservation = null
	hull_turfs = null
	hull_edge = null
	hull_collars = null
	radar_shape = null
	flight_bounds = null

/obj/overmap/entity/proc/get_facing()
	return flight?.facing || 0

/obj/overmap/entity/proc/get_world_x()
	var/turf/here = get_overmap_turf()
	return here ? (here.x + position[1]) * OVERMAP_TILE_SPAN * (sector?.tile_travel || 1) : 0

/obj/overmap/entity/proc/get_world_y()
	var/turf/here = get_overmap_turf()
	return here ? (here.y + position[2]) * OVERMAP_TILE_SPAN * (sector?.tile_travel || 1) : 0

/obj/overmap/entity/proc/set_world_position(world_x, world_y)
	var/span = OVERMAP_TILE_SPAN * (sector?.tile_travel || 1)
	var/tile_x = round(world_x / span, 1)
	var/tile_y = round(world_y / span, 1)
	position = list(world_x / span - tile_x, world_y / span - tile_y)
	var/turf/here = get_overmap_turf()
	var/turf/tile = locate(tile_x, tile_y, here.z)
	if(tile && tile != loc)
		forceMove(tile)
		on_overmap_loc_changed()
	update_overmap_pixel()

/obj/overmap/entity/proc/total_mass()
	. = vessel_mass
	for(var/obj/overmap/entity/guest as anything in docked_guests)
		. += guest.vessel_mass

/obj/overmap/entity/proc/relative_speed(obj/overmap/entity/other)
	return sqrt((speed[1] - other.speed[1]) ** 2 + (speed[2] - other.speed[2]) ** 2) * OVERMAP_TILE_SPAN

/obj/overmap/entity/proc/station_dock_targets(reach, include_busy = FALSE)
	. = list()
	var/list/center = local_space.to_bubble(get_world_x(), get_world_y())
	for(var/obj/docking_port/stationary/pad as anything in SSshuttle.stationary)
		var/obj/machinery/door/airlock/external/docking/airlock = pad.dock_airlock
		if(!airlock || pad.z != local_space.bubble_z || abs(pad.x - center[1]) > reach || abs(pad.y - center[2]) > reach || (!include_busy && pad.get_docked()))
			continue
		var/obj/overmap/entity/owner = SSovermap.shuttle_vessels[SSovermap.get_shuttle_at(airlock)]
		. += list(list(airlock, get_turf(pad), airlock.dir, pad, owner?.get_overmap_display_name() || airlock.get_helm_label()))
	var/list/seen_hosts = list()
	for(var/obj/docking_port/mobile/port as anything in SSshuttle.mobile)
		if(port == shuttle || port.mode != SHUTTLE_IDLE || port.z != local_space.bubble_z || abs(port.x - center[1]) > reach + max(port.width, port.height) || abs(port.y - center[2]) > reach + max(port.width, port.height))
			continue
		var/obj/overmap/entity/host = SSovermap.shuttle_vessels[port]
		var/obj/docking_port/stationary/port_pad = port.get_docked()
		if(!host?.overmap_shuttle || host.programmed || seen_hosts[host] || !port_pad || istype(port_pad, /obj/docking_port/stationary/transit))
			continue
		seen_hosts[host] = TRUE
		for(var/obj/machinery/door/airlock/external/docking/collar as anything in host.overmap_shuttle.shuttle_collars())
			if(collar.overmap_pad)
				continue
			for(var/direction in GLOB.cardinal)
				var/turf/outside = get_step(collar, direction)
				if(isspaceturf(outside) && !port.shuttle_areas[outside.loc])
					. += list(list(collar, outside, direction, null, host.get_overmap_display_name()))
					break

/obj/overmap/entity/proc/dock_to_station(list/own, list/target)
	var/turf/door_turf = own[1]
	var/obj/machinery/door/airlock/external/docking/collar = locate() in door_turf
	if(!collar)
		return "Стыковочный шлюз корабля не найден."
	shuttle.overmap_collar = collar
	var/obj/machinery/door/airlock/external/docking/airlock = target[1]
	var/obj/docking_port/stationary/pad = target[4]
	var/old_dir = airlock.dir
	if(!pad)
		pad = new /obj/docking_port/stationary/overmap(target[2])
		pad.setDir(target[3])
		airlock.setDir(target[3])
		pad.dock_airlock = airlock
		airlock.overmap_pad = pad
		airlock.owns_overmap_pad = TRUE
		airlock.sync_dock_label()
	var/can_status = shuttle.canDock(pad)
	if(can_status != SHUTTLE_CAN_DOCK)
		if(!target[4])
			qdel(pad, TRUE)
			airlock.setDir(old_dir)
		return dock_fail_text(can_status)
	speed[1] = 0
	speed[2] = 0
	flight.angular_velocity = 0
	flight.release_pilot()
	flight.set_autopilot(FALSE, manual = FALSE)
	selected_dock_id = pad.id
	play_shuttle_sound('sound/effects/clang.ogg')
	shake_shuttle(OVERMAP_SHIP_DOCK_SHAKE_TIME, OVERMAP_SHIP_DOCK_SHAKE_STRENGTH)
	announce_sensor_event("Стыковка: [get_overmap_display_name()] → [target[5]]", "dock")
	INVOKE_ASYNC(src, PROC_REF(finish_station_dock), pad)
	return TRUE

/obj/overmap/entity/proc/finish_station_dock(obj/docking_port/stationary/pad)
	if(shuttle.dock(pad) != DOCKING_SUCCESS)
		shuttle_visible_message(span_warning("Захваты стыковочного шлюза не сработали."))

/obj/overmap/entity/proc/radar_station_docks()
	. = list()
	if(!local_space)
		return
	for(var/list/target as anything in station_dock_targets(OVERMAP_RADAR_DOCK_RANGE))
		var/obj/machinery/door/airlock/external/docking/airlock = target[1]
		. += airlock.x * 2
		. += airlock.y * 2

/obj/overmap/entity/proc/dock_to_ship(obj/overmap/entity/host, list/own, list/theirs)
	if(QDELETED(host) || host == src || docked_ship || host.docked_ship || sector != host.sector)
		return FALSE
	if(shuttle && host.shuttle)
		return dock_physical_ship(host, own, theirs)
	var/new_facing = SIMPLIFY_DEGREES(theirs[3] + host.get_facing() + 180 - own[3])
	flight.angular_velocity = 0
	flight.set_facing(new_facing)
	var/turf/own_outside = own[2]
	var/turf/their_door = theirs[1]
	var/list/door_world = host.hull_to_world(their_door.x, their_door.y)
	var/local_x = own_outside.x - hull_center_x
	var/local_y = own_outside.y - hull_center_y
	var/world_x = door_world[1] - (local_x * cos(new_facing) + local_y * sin(new_facing))
	var/world_y = door_world[2] - (local_y * cos(new_facing) - local_x * sin(new_facing))
	set_world_position(world_x, world_y)
	remember_pose()
	var/list/in_host = host.world_to_hull(world_x, world_y)
	docked_ship = host
	dock_hull_x = in_host[1]
	dock_hull_y = in_host[2]
	dock_facing_offset = new_facing - host.get_facing()
	dock_collar_angle = own[3]
	dock_host_collar = theirs[1]
	host.docked_guests += src
	speed[1] = host.speed[1]
	speed[2] = host.speed[2]
	dock_seals += new /obj/effect/abstract/dock_seal(own_outside)
	dock_seals += new /obj/effect/abstract/dock_seal(theirs[2])
	flight.release_pilot()
	flight.set_autopilot(FALSE, manual = FALSE)
	for(var/obj/overmap/entity/joined as anything in list(src, host))
		joined.play_shuttle_sound('sound/effects/clang.ogg')
		joined.shake_shuttle(OVERMAP_SHIP_DOCK_SHAKE_TIME, OVERMAP_SHIP_DOCK_SHAKE_STRENGTH)
	announce_sensor_event("Стыковка: [get_overmap_display_name()] → [host.get_overmap_display_name()]", "dock")

/obj/overmap/entity/proc/undock_ship()
	set waitfor = FALSE
	var/obj/overmap/entity/host = docked_ship
	if(!host)
		return
	var/push_angle = dock_collar_angle + get_facing()
	if(formation_pad && !leave_physical_formation())
		return
	host.docked_guests -= src
	docked_ship = null
	dock_host_collar = null
	QDEL_LIST(dock_seals)
	speed[1] -= sin(push_angle) * OVERMAP_SHIP_UNDOCK_PUSH / OVERMAP_TILE_SPAN
	speed[2] -= cos(push_angle) * OVERMAP_SHIP_UNDOCK_PUSH / OVERMAP_TILE_SPAN
	announce_sensor_event("Расстыковка: [get_overmap_display_name()] ← [host.get_overmap_display_name()]", "undock")

/obj/overmap/entity/proc/follow_host()
	if(!(docked_ship in SSovermap.flying_vessels))
		undock_ship()
		return
	var/list/spot = docked_ship.hull_to_world(dock_hull_x, dock_hull_y)
	local_space = docked_ship.local_space
	flight.set_facing(docked_ship.get_facing() + dock_facing_offset)
	set_world_position(spot[1], spot[2])
	var/list/carried_speed = docked_ship.world_point_velocity(spot[1], spot[2])
	speed[1] = carried_speed[1]
	speed[2] = carried_speed[2]

/obj/overmap/entity/proc/world_point_velocity(world_x, world_y)
	var/spin = TORADIANS(flight?.angular_velocity || 0)
	return list(speed[1] + (world_y - get_world_y()) * spin / OVERMAP_TILE_SPAN, speed[2] - (world_x - get_world_x()) * spin / OVERMAP_TILE_SPAN)

/obj/effect/abstract/dock_seal
	name = "dock seal"
	simulated = FALSE

/obj/effect/abstract/dock_seal/Initialize(mapload)
	. = ..()
	recalculate_atmos_connectivity()

/obj/effect/abstract/dock_seal/Destroy()
	var/turf/sealed = loc
	. = ..()
	sealed?.recalculate_atmos_connectivity()

/obj/effect/abstract/dock_seal/CanAtmosPass(direction)
	return FALSE

/obj/overmap/entity/proc/world_to_hull(world_x, world_y, origin_x = get_world_x(), origin_y = get_world_y(), facing = get_facing())
	var/delta_x = world_x - origin_x
	var/delta_y = world_y - origin_y
	return list(hull_center_x + delta_x * cos(facing) - delta_y * sin(facing), hull_center_y + delta_x * sin(facing) + delta_y * cos(facing))

/obj/overmap/entity/proc/hull_to_world(hull_x, hull_y, origin_x = get_world_x(), origin_y = get_world_y(), facing = get_facing())
	var/local_x = hull_x - hull_center_x
	var/local_y = hull_y - hull_center_y
	return list(origin_x + local_x * cos(facing) + local_y * sin(facing), origin_y - local_x * sin(facing) + local_y * cos(facing))

/obj/overmap/entity/proc/hull_turf_at(world_x, world_y, origin_x = get_world_x(), origin_y = get_world_y(), facing = get_facing())
	if(!length(hull_turfs) || !hull_z)
		return null
	var/list/spot = world_to_hull(world_x, world_y, origin_x, origin_y, facing)
	var/turf/hull_turf = locate(FLOOR(spot[1] + 0.5, 1), FLOOR(spot[2] + 0.5, 1), hull_z)
	return hull_turf && hull_turfs[hull_turf] ? hull_turf : null

/obj/overmap/entity/proc/quarter_turns()
	return round(get_facing() / 90, 1) * 90

/obj/overmap/entity/proc/update_neighbors(list/flying)
	nearby_ships = list()
	for(var/obj/overmap/entity/other as anything in flying)
		if(other == src || other.sector != sector || other.formation_pad || (formation_pad && other == docked_ship))
			continue
		var/distance = sqrt((other.get_world_x() - get_world_x()) ** 2 + (other.get_world_y() - get_world_y()) ** 2) - hull_radius - other.hull_radius
		if(distance <= OVERMAP_CONTACT_RANGE)
			nearby_ships[other] = TRUE

/obj/overmap/entity/proc/show_neighbors(elapsed, watched)
	var/list/seen = list()
	if(watched)
		for(var/obj/overmap/entity/other as anything in nearby_ships)
			if(QDELETED(other) || other.sector != sector || !other.free_flight_view)
				continue
			var/list/spot = world_to_hull(other.get_world_x(), other.get_world_y())
			var/distance = sqrt((spot[1] - hull_center_x) ** 2 + (spot[2] - hull_center_y) ** 2) - hull_radius - other.hull_radius
			if(distance > OVERMAP_NEIGHBOR_RANGE)
				continue
			seen[other] = TRUE
			var/datum/hull_proxy/proxy = neighbor_proxies[other]
			if(QDELETED(proxy))
				proxy = other.create_hull_proxy(locate(round(hull_center_x), round(hull_center_y), hull_z))
				neighbor_proxies[other] = proxy
			proxy.place(spot[1], spot[2], hull_z, other.get_facing() - get_facing(), flight_bounds, elapsed)
	for(var/obj/overmap/entity/other as anything in neighbor_proxies)
		if(!seen[other])
			qdel(neighbor_proxies[other])
			neighbor_proxies -= other

/obj/overmap/entity/proc/update_flight_visuals(elapsed)
	if(!free_flight_view || formation_pad || formation_transfer)
		return
	var/is_watched = SSovermap.visual_watched[src]
	draw_scatter(scatter_candidates, elapsed, is_watched)
	show_neighbors(elapsed, is_watched)
	if(is_watched)
		show_drifters(SSovermap.bubbles, elapsed)
		update_terrain_view(elapsed)
	else
		QDEL_LIST_ASSOC_VAL(drifter_mirrors)
		QDEL_NULL(terrain_view)

/obj/overmap/entity/proc/radar_contacts()
	. = list(list("id" = UID(), "x" = 0, "y" = 0, "rot" = 0, "own" = TRUE))
	for(var/obj/overmap/entity/other as anything in nearby_ships)
		var/list/spot = world_to_hull(other.get_world_x(), other.get_world_y())
		var/closing = ((speed[1] - other.speed[1]) * (other.get_world_x() - get_world_x()) + (speed[2] - other.speed[2]) * (other.get_world_y() - get_world_y()))
		var/distance = sqrt((other.get_world_x() - get_world_x()) ** 2 + (other.get_world_y() - get_world_y()) ** 2)
		. += list(list(
			"id" = other.UID(),
			"name" = other.get_overmap_display_name(),
			"x" = spot[1] - hull_center_x,
			"y" = spot[2] - hull_center_y,
			"rot" = other.get_facing() - get_facing(),
			"distance" = round(distance, 1),
			"closing" = distance ? round(closing / distance * OVERMAP_TILE_SPAN * (1 SECONDS), 0.1) : 0,
			"docked" = other.docked_ship == src || docked_ship == other,
			"destroyed" = other.is_ai_destroyed(),
		))

/obj/overmap/entity/proc/radar_drifters()
	. = list()
	for(var/drifter_entry, mirror_entry in drifter_mirrors)
		var/atom/movable/drifter = drifter_entry
		var/obj/effect/abstract/hull_proxy_tile/mirror = mirror_entry
		. += list(list(round(mirror.x + mirror.pixel_x / ICON_SIZE_X - hull_center_x, 0.1), round(mirror.y + mirror.pixel_y / ICON_SIZE_Y - hull_center_y, 0.1), isliving(drifter) && drifter:stat != DEAD))

/obj/overmap/entity/proc/radar_engines()
	. = list()
	for(var/obj/machinery/ship_engine/engine as anything in engines)
		if(!engine.virtual_engine_owner && engine.z != hull_z)
			continue
		var/list/directions = engine.push_directions()
		for(var/key in directions)
			var/push = text2num(key)
			var/firing = engine.firing && (engine.active_pushes & push)
			var/strength = firing ? engine.last_applied_thrust * directions[key] / (OVERMAP_ENGINE_SMALL_THRUST * 4) : 0
			. += list(list(engine.thrust_origin_x() - hull_center_x, engine.thrust_origin_y() - hull_center_y, REVERSE_DIR(push), firing, round(strength, 0.001)))

/obj/overmap/entity/proc/radar_shapes()
	. = list()
	if(radar_shape)
		radar_shape["revision"] = hull_version
	.[UID()] = radar_shape
	for(var/obj/overmap/entity/other as anything in nearby_ships)
		if(other.radar_shape)
			other.radar_shape["revision"] = other.hull_version
		.[other.UID()] = other.radar_shape

/obj/overmap/entity/proc/show_drifters(list/bubbles, elapsed)
	var/list/seen = list()
	var/matrix/turned = matrix()
	turned.Turn(-get_facing())
	for(var/datum/overmap_bubble/bubble as anything in bubbles)
		if(bubble.sector != sector)
			continue
		for(var/atom/movable/drifter as anything in bubble.drifters)
			var/obj/projectile/projectile = drifter
			var/list/drifter_world = bubble.to_world(drifter.x, drifter.y)
			var/list/spot = world_to_hull(drifter_world[1], drifter_world[2])
			if(sqrt((spot[1] - hull_center_x) ** 2 + (spot[2] - hull_center_y) ** 2) > hull_radius + OVERMAP_DRIFTER_RANGE)
				continue
			seen[drifter] = TRUE
			var/obj/effect/abstract/hull_proxy_tile/mirror = drifter_mirrors[drifter]
			if(!mirror)
				mirror = new(null)
				mirror.vis_contents += drifter
				if(ismob(drifter) || drifter.hud_list)
					mirror.hud_sources = list(drifter)
					SSovermap.proxy_hud_tiles[mirror] = TRUE
				if(istype(projectile))
					mirror.appearance_flags |= KEEP_TOGETHER
				drifter_mirrors[drifter] = mirror
			mirror.glide(spot[1], spot[2], hull_z, turned, flight_bounds, elapsed)
	for(var/atom/movable/drifter as anything in drifter_mirrors)
		if(!seen[drifter])
			qdel(drifter_mirrors[drifter])
			drifter_mirrors -= drifter

/obj/overmap/entity/proc/foreign_hull_at(turf/exit_turf, blocking = FALSE)
	var/list/exit_world = hull_to_world(exit_turf.x, exit_turf.y)
	for(var/obj/overmap/entity/other as anything in SSovermap.flying_vessels)
		if(other == src || other.sector != sector)
			continue
		var/turf/hull_turf = blocking ? other.solid_hull_at(exit_world[1], exit_world[2]) : other.hull_turf_at(exit_world[1], exit_world[2])
		if(hull_turf)
			return list(other, hull_turf)

/obj/overmap/entity/proc/eject_to_bubble(atom/movable/thing, turf/exit_turf)
	if(overmap_hull_gripped(thing, src))
		return TRUE
	var/obj/projectile/bullet = thing
	if(istype(bullet) && bullet.overmap_persistent)
		var/list/point = hull_to_world(exit_turf.x + (bullet.trajectory ? bullet.trajectory.return_px() / ICON_SIZE_X : 0), exit_turf.y + (bullet.trajectory ? bullet.trajectory.return_py() / ICON_SIZE_Y : 0))
		if(SSovermap.launch_sector_projectile(bullet, sector, point[1], point[2], bullet.Angle + get_facing(), src))
			return TRUE
	var/list/foreign = foreign_hull_at(exit_turf)
	var/turf/foreign_turf = foreign?[2]
	if(foreign_turf && !foreign_turf.is_blocked_turf(exclude_mobs = TRUE))
		var/obj/overmap/entity/other = foreign[1]
		cross_frame_with_pull(thing, foreign_turf)
		if(istype(bullet))
			bullet.cross_frames(get_facing() - other.get_facing())
		else
			thing.setDir(turn(thing.dir || SOUTH, other.quarter_turns() - quarter_turns()))
		return TRUE
	var/list/exit_world = hull_to_world(exit_turf.x, exit_turf.y)

	var/datum/overmap_bubble/bubble = local_space?.static_level ? local_space : null
	if(!bubble)
		for(var/datum/overmap_bubble/place as anything in SSovermap.bubbles_by_z)
			if(!place?.static_level)
				continue
			if(abs(place.origin_x - exit_world[1]) > OVERMAP_BUBBLE_SIZE || abs(place.origin_y - exit_world[2]) > OVERMAP_BUBBLE_SIZE)
				continue
			bubble = place
			break
	bubble = bubble || local_space || SSovermap.find_bubble(sector, exit_world[1], exit_world[2])
	var/turf/landing = bubble?.turf_at(exit_world[1], exit_world[2])
	if(!landing && bubble?.static_level)

		var/list/origin = undock_origin
		if(origin && origin[1] <= length(SSovermap.bubbles_by_z) && SSovermap.bubbles_by_z[origin[1]])
			landing = locate(clamp(round(origin[2]), 1, world.maxx), clamp(round(origin[3]), 1, world.maxy), origin[1])
	if(!landing)
		log_game("OVERMAP: no landing turf to eject [thing] to at ([exit_world[1]], [exit_world[2]]); staying in transit.")
		return FALSE
	if(istype(bullet))
		if(landing.is_blocked_turf())
			bump_into_hull(bullet, landing)
			return TRUE
		bullet.forceMove(landing)
		bullet.cross_frames(get_facing())
		return TRUE
	var/drift_dir = turn(thing.dir || SOUTH, -quarter_turns())
	for(var/step in 1 to OVERMAP_EJECT_CLEARANCE)
		if(!bubble.hull_under(landing))
			break
		landing = get_step(landing, drift_dir) || landing
	cross_frame_with_pull(thing, landing)
	thing.setDir(drift_dir)
	thing.newtonian_move(drift_dir)
	return TRUE

/obj/effect/abstract/overmap_contact_proxy
	name = "overmap projection"
	simulated = FALSE
	animate_movement = NO_STEPS
	var/atom/source
	var/datum/overmap_bubble/owner
	var/last_x
	var/last_y
	var/last_z
	var/next_refresh = 0

/obj/effect/abstract/overmap_contact_proxy/New(atom/new_source, datum/overmap_bubble/new_owner)
	..()
	source = new_source
	owner = new_owner
	refresh_appearance()

/obj/effect/abstract/overmap_contact_proxy/Destroy()
	if(owner?.contact_proxies[source] == src)
		owner.contact_proxies -= source
	source = null
	owner = null
	return ..()

/obj/effect/abstract/overmap_contact_proxy/proc/refresh_appearance()
	if(!source || QDELETED(source))
		return
	var/mutable_appearance/copy = new(source)
	copy.invisibility = 0
	copy.mouse_opacity = MOUSE_OPACITY_OPAQUE

	copy.pixel_x = 0
	copy.pixel_y = 0
	appearance = copy
	opacity = source.opacity

/obj/effect/abstract/overmap_contact_proxy/proc/place(x, y, z)
	if(!source || QDELETED(source))
		return
	if(x == last_x && y == last_y && z == last_z)
		if(world.time >= next_refresh)
			next_refresh = world.time + OVERMAP_SLOW_TICK
			refresh_appearance()
		return
	last_x = x
	last_y = y
	last_z = z
	var/anchor_x = clamp(round(x), owner.bounds[1], owner.bounds[3])
	var/anchor_y = clamp(round(y), owner.bounds[2], owner.bounds[4])
	var/turf/new_anchor = locate(anchor_x, anchor_y, z)
	if(!new_anchor)
		return
	var/turf/old_anchor = loc
	if(old_anchor && old_anchor.z == z)
		pixel_x += (old_anchor.x - anchor_x) * ICON_SIZE_X
		pixel_y += (old_anchor.y - anchor_y) * ICON_SIZE_Y
	else
		forceMove(new_anchor)
		pixel_x = (x - anchor_x) * ICON_SIZE_X
		pixel_y = (y - anchor_y) * ICON_SIZE_Y
		refresh_appearance()
		return
	forceMove(new_anchor)
	animate(src, pixel_x = (x - anchor_x) * ICON_SIZE_X, pixel_y = (y - anchor_y) * ICON_SIZE_Y, time = OVERMAP_FLIGHT_TICK)

	if(world.time >= next_refresh)
		next_refresh = world.time + OVERMAP_SLOW_TICK
		refresh_appearance()

/obj/effect/abstract/overmap_contact_proxy/Click(location, control, params)
	if(!source || QDELETED(source) || !usr)
		return ..()
	return usr.ClickOn(source, params, location)

/datum/controller/subsystem/overmap/proc/frame_owner(turf/spot)
	return flight_reservations[SSmapping.used_turfs[spot]] || bubble_for_turf(spot)

/datum/controller/subsystem/overmap/proc/frame_viewports(datum/owner)
	. = list()
	for(var/client/viewer as anything in client_eyes)
		var/turf/eye = get_turf(viewer.eye || viewer.mob)
		if(frame_owner(eye) == owner)
			. += list(list(eye, (viewer.maxview() || world.view) + 4))

/datum/controller/subsystem/overmap/proc/frame_sector(datum/owner)
	var/obj/overmap/entity/vessel = owner
	if(istype(vessel))
		return vessel.sector
	var/datum/overmap_bubble/bubble = owner
	return bubble.sector

/datum/controller/subsystem/overmap/proc/frame_to_world(datum/owner, turf/spot)
	var/obj/overmap/entity/vessel = owner
	if(istype(vessel))
		return vessel.hull_to_world(spot.x, spot.y)
	var/datum/overmap_bubble/bubble = owner
	return bubble.to_world(spot.x, spot.y)

/datum/controller/subsystem/overmap/proc/world_to_frame(datum/owner, world_x, world_y)
	var/obj/overmap/entity/vessel = owner
	if(!istype(vessel))
		var/datum/overmap_bubble/bubble = owner
		return bubble.turf_at(world_x, world_y)
	var/list/spot = vessel.world_to_hull(world_x, world_y)
	var/hull_x = FLOOR(spot[1] + 0.5, 1)
	var/hull_y = FLOOR(spot[2] + 0.5, 1)
	var/list/bounds = vessel.flight_bounds
	if(!bounds)
		return null
	if(hull_x < bounds[1] || hull_x > bounds[3] || hull_y < bounds[2] || hull_y > bounds[4])
		return null
	return locate(hull_x, hull_y, vessel.hull_z)

/datum/controller/subsystem/overmap/proc/mirror_turf(turf/spot, turf/viewer_turf)
	var/datum/spot_owner = frame_owner(spot)
	var/datum/viewer_owner = frame_owner(viewer_turf)
	if(!spot_owner || !viewer_owner || spot_owner == viewer_owner || frame_sector(spot_owner) != frame_sector(viewer_owner))
		return null
	var/list/point = frame_to_world(spot_owner, spot)
	return world_to_frame(viewer_owner, point[1], point[2])

/datum/controller/subsystem/overmap/proc/mirror_target(atom/target, atom/viewer)
	if(!length(flying_vessels))
		return target
	var/turf/target_turf = get_turf(target)
	var/turf/viewer_turf = get_turf(viewer)
	if(!target_turf || !viewer_turf)
		return target
	return mirror_turf(target_turf, viewer_turf) || target

/datum/controller/subsystem/overmap/proc/mirror_explosion(datum/source, datum/explosion_data/data, silent)
	SIGNAL_HANDLER
	if(mirroring_explosion || !data?.epicenter)
		return
	var/datum/origin = frame_owner(data.epicenter)
	if(!origin)
		return
	var/datum/overmap_sector/sector = frame_sector(origin)
	var/list/point = frame_to_world(origin, data.epicenter)
	var/reach = max(data.devastation_range, data.heavy_impact_range, data.light_impact_range, data.flame_range, data.flash_range)
	var/obj/overmap/entity/origin_vessel = origin
	var/origin_heading = istype(origin_vessel) ? origin_vessel.get_facing() : 0
	var/list/datum/targets = list()
	for(var/obj/overmap/entity/vessel as anything in flying_vessels)
		if(vessel == origin || vessel.sector != sector || istype(vessel, /obj/overmap/entity/virtual_structure))
			continue
		if(sqrt((vessel.get_world_x() - point[1]) ** 2 + (vessel.get_world_y() - point[2]) ** 2) <= vessel.hull_radius + reach)
			targets += vessel
	for(var/datum/overmap_bubble/bubble as anything in bubbles)
		if(bubble != origin && bubble.sector == sector && bubble.covers(bubble.to_bubble(point[1], point[2]), reach))
			targets += bubble
	mirroring_explosion = TRUE
	affect_projected_explosion(sector, point[1], point[2], data.devastation_range, data.heavy_impact_range, data.light_impact_range, data.protect_epicenter, data.explosion_direction + origin_heading, data.explosion_arc)
	var/list/seen = list(data.epicenter)
	for(var/datum/target as anything in targets)
		var/turf/mirrored = world_to_frame(target, point[1], point[2])
		if(!mirrored || (mirrored in seen))
			continue
		seen += mirrored
		var/obj/overmap/entity/target_vessel = target
		var/target_heading = istype(target_vessel) ? target_vessel.get_facing() : 0
		explosion(mirrored, data.devastation_range, data.heavy_impact_range, data.light_impact_range, data.flash_range, adminlog = FALSE, ignorecap = TRUE, flame_range = data.flame_range, silent = silent, smoke = FALSE, cause = "overmap explosion across hull", breach = data.breach, protect_epicenter = data.protect_epicenter, explosion_direction = SIMPLIFY_DEGREES(data.explosion_direction + origin_heading - target_heading), explosion_arc = data.explosion_arc)
	mirroring_explosion = FALSE

/area/space/overmap_bubble
	name = "Open Space"
	area_flags = NONE

/turf/space/Enter(atom/movable/mover)
	. = ..()
	if(!. || !mover.simulated)
		return
	if(overmap_hyperspace_reservation(src))
		return allow_hyperspace_entry(mover)
	var/datum/overmap_bubble/bubble = SSovermap.bubble_for_turf(src)
	var/list/hull = bubble?.hull_under(src, blocking = TRUE)
	var/turf/hull_turf = hull?[2]
	if(!hull_turf?.is_blocked_turf(exclude_mobs = TRUE))
		return
	bump_into_hull(mover, hull_turf)
	return FALSE

/turf/space/transit/Enter(atom/movable/mover)
	. = ..()
	if(!.)
		return
	return allow_hyperspace_entry(mover)

/turf/space/proc/allow_hyperspace_entry(atom/movable/mover)
	if(!mover.simulated || !length(SSovermap.flying_vessels))
		return TRUE
	var/obj/overmap/entity/vessel = SSovermap.flight_reservations[SSmapping.used_turfs[src]]
	if(!vessel)
		return TRUE
	var/list/foreign = vessel.foreign_hull_at(src, blocking = TRUE)
	var/turf/hull_turf = foreign?[2]
	if(!hull_turf && vessel.local_space)
		var/list/point = vessel.hull_to_world(x, y)
		hull_turf = vessel.local_space.turf_at(point[1], point[2])
	if(!hull_turf?.is_blocked_turf(exclude_mobs = TRUE))
		return TRUE
	bump_into_hull(mover, hull_turf)
	return FALSE

/turf/space/Exited(atom/movable/gone, direction)
	. = ..()
	var/datum/overmap_bubble/bubble = SSovermap.bubble_for_turf(src)
	if(bubble?.drifters[gone] && SSovermap.bubble_for_turf(gone.loc) != bubble)
		bubble.remove_drifter(gone)

/datum/controller/subsystem/overmap/proc/bubble_for_turf(turf/spot)
	if(!isturf(spot))
		return null
	for(var/datum/overmap_bubble/bubble as anything in bubbles)
		if(bubble.static_level && bubble.bubble_z == spot.z && bubble.covers(list(spot.x, spot.y), 0))
			return bubble
	return bubbles_by_reservation[SSmapping.used_turfs[spot]]

/datum/controller/subsystem/overmap/proc/on_space_entered(turf/space/spot, atom/movable/arrived)
	if(!arrived.simulated || isobserver(arrived) || arrived.loc != spot)
		return
	var/datum/overmap_bubble/bubble = bubble_for_turf(spot)
	if(!bubble || (bubble.static_level && !length(bubble.ships)))
		return
	bubble.add_drifter(arrived)
	bubble.try_board(arrived)

/datum/controller/subsystem/overmap/proc/find_bubble(datum/overmap_sector/sector, world_x, world_y)
	for(var/datum/overmap_bubble/bubble as anything in bubbles)
		if(bubble.sector == sector && bubble.covers(bubble.to_bubble(world_x, world_y), -OVERMAP_BUBBLE_MARGIN))
			return bubble

/datum/controller/subsystem/overmap/proc/create_bubble(datum/overmap_sector/sector, world_x, world_y, speed_x, speed_y)
	if(!spare_bubble_space)
		return null
	var/datum/overmap_bubble/bubble = new(sector, world_x, world_y, speed_x, speed_y)
	bubble.fill_reservation(spare_bubble_space)
	spare_bubble_space = null
	return bubble

/datum/controller/subsystem/overmap/proc/prepare_bubble_space()
	if(spare_bubble_space || preparing_bubble_space || !length(flying_vessels))
		return
	preparing_bubble_space = TRUE
	INVOKE_ASYNC(src, PROC_REF(reserve_bubble_space))

/datum/controller/subsystem/overmap/proc/reserve_bubble_space()
	spare_bubble_space = SSmapping.request_turf_block_reservation(OVERMAP_BUBBLE_SIZE, OVERMAP_BUBBLE_SIZE)
	preparing_bubble_space = FALSE

/datum/controller/subsystem/overmap/proc/process_encounters(list/flying, elapsed)
	for(var/obj/item/overmap_hull_grip/grip as anything in hull_grips)
		grip.carry()
	for(var/obj/overmap/entity/vessel as anything in flying)
		if(vessel.docked_ship)
			vessel.follow_host()
		else
			vessel.keep_inside_local_space()
	for(var/obj/overmap/entity/vessel as anything in flying)
		if(vessel.hull_dirty && !vessel.formation_transfer)
			vessel.remap_hull()
	for(var/obj/overmap/entity/vessel as anything in flying)
		if(!vessel.formation_pad && !vessel.formation_transfer)
			vessel.process_scatter(elapsed)
	flight_index.rebuild(flying)
	process_collisions(flying)
	for(var/obj/overmap/entity/vessel as anything in flying)
		if(!vessel.formation_transfer)
			vessel.docking_approach?.process_approach(elapsed)
	flight_index.rebuild(flying)
	for(var/obj/overmap/entity/vessel as anything in flying)
		if(vessel.formation_pad || vessel.formation_transfer)
			continue
		vessel.update_neighbors(flight_index.nearby(vessel.sector, vessel.get_world_x(), vessel.get_world_y(), vessel.hull_radius + OVERMAP_CONTACT_RANGE))
		SSovermap_visuals.queue_update(vessel)
	for(var/datum/overmap_bubble/bubble as anything in bubbles)
		var/list/center = bubble.to_world(bubble.center_x, bubble.center_y)
		var/reach = max(bubble.bounds[3] - bubble.bounds[1], bubble.bounds[4] - bubble.bounds[2]) / 2 + 1
		bubble.process_bubble(flight_index.nearby(bubble.sector, center[1], center[2], reach))
		SSovermap_visuals.queue_update(bubble)
	for(var/obj/overmap/entity/vessel as anything in flying)
		vessel.remember_pose()

/datum/controller/subsystem/overmap/proc/expire_bubbles()

	if(spare_bubble_space && !length(flying_vessels))
		spare_bubble_space.Release()
		spare_bubble_space = null
	for(var/datum/overmap_bubble/bubble as anything in bubbles)
		if(!bubble.static_level && !length(bubble.ships) && !length(bubble.drifters) && world.time > bubble.last_occupied + OVERMAP_BUBBLE_TIMEOUT)
			qdel(bubble)
