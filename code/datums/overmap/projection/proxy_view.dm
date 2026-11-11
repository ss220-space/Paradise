/datum/terrain_mirror
	var/obj/overmap/entity/vessel
	var/datum/overmap_bubble/local_space
	var/turf/viewer_turf
	var/list/tiles = list()
	var/last_x
	var/last_y
	var/last_turned_facing

	var/datum/fog_scene/station/fog

/datum/terrain_mirror/New(obj/overmap/entity/vessel, datum/overmap_bubble/local_space)
	src.vessel = vessel
	src.local_space = local_space
	viewer_turf = locate(round(vessel.hull_center_x), round(vessel.hull_center_y), vessel.hull_z)
	fog = new /datum/fog_scene/station(vessel)
	addtimer(CALLBACK(src, PROC_REF(refresh_light_copies)), 1 SECONDS, TIMER_LOOP|TIMER_DELETE_ME)

/datum/terrain_mirror/Destroy(force)
	for(var/turf/shown as anything in tiles)
		qdel(tiles[shown])
	tiles.Cut()

	QDEL_NULL(fog)
	vessel = null
	local_space = null
	viewer_turf = null
	return ..()

/datum/terrain_mirror/proc/refresh_light_copies()
	for(var/shown_entry, tile_entry in tiles)
		var/obj/effect/abstract/hull_proxy_tile/tile = tile_entry
		if(tile.needs_light_refresh())
			tile.copy_light()

/datum/terrain_mirror/proc/mirror_radius()
	return round(vessel.hull_radius + OVERMAP_TERRAIN_VIEW_RANGE)

/datum/terrain_mirror/proc/update_fog(list/spot, facing)
	if(!fog)
		return

	fog.set_frame(overmap_fog_anchor(vessel.hull_center_x, vessel.hull_center_y, vessel.hull_z), spot[1], spot[2], vessel.hull_center_x, vessel.hull_center_y, facing)
	fog.drawn = tiles

	fog.reach = mirror_radius() + round(vessel.hull_radius) + 2
	fog.client_eyes = SSovermap.client_eyes
	fog.refresh()

/datum/terrain_mirror/proc/update(elapsed)
	var/list/spot = local_space.to_bubble(vessel.get_world_x(), vessel.get_world_y())
	var/facing = vessel.get_facing()
	var/ship_moved = spot[1] != last_x || spot[2] != last_y
	if(ship_moved)
		last_x = spot[1]
		last_y = spot[2]
	var/matrix/turned = matrix()
	turned.Scale(OVERMAP_TERRAIN_SEAM_SCALE)
	turned.Turn(-facing)
	var/turned_changed = facing != last_turned_facing
	last_turned_facing = facing
	var/radius = mirror_radius()
	var/cos_facing = cos(facing)
	var/sin_facing = sin(facing)
	var/list/viewports = SSovermap.frame_viewports(vessel)
	var/center_x = round(spot[1], 1)
	var/center_y = round(spot[2], 1)
	var/list/wanted = list()

	var/list/chunks = list()
	for(var/list/viewport as anything in viewports)
		var/turf/eye = viewport[1]
		var/dx = eye.x - vessel.hull_center_x
		var/dy = eye.y - vessel.hull_center_y
		var/source_x = spot[1] + dx * cos_facing + dy * sin_facing
		var/source_y = spot[2] + dy * cos_facing - dx * sin_facing
		var/source_reach = viewport[2] * (abs(cos_facing) + abs(sin_facing)) + 2
		for(var/chunk_x in max(FLOOR((source_x - source_reach) / OVERMAP_RADAR_CHUNK, 1), 0) to FLOOR(min(source_x + source_reach, world.maxx) / OVERMAP_RADAR_CHUNK, 1))
			for(var/chunk_y in max(FLOOR((source_y - source_reach) / OVERMAP_RADAR_CHUNK, 1), 0) to FLOOR(min(source_y + source_reach, world.maxy) / OVERMAP_RADAR_CHUNK, 1))
				chunks["[chunk_x],[chunk_y]"] = list(chunk_x, chunk_y)
	for(var/key in chunks)
		var/list/coordinates = chunks[key]
		var/list/chunk = local_space.terrain_chunk(coordinates[1], coordinates[2])
		for(var/index in 2 to length(chunk))
			var/turf/shown = chunk[index]
			var/delta_x = shown.x - center_x
			var/delta_y = shown.y - center_y

			if(delta_x * delta_x + delta_y * delta_y > radius * radius)
				continue

			var/hull_x = vessel.hull_center_x + (shown.x - spot[1]) * cos_facing - (shown.y - spot[2]) * sin_facing
			var/hull_y = vessel.hull_center_y + (shown.x - spot[1]) * sin_facing + (shown.y - spot[2]) * cos_facing
			var/visible = FALSE
			for(var/list/viewport as anything in viewports)
				var/turf/eye = viewport[1]
				if(abs(hull_x - eye.x) <= viewport[2] && abs(hull_y - eye.y) <= viewport[2])
					visible = TRUE
					break
			if(!visible)
				continue
			var/turf/hull_turf = locate(FLOOR(hull_x + 0.5, 1), FLOOR(hull_y + 0.5, 1), vessel.hull_z)
			if(vessel.masks_terrain_at(hull_turf))
				continue
			wanted[shown] = TRUE
			var/obj/effect/abstract/hull_proxy_tile/tile = tiles[shown]
			var/fresh = !tile
			if(fresh)
				tile = new(null)
				tile.hull_turf = shown
				tile.shown_turf = shown
				tile.frame_turf = viewer_turf
				tile.prepare_lighting()
				tiles[shown] = tile

			if(fresh || ship_moved || turned_changed)
				tile.glide(hull_x, hull_y, vessel.hull_z, (fresh || turned_changed) ? turned : null, vessel.flight_bounds, fresh ? 0 : elapsed)

	for(var/turf/shown as anything in tiles)
		if(!wanted[shown])
			qdel(tiles[shown])
			tiles.Remove(shown)

	update_fog(spot, facing)
