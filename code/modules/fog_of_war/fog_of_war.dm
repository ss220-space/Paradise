#define FOG_OF_WAR_BUILD "fog-3"

#define FOG_OF_WAR_PLANE ABOVE_LIGHTING_PLANE
#define FOG_OF_WAR_LAYER 1

/datum/fog_frame

	var/matrix/base_transform

	var/turf/origin
	var/angle = 0
	var/scale = 1

	var/offset_x = 0
	var/offset_y = 0

/datum/fog_frame/New(turf/origin_turf, angle = 0, scale = 1, offset_x = 0, offset_y = 0)
	. = ..()
	src.origin = origin_turf
	src.angle = angle
	src.scale = scale
	src.offset_x = offset_x
	src.offset_y = offset_y
	base_transform = matrix()
	base_transform.Turn(angle)
	base_transform.Scale(scale, scale)

/datum/fog_frame/proc/place(turf/source)

	var/px = (source.x - origin.x) * world.icon_size
	var/py = (source.y - origin.y) * world.icon_size

	var/rotated_x = px * cos(angle) - py * sin(angle)
	var/rotated_y = px * sin(angle) + py * cos(angle)
	return list(rotated_x * scale + offset_x, rotated_y * scale + offset_y)

/datum/fog_frame/proc/transform_copy()
	return matrix(base_transform)

/datum/fog_frame/proc/anchor()
	return origin

#define FOG_MODEL_DIAGONAL 1
#define FOG_MODEL_UNION 2
#define FOG_MODEL_STRAIGHT 3

#define FOG_MODEL_PIXEL 4

GLOBAL_VAR_INIT(fog_model, FOG_MODEL_UNION)

GLOBAL_VAR_INIT(fog_rust_verified, FALSE)

GLOBAL_VAR_INIT(fog_rust_enabled, TRUE)
GLOBAL_VAR_INIT(fog_rust_error, null)

/proc/fog_rust_usable()
#ifdef FOG_OF_WAR_USE_RUSTLIB
	return GLOB.fog_rust_enabled && GLOB.fog_rust_verified
#else
	return FALSE
#endif

GLOBAL_VAR_INIT(fog_stat_tiles, 0)
GLOBAL_VAR_INIT(fog_stat_steps, 0)
GLOBAL_VAR_INIT(fog_stat_blocked, 0)

GLOBAL_LIST_EMPTY(fog_attached_views)

/proc/fog_attach_client(client/viewer, datum/fog_frame/frame)
	if(!viewer)
		return null
	var/list/datum/fog_view/views = GLOB.fog_attached_views[viewer]
	if(!views)
		views = list()
		GLOB.fog_attached_views[viewer] = views
	var/datum/fog_view/view = frame ? views[frame] : null
	if(!view)
		view = new(viewer)
		view.frame = frame
		if(frame)
			views[frame] = view
		else
			views["no frame"] = view

	view.dirty = TRUE

	fog_update_backdrop(viewer)
	return view

/proc/fog_detach_client(client/viewer, datum/fog_frame/frame = null)
	var/list/datum/fog_view/views = GLOB.fog_attached_views[viewer]
	if(!views)
		return FALSE
	if(frame)
		var/datum/fog_view/view = views[frame]
		if(!view)
			return FALSE
		views -= frame
		view.clear()
		qdel(view)
	else
		for(var/key in views)
			var/datum/fog_view/view = views[key]
			view?.clear()
			qdel(view)
		views.Cut()
	if(!length(views))
		GLOB.fog_attached_views -= viewer

	fog_update_backdrop(viewer)
	return TRUE

/proc/fog_attached_to(client/viewer, datum/fog_frame/frame)
	var/list/datum/fog_view/views = GLOB.fog_attached_views[viewer]
	return views ? views[frame] : null

/proc/fog_mark_all_dirty()
	for(var/client/viewer as anything in GLOB.fog_attached_views)
		var/list/datum/fog_view/views = GLOB.fog_attached_views[viewer]
		for(var/key in views)
			var/datum/fog_view/view = views[key]
			if(!QDELETED(view))
				view.dirty = TRUE

/proc/fog_turf_blocks_sight(turf/spot)
	if(!spot)
		return TRUE
	return IS_OPAQUE_TURF(spot)

/proc/fog_line_of_sight(turf/center, turf/target)
	if(!center || !target || center.z != target.z)
		return FALSE
	if(center == target)
		return TRUE
	var/turf/walker = center
	for(var/step_count in 1 to get_dist(center, target))
		walker = get_step_towards(walker, target)
		if(!walker)
			return FALSE
		GLOB.fog_stat_steps++
		if(walker == target)
			return TRUE
		if(IS_OPAQUE_TURF(walker))
			GLOB.fog_stat_blocked++
			return FALSE
	return TRUE

/proc/fog_cast(turf/center, radius, model = null)
	. = list()
	GLOB.fog_stat_tiles = 0
	GLOB.fog_stat_steps = 0
	GLOB.fog_stat_blocked = 0
	if(!center)
		return
	if(radius < 0)
		radius = 0
	if(isnull(model))
		model = GLOB.fog_model
	for(var/turf/target as anything in RANGE_TURFS(radius, center))
		GLOB.fog_stat_tiles++
		if(fog_line_of_sight_for(center, target, model))
			.[target] = TRUE
	fog_boundary_highlight(., center, radius)

/proc/fog_line_of_sight_for(turf/center, turf/target, model)
	switch(model)
		if(FOG_MODEL_STRAIGHT)
			return fog_line_of_sight_straight(center, target)
		if(FOG_MODEL_PIXEL)
			return fog_line_of_sight_pixel(center, target)
		if(FOG_MODEL_UNION)

			return fog_line_of_sight(center, target) || fog_line_of_sight_straight(center, target)
		else
			return fog_line_of_sight(center, target)

/proc/fog_line_of_sight_pixel(turf/center, turf/target, eye_x = ICON_SIZE_X / 2 + 0.5, eye_y = ICON_SIZE_Y / 2 + 0.5)
	if(!center || !target || center.z != target.z)
		return FALSE
	if(center == target)
		return TRUE
	var/x1 = center.x
	var/y1 = center.y
	var/x2 = target.x
	var/y2 = target.y
	var/z = center.z
	var/turf/walker
	var/eye_offset_x = eye_x / ICON_SIZE_X - 0.5 / ICON_SIZE_X
	var/eye_offset_y = eye_y / ICON_SIZE_Y - 0.5 / ICON_SIZE_Y

	if(x1 == x2)
		var/sign_y = sign(y2 - y1)
		y1 += sign_y
		while(y1 != y2)
			walker = locate(x1, y1, z)
			if(IS_OPAQUE_TURF(walker))
				return FALSE
			y1 += sign_y
		return TRUE

	var/slope = (ICON_SIZE_Y * (y2 - y1) + (ICON_SIZE_Y / 2 + 0.5 - eye_y)) / (ICON_SIZE_X * (x2 - x1) + (ICON_SIZE_X / 2 + 0.5 - eye_x))
	var/intercept = (y1 + eye_offset_y) - slope * (x1 + eye_offset_x)
	var/sign_x = sign(x2 - x1)
	var/sign_y = sign(y2 - y1)
	if(x1 < x2)
		intercept += slope
	while(x1 != x2 || y1 != y2)
		if(round(slope * x1 + intercept - y1))
			y1 += sign_y
		else
			x1 += sign_x
		if(x1 == x2 && y1 == y2)
			return TRUE
		walker = locate(x1, y1, z)
		if(IS_OPAQUE_TURF(walker))
			return FALSE
	return TRUE

/proc/fog_cast_pixel(turf/center, radius, eye_x, eye_y, model = null)
	. = list()
	if(!center)
		return
	if(radius < 0)
		radius = 0
	if(isnull(model))
		model = GLOB.fog_model
	for(var/turf/target as anything in RANGE_TURFS(radius, center))
		if(fog_line_of_sight_pixel(center, target, eye_x, eye_y))
			.[target] = TRUE
	fog_boundary_highlight(., center, radius)

/proc/fog_line_of_sight_straight(turf/center, turf/target)
	if(!center || !target || center.z != target.z)
		return FALSE
	if(center == target)
		return TRUE
	var/current_x = center.x
	var/current_y = center.y
	var/x_distance = target.x - current_x
	var/y_distance = target.y - current_y
	var/abs_x_distance = abs(x_distance)
	var/abs_y_distance = abs(y_distance)
	var/x_distance_sign = sign(x_distance)
	var/y_distance_sign = sign(y_distance)
	var/x = abs_x_distance >> 1
	var/y = abs_y_distance >> 1
	var/turf/walker
	if(abs_x_distance >= abs_y_distance)
		for(var/distance_counter in 0 to (abs_x_distance - 1))
			y += abs_y_distance
			if(y >= abs_x_distance)
				y -= abs_x_distance
				current_y += y_distance_sign
			current_x += x_distance_sign
			if(current_x == target.x && current_y == target.y)
				return TRUE
			walker = locate(current_x, current_y, center.z)
			if(IS_OPAQUE_TURF(walker))
				return FALSE
	else
		for(var/distance_counter in 0 to (abs_y_distance - 1))
			x += abs_x_distance
			if(x >= abs_y_distance)
				x -= abs_y_distance
				current_x += x_distance_sign
			current_y += y_distance_sign
			if(current_x == target.x && current_y == target.y)
				return TRUE
			walker = locate(current_x, current_y, center.z)
			if(IS_OPAQUE_TURF(walker))
				return FALSE
	return TRUE

/proc/fog_boundary_highlight(list/visible, turf/center, radius)
	var/list/added = list()
	for(var/turf/target as anything in RANGE_TURFS(radius, center))
		if(visible[target] || !IS_OPAQUE_TURF(target))
			continue
		for(var/direction in GLOB.alldirs)
			var/turf/neighbour = get_step(target, direction)
			if(neighbour && visible[neighbour])
				added[target] = TRUE
				break
	for(var/turf/tile as anything in added)
		visible[tile] = TRUE

/proc/fog_cast_set(turf/center, list/targets, model = null)
	. = list()
	if(!center || !length(targets))
		return
	if(isnull(model))
		model = GLOB.fog_model
	GLOB.fog_stat_tiles = 0
	GLOB.fog_stat_steps = 0
	GLOB.fog_stat_blocked = 0
	for(var/turf/target as anything in targets)
		GLOB.fog_stat_tiles++
		if(fog_line_of_sight_for(center, target, model))
			.[target] = TRUE
	fog_boundary_highlight_set(., targets)

/proc/fog_boundary_highlight_set(list/visible, list/targets)
	var/list/added = list()
	for(var/turf/target as anything in targets)
		if(visible[target] || !IS_OPAQUE_TURF(target))
			continue
		for(var/direction in GLOB.alldirs)
			var/turf/neighbour = get_step(target, direction)
			if(neighbour && visible[neighbour])
				added[target] = TRUE
				break
	for(var/turf/tile as anything in added)
		visible[tile] = TRUE

/proc/fog_hidden_from_visible_set(list/visible, list/targets)
	. = list()
	for(var/turf/tile as anything in targets)
		if(!visible[tile])
			. += tile

#define FOG_NATIVE_MAX_RADIUS 32

/proc/fog_hidden_native(turf/center, radius, model = null, extra_blockers = null)
	if(!center)
		return null
	if(radius < 0 || radius > FOG_NATIVE_MAX_RADIUS)
		GLOB.fog_rust_error = "fog_hidden_runs was asked for radius [radius], outside the library's 0..[FOG_NATIVE_MAX_RADIUS]"
		return null
	var/list/runs = RUSTLIB_CALL(fog_hidden_runs, center.x, center.y, center.z, radius, extra_blockers || "")
	if(!islist(runs) || length(runs) % 3)
		GLOB.fog_rust_error = "fog_hidden_runs returned an invalid mask"
		return null
	. = list()
	for(var/index = 1, index <= length(runs), index += 3)
		var/y = center.y + runs[index + 1]
		var/first_x = center.x + runs[index]
		for(var/x in first_x to first_x + runs[index + 2] - 1)
			var/turf/tile = locate(x, y, center.z)
			if(tile)
				. += tile

/proc/fog_hidden_from_visible(list/visible, turf/center, radius)
	. = list()
	for(var/turf/tile as anything in RANGE_TURFS(radius, center))
		if(!visible[tile])
			. += tile

/datum/fog_view
	var/obj/effect/abstract/fog_image_anchor/image_anchor
	var/client/owner

	var/turf/center

	var/radius = 0

	var/list/turf/visible = list()

	var/list/turf/hidden = list()

	var/datum/fog_frame/frame

	var/last_frame_signature = "none"

	var/list/image/tiles = list()

	var/datum/fog_scene/scene

	var/frame_time = 0

	var/dirty = TRUE
	var/next_recast = 0

	var/mob/watched_mob

/datum/fog_view/New(client/new_owner)
	. = ..()
	owner = new_owner
	watch_mob()

/datum/fog_view/Destroy(force)
	clear()
	QDEL_NULL(image_anchor)
	if(watched_mob)
		UnregisterSignal(watched_mob, COMSIG_MOVABLE_MOVED)
		watched_mob = null
	owner = null
	return ..()

/datum/fog_view/proc/watch_mob()
	var/mob/current = owner?.mob
	if(current == watched_mob)
		return
	if(watched_mob)
		UnregisterSignal(watched_mob, COMSIG_MOVABLE_MOVED)
	watched_mob = current
	if(watched_mob)
		RegisterSignal(watched_mob, COMSIG_MOVABLE_MOVED, PROC_REF(on_watched_mob_moved))

/datum/fog_view/proc/on_watched_mob_moved(datum/source)
	SIGNAL_HANDLER
	update()

/datum/fog_view/proc/clear()
	if(owner && length(tiles))

		for(var/turf/tile as anything in tiles)
			owner.images -= tiles[tile]
	tiles.Cut()
	visible?.Cut()
	hidden?.Cut()
	center = null

/datum/fog_view/proc/cast_center()
	if(scene)
		return scene.cast_center(src)
	return get_turf(owner?.eye || owner?.mob)

/datum/fog_view/proc/cast_radius()
	if(scene)
		return scene.cast_radius(src)
	return owner?.maxview() || 0

/datum/fog_view/proc/render_plane()
	var/turf/plane_turf = frame ? frame.anchor() : center
	. = FOG_OF_WAR_PLANE
	if(plane_turf && SSmapping.max_plane_offset)
		. -= PLANE_RANGE * GET_TURF_PLANE_OFFSET(plane_turf)

/datum/fog_view/proc/needs_update()
	if(!owner)
		return FALSE
	if(dirty)
		return TRUE
	var/turf/spot = cast_center()
	if(!spot)
		return FALSE
	if(spot != center || cast_radius() != radius)
		return TRUE

	if(SSfog_of_war?.max_age && world.time >= next_recast)
		return TRUE
	return FALSE

/datum/fog_view/proc/update()
	if(!owner)
		return FALSE
	watch_mob()
	var/turf/spot = cast_center()
	if(!spot)
		clear()
		return FALSE
	var/new_radius = cast_radius()
	if(dirty || spot != center || new_radius != radius || (SSfog_of_war?.max_age && world.time >= next_recast))
		center = spot
		radius = new_radius
		recast()
		dirty = FALSE

	next_recast = world.time + (SSfog_of_war?.max_age || 0)

	if(!scene)
		var/signature = frame_signature()
		if(signature != last_frame_signature)
			last_frame_signature = signature
			replace_frame_tiles()
	render()
	return TRUE

/datum/fog_view/proc/recast()
	if(scene)
		hidden = scene.hidden_for(src)
		visible = null
		return
	var/list/native = null
	if(fog_rust_usable() && SSfog_of_war && SSfog_of_war.native_ready(center.z))
		native = fog_hidden_native(center, radius)
	if(!isnull(native))
		hidden = native
		visible = null
	else
		visible = fog_cast(center, radius)
		hidden = fog_hidden_from_visible(visible, center, radius)

/datum/fog_view/proc/render()
	if(!owner || !center)
		return
	if(scene?.render(src))
		return
	var/plane = render_plane()
	if(image_anchor && frame?.anchor() && image_anchor.loc != frame.anchor())
		image_anchor.forceMove(frame.anchor())

	var/list/turf/wanted = list()

	for(var/turf/tile as anything in hidden)
		if(tile.z != center.z)
			continue

		if(tile == center)
			continue
		wanted[tile] = TRUE
		var/image/existing = tiles[tile]
		if(existing)

			var/atom/expected_anchor = visual_anchor(tile) || image_anchor || frame?.anchor() || tile
			if(!scene || (!QDELETED(existing.loc) && existing.loc == expected_anchor))
				continue
			owner.images -= existing
			tiles.Remove(tile)
		tiles[tile] = make_fog_image(tile, plane)
		owner.images += tiles[tile]
	for(var/turf/tile as anything in tiles.Copy())
		if(wanted[tile])
			continue
		owner.images -= tiles[tile]
		tiles.Remove(tile)

/datum/fog_view/proc/visual_anchor(turf/tile)
	if(!scene)
		return null
	var/atom/anchor = scene.visual_for(tile)
	return QDELETED(anchor) ? null : anchor

/datum/fog_view/proc/make_fog_image(turf/tile, plane)
	var/atom/pinned = visual_anchor(tile)
	if(pinned)
		var/image/hung = image(LIGHTING_ICON, pinned, "dark_lighting_object")
		hung.plane = plane
		hung.layer = FOG_OF_WAR_LAYER

		hung.appearance_flags = RESET_COLOR | RESET_ALPHA
		hung.mouse_opacity = MOUSE_OPACITY_TRANSPARENT
		return hung
	var/atom/anchor = tile
	var/pixel_x = 0
	var/pixel_y = 0
	var/matrix/transform
	if(frame)
		var/turf/frame_anchor = frame.anchor() || tile
		if(!image_anchor)
			image_anchor = new(frame_anchor)
		else if(image_anchor.loc != frame_anchor)
			image_anchor.forceMove(frame_anchor)
		anchor = image_anchor
		var/list/spot = frame.place(tile)
		pixel_x = spot[1]
		pixel_y = spot[2]
		transform = frame.transform_copy()

	var/image/fog = image(LIGHTING_ICON, anchor, "dark_lighting_object")
	fog.plane = plane
	fog.layer = FOG_OF_WAR_LAYER
	fog.appearance_flags = RESET_COLOR | RESET_ALPHA | RESET_TRANSFORM
	fog.pixel_x = pixel_x
	fog.pixel_y = pixel_y
	if(transform)
		fog.transform = transform
	fog.mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	return fog

/datum/fog_view/proc/replace_frame_tiles()
	if(!owner || !frame || !length(tiles))
		return
	var/atom/anchor = image_anchor || frame.anchor()
	if(!anchor)
		return
	var/matrix/transform = frame.transform_copy()
	for(var/turf/tile as anything in tiles)
		var/image/fog = tiles[tile]
		var/list/spot = frame.place(tile)
		if(fog.loc != anchor)

			if(isatom(fog.loc))
				var/atom/previous = fog.loc
				fog.pixel_x += (previous.x - anchor.x) * world.icon_size
				fog.pixel_y += (previous.y - anchor.y) * world.icon_size
			fog.loc = anchor
			fog.pixel_x = spot[1]
			fog.pixel_y = spot[2]
			fog.transform = matrix(transform)
			continue
		if(frame_time > 0)
			animate(fog, pixel_x = spot[1], pixel_y = spot[2], transform = matrix(transform), time = frame_time)
		else
			animate(fog)
			fog.pixel_x = spot[1]
			fog.pixel_y = spot[2]
			fog.transform = matrix(transform)

/datum/fog_view/proc/frame_signature()
	if(!frame)
		return "none"
	return "[frame.angle]|[frame.scale]|[frame.offset_x]|[frame.offset_y]|[frame.anchor()]"

/obj/effect/abstract/fog_image_anchor
	invisibility = 0
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	simulated = FALSE
	vis_flags = VIS_HIDE

#undef FOG_OF_WAR_BUILD
#undef FOG_OF_WAR_PLANE
#undef FOG_OF_WAR_LAYER
#undef FOG_MODEL_DIAGONAL
#undef FOG_MODEL_UNION
#undef FOG_MODEL_STRAIGHT
#undef FOG_MODEL_PIXEL
#undef FOG_NATIVE_MAX_RADIUS
