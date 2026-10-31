/datum/component/ship_weapon/proc/target_position(obj/overmap/entity/vessel, mob/living/target)
	if(QDELETED(target) || target.stat == DEAD || target.invisibility > SEE_INVISIBLE_LIVING)
		return null
	var/obj/machinery/porta_turret/turret = parent
	var/turf/spot = get_turf(target)
	var/datum/owner = SSovermap.frame_owner(spot)
	if(!owner || SSovermap.frame_sector(owner) != vessel.sector)
		return null
	var/list/point = SSovermap.frame_to_world(owner, spot)
	var/list/origin = world_position(vessel)
	if(!origin || (point[1] - origin[1]) ** 2 + (point[2] - origin[2]) ** 2 > turret.scan_range ** 2 || !can_aim(vessel, point[1], point[2]))
		return null
	if(turret.assess_living(target, TRUE) == TURRET_NOT_TARGET)
		return null
	var/angle = delta_to_angle(point[1] - origin[1], point[2] - origin[2])
	origin[1] += sin(angle) * muzzle_distance
	origin[2] += cos(angle) * muzzle_distance
	return SSovermap.weapon_line_clear(vessel.sector, origin, point) ? point : null

/datum/controller/subsystem/overmap/proc/weapon_line_clear(datum/overmap_sector/sector, list/start, list/finish)
	var/dx = finish[1] - start[1]
	var/dy = finish[2] - start[2]
	var/distance = sqrt(dx ** 2 + dy ** 2)
	var/list/nearby = list()
	for(var/obj/overmap/entity/vessel as anything in flying_vessels)
		if(vessel.sector == sector && abs(vessel.get_world_x() - start[1]) <= vessel.hull_radius + distance && abs(vessel.get_world_y() - start[2]) <= vessel.hull_radius + distance)
			nearby += vessel
	var/steps = max(1, CEILING(distance / 0.5, 1))
	for(var/step in 0 to steps - 1)
		var/x = start[1] + dx * step / steps
		var/y = start[2] + dy * step / steps
		for(var/obj/overmap/entity/vessel as anything in nearby)
			if(istype(vessel, /obj/overmap/entity/virtual_structure))
				var/obj/overmap/entity/virtual_structure/structure = vessel
				if(structure.cell_at(x, y, TRUE))
					return FALSE
				continue
			if(weapon_turf_opaque(vessel.hull_turf_at(x, y)))
				return FALSE
		for(var/datum/overmap_bubble/space as anything in bubbles)
			if(space.static_level && space.sector == sector && weapon_turf_opaque(space.turf_at(x, y)))
				return FALSE
	return TRUE

/proc/weapon_turf_opaque(turf/spot)
	if(!spot)
		return FALSE
	if(spot.opacity)
		return TRUE
	for(var/atom/movable/object in spot)
		if(object.opacity && !QDELETED(object))
			return TRUE
	return FALSE
