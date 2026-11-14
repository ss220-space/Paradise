/obj/overmap/entity/proc/update_terrain_view(elapsed)
	if(!local_space)
		QDEL_NULL(terrain_view)
		return

	if(shuttle && hull_z != shuttle.z && world.time >= next_hull_resync)
		next_hull_resync = world.time + OVERMAP_SLOW_TICK
		remap_hull()
	var/datum/terrain_mirror/mirror = terrain_view
	if(mirror?.local_space != local_space)
		QDEL_NULL(terrain_view)
		terrain_view = new /datum/terrain_mirror(src, local_space)
		mirror = terrain_view
	mirror.update(elapsed)

/obj/overmap/entity/proc/keep_inside_local_space()
	var/static/next_retry = 0
	if(world.time > next_retry)
		next_retry = world.time + 5 SECONDS
		SSovermap.create_local_spaces()
	local_space = SSovermap.local_space_at(sector, get_world_x(), get_world_y()) || SSovermap.find_bubble(sector, get_world_x(), get_world_y())
	if(!local_space)
		QDEL_NULL(terrain_view)

/obj/overmap/entity/proc/local_arrival_point(list/target, list/origin)
	var/datum/overmap_bubble/arrival_space = SSovermap.local_space_at(sector, target[1], target[2])
	if(!arrival_space)
		return target
	var/list/bounds = arrival_space.bounds
	var/half_size = min(bounds[3] - bounds[1], bounds[4] - bounds[2]) / 2 - OVERMAP_LOCAL_ARRIVAL_MARGIN - hull_radius
	var/list/center = arrival_space.to_world(arrival_space.center_x, arrival_space.center_y)
	var/approach_x = origin[1] - center[1]
	var/approach_y = origin[2] - center[2]
	var/approach_length = sqrt(approach_x ** 2 + approach_y ** 2)
	if(!approach_length)
		approach_y = 1
		approach_length = 1
	return list(center[1] + approach_x / approach_length * half_size, center[2] + approach_y / approach_length * half_size)

/datum/controller/subsystem/overmap/proc/local_space_at(datum/overmap_sector/sector, world_x, world_y)

	var/datum/overmap_bubble/nearest
	var/nearest_distance
	for(var/datum/overmap_bubble/bubble as anything in bubbles)
		if(!bubble?.static_level)
			continue
		bubble.sync_host_region()
		if(bubble.sector != sector || !bubble.region)
			continue
		if(world_x >= bubble.region[1] && world_x <= bubble.region[3] && world_y >= bubble.region[2] && world_y <= bubble.region[4])
			return bubble

		var/gap_x = max(bubble.region[1] - world_x, world_x - bubble.region[3], 0)
		var/gap_y = max(bubble.region[2] - world_y, world_y - bubble.region[4], 0)
		var/gap = gap_x * gap_x + gap_y * gap_y
		if(isnull(nearest_distance) || gap < nearest_distance)
			nearest_distance = gap
			nearest = bubble
	if(nearest)
		return nearest
	for(var/datum/overmap_bubble/bubble as anything in bubbles)
		if(bubble?.sector == sector && bubble.covers(bubble.to_bubble(world_x, world_y), 0))
			return bubble

/datum/controller/subsystem/overmap/proc/create_local_spaces()

	ensure_host_space(station_entity)
	for(var/datum/component/overmap_dock_host/host as anything in dock_hosts)
		if(QDELETED(host))
			continue
		var/obj/overmap/entity/token = host.parent
		ensure_host_space(token)

/obj/overmap/entity/proc/host_content_bounds(z_level)

	var/obj/overmap/entity/feature/ruin/ruin = src
	var/datum/overmap_space_region/space_region = istype(ruin) ? ruin.landing_region : null
	if(istype(space_region) && space_region.space_z == z_level)
		return list(space_region.space_origin_x + space_region.pad, space_region.space_origin_y + space_region.pad, space_region.space_origin_x + space_region.pad + space_region.size - 1, space_region.space_origin_y + space_region.pad + space_region.size - 1)
	var/min_x
	var/min_y
	var/max_x
	var/max_y
	for(var/area/place as anything in dock_host?.host_areas())
		for(var/turf/spot as anything in place)
			if(spot.z != z_level)
				continue
			if(isnull(min_x) || spot.x < min_x)
				min_x = spot.x
			if(isnull(min_y) || spot.y < min_y)
				min_y = spot.y
			if(isnull(max_x) || spot.x > max_x)
				max_x = spot.x
			if(isnull(max_y) || spot.y > max_y)
				max_y = spot.y
	if(istype(src, /obj/overmap/entity/taipan_site))
		for(var/turf/simulated/rock in block(locate(1 + TRANSITIONEDGE, 1 + TRANSITIONEDGE, z_level), locate(world.maxx - TRANSITIONEDGE, world.maxy - TRANSITIONEDGE, z_level)))
			if(!ismineralturf(rock) && !istype(rock, /turf/simulated/floor/plating/asteroid))
				continue
			min_x = isnull(min_x) ? rock.x : min(min_x, rock.x)
			max_x = isnull(max_x) ? rock.x : max(max_x, rock.x)
			min_y = isnull(min_y) ? rock.y : min(min_y, rock.y)
			max_y = isnull(max_y) ? rock.y : max(max_y, rock.y)
	if(isnull(min_x))

		return list(1 + TRANSITIONEDGE, 1 + TRANSITIONEDGE, world.maxx - TRANSITIONEDGE, world.maxy - TRANSITIONEDGE)
	return list(min_x, min_y, max_x, max_y)

/obj/overmap/entity/proc/region_from_rect(list/rect)
	if(!rect)
		return null
	var/center_x = (rect[1] + rect[3]) / 2
	var/center_y = (rect[2] + rect[4]) / 2
	var/world_x = get_world_x()
	var/world_y = get_world_y()
	return list(world_x - center_x + rect[1], world_y - center_y + rect[2], world_x - center_x + rect[3], world_y - center_y + rect[4])

/datum/controller/subsystem/overmap/proc/ensure_host_space(obj/overmap/entity/token)
	if(istype(token, /obj/overmap/entity/virtual_structure))
		return null

	if(!token?.dock_host || !token.project_terrain || token.dock_host.planet_landing)
		return null

	if(istype(token, /obj/overmap/entity/shuttle) || istype(token, /obj/overmap/entity/pod) || token.shuttle)
		return null
	if(token.physical_space && !QDELETED(token.physical_space))
		return token.physical_space

	if(isnull(bubbles) || isnull(bubbles_by_z))
		if(isnull(bubbles))
			bubbles = list()
		if(isnull(bubbles_by_z))
			bubbles_by_z = list()
	var/z_level = token.dock_host.pick_landing_z()
	if(!z_level)
		return null

	var/list/rect = token.host_content_bounds(z_level)
	var/list/new_region = token.region_from_rect(rect)
	for(var/datum/overmap_bubble/other as anything in bubbles)
		if(QDELETED(other) || !other.static_level || other.host == token || other.sector != token.sector)
			continue
		other.sync_host_region()
		if(other.region && new_region && regions_overlap(other.region, new_region))
			return null
	var/datum/overmap_bubble/space = new(token.sector, token.get_world_x(), token.get_world_y(), 0, 0)
	space.host = token
	space.fill_level(z_level)
	if(rect)
		space.bounds = rect
		space.center_x = (rect[1] + rect[3]) / 2
		space.center_y = (rect[2] + rect[4]) / 2
	space.region = null
	space.region_z = null
	space.ensure_region()

	if(length(bubbles_by_z) < z_level)
		bubbles_by_z.len = z_level
	if(!bubbles_by_z[z_level])
		bubbles_by_z[z_level] = space
	token.physical_space = space
	return space

/obj/overmap/entity/proc/record_undock_origin()
	map_hull()

	if(docked_ship)
		undock_ship()
	undock_zone = SSovermap.station_docking_zone
	if(undock_zone?.accepts_pad(shuttle?.get_docked()))
		undock_host = SSovermap.station_entity
		undock_origin = list(hull_z, hull_center_x, hull_center_y, shuttle.overmap_origin()[2])
		return
	undock_zone = null

	var/datum/overmap_bubble/here_frame
	here_frame = SSovermap.bubble_for_turf(get_turf(shuttle))
	undock_host = docked_to || (here_frame && here_frame.host)
	var/datum/overmap_bubble/host_frame = undock_host && undock_host.physical_space

	if(!here_frame || (host_frame && host_frame != here_frame))
		undock_origin = null
		return
	undock_origin = list(hull_z, hull_center_x, hull_center_y, shuttle.overmap_origin()[2])

/obj/overmap/entity/proc/place_at_undock_origin()
	var/list/origin = undock_origin

	undock_origin = null
	if(!length(origin))
		return
	if(!QDELETED(undock_zone))
		undock_zone.place_departure(src)
		undock_zone = null
		undock_host = null
		return
	var/datum/overmap_bubble/origin_space = undock_host?.physical_space
	if(!origin_space)
		origin_space = origin[1] <= length(SSovermap.bubbles_by_z) && SSovermap.bubbles_by_z[origin[1]]
	if(!origin_space)

		SSovermap.create_local_spaces()
		origin_space = origin[1] <= length(SSovermap.bubbles_by_z) && SSovermap.bubbles_by_z[origin[1]]
	if(!origin_space)
		return

	if(!origin_space.sector)
		origin_space.sector = sector
	else if(origin_space.sector != sector)
		return
	var/list/spot = origin_space.to_world(origin[2], origin[3])
	flight?.set_autopilot(FALSE, manual = FALSE)
	flight?.set_facing(dir2angle(origin[4]) - dir2angle(shuttle.overmap_origin()[2]))
	speed[1] = 0
	speed[2] = 0
	set_world_position(spot[1], spot[2])
	local_space = origin_space
	undock_origin = null
	undock_host = null

/obj/overmap/entity/proc/radar_terrain(reach = OVERMAP_RADAR_TERRAIN_RANGE)
	if(!local_space)
		return null
	var/list/origin = radar_world_origin()
	var/list/spot = local_space.to_bubble(origin[1], origin[2])
	var/list/walls = list()
	var/list/frames = list()
	var/list/floors = list()
	var/first_x = max(round((spot[1] - reach) / OVERMAP_RADAR_CHUNK), 0)
	var/last_x = round(min(spot[1] + reach, world.maxx) / OVERMAP_RADAR_CHUNK)
	var/first_y = max(round((spot[2] - reach) / OVERMAP_RADAR_CHUNK), 0)
	var/last_y = round(min(spot[2] + reach, world.maxy) / OVERMAP_RADAR_CHUNK)
	var/list/anchor = local_space.to_world(0, 0)
	var/key = "\ref[local_space]:[first_x]:[last_x]:[first_y]:[last_y]:[anchor[1]]:[anchor[2]]"
	if(radar_cache.terrain_cache && radar_cache.terrain_key == key && world.time < radar_cache.terrain_until)
		return radar_cache.terrain_cache
	var/list/chunks = list()
	var/unchanged = radar_cache.terrain_cache && radar_cache.terrain_key == key
	for(var/chunk_x in first_x to last_x)
		for(var/chunk_y in first_y to last_y)
			var/list/chunk = local_space.radar_chunk(chunk_x, chunk_y)
			chunks += list(chunk)
			if(length(chunks) > length(radar_cache.terrain_chunks) || radar_cache.terrain_chunks[length(chunks)] != chunk)
				unchanged = FALSE
	radar_cache.terrain_key = key
	radar_cache.terrain_until = world.time + 1 SECONDS
	var/list/docks = radar_station_docks()
	var/dock_key = jointext(docks, ",")
	if(unchanged && length(chunks) == length(radar_cache.terrain_chunks) && dock_key == radar_cache.terrain_docks)
		return radar_cache.terrain_cache
	radar_cache.terrain_chunks = chunks
	radar_cache.terrain_docks = dock_key
	for(var/list/chunk as anything in chunks)
		walls += chunk[OVERMAP_RADAR_WALL]
		frames += chunk[OVERMAP_RADAR_FRAME]
		floors += chunk[OVERMAP_RADAR_FLOOR]
	var/revision = "[UID()]:[++radar_cache.terrain_revision]"
	radar_cache.terrain_cache = list("revision" = revision, "x" = anchor[1], "y" = anchor[2], "walls" = walls, "frames" = frames, "floors" = floors, "docks" = docks)
	return radar_cache.terrain_cache
