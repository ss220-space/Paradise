/datum/controller/subsystem/overmap
	var/obj/overmap/entity/station_docking_zone/station_docking_zone

/obj/overmap/entity
	var/obj/overmap/entity/station_docking_zone/undock_zone

/obj/overmap/entity/station_docking_zone
	name = "Блюспейс-зона стыковки"
	icon_state = "event"
	overmap_kind = OVERMAP_KIND_OTHER
	project_terrain = FALSE
	movable = FALSE
	halted = TRUE
	visible_without_scanner = TRUE
	scannable = FALSE
	map_color = "#6abfff"
	overmap_hazard_immune = TRUE
	var/radius = 40

/obj/overmap/entity/station_docking_zone/add_overmap_components()
	return

/obj/overmap/entity/station_docking_zone/Destroy()
	if(SSovermap.station_docking_zone == src)
		SSovermap.station_docking_zone = null
	return ..()

/obj/overmap/entity/station_docking_zone/radar_extent()
	return list(radius * 2, radius * 2)

/obj/overmap/entity/station_docking_zone/proc/accepts_pad(obj/docking_port/stationary/pad)
	if(QDELETED(pad) || istype(pad, /obj/docking_port/stationary/transit) || istype(pad, /obj/docking_port/stationary/overmap/landing))
		return FALSE
	return SSovermap.station_entity?.dock_host?.matches_pad(pad)

/obj/overmap/entity/station_docking_zone/proc/contains_vessel(obj/overmap/entity/vessel)
	return vessel.shuttle && !vessel.overmap_pod && vessel.sector == sector && (vessel.get_world_x() - get_world_x()) ** 2 + (vessel.get_world_y() - get_world_y()) ** 2 <= radius ** 2

/obj/overmap/entity/station_docking_zone/proc/place_departure(obj/overmap/entity/vessel)
	var/list/point = list(get_world_x(), get_world_y())
	for(var/attempt in 1 to 32)
		var/angle = attempt * 137.5
		var/distance = attempt == 1 ? 0 : radius * sqrt((attempt - 1) / 31)
		point = list(get_world_x() + sin(angle) * distance, get_world_y() + cos(angle) * distance)
		var/clear = TRUE
		for(var/obj/overmap/entity/other as anything in SSovermap.flying_vessels)
			if(other == vessel || other.sector != sector)
				continue
			if((other.get_world_x() - point[1]) ** 2 + (other.get_world_y() - point[2]) ** 2 < (other.hull_radius + vessel.hull_radius + 4) ** 2)
				clear = FALSE
				break
		if(clear)
			break
	vessel.flight?.set_autopilot(FALSE, manual = FALSE)
	vessel.flight?.set_facing(0)
	vessel.speed = list(0, 0)
	vessel.set_world_position(point[1], point[2])
	vessel.local_space = null

/datum/controller/subsystem/overmap/proc/create_station_docking_zone()
	if(SSmapping.map_datum.overmap_physical_docks || station_docking_zone || !station_entity?.sector)
		return
	var/datum/overmap_sector/sector = station_entity.sector
	var/turf/home = station_entity.get_overmap_turf()
	var/span = OVERMAP_TILE_SPAN * sector.tile_travel
	var/zone_radius = span * 0.4
	for(var/ring in 1 to sector.size - 2)
		for(var/direction in GLOB.alldirs)
			var/dx = (direction & EAST) ? 1 : ((direction & WEST) ? -1 : 0)
			var/dy = (direction & NORTH) ? 1 : ((direction & SOUTH) ? -1 : 0)
			var/turf/spot = sector.get_turf_at(sector.coord_x(home) + dx * ring, sector.coord_y(home) + dy * ring)
			if(!spot || sector.turf_occupied(spot))
				continue
			var/world_x = (spot.x + dx * 0.35) * span
			var/world_y = (spot.y + dy * 0.35) * span
			var/list/box = list(world_x - zone_radius - 48, world_y - zone_radius - 48, world_x + zone_radius + 48, world_y + zone_radius + 48)
			var/clear = TRUE
			for(var/datum/overmap_bubble/space as anything in bubbles)
				if(space.static_level && space.sector == sector && regions_overlap(box, space.ensure_region()))
					clear = FALSE
					break
			if(!clear)
				continue
			for(var/obj/overmap/feature/hazard/field as anything in scatter_fields_at(sector, world_x, world_y, zone_radius + 48))
				if(length(field.nearby_scatter(world_x, world_y, zone_radius + 48)))
					clear = FALSE
					break
			if(!clear)
				continue
			station_docking_zone = new(spot)
			station_docking_zone.radius = zone_radius
			sector.add_object(station_docking_zone, spot)
			station_docking_zone.set_world_position(world_x, world_y)
			return

/obj/overmap/entity/proc/in_station_docking_zone()
	return SSovermap.station_docking_zone?.contains_vessel(src)

/obj/docking_port/mobile/proc/overmap_docking_origin(obj/docking_port/stationary/pad)
	if(SSovermap.station_docking_zone?.accepts_pad(pad) && !pad.dock_airlock && !istype(pad, /obj/docking_port/stationary/overmap))
		return list(get_turf(src), dir)
	return overmap_origin()
