/datum/overmap_docking_approach
	var/obj/overmap/entity/vessel
	var/obj/overmap/entity/host
	var/list/own
	var/list/target
	var/obj/docking_port/stationary/pad
	var/datum/overmap_bubble/space
	var/aligning = FALSE
	var/deadline = 0
	var/target_x
	var/target_y
	var/target_facing
	var/owns_pad = FALSE
	var/list/landing_offset
	var/list/landing_footprint
	var/landing_hull_version
	var/previous_target_x
	var/previous_target_y
	var/previous_target_facing

/datum/overmap_docking_approach/New(obj/overmap/entity/owner, bind = TRUE)
	vessel = owner
	if(bind)
		vessel.docking_approach = src

/datum/overmap_docking_approach/Destroy()
	if(vessel?.docking_approach == src)
		vessel.docking_approach = null
	if(owns_pad && !QDELETED(pad) && !pad.get_docked())
		qdel(pad, TRUE)
	vessel = null
	host = null
	pad = null
	space = null
	return ..()

/datum/overmap_docking_approach/proc/update_target()
	if(QDELETED(vessel) || !vessel.in_free_flight())
		return FALSE
	if(host)
		if(QDELETED(host) || host.sector != vessel.sector || host.docked_ship)
			return FALSE
		var/turf/door = target[1]
		if(QDELETED(door))
			return FALSE
		var/list/point_world = host.hull_to_world(door.x, door.y)
		target_facing = SIMPLIFY_DEGREES(target[3] + host.get_facing() + 180 - own[3])
		var/turf/outside = own[2]
		var/dx = outside.x - vessel.hull_center_x
		var/dy = outside.y - vessel.hull_center_y
		target_x = point_world[1] - dx * cos(target_facing) - dy * sin(target_facing)
		target_y = point_world[2] - dy * cos(target_facing) + dx * sin(target_facing)
	else
		if(QDELETED(pad) || (space && (QDELETED(space) || (!vessel.programmed_mission && vessel.local_space != space))))
			return FALSE
		if(target)
			var/turf/door = own[1]
			var/turf/landing = target[2]
			var/turf/target_door = target[1]
			if(QDELETED(landing) || QDELETED(target_door))
				return FALSE
			target_facing = SIMPLIFY_DEGREES(dir2angle(target[3]) + 180 - own[3])
			var/list/point_world = space.to_world(landing.x, landing.y)
			var/dx = door.x - vessel.hull_center_x
			var/dy = door.y - vessel.hull_center_y
			target_x = point_world[1] - dx * cos(target_facing) - dy * sin(target_facing)
			target_y = point_world[2] - dy * cos(target_facing) + dx * sin(target_facing)
		else if(space)
			if(!landing_offset || landing_hull_version != vessel.hull_version)
				var/list/pairs = vessel.shuttle.overmap_move_pairs(pad)
				var/list/old_turfs = pairs[1]
				var/list/new_turfs = pairs[2]
				if(!length(new_turfs))
					return FALSE
				var/turf/old = old_turfs[1]
				var/turf/landing = new_turfs[1]
				if(!landing)
					return FALSE
				landing_offset = list(landing.x - pad.x, landing.y - pad.y, old.x - vessel.hull_center_x, old.y - vessel.hull_center_y)
				landing_footprint = list()
				for(var/turf/tile as anything in new_turfs)
					landing_footprint[tile] = TRUE
				landing_hull_version = vessel.hull_version
			var/list/point_world = space.to_world(pad.x + landing_offset[1], pad.y + landing_offset[2])
			var/dx = landing_offset[3]
			var/dy = landing_offset[4]
			target_x = point_world[1] - dx * cos(target_facing) - dy * sin(target_facing)
			target_y = point_world[2] - dy * cos(target_facing) + dx * sin(target_facing)
	return !!vessel.programmed_mission || distance() <= OVERMAP_APPROACH_RANGE + vessel.hull_radius

/datum/overmap_docking_approach/proc/distance()
	return sqrt((target_x - vessel.get_world_x()) ** 2 + (target_y - vessel.get_world_y()) ** 2)

/datum/overmap_docking_approach/proc/ready()
	return in_alignment_range() && available()

/datum/overmap_docking_approach/proc/in_alignment_range()
	if(!update_target())
		return FALSE
	if(!target)
		return distance() <= OVERMAP_APPROACH_READY
	var/turf/own_point = own[1]
	var/list/own_world = vessel.hull_to_world(own_point.x, own_point.y)
	var/turf/target_point = target[host ? 1 : 2]
	var/list/target_world = host ? host.hull_to_world(target_point.x, target_point.y) : space.to_world(target_point.x, target_point.y)
	return (own_world[1] - target_world[1]) ** 2 + (own_world[2] - target_world[2]) ** 2 <= OVERMAP_APPROACH_READY ** 2

/datum/overmap_docking_approach/proc/start_alignment()
	if(!ready())
		return "Подведите корабль ближе к синей области."
	aligning = TRUE
	previous_target_x = target_x
	previous_target_y = target_y
	previous_target_facing = target_facing
	deadline = world.time + OVERMAP_APPROACH_TIME
	vessel.flight.release_pilot()
	vessel.flight.set_autopilot(FALSE, manual = FALSE)
	vessel.flight.stop_burn()
	return TRUE

/datum/overmap_docking_approach/proc/process_approach(elapsed)
	if(!update_target())
		qdel(src)
		return
	if(!aligning)
		return
	if(!available())
		qdel(src)
		return
	var/fraction = clamp(elapsed / (2 SECONDS), 0, 1)
	var/carried_x = vessel.get_world_x() + target_x - previous_target_x
	var/carried_y = vessel.get_world_y() + target_y - previous_target_y
	if(host)
		vessel.flight.set_facing(vessel.get_facing() + closer_angle_difference(previous_target_facing, target_facing))
	previous_target_x = target_x
	previous_target_y = target_y
	previous_target_facing = target_facing
	var/angle = closer_angle_difference(vessel.get_facing(), target_facing)
	vessel.flight.angular_velocity = 0
	var/list/carried_speed = host ? host.world_point_velocity(target_x, target_y) : list(0, 0)
	vessel.speed[1] = carried_speed[1]
	vessel.speed[2] = carried_speed[2]
	vessel.flight.set_facing(vessel.get_facing() + angle * fraction)
	vessel.set_world_position(carried_x + (target_x - carried_x) * fraction, carried_y + (target_y - carried_y) * fraction)
	if((distance() > 0.15 || abs(angle) > 0.5) && world.time < deadline)
		return
	vessel.flight.set_facing(target_facing)
	vessel.set_world_position(target_x, target_y)
	owns_pad = FALSE
	if(host)
		INVOKE_ASYNC(vessel, TYPE_PROC_REF(/obj/overmap/entity, finish_ship_dock), host, own, target)
	else if(target)
		vessel.dock_to_station(own, target)
	else if(vessel.shuttle.canDock(pad) == SHUTTLE_CAN_DOCK)
		vessel.selected_dock_id = pad.id
		INVOKE_ASYNC(vessel, TYPE_PROC_REF(/obj/overmap/entity, finish_station_dock), pad)
	else
		vessel.announce_programmed("Посадочная область занята. Стыковка отменена.")
	owns_pad = FALSE
	qdel(src)

/datum/overmap_docking_approach/proc/available()
	if(!own || !target || !update_target())
		return !target && pad && vessel.shuttle?.canDock(pad) == SHUTTLE_CAN_DOCK
	if(!host)
		var/turf/own_tile = own[1]
		var/obj/machinery/door/airlock/external/docking/collar = locate() in own_tile
		if(!collar || !pad || pad.get_docked())
			return FALSE
		var/obj/machinery/door/airlock/external/docking/previous = vessel.shuttle.overmap_collar
		var/list/bounds = list(vessel.shuttle.width, vessel.shuttle.height, vessel.shuttle.dwidth, vessel.shuttle.dheight)
		vessel.shuttle.overmap_collar = collar
		var/valid = vessel.shuttle.canDock(pad) == SHUTTLE_CAN_DOCK
		vessel.shuttle.overmap_collar = previous
		vessel.shuttle.width = bounds[1]
		vessel.shuttle.height = bounds[2]
		vessel.shuttle.dwidth = bounds[3]
		vessel.shuttle.dheight = bounds[4]
		return valid
	if(host == vessel || host.docked_ship || vessel.docked_ship || length(vessel.docked_guests))
		return FALSE
	for(var/obj/overmap/entity/guest as anything in host.docked_guests)
		if(guest.dock_host_collar == target[1])
			return FALSE
	for(var/turf/tile as anything in vessel.hull_turfs)
		var/list/point = vessel.hull_to_world(tile.x, tile.y, target_x, target_y, target_facing)
		if(host.hull_turf_at(point[1], point[2]))
			return FALSE
		for(var/obj/overmap/entity/other as anything in vessel.nearby_ships)
			if(other != host && other.hull_turf_at(point[1], point[2]))
				return FALSE
	if(vessel.shuttle && host.shuttle)
		var/obj/overmap/entity/main = host
		var/obj/overmap/entity/guest = vessel
		if(vessel.formation_capacity() > host.formation_capacity())
			if(length(host.docked_guests))
				return FALSE
			main = vessel
			guest = host
		if(!main.flight_reservation || main.formation_transfer || guest.formation_transfer)
			return FALSE
		for(var/turf/tile as anything in guest.hull_turfs)
			var/list/point = guest == vessel ? vessel.hull_to_world(tile.x, tile.y, target_x, target_y, target_facing) : host.hull_to_world(tile.x, tile.y)
			var/list/physical = main == vessel ? vessel.world_to_hull(point[1], point[2], target_x, target_y, target_facing) : host.world_to_hull(point[1], point[2])
			var/turf/destination = overmap_fog_anchor(physical[1], physical[2], main.hull_z)
			if(!destination || SSmapping.used_turfs[destination] != main.flight_reservation || !isspaceturf(destination))
				return FALSE
			if(destination.x <= main.flight_bounds[1] || destination.y <= main.flight_bounds[2] || destination.x >= main.flight_bounds[3] || destination.y >= main.flight_bounds[4])
				return FALSE
	return TRUE

/datum/overmap_docking_approach/proc/choose_collar()
	var/list/best
	var/best_distance = INFINITY
	for(var/list/collar as anything in vessel.hull_collars)
		own = collar
		if(!available())
			continue
		var/offset = distance()
		if(offset < best_distance)
			best = collar
			best_distance = offset
	own = best
	return best && update_target()
