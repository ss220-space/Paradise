/datum/overmap_bubble/planet_surface
	orbital = FALSE
	var/list/view_chunks = list()

/datum/component/overmap_dock_host/proc/planet_surface(level)
	RETURN_TYPE(/datum/overmap_bubble/planet_surface)
	if(!planet_landing || !allows_landing_z(level))
		return null
	var/key = "[level]"
	var/datum/overmap_bubble/planet_surface/surface = LAZYACCESS(surfaces, key)
	if(!surface)
		var/obj/overmap/entity/planet = parent
		surface = new(planet.sector, planet.get_world_x(), planet.get_world_y(), 0, 0)
		surface.host = planet
		surface.fill_level(level)
		surface.bounds = list(1, 1, world.maxx, world.maxy)
		LAZYSET(surfaces, key, surface)
	return surface

/datum/overmap_atmosphere
	var/obj/overmap/entity/vessel
	var/datum/overmap_bubble/planet_surface/surface
	var/world_x
	var/world_y
	var/start_scale
	var/end_scale
	var/transition_end
	var/list/limits
	var/obj/effect/abstract/shuttle_shadow/shadow

/datum/overmap_atmosphere/New(obj/overmap/entity/owner, datum/overmap_bubble/planet_surface/ground, from_scale)
	vessel = owner
	surface = ground
	RegisterSignal(surface, COMSIG_QDELETING, PROC_REF(on_surface_deleted))
	start_scale = from_scale
	end_scale = OVERMAP_ATMOSPHERE_SCALE
	transition_end = world.time + OVERMAP_ATMOSPHERE_TRANSITION

/datum/overmap_atmosphere/Destroy()
	UnregisterSignal(surface, COMSIG_QDELETING)
	if(vessel?.atmosphere == src)
		vessel.atmosphere = null
		vessel.local_space = null
		QDEL_NULL(vessel.terrain_view)
	QDEL_NULL(shadow)
	vessel = null
	surface = null
	return ..()

/datum/overmap_atmosphere/proc/on_surface_deleted()
	SIGNAL_HANDLER
	qdel(src)

/datum/overmap_atmosphere/proc/cruising()
	return end_scale == OVERMAP_ATMOSPHERE_SCALE && world.time >= transition_end

/datum/overmap_atmosphere/proc/scale()
	var/remaining = max(transition_end - world.time, 0) / OVERMAP_ATMOSPHERE_TRANSITION
	return end_scale + (start_scale - end_scale) * remaining

/datum/overmap_atmosphere/proc/change_altitude(target)
	start_scale = scale()
	end_scale = target
	transition_end = world.time + OVERMAP_ATMOSPHERE_TRANSITION

/datum/overmap_atmosphere/proc/update_limits()
	if(limits)
		return
	var/list/origin = surface.to_world(0, 0)
	limits = list(origin[1] + 1 + OVERMAP_ATMOSPHERE_EDGE, origin[2] + 1 + OVERMAP_ATMOSPHERE_EDGE, origin[1] + world.maxx - OVERMAP_ATMOSPHERE_EDGE, origin[2] + world.maxy - OVERMAP_ATMOSPHERE_EDGE)

/datum/overmap_atmosphere/proc/can_reach(x, y)
	update_limits()
	return x >= limits[1] && y >= limits[2] && x <= limits[3] && y <= limits[4]

/datum/overmap_atmosphere/proc/set_position(x, y)
	update_limits()
	world_x = clamp(x, limits[1], limits[3])
	world_y = clamp(y, limits[2], limits[4])
	if(world_x != x)
		vessel.speed[1] = 0
	if(world_y != y)
		vessel.speed[2] = 0

/datum/overmap_surface_chunk
	var/datum/overmap_bubble/planet_surface/surface
	var/key
	var/center_x
	var/center_y
	var/list/turfs
	var/list/watched = list()
	var/list/layers
	var/list/lights
	var/users = 0

/datum/overmap_surface_chunk/New(datum/overmap_bubble/planet_surface/ground, chunk_x, chunk_y)
	surface = ground
	key = "[chunk_x],[chunk_y]"
	surface.view_chunks[key] = src
	RegisterSignals(SSdcs, list(COMSIG_STARLIGHT_COLOR_CHANGED, COMSIG_GLOB_AREA_BASE_LIGHTING_CHANGED), PROC_REF(light_changed))
	var/x = chunk_x * OVERMAP_SURFACE_CHUNK + 1
	var/y = chunk_y * OVERMAP_SURFACE_CHUNK + 1
	center_x = x + OVERMAP_SURFACE_CHUNK / 2
	center_y = y + OVERMAP_SURFACE_CHUNK / 2
	turfs = block(locate(x, y, ground.bubble_z), locate(min(x + OVERMAP_SURFACE_CHUNK - 1, world.maxx), min(y + OVERMAP_SURFACE_CHUNK - 1, world.maxy), ground.bubble_z))
	var/static/list/appearance_signals = list(COMSIG_TURF_CHANGE, COMSIG_TURF_EXPOSURE_CHANGED, COMSIG_ATOM_UPDATED_ICON, COMSIG_ATOM_SMOOTHED_ICON)
	var/static/list/contents_signals = list(COMSIG_ATOM_ENTERED, COMSIG_ATOM_EXITED, COMSIG_ATOM_AFTER_SUCCESSFUL_INITIALIZED_ON)
	for(var/turf/spot as anything in turfs)
		RegisterSignal(spot, COMSIG_TURF_LIGHTING_CHANGED, PROC_REF(light_changed))
		RegisterSignals(spot, appearance_signals, PROC_REF(invalidate))
		RegisterSignals(spot, contents_signals, PROC_REF(contents_changed))

/datum/overmap_surface_chunk/Destroy()
	UnregisterSignal(SSdcs, list(COMSIG_STARLIGHT_COLOR_CHANGED, COMSIG_GLOB_AREA_BASE_LIGHTING_CHANGED))
	surface.view_chunks -= key
	surface = null
	for(var/turf/spot as anything in turfs)
		UnregisterSignal(spot, list(COMSIG_TURF_LIGHTING_CHANGED, COMSIG_TURF_CHANGE, COMSIG_TURF_EXPOSURE_CHANGED, COMSIG_ATOM_UPDATED_ICON, COMSIG_ATOM_SMOOTHED_ICON, COMSIG_ATOM_ENTERED, COMSIG_ATOM_EXITED, COMSIG_ATOM_AFTER_SUCCESSFUL_INITIALIZED_ON))
	for(var/atom/movable/thing as anything in watched)
		UnregisterSignal(thing, list(COMSIG_ATOM_UPDATED_ICON, COMSIG_ATOM_DIR_CHANGE, COMSIG_QDELETING))
	turfs = null
	watched = null
	layers = null
	lights = null
	return ..()

/datum/overmap_surface_chunk/proc/release()
	users--
	if(!users)
		qdel(src)

/datum/overmap_surface_chunk/proc/invalidate()
	SIGNAL_HANDLER
	layers = null
	lights = null

/datum/overmap_surface_chunk/proc/light_changed()
	SIGNAL_HANDLER
	lights = null

/datum/overmap_surface_chunk/proc/contents_changed(turf/spot, atom/movable/thing)
	SIGNAL_HANDLER
	if(thing.simulated && overmap_exposed_surface(spot))
		layers = null

/datum/overmap_surface_chunk/proc/surface_overlays(list/source)
	var/list/visible = list()
	for(var/entry in source)
		var/mutable_appearance/child = new(entry)
		var/plane = PLANE_TO_TRUE(child.plane)
		if(isnull(plane))
			plane = child.plane
		if(child.plane != FLOAT_PLANE && (plane < FLOOR_PLANE || plane > ABOVE_GAME_PLANE))
			continue
		child.plane = FLOAT_PLANE
		child.appearance_flags &= ~KEEP_APART
		if(length(child.overlays))
			child.overlays = surface_overlays(child.overlays)
		if(length(child.underlays))
			child.underlays = surface_overlays(child.underlays)
		visible += child
	return visible

/datum/overmap_surface_chunk/proc/appearance_at(atom/source, turf/spot)
	var/mutable_appearance/copy = new(source)
	if(length(copy.overlays))
		copy.overlays = surface_overlays(copy.overlays)
	if(length(copy.underlays))
		copy.underlays = surface_overlays(copy.underlays)
	copy.plane = FLOAT_PLANE
	copy.appearance_flags = KEEP_TOGETHER|PIXEL_SCALE
	copy.mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	copy.pixel_x += (spot.x - center_x) * ICON_SIZE_X
	copy.pixel_y += (spot.y - center_y) * ICON_SIZE_Y
	return copy

/datum/overmap_surface_chunk/proc/render()
	if(layers)
		return layers
	var/list/previous = watched
	watched = list()
	layers = list()
	for(var/turf/spot as anything in turfs)
		if(!overmap_exposed_surface(spot))
			var/mutable_appearance/roof = mutable_appearance(/turf/simulated/floor/engine/hull/ceiling::icon, /turf/simulated/floor/engine/hull/ceiling::icon_state, TURF_LAYER)
			roof.plane = FLOAT_PLANE
			roof.pixel_x = (spot.x - center_x) * ICON_SIZE_X
			roof.pixel_y = (spot.y - center_y) * ICON_SIZE_Y
			layers += roof
			continue
		layers += appearance_at(spot, spot)
		for(var/atom/movable/thing as anything in spot)
			if(thing.loc != spot || !thing.simulated || thing.invisibility || (thing.vis_flags & VIS_HIDE) || (!isobj(thing) && !isliving(thing)) || iseffect(thing) || istype(thing, /obj/docking_port))
				continue
			layers += appearance_at(thing, spot)
			watched[thing] = TRUE
			if(!previous[thing])
				RegisterSignals(thing, list(COMSIG_ATOM_UPDATED_ICON, COMSIG_ATOM_DIR_CHANGE, COMSIG_QDELETING), PROC_REF(invalidate))
	for(var/atom/movable/thing as anything in previous)
		if(!watched[thing] && !QDELETED(thing))
			UnregisterSignal(thing, list(COMSIG_ATOM_UPDATED_ICON, COMSIG_ATOM_DIR_CHANGE, COMSIG_QDELETING))
	return layers

/datum/overmap_surface_chunk/proc/render_lights()
	if(lights)
		return lights
	lights = list()
	var/list/ambient_colors = list()
	for(var/turf/spot as anything in turfs)
		var/area/place = spot.loc
		if(!place.outdoors)
			continue
		var/atom/movable/lighting_object/source = spot.lighting_object
		if(!source && !place.base_lighting_alpha && !spot.space_lit)
			continue
		var/list/ambient = ambient_colors[place]
		if(!ambient)
			var/tint = place.base_lighting_color == COLOR_STARLIGHT ? GLOB.starlight_color : place.base_lighting_color
			ambient = rgb2num(tint || COLOR_BLACK)
			for(var/channel in 1 to 3)
				ambient[channel] *= place.base_lighting_alpha / 255
			ambient_colors[place] = ambient
		var/mutable_appearance/light
		if(islist(source?.color))
			light = mutable_appearance(LIGHTING_ICON, source.icon_state)
			var/list/colors = source.color
			colors = colors.Copy()
			colors[17] += ambient[1] / 255
			colors[18] += ambient[2] / 255
			colors[19] += ambient[3] / 255
			light.color = colors
		else
			light = mutable_appearance('icons/effects/alphacolors.dmi', "white")
			light.color = spot.space_lit && !place.base_lighting_alpha ? GLOB.starlight_color : rgb(ambient[1], ambient[2], ambient[3])
		light.plane = FLOAT_PLANE
		light.layer = LIGHTING_LAYER
		light.blend_mode = BLEND_MULTIPLY
		light.pixel_x = (spot.x - center_x) * ICON_SIZE_X
		light.pixel_y = (spot.y - center_y) * ICON_SIZE_Y
		lights += light
	return lights

/datum/terrain_mirror/atmosphere
	var/obj/effect/abstract/hull_proxy_tile/surface_frame/frame
	var/origin_x
	var/origin_y
	var/edge_mask_radius
	var/last_scale
	var/list/prefetched = list()

/datum/terrain_mirror/atmosphere/New(obj/overmap/entity/vessel, datum/overmap_bubble/local_space)
	..()
	frame = new(viewer_turf)
	SET_PLANE_EXPLICIT(frame, PLANET_SURFACE_PLANE, viewer_turf)

/datum/terrain_mirror/atmosphere/Destroy()
	for(var/key, entry in prefetched)
		var/datum/overmap_surface_chunk/chunk = entry
		chunk.release()
	prefetched = null
	QDEL_NULL(frame)
	return ..()

/datum/terrain_mirror/atmosphere/proc/prefetch_strip(datum/overmap_bubble/planet_surface/surface, list/strip, can_build)
	var/list/ahead = list()
	if(strip)
		for(var/x in strip[1] to strip[3])
			for(var/y in strip[2] to strip[4])
				var/key = "[x],[y]"
				if(tiles[key])
					continue
				ahead[key] = TRUE
				if(!can_build || surface.view_chunks[key] || TICK_CHECK || length(prefetched) >= OVERMAP_SURFACE_PREFETCH_LIMIT)
					continue
				var/datum/overmap_surface_chunk/chunk = new(surface, x, y)
				chunk.users++
				prefetched[key] = chunk
				chunk.render()
				chunk.render_lights()
				can_build = FALSE
	for(var/key, entry in prefetched)
		if(!ahead[key])
			var/datum/overmap_surface_chunk/chunk = entry
			prefetched -= key
			chunk.release()

/datum/terrain_mirror/atmosphere/proc/frame_transform(x, y, facing, scale)
	var/matrix/pose = matrix()
	pose.Translate((origin_x - x) * ICON_SIZE_X, (origin_y - y) * ICON_SIZE_Y)
	pose.Scale(1 / scale)
	pose.Turn(-facing)
	pose.Translate((vessel.hull_center_x - viewer_turf.x) * ICON_SIZE_X, (vessel.hull_center_y - viewer_turf.y) * ICON_SIZE_Y)
	return pose

/datum/terrain_mirror/atmosphere/proc/add_edge_strip(list/mask, left, bottom, right, top)
	var/mutable_appearance/strip = mutable_appearance('icons/effects/alphacolors.dmi', "white", SPACE_LAYER, plane = FLOAT_PLANE)
	strip.color = COLOR_BLACK
	strip.mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	var/matrix/position = matrix()
	position.Scale(right - left + 1, top - bottom + 1)
	position.Translate(((left + right) / 2 - origin_x) * ICON_SIZE_X, ((bottom + top) / 2 - origin_y) * ICON_SIZE_Y)
	strip.transform = position
	mask += strip

/datum/terrain_mirror/atmosphere/proc/update_edge_mask(radius)
	var/left = origin_x - radius
	var/right = origin_x + radius
	var/bottom = origin_y - radius
	var/top = origin_y + radius
	var/list/mask = list()
	if(left < 1)
		add_edge_strip(mask, left, bottom, 0, top)
	if(right > world.maxx)
		add_edge_strip(mask, world.maxx + 1, bottom, right, top)
	if(bottom < 1)
		add_edge_strip(mask, max(1, left), bottom, min(world.maxx, right), 0)
	if(top > world.maxy)
		add_edge_strip(mask, max(1, left), world.maxy + 1, min(world.maxx, right), top)
	frame.underlays = mask
	edge_mask_radius = radius

/datum/terrain_mirror/atmosphere/update(elapsed, list/viewports = SSovermap.frame_viewports(vessel))
	var/datum/overmap_atmosphere/flight = vessel.atmosphere
	var/datum/overmap_bubble/planet_surface/surface = flight.surface
	var/list/point = surface.to_bubble(flight.world_x, flight.world_y)
	var/scale = flight.scale()
	var/facing = vessel.get_facing()
	var/moved = last_x != point[1] || last_y != point[2] || last_turned_facing != facing || last_scale != scale
	var/rebase = isnull(origin_x) || max(abs(origin_x - point[1]), abs(origin_y - point[2])) > OVERMAP_SURFACE_CHUNK * 2
	if(rebase)
		origin_x = round(point[1])
		origin_y = round(point[2])
	var/c = cos(facing)
	var/s = sin(facing)
	var/list/wanted = list()
	var/list/strip
	var/cold_chunk = FALSE
	var/view_radius = 0
	for(var/list/viewport as anything in viewports)
		var/turf/eye = viewport[1]
		var/dx = (eye.x - vessel.hull_center_x) * scale
		var/dy = (eye.y - vessel.hull_center_y) * scale
		var/x = point[1] + dx * c + dy * s
		var/y = point[2] + dy * c - dx * s
		var/reach = viewport[2] * scale * (abs(c) + abs(s))
		view_radius = max(view_radius, max(abs(x - origin_x), abs(y - origin_y)) + reach)
		var/min_x = FLOOR((max(x - reach, 1) - 1) / OVERMAP_SURFACE_CHUNK, 1)
		var/min_y = FLOOR((max(y - reach, 1) - 1) / OVERMAP_SURFACE_CHUNK, 1)
		var/max_x = FLOOR((min(x + reach, world.maxx) - 1) / OVERMAP_SURFACE_CHUNK, 1)
		var/max_y = FLOOR((min(y + reach, world.maxy) - 1) / OVERMAP_SURFACE_CHUNK, 1)
		if(min_x > max_x || min_y > max_y)
			continue
		if(!strip && !isnull(last_x) && last_scale == scale && facing == last_turned_facing && (point[1] != last_x || point[2] != last_y))
			if(abs(point[1] - last_x) >= abs(point[2] - last_y))
				var/leading_x = point[1] > last_x ? max_x + 1 : min_x - 1
				if(leading_x >= 0 && leading_x * OVERMAP_SURFACE_CHUNK < world.maxx)
					strip = list(leading_x, min_y, leading_x, max_y)
			else
				var/leading_y = point[2] > last_y ? max_y + 1 : min_y - 1
				if(leading_y >= 0 && leading_y * OVERMAP_SURFACE_CHUNK < world.maxy)
					strip = list(min_x, leading_y, max_x, leading_y)
		for(var/chunk_x in min_x to max_x)
			for(var/chunk_y in min_y to max_y)
				var/key = "[chunk_x],[chunk_y]"
				if(wanted[key])
					continue
				wanted[key] = TRUE
				var/obj/effect/abstract/hull_proxy_tile/surface/tile = tiles[key]
				var/fresh = !tile
				if(fresh)
					tile = new
					tile.chunk = surface.view_chunks[key]
					if(!tile.chunk)
						cold_chunk = TRUE
						tile.chunk = new(surface, chunk_x, chunk_y)
					tile.chunk.users++
					tiles[key] = tile
					frame.vis_contents += tile
				var/list/layers = tile.chunk.render()
				var/list/lights = tile.chunk.render_lights()
				if(tile.displayed != layers || tile.displayed_lights != lights)
					tile.overlays = layers + lights
					tile.displayed = layers
					tile.displayed_lights = lights
				if(fresh || rebase)
					tile.pixel_x = (tile.chunk.center_x - origin_x) * ICON_SIZE_X
					tile.pixel_y = (tile.chunk.center_y - origin_y) * ICON_SIZE_Y
	var/radius = CEILING(view_radius, OVERMAP_SURFACE_CHUNK)
	if(rebase || edge_mask_radius != radius)
		update_edge_mask(radius)
	for(var/key in tiles)
		if(!wanted[key])
			qdel(tiles[key])
			tiles -= key
	if(strip || length(prefetched))
		prefetch_strip(surface, strip, !cold_chunk)
	if(moved || rebase)
		var/matrix/next = frame_transform(point[1], point[2], facing, scale)
		if(rebase && last_scale)
			animate(frame)
			frame.transform = frame_transform(last_x, last_y, last_turned_facing, last_scale)
		if(last_scale && elapsed)
			animate(frame, transform = next, time = elapsed)
		else
			frame.transform = next
	last_x = point[1]
	last_y = point[2]
	last_turned_facing = facing
	last_scale = scale
