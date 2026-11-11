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
