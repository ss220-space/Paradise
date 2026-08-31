/area/overmap
	name = "Overmap"
	icon_state = "start"
	requires_power = FALSE
	always_unpowered = TRUE
	static_lighting = FALSE
	base_lighting_alpha = 255
	valid_territory = FALSE
	no_teleportlocs = TRUE
	outdoors = FALSE
	var/overmap_size = OVERMAP_DEFAULT_SIZE
	var/overmap_origin_x = 1
	var/overmap_origin_y = 1

/turf/simulated/floor/indestructible/overmap
	name = "deep space"
	desc = "Карта системы. Сюда нельзя попасть пешком."
	icon = OVERMAP_ICON_FILE
	icon_state = "map"
	plane = FLOOR_PLANE
	layer = TURF_LAYER
	space_lit = TRUE
	luminosity = 1
	blocks_air = TRUE
	init_air = FALSE
	underfloor_accessibility = UNDERFLOOR_HIDDEN
	keep_dir = FALSE

/turf/simulated/floor/indestructible/overmap/Initialize(mapload)
	. = ..()
	icon = OVERMAP_ICON_FILE
	icon_state = "map"
	icon_regular_floor = "map"
	icon_regular_floor_dmi = OVERMAP_ICON_FILE
	var/area/overmap/overmap_area = loc
	if(istype(overmap_area))
		name = "[x - overmap_area.overmap_origin_x + 1]-[y - overmap_area.overmap_origin_y + 1]"
	else
		name = "[x]-[y]"
	SET_PLANE_IMPLICIT(src, FLOOR_PLANE)
	if(lighting_object)
		vis_contents -= lighting_object
		QDEL_NULL(lighting_object)

/turf/simulated/floor/indestructible/overmap/proc/add_edge_numbers()
	var/area/overmap/overmap_area = loc
	var/map_size = istype(overmap_area) ? overmap_area.overmap_size : OVERMAP_DEFAULT_SIZE
	var/origin_x = istype(overmap_area) ? overmap_area.overmap_origin_x : 1
	var/origin_y = istype(overmap_area) ? overmap_area.overmap_origin_y : 1
	var/local_x = x - origin_x + 1
	var/local_y = y - origin_y + 1
	var/list/numbers = list()
	if(local_x == 1 || local_x == map_size)
		numbers += list("[round(local_y / 10)]", "[round(local_y % 10)]")
		if(local_y == 1 || local_y == map_size)
			numbers += "-"
	if(local_y == 1 || local_y == map_size)
		numbers += list("[round(local_x / 10)]", "[round(local_x % 10)]")
	if(!length(numbers))
		return
	for(var/i in 1 to length(numbers))
		var/image/number_overlay = image(OVERMAP_NUMBERS_ICON_FILE, numbers[i])
		number_overlay.pixel_x = 5 * i - 2
		number_overlay.pixel_y = world.icon_size / 2 - 3
		if(local_y == 1)
			number_overlay.pixel_y = 3
			number_overlay.pixel_x = 5 * i + 4
		if(local_y == map_size)
			number_overlay.pixel_y = world.icon_size - 9
			number_overlay.pixel_x = 5 * i + 4
		if(local_x == 1)
			number_overlay.pixel_x = 5 * i - 2
		if(local_x == map_size)
			number_overlay.pixel_x = 5 * i + 2
		add_overlay(number_overlay)

/turf/simulated/floor/indestructible/overmap/Click(location, control, params)
	var/obj/machinery/computer/sensors/sensors = usr?.machine
	if(!istype(sensors))
		sensors = overmap_open_sensor_console(usr)
	if(istype(sensors) && sensors.try_map_click(usr, src))
		return
	var/obj/machinery/computer/helm/helm = usr?.machine
	if(istype(helm) && helm.mark_atom(usr, src))
		return
	return ..()

/turf/simulated/floor/indestructible/overmap/edge
	name = "map edge"
	icon = OVERMAP_ICON_FILE
	icon_state = "map"
	color = "#222222"
	density = TRUE
	opacity = FALSE

/turf/simulated/floor/indestructible/overmap/edge/Initialize(mapload)
	. = ..()
	icon = OVERMAP_ICON_FILE
	icon_state = "map"
	color = "#222222"

/turf/simulated/floor/indestructible/overmap/edge/buffer
	name = "map void"
	desc = null
	opacity = TRUE
	density = TRUE
	color = "#000000"
	space_lit = FALSE
	luminosity = 0

/turf/simulated/floor/indestructible/overmap/edge/buffer/Initialize(mapload)
	. = ..()
	icon = OVERMAP_ICON_FILE
	icon_state = "map"
	color = "#000000"
	name = "map void"
