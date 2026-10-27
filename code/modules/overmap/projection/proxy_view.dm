/obj/effect/abstract/hull_proxy_tile/Destroy()
	SSovermap.proxy_hud_tiles -= src
	hud_sources = null
	vis_contents.Cut()
	QDEL_LIST_ASSOC_VAL(offset_visuals)
	if(watched_source)
		UnregisterSignal(watched_source, list(COMSIG_ATOM_ENTERED, COMSIG_ATOM_EXITED, COMSIG_ATOM_AFTER_SUCCESSFUL_INITIALIZED_ON, COMSIG_ATOM_UPDATED_ICON, COMSIG_ATOM_SMOOTHED_ICON))
	watched_source = null
	for(var/atom/movable/content as anything in watched_multitile)
		UnregisterSignal(content, COMSIG_MOVABLE_MOVED)
	watched_multitile = null
	QDEL_NULL(light_mask)
	QDEL_NULL(light_backdrop)
	QDEL_NULL(shade)
	QDEL_NULL(projected_turf)
	frame = null
	hull_turf = null
	copied_light_color = null
	corner_mask = null
	return ..()

/obj/effect/abstract/hull_proxy_tile/proc/source_turf()
	return shown_turf || hull_turf

/obj/effect/abstract/hull_proxy_tile/proc/rebuild_contents()
	frame.Cut()
	hud_sources = list()
	var/list/wanted_offsets = list()
	for(var/atom/movable/content as anything in watched_multitile)
		UnregisterSignal(content, COMSIG_MOVABLE_MOVED)
	watched_multitile = null
	var/turf/source = source_turf()
	if(source)
		if(source.hud_list)
			hud_sources += source
		if(watched_source != source)
			if(watched_source)
				UnregisterSignal(watched_source, list(COMSIG_ATOM_ENTERED, COMSIG_ATOM_EXITED, COMSIG_ATOM_AFTER_SUCCESSFUL_INITIALIZED_ON, COMSIG_ATOM_UPDATED_ICON, COMSIG_ATOM_SMOOTHED_ICON))
			watched_source = source
			RegisterSignals(source, list(COMSIG_ATOM_ENTERED, COMSIG_ATOM_EXITED, COMSIG_ATOM_AFTER_SUCCESSFUL_INITIALIZED_ON), PROC_REF(on_source_contents))
			RegisterSignals(source, list(COMSIG_ATOM_UPDATED_ICON, COMSIG_ATOM_SMOOTHED_ICON), PROC_REF(on_source_icon))
		appearance_flags &= ~KEEP_TOGETHER
		SET_PLANE_EXPLICIT(src, GAME_PLANE, source)
		if(!projected_turf)
			projected_turf = new(src)
		projected_turf.hull_turf = source
		projected_turf.appearance = source.appearance
		projected_turf.name = source.name
		projected_turf.vis_flags = 0
		projected_turf.mouse_opacity = source.mouse_opacity
		frame += projected_turf
		for(var/atom/movable/content as anything in source)
			if(content.bound_width > ICON_SIZE_X || content.bound_height > ICON_SIZE_Y)
				RegisterSignal(content, COMSIG_MOVABLE_MOVED, PROC_REF(on_multitile_moved))
				LAZYADD(watched_multitile, content)
			if(content.loc == source && !(content.vis_flags & VIS_HIDE))
				frame += project_content(content, wanted_offsets)
				if(ismob(content) || content.hud_list)
					hud_sources += content
		for(var/atom/movable/content as anything in source.vis_contents)
			if(content != source.lighting_object && !(content.vis_flags & VIS_HIDE))
				frame |= project_content(content, wanted_offsets)
				if(ismob(content) || content.hud_list)
					hud_sources |= content
	for(var/atom/movable/content as anything in offset_visuals)
		if(!wanted_offsets[content])
			qdel(offset_visuals[content])
			offset_visuals -= content
	if(!QDELETED(shade))
		frame += shade
	if(lit && !QDELETED(light_mask))
		frame += light_backdrop
		frame += light_mask
	vis_contents = frame
	if(length(hud_sources))
		SSovermap.proxy_hud_tiles[src] = TRUE
	else
		SSovermap.proxy_hud_tiles -= src

/obj/effect/abstract/hull_proxy_tile/proc/on_multitile_moved()
	SIGNAL_HANDLER
	rebuild_contents()

/obj/effect/abstract/hull_proxy_tile/proc/on_source_contents(datum/source, atom/movable/changed)
	SIGNAL_HANDLER
	if(!(changed.vis_flags & VIS_HIDE))
		rebuild_contents()

/obj/effect/abstract/hull_proxy_tile/proc/on_source_icon()
	SIGNAL_HANDLER
	var/turf/source = source_turf()
	if(source && projected_turf)
		projected_turf.appearance = source.appearance
		projected_turf.name = source.name
		projected_turf.vis_flags = 0
		projected_turf.mouse_opacity = source.mouse_opacity

/obj/effect/abstract/hull_proxy_tile/projected
	mouse_opacity = MOUSE_OPACITY_OPAQUE
	vis_flags = 0

/obj/effect/abstract/hull_proxy_tile/projected/Click(location, control, params)
	var/turf/source = source_turf()
	if(!source || fog_hides_from(usr?.client, source))
		return
	if(usr)
		return usr.ClickOn(source, params, location)
	return source.Click(location, control, params)

/obj/overmap/entity/proc/masks_terrain_at(turf/spot)
	return !overmap_pod && hull_area_turfs[spot]

/obj/effect/abstract/hull_proxy_tile/proc/prepare_lighting()
	if(lit)
		copy_light()
		return
	setup_shading()

/obj/effect/abstract/hull_proxy_tile/proc/needs_light_refresh()
	return !!hull_turf?.lighting_object

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
	for(var/turf/shown as anything in tiles)
		var/obj/effect/abstract/hull_proxy_tile/tile = tiles[shown]
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
	var/list/viewports = SSovermap.scatter_viewports(vessel)
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

	for(var/turf/shown as anything in tiles.Copy())
		if(!wanted[shown])
			qdel(tiles[shown])
			tiles.Remove(shown)

	update_fog(spot, facing)
