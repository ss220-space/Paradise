/datum/overmap_map_view
	var/atom/movable/screen/map_view/camera/cam_screen
	var/turf/last_center
	var/last_range = 0
	var/map_view_min_x
	var/map_view_min_y
	var/last_size_x = 0
	var/last_size_y = 0

/datum/overmap_map_view/New(atom/movable/screen/map_view/camera/screen)
	cam_screen = screen

/datum/overmap_map_view/Destroy()
	cam_screen = null
	last_center = null
	return ..()

/datum/overmap_map_view/proc/clear()
	last_center = null
	last_range = 0
	last_size_x = 0
	last_size_y = 0
	cam_screen?.show_camera_static()

/datum/overmap_map_view/proc/fit_zoom(box_w, box_h)
	var/tiles_x = max(last_size_x, 1)
	var/tiles_y = max(last_size_y, 1)
	return min(box_w / (tiles_x * world.icon_size), box_h / (tiles_y * world.icon_size))

/datum/overmap_map_view/proc/refresh(obj/overmap/entity/vessel, range, force = FALSE)
	if(!cam_screen)
		return FALSE
	if(!vessel?.sector)
		clear()
		return TRUE
	var/turf/here = vessel.get_overmap_turf()
	if(!here)
		clear()
		return TRUE
	if(!force && here == last_center && range == last_range)
		return FALSE
	last_center = here
	last_range = range
	var/tiles = range * 2 + 1
	var/res_min_x = vessel.sector.origin_x
	var/res_min_y = vessel.sector.origin_y
	var/res_max_x = vessel.sector.reserved_max_x()
	var/res_max_y = vessel.sector.reserved_max_y()
	tiles = min(tiles, res_max_x - res_min_x + 1, res_max_y - res_min_y + 1)
	var/min_x = clamp(here.x - range, res_min_x, res_max_x - tiles + 1)
	var/min_y = clamp(here.y - range, res_min_y, res_max_y - tiles + 1)
	var/max_x = min_x + tiles - 1
	var/max_y = min_y + tiles - 1
	map_view_min_x = min_x
	map_view_min_y = min_y
	last_size_x = tiles
	last_size_y = tiles
	cam_screen.show_camera(block(locate(min_x, min_y, here.z), locate(max_x, max_y, here.z)), tiles, tiles)
	return TRUE

/datum/overmap_map_view/proc/refresh_size(obj/overmap/entity/vessel, tiles, force = FALSE)
	if(!cam_screen)
		return FALSE
	if(!vessel?.sector)
		clear()
		return TRUE
	var/turf/here = vessel.get_overmap_turf()
	if(!here)
		clear()
		return TRUE
	tiles = max(1, tiles)
	if(!force && here == last_center && last_range == tiles)
		return FALSE
	last_center = here
	last_range = tiles
	var/res_min_x = vessel.sector.origin_x
	var/res_min_y = vessel.sector.origin_y
	var/res_max_x = vessel.sector.reserved_max_x()
	var/res_max_y = vessel.sector.reserved_max_y()
	tiles = min(tiles, res_max_x - res_min_x + 1, res_max_y - res_min_y + 1)
	var/range = round((tiles - 1) / 2)
	var/min_x = clamp(here.x - range, res_min_x, res_max_x - tiles + 1)
	var/min_y = clamp(here.y - range, res_min_y, res_max_y - tiles + 1)
	var/max_x = min_x + tiles - 1
	var/max_y = min_y + tiles - 1
	map_view_min_x = min_x
	map_view_min_y = min_y
	last_size_x = tiles
	last_size_y = tiles
	cam_screen.show_camera(block(locate(min_x, min_y, here.z), locate(max_x, max_y, here.z)), tiles, tiles)
	return TRUE

/datum/overmap_map_view/proc/refresh_rect(obj/overmap/entity/vessel, size_x, size_y, force = FALSE)
	if(!cam_screen)
		return FALSE
	if(!vessel?.sector)
		clear()
		return TRUE
	var/turf/here = vessel.get_overmap_turf()
	if(!here)
		clear()
		return TRUE
	size_x = max(1, size_x)
	size_y = max(1, size_y)
	var/res_min_x = vessel.sector.origin_x
	var/res_min_y = vessel.sector.origin_y
	var/res_max_x = vessel.sector.reserved_max_x()
	var/res_max_y = vessel.sector.reserved_max_y()
	size_x = min(size_x, res_max_x - res_min_x + 1)
	size_y = min(size_y, res_max_y - res_min_y + 1)
	if(!force && here == last_center && last_size_x == size_x && last_size_y == size_y)
		return FALSE
	last_center = here
	last_range = 0
	last_size_x = size_x
	last_size_y = size_y
	var/min_x = clamp(here.x - round((size_x - 1) / 2), res_min_x, res_max_x - size_x + 1)
	var/min_y = clamp(here.y - round((size_y - 1) / 2), res_min_y, res_max_y - size_y + 1)
	var/max_x = min_x + size_x - 1
	var/max_y = min_y + size_y - 1
	map_view_min_x = min_x
	map_view_min_y = min_y
	cam_screen.show_camera(block(locate(min_x, min_y, here.z), locate(max_x, max_y, here.z)), size_x, size_y)
	return TRUE
