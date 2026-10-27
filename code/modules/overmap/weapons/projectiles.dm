/obj/projectile/proc/sector_target_at(turf/spot, ignore_structure = FALSE)
	if(!ignore_structure && spot.density && !(spot in permutated))
		return spot
	for(var/atom/movable/object in spot)
		if(object == src || object == firer || !object.simulated || (object in permutated))
			continue
		if(ignore_structure && !isliving(object))
			continue
		if((object.density || isliving(object)) && !(pass_flags & object.pass_flags_self))
			return object

/datum/controller/subsystem/overmap/proc/promote_space_projectile(atom/movable/mover, turf/space/spot)
	var/obj/projectile/shot = mover
	if(!istype(shot) || !shot.overmap_persistent || !shot.has_been_fired || shot.trajectory_ignore_forcemove)
		return FALSE
	var/datum/overmap_bubble/space = frame_owner(spot)
	if(!istype(space))
		return FALSE
	if(shot.sector_target_at(spot))
		return FALSE
	var/list/point = space.to_world(spot.x, spot.y)
	if(shot.trajectory)
		point[1] += shot.trajectory.return_px() / ICON_SIZE_X
		point[2] += shot.trajectory.return_py() / ICON_SIZE_Y
	return launch_sector_projectile(shot, space.sector, point[1], point[2], shot.Angle)

/datum/controller/subsystem/overmap/proc/launch_sector_projectile(obj/projectile/payload, datum/overmap_sector/sector, world_x, world_y, angle, obj/overmap/entity/source_vessel)
	if(QDELETED(payload) || !sector || payload.hitscan)
		return FALSE
	STOP_PROCESSING(SSprojectiles, payload)
	payload.overmap_persistent = TRUE
	payload.has_been_fired = TRUE
	payload.set_angle(angle)
	if(source_vessel && !payload.overmap_firer_vessel)
		payload.overmap_firer_vessel = source_vessel
	payload.moveToNullspace()
	var/datum/overmap_projectile/shot = new(payload, sector, world_x, world_y, angle)
	shot.clear_from = source_vessel
	projectile_snapshot_tick = -1
	return TRUE

/datum/controller/subsystem/overmap/proc/process_sector_projectiles(elapsed)
	for(var/datum/overmap_projectile/shot as anything in sector_projectiles.Copy())
		shot.advance(elapsed)
	projectile_snapshot_tick = -1

/datum/controller/subsystem/overmap/proc/draw_sector_projectiles(elapsed)
	var/list/frames = list()
	for(var/client/viewer as anything in client_eyes)
		var/turf/eye = get_turf(viewer.eye || viewer.mob)
		var/datum/owner = frame_owner(eye)
		if(!owner)
			continue
		var/list/eyes = frames[owner]
		if(!eyes)
			eyes = list()
			frames[owner] = eyes
		eyes += eye
	for(var/datum/overmap_projectile/shot as anything in sector_projectiles)
		shot.draw(frames, elapsed)

/datum/overmap_projectile
	var/obj/projectile/payload
	var/datum/overmap_sector/sector
	var/world_x
	var/world_y
	var/angle
	var/obj/overmap/entity/clear_from
	var/list/proxies = list()

/datum/overmap_projectile/New(obj/projectile/payload, datum/overmap_sector/sector, world_x, world_y, angle)
	src.payload = payload
	src.sector = sector
	src.world_x = world_x
	src.world_y = world_y
	src.angle = angle
	SSovermap.sector_projectiles += src

/datum/overmap_projectile/Destroy(force)
	SSovermap.sector_projectiles -= src
	QDEL_LIST_ASSOC_VAL(proxies)
	QDEL_NULL(payload)
	sector = null
	clear_from = null
	return ..()

/datum/overmap_projectile/proc/in_bounds(x, y)
	var/span = OVERMAP_TILE_SPAN * sector.tile_travel
	return x >= (sector.playable_min_x() - 0.5) * span && x < (sector.playable_max_x() + 0.5) * span && y >= (sector.playable_min_y() - 0.5) * span && y < (sector.playable_max_y() + 0.5) * span

/datum/overmap_projectile/proc/materialize(turf/spot, heading, atom/target, pixel_x = 0, pixel_y = 0)
	var/obj/projectile/shot = payload
	payload = null
	shot.trajectory_ignore_forcemove = TRUE
	shot.forceMove(spot)
	shot.trajectory_ignore_forcemove = FALSE
	if(QDELETED(shot))
		qdel(src)
		return
	shot.pixel_x = pixel_x
	shot.pixel_y = pixel_y
	shot.set_angle(heading)
	if(!shot.starting)
		shot.starting = spot
	if(target)
		shot.Bump(target)
	if(QDELETED(shot))
		qdel(src)
		return
	payload = shot
	angle += closer_angle_difference(heading, shot.Angle)
	shot.trajectory_ignore_forcemove = TRUE
	shot.moveToNullspace()
	shot.trajectory_ignore_forcemove = FALSE
	STOP_PROCESSING(SSprojectiles, shot)

/datum/overmap_projectile/proc/advance(elapsed)
	if(payload?.overmap_effect_until)
		if(world.time >= payload.overmap_effect_until)
			qdel(src)
		return
	if(QDELETED(payload) || !sector)
		qdel(src)
		return
	var/distance = payload.overmap_velocity * elapsed / (1 SECONDS)
	var/delta_x = sin(angle) * distance
	var/delta_y = cos(angle) * distance
	var/center_x = world_x + delta_x / 2
	var/center_y = world_y + delta_y / 2
	var/list/vessels = list()
	if(clear_from && (!clear_from.hull_turfs || !clear_from.hull_turf_at(world_x, world_y)))
		clear_from = null
	for(var/obj/overmap/entity/vessel as anything in SSovermap.flying_vessels)
		if(vessel == clear_from || vessel.sector != sector || (vessel.overmap_pod && vessel.overmap_pod.pod() == payload.firer_source_atom))
			continue
		if(abs(vessel.get_world_x() - center_x) <= vessel.hull_radius + distance / 2 + 1 && abs(vessel.get_world_y() - center_y) <= vessel.hull_radius + distance / 2 + 1)
			vessels += vessel
	var/list/fields = SSovermap.scatter_fields_at(sector, center_x, center_y, distance / 2 + 1)
	var/list/spaces = list()
	for(var/datum/overmap_bubble/space as anything in SSovermap.bubbles)
		if(!space.static_level || space.sector != sector)
			continue
		var/list/region = space.ensure_region()
		if(region && center_x + distance / 2 + 1 >= region[1] && center_x - distance / 2 - 1 <= region[3] && center_y + distance / 2 + 1 >= region[2] && center_y - distance / 2 - 1 <= region[4])
			spaces += space
	var/steps = max(1, CEILING(distance / 0.4, 1))
	for(var/step in 1 to steps)
		var/x = world_x + delta_x * step / steps
		var/y = world_y + delta_y * step / steps
		if(!in_bounds(x, y))
			qdel(src)
			return
		for(var/obj/overmap/entity/vessel as anything in vessels)
			if(istype(vessel, /obj/overmap/entity/virtual_structure))
				if(vessel == payload.overmap_firer_vessel)
					continue
				if(virtual_hit(vessel, x, y))
					return
				continue
			var/own_hull = payload.overmap_firer_vessel && (vessel.docked_ship || vessel) == (payload.overmap_firer_vessel.docked_ship || payload.overmap_firer_vessel)
			if(own_hull && vessel.overmap_pod)
				continue
			var/turf/spot = vessel.hull_turf_at(x, y)
			if(!spot)
				continue
			var/list/local_point = vessel.world_to_hull(x, y)
			var/pixel_x = (local_point[1] - spot.x) * ICON_SIZE_X
			var/pixel_y = (local_point[2] - spot.y) * ICON_SIZE_Y
			if(vessel.overmap_pod)
				var/obj/spacepod/pod = vessel.overmap_pod.pod()
				if(pod in payload.permutated)
					continue
				world_x = x
				world_y = y
				materialize(spot, angle - vessel.get_facing(), pod, pixel_x, pixel_y)
			else
				var/atom/target = payload.sector_target_at(spot, own_hull)
				if(!target)
					continue
				world_x = x
				world_y = y
				materialize(spot, angle - vessel.get_facing(), target, pixel_x, pixel_y)
			return
		for(var/datum/overmap_bubble/space as anything in spaces)
			var/list/local_point = space.to_bubble(x, y)
			if(local_point[1] < space.bounds[1] - 0.5 || local_point[1] >= space.bounds[3] + 0.5 || local_point[2] < space.bounds[2] - 0.5 || local_point[2] >= space.bounds[4] + 0.5)
				continue
			var/turf/spot = locate(FLOOR(local_point[1] + 0.5, 1), FLOOR(local_point[2] + 0.5, 1), space.bubble_z)
			if(!spot)
				continue
			var/atom/target = payload.sector_target_at(spot)
			if(target)
				world_x = x
				world_y = y
				materialize(spot, angle, target, (local_point[1] - spot.x) * ICON_SIZE_X, (local_point[2] - spot.y) * ICON_SIZE_Y)
				return
		for(var/obj/overmap/feature/hazard/field as anything in fields)
			var/index = field.scatter_at(x, y)
			if(index && scatter_hit(field, index, x, y))
				return
	world_x += delta_x
	world_y += delta_y

/datum/overmap_projectile/proc/draw(list/frames, elapsed)
	var/list/wanted = list()
	for(var/datum/owner as anything in frames)
		if(SSovermap.frame_sector(owner) != sector)
			continue
		var/obj/overmap/entity/vessel = owner
		var/datum/overmap_bubble/space = owner
		var/is_vessel = istype(vessel)
		var/list/spot = is_vessel ? vessel.world_to_hull(world_x, world_y) : space.to_bubble(world_x, world_y)
		var/visible = FALSE
		var/z
		for(var/turf/eye as anything in frames[owner])
			if(abs(spot[1] - eye.x) <= OVERMAP_TERRAIN_VIEW_RANGE + 6 && abs(spot[2] - eye.y) <= OVERMAP_TERRAIN_VIEW_RANGE + 6)
				visible = TRUE
				z = eye.z
				break
		if(!visible)
			continue
		wanted[owner] = TRUE
		var/obj/effect/abstract/hull_proxy_tile/visual = proxies[owner]
		if(!visual)
			visual = new(null)
			visual.appearance = payload.appearance
			visual.mouse_opacity = MOUSE_OPACITY_TRANSPARENT
			visual.invisibility = 0
			visual.layer = ABOVE_MOB_LAYER
			proxies[owner] = visual
		var/matrix/turned = matrix().Turn(angle - (is_vessel ? vessel.get_facing() : 0))
		visual.glide(spot[1], spot[2], z, turned, is_vessel ? vessel.flight_bounds : space.bounds, visual.loc ? min(elapsed, OVERMAP_FLIGHT_TICK) : 0)
		visual.alpha = 255
		var/turf/anchor = get_turf(visual)
		SET_PLANE_EXPLICIT(visual, GAME_PLANE, anchor)
	for(var/datum/owner as anything in proxies.Copy())
		if(!wanted[owner])
			qdel(proxies[owner])
			proxies -= owner

/datum/controller/subsystem/overmap/proc/projectiles_in_sector(datum/overmap_sector/sector)
	if(projectile_snapshot_tick != world.time)
		projectile_snapshot_tick = world.time
		projectile_snapshots = list()
		for(var/datum/overmap_projectile/shot as anything in sector_projectiles)
			if(QDELETED(shot.payload) || !shot.payload.overmap_radar_visible)
				continue
			var/list/shots = projectile_snapshots[shot.sector.id]
			if(!shots)
				shots = list()
				projectile_snapshots[shot.sector.id] = shots
			shots += list(list("id" = shot.payload.UID(), "x" = shot.world_x, "y" = shot.world_y, "angle" = shot.angle))
		for(var/obj/projectile/projectile as anything in SSprojectiles.processing)
			if(QDELETED(projectile) || !projectile.overmap_radar_visible || !projectile.has_been_fired || !isturf(projectile.loc))
				continue
			var/turf/spot = projectile.loc
			var/datum/owner = frame_owner(spot)
			if(!owner)
				continue
			var/datum/overmap_sector/where = frame_sector(owner)
			if(!where)
				continue
			var/list/point = frame_to_world(owner, spot)
			var/obj/overmap/entity/vessel = owner
			var/angle = istype(vessel) ? vessel.get_facing() : 0
			var/pixel_x = projectile.trajectory ? projectile.trajectory.return_px() : projectile.pixel_x
			var/pixel_y = projectile.trajectory ? projectile.trajectory.return_py() : projectile.pixel_y
			point[1] += (pixel_x * cos(angle) + pixel_y * sin(angle)) / ICON_SIZE_X
			point[2] += (pixel_y * cos(angle) - pixel_x * sin(angle)) / ICON_SIZE_Y
			var/list/shots = projectile_snapshots[where.id]
			if(!shots)
				shots = list()
				projectile_snapshots[where.id] = shots
			shots += list(list("id" = projectile.UID(), "x" = point[1], "y" = point[2], "angle" = SIMPLIFY_DEGREES(projectile.Angle + angle)))
	return projectile_snapshots[sector?.id] || list()

/obj/overmap/entity/proc/radar_projectiles()
	. = list()
	if(!sector)
		return
	return SSovermap.projectiles_in_sector(sector)
