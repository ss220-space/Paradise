/datum/overmap_sector
	var/name = "Local space"
	var/id = "local"
	var/size = OVERMAP_DEFAULT_SIZE
	var/z_level = 0
	var/origin_x = 1
	var/origin_y = 1
	var/datum/turf_reservation/reservation
	var/access_flags = OVERMAP_ACCESS_PUBLIC

	var/sector_kind = OVERMAP_SECTOR_KIND_STATION

	var/ruin_spawn_weight = 0

	var/hazard_spawn_weight = 0
	var/list/obj/overmap/objects = list()
	var/area/overmap/map_area

	var/wraparound = TRUE
	var/tile_travel = 1

	var/list/datum/overmap_sector_message/comms_messages = list()

/datum/overmap_sector/New(sector_id, sector_name, sector_size, sector_access)
	if(sector_id)
		id = sector_id
	if(sector_name)
		name = sector_name
	if(sector_size)
		size = sector_size
	if(!isnull(sector_access))
		access_flags = sector_access
	build_map()

/datum/overmap_sector/Destroy()
	for(var/obj/overmap/overmap_object as anything in objects)
		qdel(overmap_object)
	objects.Cut()
	QDEL_LIST(comms_messages)
	map_area = null
	QDEL_NULL(reservation)
	return ..()

/datum/overmap_sector/proc/add_comms_message(datum/overmap_sector_message/message)
	if(!message)
		return
	comms_messages += message
	while(length(comms_messages) > OVERMAP_COMMS_MAX_MESSAGES)
		var/datum/overmap_sector_message/old = comms_messages[1]
		comms_messages.Cut(1, 2)
		qdel(old)
	for(var/obj/machinery/overmap_intercom/panel as anything in GLOB.overmap_intercoms)
		if(QDELETED(panel))
			continue
		if(panel.get_comms_sector() != src)
			continue
		panel.on_sector_message(message)

/datum/overmap_sector/proc/build_map()
	var/span = size + OVERMAP_VIEW_PAD
	reservation = SSmapping.request_turf_block_reservation(span, span, 1, turf_type_override = /turf/space, noisy = FALSE)
	var/turf/bottom_left
	if(reservation && length(reservation.bottom_left_turfs))
		bottom_left = reservation.bottom_left_turfs[1]
	if(!bottom_left)
		CRASH("Overmap: failed to reserve a [span]x[span] block for sector [id].")
	origin_x = bottom_left.x
	origin_y = bottom_left.y
	z_level = bottom_left.z

	map_area = new /area/overmap
	map_area.name = "Overmap - [name]"
	map_area.overmap_size = size
	map_area.overmap_origin_x = origin_x
	map_area.overmap_origin_y = origin_y

	var/max_x = origin_x + span - 1
	var/max_y = origin_y + span - 1
	for(var/turf/old_turf as anything in block(locate(origin_x, origin_y, z_level), locate(max_x, max_y, z_level)))
		var/area/old_area = get_area(old_turf)
		var/local_x = old_turf.x - origin_x + 1
		var/local_y = old_turf.y - origin_y + 1
		var/in_map = local_x <= size && local_y <= size
		var/is_rim = in_map && (local_x == 1 || local_y == 1 || local_x == size || local_y == size)
		var/turf/new_turf
		if(!in_map)
			new_turf = old_turf.ChangeTurf(/turf/simulated/floor/indestructible/hyperspace, FALSE, FALSE, CHANGETURF_IGNORE_AIR)
		else if(is_rim)
			new_turf = old_turf.ChangeTurf(/turf/simulated/floor/indestructible/overmap/edge, FALSE, FALSE, CHANGETURF_IGNORE_AIR)
		else
			new_turf = old_turf.ChangeTurf(/turf/simulated/floor/indestructible/overmap, FALSE, FALSE, CHANGETURF_IGNORE_AIR)
		new_turf.change_area(old_area, map_area)
		new_turf.name = "[local_x]-[local_y]"
		if(in_map && istype(new_turf, /turf/simulated/floor/indestructible/overmap))
			var/turf/simulated/floor/indestructible/overmap/map_turf = new_turf
			map_turf.add_edge_numbers()

/datum/overmap_sector/proc/locate_local(local_x, local_y)
	return locate(origin_x + local_x - 1, origin_y + local_y - 1, z_level)

/datum/overmap_sector/proc/coord_x(turf/spot)
	if(!spot)
		return 0
	return spot.x - origin_x + 1

/datum/overmap_sector/proc/coord_y(turf/spot)
	if(!spot)
		return 0
	return spot.y - origin_y + 1

/datum/overmap_sector/proc/contains_turf(turf/spot)
	if(!spot || spot.z != z_level)
		return FALSE
	return spot.x >= origin_x && spot.x <= reserved_max_x() && spot.y >= origin_y && spot.y <= reserved_max_y()

/datum/overmap_sector/proc/reserved_max_x()
	return origin_x + size + OVERMAP_VIEW_PAD - 1

/datum/overmap_sector/proc/reserved_max_y()
	return origin_y + size + OVERMAP_VIEW_PAD - 1

/datum/overmap_sector/proc/playable_min_x()
	return origin_x

/datum/overmap_sector/proc/playable_max_x()
	return origin_x + size - 1

/datum/overmap_sector/proc/playable_min_y()
	return origin_y

/datum/overmap_sector/proc/playable_max_y()
	return origin_y + size - 1

/datum/overmap_sector/proc/turf_occupied(turf/open_turf)
	if(!open_turf)
		return TRUE
	if(locate(/obj/overmap) in open_turf)
		return TRUE
	for(var/obj/overmap/planet/planet as anything in objects)
		if(istype(planet) && planet.covers_turf(open_turf))
			return TRUE
	return FALSE

/datum/overmap_sector/proc/chebyshev_to_rect(turf/spot, min_x, min_y, max_x, max_y)
	if(!spot)
		return INFINITY
	var/dx = 0
	var/dy = 0
	if(spot.x < min_x)
		dx = min_x - spot.x
	else if(spot.x > max_x)
		dx = spot.x - max_x
	if(spot.y < min_y)
		dy = min_y - spot.y
	else if(spot.y > max_y)
		dy = spot.y - max_y
	return max(dx, dy)

/datum/overmap_sector/proc/get_centered_footprint_origin(footprint)
	var/local_x = 1 + round((size - footprint) / 2)
	var/local_y = 1 + round((size - footprint) / 2)
	local_x = clamp(local_x, OVERMAP_EDGE + 1, size - OVERMAP_EDGE - footprint + 1)
	local_y = clamp(local_y, OVERMAP_EDGE + 1, size - OVERMAP_EDGE - footprint + 1)
	return locate_local(local_x, local_y)

/datum/overmap_sector/proc/get_turf_at_range_from_rect(min_x, min_y, max_x, max_y, min_dist, max_dist)
	var/low_x = origin_x + OVERMAP_EDGE
	var/low_y = origin_y + OVERMAP_EDGE
	var/high_x = origin_x + size - OVERMAP_EDGE - 1
	var/high_y = origin_y + size - OVERMAP_EDGE - 1
	var/list/candidates = list()
	for(var/turf/open_turf as anything in block(locate(low_x, low_y, z_level), locate(high_x, high_y, z_level)))
		if(turf_occupied(open_turf))
			continue
		var/dist = chebyshev_to_rect(open_turf, min_x, min_y, max_x, max_y)
		if(dist >= min_dist && dist <= max_dist)
			candidates += open_turf
	if(length(candidates))
		return pick(candidates)
	return get_random_open_turf()

/datum/overmap_sector/proc/get_turf_near(turf/anchor, min_dist, max_dist, obj/overmap/planet/avoid_planet)
	if(!anchor)
		return get_random_open_turf()
	var/low_x = origin_x + OVERMAP_EDGE
	var/low_y = origin_y + OVERMAP_EDGE
	var/high_x = origin_x + size - OVERMAP_EDGE - 1
	var/high_y = origin_y + size - OVERMAP_EDGE - 1
	var/list/candidates = list()
	for(var/turf/open_turf as anything in block(locate(low_x, low_y, z_level), locate(high_x, high_y, z_level)))
		if(turf_occupied(open_turf))
			continue
		if(avoid_planet?.covers_turf(open_turf))
			continue
		var/dist = max(abs(open_turf.x - anchor.x), abs(open_turf.y - anchor.y))
		if(dist >= min_dist && dist <= max_dist)
			candidates += open_turf
	if(length(candidates))
		return pick(candidates)
	return get_random_open_turf()

/datum/overmap_sector/proc/get_random_open_turf()
	var/low_x = origin_x + OVERMAP_EDGE
	var/low_y = origin_y + OVERMAP_EDGE
	var/high_x = origin_x + size - OVERMAP_EDGE - 1
	var/high_y = origin_y + size - OVERMAP_EDGE - 1
	var/list/candidates = list()
	for(var/turf/open_turf as anything in block(locate(low_x, low_y, z_level), locate(high_x, high_y, z_level)))
		if(turf_occupied(open_turf))
			continue
		candidates += open_turf
	if(!length(candidates))
		return locate(rand(low_x, high_x), rand(low_y, high_y), z_level)
	return pick(candidates)

/datum/overmap_sector/proc/find_footprint_origin(footprint, turf/avoid, min_dist, max_dist)
	var/low = OVERMAP_EDGE + 1
	var/high = size - OVERMAP_EDGE - footprint + 1
	if(high < low)
		return null
	var/list/preferred = list()
	var/list/fallback = list()
	for(var/local_x in low to high)
		for(var/local_y in low to high)
			var/turf/origin = locate_local(local_x, local_y)
			if(!origin)
				continue
			var/blocked = FALSE
			var/closest = INFINITY
			for(var/spot_x in local_x to local_x + footprint - 1)
				for(var/spot_y in local_y to local_y + footprint - 1)
					var/turf/spot = locate_local(spot_x, spot_y)
					if(turf_occupied(spot))
						blocked = TRUE
						break
					if(avoid)
						closest = min(closest, max(abs(avoid.x - spot.x), abs(avoid.y - spot.y)))
				if(blocked)
					break
			if(blocked)
				continue
			if(avoid && closest <= 1)
				continue
			fallback += origin
			if(!avoid || (closest >= min_dist && closest <= max_dist))
				preferred += origin
	if(length(preferred))
		return pick(preferred)
	if(length(fallback))
		return pick(fallback)
	return null

/datum/overmap_sector/proc/get_turf_at(coord_x, coord_y)
	coord_x = clamp(coord_x, 1, size)
	coord_y = clamp(coord_y, 1, size)
	return locate_local(coord_x, coord_y)

/datum/overmap_sector/proc/get_nearest_open_turf(want_x, want_y)
	var/turf/start = get_turf_at(want_x, want_y)
	if(start && !turf_occupied(start))
		return start
	var/turf/best
	var/best_dist = INFINITY
	for(var/turf/open_turf as anything in get_map_turfs())
		if(turf_occupied(open_turf))
			continue
		var/dist = max(abs(coord_x(open_turf) - want_x), abs(coord_y(open_turf) - want_y))
		if(dist >= best_dist)
			continue
		best_dist = dist
		best = open_turf
	return best || start

/datum/overmap_sector/proc/add_object(obj/overmap/overmap_object, turf/target)
	overmap_object.sector = src
	objects |= overmap_object
	if(target)
		overmap_object.forceMove(target)

/datum/overmap_sector/proc/remove_object(obj/overmap/overmap_object)
	objects -= overmap_object
	if(overmap_object.sector == src)
		overmap_object.sector = null

/datum/overmap_sector/proc/get_map_turfs()
	return block(locate_local(1, 1), locate_local(size, size))

/datum/overmap_sector/proc/populate_roundstart()
	return

/datum/overmap_sector/proc/can_spawn_static_hazards()
	return sector_kind != OVERMAP_SECTOR_KIND_SERVICE

/datum/overmap_sector/station/populate_roundstart()
	if(can_spawn_static_hazards())
		spawn_static_overmap_hazards(src)
	SSovermap.spawn_overmap_ruins(src)

/datum/overmap_sector/station
	id = OVERMAP_SECTOR_ID_STATION
	name = "Эпсилон Лукусты"
	size = OVERMAP_SECTOR_STATION_SIZE
	sector_kind = OVERMAP_SECTOR_KIND_STATION
	access_flags = OVERMAP_ACCESS_PUBLIC
	ruin_spawn_weight = 0.15
	hazard_spawn_weight = 0.1
	tile_travel = 3

/datum/overmap_sector/service
	id = OVERMAP_SECTOR_ID_SERVICE
	name = "Дальный космос Эпсилон Лукусты"
	size = OVERMAP_SECTOR_SERVICE_SIZE
	sector_kind = OVERMAP_SECTOR_KIND_SERVICE
	access_flags = OVERMAP_ACCESS_CENTCOM | OVERMAP_ACCESS_SYNDICATE
	ruin_spawn_weight = 0
	hazard_spawn_weight = 0

/datum/overmap_sector/wilderness
	size = OVERMAP_SECTOR_WILDERNESS_SIZE
	sector_kind = OVERMAP_SECTOR_KIND_WILDERNESS
	access_flags = OVERMAP_ACCESS_PUBLIC
	ruin_spawn_weight = 1
	hazard_spawn_weight = 1
	tile_travel = 6

/datum/overmap_sector/wilderness/populate_roundstart()
	spawn_static_overmap_hazards(src)
	SSovermap.spawn_overmap_ruins(src)

/datum/overmap_sector/wilderness/alpha
	id = OVERMAP_SECTOR_ID_WILDERNESS_A
	name = "ПРИДУМАТЬ НАЗВАНИЕ СЕКТОРА"

/datum/overmap_sector/wilderness/beta
	id = OVERMAP_SECTOR_ID_WILDERNESS_B
	name = "ПРИДУМАТЬ НАЗВАНИЕ СЕКТОРА"
