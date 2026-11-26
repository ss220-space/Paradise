/obj/overmap/entity/proc/can_approach_planet()
	return (shuttle || overmap_pod) && in_free_flight() && !atmosphere && !relay_capture && !docked_ship && !length(docked_guests) && !docking_approach?.aligning && get_dock_host()?.dock_host?.planet_landing

/obj/overmap/entity/proc/approach_planet()
	if(!can_approach_planet())
		return FALSE
	var/obj/overmap/entity/host = get_dock_host()
	var/obj/docking_port/stationary/pad = get_selected_pad()
	var/level = pad?.z || host.dock_host.pick_landing_z()
	return enter_atmosphere(host, level, pad?.x, pad?.y)

/obj/overmap/entity/proc/enter_atmosphere(obj/overmap/entity/host, level, x_pos, y_pos, departing = FALSE)
	if(atmosphere || (!shuttle && !overmap_pod) || !host?.dock_host || host.sector != sector)
		return FALSE
	var/datum/overmap_bubble/planet_surface/surface = host.dock_host.planet_surface(level)
	if(!surface)
		return FALSE
	QDEL_NULL(docking_approach)
	QDEL_NULL(terrain_view)
	QDEL_LIST_ASSOC_VAL(drifter_mirrors)
	QDEL_LIST_ASSOC_VAL(neighbor_proxies)
	QDEL_LIST_ASSOC_VAL(scatter_proxies)
	QDEL_NULL(scatter_fog)
	nearby_ships.Cut()
	local_space = surface
	atmosphere = new(src, surface, departing ? 1 : OVERMAP_ATMOSPHERE_ORBIT_SCALE)
	var/list/point = surface.to_world(x_pos || surface.center_x, y_pos || surface.center_y)
	atmosphere.set_position(point[1], point[2])
	stop_atmospheric_motion()
	remember_pose()
	SSovermap.flight_index.remove(src)
	radar_docks_until = 0
	radar_epoch++
	for(var/turf/spot as anything in flight_reservation?.reserved_turfs)
		if(!is_hyperspace_turf(spot) || hull_turfs[spot])
			continue
		for(var/atom/movable/thing as anything in spot)
			if(thing.loc == spot && thing.simulated && !isobserver(thing) && !istype(thing, /obj/docking_port))
				atmosphere.drop_from_hull(thing, spot)
	return TRUE

/obj/overmap/entity/proc/stop_atmospheric_motion()
	flight?.set_autopilot(FALSE, manual = FALSE)
	flight?.stop_burn()
	if(flight)
		flight.angular_velocity = 0
	speed[1] = 0
	speed[2] = 0

/obj/overmap/entity/proc/leave_atmosphere()
	if(!atmosphere?.cruising() || docking_approach?.aligning || shuttle?.transfer_busy)
		return FALSE
	QDEL_NULL(docking_approach)
	stop_atmospheric_motion()
	atmosphere.change_altitude(OVERMAP_ATMOSPHERE_ORBIT_SCALE)
	return TRUE

/obj/overmap/entity/proc/process_atmosphere(elapsed)
	if(atmosphere.end_scale == OVERMAP_ATMOSPHERE_ORBIT_SCALE && world.time >= atmosphere.transition_end)
		QDEL_NULL(atmosphere)
		keep_inside_local_space()
		remember_pose()
		SSovermap.projectile_poses -= src
		radar_docks_until = 0
		radar_epoch++
		return
	atmosphere.update_shadow(elapsed)

/proc/overmap_exposed_surface(turf/spot)
	var/area/place = spot?.loc
	return !!place?.outdoors

/datum/overmap_atmosphere/proc/hull_to_surface(hull_x, hull_y)
	var/scale = scale()
	var/list/point = vessel.hull_to_world(vessel.hull_center_x + (hull_x - vessel.hull_center_x) * scale, vessel.hull_center_y + (hull_y - vessel.hull_center_y) * scale)
	return surface.to_bubble(point[1], point[2])

/datum/overmap_atmosphere/proc/drop_from_hull(atom/movable/thing, turf/exit_turf)
	if(isprojectile(thing))
		qdel(thing)
		return TRUE
	var/list/pos = hull_to_surface(exit_turf.x, exit_turf.y)
	var/turf/origin = locate(clamp(FLOOR(pos[1] + 0.5, 1), 1, world.maxx), clamp(FLOOR(pos[2] + 0.5, 1), 1, world.maxy), surface.bubble_z)
	var/obj/spacepod/craft = thing
	var/datum/component/overmap_pod/pod = isspacepod(craft) ? craft.overmap_vessel?.overmap_pod : null
	var/turf/ground = nearest_open_ground(origin, !!pod)
	if(ground)
		if(pod)
			pod.land_at(ground, surface.host)
		else
			var/mob/living/faller = thing
			var/mob/living/pulled = thing.pulling
			var/pulled_falling = isliving(pulled) && !pulled.anchored && pulled.loc != ground
			var/mob/living/struck
			if(isliving(faller) || pulled_falling)
				struck = locate() in ground
			cross_frame_with_pull(thing, ground)
			var/hit = FALSE
			if(isliving(faller) && faller.loc == ground)
				apply_fall_damage(faller)
				hit = TRUE
			if(pulled_falling && pulled.loc == ground)
				apply_fall_damage(pulled)
				hit = TRUE
			if(hit && !QDELETED(struck))
				struck.apply_damage(OVERMAP_ATMOSPHERE_FALL_DAMAGE, BRUTE, BODY_ZONE_HEAD)
				struck.apply_damage(OVERMAP_ATMOSPHERE_FALL_DAMAGE, BRUTE, spread_damage = TRUE)
	return TRUE

/datum/overmap_atmosphere/proc/apply_fall_damage(mob/living/faller)
	faller.apply_damage(OVERMAP_ATMOSPHERE_FALL_DAMAGE, BRUTE, BODY_ZONE_L_LEG)
	faller.apply_damage(OVERMAP_ATMOSPHERE_FALL_DAMAGE, BRUTE, BODY_ZONE_R_LEG)
	faller.apply_damage(OVERMAP_ATMOSPHERE_FALL_DAMAGE, BRUTE, spread_damage = TRUE)
	faller.AdjustKnockdown(Z_FALL_KNOCKDOWN_DURATION)

/datum/overmap_atmosphere/proc/nearest_open_ground(turf/origin, pod = FALSE)
	var/turf/nearest
	var/best = INFINITY
	for(var/radius in 0 to max(world.maxx, world.maxy))
		if(radius * radius >= best)
			break
		for(var/dx in -radius to radius)
			var/step_y = (abs(dx) == radius) ? 1 : max(2 * radius, 1)
			for(var/dy = -radius; dy <= radius; dy += step_y)
				var/dist = dx * dx + dy * dy
				if(dist >= best)
					continue
				var/turf/spot = locate(origin.x + dx, origin.y + dy, origin.z)
				if(!overmap_exposed_surface(spot) || isspaceturf(spot) || spot.is_blocked_turf(exclude_mobs = !pod))
					continue
				if(pod && (!overmap_pod_2x2_landable(spot) || !overmap_pod_exposed(spot)))
					continue
				nearest = spot
				best = dist
	return nearest

/obj/effect/abstract/hull_proxy_tile/surface_frame
	name = "поверхность"
	icon = null
	plane = PLANET_SURFACE_PLANE
	layer = SPACE_LAYER
	appearance_flags = KEEP_TOGETHER|PIXEL_SCALE

/obj/effect/abstract/hull_proxy_tile/surface
	name = "поверхность"
	icon = null
	layer = SPACE_LAYER
	appearance_flags = KEEP_TOGETHER|PIXEL_SCALE
	vis_flags = VIS_INHERIT_PLANE
	var/list/displayed_lights
	var/datum/overmap_surface_chunk/chunk
	var/list/displayed

/obj/effect/abstract/hull_proxy_tile/surface/Destroy()
	chunk?.release()
	chunk = null
	displayed = null
	displayed_lights = null
	return ..()

/obj/effect/abstract/shuttle_shadow
	parent_type = /obj/effect/abstract/hull_proxy_tile
	name = "тень шаттла"
	desc = "Над поверхностью пролетает шаттл."
	plane = FLOOR_PLANE
	layer = ABOVE_OPEN_TURF_LAYER
	icon = null
	alpha = 78
	appearance_flags = KEEP_TOGETHER|PIXEL_SCALE
	var/obj/effect/abstract/hull_proxy_tile/shadow_shape/shape
	var/clip_radius
	var/clip_dirty = TRUE
	var/hull_version
	var/last_x
	var/last_y
	var/last_facing
	var/last_scale
	var/center_offset_x
	var/center_offset_y

/obj/effect/abstract/hull_proxy_tile/shadow_shape
	vis_flags = VIS_INHERIT_PLANE
	appearance_flags = PIXEL_SCALE

/obj/effect/abstract/shuttle_shadow/Initialize(mapload)
	. = ..()
	shape = new(null)
	vis_contents += shape
	RegisterSignal(SSdcs, COMSIG_GLOB_TURF_EXPOSURE_CHANGED, PROC_REF(roof_changed))

/obj/effect/abstract/shuttle_shadow/Destroy()
	UnregisterSignal(SSdcs, COMSIG_GLOB_TURF_EXPOSURE_CHANGED)
	QDEL_NULL(shape)
	return ..()

/obj/effect/abstract/shuttle_shadow/proc/roof_changed(datum/source, turf/spot)
	SIGNAL_HANDLER
	if(spot.z == z && abs(spot.x - x) <= clip_radius && abs(spot.y - y) <= clip_radius)
		clip_dirty = TRUE

/obj/effect/abstract/shuttle_shadow/proc/clip_roofs(turf/anchor, radius)
	clip_radius = radius
	clip_dirty = FALSE
	var/list/roofs = list()
	var/min_x = max(1, anchor.x - radius)
	var/max_x = min(world.maxx, anchor.x + radius)
	for(var/row in max(1, anchor.y - radius) to min(world.maxy, anchor.y + radius))
		var/start
		for(var/column in min_x to max_x + 1)
			if(column <= max_x && !overmap_exposed_surface(locate(column, row, anchor.z)))
				if(!start)
					start = column
				continue
			if(!start)
				continue
			var/mutable_appearance/roof = mutable_appearance('icons/effects/alphacolors.dmi', "white", ABOVE_OPEN_TURF_LAYER, plane = FLOAT_PLANE)
			var/matrix/strip = matrix()
			strip.Scale(column - start, 1)
			strip.Translate(((start + column - 1) / 2 - anchor.x) * ICON_SIZE_X, (row - anchor.y) * ICON_SIZE_Y)
			roof.transform = strip
			roofs += roof
			start = null
	overlays = roofs
	var/opacity_fraction = initial(alpha) / 255
	color = length(roofs) ? list(0,0,0,-opacity_fraction, 0,0,0,0, 0,0,0,0, 0,0,0,opacity_fraction, 0,0,0,0) : null

/obj/effect/abstract/shuttle_shadow/proc/map_shape(obj/overmap/entity/vessel)
	var/min_x = world.maxx
	var/min_y = world.maxy
	var/max_x = 1
	var/max_y = 1
	for(var/turf/hull as anything in vessel.hull_turfs)
		min_x = min(min_x, hull.x)
		min_y = min(min_y, hull.y)
		max_x = max(max_x, hull.x)
		max_y = max(max_y, hull.y)
	var/width = max_x - min_x + 1
	var/height = max_y - min_y + 1
	var/icon/mask = icon('icons/effects/alphacolors.dmi', "white")
	mask.Crop(1, 1, width, height)
	mask.DrawBox(null, 1, 1, width, height)
	for(var/turf/hull as anything in vessel.hull_turfs)
		var/x = hull.x - min_x + 1
		var/y = hull.y - min_y + 1
		mask.DrawBox(COLOR_BLACK, x, y, x, y)
	mask.Scale(width * ICON_SIZE_X, height * ICON_SIZE_Y)
	shape.icon = mask
	shape.pixel_w = (1 - width) * ICON_SIZE_X / 2
	shape.pixel_z = (1 - height) * ICON_SIZE_Y / 2
	clip_dirty = TRUE
	center_offset_x = (max_x + min_x) / 2 - vessel.hull_center_x
	center_offset_y = (max_y + min_y) / 2 - vessel.hull_center_y
	hull_version = vessel.hull_version

/datum/overmap_atmosphere/proc/update_shadow(elapsed)
	if(!length(vessel.hull_turfs))
		QDEL_NULL(shadow)
		return
	var/facing = vessel.get_facing()
	var/scale = scale()
	if(shadow && !shadow.clip_dirty && shadow.hull_version == vessel.hull_version && shadow.last_x == world_x && shadow.last_y == world_y && shadow.last_facing == facing && shadow.last_scale == scale)
		return
	var/fresh = !shadow
	if(fresh)
		shadow = new
	if(fresh || shadow.hull_version != vessel.hull_version)
		shadow.map_shape(vessel)
	var/list/pos = surface.to_bubble(world_x, world_y)
	var/x = pos[1] + scale * (shadow.center_offset_x * cos(facing) + shadow.center_offset_y * sin(facing))
	var/y = pos[2] + scale * (shadow.center_offset_y * cos(facing) - shadow.center_offset_x * sin(facing))
	var/turf/anchor = shadow.loc
	if(!anchor || max(abs(pos[1] - anchor.x), abs(pos[2] - anchor.y)) > OVERMAP_SURFACE_CHUNK)
		var/turf/next = locate(round(pos[1]), round(pos[2]), surface.bubble_z)
		if(anchor)
			var/matrix/previous = matrix(shadow.shape.transform)
			previous.Translate((anchor.x - next.x) * ICON_SIZE_X, (anchor.y - next.y) * ICON_SIZE_Y)
			animate(shadow.shape)
			shadow.shape.transform = previous
		shadow.forceMove(next)
		anchor = next
		shadow.clip_dirty = TRUE
	if(shadow.clip_dirty)
		shadow.clip_roofs(anchor, CEILING(vessel.hull_radius * OVERMAP_ATMOSPHERE_ORBIT_SCALE, 1) + OVERMAP_SURFACE_CHUNK + 1)
	if(fresh)
		SET_PLANE_EXPLICIT(shadow, FLOOR_PLANE, anchor)
	var/matrix/rotation = matrix()
	rotation.Scale(scale)
	rotation.Turn(facing)
	rotation.Translate((x - anchor.x) * ICON_SIZE_X, (y - anchor.y) * ICON_SIZE_Y)
	if(fresh || !elapsed)
		shadow.shape.transform = rotation
	else
		animate(shadow.shape, transform = rotation, time = elapsed)
	shadow.last_x = world_x
	shadow.last_y = world_y
	shadow.last_facing = facing
	shadow.last_scale = scale
