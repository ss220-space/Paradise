#define HULL_PROXY_SEAM_SCALE 1.03
#define HULL_PROXY_SHADING_SCALE 1.3
#define HULL_PROXY_LIGHT_COPY_INTERVAL (1 SECONDS)
#define HULL_PROXY_LIGHT_LAYER (LIGHTING_PRIMARY_LAYER + 2)
#define HULL_PROXY_SHADE_LAYER (FLOOR_EMISSIVE_START_LAYER - 0.01)
#define HULL_PROXY_GLOW_MIN_RANGE 3
#define HULL_PROXY_GLOW_MAX_RANGE 8
#define HULL_PROXY_GLOW_POWER 0.6
#define HULL_PROXY_GLOW_COLOR "#cfe0ff"

/datum/hull_proxy
	var/obj/overmap/entity/vessel
	var/list/obj/effect/abstract/hull_proxy_tile/tiles = list()

	var/list/tiles_by_turf = list()

	var/turf/viewer_turf

	var/mapped_hull_version = -1
	var/center_x
	var/center_y
	var/proxy_z
	var/heading
	var/obj/effect/abstract/hull_proxy_glow/glow

	var/datum/fog_scene/hull/fog

/obj/effect/abstract/hull_proxy_tile
	name = "hull proxy tile"
	invisibility = 0

	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	simulated = FALSE
	animate_movement = NO_STEPS
	vis_flags = VIS_HIDE
	var/base_x = 0
	var/base_y = 0
	var/turf/hull_turf
	var/obj/effect/abstract/hull_proxy_light/light_mask
	var/obj/effect/abstract/hull_proxy_light/light_backdrop
	var/obj/effect/abstract/hull_proxy_shade/shade
	var/copied_light_state
	var/list/copied_light_color
	var/corner_mask
	var/reanchor_distance = 1
	name = "hull proxy tile"
	invisibility = 0

	var/turf/shown_turf

	var/turf/frame_turf

	var/lit = FALSE

	var/list/frame = list()
	var/turf/watched_source
	var/list/watched_multitile
	var/list/offset_visuals
	var/obj/effect/abstract/hull_proxy_tile/projected/projected_turf
	var/list/hud_sources

/obj/effect/abstract/hull_proxy_tile/Click(location, control, params)
	if(!hull_turf || QDELETED(hull_turf))
		return ..()

	if(fog_hides_from(usr?.client, hull_turf))
		return

	var/atom/best_target = hull_turf

	var/best_layer = -INFINITY
	for(var/atom/movable/target as anything in hull_turf)
		if(target.mouse_opacity == MOUSE_OPACITY_TRANSPARENT || target.invisibility > usr?.see_invisible)
			continue
		if(target.layer < best_layer)
			continue
		best_target = target
		best_layer = target.layer
	if(usr)
		return usr.ClickOn(best_target, params, location)
	return best_target.Click(location, control, params)

/obj/effect/abstract/hull_proxy_light
	name = "hull proxy light"
	invisibility = 0
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	simulated = FALSE
	plane = LIGHTING_PLANE
	layer = HULL_PROXY_LIGHT_LAYER
	appearance_flags = RESET_COLOR | RESET_ALPHA

/obj/effect/abstract/hull_proxy_glow
	name = "hull glow"
	invisibility = 0
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	simulated = FALSE
	light_color = HULL_PROXY_GLOW_COLOR
	light_power = HULL_PROXY_GLOW_POWER

/obj/effect/abstract/hull_proxy_shade
	name = "hull proxy shade"
	icon = 'icons/effects/alphacolors.dmi'
	icon_state = "white"
	invisibility = 0
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	simulated = FALSE
	plane = EMISSIVE_PLANE
	layer = HULL_PROXY_SHADE_LAYER
	appearance_flags = RESET_COLOR | RESET_ALPHA

/datum/hull_proxy/New(obj/overmap/entity/vessel, turf/viewer_turf, glowing = FALSE)
	src.vessel = vessel
	src.viewer_turf = viewer_turf
	if(glowing)
		glow = new(null)
		refresh_glow()
	fog = new /datum/fog_scene/hull(src, round(vessel.hull_radius) + OVERMAP_FOG_HULL_REACH)
	rebuild_tiles()
	RegisterSignal(vessel, COMSIG_QDELETING, PROC_REF(on_vessel_deleted))
	addtimer(CALLBACK(src, PROC_REF(refresh_light_copies)), HULL_PROXY_LIGHT_COPY_INTERVAL, TIMER_LOOP|TIMER_DELETE_ME)

/datum/hull_proxy/Destroy(force)
	QDEL_LIST(tiles)
	tiles = list()
	tiles_by_turf = list()
	QDEL_NULL(glow)

	QDEL_NULL(fog)
	vessel = null
	return ..()

/datum/hull_proxy/proc/on_vessel_deleted()
	SIGNAL_HANDLER
	qdel(src)

/datum/hull_proxy/proc/place(new_center_x, new_center_y, new_z, new_heading, list/bounds, time)

	var/rebuilt = update_fog(new_center_x, new_center_y, new_z, new_heading)
	if(!rebuilt && new_center_x == center_x && new_center_y == center_y && new_z == proxy_z && new_heading == heading)
		return
	var/matrix/turned
	if(rebuilt || new_heading != heading || new_z != proxy_z)
		turned = matrix()
		turned.Scale(HULL_PROXY_SEAM_SCALE)
		turned.Turn(new_heading)
	if(rebuilt || new_z != proxy_z)
		time = 0
	center_x = new_center_x
	center_y = new_center_y
	proxy_z = new_z
	heading = new_heading
	var/cos_heading = cos(heading)
	var/sin_heading = sin(heading)
	for(var/obj/effect/abstract/hull_proxy_tile/tile as anything in tiles)
		tile.glide(center_x + (tile.base_x * cos_heading + tile.base_y * sin_heading) / ICON_SIZE_X, center_y + (tile.base_y * cos_heading - tile.base_x * sin_heading) / ICON_SIZE_Y, proxy_z, turned, bounds, time)
	var/turf/glow_turf = glow && locate(clamp(round(center_x, 1), bounds[1], bounds[3]), clamp(round(center_y, 1), bounds[2], bounds[4]), proxy_z)
	if(glow_turf && glow.loc != glow_turf)
		glow.forceMove(glow_turf)

/datum/hull_proxy/proc/update_fog(new_center_x, new_center_y, new_z, new_heading)
	if(!fog)
		return FALSE
	fog.set_frame(overmap_fog_anchor(new_center_x, new_center_y, new_z), vessel.hull_center_x, vessel.hull_center_y, new_center_x, new_center_y, -new_heading)

	var/rebuilt = FALSE
	if(vessel.hull_version != mapped_hull_version)
		rebuild_tiles()
		rebuilt = TRUE
	fog.client_eyes = SSovermap.client_eyes
	fog.refresh()
	return rebuilt

/datum/hull_proxy/proc/rebuild_tiles()
	QDEL_LIST(tiles)
	tiles = list()
	tiles_by_turf = list()
	for(var/turf/hull_turf as anything in vessel.hull_turfs)
		var/obj/effect/abstract/hull_proxy_tile/tile = new(null)
		tile.base_x = (hull_turf.x - vessel.hull_center_x) * ICON_SIZE_X
		tile.base_y = (hull_turf.y - vessel.hull_center_y) * ICON_SIZE_Y
		tile.hull_turf = hull_turf
		tile.frame_turf = viewer_turf

		tile.setup_shading()
		tiles += tile
		tiles_by_turf[hull_turf] = tile
	mapped_hull_version = vessel.hull_version

	fog.drawn = tiles_by_turf

	fog.mark_dirty()

/obj/effect/abstract/hull_proxy_tile/proc/glide(visual_x, visual_y, target_z, matrix/new_transform, list/bounds, time)
	var/anchor_x = clamp(round(visual_x, 1), bounds[1], bounds[3])
	var/anchor_y = clamp(round(visual_y, 1), bounds[2], bounds[4])
	var/turf/anchor = loc
	if(!anchor || anchor.z != target_z || abs(anchor.x - anchor_x) > reanchor_distance || abs(anchor.y - anchor_y) > reanchor_distance)
		var/turf/new_anchor = locate(anchor_x, anchor_y, target_z)
		if(anchor?.z == target_z)
			pixel_x += (anchor.x - new_anchor.x) * ICON_SIZE_X
			pixel_y += (anchor.y - new_anchor.y) * ICON_SIZE_Y
		else
			time = 0
		forceMove(new_anchor)
		anchor = new_anchor
	var/offset_x = (visual_x - anchor.x) * ICON_SIZE_X
	var/offset_y = (visual_y - anchor.y) * ICON_SIZE_Y
	if(!time)
		animate(src)
		pixel_x = offset_x
		pixel_y = offset_y
		if(new_transform)
			transform = new_transform
	else if(new_transform)
		animate(src, pixel_x = offset_x, pixel_y = offset_y, transform = new_transform, time = time)
	else

		animate(src, pixel_x = offset_x, pixel_y = offset_y, time = time)

/obj/effect/abstract/hull_proxy_tile/proc/setup_shading()
	var/matrix/shading_scale = matrix()
	shading_scale.Scale(HULL_PROXY_SHADING_SCALE)
	if((hull_turf.smooth & SMOOTH_DIAGONAL_CORNERS) && length(hull_turf.underlays))
		corner_mask = filter(type = "alpha", icon = icon(hull_turf.icon, hull_turf.icon_state))
	shade = new(src)
	SET_PLANE_EXPLICIT(shade, EMISSIVE_PLANE, frame_turf)
	shade.color = GLOB.em_block_color
	shade.transform = shading_scale
	if(corner_mask)
		shade.filters += corner_mask
	if(hull_turf.lighting_object)
		prepare_light_backdrop()
		light_mask = new(src)
		SET_PLANE_EXPLICIT(light_mask, LIGHTING_PLANE, frame_turf)
		lit = TRUE

	rebuild_contents()
	copy_light()

/obj/effect/abstract/hull_proxy_tile/proc/prepare_light_backdrop()
	if(light_backdrop)
		return
	light_backdrop = new(src)
	light_backdrop.icon = 'icons/effects/alphacolors.dmi'
	light_backdrop.icon_state = "white"
	light_backdrop.color = COLOR_BLACK
	light_backdrop.layer = HULL_PROXY_LIGHT_LAYER - 1
	light_backdrop.blend_mode = BLEND_DEFAULT
	SET_PLANE_EXPLICIT(light_backdrop, LIGHTING_PLANE, frame_turf)
	if(corner_mask)
		light_backdrop.filters += corner_mask

/obj/effect/abstract/hull_proxy_tile/proc/copy_light()
	var/atom/movable/lighting_object/source_light = hull_turf?.lighting_object
	if(!source_light)
		return
	var/fresh = !light_mask
	if(!light_mask)
		prepare_light_backdrop()
		light_mask = new(src)
		SET_PLANE_EXPLICIT(light_mask, LIGHTING_PLANE, frame_turf)
		lit = TRUE
		rebuild_contents()
	var/list/light_color = source_light.color
	if(!fresh && copied_light_state == source_light.icon_state && copied_light_color ~= light_color)
		return
	copied_light_state = source_light.icon_state
	copied_light_color = light_color
	var/mutable_appearance/light_copy = new(source_light)
	light_copy.plane = light_mask.plane
	light_copy.layer = HULL_PROXY_LIGHT_LAYER
	light_copy.appearance_flags = RESET_COLOR | RESET_ALPHA
	light_copy.invisibility = 0
	light_copy.transform = light_mask.transform
	if(corner_mask)
		light_copy.filters = corner_mask
	light_mask.appearance = light_copy

/datum/hull_proxy/proc/refresh_light_copies()
	for(var/obj/effect/abstract/hull_proxy_tile/tile as anything in tiles)
		tile.copy_light()
	refresh_glow()

/datum/hull_proxy/proc/refresh_glow()
	if(!glow)
		return
	var/lit = FALSE
	for(var/area/place as anything in vessel.shuttle?.shuttle_areas)
		if(place.powered(LIGHT))
			lit = TRUE
			break
	var/glow_range = lit ? clamp(round(vessel.hull_radius) + 2, HULL_PROXY_GLOW_MIN_RANGE, HULL_PROXY_GLOW_MAX_RANGE) : 0
	if(glow.light_range != glow_range)
		glow.set_light_range(glow_range)

#undef HULL_PROXY_SEAM_SCALE
#undef HULL_PROXY_SHADING_SCALE
#undef HULL_PROXY_LIGHT_COPY_INTERVAL
#undef HULL_PROXY_LIGHT_LAYER
#undef HULL_PROXY_SHADE_LAYER
#undef HULL_PROXY_GLOW_MIN_RANGE
#undef HULL_PROXY_GLOW_MAX_RANGE
#undef HULL_PROXY_GLOW_POWER
#undef HULL_PROXY_GLOW_COLOR
