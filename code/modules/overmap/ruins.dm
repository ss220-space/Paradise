/area/space/overmap_ruin
	name = "Ruin space"
	icon_state = "space"
	requires_power = FALSE
	always_unpowered = TRUE
	valid_territory = FALSE
	no_teleportlocs = TRUE
	var/datum/overmap_space_region/region

/turf/space/overmap_region
	var/datum/overmap_space_region/region

/turf/space/overmap_region/Entered(atom/movable/arrived, atom/old_loc, list/atom/old_locs)
	if(!region || !arrived || arrived.anchored)
		return ..()
	var/turf/dest = region.wrap_space_from(src)
	if(dest && dest != src)
		arrived.zMove(null, dest, ZMOVE_ALLOW_BUCKLED)
		return
	return ..()

/datum/overmap_feature
	var/id = "feature"
	var/name = "Аномалия"
	var/token_icon_state = "event"
	var/token_type = /obj/overmap/feature
	var/obj/overmap/token
	var/datum/overmap_sector/parent_sector

/datum/overmap_feature/Destroy()
	if(token && !QDELETED(token))
		qdel(token)
	token = null
	parent_sector = null
	SSovermap?.ruin_sites -= src
	return ..()

/datum/overmap_feature/proc/spawn_on(datum/overmap_sector/parent, coord_x, coord_y)
	if(!parent)
		return FALSE
	parent_sector = parent
	var/turf/spot = parent.get_turf_at(coord_x, coord_y)
	if(!spot)
		return FALSE
	overmap_clear_tile_for_feature(parent, spot)
	var/obj/overmap/placed = new token_type(spot)
	parent.add_object(placed, spot)
	token = placed
	return TRUE

/datum/overmap_feature/ruin
	id = "ruin"
	name = "Точка интереса"
	token_type = /obj/overmap/entity/feature/ruin
	var/quadrants = OVERMAP_RUIN_QUADRANTS

	var/list/enterable_quadrants = list(1)
	var/region_size = OVERMAP_RUIN_REGION_SIZE
	var/list/datum/overmap_space_region/cells
	var/list/obj/overmap/entity/feature/ruin/tokens
	var/datum/map_template/ruin/space/ruin_template

/datum/overmap_feature/ruin/New()
	cells = list()
	tokens = list()

/datum/overmap_feature/ruin/Destroy()
	for(var/obj/overmap/entity/feature/ruin/ruin_token as anything in tokens)
		if(!QDELETED(ruin_token))
			qdel(ruin_token)
	tokens = null
	for(var/datum/overmap_space_region/cell as anything in cells)
		if(!QDELETED(cell))
			qdel(cell)
	cells = null
	return ..()

/datum/overmap_feature/ruin/spawn_on(datum/overmap_sector/parent, coord_x, coord_y)
	if(!parent)
		return FALSE
	parent_sector = parent
	SSovermap?.ruin_sites |= src
	var/placed = 0
	for(var/quadrant in 1 to quadrants)
		if(!(quadrant in enterable_quadrants))
			continue
		var/datum/overmap_space_region/cell = SSovermap.claim_space_region(region_size, src, quadrant)
		if(!cell)
			continue
		cells += cell
		var/turf/spot
		if(!placed)
			spot = parent.get_nearest_open_turf(coord_x, coord_y)
			placed++
		else
			spot = parent.get_random_open_turf()
		if(!spot)
			continue
		overmap_clear_tile_for_feature(parent, spot)
		var/obj/overmap/entity/feature/ruin/ruin_token = new(spot)
		ruin_token.configure(src, cell)
		parent.add_object(ruin_token, spot)
		tokens += ruin_token
		token = ruin_token
	return length(tokens)

/datum/overmap_feature/ruin/empty_medium
	id = "empty_medium"
	name = "Пустой сектор"
	enterable_quadrants = list(1)

/datum/overmap_space_region
	var/datum/overmap_feature/ruin/site
	var/quadrant = 1
	var/size = OVERMAP_RUIN_REGION_SIZE
	var/pad = OVERMAP_RUIN_REGION_PAD
	var/datum/turf_reservation/space_reservation
	var/space_origin_x = 1
	var/space_origin_y = 1
	var/space_z = 0
	var/area/space/overmap_ruin/space_area
	var/obj/overmap/entity/feature/ruin/token

/datum/overmap_space_region/New(datum/overmap_feature/ruin/new_site, new_quadrant, new_size)
	site = new_site
	quadrant = new_quadrant || 1
	if(new_size)
		size = new_size
	build_space()

/datum/overmap_space_region/Destroy()
	token = null
	site = null
	space_area?.region = null
	space_area = null
	QDEL_NULL(space_reservation)
	return ..()

/datum/overmap_space_region/proc/build_space()
	var/span = size + pad * 2
	space_reservation = SSovermap.reserve_ruin_space(span, span)
	var/turf/bottom_left
	if(space_reservation && length(space_reservation.bottom_left_turfs))
		bottom_left = space_reservation.bottom_left_turfs[1]
	if(!bottom_left)
		CRASH("Overmap: failed to reserve landing space for ruin cell [site?.id || "ruin"] q[quadrant].")
	space_origin_x = bottom_left.x
	space_origin_y = bottom_left.y
	space_z = bottom_left.z
	space_area = new /area/space/overmap_ruin
	space_area.name = "Космос — [site?.name || "точка интереса"] ([quadrant]/[site?.quadrants || OVERMAP_RUIN_QUADRANTS])"
	space_area.region = src
	var/max_x = space_origin_x + span - 1
	var/max_y = space_origin_y + span - 1
	for(var/turf/old_turf as anything in block(locate(space_origin_x, space_origin_y, space_z), locate(max_x, max_y, space_z)))
		var/area/old_area = get_area(old_turf)
		var/local_x = old_turf.x - space_origin_x + 1
		var/local_y = old_turf.y - space_origin_y + 1
		var/in_play = local_x > pad && local_y > pad && local_x <= pad + size && local_y <= pad + size
		var/turf/new_turf
		if(in_play)
			new_turf = old_turf.ChangeTurf(/turf/space/overmap_region, FALSE, FALSE, CHANGETURF_IGNORE_AIR)
			var/turf/space/overmap_region/cell_turf = new_turf
			cell_turf.region = src
			cell_turf.remove_transitions()
		else
			new_turf = old_turf.ChangeTurf(/turf/simulated/floor/indestructible/hyperspace, FALSE, FALSE, CHANGETURF_IGNORE_AIR)
		new_turf.change_area(old_area, space_area)

/datum/overmap_space_region/proc/playable_min_x()
	return space_origin_x + pad

/datum/overmap_space_region/proc/playable_max_x()
	return space_origin_x + pad + size - 1

/datum/overmap_space_region/proc/playable_min_y()
	return space_origin_y + pad

/datum/overmap_space_region/proc/playable_max_y()
	return space_origin_y + pad + size - 1

/datum/overmap_space_region/proc/contains_space_turf(turf/spot)
	if(!spot || spot.z != space_z)
		return FALSE
	return spot.x >= playable_min_x() && spot.x <= playable_max_x() \
		&& spot.y >= playable_min_y() && spot.y <= playable_max_y()

/datum/overmap_space_region/proc/clamp_space_turf(turf/spot)
	if(!spot || spot.z != space_z)
		return locate(playable_min_x() + round(size / 2), playable_min_y() + round(size / 2), space_z)
	return locate(clamp(spot.x, playable_min_x(), playable_max_x()), clamp(spot.y, playable_min_y(), playable_max_y()), space_z)

/datum/overmap_space_region/proc/wrap_space_from(turf/spot)
	if(!contains_space_turf(spot))
		return null
	var/min_x = playable_min_x()
	var/max_x = playable_max_x()
	var/min_y = playable_min_y()
	var/max_y = playable_max_y()
	var/inset = min(OVERMAP_RUIN_WRAP_INSET, round(size / 4))
	var/new_x = spot.x
	var/new_y = spot.y
	if(spot.x <= min_x)
		new_x = max_x - inset
	else if(spot.x >= max_x)
		new_x = min_x + inset
	if(spot.y <= min_y)
		new_y = max_y - inset
	else if(spot.y >= max_y)
		new_y = min_y + inset
	if(new_x == spot.x && new_y == spot.y)
		return null
	return locate(new_x, new_y, space_z)

/datum/overmap_space_region/proc/near_playable_edge(turf/spot, range = OVERMAP_POD_WRAP_RANGE)
	if(!contains_space_turf(spot))
		return FALSE
	var/dx = min(spot.x - playable_min_x(), playable_max_x() - spot.x)
	var/dy = min(spot.y - playable_min_y(), playable_max_y() - spot.y)
	return min(dx, dy) <= range

/datum/overmap_space_region/proc/covers_reserved_turf(turf/spot)
	if(!spot || spot.z != space_z)
		return FALSE
	return spot.x >= space_origin_x && spot.x < space_origin_x + size + pad * 2 \
		&& spot.y >= space_origin_y && spot.y < space_origin_y + size + pad * 2

/datum/overmap_space_region/proc/center_turf()
	return locate(playable_min_x() + round(size / 2), playable_min_y() + round(size / 2), space_z)

/datum/overmap_space_region/proc/pick_edge_space_turf()
	var/min_x = playable_min_x() + OVERMAP_POD_WRAP_RANGE
	var/max_x = playable_max_x() - OVERMAP_POD_WRAP_RANGE
	var/min_y = playable_min_y() + OVERMAP_POD_WRAP_RANGE
	var/max_y = playable_max_y() - OVERMAP_POD_WRAP_RANGE
	if(min_x >= max_x || min_y >= max_y)
		return clamp_space_turf(center_turf())
	for(var/i in 1 to OVERMAP_POD_LANDING_TRIES)
		var/turf/spot
		switch(pick(NORTH, SOUTH, EAST, WEST))
			if(NORTH)
				spot = locate(rand(min_x, max_x), max_y, space_z)
			if(SOUTH)
				spot = locate(rand(min_x, max_x), min_y, space_z)
			if(EAST)
				spot = locate(max_x, rand(min_y, max_y), space_z)
			if(WEST)
				spot = locate(min_x, rand(min_y, max_y), space_z)
		if(overmap_pod_2x2_free(spot))
			return spot
	return center_turf()

/obj/overmap/entity/feature
	name = "аномалия"
	desc = "Неопознанный участок пространства."
	icon_state = "event"
	overmap_kind = OVERMAP_KIND_RUIN
	movable = FALSE
	visible_without_scanner = FALSE
	hidden_from_contacts = FALSE
	map_color = "#c9a227"
	overmap_icon_preset = "event"
	status = OVERMAP_STATUS_OVERMAP
	var/datum/overmap_feature/site
	var/datum/overmap_space_region/landing_region

/obj/overmap/entity/feature/get_ru_names()
	return alist(
		NOMINATIVE = "аномалия",
		GENITIVE = "аномалии",
		DATIVE = "аномалии",
		ACCUSATIVE = "аномалию",
		INSTRUMENTAL = "аномалией",
		PREPOSITIONAL = "аномалии",
	)

/obj/overmap/entity/feature/add_overmap_components()
	return

/obj/overmap/entity/feature/ruin
	name = "аномальная зона"
	deny_pod_edge_dock = FALSE

/obj/overmap/entity/feature/ruin/get_ru_names()
	return alist(
		NOMINATIVE = "аномальная зона",
		GENITIVE = "аномальной зоны",
		DATIVE = "аномальной зоне",
		ACCUSATIVE = "аномальная зона",
		INSTRUMENTAL = "аномальной зоной",
		PREPOSITIONAL = "аномальной зоне",
	)

/obj/overmap/entity/feature/ruin/add_overmap_components()
	AddComponent(/datum/component/overmap_sensors)
	AddComponent(/datum/component/overmap_dock_host, OVERMAP_DOCK_Z_RUIN)

/obj/overmap/entity/feature/ruin/proc/configure(datum/overmap_feature/ruin/new_site, datum/overmap_space_region/cell)
	site = new_site
	landing_region = cell
	if(cell)
		cell.token = src
	if(new_site)
		name = new_site.name
		icon_state = new_site.token_icon_state
		overmap_icon_preset = new_site.token_icon_state
		if(new_site.ruin_template)
			new_site.ruin_template.apply_overmap_identity(src)
		else
			apply_overmap_identity(new_site.name, map_color, new_site.token_icon_state || "event", FALSE, FALSE, null, FALSE)

/obj/overmap/entity/feature/update_icon_state()
	icon_state = overmap_icon_preset || "event"

/proc/overmap_clear_tile_for_feature(datum/overmap_sector/sector, turf/spot)
	if(!spot)
		return
	for(var/obj/overmap/feature/hazard/hazard in spot)
		qdel(hazard)

/datum/controller/subsystem/overmap/proc/large_region_size()
	return max(OVERMAP_RUIN_REGION_SIZE, world.maxx - 16)

/datum/controller/subsystem/overmap/proc/seed_reserved_space()
	pooled_medium_cells = list()
	pooled_large_cells = list()
	transit_space_zs = list()
	for(var/i in 1 to OVERMAP_RESERVED_MEDIUM_Z)
		ruin_space_zs += SSmapping.add_ruin_space_zlevel()
	for(var/i in 1 to OVERMAP_RESERVED_MEDIUM_Z * OVERMAP_RESERVED_MEDIUM_CELLS_PER_Z)
		pooled_medium_cells += new /datum/overmap_space_region(null, 1, OVERMAP_RUIN_REGION_SIZE)
	for(var/i in 1 to OVERMAP_RESERVED_LARGE_Z)
		ruin_space_zs += SSmapping.add_ruin_space_zlevel()
		pooled_large_cells += new /datum/overmap_space_region(null, 1, large_region_size())
	for(var/i in 1 to OVERMAP_RESERVED_TRANSIT_Z)
		var/transit_z = SSmapping.add_reservation_zlevel()
		SSmapping.initialize_reserved_level(transit_z)
		transit_space_zs += transit_z
	log_world("Overmap: reserved space pool medium=[length(pooled_medium_cells)] large=[length(pooled_large_cells)] transit_z=[length(transit_space_zs)].")

/datum/controller/subsystem/overmap/proc/claim_space_region(size, datum/overmap_feature/ruin/site, quadrant)
	var/datum/overmap_space_region/cell
	if(size > OVERMAP_RUIN_REGION_SIZE && length(pooled_large_cells))
		cell = pooled_large_cells[1]
		pooled_large_cells.Cut(1, 2)
	else if(size <= OVERMAP_RUIN_REGION_SIZE && length(pooled_medium_cells))
		cell = pooled_medium_cells[1]
		pooled_medium_cells.Cut(1, 2)
	if(!cell)
		cell = new /datum/overmap_space_region(site, quadrant, size)
		return cell
	cell.site = site
	cell.quadrant = quadrant || 1
	if(cell.space_area)
		cell.space_area.name = "Космос — [site?.name || "точка интереса"] ([cell.quadrant]/[site?.quadrants || OVERMAP_RUIN_QUADRANTS])"
		cell.space_area.region = cell
	return cell

/datum/controller/subsystem/overmap/proc/spawn_roundstart_ruin_sites()
	return

/datum/controller/subsystem/overmap/proc/overmap_ruin_pool_for_sector(datum/overmap_sector/sector)
	if(sector?.sector_kind == OVERMAP_SECTOR_KIND_WILDERNESS)
		return OVERMAP_RUIN_POOL_WILD
	return OVERMAP_RUIN_POOL_STATION

/datum/controller/subsystem/overmap/proc/pick_overmap_ruin_templates(size_key, pool, allow_dupes = FALSE)
	. = list()
	for(var/name in GLOB.space_ruins_templates)
		var/datum/map_template/ruin/space/ruin = GLOB.space_ruins_templates[name]
		if(!istype(ruin) || ruin.unpickable)
			continue
		if(ruin.overmap_size != size_key)
			continue
		if(!(pool in ruin.overmap_pools))
			continue
		if(!allow_dupes && ruin.loaded)
			continue
		. += ruin

/datum/controller/subsystem/overmap/proc/take_overmap_ruin(list/datum/map_template/ruin/space/pool)
	if(!length(pool))
		return null
	var/list/weighted = list()
	for(var/datum/map_template/ruin/space/ruin as anything in pool)
		weighted[ruin] = max(ruin.placement_weight, 1)
	var/datum/map_template/ruin/space/chosen = pickweight(weighted)
	pool -= chosen
	return chosen

/datum/controller/subsystem/overmap/proc/spawn_overmap_ruins(datum/overmap_sector/sector)
	if(!sector || sector.ruin_spawn_weight <= 0)
		return
	var/pool = overmap_ruin_pool_for_sector(sector)
	var/medium_count = round(sector.size * sector.ruin_spawn_weight / 10)
	var/large_count = round(sector.size * sector.ruin_spawn_weight / 20)
	var/list/mediums = pick_overmap_ruin_templates(OVERMAP_RUIN_SIZE_MEDIUM, pool)
	var/list/larges = pick_overmap_ruin_templates(OVERMAP_RUIN_SIZE_LARGE, pool)
	for(var/i in 1 to large_count)
		var/datum/map_template/ruin/space/ruin = take_overmap_ruin(larges)
		if(!ruin)
			break
		place_overmap_ruin_site(sector, ruin, TRUE)
	for(var/i in 1 to medium_count)
		var/datum/map_template/ruin/space/ruin = take_overmap_ruin(mediums)
		if(!ruin)
			break
		place_overmap_ruin_site(sector, ruin, FALSE)

/datum/controller/subsystem/overmap/proc/place_overmap_ruin_site(datum/overmap_sector/sector, datum/map_template/ruin/space/ruin, large)
	var/turf/spot = sector.get_random_open_turf()
	if(!spot)
		return FALSE
	var/datum/overmap_feature/ruin/site = new
	site.name = ruin.identity_name || ruin.name
	site.ruin_template = ruin
	site.enterable_quadrants = list(1)
	site.region_size = large ? large_region_size() : OVERMAP_RUIN_REGION_SIZE
	if(!site.spawn_on(sector, sector.coord_x(spot), sector.coord_y(spot)))
		qdel(site)
		return FALSE
	var/datum/overmap_space_region/cell = site.cells[1]
	if(ruin.width <= cell.size && ruin.height <= cell.size)
		var/turf/load_at = cell.center_turf()
		if(ruin.fits_in_map_bounds(load_at, centered = TRUE) && cell.contains_space_turf(load_at))
			ruin.load(load_at, centered = TRUE)
			ruin.loaded++
			for(var/turf/marked as anything in ruin.get_affected_turfs(load_at, TRUE))
				marked.turf_flags |= NO_RUINS
			new /obj/effect/landmark/ruin(load_at, ruin)
	scatter_small_overmap_ruins(cell, overmap_ruin_pool_for_sector(sector), large)
	log_world("Overmap: placed [large ? "large" : "medium"] ruin [ruin.id] in sector [sector.id].")
	return TRUE

/datum/controller/subsystem/overmap/proc/scatter_small_overmap_ruins(datum/overmap_space_region/cell, pool, large)
	if(!cell)
		return
	var/count = large ? 3 + round(cell.size / 80) : 1 + round(cell.size / 96)
	var/list/smalls = pick_overmap_ruin_templates(OVERMAP_RUIN_SIZE_SMALL, pool, TRUE)
	for(var/i in 1 to count)
		var/datum/map_template/ruin/space/ruin = take_overmap_ruin(smalls)
		if(!ruin)
			break
		if(ruin.allow_duplicates)
			smalls += ruin
		ruin.try_to_place_in_region(cell)

/datum/controller/subsystem/overmap/proc/reserve_ruin_space(width, height)
	if(!length(ruin_space_zs))
		ruin_space_zs += SSmapping.add_ruin_space_zlevel()
	for(var/z_level in ruin_space_zs)
		var/datum/turf_reservation/block = SSmapping.request_turf_block_reservation(width, height, 1, z_reservation = z_level, turf_type_override = /turf/space, noisy = FALSE)
		if(block)
			return block
	var/new_z = SSmapping.add_ruin_space_zlevel()
	ruin_space_zs += new_z
	return SSmapping.request_turf_block_reservation(width, height, 1, z_reservation = new_z, turf_type_override = /turf/space, noisy = FALSE)

/datum/controller/subsystem/overmap/proc/get_space_region(atom/thing)
	var/turf/spot = get_turf(thing)
	if(!spot)
		return null
	if(istype(spot, /turf/space/overmap_region))
		var/turf/space/overmap_region/cell_turf = spot
		if(cell_turf.region)
			return cell_turf.region
	for(var/datum/overmap_feature/ruin/site as anything in ruin_sites)
		if(QDELETED(site))
			continue
		for(var/obj/overmap/entity/feature/ruin/ruin_token as anything in site.tokens)
			if(QDELETED(ruin_token) || !ruin_token.landing_region)
				continue
			if(ruin_token.landing_region.covers_reserved_turf(spot))
				return ruin_token.landing_region
	return null

/datum/controller/subsystem/overmap/proc/get_ruin_host(atom/thing)
	var/turf/spot = get_turf(thing)
	if(!spot)
		return null
	for(var/datum/overmap_feature/ruin/site as anything in ruin_sites)
		if(QDELETED(site))
			continue
		for(var/obj/overmap/entity/feature/ruin/ruin_token as anything in site.tokens)
			if(QDELETED(ruin_token) || !ruin_token.landing_region)
				continue
			if(ruin_token.landing_region.covers_reserved_turf(spot))
				return ruin_token
	return null
