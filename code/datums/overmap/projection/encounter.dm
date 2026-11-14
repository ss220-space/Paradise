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
	var/list/solid_chunks = list()
	var/solid_chunks_tick = -1
	var/solid_chunks_revision = -1
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
	SSovermap_visuals.remove(src)
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
	solid_chunks.Cut()
	navigation_density_cache = null
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
		if(QDELETED(vessel) || !vessel.free_flight_view || !length(vessel.hull_turfs))
			continue
		var/turf/hull_turf = blocking ? vessel.solid_hull_at(spot_world[1], spot_world[2]) : vessel.hull_turf_at(spot_world[1], spot_world[2])
		if(hull_turf)
			return list(vessel, hull_turf)

/datum/overmap_bubble/proc/process_bubble(list/flying)
	ships = list()
	for(var/obj/overmap/entity/vessel as anything in flying)
		if(QDELETED(vessel) || !vessel.free_flight_view || vessel.sector != sector || vessel.formation_pad)
			continue
		if(covers(to_bubble(vessel.get_world_x(), vessel.get_world_y()), vessel.hull_radius))
			ships[vessel] = TRUE
	if(length(ships))
		last_occupied = world.time
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

/datum/overmap_bubble/proc/update_flight_visuals(elapsed)
	var/list/eyes = SSovermap.visual_eyes
	var/list/drawn = list()
	for(var/obj/overmap/entity/vessel as anything in ships)
		if(QDELETED(vessel) || !vessel.free_flight_view || vessel.sector != sector || vessel.formation_pad)
			continue
		var/list/spot = to_bubble(vessel.get_world_x(), vessel.get_world_y())
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
	update_contact_proxies(eyes)
	update_scatter_proxies(eyes, elapsed)

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
	if(QDELETED(drifter) || drifter.anchored || !drifter.simulated || isobserver(drifter))
		return FALSE
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
