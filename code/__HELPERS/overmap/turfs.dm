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

/proc/overmap_release_area(area/owned_area)
	if(QDELETED(owned_area))
		return
	var/area/world_area = GLOB.areas_by_type[world.area]
	for(var/z_level in 1 to length(owned_area.turfs_by_zlevel))
		var/list/tiles = owned_area.get_turfs_by_zlevel(z_level)
		if(!length(tiles))
			continue
		LISTASSERTLEN(world_area.turfs_by_zlevel, z_level, list())
		if(length(world_area.turfs_to_uncontain_by_zlevel) >= z_level)
			world_area.turfs_to_uncontain_by_zlevel[z_level] -= tiles
		world_area.contents += tiles
		world_area.turfs_by_zlevel[z_level] |= tiles
	qdel(owned_area)
