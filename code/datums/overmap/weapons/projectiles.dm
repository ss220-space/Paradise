/datum/overmap_projectile
	var/obj/projectile/payload
	var/datum/overmap_sector/sector
	var/world_x
	var/world_y
	var/angle
	var/propulsion_angle
	var/propulsion_speed
	var/inherited_x = 0
	var/inherited_y = 0
	var/obj/overmap/entity/clear_from
	var/list/proxies = list()

/datum/overmap_projectile/New(obj/projectile/payload, datum/overmap_sector/sector, world_x, world_y, angle)
	src.payload = payload
	src.sector = sector
	src.world_x = world_x
	src.world_y = world_y
	src.angle = angle
	propulsion_angle = angle
	propulsion_speed = payload.overmap_velocity
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
	steer_missile(elapsed)
	var/distance = payload.overmap_velocity * elapsed / (1 SECONDS)
	var/delta_x = sin(angle) * distance
	var/delta_y = cos(angle) * distance
	var/center_x = world_x + delta_x / 2
	var/center_y = world_y + delta_y / 2
	var/list/vessels = list()
	var/max_travel = 0
	if(clear_from && (!clear_from.hull_turfs || !clear_from.hull_turf_at(world_x, world_y)))
		clear_from = null
	for(var/obj/overmap/entity/vessel as anything in SSovermap.flight_index.nearby(sector, center_x, center_y, distance / 2 + 1))
		if(vessel == clear_from || vessel.sector != sector || (vessel.overmap_pod && vessel.overmap_pod.pod() == payload.firer_source_atom))
			continue
		var/list/previous = SSovermap.projectile_poses[vessel]
		var/list/pose = previous && previous[4] == sector ? previous : list(vessel.get_world_x(), vessel.get_world_y(), vessel.get_facing())
		var/travel = sqrt((vessel.get_world_x() - pose[1]) ** 2 + (vessel.get_world_y() - pose[2]) ** 2) + abs(TORADIANS(closer_angle_difference(pose[3], vessel.get_facing()))) * vessel.hull_radius
		var/fraction = distance ? clamp(((vessel.get_world_x() - world_x) * delta_x + (vessel.get_world_y() - world_y) * delta_y) / (distance * distance), 0, 1) : 0
		var/near_x = world_x + delta_x * fraction
		var/near_y = world_y + delta_y * fraction
		if((vessel.get_world_x() - near_x) ** 2 + (vessel.get_world_y() - near_y) ** 2 > (vessel.hull_radius + travel + 1) ** 2)
			continue
		if(abs(vessel.get_world_x() - center_x) <= vessel.hull_radius + distance / 2 + travel + 1 && abs(vessel.get_world_y() - center_y) <= vessel.hull_radius + distance / 2 + travel + 1)
			vessels[vessel] = list(pose[1], pose[2], pose[3], vessel.get_world_x() - pose[1], vessel.get_world_y() - pose[2], closer_angle_difference(pose[3], vessel.get_facing()))
			max_travel = max(max_travel, travel)
	var/list/fields = SSovermap.scatter_fields_at(sector, center_x, center_y, distance / 2 + 1)
	var/list/spaces = list()
	for(var/datum/overmap_bubble/space as anything in SSovermap.bubbles)
		if(!space.static_level || space.sector != sector)
			continue
		var/list/region = space.ensure_region()
		if(region && center_x + distance / 2 + 1 >= region[1] && center_x - distance / 2 - 1 <= region[3] && center_y + distance / 2 + 1 >= region[2] && center_y - distance / 2 - 1 <= region[4])
			spaces += space
	if(!length(vessels) && !length(fields) && !length(spaces))
		world_x += delta_x
		world_y += delta_y
		if(!in_bounds(world_x, world_y))
			qdel(src)
		return
	var/list/empty_turfs = list()
	var/steps = max(1, CEILING((distance + max_travel) / 0.4, 1))
	var/list/sample_pose = list(0, 0, 0)
	for(var/step in 1 to steps)
		var/x = world_x + delta_x * step / steps
		var/y = world_y + delta_y * step / steps
		if(!in_bounds(x, y))
			qdel(src)
			return
		for(var/obj/overmap/entity/vessel as anything in vessels)
			var/list/previous = vessels[vessel]
			var/fraction = step / steps
			var/pose_x = previous[1] + previous[4] * fraction
			var/pose_y = previous[2] + previous[5] * fraction
			if((x - pose_x) ** 2 + (y - pose_y) ** 2 > (vessel.hull_radius + 1) ** 2)
				continue
			var/pose_facing = previous[3] + previous[6] * fraction
			if(istype(vessel, /obj/overmap/entity/virtual_structure))
				sample_pose[1] = pose_x
				sample_pose[2] = pose_y
				sample_pose[3] = pose_facing
				if(virtual_hit(vessel, x, y, sample_pose))
					return
				continue
			var/own_hull = payload.overmap_firer_vessel && (vessel.docked_ship || vessel) == (payload.overmap_firer_vessel.docked_ship || payload.overmap_firer_vessel)
			if(own_hull && vessel.overmap_pod)
				continue
			var/turf/spot = vessel.hull_turf_at(x, y, pose_x, pose_y, pose_facing)
			if(!spot || empty_turfs[spot])
				continue
			var/list/local_point = vessel.world_to_hull(x, y, pose_x, pose_y, pose_facing)
			var/pixel_x = (local_point[1] - spot.x) * ICON_SIZE_X
			var/pixel_y = (local_point[2] - spot.y) * ICON_SIZE_Y
			if(vessel.overmap_pod)
				var/obj/spacepod/pod = vessel.overmap_pod.pod()
				if(pod in payload.permutated)
					continue
				world_x = x
				world_y = y
				payload.record_overmap_hit(vessel)
				materialize(spot, angle - pose_facing, pod, pixel_x, pixel_y)
			else
				var/atom/target = payload.sector_target_at(spot)
				if(!target)
					empty_turfs[spot] = TRUE
					continue
				world_x = x
				world_y = y
				payload.record_overmap_hit(vessel)
				materialize(spot, angle - pose_facing, target, pixel_x, pixel_y)
			return
		for(var/datum/overmap_bubble/space as anything in spaces)
			var/list/local_point = space.to_bubble(x, y)
			if(local_point[1] < space.bounds[1] - 0.5 || local_point[1] >= space.bounds[3] + 0.5 || local_point[2] < space.bounds[2] - 0.5 || local_point[2] >= space.bounds[4] + 0.5)
				continue
			var/turf/spot = locate(FLOOR(local_point[1] + 0.5, 1), FLOOR(local_point[2] + 0.5, 1), space.bubble_z)
			if(!spot || empty_turfs[spot])
				continue
			var/atom/target = payload.sector_target_at(spot)
			if(target)
				world_x = x
				world_y = y
				materialize(spot, angle, target, (local_point[1] - spot.x) * ICON_SIZE_X, (local_point[2] - spot.y) * ICON_SIZE_Y)
				return
			empty_turfs[spot] = TRUE
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
		for(var/list/viewport as anything in frames[owner])
			var/turf/eye = viewport[1]
			if(abs(spot[1] - eye.x) <= viewport[2] && abs(spot[2] - eye.y) <= viewport[3])
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
	for(var/datum/owner as anything in proxies)
		if(!wanted[owner])
			qdel(proxies[owner])
			proxies -= owner
