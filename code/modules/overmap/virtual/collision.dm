/obj/overmap/entity/proc/collide_virtual(obj/overmap/entity/virtual_structure/other)
	if(navigation_collision_disabled() || other.navigation_collision_disabled())
		return
	var/steps = max(1, CEILING((pose_travel() + other.pose_travel()) / 0.4, 1))
	for(var/step in 1 to steps)
		var/list/pose = pose_at(step / steps)
		for(var/turf/edge as anything in hull_edge)
			var/list/point = hull_to_world(edge.x, edge.y, pose[1], pose[2], pose[3])
			var/list/cell = other.cell_at(point[1], point[2], TRUE, other.pose_at(step / steps))
			if(!cell)
				continue
			var/health = cell[4]
			var/own_health = overmap_pod ? max(1, overmap_pod.pod().health) : overmap_contact_health(edge)
			var/energy = mass_impact_damage(relative_speed(other) * (1 SECONDS), other)
			var/target_damage = overmap_contact_damage(energy, health, own_health)
			other.damage_cell(cell, target_damage)
			var/loss = cell[4] > 0 ? 1 : clamp(health / max(target_damage, 1), 0.02, 1)
			if(world.time >= next_ram_damage)
				next_ram_damage = world.time + OVERMAP_FLIGHT_TICK
				var/own_damage = overmap_contact_damage(energy, own_health, health)
				if(overmap_pod)
					overmap_pod.pod().deal_damage(own_damage)
				else
					overmap_damage_turf(edge, own_damage)
			set_pose(pose_at((step - 1) / steps))
			var/dx = speed[1] - other.speed[1]
			var/dy = speed[2] - other.speed[2]
			var/length = sqrt(dx ** 2 + dy ** 2)
			if(length)
				ram(other, -dx / length, -dy / length, point[1], point[2], 0, TRUE, null, loss)
			return

/obj/overmap/entity/virtual_structure/sector_obstacle_box(span)
	return list(get_world_x() - hull_radius, get_world_y() - hull_radius, get_world_x() + hull_radius, get_world_y() + hull_radius)

/obj/overmap/entity/virtual_structure/proc/collision_cells()
	if(collision_edge_version == hull_version && collision_edge)
		return collision_edge
	collision_edge_version = hull_version
	collision_edge = list()
	for(var/key, cell_entry in virtual_cells)
		var/list/cell = cell_entry
		if(cell[4] <= 0)
			continue
		for(var/dir in GLOB.cardinal)
			var/x = cell[1] + (dir == EAST ? 1 : dir == WEST ? -1 : 0)
			var/y = cell[2] + (dir == NORTH ? 1 : dir == SOUTH ? -1 : 0)
			var/list/neighbor = virtual_cells["[x],[y]"]
			if(!neighbor || neighbor[4] <= 0)
				collision_edge += list(cell)
				break
	return collision_edge

/obj/overmap/entity/virtual_structure/collide(obj/overmap/entity/other)
	if(navigation_collision_disabled() || other?.navigation_collision_disabled())
		return
	if(other && !istype(other, /obj/overmap/entity/virtual_structure))
		return other.collide_virtual(src)
	if(!flight || !movable)
		if(other?.flight && other.movable)
			return other.collide(src)
		return
	var/datum/overmap_bubble/space = collision_space()
	if(!other && !space)
		return
	var/steps = max(1, CEILING((pose_travel() + other?.pose_travel()) / 0.4, 1))
	for(var/step in 1 to steps)
		var/list/pose = pose_at(step / steps)
		for(var/list/cell as anything in collision_cells())
			var/list/point = hull_to_world(cell[1], cell[2], pose[1], pose[2], pose[3])
			var/turf/struck
			var/list/target_cell
			var/obj/overmap/entity/virtual_structure/virtual_target = other
			if(virtual_target)
				target_cell = virtual_target.cell_at(point[1], point[2], TRUE, other.pose_at(step / steps))
			else
				struck = space.solid_turf_at(point[1], point[2])
			if(!struck && !target_cell)
				continue
			var/target_health = target_cell ? target_cell[4] : overmap_contact_health(struck)
			var/severity = other ? relative_speed(other) * (1 SECONDS) : get_speed() * OVERMAP_TILE_SPAN * (1 SECONDS)
			var/energy = mass_impact_damage(severity, other)
			var/target_damage = overmap_contact_damage(energy, target_health, cell[4])
			var/own_damage = overmap_contact_damage(energy, cell[4], target_health)
			var/blocked
			if(target_cell)
				virtual_target.damage_cell(target_cell, target_damage)
				blocked = target_cell[4] > 0
			else
				var/tx = struck.x
				var/ty = struck.y
				var/tz = struck.z
				overmap_damage_turf(struck, target_damage)
				struck = locate(tx, ty, tz)
				blocked = space.is_solid(struck)
			damage_cell(cell, own_damage)
			set_pose(pose_at((step - 1) / steps))
			var/dx = speed[1] - (other ? other.speed[1] : 0)
			var/dy = speed[2] - (other ? other.speed[2] : 0)
			var/magnitude = sqrt(dx ** 2 + dy ** 2)
			if(magnitude)
				ram(other, -dx / magnitude, -dy / magnitude, point[1], point[2], 0, TRUE, null, blocked ? 1 : clamp(target_health / max(target_damage, 1), 0.02, 1))
			return

/datum/overmap_projectile/proc/virtual_hit(obj/overmap/entity/virtual_structure/structure, x, y)
	var/list/cell = structure.cell_at(x, y, TRUE)
	if(!cell)
		return FALSE
	if(ion_impact(x, y))
		return TRUE
	var/key = "[structure.UID()]:[cell[1]],[cell[2]]"
	if(key in payload.ship_pierced_tiles)
		return FALSE
	var/pierce = payload.ship_penetrations > 0 && prob(payload.ship_penetration_chance)
	if(pierce)
		payload.ship_penetrations--
		payload.damage *= payload.ship_penetration_decay
		LAZYADD(payload.ship_pierced_tiles, key)
	structure.damage_cell(cell, payload.damage)
	if(istype(payload, /obj/projectile/bullet/ship_artillery) && (!pierce || !payload.ship_penetrations))
		for(var/ix in -2 to 2)
			for(var/iy in -2 to 2)
				var/list/nearby = structure.cell_at(x + ix, y + iy, TRUE)
				if(nearby)
					structure.damage_cell(nearby, max(0, 150 - 50 * sqrt(ix ** 2 + iy ** 2)))
		var/obj/projectile/bullet/ship_artillery/shell = payload
		var/turf/blast = SSovermap.sector_explosion_turf(sector, x, y)
		if(blast)
			shell.detonate(blast)
		else
			SSovermap.show_sector_explosion(sector, x, y)
		qdel(src)
		return TRUE
	if(!pierce)
		qdel(src)
		return TRUE
	return FALSE

/obj/overmap/entity/virtual_structure/hull_turf_at(world_x, world_y, origin_x = get_world_x(), origin_y = get_world_y(), facing = get_facing())
	return null

/obj/overmap/entity/virtual_structure/solid_hull_at(world_x, world_y)
	return null

/obj/overmap/entity/virtual_structure/collide_scatter(list/candidates, travel)
	if(!movable || !flight || navigation_collision_disabled())
		return
	var/steps = max(1, CEILING(travel / 0.4, 1))
	for(var/step in 1 to steps)
		var/list/pose = pose_at(step / steps)
		for(var/obj/overmap/feature/hazard/field as anything in candidates)
			for(var/index in candidates[field])
				if(field.scatter_points[index + 2] <= 0)
					continue
				var/x = field.scatter_points[index]
				var/y = field.scatter_points[index + 1]
				var/list/cell = cell_at(x, y, FALSE, pose)
				if(!cell)
					continue
				if(istype(field, /obj/overmap/feature/hazard/carp))
					var/turf/spot = local_space?.turf_at(x, y)
					if(spot && !spot.is_blocked_turf(exclude_mobs = TRUE))
						field.damage_scatter(index, 40)
						new /mob/living/simple_animal/hostile/carp(spot)
					continue
				var/health = field.scatter_points[index + 2]
				var/energy = mass_impact_damage(get_speed() * OVERMAP_TILE_SPAN * (1 SECONDS))
				var/target_damage = overmap_contact_damage(energy, health, cell[4])
				var/own_damage = overmap_contact_damage(energy, cell[4], health)
				field.damage_scatter(index, target_damage)
				if(world.time >= next_ram_damage)
					next_ram_damage = world.time + OVERMAP_FLIGHT_TICK
					damage_cell(cell, own_damage)
				set_pose(pose_at((step - 1) / steps))
				var/retained = field.scatter_points[index + 2] > 0 ? 0 : 1 - clamp(health / max(target_damage, 1), 0.02, 1)
				speed[1] *= retained
				speed[2] *= retained
				return
