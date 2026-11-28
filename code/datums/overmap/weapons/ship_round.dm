/datum/overmap_projectile/proc/steer_missile(elapsed)
	var/obj/projectile/ship_round/missile = payload
	if(!istype(missile) || !missile.guided)
		return
	var/obj/overmap/entity/best
	var/best_distance = missile.seeker_range ** 2
	for(var/obj/overmap/entity/target as anything in SSovermap.vessels)
		if((!target.shuttle && (!istype(target, /obj/overmap/entity/virtual_structure) || !target.movable)) || target == payload.overmap_firer_vessel || target.sector != sector || target.is_jumping() || target.overmap_pod)
			continue
		var/dx = target.get_world_x() - world_x
		var/dy = target.get_world_y() - world_y
		var/distance = dx ** 2 + dy ** 2
		if(distance >= best_distance || abs(closer_angle_difference(propulsion_angle, delta_to_angle(dx, dy))) > missile.seeker_arc / 2)
			continue
		best = target
		best_distance = distance
	if(best)
		var/change = closer_angle_difference(propulsion_angle, delta_to_angle(best.get_world_x() - world_x, best.get_world_y() - world_y))
		var/limit = missile.turn_rate * elapsed / (1 SECONDS)
		propulsion_angle = SIMPLIFY_DEGREES(propulsion_angle + clamp(change, -limit, limit))
		var/velocity_x = sin(propulsion_angle) * propulsion_speed + inherited_x
		var/velocity_y = cos(propulsion_angle) * propulsion_speed + inherited_y
		payload.overmap_velocity = sqrt(velocity_x ** 2 + velocity_y ** 2)
		angle = delta_to_angle(velocity_x, velocity_y)
		payload.set_angle(angle)
