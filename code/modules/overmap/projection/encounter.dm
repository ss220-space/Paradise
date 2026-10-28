#define OVERMAP_NEIGHBOR_RANGE 12
#define OVERMAP_CONTACT_RANGE 64
#define OVERMAP_DRIFTER_RANGE 20
#define OVERMAP_BUBBLE_SIZE 96
#define OVERMAP_BUBBLE_MARGIN 16
#define OVERMAP_BUBBLE_TIMEOUT (1 MINUTES)
#define OVERMAP_EJECT_CLEARANCE 3
#define OVERMAP_SHIP_DOCK_RANGE 3
#define OVERMAP_SHIP_DOCK_ALIGN 20
#define OVERMAP_SHIP_DOCK_SPEED (2 / (1 SECONDS))
#define OVERMAP_SHIP_UNDOCK_PUSH (1 / (1 SECONDS))
#define OVERMAP_SHIP_DOCK_SHAKE_TIME 3
#define OVERMAP_SHIP_DOCK_SHAKE_STRENGTH 1
#define OVERMAP_SHOVE_CLEARANCE 4
#define OVERMAP_SHOVE_HURT_SPEED 4
#define OVERMAP_SHOVE_MAX_DAMAGE 25
#define OVERMAP_RADAR_DOCK_RANGE 64

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
	var/list/spot = world_to_hull(world_x, world_y, origin_x, origin_y, facing)
	var/turf/hull_turf = locate(FLOOR(spot[1] + 0.5, 1), FLOOR(spot[2] + 0.5, 1), hull_z)
	return hull_turfs[hull_turf] ? hull_turf : null

/obj/overmap/entity/proc/quarter_turns()
	return round(get_facing() / 90, 1) * 90

/obj/overmap/entity/proc/show_neighbors(list/flying, elapsed, watched)
	var/list/seen = list()
	var/list/nearby = list()
	for(var/obj/overmap/entity/other as anything in flying)
		if(other == src || other.sector != sector || other.formation_pad || (formation_pad && other == docked_ship))
			continue
		var/list/spot = world_to_hull(other.get_world_x(), other.get_world_y())
		var/distance = sqrt((spot[1] - hull_center_x) ** 2 + (spot[2] - hull_center_y) ** 2) - hull_radius - other.hull_radius
		if(distance > OVERMAP_CONTACT_RANGE)
			continue
		nearby[other] = TRUE
		if(!watched || distance > OVERMAP_NEIGHBOR_RANGE)
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
	nearby_ships = nearby

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
		if(engine.omnidirectional || engine.z != hull_z)
			continue
		var/list/directions = engine.push_directions()
		for(var/key in directions)
			var/push = text2num(key)
			. += list(list(engine.thrust_origin_x() - hull_center_x, engine.thrust_origin_y() - hull_center_y, REVERSE_DIR(push), engine.firing && (engine.active_pushes & push)))

/obj/overmap/entity/proc/radar_shapes()
	. = list()
	if(radar_shape)
		radar_shape["revision"] = hull_version
	.[UID()] = radar_shape
	for(var/obj/overmap/entity/other as anything in nearby_ships)
		if(other.radar_shape)
			other.radar_shape["revision"] = other.hull_version
		.[other.UID()] = other.radar_shape

/obj/overmap/entity/proc/push_radar()
	if(radar_transitioning)
		return
	if(!length(radar_uis) || !sector)
		return
	var/list/scatter = radar_scatter_data()
	var/list/data = list("radar_tick" = SSovermap.radar_frame_time * 100, "radar_epoch" = radar_epoch, "radar_locked" = !!relay_jump_from, "self_pos" = radar_sector_position(), "radar_docks" = radar_dock_targets(), "dock_ready" = docking_approach?.ready(), "dock_in_range" = docking_approach?.in_alignment_range(), "dock_aligning" = docking_approach?.aligning, "radar" = radar_contacts(), "radar_drifters" = radar_drifters(), "radar_engines" = radar_engines(), "facing" = free_flight_view ? get_facing() : 0, "radar_world" = radar_world_origin())
	if(scatter != pushed_scatter)
		data["radar_scatter"] = scatter
		pushed_scatter = scatter
	var/list/objects = radar_object_positions()
	if(objects)
		data["objects"] = objects
	data["radar_projectiles"] = radar_projectiles()
	radar_motion_frame = data
	radar_motion_epoch = radar_epoch
	radar_motion_sector = sector
	for(var/datum/tgui/ui as anything in radar_uis)
		if(QDELETED(ui) || ui.status < UI_UPDATE)
			continue
		ui.send_update(data)

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

/datum/overmap_bubble

	var/obj/overmap/entity/host
	var/datum/turf_reservation/reservation
	var/datum/overmap_sector/sector
	var/origin_x
	var/origin_y
	var/speed_x
	var/speed_y
	var/start_time
	var/center_x
	var/center_y
	var/bubble_z
	var/list/bounds
	var/area/space/overmap_bubble/bubble_area
	var/list/datum/hull_proxy/ship_proxies = list()
	var/list/obj/overmap/entity/ships = list()
	var/list/obj/effect/abstract/overmap_contact_proxy/contact_proxies = list()
	var/list/terrain_chunks = list()
	var/list/atom/movable/drifters = list()
	var/last_occupied
	var/static_level = FALSE
	var/list/radar_chunks = list()

	var/list/region
	var/list/region_z
	var/list/scatter_proxies = list()
	var/datum/fog_scene/scatter/scatter_fog
	var/list/navigation_density_cache
	var/navigation_density_until = 0
	var/navigation_density_busy = FALSE
	var/list/navigation_extent
	var/navigation_extent_until = 0

/datum/overmap_bubble/New(datum/overmap_sector/sector, origin_x, origin_y, speed_x, speed_y)
	src.sector = sector
	src.origin_x = origin_x
	src.origin_y = origin_y
	src.speed_x = speed_x
	src.speed_y = speed_y
	start_time = world.time
	last_occupied = world.time
	SSovermap.bubbles += src

/datum/overmap_bubble/proc/fill_reservation(datum/turf_reservation/reservation)
	src.reservation = reservation
	var/turf/bottom_left = reservation.bottom_left_turfs[1]
	var/turf/top_right = reservation.top_right_turfs[1]
	bounds = list(bottom_left.x, bottom_left.y, top_right.x, top_right.y)
	center_x = (bottom_left.x + top_right.x) / 2
	center_y = (bottom_left.y + top_right.y) / 2
	bubble_z = bottom_left.z
	for(var/turf/spot as anything in reservation.reserved_turfs)
		var/area/old_area = spot.loc
		LISTASSERTLEN(old_area.turfs_to_uncontain_by_zlevel, bubble_z, list())
		old_area.turfs_to_uncontain_by_zlevel[bubble_z] += spot
	bubble_area = new
	bubble_area.contents = reservation.reserved_turfs
	LISTASSERTLEN(bubble_area.turfs_by_zlevel, bubble_z, list())
	bubble_area.turfs_by_zlevel[bubble_z] = reservation.reserved_turfs.Copy()
	SSovermap.bubbles_by_reservation[reservation] = src

/datum/overmap_bubble/proc/fill_level(level)
	static_level = TRUE
	bubble_z = level
	bounds = list(1 + TRANSITIONEDGE, 1 + TRANSITIONEDGE, world.maxx - TRANSITIONEDGE, world.maxy - TRANSITIONEDGE)
	center_x = round(world.maxx / 2)
	center_y = round(world.maxy / 2)
	if(length(SSovermap.bubbles_by_z) < level)
		SSovermap.bubbles_by_z.len = level
	SSovermap.bubbles_by_z[level] = src

/datum/overmap_bubble/Destroy(force)
	SSovermap.bubbles -= src
	SSovermap.bubbles_by_reservation -= reservation
	if(static_level && bubble_z <= length(SSovermap.bubbles_by_z) && SSovermap.bubbles_by_z[bubble_z] == src)
		SSovermap.bubbles_by_z[bubble_z] = null
	QDEL_LIST_ASSOC_VAL(ship_proxies)
	ships.Cut()
	QDEL_LIST_ASSOC_VAL(contact_proxies)
	QDEL_LIST_ASSOC_VAL(scatter_proxies)
	QDEL_NULL(scatter_fog)
	terrain_chunks.Cut()
	for(var/atom/movable/drifter as anything in drifters)
		remove_drifter(drifter)
	reservation?.Release()
	reservation = null
	bubble_area = null
	if(host?.physical_space == src)
		host.physical_space = null
	host = null
	sector = null
	return ..()

/datum/overmap_bubble/proc/drift_x()
	return speed_x * OVERMAP_TILE_SPAN * (world.time - start_time)

/datum/overmap_bubble/proc/drift_y()
	return speed_y * OVERMAP_TILE_SPAN * (world.time - start_time)

/datum/overmap_bubble/proc/ensure_region()
	if(region || !static_level || isnull(bounds))
		return region
	region_z = list(bounds[1], bounds[2])
	region = list(origin_x - center_x + bounds[1], origin_y - center_y + bounds[2], origin_x - center_x + bounds[3], origin_y - center_y + bounds[4])
	return region

/datum/overmap_bubble/proc/to_bubble(world_x, world_y)
	var/list/area = ensure_region()
	if(area)
		return list(world_x - area[1] + region_z[1], world_y - area[2] + region_z[2])
	return list(center_x + world_x - origin_x - drift_x(), center_y + world_y - origin_y - drift_y())

/datum/overmap_bubble/proc/to_world(bubble_x, bubble_y)
	return list(bubble_x - center_x + origin_x + drift_x(), bubble_y - center_y + origin_y + drift_y())

/datum/overmap_bubble/proc/covers(list/spot, margin)
	return spot[1] >= bounds[1] - margin && spot[1] <= bounds[3] + margin && spot[2] >= bounds[2] - margin && spot[2] <= bounds[4] + margin

/datum/overmap_bubble/proc/turf_at(world_x, world_y)
	var/list/spot = to_bubble(world_x, world_y)
	if(!covers(spot, 0))
		return null
	return locate(CEILING(spot[1] - 0.5, 1), CEILING(spot[2] - 0.5, 1), bubble_z)

/datum/overmap_bubble/proc/hull_under(turf/spot, blocking = FALSE)
	var/list/spot_world = to_world(spot.x, spot.y)
	for(var/obj/overmap/entity/vessel as anything in ships)
		var/turf/hull_turf = blocking ? vessel.solid_hull_at(spot_world[1], spot_world[2]) : vessel.hull_turf_at(spot_world[1], spot_world[2])
		if(hull_turf)
			return list(vessel, hull_turf)

/datum/overmap_bubble/proc/process_bubble(list/flying, elapsed, list/eyes)
	var/list/seen = list()
	var/list/drawn = list()
	for(var/obj/overmap/entity/vessel as anything in flying)
		if(vessel.sector != sector || vessel.formation_pad)
			continue
		var/list/spot = to_bubble(vessel.get_world_x(), vessel.get_world_y())
		if(!covers(spot, vessel.hull_radius))
			continue
		seen[vessel] = TRUE
		if(!watched_near(spot, vessel.hull_radius + OVERMAP_NEIGHBOR_RANGE, eyes))
			continue
		drawn[vessel] = TRUE
		var/datum/hull_proxy/proxy = ship_proxies[vessel]
		if(QDELETED(proxy))
			proxy = vessel.create_hull_proxy(locate(round(center_x), round(center_y), bubble_z), TRUE)
			ship_proxies[vessel] = proxy
		proxy.place(spot[1], spot[2], bubble_z, vessel.get_facing(), bounds, elapsed)
	for(var/obj/overmap/entity/vessel as anything in ship_proxies)
		if(!drawn[vessel])
			qdel(ship_proxies[vessel])
			ship_proxies -= vessel
	ships = seen
	if(length(ships))
		last_occupied = world.time
	update_contact_proxies(eyes)
	update_scatter_proxies(eyes, elapsed)
	if(static_level && !length(ships))
		for(var/atom/movable/drifter as anything in drifters)
			remove_drifter(drifter)
		return
	for(var/obj/overmap/entity/vessel as anything in ships)
		sweep_hull(vessel)
	for(var/atom/movable/drifter as anything in drifters)
		try_board(drifter)
	if(length(drifters))
		last_occupied = world.time

/datum/overmap_bubble/proc/update_contact_proxies(list/eyes)
	var/list/wanted = list()
	var/span = OVERMAP_TILE_SPAN * (sector?.tile_travel || 1)
	for(var/obj/overmap/target as anything in sector?.objects)
		if(QDELETED(target) || !isturf(target.loc) || istype(target, /obj/overmap/entity/shuttle) || istype(target, /obj/overmap/entity/pod) || istype(target, /obj/overmap/feature/hazard))
			continue
		var/world_x = (target.x + target.position[1]) * span
		var/world_y = (target.y + target.position[2]) * span
		var/list/spot = to_bubble(world_x, world_y)
		if(!watched_near(spot, world.view + 1, eyes))
			continue
		var/obj/effect/abstract/overmap_contact_proxy/proxy = contact_proxies[target]
		if(!proxy)
			proxy = new(target, src)
			contact_proxies[target] = proxy
		wanted[target] = TRUE
		proxy.place(spot[1], spot[2], bubble_z)
		var/obj/overmap/planet/planet = target
		if(istype(planet))
			for(var/obj/effect/overmap_planet_cell/cell as anything in planet.cells)
				if(QDELETED(cell) || !isturf(cell.loc))
					continue
				var/list/cell_spot = to_bubble(cell.x * span, cell.y * span)
				var/obj/effect/abstract/overmap_contact_proxy/cell_proxy = contact_proxies[cell]
				if(!cell_proxy)
					cell_proxy = new(cell, src)
					contact_proxies[cell] = cell_proxy
				cell_proxy.place(cell_spot[1], cell_spot[2], bubble_z)
				wanted[cell] = TRUE
	for(var/atom/source as anything in contact_proxies)
		if(!wanted[source] || QDELETED(source))
			qdel(contact_proxies[source])
			contact_proxies -= source

/datum/overmap_bubble/proc/watched_near(list/spot, reach, list/eyes)
	for(var/turf/eye as anything in eyes)
		if(eye.z == bubble_z && abs(eye.x - spot[1]) <= reach && abs(eye.y - spot[2]) <= reach)
			return TRUE
	return FALSE

/datum/overmap_bubble/proc/add_drifter(atom/movable/drifter)
	if(drifters[drifter])
		return
	drifters[drifter] = TRUE
	RegisterSignal(drifter, COMSIG_MOVABLE_SPACEMOVE, PROC_REF(on_drifter_spacemove))

/datum/overmap_bubble/proc/remove_drifter(atom/movable/drifter)
	drifters -= drifter
	UnregisterSignal(drifter, COMSIG_MOVABLE_SPACEMOVE)

/datum/overmap_bubble/proc/on_drifter_spacemove(atom/movable/drifter, movement_dir, continuous_move)
	SIGNAL_HANDLER
	for(var/turf/space/near in orange(1, drifter.loc))
		var/list/hull = hull_under(near)
		var/turf/hull_turf = hull?[2]
		if(hull_turf?.is_blocked_turf(exclude_mobs = TRUE))
			return COMSIG_MOVABLE_STOP_SPACEMOVE

/datum/overmap_bubble/proc/try_board(atom/movable/drifter)
	var/turf/spot = drifter.loc
	if(!isturf(spot))
		return FALSE
	var/list/hull = hull_under(spot)
	if(!hull)
		return FALSE
	var/obj/overmap/entity/vessel = hull[1]
	var/turf/hull_turf = hull[2]
	if(vessel.overmap_pod)
		return FALSE
	if(hull_turf.is_blocked_turf(exclude_mobs = TRUE))
		return FALSE
	var/board_dir = turn(drifter.dir || SOUTH, vessel.quarter_turns())
	cross_frame_with_pull(drifter, hull_turf)
	var/obj/projectile/bullet = drifter
	if(istype(bullet))
		bullet.cross_frames(-vessel.get_facing())
	else
		drifter.setDir(board_dir)
	return TRUE

/datum/overmap_bubble/proc/sweep_hull(obj/overmap/entity/vessel)
	var/steps = max(1, CEILING(vessel.pose_travel() / 0.35, 1))
	var/list/struck = list()
	for(var/step in 0 to steps)
		var/list/pose = vessel.pose_at(step / steps)
		for(var/turf/hull_turf as anything in vessel.hull_edge)
			if(!hull_turf.is_blocked_turf(exclude_mobs = TRUE))
				continue
			var/list/spot_world = vessel.hull_to_world(hull_turf.x, hull_turf.y, pose[1], pose[2], pose[3])
			var/turf/spot = turf_at(spot_world[1], spot_world[2])
			if(!spot)
				continue
			for(var/atom/movable/thing in spot)
				if(thing.anchored || !thing.simulated || isobserver(thing) || struck[thing])
					continue
				struck[thing] = TRUE
				shove_drifter(thing, vessel)

/datum/overmap_bubble/proc/shove_drifter(atom/movable/drifter, obj/overmap/entity/vessel)
	var/velocity_x = (vessel.speed[1] - speed_x) * OVERMAP_TILE_SPAN
	var/velocity_y = (vessel.speed[2] - speed_y) * OVERMAP_TILE_SPAN
	var/impact = sqrt(velocity_x ** 2 + velocity_y ** 2) * (1 SECONDS)
	var/push_dir
	if(impact >= 1)
		push_dir = angle2dir_cardinal(delta_to_angle(velocity_x, velocity_y))
	else
		var/list/drifter_world = to_world(drifter.x, drifter.y)
		push_dir = angle2dir_cardinal(delta_to_angle(drifter_world[1] - vessel.get_world_x(), drifter_world[2] - vessel.get_world_y()))
	var/turf/landing = drifter.loc
	for(var/step in 1 to OVERMAP_SHOVE_CLEARANCE)
		landing = get_step(landing, push_dir)
		if(!landing || !covers(list(landing.x, landing.y), 0))
			return
		var/list/hull = hull_under(landing)
		var/turf/hull_turf = hull?[2]
		if(!hull_turf?.is_blocked_turf(exclude_mobs = TRUE))
			break
	drifter.forceMove(landing)
	drifter.newtonian_move(push_dir)
	if(!isliving(drifter) || impact < OVERMAP_SHOVE_HURT_SPEED)
		return
	var/mob/living/victim = drifter
	playsound(landing, 'sound/effects/bang.ogg', 50, TRUE)
	victim.Knockdown(2 SECONDS)
	victim.apply_damage(min(impact * 2, OVERMAP_SHOVE_MAX_DAMAGE), BRUTE)
	to_chat(victim, span_userdanger("Вас сбивает корпус корабля!"))

/proc/cross_frame_with_pull(atom/movable/mover, turf/destination)
	var/atom/movable/pulled = mover.pulling
	var/grip = mover.grab_state
	var/pull_force = mover.pull_force
	mover.forceMove(destination)
	if(QDELETED(pulled) || pulled.anchored || pulled.loc == destination)
		return
	pulled.forceMove(destination)
	INVOKE_ASYNC(mover, TYPE_PROC_REF(/atom/movable, start_pulling), pulled, grip, pull_force, TRUE)

/datum/controller/subsystem/overmap/proc/frame_owner(turf/spot)
	return flight_reservations[SSmapping.used_turfs[spot]] || bubble_for_turf(spot)

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

/datum/controller/subsystem/overmap/proc/mirror_explosion(datum/source, turf/epicenter, devastation_range, heavy_impact_range, light_impact_range, flash_range, flame_range)
	SIGNAL_HANDLER
	if(mirroring_explosion || !length(flying_vessels) || !epicenter)
		return
	var/datum/origin = frame_owner(epicenter)
	if(!origin)
		return
	var/datum/overmap_sector/sector = frame_sector(origin)
	var/list/point = frame_to_world(origin, epicenter)
	var/reach = max(devastation_range, heavy_impact_range, light_impact_range, flame_range)
	var/list/datum/targets = list()
	for(var/obj/overmap/entity/vessel as anything in flying_vessels)
		if(vessel == origin || vessel.sector != sector)
			continue
		if(sqrt((vessel.get_world_x() - point[1]) ** 2 + (vessel.get_world_y() - point[2]) ** 2) <= vessel.hull_radius + reach)
			targets += vessel
	for(var/datum/overmap_bubble/bubble as anything in bubbles)
		if(bubble != origin && bubble.sector == sector && bubble.covers(bubble.to_bubble(point[1], point[2]), reach))
			targets += bubble
	mirroring_explosion = TRUE
	for(var/datum/target as anything in targets)
		var/turf/mirrored = world_to_frame(target, point[1], point[2])
		if(mirrored)
			explosion(mirrored, devastation_range, heavy_impact_range, light_impact_range, flash_range, adminlog = FALSE, flame_range = flame_range, smoke = FALSE, cause = "overmap explosion across hull")
	mirroring_explosion = FALSE

/proc/bump_into_hull(atom/movable/mover, turf/hull_turf)
	var/atom/blocker = hull_turf
	for(var/atom/movable/obstacle in hull_turf)
		if(obstacle.density)
			blocker = obstacle
			break
	mover.Bump(blocker)

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

/datum/controller/subsystem/overmap/proc/process_encounters(list/flying, elapsed, list/watched, list/eyes)
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
	process_collisions(flying)
	for(var/obj/overmap/entity/vessel as anything in flying)
		if(!vessel.formation_transfer)
			vessel.docking_approach?.process_approach(elapsed)
	for(var/obj/overmap/entity/vessel as anything in flying)
		if(vessel.formation_pad || vessel.formation_transfer)
			continue
		var/is_watched = watched[vessel]
		vessel.draw_scatter(vessel.scatter_candidates, elapsed, is_watched)
		vessel.show_neighbors(flying, elapsed, is_watched)
		if(is_watched)
			vessel.show_drifters(bubbles, elapsed)
			vessel.update_terrain_view(elapsed)
		else
			QDEL_LIST_ASSOC_VAL(vessel.drifter_mirrors)
			QDEL_NULL(vessel.terrain_view)
	for(var/datum/overmap_bubble/bubble as anything in bubbles)
		bubble.process_bubble(flying, elapsed, eyes)
	for(var/obj/overmap/entity/vessel as anything in flying)
		vessel.remember_pose()

/datum/controller/subsystem/overmap/proc/expire_bubbles()

	if(spare_bubble_space && !length(flying_vessels))
		spare_bubble_space.Release()
		spare_bubble_space = null
	for(var/datum/overmap_bubble/bubble as anything in bubbles)
		if(!bubble.static_level && !length(bubble.ships) && !length(bubble.drifters) && world.time > bubble.last_occupied + OVERMAP_BUBBLE_TIMEOUT)
			qdel(bubble)

#undef OVERMAP_NEIGHBOR_RANGE
#undef OVERMAP_CONTACT_RANGE
#undef OVERMAP_DRIFTER_RANGE
#undef OVERMAP_BUBBLE_SIZE
#undef OVERMAP_BUBBLE_MARGIN
#undef OVERMAP_BUBBLE_TIMEOUT
#undef OVERMAP_EJECT_CLEARANCE
#undef OVERMAP_SHIP_DOCK_RANGE
#undef OVERMAP_SHIP_DOCK_ALIGN
#undef OVERMAP_SHIP_DOCK_SPEED
#undef OVERMAP_SHIP_UNDOCK_PUSH
#undef OVERMAP_SHIP_DOCK_SHAKE_TIME
#undef OVERMAP_SHIP_DOCK_SHAKE_STRENGTH
#undef OVERMAP_SHOVE_CLEARANCE
#undef OVERMAP_SHOVE_HURT_SPEED
#undef OVERMAP_SHOVE_MAX_DAMAGE
#undef OVERMAP_RADAR_DOCK_RANGE
