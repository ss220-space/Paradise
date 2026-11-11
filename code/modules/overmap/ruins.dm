/area/space/overmap_ruin
	name = "Ruin space"
	requires_power = FALSE
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

/datum/controller/subsystem/overmap/proc/claim_space_region(size, datum/overmap_feature/ruin/site, quadrant)
	var/datum/overmap_space_region/cell
	if(size > OVERMAP_RUIN_REGION_SIZE)
		if(length(pooled_large_cells))
			cell = pooled_large_cells[1]
			pooled_large_cells.Cut(1, 2)
		else if(world.maxz < OVERMAP_RUIN_MAX_Z_LEVEL)
			cell = new /datum/overmap_space_region(site, quadrant, size)
	else if(length(pooled_medium_cells))
		cell = pooled_medium_cells[1]
		pooled_medium_cells.Cut(1, 2)
	else if(world.maxz < OVERMAP_RUIN_MAX_Z_LEVEL)
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

/datum/controller/subsystem/overmap/proc/spawn_overmap_ruins(datum/overmap_sector/sector)
	if(!sector || sector.ruin_spawn_weight <= 0)
		return
	#ifdef SKIP_SPACE_LEVELS
	return
	#endif
	if(CONFIG_GET(flag/disable_space_ruins) || (SSmapping.map_datum.disables & DISABLE_SPACE_RUINS))
		return
	var/pool = overmap_ruin_pool_for_sector(sector)
	var/medium_count = clamp(round(sector.size * sector.ruin_spawn_weight / 7), 1, 12)
	var/large_count = clamp(round(medium_count / 4), 0, 2)
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
		if(ruin.fits_in_map_bounds(load_at, centered = TRUE) && cell.contains_space_turf(load_at) && cell_footprint_free(cell, ruin, load_at))
			ruin.load(load_at, centered = TRUE)
			ruin.loaded++
			for(var/turf/marked as anything in ruin.get_affected_turfs(load_at, TRUE))
				marked.turf_flags |= NO_RUINS
				ruin_lighting_turfs += marked
			cell.register_ruin_footprint(load_at, ruin.width, ruin.height)
			new /obj/effect/landmark/ruin(load_at, ruin)
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
		var/datum/turf_reservation/block = SSmapping.request_turf_block_reservation(width, height, 1, z_reservation = z_level, turf_type_override = /turf/space/overmap_region, noisy = FALSE)
		if(block)
			return block
	if(world.maxz >= OVERMAP_SPAWN_MAX_Z_LEVEL)
		return null
	var/new_z = SSmapping.add_ruin_space_zlevel()
	ruin_space_zs += new_z
	return SSmapping.request_turf_block_reservation(width, height, 1, z_reservation = new_z, turf_type_override = /turf/space/overmap_region, noisy = FALSE)

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
