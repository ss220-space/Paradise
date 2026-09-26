/datum/map_template/ruin
	name = null
	/// For blacklisting purposes, all ruins need an id
	var/id = null
	var/description = "In the middle of a clearing in the rockface, there's a \
		chest filled with gold coins with Spanish engravings. How is there a \
		wooden container filled with 18th century coinage in the middle of a \
		lavawracked hellscape? It is clearly a mystery."

	/// If TRUE these won't be placed automatically (can still be forced or loaded with another ruin)
	var/unpickable = FALSE
	/// Will skip the whole weighting process and just plop this down, ideally you want the ruins of this kind to have no cost.
	var/always_place = FALSE
	/// How often should this ruin appear
	var/placement_weight = 1
	/// Cost in ruin budget placement system
	var/cost = 0
	/// If TRUE, this ruin can be placed multiple times in the same map
	var/allow_duplicates = TRUE
	/// If this ruin is spawned these will not eg list(/datum/map_template/ruin/base_alternate)
	var/list/never_spawn_with = null
	/// Static part of the ruin path eg "_maps\RandomRuins\LavaRuins\"
	var/prefix = null
	/// The dynamic part of the ruin path eg "lavaland_surface_ruinfile.dmm"
	var/suffix = null
	/// Can the ruin be found by the locator
	var/can_found = FALSE
	/// Overmap footprint: OVERMAP_RUIN_SIZE_SMALL/MEDIUM/LARGE.
	var/overmap_size
	/// Overmap spawn pools
	var/list/overmap_pools
	/// Overmap beacon name. Defaults to ruin name if unset.
	var/identity_name
	var/identity_color = COLOR_WHITE
	var/identity_icon = "event"
	var/identity_distress = FALSE
	var/identity_broadcasting = FALSE
	var/identity_locked = FALSE
	/// Same as shuttle profiles, id or id = FALSE for TX off.
	var/list/identity_iff_ids

/datum/map_template/ruin/New()
	if(!name && id)
		name = id
	check_specials()
	mappath = prefix + suffix
	..(path = mappath)

/datum/map_template/ruin/proc/check_specials()
	return

/datum/map_template/ruin/proc/apply_overmap_identity(obj/overmap/entity/vessel)
	vessel?.apply_overmap_identity(identity_name || name, identity_color, identity_icon, identity_distress, identity_broadcasting, identity_iff_ids, identity_locked)

/datum/map_template/ruin/proc/try_to_place(z, allowed_areas)
	var/sanity = PLACEMENT_TRIES
	while(sanity > 0)
		sanity--
		var/width_border = TRANSITIONEDGE + SPACERUIN_MAP_EDGE_PAD + round(width / 2)
		var/height_border = TRANSITIONEDGE + SPACERUIN_MAP_EDGE_PAD + round(height / 2)
		var/turf/central_turf = locate(rand(width_border, world.maxx - width_border), rand(height_border, world.maxy - height_border), z)
		var/valid = TRUE

		for(var/turf/check in get_affected_turfs(central_turf,1))
			var/area/new_area = get_area(check)
			if(!(istype(new_area, allowed_areas)) || check.turf_flags & NO_RUINS)
				valid = FALSE
				break

		if(!valid)
			continue

		log_world("Ruin \"[name]\" placed at ([COORD(central_turf)])")

		for(var/i in get_affected_turfs(central_turf, 1))
			var/turf/T = i
			for(var/obj/structure/spawner/nest in T)
				qdel(nest)
			for(var/mob/living/simple_animal/monster in T)
				qdel(monster)
			for(var/obj/structure/flora/ash/plant in T)
				qdel(plant)

		load(central_turf,centered = TRUE)
		loaded++

		for(var/turf/T in get_affected_turfs(central_turf, 1))
			T.turf_flags |= NO_RUINS

		new /obj/effect/landmark/ruin(central_turf, src)
		return TRUE
	return FALSE

/datum/map_template/ruin/proc/try_to_place_in_region(datum/overmap_space_region/cell, margin = 0)
	if(!cell)
		return FALSE
	if(width > cell.size || height > cell.size)
		return FALSE
	var/min_x = cell.playable_min_x() + round(width / 2) + margin
	var/max_x = cell.playable_max_x() - round(width / 2) - margin
	var/min_y = cell.playable_min_y() + round(height / 2) + margin
	var/max_y = cell.playable_max_y() - round(height / 2) - margin
	if(min_x > max_x || min_y > max_y)
		return FALSE
	var/tries = PLACEMENT_TRIES
	while(tries > 0)
		tries--
		var/turf/central_turf = locate(rand(min_x, max_x), rand(min_y, max_y), cell.space_z)
		if(!cell.contains_space_turf(central_turf))
			continue
		if(cell.footprint_taken(central_turf, width, height, margin))
			continue
		var/footprint_min_x = central_turf.x - round(width / 2)
		var/footprint_min_y = central_turf.y - round(height / 2)
		var/footprint_max_x = footprint_min_x + width - 1
		var/footprint_max_y = footprint_min_y + height - 1
		var/scan_min_x = max(footprint_min_x - margin, cell.playable_min_x())
		var/scan_min_y = max(footprint_min_y - margin, cell.playable_min_y())
		var/scan_max_x = min(footprint_max_x + margin, cell.playable_max_x())
		var/scan_max_y = min(footprint_max_y + margin, cell.playable_max_y())
		var/valid = TRUE
		for(var/turf/check as anything in block(locate(scan_min_x, scan_min_y, cell.space_z), locate(scan_max_x, scan_max_y, cell.space_z)))
			if(check.turf_flags & NO_RUINS)
				valid = FALSE
				break
			if(check.x < footprint_min_x || check.x > footprint_max_x || check.y < footprint_min_y || check.y > footprint_max_y)
				continue
			if(!istype(check, /turf/space/overmap_region))
				valid = FALSE
				break
			var/turf/space/overmap_region/region_turf = check
			if(region_turf.region != cell)
				valid = FALSE
				break
		if(!valid)
			continue
		load(central_turf, centered = TRUE)
		loaded++
		for(var/turf/marked as anything in get_affected_turfs(central_turf, TRUE))
			marked.turf_flags |= NO_RUINS
		cell.register_ruin_footprint(central_turf, width, height)
		new /obj/effect/landmark/ruin(central_turf, src)
		return TRUE
	return FALSE
