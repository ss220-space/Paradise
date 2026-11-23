/proc/overmap_approach_speed(distance, acceleration, reaction_time)
	if(distance <= 0 || acceleration <= 0)
		return 0
	return 2 * distance / (reaction_time + sqrt(reaction_time ** 2 + 2 * distance / acceleration))

/proc/cmp_overmap_navigation_beacon(obj/effect/landmark/overmap_navigation_beacon/a, obj/effect/landmark/overmap_navigation_beacon/b)
	return a.nav_order - b.nav_order

/proc/overmap_nav_intersects(list/start, list/finish, list/box)
	var/enter = 0
	var/leave = 1
	for(var/axis in 1 to 2)
		var/delta = finish[axis] - start[axis]
		if(abs(delta) < 0.00001)
			if(start[axis] < box[axis] || start[axis] > box[axis + 2])
				return FALSE
			continue
		var/low = (box[axis] - start[axis]) / delta
		var/high = (box[axis + 2] - start[axis]) / delta
		enter = max(enter, min(low, high))
		leave = min(leave, max(low, high))
		if(enter > leave)
			return FALSE
	return TRUE

/proc/overmap_nav_inside(list/point, list/box)
	return point[1] >= box[1] && point[1] <= box[3] && point[2] >= box[2] && point[2] <= box[4]

/proc/overmap_nav_clear(list/start, list/finish, list/boxes)
	for(var/list/box as anything in boxes)
		if(overmap_nav_intersects(start, finish, box))
			return FALSE
	return TRUE

/proc/overmap_navigation_entry(list/box, list/target)
	var/center_x = (box[1] + box[3]) / 2
	var/center_y = (box[2] + box[4]) / 2
	var/dx = target[1] - center_x
	var/dy = target[2] - center_y
	if(!dx && !dy)
		dy = 1
	var/scale_x = dx ? (box[3] - box[1] + 2) / (2 * abs(dx)) : INFINITY
	var/scale_y = dy ? (box[4] - box[2] + 2) / (2 * abs(dy)) : INFINITY
	var/scale = min(scale_x, scale_y)
	return list(center_x + dx * scale, center_y + dy * scale)

/proc/overmap_navigation_path(list/start, list/finish, list/boxes, list/limits)
	if(!length(boxes))
		return (!limits || overmap_nav_inside(finish, limits)) ? list(finish) : null
	return RUSTLIB_CALL(overmap_sector_path, start, finish, boxes, limits)
