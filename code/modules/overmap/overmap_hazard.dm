/obj/overmap/feature
	name = "аномалия"
	desc = "Неопознанный участок пространства."
	icon_state = "event"
	visible_without_scanner = FALSE
	overmap_kind = OVERMAP_KIND_OTHER
	movable = FALSE
	map_color = "#c9a227"

/obj/overmap/feature/get_ru_names()
	return alist(
		NOMINATIVE = "аномалия",
		GENITIVE = "аномалии",
		DATIVE = "аномалии",
		ACCUSATIVE = "аномалию",
		INSTRUMENTAL = "аномалией",
		PREPOSITIONAL = "аномалии",
	)

/obj/overmap/feature/hazard
	name = "космическая угроза"
	desc = "Опасный участок пространства."
	icon_state = "object"
	overmap_kind = OVERMAP_KIND_HAZARD
	hidden_from_contacts = TRUE
	scannable = FALSE
	layer = LOW_OBJ_LAYER
	map_color = "#8899aa"
	appearance_flags = RESET_COLOR | KEEP_APART
	color = null

	var/moving_hazard = FALSE

/obj/overmap/feature/hazard/Initialize(mapload)
	. = ..()
	SSovermap?.hazards |= src

/obj/overmap/feature/hazard/Destroy()
	SSovermap?.hazards -= src
	return ..()

/obj/overmap/feature/hazard/update_overlays()
	return list()

/obj/overmap/feature/hazard/proc/process_tick(elapsed)
	if(movable)
		process_movement(elapsed)
	var/turf/here = loc
	if(!isturf(here))
		return
	for(var/obj/overmap/entity/vessel in here)
		try_affect(vessel)

/obj/overmap/feature/hazard/proc/try_affect(obj/overmap/entity/vessel)
	if(!vessel || QDELETED(vessel) || vessel.overmap_hazard_immune)
		return
	if(vessel.programmed_mission)
		return
	if(!isturf(vessel.loc))
		return
	affect_vessel(vessel)

/obj/overmap/feature/hazard/proc/affect_vessel(obj/overmap/entity/vessel)
	return

/obj/overmap/feature/hazard/proc/displayed_speed(obj/overmap/entity/vessel)
	return OVERMAP_DISPLAY_SPEED(vessel.get_speed())

/obj/overmap/feature/hazard/proc/movement_hit_chance(obj/overmap/entity/vessel)
	var/speed = displayed_speed(vessel)
	if(speed <= OVERMAP_HAZARD_SAFE_SPEED)
		return 0
	var/span = OVERMAP_HAZARD_SPEED_CAP - OVERMAP_HAZARD_SAFE_SPEED
	return OVERMAP_HAZARD_HIT_CHANCE_CAP * clamp((speed - OVERMAP_HAZARD_SAFE_SPEED) / span, 0, 1)

/obj/overmap/feature/hazard/proc/should_strike_moving(obj/overmap/entity/vessel)
	if(vessel.is_moving())
		return prob(movement_hit_chance(vessel))
	if(moving_hazard)
		return prob(OVERMAP_HAZARD_IDLE_HIT_CHANCE)
	return FALSE

/obj/overmap/feature/hazard/proc/is_open_void(turf/spot)
	return isspaceturf(spot)

/obj/overmap/feature/hazard/proc/collect_ship_turfs(obj/overmap/entity/vessel)
	. = list()
	if(vessel.shuttle)
		for(var/area/place as anything in vessel.shuttle.shuttle_areas)
			for(var/turf/spot in place)
				if(is_open_void(spot))
					continue
				. += spot
		return
	var/list/zs = levels_by_trait(STATION_LEVEL)
	if(!length(zs))
		return
	for(var/i in 1 to 80)
		var/turf/spot = locate(rand(TRANSITIONEDGE, world.maxx - TRANSITIONEDGE), rand(TRANSITIONEDGE, world.maxy - TRANSITIONEDGE), pick(zs))
		if(!spot || is_open_void(spot) || istype(get_area(spot), /area/space))
			continue
		. |= spot

/obj/overmap/feature/hazard/proc/is_hull_turf(turf/spot)
	if(!spot || is_open_void(spot))
		return FALSE
	for(var/dir in GLOB.cardinal)
		if(is_open_void(get_step(spot, dir)))
			return TRUE
	return FALSE

/obj/overmap/feature/hazard/proc/pick_impact_turf(obj/overmap/entity/vessel)
	var/list/all_turfs = collect_ship_turfs(vessel)
	if(!length(all_turfs))
		return null
	var/list/hull = list()
	for(var/turf/spot as anything in all_turfs)
		if(is_hull_turf(spot))
			hull += spot
	if(length(hull) && prob(75))
		return pick(hull)
	return pick(all_turfs)

/obj/overmap/feature/hazard/proc/pick_structure_turf(obj/overmap/entity/vessel)
	return pick_impact_turf(vessel)

/obj/overmap/feature/hazard/proc/find_approach_space(turf/goal)
	if(!goal)
		return null
	var/list/adjacent = list()
	for(var/dir in GLOB.alldirs)
		var/turf/spot = get_step(goal, dir)
		if(is_open_void(spot))
			adjacent += spot
	if(length(adjacent))
		return pick(adjacent)
	for(var/turf/spot in orange(8, goal))
		if(!is_open_void(spot))
			continue
		if(get_dist(spot, goal) < 1)
			continue
		return spot
	return null

/obj/overmap/feature/hazard/proc/pick_space_near_hull(obj/overmap/entity/vessel, min_dist = 2, max_dist = 3)
	var/turf/anchor = pick_impact_turf(vessel)
	if(!anchor)
		return null
	var/list/spots = list()
	for(var/turf/spot in orange(max_dist, anchor))
		if(!is_open_void(spot))
			continue
		var/dist = get_dist(anchor, spot)
		if(dist < min_dist || dist > max_dist)
			continue
		spots += spot
	if(!length(spots))
		return find_approach_space(anchor)
	return pick(spots)

/obj/overmap/feature/hazard/proc/count_nearby_carp(turf/spot)
	. = 0
	if(!spot)
		return
	for(var/mob/living/simple_animal/hostile/carp/carp in range(12, spot))
		.++

/obj/overmap/feature/hazard/proc/spawn_meteor_at(obj/overmap/entity/vessel)
	var/turf/goal = pick_impact_turf(vessel)
	if(!goal)
		return FALSE
	var/turf/start = find_approach_space(goal)
	if(start)
		var/obj/effect/meteor/medium/rock = new(start, goal)
		rock.dest = goal
		return TRUE

	explosion(goal, devastation_range = 0, heavy_impact_range = 1, light_impact_range = 2, flash_range = 3, adminlog = FALSE, cause = "overmap asteroid belt")
	return TRUE

/obj/overmap/feature/hazard/asteroid
	name = "пояс астероидов"
	desc = "Каменный поток. На низкой скорости безопасен, на высокой бьёт по обшивке."
	icon_state = OVERMAP_HAZARD_ICON_ASTEROID
	map_color = "#8a7a68"
	color = null

/obj/overmap/feature/hazard/asteroid/get_ru_names()
	return alist(
		NOMINATIVE = "пояс астероидов",
		GENITIVE = "пояса астероидов",
		DATIVE = "поясу астероидов",
		ACCUSATIVE = "пояс астероидов",
		INSTRUMENTAL = "поясом астероидов",
		PREPOSITIONAL = "поясе астероидов",
	)

/obj/overmap/feature/hazard/asteroid/affect_vessel(obj/overmap/entity/vessel)
	if(!should_strike_moving(vessel))
		return
	INVOKE_ASYNC(src, PROC_REF(spawn_meteor_at), vessel)

/obj/overmap/feature/hazard/emp
	name = "ЭМИ-шторм"
	desc = "Электромагнитный фронт. На скорости прошивает корабль импульсами."
	icon_state = OVERMAP_HAZARD_ICON_EMP
	map_color = "#6ec4ff"
	color = null

/obj/overmap/feature/hazard/emp/get_ru_names()
	return alist(
		NOMINATIVE = "ЭМИ-шторм",
		GENITIVE = "ЭМИ-шторма",
		DATIVE = "ЭМИ-шторму",
		ACCUSATIVE = "ЭМИ-шторм",
		INSTRUMENTAL = "ЭМИ-штормом",
		PREPOSITIONAL = "ЭМИ-шторме",
	)

/obj/overmap/feature/hazard/emp/affect_vessel(obj/overmap/entity/vessel)
	if(!should_strike_moving(vessel))
		return
	INVOKE_ASYNC(src, PROC_REF(do_emp_strike), vessel)

/obj/overmap/feature/hazard/emp/proc/do_emp_strike(obj/overmap/entity/vessel)
	var/turf/epicenter = pick_structure_turf(vessel)
	if(!epicenter)
		return
	if(prob(OVERMAP_HAZARD_LIGHTNING_CHANCE))
		strike_lightning(epicenter, vessel)
		return
	var/strong = prob(OVERMAP_HAZARD_EMP_STRONG_CHANCE)
	var/radius = strong ? rand(5, 12) : rand(3, 9)
	var/heavy = max(1, round(radius * (strong ? 0.55 : 0.35)))
	empulse(epicenter, heavy, radius, FALSE, "overmap EMP storm")

/obj/overmap/feature/hazard/emp/proc/strike_lightning(turf/epicenter, obj/overmap/entity/vessel)
	tesla_zap(source = epicenter, zap_range = rand(4, 8), power = 8e3, cutoff = 1e3, zap_flags = ZAP_MOB_DAMAGE | ZAP_OBJ_DAMAGE | ZAP_MOB_STUN)
	spawn_meteor_at(vessel)
	var/turf/cursor = epicenter
	for(var/step_i in 1 to rand(2, 4))
		cursor = get_step(cursor, pick(GLOB.cardinal))
		if(!cursor || isspaceturf(cursor))
			break
		cursor.ex_act(EXPLODE_LIGHT)

/obj/overmap/feature/hazard/carp
	name = "миграция карпов"
	desc = "Зона обитания космических карпов. Держитесь от обшивки."
	icon_state = OVERMAP_HAZARD_ICON_CARP
	map_color = "#3cb89a"
	color = null

/obj/overmap/feature/hazard/carp/get_ru_names()
	return alist(
		NOMINATIVE = "миграция карпов",
		GENITIVE = "миграции карпов",
		DATIVE = "миграции карпов",
		ACCUSATIVE = "миграцию карпов",
		INSTRUMENTAL = "миграцией карпов",
		PREPOSITIONAL = "миграции карпов",
	)

/obj/overmap/feature/hazard/carp/affect_vessel(obj/overmap/entity/vessel)
	if(world.time < vessel.next_overmap_hazard_carp)
		return
	vessel.next_overmap_hazard_carp = world.time + OVERMAP_HAZARD_CARP_COOLDOWN
	var/turf/probe = pick_space_near_hull(vessel)
	if(!probe)
		return
	if(count_nearby_carp(probe) >= OVERMAP_HAZARD_CARP_CAP)
		return
	var/amount = rand(OVERMAP_HAZARD_CARP_MIN, OVERMAP_HAZARD_CARP_MAX)
	for(var/i in 1 to amount)
		var/turf/spot = pick_space_near_hull(vessel)
		if(!spot)
			continue
		new /mob/living/simple_animal/hostile/carp(spot)

/obj/overmap/feature/hazard/asteroid/moving
	movable = TRUE
	moving_hazard = TRUE
	wraparound = TRUE

/obj/overmap/feature/hazard/emp/moving
	movable = TRUE
	moving_hazard = TRUE
	wraparound = TRUE

/obj/overmap/feature/hazard/carp/moving
	movable = TRUE
	moving_hazard = TRUE
	wraparound = TRUE

/proc/overmap_hazard_spawn_blocked(datum/overmap_sector/sector, turf/spot)
	if(!sector || !spot)
		return TRUE
	if(sector.turf_occupied(spot))
		return TRUE
	if(SSovermap.lavaland_planet?.covers_turf(spot))
		return TRUE
	if(locate(/obj/overmap/feature/hazard) in spot)
		return TRUE
	if(locate(/obj/overmap/portal) in spot)
		return TRUE
	var/obj/overmap/entity/station = SSovermap?.station_entity
	if(station?.loc && max(abs(spot.x - station.loc.x), abs(spot.y - station.loc.y)) <= 1)
		return TRUE
	return FALSE

/proc/overmap_hazard_edge_weight(datum/overmap_sector/sector, turf/spot)
	var/center_x = sector.origin_x + round(sector.size / 2)
	var/center_y = sector.origin_y + round(sector.size / 2)
	var/dist = max(abs(spot.x - center_x), abs(spot.y - center_y))
	var/max_dist = max(1, round(sector.size / 2) - OVERMAP_EDGE)
	var/ratio = clamp(dist / max_dist, 0, 1)
	return 0.14 + 0.86 * ratio * ratio

/proc/overmap_hazard_pick_start(datum/overmap_sector/sector)
	var/low_x = sector.origin_x + OVERMAP_EDGE
	var/low_y = sector.origin_y + OVERMAP_EDGE
	var/high_x = sector.origin_x + sector.size - OVERMAP_EDGE - 1
	var/high_y = sector.origin_y + sector.size - OVERMAP_EDGE - 1
	var/list/bag = list()
	for(var/turf/spot as anything in block(locate(low_x, low_y, sector.z_level), locate(high_x, high_y, sector.z_level)))
		if(overmap_hazard_spawn_blocked(sector, spot))
			continue
		var/weight = overmap_hazard_edge_weight(sector, spot)
		bag[spot] = max(1, round(weight * 100))
	if(!length(bag))
		return null
	return pickweight(bag)

/proc/overmap_hazard_place(hazard_type, datum/overmap_sector/sector, turf/spot)
	if(overmap_hazard_spawn_blocked(sector, spot))
		return null
	var/obj/overmap/feature/hazard/hazard = new hazard_type(spot)
	sector.add_object(hazard, spot)
	return hazard

/proc/overmap_hazard_paint_line(hazard_type, datum/overmap_sector/sector, turf/start, length, dir, wobble = FALSE)
	. = 0
	var/turf/cursor = start
	for(var/i in 1 to length)
		if(!cursor)
			break
		if(overmap_hazard_place(hazard_type, sector, cursor))
			.++
		if(wobble && prob(35))
			var/turf/side = get_step(cursor, turn(dir, pick(-90, 90)))
			if(side && !overmap_hazard_spawn_blocked(sector, side))
				overmap_hazard_place(hazard_type, sector, side)
				.++
		cursor = get_step(cursor, dir)
		if(!cursor || cursor.z != sector.z_level)
			break
		if(cursor.x < sector.origin_x + OVERMAP_EDGE || cursor.x > sector.origin_x + sector.size - OVERMAP_EDGE - 1)
			break
		if(cursor.y < sector.origin_y + OVERMAP_EDGE || cursor.y > sector.origin_y + sector.size - OVERMAP_EDGE - 1)
			break

/proc/overmap_hazard_paint_blob(hazard_type, datum/overmap_sector/sector, turf/start, size)
	. = 0
	var/list/open = list(start)
	var/list/seen = list()
	while(length(open) && . < size)
		var/turf/cursor = pick_n_take(open)
		if(seen[cursor])
			continue
		seen[cursor] = TRUE
		if(overmap_hazard_place(hazard_type, sector, cursor))
			.++
		for(var/dir in GLOB.cardinal)
			var/turf/next = get_step(cursor, dir)
			if(!next || seen[next] || overmap_hazard_spawn_blocked(sector, next))
				continue
			if(next.x < sector.origin_x + OVERMAP_EDGE || next.x > sector.origin_x + sector.size - OVERMAP_EDGE - 1)
				continue
			if(next.y < sector.origin_y + OVERMAP_EDGE || next.y > sector.origin_y + sector.size - OVERMAP_EDGE - 1)
				continue
			open += next

/proc/overmap_hazard_paint_arc(hazard_type, datum/overmap_sector/sector, turf/start, length, dir)
	. = 0
	var/turf/cursor = start
	var/heading = dir
	for(var/i in 1 to length)
		if(!cursor)
			break
		if(overmap_hazard_place(hazard_type, sector, cursor))
			.++
		if(prob(40))
			heading = turn(heading, pick(-45, 45))
			if(!heading)
				heading = dir
		cursor = get_step(cursor, heading)
		if(!cursor || cursor.z != sector.z_level)
			break
		if(cursor.x < sector.origin_x + OVERMAP_EDGE || cursor.x > sector.origin_x + sector.size - OVERMAP_EDGE - 1)
			break
		if(cursor.y < sector.origin_y + OVERMAP_EDGE || cursor.y > sector.origin_y + sector.size - OVERMAP_EDGE - 1)
			break

/proc/overmap_hazard_paint_ring(hazard_type, datum/overmap_sector/sector, turf/start, radius, count)
	. = 0
	if(!start)
		return
	var/list/ring = list()
	for(var/turf/spot in orange(radius, start))
		if(get_dist(start, spot) != radius)
			continue
		if(spot.z != sector.z_level)
			continue
		if(spot.x < sector.origin_x + OVERMAP_EDGE || spot.x > sector.origin_x + sector.size - OVERMAP_EDGE - 1)
			continue
		if(spot.y < sector.origin_y + OVERMAP_EDGE || spot.y > sector.origin_y + sector.size - OVERMAP_EDGE - 1)
			continue
		ring += spot
	if(!length(ring))
		return overmap_hazard_paint_blob(hazard_type, sector, start, count)
	for(var/i in 1 to min(count, length(ring)))
		var/turf/spot = pick_n_take(ring)
		if(overmap_hazard_place(hazard_type, sector, spot))
			.++

/proc/overmap_hazard_paint_scatter(hazard_type, datum/overmap_sector/sector, turf/start, count, spread)
	. = 0
	if(!start)
		return
	var/list/pool = list(start)
	for(var/turf/spot in orange(spread, start))
		if(spot.z != sector.z_level)
			continue
		if(spot.x < sector.origin_x + OVERMAP_EDGE || spot.x > sector.origin_x + sector.size - OVERMAP_EDGE - 1)
			continue
		if(spot.y < sector.origin_y + OVERMAP_EDGE || spot.y > sector.origin_y + sector.size - OVERMAP_EDGE - 1)
			continue
		pool += spot
	for(var/i in 1 to count)
		if(!length(pool))
			break
		var/turf/spot = pick_n_take(pool)
		if(overmap_hazard_place(hazard_type, sector, spot))
			.++

/proc/overmap_hazard_paint_elbow(hazard_type, datum/overmap_sector/sector, turf/start, length, dir)
	. = overmap_hazard_paint_line(hazard_type, sector, start, max(2, round(length / 2)), dir, FALSE)
	var/turf/corner = start
	for(var/i in 1 to max(1, round(length / 2)))
		corner = get_step(corner, dir)
		if(!corner)
			return
	. += overmap_hazard_paint_line(hazard_type, sector, corner, max(2, length - round(length / 2)), turn(dir, pick(-90, 90)), TRUE)

/proc/overmap_hazard_paint_random(hazard_type, datum/overmap_sector/sector, turf/start)
	if(!start)
		return 0
	var/list/line_dirs = list(NORTH, SOUTH, EAST, WEST, NORTHEAST, NORTHWEST, SOUTHEAST, SOUTHWEST)
	switch(rand(1, 6))
		if(1)
			return overmap_hazard_paint_line(hazard_type, sector, start, rand(4, 9), pick(line_dirs), TRUE)
		if(2)
			return overmap_hazard_paint_line(hazard_type, sector, start, rand(5, 10), pick(line_dirs), FALSE)
		if(3)
			return overmap_hazard_paint_blob(hazard_type, sector, start, rand(4, 8))
		if(4)
			return overmap_hazard_paint_arc(hazard_type, sector, start, rand(5, 9), pick(line_dirs))
		if(5)
			return overmap_hazard_paint_ring(hazard_type, sector, start, rand(2, 3), rand(5, 9))
		else
			if(prob(50))
				return overmap_hazard_paint_scatter(hazard_type, sector, start, rand(4, 7), rand(2, 3))
			return overmap_hazard_paint_elbow(hazard_type, sector, start, rand(5, 8), pick(line_dirs))

/proc/spawn_static_overmap_hazards(datum/overmap_sector/sector)
	if(!sector)
		return
	for(var/i in 1 to rand(4, 6))
		var/turf/start = overmap_hazard_pick_start(sector)
		if(!start)
			break
		overmap_hazard_paint_random(/obj/overmap/feature/hazard/asteroid, sector, start)
	for(var/i in 1 to rand(2, 4))
		var/turf/start = overmap_hazard_pick_start(sector)
		if(!start)
			break
		overmap_hazard_paint_random(/obj/overmap/feature/hazard/emp, sector, start)
	for(var/i in 1 to rand(2, 4))
		var/turf/start = overmap_hazard_pick_start(sector)
		if(!start)
			break
		overmap_hazard_paint_random(/obj/overmap/feature/hazard/carp, sector, start)
	log_world("Overmap: static hazards placed on sector [sector.id].")

/proc/spawn_moving_overmap_hazards(datum/overmap_sector/sector)
	return
