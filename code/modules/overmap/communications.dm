/datum/controller/subsystem/overmap/proc/spatial_position(atom/source)
	var/turf/spot = get_turf(source)
	if(!initialized || !spot)
		return null
	var/datum/owner = frame_owner(spot)
	if(owner)
		var/datum/overmap_sector/sector = frame_sector(owner)
		if(QDELETED(sector))
			return null
		var/list/point = frame_to_world(owner, spot)
		return list(sector, point[1], point[2], owner)
	var/obj/overmap/entity/host = resolve_vessel(spot)
	if(!host?.sector)
		return null
	var/datum/overmap_bubble/space = host.physical_space
	var/list/point = space ? space.to_world(spot.x, spot.y) : list(host.get_world_x(), host.get_world_y())
	return list(host.sector, point[1], point[2], host)

/obj/machinery/tcomms/core
	var/coverage_tick = -1
	var/list/coverage_nodes = list()

/obj/machinery/tcomms/core/proc/position_reachable(turf/position)
	if(!position || !active || (stat & (NOPOWER|BROKEN)) || ion)
		return FALSE
	var/list/target = SSovermap.spatial_position(position)
	if(!target)
		if(SSmapping.used_turfs[position])
			return FALSE
		return zlevel_reachable(position.z)
	if(coverage_tick != world.time)
		coverage_tick = world.time
		coverage_nodes = list()
		for(var/obj/machinery/tcomms/node as anything in list(src) + linked_relays)
			var/list/point = SSovermap.spatial_position(node)
			if(point)
				coverage_nodes += list(list(node, point))
	for(var/list/entry as anything in coverage_nodes)
		var/obj/machinery/tcomms/node = entry[1]
		if(QDELETED(node) || !node.active || (node.stat & (NOPOWER|BROKEN)) || node.ion)
			continue
		var/list/point = entry[2]
		if(point[1] != target[1])
			continue
		var/datum/overmap_sector/sector = point[1]
		if(QDELETED(sector))
			continue
		var/reach = 2 * OVERMAP_TILE_SPAN * sector.tile_travel
		if((target[2] - point[2]) ** 2 + (target[3] - point[3]) ** 2 <= reach ** 2)
			return TRUE
	return FALSE
