/proc/overmap_ai_standoff_point(x, y, angle, radius, list/limits)
	for(var/index in 0 to 8)
		var/offset = index ? round((index + 1) / 2) * 45 * (index % 2 ? 1 : -1) : 0
		var/point_x = x + sin(angle + offset) * radius
		var/point_y = y + cos(angle + offset) * radius
		if(point_x >= limits[1] && point_x <= limits[3] && point_y >= limits[2] && point_y <= limits[4])
			return list(point_x, point_y)
	var/best_distance = -1
	var/list/best
	for(var/ix in list(1, 3))
		for(var/iy in list(2, 4))
			var/distance = (limits[ix] - x) ** 2 + (limits[iy] - y) ** 2
			if(distance > best_distance)
				best_distance = distance
				best = list(limits[ix], limits[iy])
	return best

/proc/overmap_ai_intercept(dx, dy, relative_x, relative_y, speed, muzzle_distance = 0, muzzle_turn_speed = 0)
	if(speed <= 0)
		return null
	var/a = relative_x ** 2 + relative_y ** 2 - speed ** 2 - muzzle_turn_speed ** 2
	var/b = 2 * (dx * relative_x + dy * relative_y - muzzle_distance * speed)
	var/c = dx ** 2 + dy ** 2 - muzzle_distance ** 2
	if(c < 0.001)
		return 0
	if(abs(a) < 0.000001)
		return b < 0 ? -c / b : null
	var/discriminant = b ** 2 - 4 * a * c
	if(discriminant < 0)
		return null
	var/first = (-b - sqrt(discriminant)) / (2 * a)
	var/second = (-b + sqrt(discriminant)) / (2 * a)
	if(first >= 0 && second >= 0)
		return min(first, second)
	return first >= 0 ? first : second >= 0 ? second : null
