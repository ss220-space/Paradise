/datum/component/overmap_flight/proc/navigation_speed_limited()
	var/obj/overmap/entity/vessel = parent
	return autopilot || !!vessel.programmed_mission || (vessel.programmed && !vessel.programmed_profile()?.manual_helm)

/datum/component/overmap_flight/proc/clear_navigation()
	navigation?.reset()
	navigation_world_x = null
	navigation_world_y = null
	navigation_facing = null
	navigation_host = null
	matching_velocity = FALSE

/datum/component/overmap_flight/proc/navigate_world(world_x, world_y, heading, obj/overmap/entity/host)
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
	var/list/waypoint = (avoid_obstacles || vessel.navigation_collision_disabled()) ? navigation.waypoint(goal_x, goal_y, navigation_host) : list(goal_x, goal_y)
	if(!waypoint)
		autopilot_status = navigation.planning ? "Прокладывает маршрут" : "Проход перекрыт: ожидание"
		brake(elapsed)
		return
	var/dx = waypoint[1] - vessel.get_world_x()
	var/dy = waypoint[2] - vessel.get_world_y()
	var/distance = sqrt(dx ** 2 + dy ** 2)
	var/final_leg = abs(waypoint[1] - goal_x) + abs(waypoint[2] - goal_y) < 0.1
	var/arrival_range = vessel.programmed_mission ? 1 : OVERMAP_AUTOPILOT_ARRIVE_RANGE
	if(final_leg && distance <= arrival_range && vessel.get_speed() * OVERMAP_TILE_SPAN <= OVERMAP_AUTOPILOT_ARRIVE_SPEED)
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
		if(vessel.programmed_mission && !isnull(navigation_world_x))
			vessel.programmed_mission.navigation_arrived()
		else
			notify_arrival()
		return
	var/accel = strongest_thrust() / inertial_mass() / burn_delay * OVERMAP_TILE_SPAN * OVERMAP_AUTOPILOT_ACCEL_MARGIN
	var/needs_flip = min(thrust_north, thrust_south, thrust_east, thrust_west) < strongest_thrust() * 0.1
	var/flip = needs_flip ? flip_time() : 0
	var/safe_speed = accel ? accel * (sqrt(flip ** 2 + 2 * max(distance - 0.5, 0) / accel) - flip) : 0
	var/wanted_speed = min(get_effective_cruise() * OVERMAP_TILE_SPAN, safe_speed)
	var/hold_orientation = !isnull(navigation_facing) && distance <= max(64, vessel.hull_radius * 4)
	var/list/host_region = navigation_host?.physical_space?.region
	if(!isnull(navigation_facing) && host_region)
		var/gap_x = max(host_region[1] - vessel.get_world_x(), vessel.get_world_x() - host_region[3], 0)
		var/gap_y = max(host_region[2] - vessel.get_world_y(), vessel.get_world_y() - host_region[4], 0)
		hold_orientation ||= max(gap_x, gap_y) <= max(64, vessel.hull_radius * 4)
	if(vessel.programmed_mission)
		var/heading_error = abs(closer_angle_difference(facing + main_axis_angle(), hold_orientation ? navigation_facing + main_axis_angle() : delta_to_angle(dx, dy)))
		wanted_speed *= max(0, cos(heading_error)) ** 2
	var/aim = match_navigation_velocity(distance ? dx / distance * wanted_speed : 0, distance ? dy / distance * wanted_speed : 0, elapsed)
	autopilot_status = navigation.force_passage ? "Аварийный проход без коллизии" : (length(navigation.path) > 1 ? "Обходит препятствие" : "Идёт к цели")
	if(vessel.programmed_mission && hold_orientation)
		return navigation_facing + main_axis_angle()
	if(vessel.programmed_mission && distance > max(arrival_range * 2, 3))
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
	if(error <= OVERMAP_AUTOPILOT_DEADBAND)
		return
	var/accel = strongest_thrust() / inertial_mass() / burn_delay * OVERMAP_TILE_SPAN
	var/effort = accel ? min(1, error / max(accel * elapsed, 0.001)) : 1
	push(error_x / error * effort, error_y / error * effort, elapsed, !matching_velocity)
	if(error > OVERMAP_AUTOPILOT_TURN_ERROR)
		return delta_to_angle(error_x, error_y)

/datum/component/overmap_flight/proc/stop_blocked_navigation()
	var/obj/overmap/entity/vessel = parent
	vessel.speed[1] = 0
	vessel.speed[2] = 0
	navigation?.reset()
	autopilot_status = "Препятствие на пути: ожидание свободного прохода"
	vessel.refresh_heading_overlay()
