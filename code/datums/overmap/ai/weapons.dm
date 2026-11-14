/datum/overmap_ship_ai/proc/aim_at_point(obj/machinery/mount, aim_x, aim_y, velocity_x = 0, velocity_y = 0)
	var/shot_type = weapon_projectile_type(mount)
	if(!ispath(shot_type, /obj/projectile))
		return null
	var/obj/projectile/prototype = shot_type
	var/list/origin = weapon_data(mount)["position"]
	var/list/inherited = owner.projectile_inherited_velocity(origin[1], origin[2])
	var/relative_x = velocity_x - inherited[1]
	var/relative_y = velocity_y - inherited[2]
	var/obj/overmap/entity/carrier = owner.docked_ship || owner
	var/turn_speed = weapon_data(mount)["muzzle_distance"] * TORADIANS(carrier.flight?.angular_velocity || 0) * (1 SECONDS)
	var/shot_speed = initial(prototype.overmap_velocity)
	var/time = overmap_ai_intercept(aim_x - origin[1], aim_y - origin[2], relative_x, relative_y, shot_speed, weapon_data(mount)["muzzle_distance"], turn_speed)
	if(isnull(time) || time > 90)
		return null
	var/dx = aim_x + relative_x * time - origin[1]
	var/dy = aim_y + relative_y * time - origin[2]
	var/forward = weapon_data(mount)["muzzle_distance"] + shot_speed * time
	var/correction = forward > 0 ? arctan(turn_speed * time / forward) : 0
	var/angle = delta_to_angle(dx, dy) - correction
	var/distance = sqrt(dx ** 2 + dy ** 2)
	return list(origin[1] + sin(angle) * distance, origin[2] + cos(angle) * distance)

/datum/overmap_ship_ai/proc/clear_shot(obj/machinery/mount, list/aim, obj/overmap/entity/intended_target = target, facing = owner.get_facing())
	var/list/start = projected_weapon_position(mount, facing)
	var/angle = delta_to_angle(aim[1] - start[1], aim[2] - start[2])
	start[1] += sin(angle) * weapon_data(mount)["muzzle_distance"]
	start[2] += cos(angle) * weapon_data(mount)["muzzle_distance"]
	if(!safe_firing_path(mount, start, angle, facing))
		return FALSE
	var/dx = aim[1] - start[1]
	var/dy = aim[2] - start[2]
	var/length_squared = dx ** 2 + dy ** 2
	if(length_squared <= 0.001)
		return FALSE
	var/range = sqrt(length_squared)
	for(var/list/entry as anything in controller.nearby(owner.sector, (start[1] + aim[1]) / 2, (start[2] + aim[2]) / 2, range / 2 + 1))
		if(entry["ship"] == owner || (order?["kind"] != "suppress" && entry["ship"] == intended_target))
			continue
		if(order?["kind"] == "suppress" && hostile_to(entry["ship"]))
			continue
		var/fraction = clamp(((entry["x"] - start[1]) * dx + (entry["y"] - start[2]) * dy) / length_squared, 0, 1)
		if((entry["x"] - start[1] - dx * fraction) ** 2 + (entry["y"] - start[2] - dy * fraction) ** 2 <= (entry["radius"] + 1) ** 2)
			return FALSE
	return TRUE

/datum/overmap_ship_ai/proc/safe_firing_path(obj/machinery/gun, list/start, angle, facing = owner.get_facing())
	if(facing != owner.get_facing())
		var/list/local = owner.world_to_hull(start[1], start[2], facing = facing)
		start = owner.hull_to_world(local[1], local[2])
		angle -= closer_angle_difference(owner.get_facing(), facing)
	var/distance = min(sqrt((start[1] - owner.get_world_x()) ** 2 + (start[2] - owner.get_world_y()) ** 2) + overmap_ai_radius(owner) * 2 + 2, 10000)
	var/obj/overmap/entity/virtual_structure/virtual = owner
	for(var/step in 0 to distance step 0.4)
		var/x = start[1] + sin(angle) * step
		var/y = start[2] + cos(angle) * step
		if(istype(virtual))
			var/list/cell = virtual.cell_at(x, y, TRUE)
			if(cell && (gun.virtual_weapon_owner != owner || cell[1] != gun.virtual_weapon_x || cell[2] != gun.virtual_weapon_y))
				return FALSE
			continue
		var/turf/spot = owner.free_flight_view ? owner.hull_turf_at(x, y) : owner.physical_space?.turf_at(x, y)
		if(!spot)
			continue
		if(spot.density)
			return FALSE
		for(var/atom/movable/obstacle in spot)
			if(obstacle != gun && obstacle.simulated && obstacle.density)
				return FALSE
	return TRUE

/datum/overmap_ship_ai/proc/projected_weapon_position(obj/machinery/gun, facing)
	var/list/point = weapon_data(gun)["position"]
	if(facing == owner.get_facing())
		return list(point[1], point[2])
	var/list/local = owner.world_to_hull(point[1], point[2])
	return owner.hull_to_world(local[1], local[2], facing = facing)

/datum/overmap_ship_ai/proc/facing_score(facing, list/mounts, list/aims, check_clearance = FALSE)
	var/count = 0
	var/fit = 0
	for(var/obj/machinery/gun as anything in mounts)
		var/list/aim = aims[gun]
		if(!aim)
			continue
		var/list/point = projected_weapon_position(gun, facing)
		var/barrel = facing + weapon_data(gun)["heading"] - owner.get_facing()
		if(abs(closer_angle_difference(barrel, delta_to_angle(aim[1] - point[1], aim[2] - point[2]))) > weapon_data(gun)["arc"] / 2)
			continue
		if(check_clearance && !clear_shot(gun, aim, weapon_targets[gun], facing))
			continue
		count++
		var/obj/overmap/entity/contact = weapon_targets[gun]
		if(contact)
			fit += weapon_target_fit(gun, contact)
	return count * 1000 + fit * 10 - abs(closer_angle_difference(owner.get_facing(), facing)) / 180

/datum/overmap_ship_ai/proc/choose_firing_facing(list/mounts, list/aims)
	var/list/scores = list()
	var/list/headings = list(owner.get_facing(), wanted_facing)
	for(var/obj/machinery/gun as anything in mounts)
		var/list/aim = aims[gun]
		if(!aim)
			continue
		var/list/point = weapon_data(gun)["position"]
		var/ideal = delta_to_angle(aim[1] - point[1], aim[2] - point[2]) - weapon_data(gun)["heading"] + owner.get_facing()
		var/half_arc = max(0, weapon_data(gun)["arc"] / 2 - 0.25)
		headings |= list(ideal, ideal - half_arc, ideal + half_arc)
	for(var/facing in headings)
		scores["[facing]"] = facing_score(facing, mounts, aims)
	var/best_heading = owner.get_facing()
	var/best_score = facing_score(best_heading, mounts, aims, TRUE)
	for(var/attempt in 1 to min(4, length(scores)))
		var/candidate
		var/candidate_score = -INFINITY
		for(var/angle, score in scores)
			if(score > candidate_score)
				candidate = angle
				candidate_score = score
		scores -= candidate
		var/heading = text2num(candidate)
		var/score = facing_score(heading, mounts, aims, TRUE)
		if(score > best_score)
			best_score = score
			best_heading = heading
	wanted_facing = SIMPLIFY_DEGREES(best_heading)

/datum/overmap_ship_ai/proc/burst_aim(obj/machinery/mount)
	weapon_snapshots.Cut()
	if(enabled && order?["kind"] == "suppress")
		return suppression_aim(mount)
	var/obj/overmap/entity/contact = weapon_targets[mount]
	if(!enabled || QDELETED(contact) || contact.is_ai_destroyed() || !can_see(controller.contacts[contact]) || (!is_ordered_target(contact) && !hostile_to(contact)) || !within_fire_range(mount, contact.get_world_x(), contact.get_world_y(), overmap_ai_radius(contact)))
		return null
	var/list/aim = aim_at_point(mount, contact.get_world_x(), contact.get_world_y(), contact.speed[1] * OVERMAP_TILE_SPAN * (1 SECONDS), contact.speed[2] * OVERMAP_TILE_SPAN * (1 SECONDS))
	return aim && clear_shot(mount, aim, contact) ? aim : null

/datum/overmap_ship_ai/proc/aim_and_fire()
	var/area_fire = order?["kind"] == "suppress"
	if(area_fire)
		weapon_targets.Cut()
	else
		select_weapon_targets()
	var/list/ready = list()
	var/list/active = list()
	var/list/aims = list()
	for(var/obj/machinery/gun as anything in weapons)
		if(!weapon_operational(gun))
			continue
		var/obj/overmap/entity/contact = weapon_targets[gun]
		var/list/aim
		if(area_fire)
			aim = aim_at_point(gun, order["x"], order["y"])
		else if(!QDELETED(contact))
			aim = aim_at_point(gun, contact.get_world_x(), contact.get_world_y(), contact.speed[1] * OVERMAP_TILE_SPAN * (1 SECONDS), contact.speed[2] * OVERMAP_TILE_SPAN * (1 SECONDS))
		if(!aim)
			continue
		aims[gun] = aim
		active += gun
		if(world.time >= weapon_data(gun)["next_fire"])
			ready += gun
	if(!owner.stationary_ai)
		choose_firing_facing(length(ready) ? ready : active, aims)
	for(var/obj/machinery/gun as anything in ready)
		var/list/aim = aims[gun]
		var/obj/overmap/entity/contact = area_fire ? null : weapon_targets[gun]
		if(SEND_SIGNAL(gun, COMSIG_OVERMAP_WEAPON_CAN_AIM, owner, aim[1], aim[2]) && clear_shot(gun, aim, contact))
			report(area_fire ? "suppress" : "fire", contact)
			SEND_SIGNAL(gun, COMSIG_OVERMAP_WEAPON_FIRE, owner, aim[1], aim[2], null, FALSE)
			weapon_snapshots -= gun
