/obj/effect/spawner/monofrontier_ship_weapons
	desc = "TEMP123TEMP"
	name = "all MonoFrontier ship weapons spawner (25 guns)"
	icon = 'icons/obj/engines_and_power/particle_accelerator3.dmi'
	icon_state = "emitter_center"

/obj/effect/spawner/monofrontier_ship_weapons/Initialize(mapload)
	. = ..()
	var/turf/center = get_turf(src)
	if(!center)
		return INITIALIZE_HINT_QDEL
	var/columns = 8
	var/spacing = 6
	var/rows = CEILING(length(GLOB.monofrontier_ship_weapons) / columns, 1)
	var/margin = 3
	if(world.maxx < (columns - 1) * spacing + margin * 2 || world.maxy < (rows - 1) * spacing + margin * 2)
		log_world("MonoFrontier weapon catalog needs a map at least 48 by 24 tiles.")
		return INITIALIZE_HINT_QDEL
	var/start_x = clamp(center.x - (columns - 1) * spacing / 2, margin, world.maxx - (columns - 1) * spacing - margin)
	var/start_y = clamp(center.y + (rows - 1) * spacing / 2, (rows - 1) * spacing + margin, world.maxy - margin)
	var/list/locations = list()
	for(var/i in 1 to length(GLOB.monofrontier_ship_weapons))
		var/turf/spot = locate(round(start_x + ((i - 1) % columns) * spacing), round(start_y - FLOOR((i - 1) / columns, 1) * spacing), center.z)
		if(!spot || spot.is_blocked_turf(exclude_mobs = TRUE))
			visible_message(span_warning("Для каталога MonoFrontier нужна свободная площадка 48 × 24 клетки. Орудия не созданы."))
			log_world("MonoFrontier catalog placement blocked at slot [i]; no guns spawned.")
			return INITIALIZE_HINT_QDEL
		locations += spot
	for(var/i in 1 to length(GLOB.monofrontier_ship_weapons))
		var/gun_type = GLOB.monofrontier_ship_weapons[i]
		var/obj/machinery/gun = new gun_type(locations[i])
		gun.setDir(dir)
	return INITIALIZE_HINT_QDEL
