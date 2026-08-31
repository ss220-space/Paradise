/datum/component/overmap_flight
	dupe_mode = COMPONENT_DUPE_UNIQUE
	var/burn_delay = 1 SECONDS
	var/last_burn = 0
	var/engines_state = TRUE
	var/held_thrust_dir = NONE
	var/held_thrust_nx = 0
	var/held_thrust_ny = 0
	var/held_thrust_power = 0
	var/held_brake = FALSE
	var/thrust_limit = 1
	var/autopilot = FALSE
	var/autopilot_x
	var/autopilot_y

	var/cruise_speed = OVERMAP_FROM_DISPLAY(OVERMAP_CRUISE_DEFAULT)

/datum/component/overmap_flight/Initialize()
	if(!istype(parent, /obj/overmap/entity))
		return COMPONENT_INCOMPATIBLE
	if(istype(parent, /obj/overmap/entity/pod))
		cruise_speed = OVERMAP_FROM_DISPLAY(OVERMAP_POD_CRUISE)

/datum/component/overmap_flight/RegisterWithParent()
	var/obj/overmap/entity/token = parent
	token.flight = src
	SSovermap?.flights |= src

/datum/component/overmap_flight/UnregisterFromParent()
	var/obj/overmap/entity/token = parent
	if(token.flight == src)
		token.flight = null
	SSovermap?.flights -= src

/datum/component/overmap_flight/proc/token()
	RETURN_TYPE(/obj/overmap/entity)
	return parent

/datum/component/overmap_flight/proc/needs_physics()
	var/obj/overmap/entity/vessel = parent
	if(src.held_thrust_dir || src.held_thrust_power || src.held_brake || src.autopilot)
		return TRUE
	return vessel.movable && !vessel.halted && vessel.is_moving()

/datum/component/overmap_flight/proc/process_tick(elapsed)
	var/obj/overmap/entity/vessel = parent
	if(QDELETED(vessel))
		return
	if(!needs_physics())
		return
	process_held_controls()
	process_autopilot()
	enforce_cruise_speed()
	vessel.process_movement(elapsed)

/datum/component/overmap_flight/proc/get_total_thrust()
	. = 0
	var/obj/overmap/entity/vessel = parent
	for(var/obj/machinery/ship_engine/engine as anything in vessel.engines)
		. += engine.get_thrust()

/datum/component/overmap_flight/proc/inertial_mass()
	var/obj/overmap/entity/vessel = parent
	return max(vessel.vessel_mass, 1) * OVERMAP_MASS_INERTIA

/datum/component/overmap_flight/proc/get_acceleration()
	return round(get_total_thrust() / inertial_mass(), OVERMAP_MOVE_RESOLUTION)

/datum/component/overmap_flight/proc/has_working_engines()
	var/obj/overmap/entity/vessel = parent
	for(var/obj/machinery/ship_engine/engine as anything in vessel.engines)
		if(engine.can_burn())
			return TRUE
	return FALSE

/datum/component/overmap_flight/proc/can_steer()
	var/obj/overmap/entity/vessel = parent
	return (vessel.status == OVERMAP_STATUS_OVERMAP || vessel.status == OVERMAP_STATUS_TRANSIT) && !vessel.halted && isturf(vessel.loc)

/datum/component/overmap_flight/proc/can_burn()
	if(!can_steer())
		return FALSE
	if(world.time < last_burn + burn_delay)
		return FALSE
	if(!engines_state)
		return FALSE
	return has_working_engines()

/datum/component/overmap_flight/proc/set_held_thrust(direction)
	if(!can_steer())
		return FALSE
	autopilot = FALSE
	held_brake = FALSE
	engines_state = TRUE
	if(held_thrust_dir == direction)
		clear_held_thrust()
		return TRUE
	apply_held_dir(direction)
	return TRUE

/datum/component/overmap_flight/proc/set_held_vector(nx, ny, power)
	if(!can_steer())
		return FALSE
	if(!isnum(nx))
		nx = text2num(nx)
	if(!isnum(ny))
		ny = text2num(ny)
	if(!isnum(power))
		power = text2num(power)
	if(isnull(nx) || isnull(ny) || isnull(power) || power <= 0)
		clear_held_thrust()
		return TRUE
	autopilot = FALSE
	held_brake = FALSE
	var/mag = sqrt(nx * nx + ny * ny)
	if(mag <= 0)
		clear_held_thrust()
		return TRUE
	engines_state = TRUE
	held_thrust_nx = nx / mag
	held_thrust_ny = ny / mag
	held_thrust_power = clamp(power, 0, 1)
	held_thrust_dir = vector_to_overmap_dir(held_thrust_nx, held_thrust_ny)
	return TRUE

/datum/component/overmap_flight/proc/clear_held_thrust()
	held_thrust_dir = NONE
	held_thrust_nx = 0
	held_thrust_ny = 0
	held_thrust_power = 0

/datum/component/overmap_flight/proc/apply_held_dir(direction)
	held_thrust_dir = direction
	held_thrust_nx = (direction & EAST) ? 1 : ((direction & WEST) ? -1 : 0)
	held_thrust_ny = (direction & NORTH) ? 1 : ((direction & SOUTH) ? -1 : 0)
	var/mag = sqrt(held_thrust_nx ** 2 + held_thrust_ny ** 2)
	if(mag > 0)
		held_thrust_nx /= mag
		held_thrust_ny /= mag
	held_thrust_power = 1

/proc/vector_to_overmap_dir(nx, ny)
	var/ew = (nx > 0.38) ? EAST : ((nx < -0.38) ? WEST : 0)
	var/ns = (ny > 0.38) ? NORTH : ((ny < -0.38) ? SOUTH : 0)
	return ns | ew

/datum/component/overmap_flight/proc/set_held_brake(enabled)
	if(!can_steer())
		return FALSE
	autopilot = FALSE
	if(enabled)
		engines_state = TRUE
		clear_held_thrust()
		held_brake = TRUE
	else
		held_brake = FALSE
	return TRUE

/datum/component/overmap_flight/proc/cut_engines()
	clear_held_thrust()
	held_brake = FALSE
	engines_state = !engines_state
	return TRUE

/datum/component/overmap_flight/proc/process_held_controls()
	if(held_brake)
		decelerate()
		return
	if(held_thrust_power > 0)
		accelerate_vector(held_thrust_nx, held_thrust_ny, held_thrust_power)
	else if(held_thrust_dir)
		accelerate(held_thrust_dir)

/datum/component/overmap_flight/proc/apply_thrust()
	. = 0
	var/obj/overmap/entity/vessel = parent
	for(var/obj/machinery/ship_engine/engine as anything in vessel.engines)
		. += engine.apply_thrust()

/datum/component/overmap_flight/proc/get_burn_acceleration()
	return round(apply_thrust() / inertial_mass(), OVERMAP_MOVE_RESOLUTION)

/datum/component/overmap_flight/proc/accelerate(direction)
	if(!direction || !can_burn())
		return FALSE
	var/dx = (direction & EAST) ? 1 : ((direction & WEST) ? -1 : 0)
	var/dy = (direction & NORTH) ? 1 : ((direction & SOUTH) ? -1 : 0)
	if(dx && dy)
		var/diag = sqrt(dx * dx + dy * dy)
		dx /= diag
		dy /= diag
	return accelerate_vector(dx, dy)

/datum/component/overmap_flight/proc/accelerate_vector(nx, ny, power = 1)
	var/obj/overmap/entity/vessel = parent
	if(!can_burn())
		return FALSE
	var/mag = sqrt(nx * nx + ny * ny)
	if(mag <= 0)
		return FALSE
	var/delta = get_burn_acceleration()
	if(delta <= 0)
		return FALSE
	src.last_burn = world.time
	delta *= clamp(power, 0, 1)
	vessel.adjust_speed(delta * (nx / mag), delta * (ny / mag))
	return TRUE

/datum/component/overmap_flight/proc/decelerate()
	var/obj/overmap/entity/vessel = parent
	if((!vessel.speed[1] && !vessel.speed[2]) || !can_burn())
		return FALSE
	src.last_burn = world.time
	var/delta = get_burn_acceleration()
	if(delta <= 0)
		return FALSE
	var/mag = sqrt(vessel.speed[1] ** 2 + vessel.speed[2] ** 2)
	if(delta >= mag)
		vessel.adjust_speed(-vessel.speed[1], -vessel.speed[2])
	else
		vessel.adjust_speed(-(vessel.speed[1] * delta) / mag, -(vessel.speed[2] * delta) / mag)
	return TRUE

/datum/component/overmap_flight/proc/enforce_cruise_speed()
	var/obj/overmap/entity/vessel = parent
	var/current = vessel.get_speed()
	if(current <= get_effective_cruise() || current <= 0)
		return
	var/delta = get_acceleration()
	if(delta <= 0)
		return
	var/excess = current - get_effective_cruise()
	var/new_speed = (delta >= excess) ? get_effective_cruise() : (current - delta)
	var/scale = new_speed / current
	vessel.speed[1] *= scale
	vessel.speed[2] *= scale
	vessel.refresh_heading_overlay()

/datum/component/overmap_flight/proc/get_brake_distance()
	var/obj/overmap/entity/vessel = parent
	var/accel = get_acceleration()
	var/current = vessel.get_speed()
	if(!accel || current < vessel.min_speed || !src.burn_delay)
		return 0
	var/accel_per_ds = accel / src.burn_delay
	if(accel_per_ds <= 0)
		return 0
	return (current * current) / (2 * accel_per_ds) + 0.2

/datum/component/overmap_flight/proc/ETA()
	var/obj/overmap/entity/vessel = parent
	. = INFINITY
	for(var/i in 1 to 2)
		if(abs(vessel.speed[i]) >= vessel.min_speed)
			. = min(., ((vessel.speed[i] > 0 ? OVERMAP_TILE_EDGE : -OVERMAP_TILE_EDGE) - vessel.position[i]) / vessel.speed[i])
	. = max(CEILING(., 1), 0)

/datum/component/overmap_flight/proc/set_autopilot(enabled, dest_x, dest_y)
	var/obj/overmap/entity/vessel = parent
	src.autopilot = enabled
	if(src.autopilot)
		clear_held_thrust()
		src.held_brake = FALSE
		src.engines_state = TRUE
	if(!isnull(dest_x))
		src.autopilot_x = dest_x
	if(!isnull(dest_y))
		src.autopilot_y = dest_y
	if(vessel.sector)
		if(!isnull(src.autopilot_x))
			src.autopilot_x = clamp(round(src.autopilot_x), 1, vessel.sector.size)
		if(!isnull(src.autopilot_y))
			src.autopilot_y = clamp(round(src.autopilot_y), 1, vessel.sector.size)
	if(src.autopilot && (isnull(src.autopilot_x) || isnull(src.autopilot_y)))
		src.autopilot = FALSE

/datum/component/overmap_flight/proc/process_autopilot()
	var/obj/overmap/entity/vessel = parent
	if(!src.autopilot || src.held_brake)
		return
	if(src.held_thrust_power > 0)
		return
	if(isnull(src.autopilot_x) || isnull(src.autopilot_y))
		return
	var/turf/here = vessel.get_overmap_turf()
	if(!here || !can_steer())
		return
	var/turf/target = vessel.sector?.get_turf_at(src.autopilot_x, src.autopilot_y)
	if(!target || target.z != here.z)
		return
	if(here == target)
		arrive_autopilot()
		return
	var/dx = target.x - here.x
	var/dy = target.y - here.y
	var/distance = sqrt(dx * dx + dy * dy)
	if(distance <= 0)
		arrive_autopilot()
		return
	src.engines_state = TRUE
	var/current = vessel.get_speed()
	var/cruise = get_effective_cruise()
	if(cruise <= 0)
		cruise = max(src.cruise_speed, OVERMAP_FROM_DISPLAY(OVERMAP_PROGRAMMED_CRUISE))
	var/brake_dist = get_brake_distance()
	var/remaining = remaining_to_enter_turf(target)
	if(remaining > 0 && remaining <= brake_dist && current > vessel.min_speed)
		decelerate()
		vessel.refresh_heading_overlay()
		return
	if(current > cruise * 1.02)
		decelerate()
		vessel.refresh_heading_overlay()
		return
	if(current >= cruise * 0.98)
		var/sx = vessel.speed[1]
		var/sy = vessel.speed[2]
		var/align = (sx * dx + sy * dy) / (max(current, OVERMAP_MOVE_RESOLUTION) * distance)
		if(align > 0.97)
			vessel.refresh_heading_overlay()
			return
	accelerate_vector(dx / distance, dy / distance)

/datum/component/overmap_flight/proc/arrive_autopilot()
	var/obj/overmap/entity/vessel = parent
	var/turf/target = vessel.sector?.get_turf_at(src.autopilot_x, src.autopilot_y)
	if(target && isturf(vessel.loc) && vessel.loc != target && target.z == vessel.z)
		vessel.forceMove(target)
		vessel.position = list(0, 0)
		vessel.update_overmap_pixel()
	vessel.speed[1] = 0
	vessel.speed[2] = 0
	src.autopilot = FALSE
	vessel.refresh_heading_overlay()
	notify_arrival()

/datum/component/overmap_flight/proc/get_effective_cruise()
	var/obj/overmap/entity/vessel = parent
	var/limit = src.cruise_speed
	if(vessel.programmed && vessel.is_programmed_locked())
		limit = min(limit, OVERMAP_FROM_DISPLAY(OVERMAP_PROGRAMMED_CRUISE))
	if(!vessel.programmed_mission)
		return limit
	if(vessel.overmap_hazard_immune)
		return limit
	var/safe = OVERMAP_FROM_DISPLAY(OVERMAP_HAZARD_SAFE_SPEED)
	var/remaining = remaining_to_hazard_on_course()
	if(remaining >= INFINITY)
		return limit
	var/need = brake_distance_to_speed(safe)
	if(need <= 0)
		if(remaining <= remaining_to_next_course_tile())
			limit = min(limit, safe)
		return limit
	if(remaining <= need)
		limit = min(limit, safe)
	return limit

/datum/component/overmap_flight/proc/brake_distance_to_speed(target_speed)
	var/obj/overmap/entity/vessel = parent
	var/current = vessel.get_speed()
	if(current <= target_speed)
		return 0
	var/accel = get_acceleration()
	if(!accel || !src.burn_delay)
		return 0
	var/accel_per_ds = accel / src.burn_delay
	if(accel_per_ds <= 0)
		return 0
	return ((current * current) - (target_speed * target_speed)) / (2 * accel_per_ds)

/datum/component/overmap_flight/proc/remaining_to_next_course_tile()
	var/obj/overmap/entity/vessel = parent
	var/turf/here = vessel.get_overmap_turf()
	var/turf/target = vessel.sector?.get_turf_at(src.autopilot_x, src.autopilot_y)
	if(!here || !target || here == target)
		return 0
	return remaining_to_tile_edge(sign(target.x - here.x), sign(target.y - here.y))

/datum/component/overmap_flight/proc/remaining_to_tile_edge(dir_x, dir_y)
	var/obj/overmap/entity/vessel = parent
	if(!dir_x && !dir_y)
		return 0
	var/best
	if(dir_x)
		best = (dir_x > 0 ? OVERMAP_TILE_EDGE : -OVERMAP_TILE_EDGE) - vessel.position[1]
	if(dir_y)
		var/need = (dir_y > 0 ? OVERMAP_TILE_EDGE : -OVERMAP_TILE_EDGE) - vessel.position[2]
		best = isnull(best) ? need : max(best, need)
	return max(best, 0)

/datum/component/overmap_flight/proc/remaining_to_enter_turf(turf/spot)
	var/obj/overmap/entity/vessel = parent
	var/turf/here = vessel.get_overmap_turf()
	if(!here || !spot || here.z != spot.z)
		return INFINITY
	if(here == spot)
		return 0
	var/steps = max(abs(spot.x - here.x), abs(spot.y - here.y))
	return remaining_to_tile_edge(sign(spot.x - here.x), sign(spot.y - here.y)) + (steps - 1)

/datum/component/overmap_flight/proc/remaining_to_hazard_on_course()
	var/obj/overmap/entity/vessel = parent
	var/turf/here = vessel.get_overmap_turf()
	if(!here || !vessel.sector)
		return INFINITY
	if(locate_hazard_on_turf(here))
		return 0
	if(!src.autopilot_x || !src.autopilot_y)
		return INFINITY
	var/turf/target = vessel.sector.get_turf_at(src.autopilot_x, src.autopilot_y)
	if(!target)
		return INFINITY
	var/tx = here.x
	var/ty = here.y
	var/first_dx = 0
	var/first_dy = 0
	var/steps = 0
	while(steps < 48 && (tx != target.x || ty != target.y))
		if(tx < target.x)
			tx++
			if(!steps)
				first_dx = 1
		else if(tx > target.x)
			tx--
			if(!steps)
				first_dx = -1
		if(ty < target.y)
			ty++
			if(!steps)
				first_dy = 1
		else if(ty > target.y)
			ty--
			if(!steps)
				first_dy = -1
		steps++
		var/turf/spot = locate(tx, ty, here.z)
		if(locate_hazard_on_turf(spot))
			return remaining_to_tile_edge(first_dx, first_dy) + (steps - 1)
	return INFINITY

/datum/component/overmap_flight/proc/locate_hazard_on_turf(turf/spot)
	if(!spot)
		return FALSE
	for(var/atom/thing as anything in spot.contents)
		if(istype(thing, /obj/overmap/feature/hazard))
			return TRUE
	return FALSE

/datum/component/overmap_flight/proc/notify_arrival()
	var/obj/overmap/entity/vessel = parent
	vessel.programmed_mission?.on_overmap_arrived()

/obj/overmap/entity/proc/get_total_thrust()
	return flight ? flight.get_total_thrust() : 0

/obj/overmap/entity/proc/get_acceleration()
	return flight ? flight.get_acceleration() : 0

/obj/overmap/entity/proc/has_working_engines()
	return !!flight?.has_working_engines()

/obj/overmap/entity/proc/can_steer()
	return !!flight?.can_steer()

/obj/overmap/entity/proc/can_burn()
	return !!flight?.can_burn()

/obj/overmap/entity/proc/set_held_thrust(direction)
	return flight?.set_held_thrust(direction)

/obj/overmap/entity/proc/set_held_vector(nx, ny, power)
	return flight?.set_held_vector(nx, ny, power)

/obj/overmap/entity/proc/set_held_brake(enabled)
	return flight?.set_held_brake(enabled)

/obj/overmap/entity/proc/cut_engines()
	return flight?.cut_engines()

/obj/overmap/entity/proc/get_effective_acceleration()
	return get_acceleration()

/obj/overmap/entity/proc/get_brake_distance()
	return flight ? flight.get_brake_distance() : 0

/obj/overmap/entity/proc/ETA()
	return flight ? flight.ETA() : 0

/obj/overmap/entity/proc/set_autopilot(enabled, dest_x, dest_y)
	flight?.set_autopilot(enabled, dest_x, dest_y)
