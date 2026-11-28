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

/obj/overmap/entity/virtual_structure/proc/cache_collision_hull()
	if(native_collision_version == hull_version)
		return TRUE
	var/list/edges = list()
	for(var/list/cell as anything in collision_cells())
		edges += cell[1] - hull_center_x
		edges += cell[2] - hull_center_y
	var/list/solid = list()
	var/list/targets = list()
	for(var/key, cell_entry in virtual_cells)
		var/list/cell = cell_entry
		var/datum/overmap_virtual_model/model = cell[3]
		if(cell[4] > 0 && model.solid)
			solid += cell[1]
			solid += cell[2]
			targets += list(cell)
	if(!RUSTLIB_CALL(overmap_hull_upload, src, edges, solid))
		return FALSE
	collision_targets = targets
	native_collision_version = hull_version
	return TRUE

/obj/overmap/entity/virtual_structure/find_impact(obj/overmap/entity/other)
	var/obj/overmap/entity/virtual_structure/structure = other
	if(!istype(structure) || !cache_collision_hull() || !structure.cache_collision_hull())
		return ..()
	var/list/start = pose_at(0)
	var/list/target_start = structure.pose_at(0)
	var/steps = max(CEILING((pose_travel() + structure.pose_travel()) / OVERMAP_RAM_SWEEP_STEP, 1), 1)
	var/list/sweep = list(
		start[1], start[2], start[3],
		get_world_x() - start[1], get_world_y() - start[2], closer_angle_difference(start[3], get_facing()),
		target_start[1], target_start[2], target_start[3],
		structure.get_world_x() - target_start[1], structure.get_world_y() - target_start[2], closer_angle_difference(target_start[3], structure.get_facing()),
		structure.hull_center_x, structure.hull_center_y, steps, OVERMAP_RAM_REFINE_STEPS,
	)
	var/list/hits = RUSTLIB_CALL(overmap_hull_impact, src, structure, sweep)
	if(isnull(hits))
		return ..()
	if(!length(hits))
		return null
	var/list/contacts = list()
	for(var/i in 2 to length(hits) step 4)
		contacts += list(list(collision_edge[hits[i]], structure.collision_targets[hits[i + 1]], list(hits[i + 2], hits[i + 3])))
	return list(hits[1], contacts)

/obj/overmap/entity/virtual_structure/contacts_at(fraction, obj/overmap/entity/other)
	. = list()
	var/list/pose = pose_at(fraction)
	var/list/other_pose = other?.pose_at(fraction)
	if(istype(other, /obj/overmap/entity/virtual_structure))
		var/obj/overmap/entity/virtual_structure/structure = other
		if(cache_collision_hull() && structure.cache_collision_hull())
			var/list/frame = list(pose[1], pose[2], cos(pose[3]), sin(pose[3]), other_pose[1], other_pose[2], cos(other_pose[3]), sin(other_pose[3]), structure.hull_center_x, structure.hull_center_y)
			var/list/hits = RUSTLIB_CALL(overmap_hull_contacts, src, structure, frame)
			for(var/i in 1 to length(hits) step 4)
				. += list(list(collision_edge[hits[i]], structure.collision_targets[hits[i + 1]], list(hits[i + 2], hits[i + 3])))
			return
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

/obj/overmap/entity/virtual_structure/hull_turf_at(world_x, world_y, origin_x = get_world_x(), origin_y = get_world_y(), facing = get_facing())
	return null

/obj/overmap/entity/virtual_structure/solid_hull_at(world_x, world_y)
	return null

/obj/overmap/entity/virtual_structure/scatter_contact_at(hull_x, hull_y)
	var/list/cell = virtual_cells["[FLOOR(hull_x + 0.5, 1)],[FLOOR(hull_y + 0.5, 1)]"]
	return cell && cell[4] > 0 ? cell : null

/obj/overmap/entity/virtual_structure/scatter_carp_turf(contact, world_x, world_y)
	return local_space?.turf_at(world_x, world_y)
