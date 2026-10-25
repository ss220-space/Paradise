/obj/overmap/entity/pod/in_free_flight()
	return overmap_pod?.is_in_own_pocket() && !is_jumping() && !relay_jump_from && status == OVERMAP_STATUS_OVERMAP && isturf(loc)

/datum/controller/subsystem/overmap
	var/list/obj/overmap/entity/pod/flying_pods = list()

/datum/controller/subsystem/overmap/proc/pod_blocker(turf/next, atom/movable/mover)
	if(!mover.simulated || isobserver(mover) || (mover.movement_type & PHASING))
		return null
	var/datum/owner = frame_owner(next)
	if(!owner)
		return null
	var/list/point = frame_to_world(owner, next)
	var/datum/overmap_sector/sector = frame_sector(owner)
	var/obj/projectile/projectile = mover
	for(var/obj/overmap/entity/pod/vessel as anything in flying_pods)
		if(QDELETED(vessel) || !vessel.in_free_flight() || vessel.sector != sector || mover == vessel.pod)
			continue
		if(istype(projectile) && (projectile.firer_source_atom == vessel.pod || (vessel.pod in projectile.permutated)))
			continue
		if(abs(point[1] - vessel.get_world_x()) > vessel.hull_radius || abs(point[2] - vessel.get_world_y()) > vessel.hull_radius)
			continue
		if(vessel.solid_hull_at(point[1], point[2]))
			return vessel.pod
	return null

/obj/overmap/entity/pod/is_physically_docked()
	return overmap_pod?.is_landed()

/obj/overmap/entity/pod/set_free_flight_view(enabled)
	radar_epoch++
	free_flight_view = enabled
	if(enabled)
		map_hull()
		remember_pose()
	else
		clear_encounter_visuals()

/obj/overmap/entity/pod/map_hull(keep_center = FALSE)
	var/turf/origin = get_turf(pod)
	if(!origin)
		return
	hull_dirty = FALSE
	hull_version++
	hull_center_x = origin.x + 0.5
	hull_center_y = origin.y + 0.5
	hull_z = origin.z
	hull_turfs = list()
	hull_area_turfs = list()
	hull_collars = list()
	for(var/turf/tile as anything in block(origin, locate(origin.x + 1, origin.y + 1, origin.z)))
		hull_turfs[tile] = TRUE
		hull_area_turfs[tile] = TRUE
	hull_edge = hull_turfs.Copy()
	hull_radius = sqrt(2)
	hull_inertia = 2 / 3
	radar_shape = list("tiles" = list(-1, -1, 1, -1, -1, 1, 1, 1), "collars" = list())
	flight_reservation = overmap_pod.pocket
	if(flight_reservation)
		SSovermap.flight_reservations[flight_reservation] = src
		flight_bounds = hyperspace_reservation_bounds(flight_reservation)

/obj/overmap/entity/pod/solid_hull_at(world_x, world_y)
	return hull_turf_at(world_x, world_y)

/obj/overmap/entity/pod/can_radar_land()
	return in_free_flight() && length(overmap_pod.build_dock_list()) > 0

/obj/overmap/entity/pod/prepare_stop()
	return overmap_pod?.begin_dock() == TRUE

/obj/overmap/entity/pod/prepare_docked_radar()
	if(!is_physically_docked())
		return FALSE
	var/obj/overmap/entity/host = SSovermap.resolve_pod_host(pod)
	local_space = host?.free_flight_view ? host.local_space : SSovermap.ensure_host_space(host)
	return TRUE

/obj/overmap/entity/pod/radar_world_origin()
	if(is_physically_docked())
		var/obj/overmap/entity/host = SSovermap.resolve_pod_host(pod)
		if(host?.free_flight_view)
			return host.hull_to_world(pod.x + 0.5, pod.y + 0.5)
		var/datum/overmap_bubble/space = local_space || host?.physical_space
		if(space && space.bubble_z == pod.z)
			return space.to_world(pod.x + 0.5, pod.y + 0.5)
	return ..()

/obj/overmap/entity/pod/feel_impact(impact_speed, kick, push_x, push_y)
	if(!pod || world.time < next_ram_effect || impact_speed < 1)
		return
	next_ram_effect = world.time + (1 SECONDS)
	pod.play_sound_to_riders('sound/effects/clang.ogg')

/obj/overmap/entity/proc/create_hull_proxy(turf/viewer_turf, glowing = FALSE)
	if(overmap_pod)
		return new /datum/hull_proxy/pod(src, viewer_turf)
	return new /datum/hull_proxy(src, viewer_turf, glowing)

/datum/hull_proxy/pod/New(obj/overmap/entity/pod/vessel, turf/viewer_turf)
	src.vessel = vessel
	src.viewer_turf = viewer_turf
	var/obj/effect/abstract/hull_proxy_tile/pod/tile = new(null)
	tile.craft = vessel.pod
	tile.frame_turf = viewer_turf
	SET_PLANE_EXPLICIT(tile, GAME_PLANE, viewer_turf)
	tile.vis_contents += vessel.pod
	tiles = list(tile)
	RegisterSignal(vessel, COMSIG_QDELETING, PROC_REF(on_vessel_deleted))

/datum/hull_proxy/pod/place(new_center_x, new_center_y, new_z, new_heading, list/bounds, time)
	var/obj/effect/abstract/hull_proxy_tile/pod/tile = tiles[1]
	var/matrix/turned = matrix()
	turned.Turn(new_heading)
	tile.glide(new_center_x - 0.5 * cos(new_heading) - 0.5 * sin(new_heading), new_center_y + 0.5 * sin(new_heading) - 0.5 * cos(new_heading), new_z, turned, bounds, time)

/obj/effect/abstract/hull_proxy_tile/pod
	var/obj/spacepod/craft

/obj/effect/abstract/hull_proxy_tile/pod/Click(location, control, params)
	if(!QDELETED(craft) && usr)
		if(isgun(usr.get_active_hand()))
			return usr.ClickOn(src, params, location)
		return usr.ClickOn(craft, params, location)

/obj/effect/abstract/hull_proxy_tile/pod/mouse_drop_receive(atom/dropped, mob/user, params)
	if(dropped == user && !QDELETED(craft))
		return craft.enter_pod(user)
	return ..()

/obj/effect/abstract/hull_proxy_tile/pod/bullet_act(obj/projectile/projectile, def_zone)
	return craft?.bullet_act(projectile, def_zone)

/obj/spacepod/proc/boarding_distance(mob/user)
	var/turf/spot = get_turf(user)
	var/turf/origin = get_turf(src)
	if(!spot || !origin)
		return INFINITY
	if(overmap_vessel?.free_flight_view)
		spot = SSovermap.mirror_turf(spot, origin) || spot
	if(spot.z != origin.z)
		return INFINITY
	return max(origin.x - spot.x, spot.x - origin.x - 1, origin.y - spot.y, spot.y - origin.y - 1, 0)

/obj/spacepod/proc/can_board_now(mob/user)
	return !QDELETED(src) && boarding_distance(user) <= 2 && (!equipment_system.lock_system || unlocked)

/obj/spacepod/proc/release_rider(mob/rider)
	var/obj/overmap/entity/pod/vessel = overmap_vessel
	if(vessel?.overmap_pod?.is_in_own_pocket())
		var/released = FALSE
		for(var/list/offset as anything in list(list(-1, 0), list(2, 0), list(0, -1), list(0, 2)))
			var/turf/exit = locate(x + offset[1], y + offset[2], z)
			if(vessel.eject_to_bubble(rider, exit))
				released = TRUE
				break
		if(!released && QDELETED(src))
			released = vessel.eject_to_bubble(rider, get_turf(src))
		if(!released)
			return FALSE
	else
		rider.forceMove(get_turf(src))
	if(vessel?.flight?.pilot == rider)
		vessel.flight.release_pilot()
	return TRUE

/obj/overmap/entity/pod/proc/flight_space(world_x = get_world_x(), world_y = get_world_y())
	var/datum/overmap_bubble/space = local_space
	if(space && space.covers(space.to_bubble(world_x, world_y), -2))
		return space
	space = SSovermap.find_bubble(sector, world_x, world_y)
	if(!space)
		space = SSovermap.create_bubble(sector, world_x, world_y, speed[1], speed[2])
	if(!space)
		SSovermap.prepare_bubble_space()
	return space

/obj/overmap/entity/pod/eject_to_bubble(atom/movable/thing, turf/exit_turf)
	var/obj/projectile/sector_shot = thing
	if(istype(sector_shot) && sector_shot.overmap_persistent)
		var/list/point = hull_to_world(exit_turf.x + (sector_shot.trajectory ? sector_shot.trajectory.return_px() / ICON_SIZE_X : 0), exit_turf.y + (sector_shot.trajectory ? sector_shot.trajectory.return_py() / ICON_SIZE_Y : 0))
		if(SSovermap.launch_sector_projectile(sector_shot, sector, point[1], point[2], sector_shot.Angle + get_facing(), src))
			return TRUE
	var/obj/projectile/projectile = thing
	var/list/foreign = foreign_hull_at(exit_turf)
	var/turf/foreign_turf = foreign?[2]
	if(foreign_turf && !foreign_turf.is_blocked_turf(exclude_mobs = TRUE))
		cross_frame_with_pull(thing, foreign_turf)
		if(istype(projectile))
			var/obj/overmap/entity/other = foreign[1]
			projectile.cross_frames(get_facing() - other.get_facing())
		return TRUE
	var/list/point = hull_to_world(exit_turf.x, exit_turf.y)
	var/datum/overmap_bubble/space = flight_space(point[1], point[2])
	var/turf/destination = space?.turf_at(point[1], point[2])
	if(!destination || destination.is_blocked_turf(exclude_mobs = TRUE))
		return FALSE
	cross_frame_with_pull(thing, destination)
	if(thing.loc != destination)
		return TRUE
	space.add_drifter(thing)
	if(istype(projectile))
		projectile.cross_frames(get_facing())
		return TRUE
	var/direction = angle2dir(delta_to_angle(speed[1] - space.speed_x, speed[2] - space.speed_y))
	thing.newtonian_move(direction || turn(WEST, -quarter_turns()))
	return TRUE

/obj/overmap/entity/pod/proc/fire_pod_projectile(obj/projectile/projectile, side, target_x, target_y)
	var/list/point = hull_to_world(hull_center_x + side * 0.5, hull_center_y + 1.5)
	var/heading = isnum(target_x) && isnum(target_y) ? delta_to_angle(target_x - point[1], target_y - point[2]) : get_facing()
	if(!projectile.hitscan)
		projectile.overmap_velocity = (1 SECONDS) / (projectile.speed * 3)
		return SSovermap.launch_sector_projectile(projectile, sector, point[1], point[2], heading, src)
	var/datum/overmap_bubble/space = flight_space(point[1], point[2])
	var/turf/muzzle = space?.turf_at(point[1], point[2])
	if(!muzzle)
		qdel(projectile)
		return FALSE
	projectile.forceMove(muzzle)
	projectile.starting = muzzle
	projectile.set_angle(heading)
	projectile.speed *= 3
	projectile.current = get_step(muzzle, angle2dir(heading))
	projectile.fire()
	if(!QDELETED(projectile) && muzzle.is_blocked_turf(exclude_mobs = TRUE))
		bump_into_hull(projectile, muzzle)
	return TRUE

/obj/spacepod/proc/nearest_hangar_door(reach = 3)
	var/list/point = SSovermap.spatial_position(src)
	var/list/anchors = list(get_turf(src))
	var/obj/overmap/entity/pod/vessel = overmap_vessel
	if(vessel?.in_free_flight())
		if(vessel.local_space)
			var/list/spot = vessel.local_space.to_bubble(vessel.get_world_x(), vessel.get_world_y())
			var/turf/anchor = locate(round(spot[1]), round(spot[2]), vessel.local_space.bubble_z)
			if(anchor)
				anchors |= anchor
		for(var/obj/overmap/entity/other as anything in vessel.nearby_ships)
			var/turf/anchor = SSovermap.world_to_frame(other, vessel.get_world_x(), vessel.get_world_y())
			if(anchor)
				anchors |= anchor
	var/list/seen = list()
	var/obj/machinery/door/poddoor/multi_tile/nearest
	var/nearest_distance = reach
	for(var/turf/anchor as anything in anchors)
		for(var/obj/machinery/door/poddoor/multi_tile/door in range(reach + 4, anchor))
			if(seen[door])
				continue
			seen[door] = TRUE
			for(var/turf/tile as anything in door.locs)
				var/list/door_point = point && SSovermap.spatial_position(tile)
				var/distance
				if(point && door_point && point[1] == door_point[1])
					distance = sqrt((point[2] - door_point[2]) ** 2 + (point[3] - door_point[3]) ** 2)
				else if(!vessel?.in_free_flight() && tile.z == z)
					distance = get_dist(tile, src)
				else
					continue
				if(distance <= nearest_distance)
					nearest_distance = distance
					nearest = door
	return nearest
