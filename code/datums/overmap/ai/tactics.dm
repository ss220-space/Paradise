/datum/overmap_ship_ai/proc/effective_role()
	if(role == "heavy" && !controller.medium_cover[controller.group_key(src)])
		return "medium"
	return role

/datum/overmap_ship_ai/proc/think()
	if(QDELETED(owner) || !owner.sector || !isturf(owner.loc))
		return
	if(home_sector != owner.sector)
		home_sector = owner.sector
		home_x = owner.get_world_x()
		home_y = owner.get_world_y()
		target = null
		goal_x = null
		order = null
	if(owner.ai_destroyed || !owner.drive_intact())
		state = "disabled"
		target = null
		wanted_x = 0
		wanted_y = 0
		return
	if(order?["sector"] != owner.sector)
		order = null
	acquire_target()
	var/x = owner.get_world_x()
	var/y = owner.get_world_y()
	if(target && !has_weapons())
		state = "flee"
		var/away = delta_to_angle(x - last_x, y - last_y)
		var/list/escape = overmap_ai_standoff_point(last_x, last_y, away, max(detection_range(), sqrt((x - last_x) ** 2 + (y - last_y) ** 2) + 150), world_limits())
		steer_to(escape[1], escape[2], navigation_speed())
		wanted_facing = delta_to_angle(wanted_x, wanted_y)
	else if(order)
		if(!execute_order())
			combat_movement()
			aim_and_fire()
	else if(!target)
		state = "patrol"
		if(isnull(goal_x) || (goal_x - x) ** 2 + (goal_y - y) ** 2 < 64)
			var/angle = (patrol_step++ % 4) * 90 + slot * 37
			goal_x = home_x + sin(angle) * patrol_radius
			goal_y = home_y + cos(angle) * patrol_radius
		steer_to(goal_x, goal_y, navigation_speed() * 0.6)
		if(wanted_x || wanted_y)
			wanted_facing = delta_to_angle(wanted_x, wanted_y)
	else if(!target_visible)
		state = "search"
		steer_to(last_x + last_vx * min(2, (world.time - last_seen) / (1 SECONDS)), last_y + last_vy * min(2, (world.time - last_seen) / (1 SECONDS)), navigation_speed() * 0.75)
		wanted_facing = delta_to_angle(last_x - x, last_y - y)
	else
		combat_movement()
		aim_and_fire()
	avoid_collisions()
	var/speed = sqrt(wanted_x ** 2 + wanted_y ** 2)
	if(speed > navigation_speed())
		wanted_x *= navigation_speed() / speed
		wanted_y *= navigation_speed() / speed

/datum/overmap_ship_ai/proc/world_limits()
	var/datum/overmap_sector/sector = owner.sector
	var/span = OVERMAP_TILE_SPAN * sector.tile_travel
	var/margin = owner.hull_radius + 6
	return list((sector.playable_min_x() - 0.5) * span + margin, (sector.playable_min_y() - 0.5) * span + margin, (sector.playable_max_x() + 0.5) * span - margin, (sector.playable_max_y() + 0.5) * span - margin)

/datum/overmap_ship_ai/proc/steer_to(x, y, speed, follow_x = 0, follow_y = 0)
	var/list/limits = world_limits()
	x = clamp(x, limits[1], limits[3])
	y = clamp(y, limits[2], limits[4])
	var/dx = x - owner.get_world_x()
	var/dy = y - owner.get_world_y()
	var/distance = sqrt(dx ** 2 + dy ** 2)
	var/wanted_speed = min(speed, sqrt(2 * profile.acceleration * distance), distance * 0.7)
	wanted_x = follow_x + (distance ? dx / distance * wanted_speed : 0)
	wanted_y = follow_y + (distance ? dy / distance * wanted_speed : 0)

/datum/overmap_ship_ai/proc/combat_movement()
	var/x = owner.get_world_x()
	var/y = owner.get_world_y()
	var/dx = x - last_x
	var/dy = y - last_y
	var/distance = max(0.1, sqrt(dx ** 2 + dy ** 2))
	var/list/contact = controller.contacts[target]
	var/target_radius = contact?["radius"] || 1
	var/tactic = effective_role()
	var/standoff = owner.hull_radius + target_radius + (tactic == "medium" ? 65 : profile.distance)
	state = tactic == "light" ? "orbit" : tactic == "medium" ? "flank" : "standoff"
	if(tactic == "light")
		var/radial_speed = clamp((distance - standoff) * 0.3, -navigation_speed() * 0.8, navigation_speed() * 0.8)
		var/tangent_speed = min(navigation_speed(), sqrt(profile.acceleration * standoff)) * (distance > standoff * 2 ? 0.25 : 0.8)
		var/side = slot % 2 ? 1 : -1
		wanted_x = last_vx - dx / distance * radial_speed + dy / distance * tangent_speed * side
		wanted_y = last_vy - dy / distance * radial_speed - dx / distance * tangent_speed * side
		return
	var/angle
	if(tactic == "medium")
		var/flank = target.get_facing() + (slot % 2 ? 270 : 90) + (FLOOR(slot / 2, 1) % 3 - 1) * 25
		var/bearing = delta_to_angle(dx, dy)
		var/difference = closer_angle_difference(bearing, flank)
		angle = distance < standoff * 1.8 ? bearing + clamp(difference, -30, 30) : bearing
		if(abs(difference) < 30)
			angle = flank
	else
		angle = delta_to_angle(home_x - last_x, home_y - last_y)
	if(tactic == "medium")
		steer_to(last_x + sin(angle) * standoff, last_y + cos(angle) * standoff, navigation_speed(), last_vx, last_vy)
	else
		var/list/point = overmap_ai_standoff_point(last_x, last_y, angle, standoff, world_limits())
		steer_to(point[1], point[2], navigation_speed(), last_vx, last_vy)

/datum/overmap_ship_ai/proc/avoid_collisions()
	var/x = owner.get_world_x()
	var/y = owner.get_world_y()
	var/maneuver_speed = max(sqrt(wanted_x ** 2 + wanted_y ** 2), owner.get_speed() * OVERMAP_TILE_SPAN * (1 SECONDS), profile.acceleration * 3)
	var/lookahead = max(20, maneuver_speed * 3)
	var/list/neighbors = controller.nearby(owner.sector, x, y, lookahead + owner.hull_radius + 15)
	for(var/list/entry as anything in neighbors)
		if(entry["ship"] == owner)
			continue
		var/dx = x - entry["x"]
		var/dy = y - entry["y"]
		var/range = max(0.1, sqrt(dx ** 2 + dy ** 2))
		var/safe = owner.hull_radius + entry["radius"] + 12
		var/closing = -(wanted_x * dx + wanted_y * dy) / range
		if(range > safe + max(0, closing) * 3)
			continue
		if(range < safe)
			wanted_x += dx / range * maneuver_speed * 2
			wanted_y += dy / range * maneuver_speed * 2
		else if(closing > 0)
			wanted_x += dx / range * closing
			wanted_y += dy / range * closing
			var/side = slot % 2 ? 1 : -1
			wanted_x += dy / range * maneuver_speed * 0.7 * side
			wanted_y -= dx / range * maneuver_speed * 0.7 * side
	var/list/fields = SSovermap.scatter_fields_at(owner.sector, x, y, lookahead + owner.hull_radius)
	for(var/obj/overmap/feature/hazard/field as anything in fields)
		if(field.scatter_at(x + wanted_x * 3, y + wanted_y * 3))
			var/old_x = wanted_x
			wanted_x = wanted_y
			wanted_y = -old_x
			break
	var/list/limits = world_limits()
	if(x + wanted_x * 3 < limits[1] || x + wanted_x * 3 > limits[3])
		wanted_x = clamp((limits[1] + limits[3]) / 2 - x, -navigation_speed(), navigation_speed())
	if(y + wanted_y * 3 < limits[2] || y + wanted_y * 3 > limits[4])
		wanted_y = clamp((limits[2] + limits[4]) / 2 - y, -navigation_speed(), navigation_speed())

/datum/overmap_ship_ai/proc/aim_point(datum/component/ship_weapon/mount, live = FALSE)
	if(order?["kind"] == "suppress")
		return aim_at_point(mount, order["x"], order["y"])
	return aim_at_point(mount, live ? target.get_world_x() : last_x, live ? target.get_world_y() : last_y, live ? target.speed[1] * OVERMAP_TILE_SPAN * (1 SECONDS) : last_vx, live ? target.speed[2] * OVERMAP_TILE_SPAN * (1 SECONDS) : last_vy)

/datum/overmap_ship_ai/proc/aim_at_point(datum/component/ship_weapon/mount, aim_x, aim_y, velocity_x = 0, velocity_y = 0)
	var/obj/machinery/gun = mount.parent
	var/shot_type = gun.ship_round_type || /obj/projectile/bullet/ship_artillery
	var/obj/machinery/porta_turret/turret = gun
	if(istype(turret))
		shot_type = (turret.lethal || turret.emagged) ? turret.eprojectile : turret.projectile
	if(!ispath(shot_type, /obj/projectile))
		return null
	var/obj/projectile/prototype = shot_type
	var/list/origin = mount.world_position(owner)
	var/list/inherited = owner.projectile_inherited_velocity(origin[1], origin[2])
	var/relative_x = velocity_x - inherited[1]
	var/relative_y = velocity_y - inherited[2]
	var/obj/overmap/entity/carrier = owner.docked_ship || owner
	var/turn_speed = mount.muzzle_distance * TORADIANS(carrier.flight?.angular_velocity || 0) * (1 SECONDS)
	var/shot_speed = initial(prototype.overmap_velocity)
	var/time = overmap_ai_intercept(aim_x - origin[1], aim_y - origin[2], relative_x, relative_y, shot_speed, mount.muzzle_distance, turn_speed)
	if(isnull(time) || time > 90)
		return null
	var/dx = aim_x + relative_x * time - origin[1]
	var/dy = aim_y + relative_y * time - origin[2]
	var/forward = mount.muzzle_distance + shot_speed * time
	var/correction = forward > 0 ? arctan(turn_speed * time / forward) : 0
	var/angle = delta_to_angle(dx, dy) - correction
	var/distance = sqrt(dx ** 2 + dy ** 2)
	return list(origin[1] + sin(angle) * distance, origin[2] + cos(angle) * distance)

/datum/overmap_ship_ai/proc/burst_aim(datum/component/ship_weapon/mount)
	if(enabled && order?["kind"] == "suppress")
		return suppression_aim(mount)
	if(!enabled || !target_visible || QDELETED(target) || !can_see(controller.contacts[target]) || (!is_ordered_target(target) && (is_fleet_member(target) || !hostile(perceived_faction(target)))))
		return null
	var/list/aim = aim_point(mount, TRUE)
	return aim && clear_shot(mount, aim) ? aim : null

/datum/overmap_ship_ai/proc/aim_and_fire()
	var/list/ready = list()
	var/list/aims = list()
	for(var/datum/component/ship_weapon/mount as anything in weapons)
		if(!weapon_operational(mount))
			continue
		var/list/aim = aim_point(mount)
		if(!aim)
			continue
		aims[mount] = aim
		if(world.time >= mount.next_fire)
			ready += mount
	var/list/orientation_guns = length(ready) ? ready : weapons
	var/best_score = -1
	for(var/datum/component/ship_weapon/candidate as anything in orientation_guns)
		var/list/aim = aims[candidate]
		if(!aim)
			continue
		var/list/origin = candidate.world_position(owner)
		var/heading = delta_to_angle(aim[1] - origin[1], aim[2] - origin[2]) - (candidate.heading(owner) - owner.get_facing())
		var/score = 0
		for(var/datum/component/ship_weapon/mount as anything in orientation_guns)
			var/list/other_aim = aims[mount]
			if(!other_aim)
				continue
			var/list/point = mount.world_position(owner)
			var/barrel = heading + mount.heading(owner) - owner.get_facing()
			if(abs(closer_angle_difference(barrel, delta_to_angle(other_aim[1] - point[1], other_aim[2] - point[2]))) <= max(0, mount.arc / 2 - 1))
				score += 1 + 30 / max(10, mount.arc)
		score -= abs(closer_angle_difference(owner.get_facing(), heading)) / 720
		if(score > best_score)
			best_score = score
			wanted_facing = heading
	var/area_fire = order?["kind"] == "suppress"
	var/distance = sqrt(((area_fire ? order["x"] : last_x) - owner.get_world_x()) ** 2 + ((area_fire ? order["y"] : last_y) - owner.get_world_y()) ** 2) - (area_fire ? 0 : overmap_ai_radius(target))
	if(distance > profile.fire_range)
		return
	for(var/datum/component/ship_weapon/mount as anything in ready)
		var/list/aim = aims[mount]
		if(mount.can_aim(owner, aim[1], aim[2]) && clear_shot(mount, aim))
			mount.fire_at(owner, aim[1], aim[2], FALSE)

/datum/overmap_ship_ai/proc/clear_shot(datum/component/ship_weapon/mount, list/aim, obj/overmap/entity/intended_target = target)
	var/list/start = mount.world_position(owner)
	var/angle = delta_to_angle(aim[1] - start[1], aim[2] - start[2])
	start[1] += sin(angle) * mount.muzzle_distance
	start[2] += cos(angle) * mount.muzzle_distance
	for(var/distance in 0 to CEILING(owner.hull_radius * 2 + 2, 1) step 0.5)
		var/list/cell = owner.cell_at(start[1] + sin(angle) * distance, start[2] + cos(angle) * distance, TRUE)
		var/obj/machinery/gun = mount.parent
		if(cell && (cell[1] != gun.virtual_weapon_x || cell[2] != gun.virtual_weapon_y))
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
		if(order?["kind"] == "suppress" && !is_fleet_member(entry["ship"]) && hostile(perceived_faction(entry["ship"])))
			continue
		var/fraction = clamp(((entry["x"] - start[1]) * dx + (entry["y"] - start[2]) * dy) / length_squared, 0, 1)
		if((entry["x"] - start[1] - dx * fraction) ** 2 + (entry["y"] - start[2] - dy * fraction) ** 2 <= (entry["radius"] + 1) ** 2)
			return FALSE
	return TRUE
