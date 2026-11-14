/obj/effect/spawner/ship_engine_catalog
	name = "all ship engines spawner (15 engines)"
	desc = "TEMP123TEMP"
	icon = 'icons/turf/shuttle/misc.dmi'
	icon_state = "propulsion"

/obj/effect/spawner/ship_engine_catalog/proc/engine_types()
	return GLOB.ship_engine_types

/obj/effect/spawner/ship_engine_catalog/Initialize(mapload)
	. = ..()
	var/turf/center = get_turf(src)
	if(!center)
		return INITIALIZE_HINT_QDEL
	var/list/types = engine_types()
	var/columns = 5
	var/spacing = 5
	var/rows = CEILING(length(types) / columns, 1)
	var/margin = 3
	if(world.maxx < (columns - 1) * spacing + margin * 2 || world.maxy < (rows - 1) * spacing + margin * 2)
		to_chat(usr, span_warning("Для каталога двигателей нужна площадка 26×21 клетка."))
		return INITIALIZE_HINT_QDEL
	var/start_x = clamp(center.x - (columns - 1) * spacing / 2, margin, world.maxx - (columns - 1) * spacing - margin)
	var/start_y = clamp(center.y + (rows - 1) * spacing / 2, (rows - 1) * spacing + margin, world.maxy - margin)
	var/list/locations = list()
	for(var/index in 1 to length(types))
		var/obj/machinery/ship_engine/prototype = types[index]
		var/size = initial(prototype.engine_size)
		var/turf/spot = locate(round(start_x + ((index - 1) % columns) * spacing), round(start_y - FLOOR((index - 1) / columns, 1) * spacing), center.z)
		var/low = size == 3 ? -1 : 0
		var/high = size == 1 ? 0 : 1
		for(var/dx in low to high)
			for(var/dy in low to high)
				var/turf/tile = locate(spot.x + dx, spot.y + dy, spot.z)
				if(!tile || tile.is_blocked_turf(exclude_mobs = TRUE))
					visible_message(span_warning("Площадка каталога двигателей занята. Двигатели не созданы."))
					return INITIALIZE_HINT_QDEL
		locations += spot
	for(var/index in 1 to length(types))
		var/path = types[index]
		var/obj/machinery/ship_engine/engine = new path(locations[index])
		engine.setDir(dir)
	return INITIALIZE_HINT_QDEL
