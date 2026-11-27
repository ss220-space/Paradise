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
	RegisterSignal(parent, COMSIG_OVERMAP_POD_STATE, PROC_REF(on_pod_state))
	RegisterSignal(parent, COMSIG_OVERMAP_POD_RESCUE, PROC_REF(on_rescue))
	RegisterSignal(parent, COMSIG_OVERMAP_POD_LAND, PROC_REF(on_land))

/datum/component/overmap_pod/UnregisterFromParent()
	UnregisterSignal(parent, list(COMSIG_OVERMAP_POD_STATE, COMSIG_OVERMAP_POD_RESCUE, COMSIG_OVERMAP_POD_LAND))
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

/datum/component/overmap_pod/proc/on_pod_state(datum/source, requested, list/flying_areas)
	SIGNAL_HANDLER
	. = COMPONENT_OVERMAP_POD_LINKED
	if((requested & COMPONENT_OVERMAP_POD_IN_POCKET) && is_in_own_pocket())
		. |= COMPONENT_OVERMAP_POD_IN_POCKET
		if(flying_areas)
			flying_areas[pocket_area] = parent
	if((requested & COMPONENT_OVERMAP_POD_UNDOCKING) && is_undocking())
		. |= COMPONENT_OVERMAP_POD_UNDOCKING

/datum/component/overmap_pod/proc/is_undocking()
	return undocking_until != 0

/datum/component/overmap_pod/proc/is_landed()
	return !is_in_own_pocket() && !is_undocking()

/datum/component/overmap_pod/proc/release_pocket()
	overmap_release_area(pocket_area)
	pocket_area = null
	if(pocket)
		SSovermap.flight_reservations -= pocket
		QDEL_NULL(pocket)

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
	var/datum/overmap_bubble/planet_surface/surface
	var/obj/overmap/entity/planet = host.dock_host?.planet_landing ? host : host.docked_to
	var/list/ground
	var/heading = dir2angle(craft.dir)
	if(host.free_flight_view)
		point = host.hull_to_world(origin.x + 0.5, origin.y + 0.5)
		heading += host.get_facing()
		if(host.atmosphere)
			surface = host.atmosphere.surface
			ground = host.atmosphere.hull_to_surface(origin.x + 0.5, origin.y + 0.5)
	else if(planet?.dock_host?.planet_landing)
		surface = planet.dock_host.planet_surface(origin.z)
		if(!surface)
			return FALSE
		ground = list(origin.x + 0.5, origin.y + 0.5)
	else if(istype(host, /obj/overmap/entity/service_site))
		point = list(host.get_world_x(), host.get_world_y())
	else
		var/datum/overmap_bubble/space = SSovermap.bubble_for_turf(origin) || SSovermap.ensure_host_space(host)
		if(space && space.bubble_z == origin.z)
			point = space.to_world(origin.x + 0.5, origin.y + 0.5)
		else if(!host.project_terrain)
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
	if(surface)
		point = list(surface.host.get_world_x(), surface.host.get_world_y())
	token.release_to_overmap(host.get_overmap_turf(), point, heading)
	if(surface)
		token.enter_atmosphere(surface.host, surface.bubble_z, ground[1], ground[2], TRUE)
	token.status = OVERMAP_STATUS_OVERMAP
	token.halted = FALSE
	token.hidden_from_contacts = FALSE
	token.keep_inside_local_space()
	token.update_overmap_visibility()
	if(craft.pilot)
		token.flight.take_pilot(craft.pilot, craft.overmap_helm)
	craft.refresh_overmap_parallax()
	return TRUE

/datum/component/overmap_pod/proc/on_rescue()
	SIGNAL_HANDLER
	INVOKE_ASYNC(src, PROC_REF(enter_hyperspace))
	return COMPONENT_OVERMAP_POD_RESCUING

/datum/component/overmap_pod/proc/landing_target()
	var/obj/overmap/entity/pod/token = parent
	if(!token.in_free_flight())
		return null
	if(token.atmosphere)
		if(!token.atmosphere.cruising() || !OVERMAP_SPEED_STOPPED(token.get_speed()))
			return null
		var/list/center = token.local_space.to_bubble(token.get_world_x(), token.get_world_y())
		var/turf/ground = locate(FLOOR(center[1], 1), FLOOR(center[2], 1), token.local_space.bubble_z)
		if(overmap_pod_exposed(ground) && overmap_pod_2x2_landable(ground))
			return list(ground, token.local_space.host)
		return null
	if(token.can_approach_planet())
		return null
	for(var/obj/overmap/entity/host as anything in SSovermap.flying_vessels)
		if(host == token || host.atmosphere || host.overmap_pod || host.sector != token.sector)
			continue
		var/list/spot = host.world_to_hull(token.get_world_x(), token.get_world_y())
		var/turf/dest = locate(round(spot[1]), round(spot[2]), host.hull_z)
		if(!dest || !host.hull_turfs?[dest] || token.relative_speed(host) * (1 SECONDS) > 1)
			continue
		if(overmap_pod_2x2_landable(dest) && overmap_pod_supported_by(dest, host))
			return list(dest, host)
	var/datum/overmap_bubble/space = token.local_space
	var/obj/overmap/entity/host = token.get_dock_host()
	if(istype(host, /obj/overmap/entity/service_site))
		return null
	if(host && (!host.project_terrain || host.dock_host?.planet_landing) && OVERMAP_SPEED_STOPPED(token.get_speed()))
		for(var/obj/docking_port/stationary/pad as anything in host_landing_pads(host))
			if(token.selected_dock_id && token.selected_dock_id != pad.id)
				continue
			var/turf/pad_turf = overmap_pick_pod_beacon_turf(pad)
			if(pad_turf)
				return list(pad_turf, host, pad)
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
	for(var/obj/docking_port/stationary/pad as anything in host_landing_pads(host))
		. += list(list("id" = pad.id, "name" = pad.overmap_dock_label || pad.name, "can_dock" = !!overmap_pick_pod_beacon_turf(pad), "selected" = token.selected_dock_id == pad.id))

/datum/component/overmap_pod/proc/host_landing_pads(obj/overmap/entity/host)
	. = list()
	var/obj/overmap/entity/pod/token = parent
	for(var/obj/docking_port/stationary/pad as anything in SSshuttle.stationary)
		if(QDELETED(pad) || pad.hidden || (!istype(pad, /obj/docking_port/stationary/overmap/landing) && !(locate(/obj/machinery/landing_beacon) in pad.loc)))
			continue
		if(token.pad_matches_host(pad, host))
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
	var/obj/overmap/entity/pod/token = parent
	if(token.atmosphere)
		return prepare_approach(target[1])
	return land_at(target[1], target[2], length(target) >= 3 ? target[3] : null)

/datum/component/overmap_pod/proc/prepare_approach(turf/ground, obj/docking_port/stationary/pad, list/point)
	var/obj/overmap/entity/pod/token = parent
	if(!ground || !token.in_free_flight() || token.docking_approach?.aligning || (token.atmosphere && !token.atmosphere.cruising()))
		return FALSE
	var/datum/overmap_docking_approach/approach = new(token, FALSE)
	approach.space = token.atmosphere?.surface
	if(approach.space)
		point = approach.space.to_world(ground.x + 0.5, ground.y + 0.5)
	approach.pod_landing = ground
	approach.pad = pad
	approach.target_x = point[1]
	approach.target_y = point[2]
	approach.target_facing = SIMPLIFY_DEGREES(round(token.get_facing() / 90) * 90)
	if(!approach.available())
		qdel(approach)
		return FALSE
	QDEL_NULL(token.docking_approach)
	token.docking_approach = approach
	token.radar_docks_until = 0
	return TRUE

/datum/component/overmap_pod/proc/on_land(datum/source, turf/dest, obj/overmap/entity/host, obj/docking_port/stationary/pad)
	SIGNAL_HANDLER
	return land_at(dest, host, pad) ? COMPONENT_OVERMAP_POD_LANDED : NONE

/datum/component/overmap_pod/proc/land_at(turf/dest, obj/overmap/entity/host, obj/docking_port/stationary/pad)
	var/obj/overmap/entity/pod/token = parent
	var/obj/spacepod/craft = pod()
	if(!craft || !host || !overmap_pod_pad_fits(pad, dest))
		return FALSE
	var/heading = token.get_facing() - (host.free_flight_view ? host.get_facing() : 0)
	token.flight.release_pilot()
	token.flight.set_autopilot(FALSE)
	token.flight.angular_velocity = 0
	craft.forceMove(dest)
	craft.setDir(angle2dir_cardinal(heading))
	craft.vis_flags = landed_vis_flags
	craft.anchored = TRUE
	var/obj/docking_port/stationary/overmap/landing/landing = pad
	if(istype(landing) && landing.beacon_corners)
		landing.dock_pod(craft)
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

/proc/overmap_pick_pod_beacon_turf(obj/docking_port/stationary/pad, obj/overmap/entity/service_site/site)
	var/turf/origin = get_turf(pad)
	if(overmap_pod_pad_fits(pad, origin) && (!site || SSovermap.get_service_site(origin) == site))
		return origin
	for(var/turf/spot in orange(2, origin))
		if(overmap_pod_pad_fits(pad, spot) && (!site || SSovermap.get_service_site(spot) == site))
			return spot
	return null

/proc/overmap_pod_pad_fits(obj/docking_port/stationary/pad, turf/spot)
	var/obj/docking_port/stationary/overmap/landing/landing = pad
	if(istype(landing) && landing.beacon_corners)
		var/list/bounds = landing.landing_bounds
		if(!spot || landing.hidden || landing.get_docked() || landing.landed_pod || spot.z != landing.z || spot.x < bounds[1] || spot.y < bounds[2] || spot.x + 1 > bounds[3] || spot.y + 1 > bounds[4])
			return FALSE
	return overmap_pod_2x2_landable(spot)

/proc/overmap_pod_exposed(turf/spot)
	return overmap_exposed_surface(spot) && overmap_exposed_surface(get_step(spot, EAST)) && overmap_exposed_surface(get_step(spot, NORTH)) && overmap_exposed_surface(get_step(spot, NORTHEAST))

/proc/overmap_pod_2x2_landable(turf/spot)
	return overmap_pod_tile_landable(spot) && overmap_pod_tile_landable(get_step(spot, EAST)) && overmap_pod_tile_landable(get_step(spot, NORTH)) && overmap_pod_tile_landable(get_step(spot, NORTHEAST))

/proc/overmap_pod_supported_by(turf/spot, obj/overmap/entity/host)
	for(var/direction in list(NONE, EAST, NORTH, NORTHEAST))
		if(!host.hull_turfs[get_step(spot, direction)])
			return FALSE
	return TRUE
