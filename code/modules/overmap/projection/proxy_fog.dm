#define OVERMAP_FOG_CHUNK_SIZE 16

/datum/fog_frame/proxy

	var/source_x = 0
	var/source_y = 0

	var/target_x = 0
	var/target_y = 0

	var/turf/anchor_turf

	var/built_angle = null

/datum/fog_frame/proxy/New(turf/anchor_turf, angle = 0, scale = OVERMAP_TERRAIN_SEAM_SCALE)
	. = ..(anchor_turf, angle, scale, 0, 0)
	src.anchor_turf = anchor_turf

/datum/fog_frame/proxy/anchor()
	return anchor_turf

/datum/fog_frame/proxy/proc/setup(turf/new_anchor, src_x, src_y, tgt_x, tgt_y, new_angle)
	if(new_anchor)
		anchor_turf = new_anchor
		origin = new_anchor
	source_x = src_x
	source_y = src_y
	target_x = tgt_x
	target_y = tgt_y
	angle = new_angle
	if(new_angle != built_angle)
		built_angle = new_angle
		base_transform = matrix()
		base_transform.Scale(scale, scale)
		base_transform.Turn(-new_angle)

/datum/fog_frame/proxy/place(turf/source)
	var/turf/anchor = anchor_turf
	if(!anchor || !source)
		return list(0, 0)
	var/delta_x = source.x - source_x
	var/delta_y = source.y - source_y
	var/placed_x = target_x + delta_x * cos(angle) - delta_y * sin(angle)
	var/placed_y = target_y + delta_x * sin(angle) + delta_y * cos(angle)
	return list((placed_x - anchor.x) * world.icon_size, (placed_y - anchor.y) * world.icon_size)

/proc/overmap_fog_anchor(x, y, z)
	return locate(FLOOR(x + 0.5, 1), FLOOR(y + 0.5, 1), z)

/proc/overmap_probe_stepped(turf/probe, list/blockers)
	if(!probe)
		return null
	if(!fog_turf_blocks_sight(probe, blockers))
		return probe
	for(var/direction in GLOB.cardinal)
		var/turf/step = get_step(probe, direction)
		if(step && !fog_turf_blocks_sight(step, blockers))
			return step
	return probe

/datum/fog_cast_data
	var/turf/center
	var/list/blockers
	var/list/source_keys

/datum/fog_cast_data/Destroy()
	center = null
	blockers = null
	source_keys = null
	return ..()

/datum/fog_scene

	var/label = "proxy"

	var/datum/fog_frame/proxy/frame

	var/list/drawn = list()

	var/list/mine = list()
	var/list/client_eyes

	var/reach = 8

/datum/fog_scene/New(reach = 8)
	. = ..()
	if(reach)
		src.reach = reach

/datum/fog_scene/Destroy(force)
	detach_all()
	drawn = null
	client_eyes = null
	QDEL_NULL(frame)
	return ..()

/datum/fog_scene/proc/detach_all()
	for(var/client/viewer as anything in mine)
		fog_detach_client(viewer, frame)
	mine = list()

/datum/fog_scene/proc/set_frame(turf/anchor, src_x, src_y, tgt_x, tgt_y, angle)
	if(!frame)
		frame = new /datum/fog_frame/proxy(anchor, angle)
	if(frame.source_x != src_x || frame.source_y != src_y || frame.target_x != tgt_x || frame.target_y != tgt_y || frame.angle != angle)
		mark_dirty()
	frame.setup(anchor, src_x, src_y, tgt_x, tgt_y, angle)

/datum/fog_scene/proc/visual_for(atom/source)
	var/atom/visual = drawn ? drawn[source] : null
	return isatom(visual) ? visual : null

/datum/fog_scene/proc/refresh()
	if(!frame)
		return
	var/list/wanted = list()
	collect_clients(wanted)
	for(var/client/viewer as anything in mine)
		if(QDELETED(viewer) || !wanted[viewer])
			mine -= viewer
			fog_detach_client(viewer, frame)
	for(var/client/viewer as anything in wanted)
		if(QDELETED(viewer))
			continue
		var/datum/fog_view/view = fog_attached_to(viewer, frame)
		if(!view)
			view = fog_attach_client(viewer, frame)
			if(!view)
				continue
			view.scene = src

			view.radius = -1
		mine[viewer] = TRUE

/datum/fog_scene/proc/hidden_for(datum/fog_view/view)
	. = list()
	if(!view.center || !length(drawn))
		return
	var/datum/fog_cast_data/data = prepare_cast(view)
	if(!data.center)
		return
	var/list/square
	if(fog_rust_usable() && SSfog_of_war && (!isnull(data.blockers) || SSfog_of_war.native_ready(data.center.z)))
		var/packed
		if(!isnull(data.blockers))
			var/list/entries = list()
			for(var/turf/tile as anything in data.blockers)
				entries += "[tile.x],[tile.y]"
			packed = "virtual;[jointext(entries, ";")]"
		square = fog_hidden_native(data.center, view.radius, extra_blockers = packed)
	if(isnull(square))
		var/list/visible = fog_cast(data.center, view.radius, blockers = data.blockers)
		square = fog_hidden_from_visible(visible, data.center, view.radius)
	for(var/turf/tile as anything in square)
		square[tile] = TRUE
	if(isnull(data.source_keys))
		for(var/turf/tile as anything in square)
			if(drawn[tile])
				. += tile
		return
	for(var/atom/source, key_entry in data.source_keys)
		if(square[key_entry])
			. += source

/datum/fog_scene/proc/prepare_cast(datum/fog_view/view)
	var/datum/fog_cast_data/data = view.cast_data
	data.center = view.center
	data.blockers = null
	data.source_keys = null
	return data

/datum/fog_scene/proc/mark_dirty()
	for(var/client/viewer as anything in mine)
		var/datum/fog_view/view = fog_attached_to(viewer, frame)
		if(view)
			view.dirty = TRUE

/datum/fog_scene/proc/collect_clients(list/out)
	var/list/eyes = client_eyes || SSovermap.client_eyes
	var/turf/anchor = frame?.anchor()
	if(!anchor)
		return
	for(var/client/viewer as anything in eyes)
		for(var/turf/spot as anything in eyes[viewer])
			if(spot.z == anchor.z && (spot.x - frame.target_x) ** 2 + (spot.y - frame.target_y) ** 2 <= reach ** 2)
				out[viewer] = TRUE
				break

/datum/fog_scene/proc/cast_center(datum/fog_view/view)
	return null

/datum/fog_scene/proc/cast_radius(datum/fog_view/view)
	return min(reach, CEILING((view.owner?.maxview() || world.view) * 1.42 + 2, 1))

/datum/fog_scene/projected
	var/list/source_positions = list()
	var/list/opaque_chunks = list()

/datum/fog_scene/projected/Destroy(force)
	source_positions = null
	opaque_chunks = null
	return ..()

/datum/fog_scene/projected/proc/add_opaque_point(list/point)
	var/key = "[FLOOR(point[1] / OVERMAP_FOG_CHUNK_SIZE, 1)],[FLOOR(point[2] / OVERMAP_FOG_CHUNK_SIZE, 1)]"
	var/list/chunk = opaque_chunks[key]
	if(!chunk)
		chunk = list()
		opaque_chunks[key] = chunk
	chunk += list(point)

/datum/fog_scene/projected/cast_center(datum/fog_view/view)
	var/turf/eye = get_turf(view.owner?.eye || view.owner?.mob)
	var/turf/anchor = frame?.anchor()
	return eye && anchor && eye.z == anchor.z ? eye : null

/datum/fog_scene/projected/prepare_cast(datum/fog_view/view)
	var/datum/fog_cast_data/data = ..()
	data.center = locate(round(world.maxx / 2), round(world.maxy / 2), view.center.z)
	data.blockers = list()
	data.source_keys = list()
	var/delta_x = view.center.x - frame.target_x
	var/delta_y = view.center.y - frame.target_y
	var/source_x = FLOOR(frame.source_x + delta_x * cos(frame.angle) + delta_y * sin(frame.angle) + 0.5, 1)
	var/source_y = FLOOR(frame.source_y - delta_x * sin(frame.angle) + delta_y * cos(frame.angle) + 0.5, 1)
	var/min_chunk_x = FLOOR((source_x - view.radius - 1) / OVERMAP_FOG_CHUNK_SIZE, 1)
	var/max_chunk_x = FLOOR((source_x + view.radius + 1) / OVERMAP_FOG_CHUNK_SIZE, 1)
	var/min_chunk_y = FLOOR((source_y - view.radius - 1) / OVERMAP_FOG_CHUNK_SIZE, 1)
	var/max_chunk_y = FLOOR((source_y + view.radius + 1) / OVERMAP_FOG_CHUNK_SIZE, 1)
	for(var/chunk_x in min_chunk_x to max_chunk_x)
		for(var/chunk_y in min_chunk_y to max_chunk_y)
			for(var/list/point as anything in opaque_chunks["[chunk_x],[chunk_y]"])
				if(abs(point[1] - source_x) > view.radius + 1 || abs(point[2] - source_y) > view.radius + 1)
					continue
				var/turf/tile = locate(data.center.x + point[1] - source_x, data.center.y + point[2] - source_y, data.center.z)
				if(tile)
					data.blockers[tile] = TRUE
	for(var/atom/source, point_entry in source_positions)
		var/list/point = point_entry
		if(abs(point[1] - source_x) > view.radius || abs(point[2] - source_y) > view.radius)
			continue
		var/turf/tile = locate(data.center.x + point[1] - source_x, data.center.y + point[2] - source_y, data.center.z)
		if(tile)
			data.source_keys[source] = tile
	data.center = overmap_probe_stepped(data.center, data.blockers)
	return data

/datum/fog_scene/station
	label = "station mirror"
	var/obj/overmap/entity/vessel

/datum/fog_scene/station/New(obj/overmap/entity/vessel, reach)
	. = ..(reach)
	src.vessel = vessel

/datum/fog_scene/station/Destroy(force)
	vessel = null
	return ..()

/datum/fog_scene/station/collect_clients(list/out)
	if(!vessel)
		return
	var/list/eyes = client_eyes
	var/list/zones = vessel.hull_area_turfs
	if(!length(eyes) || !length(zones))
		return
	for(var/viewer_entry, spots_entry in eyes)
		var/client/viewer = viewer_entry
		var/list/spots = spots_entry
		if(!length(spots))
			continue

		for(var/turf/spot as anything in spots)
			if(zones[spot])
				out[viewer] = TRUE
				break

/datum/fog_scene/station/cast_center(datum/fog_view/view)
	var/client/viewer = view.owner
	var/datum/overmap_bubble/space = vessel ? vessel.local_space : null
	if(!viewer || !space)
		return null
	var/turf/eye_turf = get_turf(viewer.eye || viewer.mob)
	if(!eye_turf)
		return null
	var/list/zones = vessel.hull_area_turfs
	if(!length(zones) || !zones[eye_turf])
		return null
	var/list/spot = vessel.hull_to_world(eye_turf.x, eye_turf.y)
	return overmap_probe_stepped(space.turf_at(spot[1], spot[2]))

/datum/fog_scene/hull
	label = "hull proxy"
	var/datum/hull_proxy/proxy
/datum/fog_scene/hull/New(datum/hull_proxy/proxy, reach)
	. = ..(reach)
	src.proxy = proxy

/datum/fog_scene/hull/Destroy(force)
	proxy = null
	return ..()

/datum/fog_scene/hull/cast_center(datum/fog_view/view)
	var/client/viewer = view.owner
	var/datum/fog_frame/proxy/frame_now = frame
	if(!viewer || !proxy || !frame_now)
		return null
	var/turf/eye_turf = get_turf(viewer.eye || viewer.mob)
	if(!eye_turf || eye_turf.z != proxy.proxy_z)
		return null

	var/delta_x = eye_turf.x - frame_now.target_x
	var/delta_y = eye_turf.y - frame_now.target_y
	var/back_angle = -frame_now.angle
	var/hull_x = frame_now.source_x + delta_x * cos(back_angle) - delta_y * sin(back_angle)
	var/hull_y = frame_now.source_y + delta_x * sin(back_angle) + delta_y * cos(back_angle)
	var/turf/probe = overmap_fog_anchor(hull_x, hull_y, proxy.vessel ? proxy.vessel.hull_z : eye_turf.z)
	return overmap_probe_stepped(probe)

/proc/fog_hides_from(client/viewer, atom/source)
	if(!viewer || !source)
		return FALSE
	var/list/datum/fog_view/views = GLOB.fog_attached_views[viewer]
	if(!views)
		return FALSE
	for(var/frame_key, view_entry in views)
		var/datum/fog_view/view = view_entry
		if(view?.tiles[source])
			return TRUE
	return FALSE

#define OVERMAP_PROXY_VOID_PLANE (FLOOR_PLANE - 1)

/atom/movable/screen/overmap_proxy_void
	icon = 'icons/effects/alphacolors.dmi'
	icon_state = "white"
	color = COLOR_BLACK
	plane = OVERMAP_PROXY_VOID_PLANE
	layer = 0
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	screen_loc = "SOUTH,WEST to NORTH,EAST"

GLOBAL_LIST_EMPTY(fog_proxy_backdrops)

/proc/fog_update_backdrop(client/viewer)
	if(!viewer)
		return
	var/atom/movable/screen/overmap_proxy_void/backdrop = GLOB.fog_proxy_backdrops[viewer]
	var/needed = length(GLOB.fog_attached_views[viewer]) > 0
	if(needed && QDELETED(backdrop))
		backdrop = new
		GLOB.fog_proxy_backdrops[viewer] = backdrop
		viewer.screen += backdrop
	else if(!needed && !QDELETED(backdrop))
		viewer.screen -= backdrop
		qdel(backdrop)
		GLOB.fog_proxy_backdrops -= viewer

#undef OVERMAP_PROXY_VOID_PLANE

#undef OVERMAP_FOG_CHUNK_SIZE
