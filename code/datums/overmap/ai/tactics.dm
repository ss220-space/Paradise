/datum/overmap_ship_ai/proc/effective_role()
	if(role == "heavy" && !controller.medium_cover[controller.group_key(src)])
		return "medium"
	return role

/datum/overmap_ship_ai/proc/think()
	weapon_snapshots.Cut()
	if(QDELETED(owner) || !owner.sector || !isturf(owner.loc))
		return
	if(home_sector != owner.sector)
		home_sector = owner.sector
		home_x = owner.get_world_x()
		home_y = owner.get_world_y()
		target = null
		goal_x = null
		order = null
	if(owner.is_ai_destroyed() || !owner.ai_drive_intact())
		state = "disabled"
		report_state()
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
	report_state()
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
