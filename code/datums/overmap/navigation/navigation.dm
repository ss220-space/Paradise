/datum/overmap_bubble/proc/navigation_box()
	if(world.time < navigation_extent_until)
		return navigation_extent
	var/min_x = bounds[3] + 1
	var/min_y = bounds[4] + 1
	var/max_x = bounds[1] - 1
	var/max_y = bounds[2] - 1
	for(var/chunk_x in FLOOR(bounds[1] / OVERMAP_RADAR_CHUNK, 1) to FLOOR(bounds[3] / OVERMAP_RADAR_CHUNK, 1))
		for(var/chunk_y in FLOOR(bounds[2] / OVERMAP_RADAR_CHUNK, 1) to FLOOR(bounds[4] / OVERMAP_RADAR_CHUNK, 1))
			var/list/chunk = terrain_chunk(chunk_x, chunk_y)
			for(var/index in 2 to length(chunk))
				var/turf/tile = chunk[index]
				if(!is_solid(tile))
					continue
				min_x = min(min_x, tile.x)
				min_y = min(min_y, tile.y)
				max_x = max(max_x, tile.x)
				max_y = max(max_y, tile.y)
			CHECK_TICK
	navigation_extent = null
	if(min_x <= max_x && min_y <= max_y)
		var/list/low = to_world(min_x - 0.5, min_y - 0.5)
		var/list/high = to_world(max_x + 0.5, max_y + 0.5)
		navigation_extent = list(low[1], low[2], high[1], high[2])
	navigation_extent_until = world.time + (30 SECONDS)
	return navigation_extent

/datum/overmap_navigation
	var/datum/component/overmap_flight/flight
	var/list/path
	var/next_plan = 0
	var/planning = FALSE
	var/revision = 0
	var/blocked = FALSE
	var/blocked_since
	var/force_passage = FALSE
	var/list/goal
	var/path_precision = 2
	var/obj/overmap/entity/corridor_host

/datum/overmap_navigation/New(datum/component/overmap_flight/owner)
	flight = owner

/datum/overmap_navigation/Destroy()
	revision++
	flight = null
	path = null
	corridor_host = null
	return ..()

/datum/overmap_navigation/proc/reset()
	revision++
	path = null
	goal = null
	next_plan = 0
	planning = FALSE
	blocked = FALSE
	blocked_since = null
	force_passage = FALSE

/datum/overmap_navigation/proc/waypoint(world_x, world_y, obj/overmap/entity/host)
	var/obj/overmap/entity/vessel = flight.parent
	var/list/entry_box = flight.navigation_entry_box
	if(!goal || abs(goal[1] - world_x) + abs(goal[2] - world_y) > 4 || corridor_host != host)
		reset()
		goal = list(world_x, world_y)
		corridor_host = host
	if(!length(path) && isnull(blocked_since))
		blocked_since = world.time
	if(!isnull(blocked_since) && world.time >= blocked_since + (15 SECONDS) && vessel.navigation_collision_disabled())
		revision++
		planning = FALSE
		force_passage = TRUE
		blocked_since = null
		path = entry_box ? null : list(list(world_x, world_y))
		next_plan = 0
	if(force_passage && !entry_box)
		return list(world_x, world_y)
	if(!planning && world.time >= next_plan)
		plan(revision, list(vessel.get_world_x(), vessel.get_world_y()), goal.Copy(), host)
	if(!length(path))
		return null
	while(length(path) > 1)
		var/list/point = path[1]
		if((point[1] - vessel.get_world_x()) ** 2 + (point[2] - vessel.get_world_y()) ** 2 > path_precision ** 2)
			break
		path.Cut(1, 2)
	return length(path) == 1 ? list(world_x, world_y) : path[1]

/datum/overmap_navigation/proc/plan(version, list/start, list/finish, obj/overmap/entity/host)
	set waitfor = FALSE
	planning = TRUE
	var/obj/overmap/entity/vessel = flight.parent
	var/datum/overmap_sector/sector = vessel.sector
	var/list/boxes = list()
	var/list/entry_box = flight.navigation_entry_box
	if(entry_box)
		boxes += list(entry_box)
	var/span = OVERMAP_TILE_SPAN * sector.tile_travel
	for(var/obj/overmap/entity/obstacle in sector.objects)
		if(force_passage && entry_box)
			break
		if(QDELETED(src) || QDELETED(vessel) || revision != version)
			return
		if(obstacle == vessel || obstacle == host || obstacle.docked_ship == vessel || !isturf(obstacle.loc) || obstacle.dock_host?.planet_landing || !obstacle.project_terrain)
			continue
		if(flight.navigation_known_obstacles_only && !vessel.iff_detects(obstacle) && !obstacle.visible_without_scanner && vessel.object_visibility(obstacle, vessel.get_overmap_turf(), vessel.sensor_reach_cells()) <= OVERMAP_CHART_UNSEEN_ALPHA)
			continue
		var/list/box = obstacle.physical_space?.navigation_box() || obstacle.sector_obstacle_box(span)
		if(QDELETED(src) || QDELETED(vessel) || revision != version)
			return
		if(!box && obstacle.shuttle)
			box = list(obstacle.get_world_x() - obstacle.hull_radius, obstacle.get_world_y() - obstacle.hull_radius, obstacle.get_world_x() + obstacle.hull_radius, obstacle.get_world_y() + obstacle.hull_radius)
		if(box)
			box = list(box[1] - vessel.hull_radius - 2, box[2] - vessel.hull_radius - 2, box[3] + vessel.hull_radius + 2, box[4] + vessel.hull_radius + 2)
			boxes += list(box)
		CHECK_TICK
	for(var/list/cluster as anything in overmap_hazard_clusters(sector))
		if(force_passage && entry_box)
			break
		var/list/box
		for(var/obj/overmap/feature/hazard/field as anything in cluster)
			if(flight.navigation_known_obstacles_only && vessel.object_visibility(field, vessel.get_overmap_turf(), vessel.sensor_reach_cells()) <= OVERMAP_CHART_UNSEEN_ALPHA)
				continue
			var/list/field_box = list((field.x - 0.5) * span, (field.y - 0.5) * span, (field.x + 0.5) * span, (field.y + 0.5) * span)
			if(!box)
				box = field_box
			else
				box = list(min(box[1], field_box[1]), min(box[2], field_box[2]), max(box[3], field_box[3]), max(box[4], field_box[4]))
		if(box && !overmap_nav_inside(start, box) && !overmap_nav_inside(finish, box))
			boxes += list(list(box[1] - vessel.hull_radius - 2, box[2] - vessel.hull_radius - 2, box[3] + vessel.hull_radius + 2, box[4] + vessel.hull_radius + 2))
	var/list/limits = list((sector.origin_x + 0.5) * span + vessel.hull_radius, (sector.origin_y + 0.5) * span + vessel.hull_radius, (sector.origin_x + sector.size - 1.5) * span - vessel.hull_radius, (sector.origin_y + sector.size - 1.5) * span - vessel.hull_radius)
	var/list/result
	var/precision = 2
	if(host?.physical_space && !entry_box)
		var/datum/overmap_navigation_grid/grid = new(src, host.physical_space, boxes, limits, finish)
		result = grid.find_path(start)
		precision = 0.5
		qdel(grid)
	else
		result = overmap_navigation_path(start, finish, boxes, limits)
	if(QDELETED(src) || version != revision || QDELETED(flight) || vessel.sector != sector)
		return
	path = result
	path_precision = precision
	blocked = !length(path)
	if(blocked)
		if(isnull(blocked_since))
			blocked_since = world.time
	else
		blocked_since = null
	planning = FALSE
	next_plan = world.time + (2 SECONDS)
