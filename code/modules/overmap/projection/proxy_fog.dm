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

/proc/overmap_probe_stepped(turf/probe)
	if(!probe)
		return null
	if(!fog_turf_blocks_sight(probe))
		return probe
	for(var/direction in GLOB.cardinal)
		var/turf/step = get_step(probe, direction)
		if(step && !fog_turf_blocks_sight(step))
			return step
	return probe

/datum/fog_scene

	var/label = "proxy"

	var/datum/fog_frame/proxy/frame

	var/list/drawn = list()

	var/list/mine = list()

	var/reach = 8

/datum/fog_scene/New(reach = 8)
	. = ..()
	if(reach)
		src.reach = reach

/datum/fog_scene/Destroy(force)
	detach_all()
	drawn = null
	QDEL_NULL(frame)
	return ..()

/datum/fog_scene/proc/detach_all()
	for(var/client/viewer as anything in mine)
		fog_detach_client(viewer, frame)
	mine = list()

/datum/fog_scene/proc/set_frame(turf/anchor, src_x, src_y, tgt_x, tgt_y, angle)
	if(!frame)
		frame = new /datum/fog_frame/proxy(anchor, angle)
	frame.setup(anchor, src_x, src_y, tgt_x, tgt_y, angle)

/datum/fog_scene/proc/visual_for(turf/source)
	var/atom/visual = drawn ? drawn[source] : null
	return isatom(visual) ? visual : null

/datum/fog_scene/proc/render(datum/fog_view/view)
	return FALSE

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
	var/turf/probe = view.center
	if(!probe || !length(drawn))
		return
	var/answered = FALSE
	if(fog_rust_usable() && SSfog_of_war && SSfog_of_war.native_ready(probe.z))
		var/list/square = fog_hidden_native(probe, view.radius)
		if(!isnull(square))
			answered = TRUE
			for(var/turf/tile as anything in square)
				if(drawn[tile])
					. += tile
	if(!answered)
		var/list/visible = fog_cast_set(probe, drawn)
		. = fog_hidden_from_visible_set(visible, drawn)

/datum/fog_scene/proc/mark_dirty()
	for(var/client/viewer as anything in mine)
		var/datum/fog_view/view = fog_attached_to(viewer, frame)
		if(view)
			view.dirty = TRUE

/datum/fog_scene/proc/collect_clients(list/out)
	return

/datum/fog_scene/proc/cast_center(datum/fog_view/view)
	return null

/datum/fog_scene/proc/cast_radius(datum/fog_view/view)
	return reach

/datum/fog_scene/station
	label = "station mirror"
	var/obj/overmap/entity/vessel

	var/list/client_eyes

/datum/fog_scene/station/New(obj/overmap/entity/vessel, reach)
	. = ..(reach)
	src.vessel = vessel

/datum/fog_scene/station/collect_clients(list/out)
	if(!vessel)
		return
	var/list/eyes = client_eyes
	var/list/zones = vessel.hull_area_turfs
	if(!length(eyes) || !length(zones))
		return
	for(var/client/viewer as anything in eyes)
		var/list/spots = eyes[viewer]
		if(!length(spots))
			continue

		if(zones[spots[1]])
			out[viewer] = TRUE

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

/datum/fog_scene/station/cast_radius(datum/fog_view/view)
	return reach

/datum/fog_scene/hull
	label = "hull proxy"
	var/datum/hull_proxy/proxy
	var/list/client_eyes

/datum/fog_scene/hull/New(datum/hull_proxy/proxy, reach)
	. = ..(reach)
	src.proxy = proxy

/datum/fog_scene/hull/collect_clients(list/out)
	var/list/eyes = client_eyes
	if(!proxy || !length(eyes))
		return
	var/check_z = proxy.proxy_z
	var/center_x = proxy.center_x
	var/center_y = proxy.center_y
	var/reach_squared = reach * reach
	for(var/client/viewer as anything in eyes)
		for(var/turf/spot as anything in eyes[viewer])
			if(spot.z != check_z)
				continue
			var/delta_x = spot.x - center_x
			var/delta_y = spot.y - center_y
			if(delta_x * delta_x + delta_y * delta_y > reach_squared)
				continue
			out[viewer] = TRUE
			break

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

/datum/fog_scene/hull/cast_radius(datum/fog_view/view)
	return reach

/proc/fog_hides_from(client/viewer, atom/source)
	if(!viewer || !source)
		return FALSE
	var/list/datum/fog_view/views = GLOB.fog_attached_views[viewer]
	if(!views)
		return FALSE
	for(var/frame_key in views)
		var/datum/fog_view/view = views[frame_key]
		if(view?.tiles[source])
			return TRUE
	return FALSE

#define OVERMAP_PROXY_VOID_PLANE (FLOOR_PLANE - 1)

/atom/movable/screen/overmap_proxy_void
	icon = 'icons/effects/alphacolors.dmi'
	icon_state = "white"
	color = "#000000"
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
