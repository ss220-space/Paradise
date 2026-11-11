/proc/overmap_seal_block_with_hyperspace(turf/bottom_left, turf/top_right)
	if(!bottom_left || !top_right || bottom_left.z != top_right.z)
		return
	var/width = top_right.x - bottom_left.x + 1
	var/height = top_right.y - bottom_left.y + 1
	var/turf/inner_corner = locate(bottom_left.x + 1, bottom_left.y + 1, bottom_left.z)
	var/list/edges = (width <= 2 || height <= 2) ? block(bottom_left, top_right) : CORNER_OUTLINE(inner_corner, width - 2, height - 2)
	for(var/turf/spot as anything in edges)
		spot.ChangeTurf(/turf/simulated/floor/indestructible/hyperspace, FALSE, FALSE, CHANGETURF_IGNORE_AIR)
		CHECK_TICK
