/obj/overmap/entity
	var/radar_snapshot_tick = -1
	var/radar_snapshot_epoch = -1
	var/list/radar_snapshots = list()
	var/turf/radar_docked_at
	var/radar_docked_dir
	var/radar_epoch = 0
	var/radar_transitioning = FALSE

/obj/overmap/entity/proc/fill_radar_data(list/data, reach = OVERMAP_RADAR_TERRAIN_RANGE)
	if(radar_snapshot_tick != world.time || radar_snapshot_epoch != radar_epoch)
		radar_snapshot_tick = world.time
		radar_snapshot_epoch = radar_epoch
		radar_snapshots = list()
	var/key = "[reach]"
	var/list/snapshot = radar_snapshots[key]
	if(!snapshot)
		snapshot = list()
		build_radar_data_uncached(snapshot, reach)
		radar_snapshots[key] = snapshot
	for(var/field in snapshot)
		data[field] = snapshot[field]
	if(radar_motion_frame && radar_motion_epoch == radar_epoch && radar_motion_sector == sector)
		for(var/field in radar_motion_frame)
			if(field != "objects")
				data[field] = radar_motion_frame[field]
		var/list/positions = list()
		for(var/list/entry as anything in radar_motion_frame["objects"])
			positions[entry["id"]] = entry
		var/list/objects = list()
		for(var/list/entry as anything in data["objects"])
			var/list/pose = positions[entry["id"]]
			if(pose)
				entry = entry.Copy()
				entry["x"] = pose["x"]
				entry["y"] = pose["y"]
				entry["facing"] = pose["facing"]
			objects += list(entry)
		data["objects"] = objects

/obj/overmap/entity/proc/prepare_docked_radar()
	if(!shuttle || free_flight_view || !is_physically_docked() || shuttle.transfer_busy)
		return FALSE
	if(!radar_shape || hull_dirty || radar_docked_at != get_turf(shuttle) || radar_docked_dir != shuttle.dir)
		map_hull()
		radar_docked_at = get_turf(shuttle)
		radar_docked_dir = shuttle.dir
	var/obj/overmap/entity/host = get_dock_host()
	var/datum/overmap_bubble/space = SSovermap.ensure_host_space(host)
	if(!space && shuttle.z <= length(SSovermap.bubbles_by_z))
		space = SSovermap.bubbles_by_z[shuttle.z]
	local_space = space?.static_level && space.bubble_z == shuttle.z ? space : null
	return TRUE

/obj/overmap/entity/proc/radar_world_origin()
	if(shuttle && !free_flight_view && is_physically_docked() && local_space && hull_z == local_space.bubble_z)
		return local_space.to_world(hull_center_x, hull_center_y)
	return list(get_world_x(), get_world_y())

/obj/overmap/entity/proc/radar_sector_position()
	if(!sector)
		return list(0, 0)
	var/list/origin = radar_world_origin()
	var/span = OVERMAP_TILE_SPAN * (sector?.tile_travel || 1)
	return list(origin[1] / span - sector.origin_x + 1, origin[2] / span - sector.origin_y + 1)

/obj/overmap/entity/proc/radar_extent()
	if(shuttle)
		return list(hull_radius * 2, hull_radius * 2)
	var/list/rect = physical_space?.bounds
	if(rect)
		return list(rect[3] - rect[1] + 1, rect[4] - rect[2] + 1)
	return null

/obj/overmap/entity/proc/build_radar_data_uncached(list/data, reach = OVERMAP_RADAR_TERRAIN_RANGE)
	data["radar_tick"] = SSovermap.radar_frame_time * 100
	data["radar_epoch"] = radar_epoch
	data["radar_locked"] = !!relay_jump_from
	var/docked_radar = prepare_docked_radar()
	var/turf/here = get_overmap_turf()
	data["sector_id"] = sector?.id
	data["sector_size"] = sector?.size || OVERMAP_DEFAULT_SIZE
	data["cell_span"] = OVERMAP_TILE_SPAN * (sector?.tile_travel || 1)
	data["galaxy"] = SSovermap.galaxy_map(src)
	var/list/peels = list()
	for(var/obj/overmap/entity/source in sector?.objects)
		var/own_short = source == src && short_sensors_on && has_working_sensor(OVERMAP_SENSOR_KIND_SHORT)
		var/public_long = source.long_sensors_on && source.has_working_sensor(OVERMAP_SENSOR_KIND_LONG)
		if(!own_short && !public_long)
			continue
		var/turf/spot = source.get_overmap_turf()
		if(!spot)
			continue
		peels += list(list("id" = source.UID(), "x" = sector.coord_x(spot) + source.position[1], "y" = sector.coord_y(spot) + source.position[2], "range" = public_long ? OVERMAP_SENSOR_LONG_VIEW : OVERMAP_SENSOR_SHORT_VIEW, "short" = !public_long, "age" = (world.time - (public_long ? source.sensor_peel_at : source.short_peel_at)) / (1 SECONDS), "period" = OVERMAP_SENSOR_PEEL_INTERVAL / (1 SECONDS)))
	data["radar_peels"] = peels
	data["facing"] = docked_radar ? 0 : get_facing()
	data["radar_scatter"] = radar_scatter_data()
	data["radar_shapes"] = radar_shapes()
	data["radar"] = radar_contacts()
	data["radar_drifters"] = radar_drifters()
	data["radar_projectiles"] = radar_projectiles()
	data["radar_engines"] = radar_engines()
	data["radar_terrain"] = radar_terrain(reach)
	data["radar_docks"] = free_flight_view ? radar_dock_targets() : list()
	data["dock_preview"] = null
	if(docking_approach?.update_target())
		data["dock_preview"] = list("x" = docking_approach.target_x, "y" = docking_approach.target_y, "facing" = docking_approach.target_facing, "tiles" = radar_shape?["tiles"])
	data["radar_world"] = radar_world_origin()
	if(sector && here)
		data["self_pos"] = radar_sector_position()
	var/list/objects = list()
	var/list/outlines = list()
	radar_object_sources = list()
	radar_objects_sector = sector
	var/view_range = sector?.size || OVERMAP_DEFAULT_SIZE
	var/sensor_reach = sensor_reach_cells()
	if(sector)
		for(var/obj/overmap/overmap_object as anything in sector.objects)
			var/turf/object_turf = overmap_object.get_overmap_turf()
			if(!object_turf)
				continue

			if(!isnull(here) && !sector.contains_turf(object_turf))
				continue
			if(here && max(abs(here.x - object_turf.x), abs(here.y - object_turf.y)) > view_range)
				continue
			var/is_self = overmap_object == src
			var/is_terrain = istype(overmap_object, /obj/overmap/planet) || istype(overmap_object, /obj/overmap/feature/hazard)
			var/is_vessel = istype(overmap_object, /obj/overmap/entity/shuttle) || istype(overmap_object, /obj/overmap/entity/pod)
			if(!is_self && !is_terrain)
				if(!isturf(overmap_object.loc))
					continue

				if(overmap_object.hidden_from_contacts && !is_vessel)
					continue
			var/identified = overmap_object.visible_without_scanner || display_identified(overmap_object)

			var/visibility = object_visibility(overmap_object, here, sensor_reach)
			visibility = max(visibility, is_self ? 1 : (short_knows(overmap_object) ? OVERMAP_CHART_UNSEEN_ALPHA : 0))
			if(visibility <= 0)
				continue
			var/obj/overmap/entity/contact = overmap_object
			var/is_entity = istype(contact)
			var/obj/overmap/planet/planet = overmap_object
			var/obj/overmap/entity/hyperrelay/relay = overmap_object
			if(istype(overmap_object, /obj/overmap/feature/hazard))

				continue
			var/list/entry = list(
				"id" = overmap_object.UID(),
				"name" = is_self || identified ? overmap_object.get_overmap_display_name() : OVERMAP_UNKNOWN_NAME,
				"kind" = identified || is_self ? overmap_object.overmap_kind : "unknown",
				"x" = is_self ? data["self_pos"][1] : sector.coord_x(object_turf) + overmap_object.position[1],
				"y" = is_self ? data["self_pos"][2] : sector.coord_y(object_turf) + overmap_object.position[2],
				"color" = identified ? overmap_object.map_color : "#fffffe",
				"is_self" = is_self,
				"nested" = !isturf(overmap_object.loc),
				"speed" = round(OVERMAP_DISPLAY_SPEED(overmap_object.get_speed()), 0.01),
				"heading" = overmap_object.get_heading_angle(),
				"status" = is_entity ? contact.get_helm_status_text() : overmap_object.overmap_kind,
				"distress" = is_entity && contact.identity_distress,
				"identified" = identified || is_self,
				"docked_to" = is_entity ? contact.docked_to?.name : null,
				"size" = istype(planet) ? planet.footprint : 1,
				"extent" = is_entity ? contact.radar_extent() : null,
				"facing" = is_entity && contact.free_flight_view ? contact.get_facing() : 0,
				"leads_to" = istype(relay) && relay.paired && identified ? relay.paired.sector?.name : null,
				"visibility" = visibility,
				"scanned" = identified || is_self,
			)
			objects += list(entry)
			radar_object_sources[overmap_object] = entry
			if(is_entity)
				outlines[overmap_object.UID()] = contact.radar_outline()
	data["objects"] = objects
	data["radar_outlines"] = outlines
	data["view_range"] = view_range

	var/list/hazard_fields = list()
	if(sector)
		for(var/list/group as anything in overmap_hazard_clusters(sector))
			var/obj/overmap/feature/hazard/seed = group[1]
			if(!seed)
				continue
			var/list/cells = list()
			var/list/seen_cells = list()
			var/field_visibility = 0
			var/scan_uid
			for(var/obj/overmap/feature/hazard/point as anything in group)
				var/turf/spot = point.loc
				if(!isturf(spot))
					continue
				var/point_visibility = object_visibility(point, here, sensor_reach)
				var/span = OVERMAP_TILE_SPAN * sector.tile_travel
				var/local_geometry = abs(point.x * span - get_world_x()) < span + 128 && abs(point.y * span - get_world_y()) < span + 128
				if(point_visibility <= 0 && !local_geometry)
					continue
				field_visibility = max(field_visibility, point_visibility)
				if(can_short_scan(point))
					scan_uid = point.UID()

				var/cell_key = "[sector.coord_x(spot)],[sector.coord_y(spot)]"
				if(seen_cells[cell_key])
					continue
				seen_cells[cell_key] = TRUE
				cells += list(list(sector.coord_x(spot), sector.coord_y(spot), point_visibility))
			if(!length(cells))
				continue
			hazard_fields += list(list(
				"id" = scan_uid,
				"kind" = contact_identified(seed) ? hazard_flavour(seed) : null,
				"density" = overmap_hazard_cluster_density(group),
				"cells" = cells,
				"contours" = overmap_hazard_contours(sector, group),
				"scanned" = contact_identified(seed),
				"visibility" = field_visibility,
			))
	data["hazard_fields"] = hazard_fields

/obj/overmap/entity/proc/sensor_reach_cells()
	if(has_working_sensor(OVERMAP_SENSOR_KIND_LONG) && long_sensors_on)
		return OVERMAP_SENSOR_LONG_VIEW
	if(has_working_sensor(OVERMAP_SENSOR_KIND_SHORT) && short_sensors_on)
		return OVERMAP_SENSOR_SHORT_VIEW
	return 0

/obj/overmap/entity/proc/object_visibility(obj/overmap/contact, turf/here, reach)
	if(contact == src)
		return 1
	if(contact.hidden_from_sensors)
		return 0
	if(contact.visible_without_scanner || iff_detects(contact))
		return 1
	var/turf/there = contact.get_overmap_turf()
	if(!here || !there || there.z != here.z)
		return 0
	var/visibility = short_knows(contact) ? OVERMAP_CHART_UNSEEN_ALPHA : 0
	if(reach > 0)
		var/span = OVERMAP_TILE_SPAN * (sector?.tile_travel || 1)
		var/contact_x = (there.x + contact.position[1]) * span
		var/contact_y = (there.y + contact.position[2]) * span
		var/distance = sqrt((contact_x - get_world_x()) ** 2 + (contact_y - get_world_y()) ** 2) / span
		if(distance < reach)
			visibility = max(visibility, clamp((reach - distance) / 0.5, 0, 1))
	return max(visibility, sensor_pack?.peel_alpha(contact) / 255)
