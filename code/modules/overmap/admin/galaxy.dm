/datum/controller/subsystem/overmap/proc/galaxy_route_busy(obj/overmap/entity/hyperrelay/relay)
	for(var/obj/overmap/entity/vessel as anything in vessels)
		if(vessel.relay_jump_from == relay || vessel.relay_jump_from == relay.paired || vessel.relay_capture?.portal?.relay == relay || vessel.relay_capture?.portal?.relay == relay.paired)
			return TRUE
	for(var/atom/movable/thing as anything in relay_drifter_captures)
		var/datum/overmap_relay_drifter_capture/capture = relay_drifter_captures[thing]
		if(capture.portal?.relay == relay || capture.portal?.relay == relay.paired)
			return TRUE
	return FALSE

/datum/controller/subsystem/overmap/proc/move_galaxy_system(list/entry, x, y)
	var/old_x = entry["x"]
	var/old_y = entry["y"]
	entry["x"] = x
	entry["y"] = y
	var/list/plans = list()
	var/list/reserved = list()
	try
		for(var/list/route as anything in build_galaxy_routes(galaxy_layout))
			if(route["from"] != entry["id"] && route["to"] != entry["id"])
				continue
			var/datum/overmap_sector/source = sectors[route["from"]]
			var/datum/overmap_sector/destination = sectors[route["to"]]
			var/obj/overmap/entity/hyperrelay/a_relay
			for(var/obj/overmap/entity/hyperrelay/relay in source.objects)
				if(relay.pair_id == route["id"] && relay.paired)
					a_relay = relay
					break
			if(!a_relay)
				continue
			if(galaxy_route_busy(a_relay))
				throw EXCEPTION("По связанному маршруту идёт перелёт. Дождитесь его завершения.")
			var/obj/overmap/entity/hyperrelay/b_relay = a_relay.paired
			var/list/points = route["points"]
			var/list/a = points[1]
			var/list/b = points[length(points)]
			var/list/next = points[2]
			var/list/previous = points[length(points) - 1]
			var/dx_a = next[1] - a[1]
			var/dy_a = next[2] - a[2]
			var/dx_b = previous[1] - b[1]
			var/dy_b = previous[2] - b[2]
			if(!dx_a && !dy_a)
				dx_a = b[1] - a[1]
				dy_a = b[2] - a[2]
			if(!dx_b && !dy_b)
				dx_b = a[1] - b[1]
				dy_b = a[2] - b[2]
			var/turf/a_spot = pick_galaxy_relay_turf(source, dx_a, dy_a, a_relay, reserved)
			var/turf/b_spot = pick_galaxy_relay_turf(destination, dx_b, dy_b, b_relay, reserved)
			if(!a_spot || !b_spot)
				throw EXCEPTION("Недостаточно свободного места для переноса гипертрансляторов.")
			reserved |= a_spot
			reserved |= b_spot
			plans += list(list(a_relay, b_relay, a_spot, b_spot, route))
	catch(var/exception/error)
		entry["x"] = old_x
		entry["y"] = old_y
		throw error
	for(var/list/plan as anything in plans)
		var/obj/overmap/entity/hyperrelay/a_relay = plan[1]
		var/obj/overmap/entity/hyperrelay/b_relay = plan[2]
		var/list/route = plan[5]
		a_relay.forceMove(plan[3])
		b_relay.forceMove(plan[4])
		a_relay.position = list(0, 0)
		b_relay.position = list(0, 0)
		a_relay.link_distance = route["distance"]
		b_relay.link_distance = route["distance"]
		a_relay.galaxy_route_points = route["points"]
		b_relay.galaxy_route_points = list()
		for(var/i in length(a_relay.galaxy_route_points) to 1 step -1)
			b_relay.galaxy_route_points += list(a_relay.galaxy_route_points[i])
		a_relay.orient_to_sector_edge()
		b_relay.orient_to_sector_edge()
	galaxy_positions = null
