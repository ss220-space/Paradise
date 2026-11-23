/atom/movable/screen/overmap_proxy_void
	clear_with_screen = FALSE
	icon = 'icons/effects/alphacolors.dmi'
	icon_state = "white"
	color = COLOR_BLACK
	plane = OVERMAP_PROXY_VOID_PLANE
	layer = 0
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	screen_loc = "SOUTH,WEST to NORTH,EAST"

/datum/fog_view/proc/include_occluded_proxies()
	var/turf/eye = get_turf(owner.eye || owner.mob)
	if(!eye)
		return
	var/list/visible_turfs = list()
	for(var/turf/spot in dview(owner.view, eye))
		visible_turfs[spot] = TRUE
	var/list/size = getviewsize(owner.view)
	for(var/source, visual_entry in scene.drawn)
		var/obj/effect/abstract/hull_proxy_tile/visual = visual_entry
		if(!istype(visual) || visual.z != eye.z || visible_turfs[visual.loc])
			continue
		if(abs(visual.x + visual.pixel_x / ICON_SIZE_X - eye.x) > size[1] / 2 + 1 || abs(visual.y + visual.pixel_y / ICON_SIZE_Y - eye.y) > size[2] / 2 + 1)
			continue
		hidden[source] = eye

/datum/fog_view/proc/position_occluded_mask(image/mask, atom/source, turf/eye)
	var/obj/effect/abstract/hull_proxy_tile/visual = scene.visual_for(source)
	if(QDELETED(visual))
		return
	mask.loc = eye
	mask.pixel_x = (visual.x - eye.x) * ICON_SIZE_X + visual.pixel_x
	mask.pixel_y = (visual.y - eye.y) * ICON_SIZE_Y + visual.pixel_y
	mask.transform = visual.transform
	mask.icon = (proxy_sight & SEE_OBJS) ? LIGHTING_ICON : null

/datum/fog_view/proc/update_proxy_mask(image/mask, atom/source)
	var/list/allowed = list()
	if(proxy_sight && isturf(source))
		var/obj/effect/abstract/hull_proxy_tile/tile = scene.visual_for(source)
		if(proxy_sight & SEE_TURFS)
			allowed += fog_overlay(source.appearance)
		if(proxy_sight & (SEE_OBJS|SEE_MOBS))
			for(var/atom/movable/part as anything in tile?.frame)
				if(part == tile.projected_turf || part == tile.shade || part == tile.light_mask || part == tile.light_backdrop)
					continue
				var/atom/movable/content = part
				if(istype(part, /obj/effect/abstract/hull_proxy_offset))
					var/obj/effect/abstract/hull_proxy_offset/offset = part
					content = offset.source
				if(!QDELETED(content) && content.invisibility <= owner.mob.see_invisible && (proxy_sight & fog_sight_flag(content)))
					allowed += fog_overlay(content.appearance)
	else if(istype(source, /obj/effect/abstract/hull_proxy_tile/scatter))
		if(proxy_sight & fog_sight_flag(source))
			var/mutable_appearance/visual = fog_overlay(source.appearance)
			visual.pixel_x = 0
			visual.pixel_y = 0
			visual.transform = null
			allowed += visual
	else if(proxy_sight && istype(scene, /datum/fog_scene/projected))
		var/datum/fog_scene/projected/projected = scene
		var/list/cell = projected.source_positions[source]
		var/datum/overmap_virtual_model/model = cell?[3]
		if(istype(model))
			var/mutable_appearance/visual = fog_overlay(model.visual)
			if(!(proxy_sight & SEE_TURFS))
				visual.icon = null
			if(!(proxy_sight & SEE_OBJS))
				visual.overlays.Cut()
			allowed += visual
	mask.overlays = allowed

/datum/fog_view/proc/fog_overlay(appearance)
	var/mutable_appearance/visual = new(appearance)
	visual.plane = FLOAT_PLANE
	visual.layer = FLOAT_LAYER
	return visual
