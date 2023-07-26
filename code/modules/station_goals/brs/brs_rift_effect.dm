/obj/effect/abstract/bluespace_rift
	name = "Блюспейс Разлом"
	desc = "Аномальное образование с неизвестными свойствами загадочного синего космоса."
	icon = 'icons/obj/engines_and_power/singularity.dmi'
	icon_state = "singularity_fog"
	appearance_flags = 0
	layer = MASSIVE_OBJ_LAYER
	invisibility =  INVISIBILITY_ANOMALY
	level = 1 // t-ray scaners show only things with level = 1
	luminosity = 1
	alpha = 180
	var/datum/bluespace_rift/rift
	var/size
	var/time_per_tile
	/// World time when the next step should happen.
	var/next_step
	/// An object on the map (turf, mob, etc.) Typecasted to /datum to perform QDELETED check.
	var/datum/target_loc

/obj/effect/abstract/bluespace_rift/Initialize(mapload, rift, size, time_per_tile)
	. = ..()
	if(!(isnull(loc) || rift || size || time_per_tile))
		// The object spawned incorrectly, it won't work that way.
		return INITIALIZE_HINT_QDEL
	
	loc = pick_turf_to_go()
	src.rift = rift
	src.size = size
	src.time_per_tile = time_per_tile
	next_step = world.time
	change_direction()

	GLOB.bluespace_rifts_list |= src
	GLOB.poi_list |= src

	// resize
	var/matrix/new_transform = matrix()
	new_transform.Scale(size)
	transform = new_transform
	// repaint
	color = rand_hex_color()

/obj/effect/abstract/bluespace_rift/Destroy()
	GLOB.bluespace_rifts_list.Remove(src)
	GLOB.poi_list.Remove(src)
	return ..()

/** Movement processing, must be called from `process` function. */
/obj/effect/abstract/bluespace_rift/proc/move()
	if(QDELETED(target_loc))
		change_direction()

	var/iterations = 0
	while(next_step < world.time)
		// Safety check against infinite loop
		if(iterations > 10)
			next_step = world.time + time_till_next_step()
			break
		iterations++
		// The actual step
		forceMove(get_step_towards(src, target_loc))
		next_step += time_till_next_step()
		if(is_target_reached())
			change_direction()

/obj/effect/abstract/bluespace_rift/proc/change_direction()
	target_loc = pick_turf_to_go()

/obj/effect/abstract/bluespace_rift/proc/pick_turf_to_go()
	var/rand_area = findEventArea()
	if(!rand_area)
		log_runtime(EXCEPTION("Couldn't find any station turfs."))
		// Use random coordinates if failing to find a station turf. Should never happen.
		var/rand_x = rand(0, world.maxx)
		var/rand_y = rand(0, world.maxy)
		var/station_z = level_name_to_num(MAIN_STATION)
		return locate(rand_x, rand_y, station_z)
	var/rand_turf = pick(get_area_turfs(rand_area))
	return rand_turf

/obj/effect/abstract/bluespace_rift/proc/is_target_reached()
	return get_turf(src) == get_turf(target_loc)

/obj/effect/abstract/bluespace_rift/proc/time_till_next_step()
	return time_per_tile

/** The speed of a `hunter` rift depends on how close the target is. */
/obj/effect/abstract/bluespace_rift/hunter

/obj/effect/abstract/bluespace_rift/hunter/change_direction()
	target_loc = pick_mob_to_chase()

/obj/effect/abstract/bluespace_rift/hunter/time_till_next_step()
	var/dist_to_target = get_dist(src, target_loc)
	var/time_till_next_step = clamp(dist_to_target * 0.5, 2, 20) SECONDS
	return time_till_next_step

/obj/effect/abstract/bluespace_rift/hunter/proc/pick_mob_to_chase()
	var/list/candidate_players = list()
	for(var/mob/M in GLOB.player_list)
		if(!is_station_level(M.z))
			continue
		if(!isliving(M))
			continue
		if(!M.client)
			continue
		if(M == target_loc)
			continue
		candidate_players += M
	
	if(!length(candidate_players))
		// Use random turf if there are no players on the station
		return pick_turf_to_go()
	var/rand_player = pick(candidate_players)
	return rand_player
