/datum/component/overmap_flight/proc/navigation_speed_limited()
	return autopilot

/datum/component/overmap_flight/proc/clear_navigation()
	navigation?.reset()
	navigation_world_x = null
	navigation_world_y = null
	navigation_facing = null
	navigation_host = null
	navigation_arrival_range = OVERMAP_AUTOPILOT_ARRIVE_RANGE
	navigation_fly_through = FALSE
	navigation_ignore_collisions = FALSE
	navigation_known_obstacles_only = TRUE
	navigation_entry_box = null
	matching_velocity = FALSE

/datum/component/overmap_flight/proc/navigate_world(world_x, world_y, heading, obj/overmap/entity/host, arrival_range = OVERMAP_AUTOPILOT_ARRIVE_RANGE, ignore_collisions = FALSE, known_obstacles_only = TRUE, list/entry_box, fly_through = FALSE)
	if(!autopilot)
		release_pilot()
		held_brake = FALSE
		engines_state = TRUE
		autopilot = TRUE
	matching_velocity = FALSE
	navigation_world_x = world_x
	navigation_world_y = world_y
	navigation_facing = heading
	navigation_host = host
	navigation_arrival_range = arrival_range
	navigation_fly_through = fly_through
	navigation_ignore_collisions = ignore_collisions
	navigation_known_obstacles_only = known_obstacles_only
	navigation_entry_box = entry_box
	var/obj/overmap/entity/vessel = parent
	if(vessel.sector)
		var/span = OVERMAP_TILE_SPAN * vessel.sector.tile_travel
		autopilot_x = world_x / span - vessel.sector.origin_x + 1
		autopilot_y = world_y / span - vessel.sector.origin_y + 1

/datum/component/overmap_flight/proc/toggle_velocity_matching()
	var/obj/overmap/entity/vessel = parent
	if(matching_velocity)
		set_autopilot(FALSE)
		return TRUE
	if(QDELETED(navigation_target) || navigation_target.sector != vessel.sector || !isturf(navigation_target.loc) || !can_steer())
		return FALSE
	set_autopilot(FALSE)
	matching_velocity = TRUE
	autopilot = TRUE
	held_brake = FALSE
	engines_state = TRUE
	return TRUE

/datum/component/overmap_flight/proc/process_navigation(elapsed)
	var/obj/overmap/entity/vessel = parent
	if(held_brake || !can_steer() || !vessel.sector)
		return
	if(matching_velocity)
		if(QDELETED(navigation_target) || navigation_target.sector != vessel.sector || !isturf(navigation_target.loc))
			set_autopilot(FALSE)
			return
		autopilot_status = "Сближение: [navigation_target.get_overmap_display_name()]"
		match_navigation_velocity(navigation_target.speed[1] * OVERMAP_TILE_SPAN, navigation_target.speed[2] * OVERMAP_TILE_SPAN, elapsed)
		return
	var/goal_x = navigation_world_x
	var/goal_y = navigation_world_y
	if(isnull(goal_x) || isnull(goal_y))
		if(!QDELETED(navigation_target) && navigation_target.sector == vessel.sector && isturf(navigation_target.loc))
			var/dx = vessel.get_world_x() - navigation_target.get_world_x()
			var/dy = vessel.get_world_y() - navigation_target.get_world_y()
			var/distance = sqrt(dx ** 2 + dy ** 2)
			var/standoff = vessel.hull_radius + navigation_target.hull_radius + 12
			goal_x = navigation_target.get_world_x() + (distance ? dx / distance : 0) * standoff
			goal_y = navigation_target.get_world_y() + (distance ? dy / distance : 1) * standoff
			var/list/extent = navigation_target.physical_space?.navigation_extent
			if(extent)
				var/margin = vessel.hull_radius + 4
				goal_x = clamp(vessel.get_world_x(), extent[1] - margin, extent[3] + margin)
				goal_y = clamp(vessel.get_world_y(), extent[2] - margin, extent[4] + margin)
		else
			if(isnull(autopilot_x) || isnull(autopilot_y))
				return
			var/span = OVERMAP_TILE_SPAN * vessel.sector.tile_travel
			goal_x = (vessel.sector.origin_x + autopilot_x - 1) * span
			goal_y = (vessel.sector.origin_y + autopilot_y - 1) * span
	if(!navigation)
		navigation = new(src)
	var/list/waypoint = !vessel.atmosphere && (avoid_obstacles || vessel.navigation_collision_disabled()) ? navigation.waypoint(goal_x, goal_y, navigation_host) : list(goal_x, goal_y)
	if(!waypoint)
		autopilot_status = navigation.planning ? "Прокладывает маршрут" : "Проход перекрыт: ожидание"
		brake(elapsed)
		return
	var/dx = waypoint[1] - vessel.get_world_x()
	var/dy = waypoint[2] - vessel.get_world_y()
	var/distance = sqrt(dx ** 2 + dy ** 2)
	var/final_leg = abs(waypoint[1] - goal_x) + abs(waypoint[2] - goal_y) < 0.1
	var/arrival_range = navigation_arrival_range
	var/in_range = final_leg && distance <= arrival_range
	if(in_range && (navigation_fly_through || (vessel.speed[1] ** 2 + vessel.speed[2] ** 2) * OVERMAP_TILE_SPAN ** 2 <= OVERMAP_AUTOPILOT_ARRIVE_SPEED ** 2))
		if(!navigation_fly_through)
			if(!isnull(navigation_facing) && abs(closer_angle_difference(facing, navigation_facing)) > 2)
				brake(elapsed)
				return navigation_facing + main_axis_angle()
			vessel.speed[1] = 0
			vessel.speed[2] = 0
			if(!isnull(navigation_facing))
				set_facing(navigation_facing)
			angular_velocity = 0
		autopilot = FALSE
		navigation.reset()
		vessel.refresh_heading_overlay()
		notify_arrival()
		return
	var/min_thrust = min(thrust_north, thrust_south, thrust_east, thrust_west)
	var/needs_flip = min_thrust < strongest_thrust() * 0.1
	var/braking_thrust = needs_flip ? strongest_thrust() : min_thrust
	var/accel = braking_thrust / inertial_mass() / burn_delay * OVERMAP_TILE_SPAN * OVERMAP_AUTOPILOT_ACCEL_MARGIN
	var/reaction_time = elapsed + (needs_flip ? flip_time() : 0)
	var/safe_speed = in_range ? 0 : overmap_approach_speed(distance, accel, reaction_time)
	var/wanted_speed = min(get_effective_cruise() * OVERMAP_TILE_SPAN, safe_speed)
	var/hold_orientation = !needs_flip && !isnull(navigation_facing) && distance <= max(64, vessel.hull_radius * 4)
	var/list/host_region = navigation_host?.physical_space?.region
	if(!needs_flip && !isnull(navigation_facing) && host_region)
		var/gap_x = max(host_region[1] - vessel.get_world_x(), vessel.get_world_x() - host_region[3], 0)
		var/gap_y = max(host_region[2] - vessel.get_world_y(), vessel.get_world_y() - host_region[4], 0)
		hold_orientation ||= max(gap_x, gap_y) <= max(64, vessel.hull_radius * 4)
	var/aim = match_navigation_velocity(distance ? dx / distance * wanted_speed : 0, distance ? dy / distance * wanted_speed : 0, elapsed)
	autopilot_status = navigation.force_passage ? "Аварийный проход без коллизии" : (length(navigation.path) > 1 ? "Обходит препятствие" : "Идёт к цели")
	if(hold_orientation)
		return navigation_facing + main_axis_angle()
	if(!needs_flip && !isnull(navigation_facing) && distance > max(arrival_range * 2, 3))
		return delta_to_angle(dx, dy)
	return final_leg && !isnull(navigation_facing) && !needs_flip ? navigation_facing + main_axis_angle() : aim

/datum/component/overmap_flight/proc/match_navigation_velocity(wanted_x, wanted_y, elapsed)
	var/obj/overmap/entity/vessel = parent
	var/wanted_speed = sqrt(wanted_x ** 2 + wanted_y ** 2)
	var/limit = get_effective_cruise() * OVERMAP_TILE_SPAN
	if(wanted_speed > limit)
		wanted_x *= limit / wanted_speed
		wanted_y *= limit / wanted_speed
	var/error_x = wanted_x - vessel.speed[1] * OVERMAP_TILE_SPAN
	var/error_y = wanted_y - vessel.speed[2] * OVERMAP_TILE_SPAN
	var/error = sqrt(error_x ** 2 + error_y ** 2)
	if(!error || (matching_velocity && error <= OVERMAP_AUTOPILOT_DEADBAND))
		return
	var/local_x = error_x * cos(facing) - error_y * sin(facing)
	var/local_y = error_x * sin(facing) + error_y * cos(facing)
	var/scale = elapsed * OVERMAP_TILE_SPAN / inertial_mass() / burn_delay
	var/step_x = side_thrust(local_x > 0 ? EAST : WEST) * scale
	var/step_y = side_thrust(local_y > 0 ? NORTH : SOUTH) * scale
	var/input_x = step_x ? local_x / step_x : 0
	var/input_y = step_y ? local_y / step_y : 0
	var/magnitude = max(1, sqrt(input_x ** 2 + input_y ** 2))
	push_local(input_x / magnitude, input_y / magnitude, elapsed, !matching_velocity)
	if(error > OVERMAP_AUTOPILOT_TURN_ERROR || (!step_x && abs(local_x) > OVERMAP_SPEED_EPSILON) || (!step_y && abs(local_y) > OVERMAP_SPEED_EPSILON))
		return delta_to_angle(error_x, error_y)

/datum/component/overmap_flight/proc/stop_blocked_navigation()
	var/obj/overmap/entity/vessel = parent
	vessel.speed[1] = 0
	vessel.speed[2] = 0
	navigation?.reset()
	autopilot_status = "Препятствие на пути: ожидание свободного прохода"
	vessel.refresh_heading_overlay()
