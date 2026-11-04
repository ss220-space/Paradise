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

/obj/overmap/entity/virtual_structure/contacts_at(fraction, obj/overmap/entity/other)
	. = list()
	var/list/pose = pose_at(fraction)
	var/list/other_pose = other?.pose_at(fraction)
	var/datum/overmap_bubble/space = collision_space()
	if(!other && !space)
		return
	for(var/list/cell as anything in collision_cells())
		var/list/point = hull_to_world(cell[1], cell[2], pose[1], pose[2], pose[3])
		var/target
		if(istype(other, /obj/overmap/entity/virtual_structure))
			var/obj/overmap/entity/virtual_structure/structure = other
			target = structure.cell_at(point[1], point[2], TRUE, other_pose)
		else if(other)
			var/turf/spot = other.hull_turf_at(point[1], point[2], other_pose[1], other_pose[2], other_pose[3])
			if(other.overmap_pod || overmap_turf_blocked(spot))
				target = spot
		else
			target = space.solid_turf_at(point[1], point[2])
		if(target)
			. += list(list(cell, target, point))

/obj/overmap/entity/virtual_structure/hull_face(list/cell)
	var/face_x = 0
	var/face_y = 0
	for(var/direction in GLOB.cardinal)
		var/x = cell[1] + (!!(direction & EAST) - !!(direction & WEST))
		var/y = cell[2] + (!!(direction & NORTH) - !!(direction & SOUTH))
		var/list/neighbor = virtual_cells["[x],[y]"]
		if(neighbor && neighbor[4] > 0)
			continue
		face_x += !!(direction & EAST) - !!(direction & WEST)
		face_y += !!(direction & NORTH) - !!(direction & SOUTH)
	var/facing = get_facing()
	return list(face_x * cos(facing) + face_y * sin(facing), face_y * cos(facing) - face_x * sin(facing))

/datum/overmap_projectile/proc/virtual_hit(obj/overmap/entity/virtual_structure/structure, x, y)
	var/list/cell = structure.cell_at(x, y, TRUE)
	if(!cell)
		return FALSE
	if(ion_impact(x, y))
		return TRUE
	var/key = "[structure.UID()]:[cell[1]],[cell[2]]"
	if(key in payload.ship_pierced_tiles)
		return FALSE
	var/pierce = payload.try_ship_penetration(key)
	structure.damage_cell(cell, payload.damage)
	if(istype(payload, /obj/projectile/bullet/ship_artillery) && (!pierce || !payload.ship_penetrations))
		detonate_shell(x, y)
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

/obj/overmap/entity/virtual_structure/scatter_contact_at(hull_x, hull_y)
	var/list/cell = virtual_cells["[FLOOR(hull_x + 0.5, 1)],[FLOOR(hull_y + 0.5, 1)]"]
	return cell && cell[4] > 0 ? cell : null

/obj/overmap/entity/virtual_structure/scatter_carp_turf(contact, world_x, world_y)
	return local_space?.turf_at(world_x, world_y)
