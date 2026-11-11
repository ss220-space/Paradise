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
	overmap_clear_tile_for_feature(spot)
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
		overmap_clear_tile_for_feature(spot)
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
	var/list/placed_ruins = list()

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
	placed_ruins = null
	QDEL_NULL(space_reservation)
	return ..()

/datum/overmap_space_region/proc/build_space()
	var/span = size + pad * 2
	space_reservation = SSovermap.reserve_ruin_space(span, span)
	var/turf/bottom_left
	if(space_reservation && length(space_reservation.bottom_left_turfs))
		bottom_left = space_reservation.bottom_left_turfs[1]
	if(!bottom_left)
		qdel(src)
		return FALSE
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
		CHECK_TICK

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

/datum/overmap_space_region/proc/footprint_taken(turf/load_at, width, height, margin = 0)
	if(!load_at)
		return TRUE
	var/taken_min_x = load_at.x - round(width / 2) - margin
	var/taken_min_y = load_at.y - round(height / 2) - margin
	var/taken_max_x = taken_min_x + width + margin * 2 - 1
	var/taken_max_y = taken_min_y + height + margin * 2 - 1
	for(var/list/placed as anything in placed_ruins)
		if(placed[1] <= taken_max_x && placed[2] <= taken_max_y && placed[3] >= taken_min_x && placed[4] >= taken_min_y)
			return TRUE
	return FALSE

/datum/overmap_space_region/proc/register_ruin_footprint(turf/load_at, width, height)
	if(!load_at)
		return
	placed_ruins += list(list(
		load_at.x - round(width / 2),
		load_at.y - round(height / 2),
		load_at.x - round(width / 2) + width - 1,
		load_at.y - round(height / 2) + height - 1,
	))

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

/datum/overmap_space_region/proc/covers_reserved_turf(turf/spot)
	if(!spot || spot.z != space_z)
		return FALSE
	return spot.x >= space_origin_x && spot.x < space_origin_x + size + pad * 2 \
		&& spot.y >= space_origin_y && spot.y < space_origin_y + size + pad * 2

/datum/overmap_space_region/proc/center_turf()
	return locate(playable_min_x() + round(size / 2), playable_min_y() + round(size / 2), space_z)
