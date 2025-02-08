//TODO: Flash range does nothing currently

#define CREAK_DELAY 5 SECONDS //Time taken for the creak to play after explosion, if applicable.
#define DEVASTATION_PROB 30 //The probability modifier for devistation, maths!
#define HEAVY_IMPACT_PROB 5 //ditto
#define FAR_UPPER 60 //Upper limit for the far_volume, distance, clamped.
#define FAR_LOWER 40 //lower limit for the far_volume, distance, clamped.
#define PROB_SOUND 75 //The probability modifier for a sound to be an echo, or a far sound. (0-100)
#define SHAKE_CLAMP 2.5 //The limit for how much the camera can shake for out of view booms.
#define FREQ_UPPER 40 //The upper limit for the randomly selected frequency.
#define FREQ_LOWER 25 //The lower of the above.

GLOBAL_LIST_EMPTY(explosions)

SUBSYSTEM_DEF(explosions)
	name = "Explosions"
	init_order = INIT_ORDER_EXPLOSIONS
	priority = FIRE_PRIORITY_EXPLOSIONS
	wait = 1
	flags = SS_TICKER
	runlevels = RUNLEVEL_GAME | RUNLEVEL_POSTGAME

	var/priority_queue/explosion_queue

	var/reactionary_explosions = FALSE
	var/multiz_explosions = FALSE

	// Explosion sounds cache
	var/sound/explosion_sound
	var/sound/far_explosion_sound
	var/sound/creaking_explosion_sound
	var/sound/hull_creaking_sound
	var/sound/explosion_echo_sound


/datum/controller/subsystem/explosions/Initialize()
	if(CONFIG_GET(flag/multiz_explosions))
		multiz_explosions = TRUE
	if(CONFIG_GET(flag/reactionary_explosions))
		reactionary_explosions = TRUE
	explosion_sound = sound(get_sfx("explosion"))
	far_explosion_sound = sound('sound/effects/explosionfar.ogg')
	creaking_explosion_sound = sound(get_sfx("explosion_creaking"))
	hull_creaking_sound = sound(get_sfx("hull_creaking"))
	explosion_echo_sound = sound('sound/effects/explosion_distant.ogg')
	explosion_queue = new()
	return SS_INIT_SUCCESS


/datum/controller/subsystem/explosions/fire(resumed = 0)
	while(!explosion_queue.is_empty())
		var/datum/explosion_data/data = explosion_queue.peek()
		while(!data.affected_turfs_queue.is_empty())
			var/turf/T = data.affected_turfs_queue.dequeue()
			if(QDELETED(T))
				continue
			var/dist = HYPOTENUSE(T.x, T.y, data.x0, data.y0)

			if(reactionary_explosions)
				var/turf_block
				var/total_cords = "[T.x],[T.y],[T.z]"
				var/prev_block
				if(data.multiz_explosion)
					turf_block = data.cached_turf_vert_exp_block[T] ? data.cached_turf_vert_exp_block[T] : count_turf_vert_block(T)
					if(T != data.epicenter)
						var/turf/next_turf = get_step_towards_multiz(T, data.epicenter)
						var/next_cords = "[next_turf.x],[next_turf.y],[next_turf.z]"
						if(next_turf.z != T.z)
							prev_block = data.cached_exp_block[next_cords] ? data.cached_exp_block[next_cords] : count_turf_vert_block(next_turf)
						else
							prev_block = data.cached_exp_block[next_cords] ? data.cached_exp_block[next_cords] : count_turf_block(next_turf)

				else
					turf_block = data.cached_turf_exp_block[T] ? data.cached_turf_exp_block[T] : count_turf_block(T)

					if(T != data.epicenter)
						var/turf/next_turf = get_step_towards(T, data.epicenter)
						var/next_cords = "[next_turf.x],[next_turf.y],[next_turf.z]"
						prev_block = data.cached_exp_block[next_cords] ? data.cached_exp_block[next_cords] : count_turf_block(next_turf)

				if(T == data.epicenter)
					data.cached_exp_block[total_cords] = turf_block
				dist += prev_block
				data.cached_exp_block[total_cords] = prev_block + turf_block

			var/flame_dist = 0

			if(dist < data.flame_range)
				flame_dist = 1

			if(dist < data.devastation_range)		dist = 1
			else if(dist < data.heavy_impact_range)	dist = 2
			else if(dist < data.light_impact_range)	dist = 3
			else 									dist = 0

			//------- TURF FIRES -------

			if(flame_dist && prob(40) && !isspaceturf(T) && !T.density)
				new /obj/effect/hotspot(T) //Mostly for ambience!
			if(dist > 0)
				if(issimulatedturf(T))
					var/turf/simulated/S = T
					var/affecting_level
					if(dist == 1)
						affecting_level = 1
					else
						affecting_level = S.is_shielded() ? 2 : (S.intact ? 2 : 1)
					for(var/atom/AM as anything in S)	//bypass type checking since only atom can be contained by turfs anyway
						if(!QDELETED(AM) && AM.simulated)
							if(AM.level >= affecting_level)
								AM.ex_act(dist, data.epicenter)
				else
					for(var/atom/AM as anything in T)	//see above
						if(!QDELETED(AM) && AM.simulated)
							AM.ex_act(dist, data.epicenter)
				if(data.breach)
					T.ex_act(dist, data.epicenter)
				else
					T.ex_act(3, data.epicenter)
			if(MC_TICK_CHECK)
				return

		var/took = stop_watch(data.watch)
		//You need to press the DebugGame verb to see these now....they were getting annoying and we've collected a fair bit of data. Just -test- changes  to explosion code using this please so we can compare
		log_world("## DEBUG: Explosion([data.x0],[data.y0],[data.z0])(d[data.devastation_range],h[data.heavy_impact_range],l[data.light_impact_range]): Took [took] seconds.")
		data.log_explosions_machines(took)
		qdel(explosion_queue.dequeue())
		if(MC_TICK_CHECK)
			return

/datum/controller/subsystem/explosions/proc/start_explosion(datum/explosion_data/data, adminlog, cause, smoke, silent)
	if(adminlog)
		data.explosion_log(cause)
	if(!silent)
		data.play_sounds_and_shake()
	data.create_effect(smoke)
	data.enqueue_affected_turfs(reactionary_explosions)
	explosion_queue.enqueue(data, data.affected_turfs_queue.count)

/datum/controller/subsystem/explosions/proc/explosion(turf/epicenter, devastation_range, heavy_impact_range, light_impact_range, flash_range, adminlog = TRUE, ignorecap = FALSE, flame_range = 0, silent = FALSE, smoke = TRUE, cause = null, breach = TRUE, protect_epicenter, explosion_direction, explosion_arc)
	if(!epicenter)
		return FALSE

	var/datum/explosion_data/data = new(epicenter, devastation_range, heavy_impact_range, light_impact_range, flash_range, ignorecap, flame_range, breach, multiz_explosions, protect_epicenter, explosion_direction, explosion_arc)
	INVOKE_ASYNC(src, PROC_REF(start_explosion), data, adminlog, cause, smoke, silent)

	return TRUE


/proc/explosion(turf/epicenter, devastation_range, heavy_impact_range, light_impact_range, flash_range, adminlog, ignorecap, flame_range, silent, smoke, cause, breach, protect_epicenter = FALSE, explosion_direction = 0, explosion_arc = 360)
	SSexplosions.explosion(epicenter, devastation_range, heavy_impact_range, light_impact_range, flash_range, adminlog, ignorecap, flame_range, silent, smoke, cause, breach, protect_epicenter, explosion_direction, explosion_arc)

/*
* DON'T USE THIS!!! It is not processed by the system and has no radius restrictions.
*/
/proc/secondaryexplosion(turf/epicenter, range)
	for(var/turf/tile in prepare_explosion_turfs(range, epicenter))
		tile.ex_act(2, epicenter)

/datum/explosion_data
	var/orig_dev_range
	var/orig_heavy_range
	var/orig_light_range
	var/orig_max_distance

	var/turf/epicenter

	var/max_range
	var/x0
	var/y0
	var/z0
	var/min_z
	var/max_z
	var/far_dist = 0
	var/flame_range
	var/flash_range
	var/devastation_range
	var/heavy_impact_range
	var/light_impact_range
	var/explosion_direction = 0
	var/explosion_arc = 360
	var/protect_epicenter = FALSE
	var/breach
	var/multiz_explosion = FALSE
	var/queue/affected_turfs_queue = new()
	var/list/cached_turf_exp_block = list()
	var/list/cached_turf_vert_exp_block = list()
	var/list/cached_exp_block = list()
	var/list/epicenter_list = list()
	var/watch

/datum/explosion_data/New(turf/epicenter, devastation_range, heavy_impact_range, light_impact_range, flash_range, ignorecap = FALSE, flame_range = 0, breach = TRUE, multiz = FALSE, protect_epicenter = FALSE, explosion_direction = 0, explosion_arc = 360)
	. = ..()
	src.epicenter = get_turf(epicenter)
	src.flame_range = flame_range
	src.flash_range = flash_range
	src.devastation_range = devastation_range
	src.heavy_impact_range = heavy_impact_range
	src.light_impact_range = light_impact_range
	src.breach = breach
	src.max_range = max(devastation_range, heavy_impact_range, light_impact_range, flame_range)
	src.explosion_arc = explosion_arc
	src.explosion_direction = explosion_direction
	src.protect_epicenter = protect_epicenter

	orig_dev_range = devastation_range
	orig_heavy_range = heavy_impact_range
	orig_light_range = light_impact_range

	orig_max_distance = max(devastation_range, heavy_impact_range, light_impact_range, flash_range, flame_range)

	if(multiz)
		var/turf/top_turf = get_highest_turf(epicenter)
		var/turf/low_turf = get_lowest_turf(epicenter)
		max_z = min(top_turf.z, epicenter.z + orig_max_distance)
		min_z = max(low_turf.z, epicenter.z - orig_max_distance)
		multiz_explosion = multiz && max_z != min_z

	x0 = epicenter.x
	y0 = epicenter.y
	z0 = epicenter.z

	far_dist = 0
	far_dist += heavy_impact_range * 15
	far_dist += devastation_range * 20
	if(!ignorecap)
		clamp_ranges()
	epicenter_list += epicenter
	watch = start_watch()

/datum/explosion_data/Destroy()
	qdel(affected_turfs_queue)
	LAZYCLEARLIST(epicenter_list)
	LAZYNULL(epicenter_list)
	LAZYCLEARLIST(cached_exp_block)
	LAZYNULL(cached_exp_block)
	LAZYCLEARLIST(cached_turf_exp_block)
	LAZYNULL(cached_turf_exp_block)
	LAZYCLEARLIST(cached_turf_vert_exp_block)
	LAZYNULL(cached_turf_vert_exp_block)
	. = ..()

/datum/explosion_data/proc/clamp_ranges()
	devastation_range = clamp(devastation_range, 0, GLOB.max_ex_devastation_range)
	heavy_impact_range = clamp(heavy_impact_range, 0, GLOB.max_ex_heavy_range)
	light_impact_range = clamp(light_impact_range, 0, GLOB.max_ex_light_range)
	flash_range = clamp(flash_range, 0, GLOB.max_ex_flash_range)
	flame_range = clamp(flame_range, 0, GLOB.max_ex_flame_range)


/datum/explosion_data/proc/create_effect(smoke)
	if(heavy_impact_range > 1)
		var/datum/effect_system/explosion/E
		if(smoke)
			E = new /datum/effect_system/explosion/smoke
		else
			E = new
		E.set_up(epicenter)
		E.start()

/datum/explosion_data/proc/enqueue_affected_turfs(reactionary_explosions)
	var/list/affected_turfs = prepare_explosion_turfs(max_range, epicenter, protect_epicenter, explosion_direction, explosion_arc, multiz_explosion, min_z, max_z)
	if(reactionary_explosions)
		count_reactionary_explosions(affected_turfs)

	for(var/turf in affected_turfs)
		affected_turfs_queue.enqueue(turf)

/datum/explosion_data/proc/count_reactionary_explosions(list/affected_turfs)
	for(var/turf/counted_turf as anything in affected_turfs) // we cache the explosion block rating of every turf in the explosion area
		cached_turf_exp_block[counted_turf] = count_turf_block(counted_turf)
		if(multiz_explosion)
			cached_turf_vert_exp_block[counted_turf] = count_turf_vert_block(counted_turf)

/proc/count_turf_block(turf/counted_turf)
	var/block = 0
	if(counted_turf.density && counted_turf.explosion_block)
		block += counted_turf.explosion_block

	for(var/atom/object as anything in counted_turf)
		var/the_block = object.explosion_block
		block += the_block == EXPLOSION_BLOCK_PROC ? object.get_explosion_block() : the_block
	return block

/proc/count_turf_vert_block(turf/counted_turf)
	var/block = 0
	if(counted_turf.density && counted_turf.explosion_block)
		block += counted_turf.explosion_vertical_block

	for(var/atom/object as anything in counted_turf)
		block += object.explosion_vertical_block
	return block

/datum/explosion_data/proc/explosion_log(cause)
	var/cause_str
	var/atom/cause_atom
	var/cause_vv = ""
	if(isatom(cause))
		cause_atom = cause
		cause_str = cause_atom.name
		cause_vv += ADMIN_VV(cause_atom,"VV")
	else if(istext(cause))
		cause_str = cause
	else if(isnull(cause))
		pass()
	else
		log_runtime("Bad type of cause for logging explosion.")

	message_admins("Explosion with size ([devastation_range], [heavy_impact_range], [light_impact_range], [flame_range]) [cause ? "(Cause: [cause_str] [cause_vv])" : ""] [ADMIN_VERBOSEJMP(epicenter)] ")
	add_game_logs("Explosion with size ([devastation_range], [heavy_impact_range], [light_impact_range], [flame_range]) [cause ? "(Cause: [cause_str])" : ""] [AREACOORD(epicenter)] ")

/datum/explosion_data/proc/log_explosions_machines(took)
	//Machines which report explosions.
	for(var/array in GLOB.doppler_arrays)
		if(!array)
			continue
		if(istype(array, /obj/machinery/doppler_array))
			var/obj/machinery/doppler_array/doppler_array = array
			doppler_array.sense_explosion(x0,y0,z0,devastation_range,heavy_impact_range,light_impact_range,took,orig_dev_range,orig_heavy_range,orig_light_range)
		if(istype(array, /obj/item/clothing/head/helmet/space/hardsuit/rd))
			var/obj/item/clothing/head/helmet/space/hardsuit/rd/helm_array = array
			helm_array.sense_explosion(x0,y0,z0,devastation_range,heavy_impact_range,light_impact_range,took,orig_dev_range,orig_heavy_range,orig_light_range)

/*
* Play sounds; we want sounds to be different depending on distance so we will manually do it ourselves.
* Stereo users will also hear the direction of the explosion!
* Calculate far explosion sound range. Only allow the sound effect for heavy/devastating explosions.
* 3/7/14 will calculate to 80 + 35
*/
/datum/explosion_data/proc/play_sounds_and_shake()
	var/frequency = get_rand_frequency()
	var/on_station = is_station_level(epicenter.z)
	var/creaking_explosion = FALSE

	if(prob(devastation_range * DEVASTATION_PROB + heavy_impact_range * HEAVY_IMPACT_PROB) && on_station) // Huge explosions are near guaranteed to make the station creak and whine, smaller ones might.
		creaking_explosion = TRUE // prob over 100 always returns true

	for(var/MN in GLOB.player_list)
		var/mob/M = MN
		// Double check for client
		var/turf/M_turf = get_turf(M)
		if(M_turf && M_turf.z == z0)
			var/dist = get_dist(M_turf, epicenter)
			var/baseshakeamount
			if(orig_max_distance - dist > 0)
				baseshakeamount = sqrt((orig_max_distance - dist) * 0.1)
			// If inside the blast radius + world.view - 2
			if(dist <= round(max_range + world.view - 2, 1))
				M.playsound_local(epicenter, null, 100, 1, frequency, S = SSexplosions.explosion_sound)
				if(baseshakeamount > 0)
					shake_camera(M, 25, clamp(baseshakeamount, 0, 10))
			// You hear a far explosion if you're outside the blast radius. Small bombs shouldn't be heard all over the station.
			else if(dist <= far_dist)
				var/far_volume = clamp(far_dist / 2, FAR_LOWER, FAR_UPPER) // Volume is based on explosion size and dist
				if(creaking_explosion)
					M.playsound_local(epicenter, null, far_volume, 1, frequency, S = SSexplosions.creaking_explosion_sound, distance_multiplier = 0)
				else if(prob(PROB_SOUND)) // Sound variety during meteor storm/tesloose/other bad event
					M.playsound_local(epicenter, null, far_volume, 1, frequency, S = SSexplosions.far_explosion_sound, distance_multiplier = 0) // Far sound
				else
					M.playsound_local(epicenter, null, far_volume, 1, frequency, S = SSexplosions.explosion_echo_sound, distance_multiplier = 0) // Echo sound

				if(baseshakeamount > 0 || devastation_range)
					if(!baseshakeamount) // Devastating explosions rock the station and ground
						baseshakeamount = devastation_range * 3
					shake_camera(M, 10, clamp(baseshakeamount * 0.25, 0, SHAKE_CLAMP))
			else if(!isspaceturf(get_turf(M)) && heavy_impact_range) // Big enough explosions echo throughout the hull
				var/echo_volume = 40
				if(devastation_range)
					baseshakeamount = devastation_range
					shake_camera(M, 10, clamp(baseshakeamount * 0.25, 0, SHAKE_CLAMP))
					echo_volume = 60
				M.playsound_local(epicenter, null, echo_volume, 1, frequency, S = SSexplosions.explosion_echo_sound, distance_multiplier = 0)

			if(creaking_explosion) // 5 seconds after the bang, the station begins to creak
				addtimer(CALLBACK(M, TYPE_PROC_REF(/mob, playsound_local), epicenter, null, rand(FREQ_LOWER, FREQ_UPPER), 1, frequency, null, null, FALSE, SSexplosions.hull_creaking_sound, 0), CREAK_DELAY)

/// Returns a list of turfs in X range from the epicenter
/// Returns in a unique order, spiraling outwards
/// This is done to ensure our progressive cache of blast resistance is always valid
/// This is quite fast
/proc/prepare_explosion_turfs(range, turf/epicenter, protect_epicenter, explosion_direction = 0, explosion_arc = 360, multiz = FALSE, min_z, max_z)
	var/list/outlist = list()
	var/list/candidates = list()

	var/our_x = epicenter.x
	var/our_y = epicenter.y
	var/our_z = epicenter.z

	if(!multiz)
		min_z = our_z
		max_z = our_z

	var/max_x = world.maxx
	var/max_y = world.maxy

	// Work out the angles to explode between
	var/first_angle_limit = WRAP(explosion_direction - explosion_arc * 0.5, 0, 360)
	var/second_angle_limit = WRAP(explosion_direction + explosion_arc * 0.5, 0, 360)

	// Get everything in the right order
	var/lower_angle_limit
	var/upper_angle_limit
	var/do_directional
	var/reverse_angle

	// Work out which case we're in
	if(first_angle_limit == second_angle_limit) // CASE A: FULL CIRCLE
		do_directional = FALSE
	else if(first_angle_limit < second_angle_limit) // CASE B: When the arc does not cross 0 degrees
		lower_angle_limit = first_angle_limit
		upper_angle_limit = second_angle_limit
		do_directional = TRUE
		reverse_angle = FALSE
	else if (first_angle_limit > second_angle_limit) // CASE C: When the arc crosses 0 degrees
		lower_angle_limit = second_angle_limit
		upper_angle_limit = first_angle_limit
		do_directional = TRUE
		reverse_angle = TRUE

	if(!protect_epicenter)
		if(!do_directional)
			candidates += epicenter
		else
			outlist += epicenter

	for(var/i in 1 to range)
		var/lowest_x = our_x - i
		var/lowest_y = our_y - i
		var/lowest_z = our_z - i
		var/highest_x = our_x + i
		var/highest_y = our_y + i
		var/highest_z = our_z + i
		// top left to one before top right
		if(highest_y <= max_y)
			candidates += block(lowest_x, highest_y, min_z,
								highest_x - 1, highest_y, max_z)
		// top right to one before bottom right
		if(highest_x <= max_x)
			candidates += block(highest_x, highest_y, min_z,
								highest_x, lowest_y + 1, max_z)

		if(multiz && highest_z <= max_z)
			candidates += block(lowest_x + 1, highest_y - 1, max_z,
								highest_x - 1, lowest_y + 1, max_z)

		// bottom right to one before bottom left
		if(lowest_y >= 1)
			candidates += block(highest_x, lowest_y, min_z,
								lowest_x + 1, lowest_y, max_z)
		// bottom left to one before top left
		if(lowest_x >= 1)
			candidates += block(lowest_x, lowest_y, min_z,
								lowest_x, highest_y - 1, max_z)

		if(multiz && lowest_z >= min_z)
			candidates += block(lowest_x + 1, highest_y - 1, min_z,
								highest_x - 1, lowest_y + 1, max_z)

	if(!do_directional)
		outlist = candidates
	else
		for(var/turf/candidate as anything in candidates)
			var/angle = get_angle(epicenter, candidate)
			if(ISINRANGE(angle, lower_angle_limit, upper_angle_limit) ^ reverse_angle)
				outlist += candidate
	return outlist

#undef CREAK_DELAY
#undef DEVASTATION_PROB
#undef HEAVY_IMPACT_PROB
#undef FAR_UPPER
#undef FAR_LOWER
#undef PROB_SOUND
#undef SHAKE_CLAMP
#undef FREQ_UPPER
#undef FREQ_LOWER
