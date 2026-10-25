#define OVERMAP_RAM_FRICTION 0.4
#define OVERMAP_RAM_SEPARATION (0.2 / (1 SECONDS))
#define OVERMAP_RAM_PUSH_OUT 0.5
#define OVERMAP_RAM_SWEEP_STEP 0.4
#define OVERMAP_RAM_REFINE_STEPS 4
#define OVERMAP_RAM_SOUND_SPEED 1
#define OVERMAP_RAM_SHAKE_SPEED 2
#define OVERMAP_RAM_THROW_SPEED 8
#define OVERMAP_RAM_MAX_THROW 4
#define OVERMAP_RAM_EFFECT_COOLDOWN (1 SECONDS)

/obj/overmap/entity
	var/next_ram_damage = 0

/proc/overmap_impact_damage(impact_speed)
	return clamp(impact_speed * 2, 0, 60) * 10

/proc/overmap_contact_health(turf/spot)
	if(!spot)
		return 1
	if(istype(spot, /turf/simulated/wall/indestructible))
		return 1000000
	var/health = isspaceturf(spot) ? 0 : 25
	if(istype(spot, /turf/simulated/wall))
		var/turf/simulated/wall/wall = spot
		health = max(1, wall.damage_cap - wall.damage)
	else if(spot.density)
		return 1000000
	for(var/obj/object in spot)
		if(!object.density || !object.simulated || QDELETED(object))
			continue
		if(object.resistance_flags & INDESTRUCTIBLE)
			return 1000000
		if(isspacepod(object))
			var/obj/spacepod/pod = object
			health += max(0, pod.health)
		else
			health += max(0, object.obj_integrity)
	return max(1, health)

/proc/overmap_contact_damage(energy, own_health, target_health)
	return energy * target_health / max(own_health + target_health, 1)

/proc/overmap_damage_turf(turf/spot, damage)
	if(!spot || damage <= 0)
		return
	var/was_wall = istype(spot, /turf/simulated/wall)
	var/hit_object = FALSE
	if(istype(spot, /turf/simulated/wall) && !istype(spot, /turf/simulated/wall/indestructible))
		var/turf/simulated/wall/wall = spot
		var/x = spot.x
		var/y = spot.y
		var/z = spot.z
		wall.take_damage(damage)
		spot = locate(x, y, z)
	for(var/obj/object in spot.contents.Copy())
		if(!object.simulated || QDELETED(object))
			continue
		if(object.density)
			hit_object = TRUE
		if(object.resistance_flags & INDESTRUCTIBLE)
			continue
		if(isspacepod(object))
			var/obj/spacepod/pod = object
			pod.deal_damage(damage)
		else
			object.take_damage(damage, BRUTE, MELEE, FALSE, null, 100)
	for(var/mob/living/victim in spot)
		victim.apply_damage(damage, BRUTE)
	if(was_wall || hit_object)
		return
	if(istype(spot, /turf/simulated/floor) && damage >= 25)
		spot.ex_act(EXPLODE_DEVASTATE)
	else if(damage >= 250)
		spot.ex_act(EXPLODE_DEVASTATE)
	else if(damage >= 150)
		spot.ex_act(EXPLODE_HEAVY)
	else if(damage >= 60)
		spot.ex_act(EXPLODE_LIGHT)

/obj/overmap/entity/proc/damage_impact(list/contacts, impact_speed, obj/overmap/entity/other)
	if(impact_speed < 1 || world.time < next_ram_damage)
		return 1
	next_ram_damage = world.time + OVERMAP_FLIGHT_TICK
	var/energy = mass_impact_damage(impact_speed, other)
	var/list/own_damage = list()
	var/list/target_damage = list()
	var/loss = 0
	var/blocked = FALSE
	for(var/list/contact as anything in contacts)
		var/turf/own = contact[1]
		var/turf/target = contact[2]
		var/own_health = overmap_pod ? max(1, overmap_pod.pod().health) : overmap_contact_health(own)
		var/target_health = other?.overmap_pod ? max(1, other.overmap_pod.pod().health) : overmap_contact_health(target)
		var/damage_to_own = overmap_contact_damage(energy, own_health, target_health)
		var/damage_to_target = overmap_contact_damage(energy, target_health, own_health)
		own_damage[own] = max(own_damage[own], damage_to_own)
		target_damage[target] = max(target_damage[target], damage_to_target)
		loss = max(loss, clamp(target_health / max(damage_to_target, 1), 0.02, 1))
	if(overmap_pod)
		var/damage = 0
		for(var/turf/spot as anything in own_damage)
			damage = max(damage, own_damage[spot])
		overmap_pod.pod().deal_damage(damage)
	else
		for(var/turf/spot as anything in own_damage)
			overmap_damage_turf(spot, own_damage[spot])
	if(other?.overmap_pod)
		var/damage = 0
		for(var/turf/spot as anything in target_damage)
			damage = max(damage, target_damage[spot])
		other.overmap_pod.pod().deal_damage(damage)
	else
		for(var/turf/spot as anything in target_damage)
			var/x = spot.x
			var/y = spot.y
			var/z = spot.z
			overmap_damage_turf(spot, target_damage[spot])
			var/turf/remaining = locate(x, y, z)
			if(remaining.is_blocked_turf(exclude_mobs = TRUE))
				blocked = TRUE
	if(blocked)
		return 1
	if(other?.overmap_pod?.pod()?.health > 0)
		return 1
	return loss

/obj/overmap/entity/proc/remember_pose()
	last_world_x = get_world_x()
	last_world_y = get_world_y()
	last_facing = get_facing()

/obj/overmap/entity/on_sector_wrap(delta_x, delta_y)
	var/span = OVERMAP_TILE_SPAN * (sector?.tile_travel || 1)
	shift_previous_pose(delta_x * span, delta_y * span)
	for(var/obj/overmap/entity/guest as anything in docked_guests)
		guest.shift_previous_pose(delta_x * span, delta_y * span)
	QDEL_NULL(docking_approach)
	radar_docks_until = 0

/obj/overmap/entity/proc/shift_previous_pose(delta_x, delta_y)
	if(isnull(last_world_x))
		return
	last_world_x += delta_x
	last_world_y += delta_y

/obj/overmap/entity/proc/pose_at(fraction)
	var/world_x = get_world_x()
	var/world_y = get_world_y()
	var/facing = get_facing()
	if(isnull(last_world_x))
		return list(world_x, world_y, facing)
	return list(last_world_x + (world_x - last_world_x) * fraction, last_world_y + (world_y - last_world_y) * fraction, last_facing + closer_angle_difference(last_facing, facing) * fraction)

/obj/overmap/entity/proc/pose_travel()
	if(isnull(last_world_x))
		return 0
	return sqrt((get_world_x() - last_world_x) ** 2 + (get_world_y() - last_world_y) ** 2) + TORADIANS(abs(closer_angle_difference(last_facing, get_facing()))) * hull_radius

/obj/overmap/entity/proc/set_pose(list/pose)
	flight.set_facing(pose[3])
	set_world_position(pose[1], pose[2])
	for(var/obj/overmap/entity/guest as anything in docked_guests)
		guest.follow_host()

/obj/overmap/entity/proc/push_out(normal_x, normal_y)
	set_pose(list(get_world_x() + normal_x * OVERMAP_RAM_PUSH_OUT, get_world_y() + normal_y * OVERMAP_RAM_PUSH_OUT, get_facing()))

/obj/overmap/entity/proc/collision_space()
	var/obj/overmap/entity/body = docked_ship || src
	return body.local_space

/obj/overmap/entity/proc/contacts_at(fraction, obj/overmap/entity/other)
	. = list()
	var/list/pose = pose_at(fraction)
	var/list/other_pose = other?.pose_at(fraction)
	var/datum/overmap_bubble/space = collision_space()
	var/cos_facing = cos(pose[3])
	var/sin_facing = sin(pose[3])
	var/cos_other = other && cos(other_pose[3])
	var/sin_other = other && sin(other_pose[3])
	var/drift_x = space?.drift_x()
	var/drift_y = space?.drift_y()
	for(var/turf/hull_turf as anything in hull_edge)
		if(other?.overmap_pod && !hull_turf.is_blocked_turf(exclude_mobs = TRUE))
			continue
		var/local_x = hull_turf.x - hull_center_x
		var/local_y = hull_turf.y - hull_center_y
		var/world_x = pose[1] + local_x * cos_facing + local_y * sin_facing
		var/world_y = pose[2] - local_x * sin_facing + local_y * cos_facing
		var/turf/struck
		if(other)
			var/delta_x = world_x - other_pose[1]
			var/delta_y = world_y - other_pose[2]
			var/hull_x = other.hull_center_x + delta_x * cos_other - delta_y * sin_other
			var/hull_y = other.hull_center_y + delta_x * sin_other + delta_y * cos_other
			struck = locate(FLOOR(hull_x + 0.5, 1), FLOOR(hull_y + 0.5, 1), other.hull_z)
			if(!other.hull_turfs[struck])
				continue
		else
			var/bubble_x = space.center_x + world_x - space.origin_x - drift_x
			var/bubble_y = space.center_y + world_y - space.origin_y - drift_y
			if(bubble_x < space.bounds[1] || bubble_x > space.bounds[3] || bubble_y < space.bounds[2] || bubble_y > space.bounds[4])
				continue
			struck = locate(CEILING(bubble_x - 0.5, 1), CEILING(bubble_y - 0.5, 1), space.bubble_z)
			if(!space.is_solid(struck))
				continue
		if(!other?.overmap_pod && !struck?.is_blocked_turf(exclude_mobs = TRUE))
			continue
		if(struck)
			. += list(list(hull_turf, struck, list(world_x, world_y)))

/obj/overmap/entity/proc/find_impact(obj/overmap/entity/other)
	var/steps = max(CEILING((pose_travel() + other?.pose_travel()) / OVERMAP_RAM_SWEEP_STEP, 1), 1)
	var/safe = 0
	for(var/step in 1 to steps)
		var/list/contacts = contacts_at(step / steps, other)
		if(!length(contacts))
			safe = step / steps
			continue
		var/hit = step / steps
		for(var/refine in 1 to OVERMAP_RAM_REFINE_STEPS)
			var/middle = (safe + hit) / 2
			var/list/middle_contacts = contacts_at(middle, other)
			if(length(middle_contacts))
				hit = middle
				contacts = middle_contacts
			else
				safe = middle
		return list(safe, contacts)

/obj/overmap/entity/proc/hull_face(turf/hull_turf)
	var/face_x = 0
	var/face_y = 0
	for(var/direction in GLOB.cardinal)
		if(hull_turfs[get_step(hull_turf, direction)])
			continue
		face_x += (direction & EAST) ? 1 : ((direction & WEST) ? -1 : 0)
		face_y += (direction & NORTH) ? 1 : ((direction & SOUTH) ? -1 : 0)
	var/facing = get_facing()
	return list(face_x * cos(facing) + face_y * sin(facing), face_y * cos(facing) - face_x * sin(facing))

/datum/overmap_bubble/proc/is_solid(turf/spot)
	return spot && spot.is_blocked_turf(exclude_mobs = TRUE)

/datum/overmap_bubble/proc/solid_turf_at(world_x, world_y)
	var/turf/spot = turf_at(world_x, world_y)
	return is_solid(spot) ? spot : null

/datum/overmap_bubble/proc/solid_face(turf/spot)
	var/face_x = 0
	var/face_y = 0
	for(var/direction in GLOB.cardinal)
		if(is_solid(get_step(spot, direction)))
			continue
		face_x += (direction & EAST) ? 1 : ((direction & WEST) ? -1 : 0)
		face_y += (direction & NORTH) ? 1 : ((direction & SOUTH) ? -1 : 0)
	return list(face_x, face_y)

/obj/overmap/entity/proc/collide(obj/overmap/entity/other)
	if(istype(other, /obj/overmap/entity/virtual_structure))
		return collide_virtual(other)
	if(other && istype(src, /obj/overmap/entity/virtual_structure))
		return other.collide_virtual(src)
	if(navigation_collision_disabled() || other?.navigation_collision_disabled())
		return
	var/list/impact = find_impact(other)
	if(!impact)
		return
	var/list/contacts = impact[2]
	var/overlapping = !impact[1] && length(contacts_at(0, other))
	var/obj/overmap/entity/body = docked_ship || src
	var/obj/overmap/entity/other_body = other && (other.docked_ship || other)
	body.set_pose(body.pose_at(impact[1]))
	other_body?.set_pose(other_body.pose_at(impact[1]))
	if(!impact[1])
		body.flight.angular_velocity = 0
		if(other_body)
			other_body.flight.angular_velocity = 0
	var/datum/overmap_bubble/space = collision_space()
	var/normal_x = 0
	var/normal_y = 0
	var/point_x = 0
	var/point_y = 0
	for(var/list/contact as anything in contacts)
		var/list/spot = contact[3]
		point_x += spot[1]
		point_y += spot[2]
		var/list/own_face = hull_face(contact[1])
		var/list/struck_face = other ? other.hull_face(contact[2]) : space.solid_face(contact[2])
		normal_x += struck_face[1] - own_face[1]
		normal_y += struck_face[2] - own_face[2]
	point_x /= length(contacts)
	point_y /= length(contacts)
	if(!normal_x && !normal_y)
		normal_x = body.get_world_x() - point_x
		normal_y = body.get_world_y() - point_y
	var/normal_length = sqrt(normal_x ** 2 + normal_y ** 2)
	if(!normal_length)
		return
	normal_x /= normal_length
	normal_y /= normal_length
	if(overlapping)
		body.push_out(normal_x, normal_y)
		other_body?.push_out(-normal_x, -normal_y)
	body.ram(other_body, normal_x, normal_y, point_x, point_y, impact[1] ? 0 : OVERMAP_RAM_SEPARATION, !overlapping, contacts)

/obj/overmap/entity/proc/point_velocity(arm_x, arm_y)
	var/spin = TORADIANS(flight?.angular_velocity || 0)
	return list(speed[1] * OVERMAP_TILE_SPAN + spin * arm_y, speed[2] * OVERMAP_TILE_SPAN - spin * arm_x)

/obj/overmap/entity/proc/collision_inverse_mass()
	return flight && movable ? 1 / max(total_mass(), 1) : 0

/obj/overmap/entity/proc/mass_impact_damage(impact_speed, obj/overmap/entity/other)
	var/inverse_mass = collision_inverse_mass() + (other ? other.collision_inverse_mass() : 0)
	return inverse_mass > 0 ? overmap_impact_damage(impact_speed) / (inverse_mass * OVERMAP_IMPACT_REFERENCE_MASS) : 0

/obj/overmap/entity/proc/impulse_response(arm_x, arm_y, direction_x, direction_y)
	var/inverse_mass = collision_inverse_mass()
	return inverse_mass + inverse_mass / hull_inertia * (arm_x * direction_y - arm_y * direction_x) ** 2

/obj/overmap/entity/proc/apply_impulse(impulse_x, impulse_y, arm_x, arm_y)
	var/inverse_mass = collision_inverse_mass()
	if(!inverse_mass)
		return 0
	speed[1] += impulse_x * inverse_mass / OVERMAP_TILE_SPAN
	speed[2] += impulse_y * inverse_mass / OVERMAP_TILE_SPAN
	var/spin_change = TODEGREES(-(arm_x * impulse_y - arm_y * impulse_x) * inverse_mass / hull_inertia)
	flight.angular_velocity = clamp(flight.angular_velocity + spin_change, -OVERMAP_TURN_RATE_MAX, OVERMAP_TURN_RATE_MAX)
	return sqrt(impulse_x ** 2 + impulse_y ** 2) * inverse_mass * (1 SECONDS)

/obj/overmap/entity/proc/ram(obj/overmap/entity/other, normal_x, normal_y, point_x, point_y, separation, entering, list/contacts, impulse_scale = 1)
	if(navigation_collision_disabled() || other?.navigation_collision_disabled())
		return
	var/arm_x = point_x - get_world_x()
	var/arm_y = point_y - get_world_y()
	var/other_arm_x = other ? point_x - other.get_world_x() : 0
	var/other_arm_y = other ? point_y - other.get_world_y() : 0
	var/list/velocity = point_velocity(arm_x, arm_y)
	var/list/other_velocity = other ? other.point_velocity(other_arm_x, other_arm_y) : list(0, 0)
	var/relative_x = velocity[1] - other_velocity[1]
	var/relative_y = velocity[2] - other_velocity[2]
	var/approach = relative_x * normal_x + relative_y * normal_y
	if(approach >= separation)
		var/relative_speed = sqrt(relative_x ** 2 + relative_y ** 2)
		if(!entering || !relative_speed)
			return
		normal_x = -relative_x / relative_speed
		normal_y = -relative_y / relative_speed
		approach = -relative_speed
	var/normal_response = impulse_response(arm_x, arm_y, normal_x, normal_y) + (other ? other.impulse_response(other_arm_x, other_arm_y, normal_x, normal_y) : 0)
	if(normal_response <= 0)
		return
	var/normal_impulse = (separation - approach) / normal_response
	normal_impulse *= impulse_scale
	var/impact_speed = -approach * (1 SECONDS)
	if(length(contacts))
		normal_impulse *= damage_impact(contacts, impact_speed, other)
	var/impulse_x = normal_impulse * normal_x
	var/impulse_y = normal_impulse * normal_y
	var/tangent_x = relative_x - approach * normal_x
	var/tangent_y = relative_y - approach * normal_y
	var/tangent_speed = sqrt(tangent_x ** 2 + tangent_y ** 2)
	if(tangent_speed > 0)
		tangent_x /= tangent_speed
		tangent_y /= tangent_speed
		var/tangent_response = impulse_response(arm_x, arm_y, tangent_x, tangent_y) + (other ? other.impulse_response(other_arm_x, other_arm_y, tangent_x, tangent_y) : 0)
		var/friction_impulse = min(tangent_speed / tangent_response, OVERMAP_RAM_FRICTION * normal_impulse)
		impulse_x -= friction_impulse * tangent_x
		impulse_y -= friction_impulse * tangent_y
	var/kick = apply_impulse(impulse_x, impulse_y, arm_x, arm_y)
	var/other_kick = other?.apply_impulse(-impulse_x, -impulse_y, other_arm_x, other_arm_y)
	if(max(kick, other_kick) >= OVERMAP_RAM_THROW_SPEED && world.time >= next_ram_effect)
		log_game("Overmap collision: [get_overmap_display_name()] hit [other ? other.get_overmap_display_name() : "station structures"] at [round(impact_speed, 0.1)] m/s")
	feel_impact(impact_speed, kick, -impulse_x, -impulse_y)
	other?.feel_impact(impact_speed, other_kick, impulse_x, impulse_y)

/obj/overmap/entity/proc/feel_impact(impact_speed, kick, push_x, push_y)
	if(impact_speed < OVERMAP_RAM_SOUND_SPEED || world.time < next_ram_effect)
		return
	next_ram_effect = world.time + OVERMAP_RAM_EFFECT_COOLDOWN
	var/hard = kick >= OVERMAP_RAM_THROW_SPEED
	var/facing = get_facing()
	var/throw_dir = angle2dir(delta_to_angle(push_x * cos(facing) - push_y * sin(facing), push_x * sin(facing) + push_y * cos(facing)))
	var/throw_range = clamp(round(kick / OVERMAP_RAM_THROW_SPEED), 1, OVERMAP_RAM_MAX_THROW)
	for(var/obj/overmap/entity/part as anything in list(src) + docked_guests)
		part.play_shuttle_sound(hard ? 'sound/effects/meteorimpact.ogg' : 'sound/effects/clang.ogg', clamp(impact_speed * 10, 20, 100))
		if(kick >= OVERMAP_RAM_SHAKE_SPEED)
			part.shake_shuttle(min(kick, 10), clamp(round(kick / OVERMAP_RAM_SHAKE_SPEED / 2), 1, 3))
		if(!hard)
			continue
		if(!part.shuttle)
			continue
		for(var/area/place as anything in part.shuttle.shuttle_areas)
			for(var/mob/living/passenger in place)
				if(passenger.buckled || HAS_TRAIT(passenger, TRAIT_NEGATES_GRAVITY))
					continue
				passenger.Knockdown(2 SECONDS)
				passenger.throw_at(get_ranged_target_turf(passenger, throw_dir, throw_range), throw_range, 1)

/datum/controller/subsystem/overmap/proc/process_collisions(list/flying)
	for(var/obj/overmap/entity/vessel as anything in flying)
		if(vessel.formation_transfer || vessel.formation_pad || vessel.docking_approach?.aligning || vessel.navigation_collision_disabled())
			continue
		var/datum/overmap_bubble/space = vessel.collision_space()
		if(!space)
			continue
		if(space.terrain_near(space.to_bubble(vessel.get_world_x(), vessel.get_world_y()), vessel.hull_radius + vessel.pose_travel() + 1))
			vessel.collide()
	for(var/index in 1 to length(flying))
		var/obj/overmap/entity/vessel = flying[index]
		if(vessel.formation_transfer || vessel.formation_pad)
			continue
		var/obj/overmap/entity/body = vessel.docked_ship || vessel
		for(var/other_index in index + 1 to length(flying))
			var/obj/overmap/entity/other = flying[other_index]
			if(other.formation_transfer || other.formation_pad || other.sector != vessel.sector || (other.docked_ship || other) == body || vessel.docking_approach?.aligning || other.docking_approach?.aligning || vessel.navigation_collision_disabled() || other.navigation_collision_disabled())
				continue
			var/reach = vessel.hull_radius + other.hull_radius + vessel.pose_travel() + other.pose_travel()
			if(sqrt((vessel.get_world_x() - other.get_world_x()) ** 2 + (vessel.get_world_y() - other.get_world_y()) ** 2) > reach)
				continue
			vessel.collide(other)

/obj/projectile/proc/cross_frames(angle_offset)
	set_angle(SIMPLIFY_DEGREES(Angle + angle_offset))
	transform = matrix().Turn(Angle)

#undef OVERMAP_RAM_FRICTION
#undef OVERMAP_RAM_SEPARATION
#undef OVERMAP_RAM_PUSH_OUT
#undef OVERMAP_RAM_SWEEP_STEP
#undef OVERMAP_RAM_REFINE_STEPS
#undef OVERMAP_RAM_SOUND_SPEED
#undef OVERMAP_RAM_SHAKE_SPEED
#undef OVERMAP_RAM_THROW_SPEED
#undef OVERMAP_RAM_MAX_THROW
#undef OVERMAP_RAM_EFFECT_COOLDOWN

/proc/overmap_tiles_overlap(delta_x, delta_y, cosine, sine)
	var/extent = (1 + abs(cosine) + abs(sine)) / 2 - OVERMAP_MOVE_RESOLUTION
	return abs(delta_x) < extent && abs(delta_y) < extent && abs(delta_x * cosine + delta_y * sine) < extent && abs(delta_y * cosine - delta_x * sine) < extent

/obj/overmap/entity/proc/solid_hull_at(world_x, world_y)
	var/list/point = world_to_hull(world_x, world_y)
	var/cosine = cos(get_facing())
	var/sine = sin(get_facing())
	var/center_x = FLOOR(point[1] + 0.5, 1)
	var/center_y = FLOOR(point[2] + 0.5, 1)
	for(var/tile_x in center_x - 1 to center_x + 1)
		for(var/tile_y in center_y - 1 to center_y + 1)
			var/turf/tile = locate(tile_x, tile_y, hull_z)
			if(!hull_turfs[tile] || !overmap_tiles_overlap(point[1] - tile_x, point[2] - tile_y, cosine, sine))
				continue
			if(tile.is_blocked_turf(exclude_mobs = TRUE))
				return tile
