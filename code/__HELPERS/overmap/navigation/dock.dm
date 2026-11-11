/proc/overmap_rebuild_landing_zones()
	var/list/available = list()
	var/list/pads = list()
	for(var/obj/machinery/landing_beacon/beacon as anything in GLOB.landing_beacons)
		if(!QDELETED(beacon) && isturf(beacon.loc))
			available += beacon
		if(!QDELETED(beacon.pad))
			pads |= beacon.pad
	for(var/obj/docking_port/stationary/overmap/landing/pad as anything in pads)
		var/valid = length(pad.beacon_corners) == 4
		for(var/obj/machinery/landing_beacon/corner as anything in pad.beacon_corners)
			if(QDELETED(corner) || !(corner in available) || corner.dock_name != pad.overmap_dock_label || corner.z != pad.z)
				valid = FALSE
		if(valid)
			var/list/bounds = pad.landing_bounds
			var/list/positions = list()
			for(var/obj/machinery/landing_beacon/corner as anything in pad.beacon_corners)
				if((corner.x != bounds[1] - 1 && corner.x != bounds[3] + 1) || (corner.y != bounds[2] - 1 && corner.y != bounds[4] + 1))
					valid = FALSE
				positions["[corner.x],[corner.y]"] = TRUE
			if(length(positions) != 4)
				valid = FALSE
		if(valid)
			available -= pad.beacon_corners
			continue
		for(var/obj/machinery/landing_beacon/corner as anything in pad.beacon_corners)
			if(!QDELETED(corner))
				corner.pad = null
		qdel(pad, TRUE)
	for(var/obj/machinery/landing_beacon/first as anything in available)
		if(first.pad)
			continue
		var/list/best
		var/best_area = INFINITY
		for(var/obj/machinery/landing_beacon/opposite as anything in available)
			if(opposite.pad || opposite.z != first.z || opposite.dock_name != first.dock_name || opposite.x <= first.x + 2 || opposite.y <= first.y + 2)
				continue
			var/obj/machinery/landing_beacon/second
			var/obj/machinery/landing_beacon/third
			for(var/obj/machinery/landing_beacon/corner as anything in available)
				if(corner.pad || corner.z != first.z || corner.dock_name != first.dock_name)
					continue
				if(corner.x == opposite.x && corner.y == first.y)
					second = corner
				if(corner.x == first.x && corner.y == opposite.y)
					third = corner
			var/size = (opposite.x - first.x) * (opposite.y - first.y)
			if(second && third && size < best_area)
				best = list(first, second, third, opposite)
				best_area = size
		if(!best)
			continue
		var/obj/machinery/landing_beacon/opposite = best[4]
		var/turf/center = locate(round((first.x + opposite.x) / 2), round((first.y + opposite.y) / 2), first.z)
		var/obj/docking_port/stationary/overmap/landing/pad = new(center)
		pad.landing_bounds = list(first.x + 1, first.y + 1, opposite.x - 1, opposite.y - 1)
		pad.beacon_corners = best
		pad.overmap_dock_label = first.dock_name
		pad.turf_type = center.type
		var/area/place = get_area(center)
		pad.area_type = place.type
		for(var/obj/machinery/landing_beacon/corner as anything in best)
			corner.pad = pad
		first.bind_pad_host()
