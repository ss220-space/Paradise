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

	var/datum/fog_scene/fog
	var/copy_lighting = TRUE

/datum/hull_proxy/New(obj/overmap/entity/vessel, turf/viewer_turf, glowing = FALSE)
	src.vessel = vessel
	src.viewer_turf = viewer_turf
	if(glowing)
		glow = new(null)
		refresh_glow()
	fog = create_fog()
	rebuild_tiles()
	RegisterSignal(vessel, COMSIG_QDELETING, PROC_REF(on_vessel_deleted))
	if(copy_lighting)
		addtimer(CALLBACK(src, PROC_REF(refresh_light_copies)), HULL_PROXY_LIGHT_COPY_INTERVAL, TIMER_LOOP|TIMER_DELETE_ME)

/datum/hull_proxy/proc/create_fog()
	return new /datum/fog_scene/hull(src, round(vessel.hull_radius) + OVERMAP_FOG_HULL_REACH)

/datum/hull_proxy/Destroy(force)
	QDEL_LIST(tiles)
	tiles = list()
	tiles_by_turf = list()
	QDEL_NULL(glow)

	QDEL_NULL(fog)
	vessel = null
	viewer_turf = null
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
