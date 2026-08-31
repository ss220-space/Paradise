/obj/overmap/planet
	name = "planet"
	desc = "Крупное тело на карте системы. Занимает несколько клеток."
	icon = OVERMAP_PLANET_ICON_FILE
	icon_state = "lavaland"
	color = null
	plane = FLOOR_PLANE
	layer = ABOVE_OPEN_TURF_LAYER
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	overmap_kind = OVERMAP_KIND_PLANET
	hidden_from_contacts = TRUE
	scannable = FALSE
	deny_pod_edge_dock = TRUE
	appearance_flags = RESET_COLOR | RESET_TRANSFORM | KEEP_APART
	var/footprint = OVERMAP_LAVALAND_FOOTPRINT
	var/obj/overmap/entity/planet_station/outpost
	var/list/obj/effect/overmap_planet_cell/cells

/obj/overmap/planet/Initialize(mapload)
	. = ..()
	spawn_footprint_cells()

	icon = null

/obj/overmap/planet/update_overmap_pixel()
	pixel_x = 0
	pixel_y = 0

/obj/overmap/planet/update_overlays()
	return list()

/obj/overmap/planet/proc/spawn_footprint_cells()
	var/turf/origin = loc
	if(!isturf(origin) || footprint <= 0)
		return
	var/icon/full = icon(OVERMAP_PLANET_ICON_FILE, icon_state)
	cells = list()
	for(var/tile_x in 0 to footprint - 1)
		for(var/tile_y in 0 to footprint - 1)
			var/turf/spot = locate(origin.x + tile_x, origin.y + tile_y, origin.z)
			if(!spot)
				continue
			var/icon/piece = icon(full)
			piece.Crop(tile_x * 32 + 1, tile_y * 32 + 1, (tile_x + 1) * 32, (tile_y + 1) * 32)
			var/obj/effect/overmap_planet_cell/cell = new(spot)
			cell.icon = piece
			cell.parent_planet = src
			cells += cell

/obj/overmap/planet/Destroy()
	QDEL_LIST(cells)
	if(outpost?.planet == src)
		outpost.planet = null
	outpost = null
	return ..()

/obj/effect/overmap_planet_cell
	name = ""
	desc = null
	anchored = TRUE
	density = FALSE
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	plane = FLOOR_PLANE
	layer = ABOVE_OPEN_TURF_LAYER
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF
	appearance_flags = RESET_COLOR | RESET_TRANSFORM | KEEP_APART
	var/obj/overmap/planet/parent_planet

/obj/effect/overmap_planet_cell/Initialize(mapload)
	. = ..()
	SET_PLANE_IMPLICIT(src, FLOOR_PLANE)

/obj/effect/overmap_planet_cell/Destroy()
	if(parent_planet)
		parent_planet.cells -= src
		parent_planet = null
	return ..()

/obj/overmap/planet/proc/covers_turf(turf/spot)
	var/turf/origin = loc
	if(!isturf(origin) || !spot || spot.z != origin.z)
		return FALSE
	return spot.x >= origin.x && spot.x < origin.x + footprint && spot.y >= origin.y && spot.y < origin.y + footprint

/obj/overmap/planet/proc/footprint_turfs()
	. = list()
	var/turf/origin = loc
	if(!isturf(origin))
		return
	var/max_x = origin.x + footprint - 1
	var/max_y = origin.y + footprint - 1
	for(var/turf/spot as anything in block(origin, locate(max_x, max_y, origin.z)))
		. += spot

/obj/overmap/planet/lavaland
	name = "Лаваленд"
	desc = "Лаваленд. Планета занимает 4×4 клетки карты системы."
	icon_state = "lavaland"
	map_color = "#c45c2a"
	visible_without_scanner = TRUE

/obj/overmap/planet/lavaland/get_ru_names()
	return alist(
		NOMINATIVE = "Лаваленд",
		GENITIVE = "Лаваленда",
		DATIVE = "Лаваленду",
		ACCUSATIVE = "Лаваленд",
		INSTRUMENTAL = "Лавалендом",
		PREPOSITIONAL = "Лаваленде",
	)

/obj/overmap/entity/planet_station
	name = "planetary outpost"
	icon_state = "ship"
	movable = FALSE
	halted = TRUE
	overmap_kind = OVERMAP_KIND_STATION
	vessel_flags = OVERMAP_VESSEL_STATION
	vessel_mass = OVERMAP_MASS_STATION
	overmap_icon_preset = "station"
	map_color = "#c45c2a"
	overmap_hazard_immune = TRUE
	deny_pod_edge_dock = TRUE
	var/obj/overmap/planet/planet

/obj/overmap/entity/planet_station/add_overmap_components()
	AddComponent(/datum/component/overmap_sensors)
	AddComponent(/datum/component/overmap_dock_host, OVERMAP_DOCK_Z_MINING, null, FALSE, TRUE)

/obj/overmap/entity/planet_station/Destroy()
	if(planet?.outpost == src)
		planet.outpost = null
	planet = null
	if(SSovermap?.lavaland_entity == src)
		SSovermap.lavaland_entity = null
	return ..()

/obj/overmap/entity/planet_station/lavaland
	name = "Lavaland mining station"
	desc = "Шахтёрская станция на Лаваленде. Двигателями не переносится."

/obj/overmap/entity/planet_station/lavaland/get_ru_names()
	return alist(
		NOMINATIVE = "шахтёрская станция Лаваленда",
		GENITIVE = "шахтёрской станции Лаваленда",
		DATIVE = "шахтёрской станции Лаваленда",
		ACCUSATIVE = "шахтёрскую станцию Лаваленда",
		INSTRUMENTAL = "шахтёрской станцией Лаваленда",
		PREPOSITIONAL = "шахтёрской станции Лаваленда",
	)

/proc/overmap_lavaland_landing_blocked(turf/spot)
	if(!spot)
		return TRUE
	if(spot.density)
		return TRUE
	if(islava(spot) || ischasm(spot) || istype(spot, /turf/simulated/openspace))
		return TRUE
	if(istype(spot, /turf/simulated/mineral))
		return TRUE
	if(locate(/obj/structure/spawner/lavaland) in spot)
		return TRUE
	for(var/mob/living/simple_animal/hostile/megafauna/fauna in spot)
		if(!QDELETED(fauna) && fauna.stat != DEAD)
			return TRUE
	return FALSE
