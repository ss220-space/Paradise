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
