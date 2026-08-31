/datum/component/overmap_pod
	dupe_mode = COMPONENT_DUPE_UNIQUE
	var/datum/turf_reservation/pocket
	var/area/spacepod/hyperspace/pocket_area
	var/undocking_until = 0

/datum/component/overmap_pod/Initialize()
	if(!istype(parent, /obj/overmap/entity/pod))
		return COMPONENT_INCOMPATIBLE

/datum/component/overmap_pod/RegisterWithParent()
	var/obj/overmap/entity/pod/token = parent
	token.overmap_pod = src

/datum/component/overmap_pod/UnregisterFromParent()
	var/obj/overmap/entity/pod/token = parent
	if(token.overmap_pod == src)
		token.overmap_pod = null
	release_pocket()

/datum/component/overmap_pod/proc/pod()
	RETURN_TYPE(/obj/spacepod)
	var/obj/overmap/entity/pod/token = parent
	return token.pod

/datum/component/overmap_pod/proc/is_in_own_pocket()
	var/obj/spacepod/craft = pod()
	if(!pocket || QDELETED(pocket) || !craft)
		return FALSE
	var/turf/spot = get_turf(craft)
	return spot && (spot in pocket.reserved_turfs)

/datum/component/overmap_pod/proc/blocks_local_move()
	return is_in_own_pocket() || is_undocking()

/datum/component/overmap_pod/proc/is_undocking()
	return undocking_until && world.time < undocking_until

/datum/component/overmap_pod/proc/is_landed()
	return !is_in_own_pocket() && !is_undocking()

/datum/component/overmap_pod/proc/release_pocket()
	if(pocket && !QDELETED(pocket))
		pocket.Release()
	pocket = null
	if(pocket_area && !QDELETED(pocket_area))
		qdel(pocket_area)
	pocket_area = null

/datum/component/overmap_pod/proc/near_wrap_edge()
	var/obj/spacepod/craft = pod()
	var/turf/spot = get_turf(craft)
	if(!spot || istype(spot, /turf/space/transit) || is_in_own_pocket())
		return FALSE
	if(!isspaceturf(spot))
		return FALSE
	var/datum/overmap_space_region/region = SSovermap?.get_space_region(spot)
	if(region)
		return region.near_playable_edge(spot)
	var/dx = min(spot.x - TRANSITION_BORDER_WEST, TRANSITION_BORDER_EAST - spot.x)
	var/dy = min(spot.y - TRANSITION_BORDER_SOUTH, TRANSITION_BORDER_NORTH - spot.y)
	return min(dx, dy) <= OVERMAP_POD_WRAP_RANGE

/datum/component/overmap_pod/proc/near_landing_beacon(range = OVERMAP_POD_BEACON_RANGE)
	var/obj/spacepod/craft = pod()
	var/turf/spot = get_turf(craft)
	if(!spot || is_in_own_pocket())
		return FALSE
	for(var/obj/machinery/landing_beacon/beacon as anything in GLOB.landing_beacons)
		if(QDELETED(beacon) || beacon.z != spot.z)
			continue
		if(get_dist(spot, beacon) <= range)
			return TRUE
	return FALSE

/datum/component/overmap_pod/proc/can_undock_here()
	var/obj/spacepod/craft = pod()
	var/turf/spot = get_turf(craft)
	if(!spot || istype(spot, /turf/space/transit) || is_in_own_pocket())
		return FALSE
	if(is_mining_level(spot.z))
		return near_landing_beacon()
	return near_landing_beacon() || near_wrap_edge()

/datum/component/overmap_pod/proc/begin_undock()
	var/obj/spacepod/craft = pod()
	if(!craft)
		return "Нет челнока."
	if(is_in_own_pocket())
		return "Челнок уже в гиперпространстве."
	if(is_undocking())
		return "Челнок уже выходит в гиперпространство."
	var/turf/spot = get_turf(craft)
	if(is_mining_level(spot?.z) && !near_landing_beacon())
		return "С Лаваленда можно взлететь только у посадочного маяка (в пределах [OVERMAP_POD_BEACON_RANGE] тайлов)."
	if(!can_undock_here())
		return "Гравитационные сигнатуры не позволяют отлететь в гиперпространство. Отлетите дальше или встаньте у посадочного маяка."
	undocking_until = world.time + OVERMAP_POD_UNDOCK_DELAY
	craft.play_sound_to_riders('sound/effects/hyperspace_begin.ogg')
	craft.message_to_riders(span_warning("Зажигание. Управление заблокировано."))
	addtimer(CALLBACK(src, PROC_REF(finish_undock)), OVERMAP_POD_UNDOCK_DELAY)
	return TRUE

/datum/component/overmap_pod/proc/finish_undock()
	undocking_until = 0
	var/obj/overmap/entity/pod/token = parent
	var/obj/spacepod/craft = pod()
	if(QDELETED(src) || QDELETED(token) || QDELETED(craft))
		return
	if(is_in_own_pocket())
		return
	if(!enter_hyperspace(play_windup = FALSE))
		craft.message_to_riders(span_warning("Не удалось выйти в гиперпространство."))
		return
	craft.message_to_riders(span_warning("Челнок в гиперпространстве. Управление корпусом заблокировано."))
	token.announce_sensor_event("Челнок вышел в гиперпространство: [token.get_overmap_display_name()]", "undock")

/datum/component/overmap_pod/proc/can_physical_dock()
	var/obj/overmap/entity/pod/token = parent
	if(!is_in_own_pocket() || !isturf(token.loc))
		return FALSE
	if(token.is_moving() && !OVERMAP_SPEED_STOPPED(token.get_speed()))
		return FALSE
	var/obj/overmap/entity/host = token.get_dock_host()
	if(!host)
		return FALSE
	if(length(host_landing_pads(host)))
		return TRUE
	return !host.deny_pod_edge_dock

/datum/component/overmap_pod/proc/can_edge_dock()
	var/obj/overmap/entity/pod/token = parent
	var/obj/overmap/entity/host = token.get_dock_host()
	return host && !host.deny_pod_edge_dock

/datum/component/overmap_pod/proc/host_landing_pads(obj/overmap/entity/host)
	. = list()
	var/obj/overmap/entity/pod/token = parent
	if(!host)
		return
	for(var/obj/docking_port/stationary/overmap/landing/pad as anything in SSshuttle.stationary)
		if(!istype(pad) || QDELETED(pad))
			continue
		if(token.pad_matches_host(pad, host))
			. += pad

/datum/component/overmap_pod/proc/build_dock_list()
	. = list()
	var/obj/overmap/entity/pod/token = parent
	var/obj/overmap/entity/host = token.get_dock_host()
	if(!host)
		return
	var/chosen_id = token.selected_dock_id
	if(can_edge_dock())
		. += list(list(
			"id" = OVERMAP_DOCK_ID_EDGE,
			"name" = "Рядом с объектом ([host.name])",
			"selected" = chosen_id == OVERMAP_DOCK_ID_EDGE || !chosen_id,
			"current" = FALSE,
			"can_dock" = TRUE,
			"state" = "free",
			"reason" = "Посадка у края сектора этого объекта",
		))
	for(var/obj/docking_port/stationary/overmap/landing/pad as anything in host_landing_pads(host))
		if(!pad.overmap_dock_label)
			pad.apply_overmap_dock_role()
		var/turf/dest = overmap_pick_pod_beacon_turf(pad)
		. += list(list(
			"id" = pad.id,
			"name" = pad.overmap_dock_label || pad.name,
			"selected" = pad.id == chosen_id,
			"current" = FALSE,
			"can_dock" = !!dest,
			"state" = dest ? "free" : "small",
			"reason" = dest ? "Посадка на маяк" : "Нет места у маяка",
		))

/datum/component/overmap_pod/proc/set_selected_pad(pad_id)
	var/obj/overmap/entity/pod/token = parent
	if(!pad_id)
		return FALSE
	var/obj/overmap/entity/host = token.get_dock_host()
	if(pad_id == OVERMAP_DOCK_ID_EDGE)
		if(!can_edge_dock())
			return FALSE
		token.selected_dock_id = OVERMAP_DOCK_ID_EDGE
		return TRUE
	var/obj/docking_port/stationary/pad = SSshuttle.getDock(pad_id)
	if(!istype(pad, /obj/docking_port/stationary/overmap/landing))
		return FALSE
	if(!token.pad_matches_host(pad, host))
		return FALSE
	token.selected_dock_id = pad_id
	return TRUE

/datum/component/overmap_pod/proc/get_selected_landing_pad()
	var/obj/overmap/entity/pod/token = parent
	var/obj/overmap/entity/host = token.get_dock_host()
	if(!host)
		return null
	var/obj/docking_port/stationary/pad
	if(token.selected_dock_id)
		pad = SSshuttle.getDock(token.selected_dock_id)
	if(istype(pad, /obj/docking_port/stationary/overmap/landing) && token.pad_matches_host(pad, host))
		return pad
	for(var/obj/docking_port/stationary/overmap/landing/candidate as anything in host_landing_pads(host))
		if(overmap_pick_pod_beacon_turf(candidate))
			return candidate
	return null

/datum/component/overmap_pod/proc/begin_dock(force_edge = FALSE)
	var/obj/overmap/entity/pod/token = parent
	var/obj/spacepod/craft = pod()
	if(!craft)
		return "Нет челнока."
	if(is_undocking())
		return "Сначала дождитесь выхода в гиперпространство."
	if(!is_in_own_pocket())
		return "Сначала отстыкуйтесь в гиперпространство."
	if(token.is_moving() && !OVERMAP_SPEED_STOPPED(token.get_speed()))
		return "Сначала остановитесь."
	var/obj/overmap/entity/host = token.get_dock_host()
	if(!host)
		return "На этой клетке не к чему стыковаться."
	var/turf/dest
	var/obj/docking_port/stationary/overmap/landing/beacon_pad
	if(!force_edge)
		if(token.selected_dock_id == OVERMAP_DOCK_ID_EDGE)
			force_edge = TRUE
		else
			beacon_pad = get_selected_landing_pad()
		if(beacon_pad)
			dest = overmap_pick_pod_beacon_turf(beacon_pad)
			if(!dest)
				return "Нет свободного места у посадочного маяка."
	if(!dest)
		if(host.deny_pod_edge_dock)
			return "Этот объект принимает челноки только на посадочный маяк."
		dest = overmap_pick_pod_edge_turf(overmap_pod_landing_z(host))
		if(!dest)
			return "Нет свободного места на краю сектора."
	if(!land_at(dest, host))
		return "Не удалось приземлиться."
	token.announce_sensor_event("Челнок вышел из гиперпространства: [token.get_overmap_display_name()] → [host.name]", "dock")
	return TRUE

/datum/component/overmap_pod/proc/enter_hyperspace(play_windup = TRUE)
	var/obj/overmap/entity/pod/token = parent
	var/obj/spacepod/craft = pod()
	if(!craft)
		return FALSE
	if(is_in_own_pocket())
		return TRUE
	if(!ensure_pocket())
		return FALSE
	var/turf/pad = pocket_center()
	if(!pad)
		release_pocket()
		return FALSE
	var/saved_overmap = token.get_overmap_turf()
	craft.forceMove(pad)
	if(token.docked_to)
		token.release_to_overmap(saved_overmap)
	else if(saved_overmap && !isturf(token.loc))
		token.forceMove(saved_overmap)
	else if(saved_overmap && token.loc != saved_overmap)
		token.forceMove(saved_overmap)
	if(token.sector && saved_overmap)
		token.sector.objects |= token
	token.status = OVERMAP_STATUS_TRANSIT
	token.halted = FALSE
	token.hidden_from_contacts = FALSE
	token.update_overmap_visibility()
	if(play_windup)
		craft.play_sound_to_riders('sound/effects/hyperspace_begin.ogg')
		craft.message_to_riders(span_warning("Управление корпусом заблокировано. Челнок в гиперпространстве."))
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
		reservation_type = /datum/turf_reservation/transit,
		turf_type_override = /turf/space/transit/south,
	)
	if(!istype(pocket))
		pocket = null
		return FALSE
	var/turf/bottom = pocket.bottom_left_turfs[1]
	if(!bottom)
		release_pocket()
		return FALSE
	pocket_area = new /area/spacepod/hyperspace
	pocket_area.parallax_movedir = SOUTH
	pocket_area.moving = TRUE
	LISTASSERTLEN(pocket_area.turfs_by_zlevel, bottom.z, list())
	var/turf/inner = inner_origin()
	if(!inner)
		release_pocket()
		return FALSE
	var/inner_max_x = inner.x + OVERMAP_POD_HYPERSPACE_SIZE - 1
	var/inner_max_y = inner.y + OVERMAP_POD_HYPERSPACE_SIZE - 1
	for(var/turf/hold as anything in block(inner, locate(inner_max_x, inner_max_y, inner.z)))
		if(!istype(hold, /turf/space/transit/pod))
			hold.ChangeTurf(/turf/space/transit/pod)
	var/turf/top_right = pocket.top_right_turfs[1]
	if(!top_right)
		release_pocket()
		return FALSE
	pocket.reserved_turfs = block(bottom, top_right)
	for(var/turf/spot as anything in pocket.reserved_turfs)
		SSmapping.used_turfs[spot] = pocket
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

/datum/component/overmap_pod/proc/collect_keep_payload()
	. = list()
	var/obj/spacepod/craft = pod()
	if(!craft)
		return
	var/turf/origin = get_turf(craft)
	if(!origin)
		return
	var/min_x = origin.x - 2
	var/min_y = origin.y - 2
	var/max_x = min_x + OVERMAP_POD_DOCK_KEEP - 1
	var/max_y = min_y + OVERMAP_POD_DOCK_KEEP - 1
	for(var/turf/spot as anything in block(locate(min_x, min_y, origin.z), locate(max_x, max_y, origin.z)))
		if(!spot)
			continue
		if(pocket && !(spot in pocket.reserved_turfs))
			continue
		for(var/atom/movable/thing in spot)
			if(thing == craft || !thing.simulated || isobserver(thing) || istype(thing, /obj/docking_port))
				continue
			if(thing.loc != spot)
				continue
			.[thing] = list(thing.x - origin.x, thing.y - origin.y)

/datum/component/overmap_pod/proc/land_at(turf/dest, obj/overmap/entity/host)
	var/obj/overmap/entity/pod/token = parent
	var/obj/spacepod/craft = pod()
	if(!craft || !dest)
		return FALSE
	var/list/payload = collect_keep_payload()
	craft.forceMove(dest)
	for(var/atom/movable/thing as anything in payload)
		var/list/offset = payload[thing]
		var/turf/drop = locate(dest.x + offset[1], dest.y + offset[2], dest.z)
		if(drop)
			thing.forceMove(drop)
		else
			thing.forceMove(dest)
	release_pocket()
	token.nest_inside(host)
	if(host.sector)
		token.sector = host.sector
		host.sector.objects |= token
	token.speed[1] = 0
	token.speed[2] = 0
	craft.play_sound_to_riders('sound/effects/hyperspace_end.ogg')
	craft.refresh_overmap_parallax()
	return TRUE

/proc/overmap_pod_landing_z(obj/overmap/entity/host)
	if(!host)
		return null
	var/z_level = host.dock_host?.pick_landing_z()
	if(z_level)
		return z_level
	var/turf/here = host.get_overmap_turf()
	return here?.z

/proc/overmap_pod_tile_landable(turf/spot)
	if(!spot || istype(spot, /turf/space/transit))
		return FALSE
	if(overmap_lavaland_landing_blocked(spot))
		return FALSE
	if(spot.density)
		return FALSE
	for(var/atom/movable/thing in spot)
		if(thing.density && !istype(thing, /obj/machinery/landing_beacon))
			return FALSE
	return TRUE

/proc/overmap_pod_2x2_landable(turf/spot)
	if(!overmap_pod_tile_landable(spot))
		return FALSE
	var/turf/east = get_step(spot, EAST)
	var/turf/north = get_step(spot, NORTH)
	var/turf/ne = get_step(spot, NORTHEAST)
	return overmap_pod_tile_landable(east) && overmap_pod_tile_landable(north) && overmap_pod_tile_landable(ne)

/proc/overmap_pick_pod_beacon_turf(obj/docking_port/stationary/pad)
	var/turf/origin = get_turf(pad)
	if(!origin)
		return null
	if(overmap_pod_2x2_landable(origin))
		return origin
	for(var/turf/spot in orange(2, origin))
		if(overmap_pod_2x2_landable(spot))
			return spot
	return null

/proc/overmap_pod_tile_free(turf/spot)
	if(!isspaceturf(spot) || istype(spot, /turf/space/transit))
		return FALSE
	if(spot.density)
		return FALSE
	for(var/atom/movable/thing in spot)
		if(thing.density)
			return FALSE
	return TRUE

/proc/overmap_pod_2x2_free(turf/spot)
	if(!overmap_pod_tile_free(spot))
		return FALSE
	var/turf/east = get_step(spot, EAST)
	var/turf/north = get_step(spot, NORTH)
	var/turf/ne = get_step(spot, NORTHEAST)
	return overmap_pod_tile_free(east) && overmap_pod_tile_free(north) && overmap_pod_tile_free(ne)

/proc/overmap_pick_pod_edge_turf(z)
	if(!z)
		return null
	var/datum/overmap_space_region/region
	for(var/datum/overmap_feature/ruin/site as anything in SSovermap?.ruin_sites)
		if(QDELETED(site))
			continue
		for(var/obj/overmap/entity/feature/ruin/ruin_token as anything in site.tokens)
			if(ruin_token?.landing_region?.space_z == z)
				region = ruin_token.landing_region
				break
		if(region)
			break
	if(region)
		return region.pick_edge_space_turf()
	var/inset = OVERMAP_POD_WRAP_RANGE
	var/min_x = TRANSITIONEDGE + inset
	var/max_x = world.maxx - TRANSITIONEDGE - inset
	var/min_y = TRANSITIONEDGE + inset
	var/max_y = world.maxy - TRANSITIONEDGE - inset
	if(min_x >= max_x || min_y >= max_y)
		return null
	for(var/i in 1 to OVERMAP_POD_LANDING_TRIES)
		var/turf/spot
		switch(pick(NORTH, SOUTH, EAST, WEST))
			if(NORTH)
				spot = locate(rand(min_x, max_x), max_y, z)
			if(SOUTH)
				spot = locate(rand(min_x, max_x), min_y, z)
			if(EAST)
				spot = locate(max_x, rand(min_y, max_y), z)
			if(WEST)
				spot = locate(min_x, rand(min_y, max_y), z)
		if(overmap_pod_2x2_free(spot))
			return spot
	return null
