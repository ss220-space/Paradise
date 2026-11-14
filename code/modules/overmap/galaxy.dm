/datum/controller/subsystem/overmap/proc/load_galaxy_layout()
	for(var/path in list("config/overmap_galaxy.json", "config/example/overmap_galaxy.json"))
		if(!fexists(path))
			continue
		try
			var/list/layout = json_decode(file2text(path))
			if(!islist(layout) || layout["version"] != 1 || !islist(layout["systems"]) || !islist(layout["links"]))
				throw EXCEPTION("Unsupported galaxy chart format")
			if(length(layout["systems"]) > 256 || length(layout["links"]) > 256)
				throw EXCEPTION("Galaxy chart is too large")
			var/list/ids = list()
			for(var/list/entry as anything in layout["systems"])
				if(!istext(entry["id"]) || !length(entry["id"]) || ids[entry["id"]] || !isnum(entry["x"]) || !isnum(entry["y"]))
					throw EXCEPTION("Invalid or duplicate system")
				if(abs(entry["x"]) > 100000 || abs(entry["y"]) > 100000 || !istext(entry["name"]))
					throw EXCEPTION("Invalid system coordinates or label")
				if(!isnull(entry["generation"]))
					var/list/weights = entry["generation"]
					if(!islist(weights))
						throw EXCEPTION("Invalid generation weights")
					for(var/key in weights)
						if(!(key in list("hazards", "asteroids", "emp", "carp", "ruins")) || !isnum(weights[key]) || weights[key] < 0 || weights[key] > 5)
							throw EXCEPTION("Generation weights must be between zero and five")
				ids[entry["id"]] = entry
			if(!ids[OVERMAP_SECTOR_ID_STATION] || !ids[OVERMAP_SECTOR_ID_SERVICE] || !ids[OVERMAP_SECTOR_ID_WILDERNESS_A])
				throw EXCEPTION("Missing core galaxy system")
			var/list/link_ids = list()
			for(var/list/link as anything in layout["links"])
				if(!ids[link["from"]] || !ids[link["to"]] || link["from"] == link["to"] || !istext(link["id"]) || link_ids[link["id"]])
					throw EXCEPTION("Invalid galaxy link")
				link_ids[link["id"]] = TRUE
				var/list/source_entry = ids[link["from"]]
				var/list/destination_entry = ids[link["to"]]
				if(source_entry["x"] == destination_entry["x"] && source_entry["y"] == destination_entry["y"])
					throw EXCEPTION("Linked systems share coordinates")
				if(!isnull(link["waypoints"]) && !galaxy_points_valid(link["waypoints"], 0, 64))
					throw EXCEPTION("Invalid link waypoints")
			for(var/key in list("factions", "territories", "pois"))
				if(isnull(layout[key]))
					layout[key] = list()
				if(!islist(layout[key]) || length(layout[key]) > 256)
					throw EXCEPTION("Invalid galaxy annotation list")
				for(var/list/annotation as anything in layout[key])
					if(!istext(annotation["id"]) || !istext(annotation["name"]))
						throw EXCEPTION("Invalid galaxy annotation")
					if(key == "territories" && !galaxy_points_valid(annotation["points"], 3, 512))
						throw EXCEPTION("Invalid territory polygon")
					if(key == "pois" && (!isnum(annotation["x"]) || !isnum(annotation["y"])))
						throw EXCEPTION("Invalid point of interest")
			build_galaxy_routes(layout)
			return layout
		catch(var/exception/error)
			log_world("Overmap: rejected galaxy layout [path]: [error]")
	return list("version" = 1, "name" = "Межсекторная сеть", "systems" = list(
		list("id" = OVERMAP_SECTOR_ID_STATION, "name" = station_sector.name, "x" = 0, "y" = 0),
		list("id" = OVERMAP_SECTOR_ID_SERVICE, "name" = service_sector.name, "x" = -100, "y" = 0),
		list("id" = OVERMAP_SECTOR_ID_WILDERNESS_A, "name" = wilderness_sector.name, "x" = 100, "y" = 0)),
		"links" = list(list("id" = "station_service", "from" = "station", "to" = "service", "access" = "restricted"),
		list("id" = "station_wilderness", "from" = "station", "to" = "wilderness_a")))

/datum/controller/subsystem/overmap/proc/galaxy_points_valid(list/points, minimum, maximum)
	if(!islist(points) || length(points) < minimum || length(points) > maximum)
		return FALSE
	for(var/list/point as anything in points)
		if(!islist(point) || length(point) != 2 || !isnum(point[1]) || !isnum(point[2]) || abs(point[1]) > 100000 || abs(point[2]) > 100000)
			return FALSE
	return TRUE

/datum/controller/subsystem/overmap/proc/build_galaxy_routes(list/layout)
	var/list/systems = list()
	var/list/adjacent = list()
	for(var/list/entry as anything in layout["systems"])
		var/id = entry["id"]
		systems[id] = entry
		adjacent[id] = list()
		if(entry["kind"] == "transit" && (id in list(OVERMAP_SECTOR_ID_STATION, OVERMAP_SECTOR_ID_SERVICE, OVERMAP_SECTOR_ID_WILDERNESS_A)))
			throw EXCEPTION("A core sector cannot be transit-only")
	for(var/list/link as anything in layout["links"])
		var/list/source_links = adjacent[link["from"]]
		var/list/destination_links = adjacent[link["to"]]
		if(!islist(source_links) || !islist(destination_links))
			throw EXCEPTION("Unknown transit route endpoint")
		source_links += list(link)
		destination_links += list(link)
	for(var/id in systems)
		var/list/entry = systems[id]
		if(entry["kind"] == "transit" && length(adjacent[id]) != 2)
			throw EXCEPTION("Transit sector [id] must have exactly two connections")
	var/list/visited = list()
	var/list/routes = list()
	for(var/list/start as anything in layout["systems"])
		if(start["kind"] == "transit")
			continue
		for(var/list/first_link as anything in adjacent[start["id"]])
			if(visited[first_link["id"]])
				continue
			var/list/route = list("id" = first_link["id"], "from" = start["id"], "access" = "public", "state" = "active")
			var/list/points = list(list(start["x"], start["y"]))
			var/list/segments = list()
			var/list/current = start
			var/list/link = first_link
			var/distance = 0
			while(link)
				if(visited[link["id"]])
					throw EXCEPTION("Cyclic transit route")
				visited[link["id"]] = TRUE
				segments += link["id"]
				var/forward = link["from"] == current["id"]
				var/list/next = systems[forward ? link["to"] : link["from"]]
				var/list/bends = link["waypoints"]
				var/segment_start = length(points)
				for(var/i in 1 to length(bends))
					points += list(bends[forward ? i : length(bends) - i + 1])
				points += list(list(next["x"], next["y"]))
				if(isnum(link["distance"]) && link["distance"] > 0)
					distance += link["distance"]
				else
					var/segment_distance = 0
					for(var/i in segment_start to length(points) - 1)
						var/list/a = points[i]
						var/list/b = points[i + 1]
						segment_distance += sqrt((b[1] - a[1]) ** 2 + (b[2] - a[2]) ** 2)
					distance += max(1, round(segment_distance * 10))
				if(link["access"] == "restricted")
					route["access"] = "restricted"
				if(link["state"] == "closed")
					route["state"] = "closed"
				else if(link["state"] == "unstable" && route["state"] != "closed")
					route["state"] = "unstable"
				if(next["kind"] != "transit")
					if(next == start)
						throw EXCEPTION("Transit route returns to its source sector")
					route["to"] = next["id"]
					break
				var/list/options = adjacent[next["id"]]
				link = options[1] == link ? options[2] : options[1]
				current = next
			route["distance"] = max(1, distance)
			route["points"] = points
			route["waypoints"] = points.Copy(2, length(points))
			route["segments"] = segments
			routes += list(route)
	if(length(visited) != length(layout["links"]))
		throw EXCEPTION("Transit corridor has no physical endpoints")
	return routes

/datum/controller/subsystem/overmap/proc/initialize_galaxy_layout(spawn_links = TRUE)
	galaxy_layout = load_galaxy_layout()
	galaxy_systems = list()
	for(var/list/entry as anything in galaxy_layout["systems"])
		var/id = entry["id"]
		galaxy_systems[id] = entry
		if(entry["kind"] == "transit")
			continue
		var/datum/overmap_sector/sector = sectors[id]
		if(!sector)
			sector = create_galaxy_sector(entry)
			sectors[id] = sector
			sector_order |= sector
		sector.galaxy_generation = entry["generation"]
		if(islist(sector.galaxy_generation))
			if(isnum(sector.galaxy_generation["hazards"]))
				sector.hazard_spawn_weight = sector.galaxy_generation["hazards"]
			if(isnum(sector.galaxy_generation["ruins"]))
				sector.ruin_spawn_weight = sector.galaxy_generation["ruins"]
		sector.name = entry["name"] || sector.name
		sector.map_area.name = "Overmap - [sector.name]"
	if(spawn_links)
		spawn_galaxy_relays()

/datum/controller/subsystem/overmap/proc/spawn_galaxy_relays()
	for(var/list/link as anything in build_galaxy_routes(galaxy_layout))
		spawn_galaxy_link(link)
	bump_galaxy()

/datum/controller/subsystem/overmap/proc/create_galaxy_sector(list/entry)
	if(entry["kind"] == "transit")
		return null
	var/datum/overmap_sector/sector = new(entry["id"], entry["name"], station_sector.size)
	sector.sector_kind = entry["kind"] || OVERMAP_SECTOR_KIND_WILDERNESS
	return sector

/datum/controller/subsystem/overmap/proc/galaxy_positions()
	if(galaxy_positions)
		return galaxy_positions
	galaxy_positions = list()
	for(var/id, record in galaxy_systems)
		var/list/entry = record
		galaxy_positions[id] = list(entry["x"], entry["y"])
	return galaxy_positions

/datum/controller/subsystem/overmap/proc/bump_galaxy()
	galaxy_revision++
	galaxy_positions = null

/datum/controller/subsystem/overmap/proc/pick_galaxy_relay_turf(datum/overmap_sector/sector, dx, dy, obj/overmap/entity/hyperrelay/ignore_relay, list/reserved)
	var/low = OVERMAP_EDGE + 1
	var/high = sector.size - OVERMAP_EDGE
	var/center = (low + high) / 2
	var/factor = (high - low) / 2 / max(abs(dx), abs(dy), 0.001)
	var/want_x = center + dx * factor
	var/want_y = center + dy * factor
	var/turf/best
	var/score = INFINITY
	for(var/local_x in low to high)
		for(var/local_y in low to high)
			if(local_x != low && local_x != high && local_y != low && local_y != high)
				continue
			var/turf/spot = sector.locate_local(local_x, local_y)
			if(!spot || (sector.turf_occupied(spot) && spot != get_turf(ignore_relay)) || (reserved && spot in reserved))
				continue
			var/blocked = FALSE
			for(var/obj/overmap/entity/hyperrelay/nearby in range(1, spot))
				if(nearby != ignore_relay)
					blocked = TRUE
			for(var/turf/planned as anything in reserved)
				if(planned.z == spot.z && get_dist(planned, spot) <= 1)
					blocked = TRUE
			if(blocked)
				continue
			var/distance = (local_x - want_x) ** 2 + (local_y - want_y) ** 2
			if(distance < score)
				score = distance
				best = spot
	return best

/datum/controller/subsystem/overmap/proc/spawn_galaxy_link(list/link)
	var/datum/overmap_sector/source = sectors[link["from"]]
	var/datum/overmap_sector/destination = sectors[link["to"]]
	if(!source || !destination)
		return
	var/list/a = galaxy_positions()[source.id]
	var/list/b = galaxy_positions()[destination.id]
	var/list/waypoints = link["waypoints"]
	var/list/first = length(waypoints) ? waypoints[1] : b
	var/list/last = length(waypoints) ? waypoints[length(waypoints)] : a
	var/dx_a = first[1] - a[1]
	var/dy_a = first[2] - a[2]
	var/dx_b = last[1] - b[1]
	var/dy_b = last[2] - b[2]
	if(!dx_a && !dy_a)
		dx_a = b[1] - a[1]
		dy_a = b[2] - a[2]
	if(!dx_b && !dy_b)
		dx_b = a[1] - b[1]
		dy_b = a[2] - b[2]
	var/turf/a_spot = pick_galaxy_relay_turf(source, dx_a, dy_a)
	var/turf/b_spot = pick_galaxy_relay_turf(destination, dx_b, dy_b)
	if(!a_spot || !b_spot)
		log_world("Overmap: no free edge position for galaxy link [link["id"]].")
		return
	var/relay_type = link["access"] == "restricted" ? /obj/overmap/entity/hyperrelay : /obj/overmap/entity/hyperrelay/public
	var/obj/overmap/entity/hyperrelay/a_relay = new relay_type(a_spot)
	var/obj/overmap/entity/hyperrelay/b_relay = new relay_type(b_spot)
	a_relay.pair_id = link["id"]
	b_relay.pair_id = link["id"]
	a_relay.paired = b_relay
	b_relay.paired = a_relay
	var/distance = link["distance"] || round(sqrt((b[1] - a[1]) ** 2 + (b[2] - a[2]) ** 2) * 10)
	a_relay.link_distance = max(1, distance)
	b_relay.link_distance = a_relay.link_distance
	a_relay.galaxy_route_points = link["points"]
	if(length(a_relay.galaxy_route_points))
		b_relay.galaxy_route_points = list()
		for(var/i in length(a_relay.galaxy_route_points) to 1 step -1)
			b_relay.galaxy_route_points += list(a_relay.galaxy_route_points[i])
	source.add_object(a_relay, a_spot)
	destination.add_object(b_relay, b_spot)
	a_relay.update_destination_name()
	b_relay.update_destination_name()
	a_relay.orient_to_sector_edge()
	b_relay.orient_to_sector_edge()
	a_relay.set_enabled(link["state"] != "closed")
	b_relay.set_enabled(link["state"] != "closed")
	return list(a_relay, b_relay)

/datum/controller/subsystem/overmap/proc/sector_neighbours(datum/overmap_sector/sector)
	. = list()
	if(!sector)
		return
	for(var/obj/overmap/entity/hyperrelay/relay in sector.objects)
		var/datum/overmap_sector/other = relay.paired?.sector
		if(other && other != sector && !(other in .))
			. += other

/datum/controller/subsystem/overmap/proc/galaxy_map(obj/overmap/entity/viewer)
	if(galaxy_snapshot_tick != world.time || galaxy_snapshot_revision != galaxy_revision)
		galaxy_snapshot = build_galaxy_map()
		galaxy_snapshot_tick = world.time
		galaxy_snapshot_revision = galaxy_revision
	if(!viewer)
		return galaxy_snapshot
	. = galaxy_snapshot.Copy()
	var/list/signals = list()
	for(var/obj/overmap/entity/hyperrelay/relay in viewer.sector?.objects)
		if(relay.enabled && relay.paired?.sector && viewer.iff_detects(relay))
			signals |= relay.paired.sector.id
	var/list/sector_data = list()
	for(var/list/entry as anything in galaxy_snapshot["sectors"])
		var/list/personal = entry.Copy()
		personal["signal_links"] = entry["id"] == viewer.sector?.id ? signals : list()
		sector_data += list(personal)
	.["sectors"] = sector_data
	var/list/transits = list()
	for(var/list/entry as anything in galaxy_snapshot["transits"])
		var/list/personal = entry.Copy()
		personal["own"] = entry["id"] == viewer.UID()
		transits += list(personal)
	.["transits"] = transits

/datum/controller/subsystem/overmap/proc/build_galaxy_map()
	. = list("revision" = galaxy_revision, "center" = station_sector?.id, "sectors" = list(), "transits" = list(),
		"name" = galaxy_layout?["name"], "units" = galaxy_layout?["units"],
		"factions" = galaxy_layout?["factions"] || list(), "territories" = galaxy_layout?["territories"] || list(),
		"links" = galaxy_layout?["links"] || list(), "pois" = galaxy_layout?["pois"] || list())
	var/list/positions = galaxy_positions()
	for(var/id in galaxy_systems)
		var/list/entry = galaxy_systems[id]
		if(entry["kind"] != "transit")
			continue
		var/list/neighbours = list()
		for(var/list/link as anything in galaxy_layout["links"])
			if(link["from"] == id)
				neighbours |= link["to"]
			else if(link["to"] == id)
				neighbours |= link["from"]
		.["sectors"] += list(list("id" = id, "name" = entry["name"], "kind" = "transit", "x" = entry["x"], "y" = entry["y"],
			"faction" = entry["faction"], "description" = entry["description"], "marker" = entry["marker"],
			"links" = neighbours, "signal_links" = list(), "contacts" = 0, "distress" = FALSE))
	for(var/datum/overmap_sector/sector as anything in sector_order)
		var/list/spot = positions[sector.id]
		if(!spot)
			continue
		var/list/entry = galaxy_systems[sector.id]
		var/list/links = list()
		var/list/signals = list()
		var/list/distances = list()
		for(var/obj/overmap/entity/hyperrelay/relay in sector.objects)
			if(!relay.paired?.sector)
				continue
			var/id = relay.paired.sector.id
			links |= id
			distances[id] = relay.get_link_distance()
			if(relay.enabled)
				signals |= id
		var/contacts = 0
		var/distress = FALSE
		for(var/obj/overmap/entity/vessel in sector.objects)
			contacts++
			distress ||= vessel.identity_distress
		.["sectors"] += list(list("id" = sector.id, "name" = sector.name, "kind" = entry?["kind"] || sector.sector_kind,
			"x" = spot[1], "y" = spot[2], "faction" = entry?["faction"], "description" = entry?["description"],
			"marker" = entry?["marker"], "generation" = entry?["generation"],
			"size" = sector.size, "cell_span" = OVERMAP_TILE_SPAN * sector.tile_travel,
			"links" = links, "signal_links" = signals, "distances" = distances, "contacts" = contacts, "distress" = distress))
	for(var/obj/overmap/entity/vessel as anything in vessels)
		var/obj/overmap/entity/hyperrelay/relay = vessel.relay_jump_from
		if(!relay?.paired?.sector || vessel.relay_jump_ends <= world.time)
			continue
		.["transits"] += list(list("id" = vessel.UID(), "from" = relay.sector.id, "to" = relay.paired.sector.id,
			"path" = relay.galaxy_route_points,
			"progress" = clamp((world.time - vessel.relay_jump_started) / max(1, vessel.relay_jump_ends - vessel.relay_jump_started), 0, 1),
			"remaining" = (vessel.relay_jump_ends - world.time) * 100, "own" = FALSE))
