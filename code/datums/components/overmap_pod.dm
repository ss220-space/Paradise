/datum/component/overmap_pod
	dupe_mode = COMPONENT_DUPE_UNIQUE
	var/datum/turf_reservation/pocket
	var/area/spacepod/hyperspace/pocket_area
	var/undocking_until = 0
	var/landed_vis_flags

/datum/component/overmap_pod/Initialize()
	if(!istype(parent, /obj/overmap/entity/pod))
		return COMPONENT_INCOMPATIBLE

/datum/component/overmap_pod/RegisterWithParent()
	var/obj/overmap/entity/pod/token = parent
	token.overmap_pod = src

/datum/component/overmap_pod/UnregisterFromParent()
	var/obj/overmap/entity/pod/token = parent
	token.set_free_flight_view(FALSE)
	if(token.overmap_pod == src)
		token.overmap_pod = null
	release_pocket()

/datum/component/overmap_pod/proc/pod()
	RETURN_TYPE(/obj/spacepod)
	var/obj/overmap/entity/pod/token = parent
	return token.pod

/datum/component/overmap_pod/proc/is_in_own_pocket()
	var/obj/spacepod/craft = pod()
	return pocket && !QDELETED(pocket) && craft && (get_turf(craft) in pocket.reserved_turfs)

/datum/component/overmap_pod/proc/blocks_local_move()
	return is_in_own_pocket() || is_undocking()

/datum/component/overmap_pod/proc/is_undocking()
	return undocking_until != 0

/datum/component/overmap_pod/proc/is_landed()
	return !is_in_own_pocket() && !is_undocking()

/datum/component/overmap_pod/proc/release_pocket()
	if(pocket && !QDELETED(pocket))
		if(pocket_area && length(pocket.reserved_turfs))
			var/area/world_area = GLOB.areas_by_type[world.area]
			var/turf/first = pocket.reserved_turfs[1]
			LISTASSERTLEN(world_area.turfs_by_zlevel, first.z, list())
			LISTASSERTLEN(world_area.turfs_to_uncontain_by_zlevel, first.z, list())
			world_area.turfs_to_uncontain_by_zlevel[first.z] -= pocket.reserved_turfs
			world_area.contents += pocket.reserved_turfs
			world_area.turfs_by_zlevel[first.z] |= pocket.reserved_turfs
			pocket_area.turfs_by_zlevel[first.z] -= pocket.reserved_turfs
		pocket.Release()
		SSovermap.flight_reservations -= pocket
	pocket = null
	QDEL_NULL(pocket_area)

/datum/component/overmap_pod/proc/can_undock_here()
	var/obj/spacepod/craft = pod()
	return is_landed() && !QDELETED(craft) && craft.health > 0 && !!SSovermap.resolve_pod_host(craft)

/datum/component/overmap_pod/proc/begin_undock()
	if(!can_undock_here())
		return "Невозможно снять магнитное крепление."
	undocking_until = world.time + OVERMAP_POD_UNDOCK_DELAY
	pod().play_sound_to_riders('sound/effects/hyperspace_begin.ogg')
	addtimer(CALLBACK(src, PROC_REF(finish_undock)), OVERMAP_POD_UNDOCK_DELAY)
	return TRUE

/datum/component/overmap_pod/proc/finish_undock()
	if(!QDELETED(src))
		if(!enter_hyperspace())
			pod()?.message_to_riders(span_warning("Не удалось снять магнитное крепление."))
		undocking_until = 0

/datum/component/overmap_pod/proc/enter_hyperspace()
	var/obj/overmap/entity/pod/token = parent
	var/obj/spacepod/craft = pod()
	if(QDELETED(craft) || craft.health <= 0)
		return FALSE
	if(is_in_own_pocket())
		return TRUE
	var/turf/origin = get_turf(craft)
	var/obj/overmap/entity/host = SSovermap.resolve_pod_host(craft)
	if(!origin || !host || !host.sector)
		return FALSE
	var/list/point
	var/heading = dir2angle(craft.dir)
	if(host.free_flight_view)
		point = host.hull_to_world(origin.x + 0.5, origin.y + 0.5)
		heading += host.get_facing()
	else
		var/datum/overmap_bubble/space = SSovermap.bubble_for_turf(origin) || SSovermap.ensure_host_space(host)
		if(space && space.bubble_z == origin.z)
			point = space.to_world(origin.x + 0.5, origin.y + 0.5)
		else if(!host.project_terrain || host.dock_host?.planet_landing)
			point = list(host.get_world_x(), host.get_world_y())
		else
			return FALSE
	if(!ensure_pocket())
		return FALSE
	if(QDELETED(craft) || get_turf(craft) != origin || SSovermap.resolve_pod_host(craft) != host)
		release_pocket()
		return FALSE
	var/turf/center = pocket_center()
	if(!center)
		release_pocket()
		return FALSE
	craft.forceMove(center)
	craft.setDir(NORTH)
	landed_vis_flags = craft.vis_flags
	craft.anchored = TRUE
	craft.vis_flags = (craft.vis_flags & ~VIS_INHERIT_ID) | VIS_INHERIT_PLANE
	token.nest_inside(host)
	token.speed = host.speed.Copy()
	token.release_to_overmap(host.get_overmap_turf(), point, heading)
	token.status = OVERMAP_STATUS_OVERMAP
	token.halted = FALSE
	token.hidden_from_contacts = FALSE
	token.keep_inside_local_space()
	token.update_overmap_visibility()
	if(craft.pilot)
		token.flight.take_pilot(craft.pilot, craft.overmap_helm)
	craft.refresh_overmap_parallax()
	return TRUE

/datum/component/overmap_pod/proc/rescue_from_transit()
	INVOKE_ASYNC(src, PROC_REF(enter_hyperspace))

/datum/component/overmap_pod/proc/landing_target()
	var/obj/overmap/entity/pod/token = parent
	if(!token.in_free_flight())
		return null
	for(var/obj/overmap/entity/host as anything in SSovermap.flying_vessels)
		if(host == token || host.overmap_pod || host.sector != token.sector)
			continue
		var/list/spot = host.world_to_hull(token.get_world_x(), token.get_world_y())
		var/turf/dest = locate(round(spot[1]), round(spot[2]), host.hull_z)
		if(!host.hull_turfs[dest] || token.relative_speed(host) * (1 SECONDS) > 1)
			continue
		if(overmap_pod_2x2_landable(dest) && overmap_pod_supported_by(dest, host))
			return list(dest, host)
	var/datum/overmap_bubble/space = token.local_space
	var/obj/overmap/entity/host = token.get_dock_host()
	if(host && (!host.project_terrain || host.dock_host?.planet_landing) && OVERMAP_SPEED_STOPPED(token.get_speed()))
		for(var/obj/docking_port/stationary/overmap/landing/pad as anything in host_landing_pads(host))
			if(token.selected_dock_id && token.selected_dock_id != pad.id)
				continue
			var/turf/pad_turf = overmap_pick_pod_beacon_turf(pad)
			if(pad_turf)
				return list(pad_turf, host)
	if(!space?.static_level || !OVERMAP_SPEED_STOPPED(token.get_speed()))
		return null
	var/list/spot = space.to_bubble(token.get_world_x(), token.get_world_y())
	var/turf/dest = locate(round(spot[1]), round(spot[2]), space.bubble_z)
	if(!dest || !space.covers(list(dest.x, dest.y), -1) || !overmap_pod_2x2_landable(dest))
		return null
	return list(dest, space.host)

/datum/component/overmap_pod/proc/can_physical_dock()
	return !!landing_target()

/datum/component/overmap_pod/proc/can_edge_dock()
	return FALSE

/datum/component/overmap_pod/proc/build_dock_list()
	. = list()
	var/obj/overmap/entity/pod/token = parent
	var/obj/overmap/entity/host = token.get_dock_host()
	if(!host || (host.project_terrain && !host.dock_host?.planet_landing))
		return
	for(var/obj/docking_port/stationary/overmap/landing/pad as anything in host_landing_pads(host))
		. += list(list("id" = pad.id, "name" = pad.overmap_dock_label || pad.name, "can_dock" = !!overmap_pick_pod_beacon_turf(pad), "selected" = token.selected_dock_id == pad.id))

/datum/component/overmap_pod/proc/host_landing_pads(obj/overmap/entity/host)
	. = list()
	var/obj/overmap/entity/pod/token = parent
	for(var/obj/docking_port/stationary/overmap/landing/pad as anything in SSshuttle.stationary)
		if(!QDELETED(pad) && token.pad_matches_host(pad, host))
			. += pad

/datum/component/overmap_pod/proc/set_selected_pad(pad_id)
	var/obj/overmap/entity/pod/token = parent
	for(var/list/entry as anything in build_dock_list())
		if(entry["id"] == pad_id && entry["can_dock"])
			token.selected_dock_id = pad_id
			return TRUE
	return FALSE

/datum/component/overmap_pod/proc/begin_dock(force_edge = FALSE)
	var/list/target = landing_target()
	if(!target)
		return "Подведите аппарат к свободному полу или решётке и погасите относительную скорость."
	return land_at(target[1], target[2])

/datum/component/overmap_pod/proc/land_at(turf/dest, obj/overmap/entity/host)
	var/obj/overmap/entity/pod/token = parent
	var/obj/spacepod/craft = pod()
	if(!craft || !host || !overmap_pod_2x2_landable(dest))
		return FALSE
	var/heading = token.get_facing() - (host.free_flight_view ? host.get_facing() : 0)
	token.flight.release_pilot()
	token.flight.set_autopilot(FALSE)
	token.flight.angular_velocity = 0
	craft.forceMove(dest)
	craft.setDir(angle2dir_cardinal(heading))
	craft.vis_flags = landed_vis_flags
	craft.anchored = TRUE
	token.set_free_flight_view(FALSE)
	token.nest_inside(host)
	token.speed = list(0, 0)
	token.selected_dock_id = null
	release_pocket()
	craft.play_sound_to_riders('sound/effects/hyperspace_end.ogg')
	craft.refresh_overmap_parallax()
	return TRUE

/datum/component/overmap_pod/proc/inner_origin()
	if(!pocket || !length(pocket.bottom_left_turfs))
		return null
	var/turf/bottom = pocket.bottom_left_turfs[1]
	return locate(bottom.x + OVERMAP_POD_TRANSIT_BORDER, bottom.y + OVERMAP_POD_TRANSIT_BORDER, bottom.z)

/datum/component/overmap_pod/proc/ensure_pocket()
	if(pocket && !QDELETED(pocket))
		return TRUE
	var/size = OVERMAP_POD_HYPERSPACE_SIZE + OVERMAP_POD_TRANSIT_BORDER * 2
	pocket = SSmapping.request_turf_block_reservation(
		size,
		size,
		z_size = 1,
		reservation_type = /datum/turf_reservation/transit/overmap,
	)
	if(!istype(pocket))
		pocket = null
		return FALSE
	var/turf/bottom = pocket.bottom_left_turfs[1]
	if(!bottom)
		release_pocket()
		return FALSE
	pocket_area = new /area/spacepod/hyperspace
	LISTASSERTLEN(pocket_area.turfs_by_zlevel, bottom.z, list())
	var/turf/inner = inner_origin()
	if(!inner)
		release_pocket()
		return FALSE
	var/inner_max_x = inner.x + OVERMAP_POD_HYPERSPACE_SIZE - 1
	var/inner_max_y = inner.y + OVERMAP_POD_HYPERSPACE_SIZE - 1
	var/datum/turf_reservation/transit/overmap/hyperspace = pocket
	hyperspace.pod_inner_bounds = list(inner.x, inner.y, inner_max_x, inner_max_y)
	var/turf/top_right = pocket.top_right_turfs[1]
	if(!top_right)
		release_pocket()
		return FALSE
	for(var/turf/spot as anything in pocket.reserved_turfs)
		var/area/old_area = spot.loc
		LISTASSERTLEN(old_area.turfs_to_uncontain_by_zlevel, spot.z, list())
		old_area.turfs_to_uncontain_by_zlevel[spot.z] += spot
		pocket_area.contents += spot
		pocket_area.turfs_by_zlevel[spot.z] += spot
	return TRUE

/datum/component/overmap_pod/proc/pocket_center()
	var/turf/inner = inner_origin()
	if(!inner)
		return null
	return locate(inner.x + 1, inner.y + 1, inner.z)

/proc/overmap_pod_tile_landable(turf/spot)
	if(!spot || spot.density || overmap_lavaland_landing_blocked(spot))
		return FALSE
	if(!isfloorturf(spot) && !(locate(/obj/structure/lattice) in spot))
		return FALSE
	for(var/atom/movable/thing in spot)
		if(thing.density && !istype(thing, /obj/machinery/landing_beacon))
			return FALSE
	return TRUE

/proc/overmap_pick_pod_beacon_turf(obj/docking_port/stationary/pad)
	var/turf/origin = get_turf(pad)
	if(overmap_pod_2x2_landable(origin))
		return origin
	for(var/turf/spot in orange(2, origin))
		if(overmap_pod_2x2_landable(spot))
			return spot
	return null

/proc/overmap_pod_2x2_landable(turf/spot)
	return overmap_pod_tile_landable(spot) && overmap_pod_tile_landable(get_step(spot, EAST)) && overmap_pod_tile_landable(get_step(spot, NORTH)) && overmap_pod_tile_landable(get_step(spot, NORTHEAST))

/proc/overmap_pod_supported_by(turf/spot, obj/overmap/entity/host)
	for(var/direction in list(NONE, EAST, NORTH, NORTHEAST))
		if(!host.hull_turfs[get_step(spot, direction)])
			return FALSE
	return TRUE

/proc/overmap_pod_2x2_free(turf/spot)
	if(!spot)
		return FALSE
	for(var/direction in list(NONE, EAST, NORTH, NORTHEAST))
		var/turf/tile = get_step(spot, direction)
		if(!isspaceturf(tile) || is_hyperspace_turf(tile) || tile.is_blocked_turf())
			return FALSE
	return TRUE
