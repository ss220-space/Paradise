/obj/overmap/feature
	name = "аномалия"
	desc = "Неопознанный участок пространства."
	icon_state = "event"
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

	var/hazard_density = 3
	var/list/scatter_points
	var/list/scatter_chunks
	var/list/scatter_radar_chunks
	var/list/scatter_hit_chunks

/obj/overmap/feature/hazard/proc/roll_density()
	return rand(2, 4)

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
	return

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
	if(world.time < vessel.next_overmap_hazard_hit)
		return FALSE
	var/chance = vessel.is_moving() ? movement_hit_chance(vessel) : 0
	if(moving_hazard)
		chance = max(chance, OVERMAP_HAZARD_IDLE_HIT_CHANCE)
	if(!prob(chance))
		return FALSE
	vessel.next_overmap_hazard_hit = world.time + OVERMAP_HAZARD_HIT_COOLDOWN
	return TRUE

/obj/overmap/feature/hazard/proc/is_open_void(turf/spot)
	return isspaceturf(spot)

/obj/overmap/feature/hazard/proc/collect_ship_turfs(obj/overmap/entity/vessel)
	if(vessel.overmap_pod)
		return list(get_turf(vessel.overmap_pod.pod()))
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
		if(!spot || is_open_void(spot) || isspacearea(get_area(spot)))
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
	var/carp_count = 0
	if(!spot)
		return carp_count
	for(var/mob/living/simple_animal/hostile/carp/carp in range(12, spot))
		carp_count++
	return carp_count

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
	desc = "Каменный поток. Имеется шанс врезаться в астероид на большой скорости."
	icon_state = OVERMAP_HAZARD_ICON_ASTEROID
	map_color = "#8a7a68"
	color = null

/obj/overmap/feature/hazard/asteroid/roll_density()
	return text2num(pickweight(list("1" = 16, "2" = 26, "3" = 24, "4" = 16, "5" = 9, "6" = 5, "7" = 3, "8" = 1)))

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

/obj/overmap/feature/hazard/asteroid/taipan_cover
	hidden_from_contacts = FALSE
	scannable = TRUE
	scan_mass = OVERMAP_MASS_STATION
	var/obj/overmap/entity/mask_host

/obj/overmap/feature/hazard/asteroid/taipan_cover/try_affect(obj/overmap/entity/vessel)
	if(vessel && vessel == mask_host)
		return
	return ..()

/obj/overmap/feature/hazard/asteroid/taipan_cover/get_scan_mass()
	if(mask_host)
		return mask_host.get_scan_mass()
	return scan_mass

/obj/overmap/feature/hazard/emp
	name = "ЭМИ-шторм"
	desc = "Электромагнитный фронт. На скорости прошивает корабль импульсами."
	icon_state = OVERMAP_HAZARD_ICON_EMP
	map_color = "#6ec4ff"
	color = null

/obj/overmap/feature/hazard/emp/roll_density()
	return rand(2, 5)

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

/obj/overmap/feature/hazard/carp/roll_density()
	return rand(1, 4)

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

/obj/overmap/feature/hazard/emp/moving
	movable = TRUE
	moving_hazard = TRUE

/obj/overmap/feature/hazard/carp/moving
	movable = TRUE
	moving_hazard = TRUE
