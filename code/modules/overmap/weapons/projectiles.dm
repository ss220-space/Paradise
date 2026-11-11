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

/obj/overmap/entity/proc/projectile_inherited_velocity(world_x, world_y)
	var/obj/overmap/entity/carrier = docked_ship || src
	var/list/velocity = carrier.world_point_velocity(world_x, world_y)
	return list(velocity[1] * OVERMAP_TILE_SPAN * (1 SECONDS), velocity[2] * OVERMAP_TILE_SPAN * (1 SECONDS))

/datum/controller/subsystem/overmap/proc/launch_sector_projectile(obj/projectile/payload, datum/overmap_sector/sector, world_x, world_y, angle, obj/overmap/entity/source_vessel, inherit_velocity = TRUE)
	if(QDELETED(payload) || !sector || payload.hitscan)
		return FALSE
	STOP_PROCESSING(SSprojectiles, payload)
	payload.overmap_persistent = TRUE
	payload.has_been_fired = TRUE
	var/propulsion_angle = angle
	var/propulsion_speed = payload.overmap_velocity
	var/list/inherited
	if(source_vessel && !payload.overmap_firer_vessel)
		payload.overmap_firer_vessel = source_vessel
		if(inherit_velocity)
			inherited = source_vessel.projectile_inherited_velocity(world_x, world_y)
			var/velocity_x = sin(angle) * payload.overmap_velocity + inherited[1]
			var/velocity_y = cos(angle) * payload.overmap_velocity + inherited[2]
			payload.overmap_velocity = sqrt(velocity_x ** 2 + velocity_y ** 2)
			if(payload.overmap_velocity)
				angle = delta_to_angle(velocity_x, velocity_y)
	payload.set_angle(angle)
	payload.moveToNullspace()
	var/datum/overmap_projectile/shot = new(payload, sector, world_x, world_y, angle)
	shot.propulsion_angle = propulsion_angle
	shot.propulsion_speed = propulsion_speed
	if(inherited)
		shot.inherited_x = inherited[1]
		shot.inherited_y = inherited[2]
	shot.clear_from = source_vessel?.overmap_pod ? source_vessel : null
	projectile_snapshot_tick = -1
	return TRUE

/datum/controller/subsystem/overmap/proc/process_sector_projectiles(elapsed)
	for(var/datum/overmap_projectile/shot as anything in sector_projectiles)
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
			shots += list(list("id" = shot.payload.UID(), "x" = shot.world_x, "y" = shot.world_y, "angle" = shot.angle, "kind" = shot.payload.overmap_radar_kind))
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
			shots += list(list("id" = projectile.UID(), "x" = point[1], "y" = point[2], "angle" = SIMPLIFY_DEGREES(projectile.Angle + angle), "kind" = projectile.overmap_radar_kind))
	return projectile_snapshots[sector?.id] || list()

/obj/overmap/entity/proc/radar_projectiles()
	. = list()
	if(!sector)
		return
	return SSovermap.projectiles_in_sector(sector)
