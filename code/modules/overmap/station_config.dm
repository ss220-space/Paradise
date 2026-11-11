/datum/controller/subsystem/overmap/proc/configured_map_sector(id, datum/overmap_sector/fallback, label)
	if(isnull(id))
		return fallback
	var/datum/overmap_sector/chosen = sectors[id]
	if(chosen)
		return chosen
	log_world("Overmap: [label] sector '[id]' is missing or transit-only; using [fallback.id].")
	return fallback

/datum/controller/subsystem/overmap/proc/apply_overmap_map_config()
	station_sector = configured_map_sector(SSmapping.map_datum.overmap_station_sector_id, station_sector, "Station")
	local_sector = station_sector

/datum/controller/subsystem/overmap/proc/configured_station_turf(list/position)
	if(!islist(position) || length(position) != 2 || !isnum(position[1]) || !isnum(position[2]))
		log_world("Overmap: invalid station coordinates; choosing a free location.")
		return null
	if(position[1] <= OVERMAP_EDGE || position[2] <= OVERMAP_EDGE || position[1] > local_sector.size - OVERMAP_EDGE || position[2] > local_sector.size - OVERMAP_EDGE)
		log_world("Overmap: station coordinates lie outside the playable sector; choosing a free location.")
		return null
	var/turf/spot = local_sector.locate_local(round(position[1], 1), round(position[2], 1))
	if(!spot || local_sector.turf_occupied(spot))
		log_world("Overmap: configured station location is occupied; choosing a free location.")
		return null
	return spot

/datum/controller/subsystem/overmap/proc/station_planet_origin(footprint, list/position)
	var/center_x = (local_sector.size + 1) / 2
	var/center_y = center_x
	if(islist(position) && length(position) == 2 && isnum(position[1]) && isnum(position[2]))
		center_x = position[1]
		center_y = position[2]
	var/turf/best
	var/best_score = INFINITY
	for(var/x in OVERMAP_EDGE + 1 to local_sector.size - OVERMAP_EDGE - footprint + 1)
		for(var/y in OVERMAP_EDGE + 1 to local_sector.size - OVERMAP_EDGE - footprint + 1)
			var/clear = TRUE
			for(var/dx in 0 to footprint - 1)
				for(var/dy in 0 to footprint - 1)
					if(local_sector.turf_occupied(local_sector.locate_local(x + dx, y + dy)))
						clear = FALSE
			if(!clear)
				continue
			var/score = (x + (footprint - 1) / 2 - center_x) ** 2 + (y + (footprint - 1) / 2 - center_y) ** 2
			if(score < best_score)
				best_score = score
				best = local_sector.locate_local(x, y)
	return best

/datum/controller/subsystem/overmap/proc/spawn_planetary_station(datum/map/settings)
	var/footprint = isnum(settings.overmap_station_planet_footprint) ? settings.overmap_station_planet_footprint : 3
	footprint = clamp(round(footprint, 1), 1, min(8, local_sector.size - 2 * OVERMAP_EDGE))
	var/turf/origin = station_planet_origin(footprint, settings.overmap_station_position)
	if(!origin)
		log_world("Overmap: no free footprint for the main station planet; placing a space station instead.")
		return FALSE
	var/obj/overmap/planet/station_world/planet = new(origin, settings, footprint)
	local_sector.add_object(planet, origin)
	var/turf/center = local_sector.locate_local(local_sector.coord_x(origin) + round((footprint - 1) / 2), local_sector.coord_y(origin) + round((footprint - 1) / 2))
	var/obj/overmap/entity/planet_station/main_station/host = new(center)
	station_entity = host
	host.planet = planet
	planet.outpost = host
	host.status = OVERMAP_STATUS_OVERMAP
	host.apply_overmap_identity(station_name(), COLOR_WHITE, "station", FALSE, settings.overmap_station_broadcasting, null, TRUE)
	local_sector.add_object(host, center)
	return TRUE

/obj/overmap/planet/station_world/Initialize(mapload, datum/map/settings, footprint_size)
	name = settings.overmap_station_planet_name
	map_color = settings.overmap_station_planet_color
	footprint = footprint_size
	if(settings.overmap_station_planet_icon_state in icon_states(OVERMAP_PLANET_ICON_FILE))
		icon_state = settings.overmap_station_planet_icon_state
	return ..()

/obj/overmap/entity/planet_station/main_station/add_overmap_components()
	AddComponent(/datum/component/overmap_sensors)
	AddComponent(/datum/component/overmap_dock_host, OVERMAP_DOCK_Z_STATION, null, SSmapping.map_datum.overmap_station_allow_custom_landing, TRUE)

/obj/overmap/entity/station/add_overmap_components()
	AddComponent(/datum/component/overmap_sensors)
	AddComponent(/datum/component/overmap_dock_host, OVERMAP_DOCK_Z_STATION, null, SSmapping.map_datum.overmap_station_allow_custom_landing, FALSE)

/obj/overmap/entity/proc/apply_main_station_visibility()
	hidden_from_contacts = SSmapping.map_datum.overmap_station_hidden
	hidden_from_sensors = hidden_from_contacts

/obj/overmap/entity/station/sync_transponder()
	. = ..()
	apply_main_station_visibility()

/obj/overmap/entity/planet_station/main_station/sync_transponder()
	. = ..()
	apply_main_station_visibility()

/obj/overmap/entity/station/is_overmap_visible()
	return !SSmapping.map_datum.overmap_station_hidden

/obj/overmap/entity/planet_station/main_station/is_overmap_visible()
	return !SSmapping.map_datum.overmap_station_hidden

/obj/overmap/entity/station/shows_overmap_map_signature()
	return !SSmapping.map_datum.overmap_station_hidden && ..()

/obj/overmap/entity/planet_station/main_station/shows_overmap_map_signature()
	return !SSmapping.map_datum.overmap_station_hidden && ..()

/obj/overmap/planet/station_world
	desc = "TEMP123TEMP"

/obj/overmap/entity/planet_station/main_station
	desc = "TEMP123TEMP"
