/area/space/overmap_ruin
	name = "Ruin space"
	requires_power = FALSE
	no_teleportlocs = TRUE
	var/datum/overmap_space_region/region

/datum/turf_reservation/overmap_ruin
	turf_type = /turf/space/overmap_region
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

/obj/overmap/entity/feature
	name = "аномалия"
	desc = "Неопознанный участок пространства."
	icon_state = "event"
	overmap_kind = OVERMAP_KIND_RUIN
	movable = FALSE
	map_color = "#c9a227"
	overmap_icon_preset = "event"
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
	structure_faction = "neutral"
	name = "аномальная зона"

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

/datum/controller/subsystem/overmap/proc/large_region_size()
	return max(OVERMAP_RUIN_REGION_SIZE, world.maxx - 16)

/datum/controller/subsystem/overmap/proc/seed_reserved_space()
	if(world.maxz < OVERMAP_SPAWN_MAX_Z_LEVEL)
		var/transit_z = SSmapping.add_reservation_zlevel()
		SSmapping.initialize_reserved_level(transit_z)
	#ifdef SKIP_SPACE_LEVELS
	return
	#endif
	if(CONFIG_GET(flag/disable_space_ruins) || (SSmapping.map_datum.disables & DISABLE_SPACE_RUINS))
		return
	var/level_count = SSmapping.map_datum.space_ruins_levels
	if(isnull(level_count))
		level_count = SPACE_RUINS_NUMBER
	for(var/i in 1 to level_count)
		if(world.maxz >= OVERMAP_SPAWN_MAX_Z_LEVEL)
			break
		ruin_space_zs += SSmapping.add_ruin_space_zlevel()
	var/medium_levels = length(ruin_space_zs)
	if(medium_levels > 1)
		var/datum/overmap_space_region/large = new(null, 1, large_region_size())
		if(!QDELETED(large))
			pooled_large_cells += large
			medium_levels--
	for(var/i in 1 to medium_levels * OVERMAP_RESERVED_MEDIUM_CELLS_PER_Z)
		var/datum/overmap_space_region/medium = new(null, 1, OVERMAP_RUIN_REGION_SIZE)
		if(QDELETED(medium))
			break
		pooled_medium_cells += medium

/datum/controller/subsystem/overmap/proc/claim_space_region(size, datum/overmap_feature/ruin/site, quadrant)
	var/datum/overmap_space_region/cell
	if(size > OVERMAP_RUIN_REGION_SIZE)
		if(length(pooled_large_cells))
			cell = pooled_large_cells[1]
			pooled_large_cells.Cut(1, 2)
		else if(length(ruin_space_zs))
			cell = new /datum/overmap_space_region(site, quadrant, size)
	else if(length(pooled_medium_cells))
		cell = pooled_medium_cells[1]
		pooled_medium_cells.Cut(1, 2)
	else if(length(ruin_space_zs))
		cell = new /datum/overmap_space_region(site, quadrant, size)
	if(QDELETED(cell))
		return null
	cell.site = site
	cell.quadrant = quadrant || 1
	if(cell.space_area)
		cell.space_area.name = "Космос — [site?.name || "точка интереса"] ([cell.quadrant]/[site?.quadrants || OVERMAP_RUIN_QUADRANTS])"
		cell.space_area.region = cell
	return cell

/datum/controller/subsystem/overmap/proc/overmap_ruin_pool_for_sector(datum/overmap_sector/sector)
	if(sector?.sector_kind == OVERMAP_SECTOR_KIND_WILDERNESS)
		return OVERMAP_RUIN_POOL_WILD
	return OVERMAP_RUIN_POOL_STATION

/datum/controller/subsystem/overmap/proc/pick_overmap_ruin_templates(size_key, pool, allow_dupes = FALSE)
	. = list()
	for(var/name, ruin_entry in GLOB.space_ruins_templates)
		var/datum/map_template/ruin/space/ruin = ruin_entry
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

/datum/controller/subsystem/overmap/proc/spawn_overmap_ruins(list/candidates)
	#ifdef SKIP_SPACE_LEVELS
	return
	#endif
	if(CONFIG_GET(flag/disable_space_ruins) || (SSmapping.map_datum.disables & DISABLE_SPACE_RUINS))
		return
	if(!length(pooled_medium_cells) && !length(pooled_large_cells))
		return
	var/list/weights = list()
	var/total_weight = 0
	var/medium_count = 0
	var/large_count = 0
	for(var/datum/overmap_sector/sector as anything in shuffle(candidates))
		var/weight = galaxy_systems[sector.id]?["generation"]?["ruins"]
		if(!isnum(weight))
			weight = sector.ruin_spawn_weight
		if(weight <= 0)
			continue
		weights[sector] = weight
		total_weight += weight
		var/medium_limit = clamp(round(sector.size * weight / 7), 1, 12)
		medium_count += medium_limit
		large_count += clamp(round(medium_limit / 4), 0, 2)
	large_count = min(large_count, length(pooled_large_cells))
	var/count = large_count + min(medium_count, length(pooled_medium_cells))
	if(!count)
		return
	var/stride = total_weight / count
	var/offset = rand(0, 65535) / 65536 * stride
	var/list/locations = list()
	for(var/datum/overmap_sector/sector as anything in weights)
		while(offset < weights[sector] && length(locations) < count)
			locations += sector
			offset += stride
		offset -= weights[sector]
	locations = shuffle(locations)
	for(var/i in 1 to length(locations))
		var/datum/overmap_sector/sector = locations[i]
		var/large = i <= large_count
		var/list/cells = large ? pooled_large_cells : pooled_medium_cells
		var/list/templates = pick_overmap_ruin_templates(large ? OVERMAP_RUIN_SIZE_LARGE : OVERMAP_RUIN_SIZE_MEDIUM, overmap_ruin_pool_for_sector(sector))
		while(length(cells) && length(templates))
			if(place_overmap_ruin_site(sector, take_overmap_ruin(templates), large))
				break
		CHECK_TICK

/datum/controller/subsystem/overmap/proc/place_overmap_ruin_site(datum/overmap_sector/sector, datum/map_template/ruin/space/ruin, large)
	var/region_size = large ? large_region_size() : OVERMAP_RUIN_REGION_SIZE
	if(ruin.width <= 0 || ruin.height <= 0 || max(ruin.width, ruin.height) > region_size)
		return FALSE
	var/turf/spot = sector.get_random_open_turf()
	if(sector.turf_occupied(spot))
		return FALSE
	var/datum/overmap_feature/ruin/site = new
	site.name = ruin.identity_name || ruin.name
	site.ruin_template = ruin
	site.enterable_quadrants = list(1)
	site.region_size = region_size
	if(!site.spawn_on(sector, sector.coord_x(spot), sector.coord_y(spot)))
		qdel(site)
		return FALSE
	var/datum/overmap_space_region/cell = site.cells[1]
	var/turf/load_at = cell.center_turf()
	try
		if(!ruin.fits_in_map_bounds(load_at, centered = TRUE) || !cell_footprint_free(cell, ruin, load_at) || !ruin.load_in_region(cell, load_at))
			qdel(site)
			return FALSE
	catch(var/exception/error)
		qdel(site)
		throw error
	scatter_small_overmap_ruins(cell, overmap_ruin_pool_for_sector(sector), large)
	if(initialized)
		refresh_ruin_space_lighting()
	return TRUE

/datum/controller/subsystem/overmap/proc/cell_footprint_free(datum/overmap_space_region/cell, datum/map_template/ruin/ruin, turf/load_at)
	for(var/turf/spot as anything in ruin.get_affected_turfs(load_at, TRUE))
		if(spot.turf_flags & NO_RUINS)
			return FALSE
		if(!istype(spot, /turf/space/overmap_region))
			return FALSE
		var/turf/space/overmap_region/region_turf = spot
		if(region_turf.region != cell)
			return FALSE
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
		ruin.try_to_place_in_region(cell, OVERMAP_RUIN_SCATTER_MARGIN)

/datum/controller/subsystem/overmap/proc/reserve_ruin_space(width, height)
	for(var/z_level in ruin_space_zs)
		var/datum/turf_reservation/block = SSmapping.request_turf_block_reservation(width, height, 1, z_reservation = z_level, reservation_type = /datum/turf_reservation/overmap_ruin, noisy = FALSE)
		if(block)
			return block
	return null

/datum/controller/subsystem/overmap/proc/get_space_region(atom/thing)
	RETURN_TYPE(/datum/overmap_space_region)
	var/turf/spot = get_turf(thing)
	if(!spot)
		return null
	if(istype(spot, /turf/space/overmap_region))
		var/turf/space/overmap_region/cell_turf = spot
		if(cell_turf.region)
			return cell_turf.region
	var/datum/turf_reservation/overmap_ruin/reservation = SSmapping.used_turfs[spot]
	if(istype(reservation) && reservation.region?.covers_reserved_turf(spot))
		return reservation.region

/datum/controller/subsystem/overmap/proc/get_ruin_host(atom/thing)
	var/obj/overmap/entity/host = get_space_region(thing)?.token
	return QDELETED(host) ? null : host
