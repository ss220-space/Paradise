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
	if(limits && !overmap_nav_inside(finish, limits))
		return null
	var/list/containing = list()
	for(var/list/box as anything in boxes)
		if(overmap_nav_inside(start, box))
			containing += list(box)
	if(length(containing))
		var/list/outside = boxes.Copy()
		outside -= containing
		var/list/exit
		var/exit_distance = INFINITY
		for(var/list/box as anything in containing)
			var/list/candidates = list(list(box[1] - 1, clamp(start[2], box[2], box[4])), list(box[3] + 1, clamp(start[2], box[2], box[4])), list(clamp(start[1], box[1], box[3]), box[2] - 1), list(clamp(start[1], box[1], box[3]), box[4] + 1))
			candidates += list(list(box[1] - 1, box[2] - 1), list(box[1] - 1, box[4] + 1), list(box[3] + 1, box[2] - 1), list(box[3] + 1, box[4] + 1))
			for(var/list/point as anything in candidates)
				if((limits && !overmap_nav_inside(point, limits)) || !overmap_nav_clear(point, point, boxes) || !overmap_nav_clear(start, point, outside))
					continue
				var/distance = (point[1] - start[1]) ** 2 + (point[2] - start[2]) ** 2
				if(distance < exit_distance)
					exit = point
					exit_distance = distance
		if(!exit)
			return null
		var/list/remainder = overmap_navigation_path(exit, finish, boxes, limits)
		if(!length(remainder))
			return null
		remainder.Insert(1, list(exit))
		return remainder
	if(overmap_nav_clear(start, finish, boxes))
		return list(finish)
	var/list/nodes = list(start, finish)
	for(var/list/box as anything in boxes)
		for(var/list/corner as anything in list(list(box[1] - 1, box[2] - 1), list(box[1] - 1, box[4] + 1), list(box[3] + 1, box[2] - 1), list(box[3] + 1, box[4] + 1)))
			if((!limits || overmap_nav_inside(corner, limits)) && overmap_nav_clear(corner, corner, boxes))
				nodes += list(corner)
		if(length(nodes) > 512)
			return null
		CHECK_TICK
	var/list/open = list(1)
	var/list/costs = list("1" = 0)
	var/list/parents = list()
	var/list/closed = list()
	while(length(open))
		var/best
		var/best_score = INFINITY
		for(var/index in open)
			var/list/point = nodes[index]
			var/score = costs["[index]"] + sqrt((point[1] - finish[1]) ** 2 + (point[2] - finish[2]) ** 2)
			if(score < best_score)
				best = index
				best_score = score
		open -= best
		if(best == 2)
			var/list/path = list()
			while(best != 1)
				path.Insert(1, list(nodes[best]))
				best = parents["[best]"]
			return path
		closed["[best]"] = TRUE
		var/list/from = nodes[best]
		for(var/index in 2 to length(nodes))
			if(closed["[index]"])
				continue
			var/list/destination = nodes[index]
			var/cost = costs["[best]"] + sqrt((from[1] - destination[1]) ** 2 + (from[2] - destination[2]) ** 2)
			if(!isnull(costs["[index]"]) && costs["[index]"] <= cost)
				continue
			if(!overmap_nav_clear(from, destination, boxes))
				continue
			costs["[index]"] = cost
			parents["[index]"] = best
			open |= index
		CHECK_TICK
	return null
