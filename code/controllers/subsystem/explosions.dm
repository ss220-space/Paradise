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
	var/multiz_explosions = TRUE

	// Explosion sounds cache
	var/sound/explosion_sound
	var/sound/far_explosion_sound
	var/sound/creaking_explosion_sound
	var/sound/hull_creaking_sound
	var/sound/explosion_echo_sound


/datum/controller/subsystem/explosions/Initialize()
	if(CONFIG_GET(flag/reactionary_explosions))
		reactionary_explosions = TRUE
	explosion_sound = sound(get_sfx(SFX_EXPLOSION))
	far_explosion_sound = sound('sound/effects/explosionfar.ogg')
	creaking_explosion_sound = sound(get_sfx(SFX_EXPLOSION_CREAKING))
	hull_creaking_sound = sound(get_sfx(SFX_HULL_CREAKING))
	explosion_echo_sound = sound('sound/effects/explosion_distant.ogg')
	explosion_queue = new()
	return SS_INIT_SUCCESS


/datum/controller/subsystem/explosions/fire(resumed = 0)
	while(!explosion_queue.is_empty())
		var/datum/explosion_data/data = explosion_queue.peek()
		while(!data.affected_turfs_queue.is_empty())
			var/turf/explode = data.affected_turfs_queue.dequeue()
			if(QDELETED(explode))
				continue
			var/distance = CHEAP_HYPOTENUSE(explode.x, explode.y, data.x0, data.y0)

			if(reactionary_explosions)
				var/turf_block
				var/total_cords = "[explode.x],[explode.y],[explode.z]"
				var/prev_block
				if(data.multiz_explosion)
					turf_block = data.cached_turf_vert_exp_block[explode] ? data.cached_turf_vert_exp_block[explode] : count_turf_vert_block(explode)
					if(explode != data.epicenter)
						var/turf/next_turf = get_step_towards_multiz(explode, data.epicenter)
						var/next_cords = "[next_turf.x],[next_turf.y],[next_turf.z]"
						if(next_turf.z != explode.z)
							prev_block = data.cached_exp_block[next_cords] ? data.cached_exp_block[next_cords] : count_turf_vert_block(next_turf)
						else
							prev_block = data.cached_exp_block[next_cords] ? data.cached_exp_block[next_cords] : count_turf_block(next_turf)

				else
					turf_block = data.cached_turf_exp_block[explode] ? data.cached_turf_exp_block[explode] : count_turf_block(explode)

					if(explode != data.epicenter)
						var/turf/next_turf = get_step_towards(explode, data.epicenter)
						var/next_cords = "[next_turf.x],[next_turf.y],[next_turf.z]"
						prev_block = data.cached_exp_block[next_cords] ? data.cached_exp_block[next_cords] : count_turf_block(next_turf)

				if(explode == data.epicenter)
					data.cached_exp_block[total_cords] = turf_block
				distance += prev_block
				data.cached_exp_block[total_cords] = prev_block + turf_block

			var/flame_distance = distance < data.flame_range


			if(distance < data.devastation_range)
				distance = EXPLODE_DEVASTATE
			else if(distance < data.heavy_impact_range)
				distance = EXPLODE_HEAVY
			else if(distance < data.light_impact_range)
				distance = EXPLODE_LIGHT
			else
				distance = EXPLODE_NONE

			//------- TURF FIRES -------

			if(flame_distance && prob(40) && !isspaceturf(explode) && !explode.density)
				new /obj/effect/hotspot(explode) //Mostly for ambience!
			if(distance > EXPLODE_NONE)
				if(issimulatedturf(explode))
					var/turf/simulated/S = explode
					var/affecting_level
					if(distance == EXPLODE_DEVASTATE)
						affecting_level = 1
					else
						affecting_level = S.is_shielded() ? 2 : (S.intact ? 2 : 1)
					for(var/atom/AM as anything in S)	//bypass type checking since only atom can be contained by turfs anyway
						if(!QDELETED(AM) && AM.simulated)
							if(AM.level >= affecting_level)
								AM.ex_act(distance, data.epicenter)
				else
					for(var/atom/AM as anything in explode)	//see above
						if(!QDELETED(AM) && AM.simulated)
							AM.ex_act(distance, data.epicenter)
				if(data.breach)
					explode.ex_act(distance, data.epicenter)
				else
					explode.ex_act(EXPLODE_LIGHT, data.epicenter)
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

	var/datum/explosion_data/data = new(get_turf(epicenter), devastation_range, heavy_impact_range, light_impact_range, flash_range, ignorecap, flame_range, breach, multiz_explosions, protect_epicenter, explosion_direction, explosion_arc)
	INVOKE_ASYNC(src, PROC_REF(start_explosion), data, adminlog, cause, smoke, silent)

	return TRUE

/**
 * Makes a given turf explode.
 *
 * Arguments:
 * - [origin][/turf]: The turf that's exploding.
 * - devastation_range: The range at which the effects of the explosion are at their strongest.
 * - heavy_impact_range: The range at which the effects of the explosion are relatively severe.
 * - light_impact_range: The range at which the effects of the explosion are relatively weak.
 * - flash_range: The range at which the explosion flashes people.
 * - adminlog: Whether to log the explosion/report it to the administration.
 * - ignorecap: Whether to ignore the relevant bombcap. Defaults to FALSE.
 * - flame_range: The range at which the explosion should produce hotspots.
 * - silent: Whether to generate/execute sound effects.
 * - smoke: Whether to generate a smoke cloud provided the explosion is powerful enough to warrant it.
 * - cause: [Optional] The turf that caused the explosion, when different to the origin. Used for logging.
 * - breach: ... (Is it possible that this is a hole formation and the value is Boolean? -- LittleBoobs)
 * - protect_epicenter: Whether to leave the epicenter turf unaffected by the explosion
 * - explosion_direction: The angle in which the explosion is pointed (for directional explosions.)
 * - explosion_arc: The angle of the arc covered by a directional explosion (if 360 the explosion is non-directional.)
 */
/proc/explosion(turf/epicenter, devastation_range, heavy_impact_range, light_impact_range, flash_range, adminlog, ignorecap, flame_range, silent, smoke, cause, breach, protect_epicenter = FALSE, explosion_direction = 0, explosion_arc = 360)
	SSexplosions.explosion(epicenter, devastation_range, heavy_impact_range, light_impact_range, flash_range, adminlog, ignorecap, flame_range, silent, smoke, cause, breach, protect_epicenter, explosion_direction, explosion_arc)

/*
* DONT USE THIS!!! It is not processed by the system and has no radius restrictions.
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
	var/far_distance = 0
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
	var/watch

/datum/explosion_data/New(turf/epicenter, devastation_range, heavy_impact_range, light_impact_range, flash_range, ignorecap = FALSE, flame_range = 0, breach = TRUE, multiz = FALSE, protect_epicenter = FALSE, explosion_direction = 0, explosion_arc = 360)
	. = ..()
	src.epicenter = epicenter
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

	far_distance = 0
	far_distance += heavy_impact_range * 15
	far_distance += devastation_range * 20
	if(!ignorecap)
		clamp_ranges()
	watch = start_watch()

/datum/explosion_data/Destroy()
	qdel(affected_turfs_queue)
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
	if(devastation_range > 0)
		new /obj/effect/temp_visual/explosion(epicenter, max_range, FALSE, TRUE)
	else if(heavy_impact_range > 0)
		new /obj/effect/temp_visual/explosion(epicenter, max_range, FALSE, FALSE)
	else if(light_impact_range > 0)
		new /obj/effect/temp_visual/explosion(epicenter, max_range, TRUE, FALSE)

	if(max_range >= 6 || heavy_impact_range)
		new /obj/effect/temp_visual/shockwave(epicenter, max_range)

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
			doppler_array.sense_explosion(x0, y0, z0, devastation_range, heavy_impact_range, light_impact_range, took, orig_dev_range, orig_heavy_range, orig_light_range)
		if(istype(array, /obj/item/clothing/head/helmet/space/hardsuit/rd))
			var/obj/item/clothing/head/helmet/space/hardsuit/rd/helm_array = array
			helm_array.sense_explosion(x0, y0, z0, devastation_range, heavy_impact_range, light_impact_range, took, orig_dev_range, orig_heavy_range, orig_light_range)

// Explosion SFX defines...
/// The probability that a quaking explosion will make the station creak per unit. Maths!
#define QUAKE_CREAK_PROB 30
/// The probability that an echoing explosion will make the station creak per unit.
#define ECHO_CREAK_PROB 5
/// Time taken for the hull to begin to creak after an explosion, if applicable.
#define CREAK_DELAY (5 SECONDS)
/// Lower limit for far explosion SFX volume.
#define FAR_LOWER 40
/// Upper limit for far explosion SFX volume.
#define FAR_UPPER 60
/// The probability that a distant explosion SFX will be a far explosion sound rather than an echo. (0-100)
#define FAR_SOUND_PROB 75
/// The upper limit on screenshake amplitude for nearby explosions.
#define NEAR_SHAKE_CAP 5
/// The upper limit on screenshake amplifude for distant explosions.
#define FAR_SHAKE_CAP 1.5
/// The duration of the screenshake for nearby explosions.
#define NEAR_SHAKE_DURATION (1.5 SECONDS)
/// The duration of the screenshake for distant explosions.
#define FAR_SHAKE_DURATION (1 SECONDS)
/// The lower limit for the randomly selected hull creaking_explosion frequency.
#define FREQ_LOWER 25
/// The upper limit for the randomly selected hull creaking_explosion frequency.
#define FREQ_UPPER 40

/**
 * Handles the sfx and screenshake caused by an explosion.
 *
 * Arguments:
 * - [epicenter][/turf]: The location of the explosion.
 * - max_range: How close to the explosion you need to be to get the full effect of the explosion.
 * - far_distance: How close to the explosion you need to be to hear more than echos.
 * - devastation_range: Main scaling factor for screenshake.
 * - heavy_impact_range: Whether to make the explosion echo off of very distant parts of the station.
 * - creaking_explosion: Whether to make the station creak. Autoset if null.
 * - [explosion_sound][/sound]: The sound that plays if you are close to the explosion.
 * - [far_explosion_sound][/sound]: The sound that plays if you are far from the explosion.
 * - [explosion_echo_sound][/sound]: The sound that plays as echos for the explosion.
 * - [creaking_explosion_sound][/sound]: The sound that plays when the station creaks during the explosion.
 * - [hull_creaking_sound][/sound]: The sound that plays when the station creaks after the explosion.
 */
/datum/explosion_data/proc/play_sounds_and_shake()
	var/frequency = get_rand_frequency()
	var/on_station = is_station_level(epicenter.z)
	var/creaking_explosion = FALSE

	if(on_station && prob((devastation_range * QUAKE_CREAK_PROB) + (heavy_impact_range * ECHO_CREAK_PROB))) // Huge explosions are near guaranteed to make the station creak and whine, smaller ones might.
		creaking_explosion = TRUE // prob over 100 always returns true

	for(var/mob/listener as anything in GLOB.player_list)
		var/turf/listener_turf = get_turf(listener)
		if(!listener_turf || listener_turf.z != z0)
			continue

		var/distance = get_dist(listener_turf, epicenter)
		if(epicenter == listener_turf)
			distance = 0
		var/base_shake_amount = sqrt(orig_max_distance / (distance + 1))

		if(distance <= round(max_range + world.view - 2, 1)) // If you are close enough to see the effects of the explosion first-hand (ignoring walls)
			listener.playsound_local(epicenter, null, 100, TRUE, frequency, sound = SSexplosions.explosion_sound)
			if(base_shake_amount > 0)
				shake_camera(listener, NEAR_SHAKE_DURATION, clamp(base_shake_amount, 0, NEAR_SHAKE_CAP))

		else if(distance <= far_distance) // You can hear a far explosion if you are outside the blast radius. Small explosions shouldn't be heard throughout the station.
			var/far_volume = clamp(far_distance / 2, FAR_LOWER, FAR_UPPER) // Volume is based on explosion size and distance
			if(creaking_explosion)
				listener.playsound_local(epicenter, null, far_volume, TRUE, frequency, sound = SSexplosions.creaking_explosion_sound, distance_multiplier = 0)
			else if(prob(FAR_SOUND_PROB)) // Sound variety during meteor storm/tesloose/other bad event
				listener.playsound_local(epicenter, null, far_volume, TRUE, frequency, sound = SSexplosions.far_explosion_sound, distance_multiplier = 0) // Far sound
			else
				listener.playsound_local(epicenter, null, far_volume, TRUE, frequency, sound = SSexplosions.explosion_echo_sound, distance_multiplier = 0) // Echo sound

			if(base_shake_amount > 0 || devastation_range)
				base_shake_amount = max(base_shake_amount, devastation_range * 3, 0) // Devastating explosions rock the station and ground
				shake_camera(listener, FAR_SHAKE_DURATION, min(base_shake_amount, FAR_SHAKE_CAP))

		else if(!isspaceturf(get_turf(listener)) && heavy_impact_range) // Big enough explosions echo throughout the hull
			var/echo_volume = 40
			if(devastation_range)
				echo_volume = 60
				shake_camera(listener, 10, clamp(devastation_range * 0.25, 0, FAR_SHAKE_CAP))
			listener.playsound_local(epicenter, null, echo_volume, TRUE, frequency, sound = SSexplosions.explosion_echo_sound, distance_multiplier = 0)

		if(creaking_explosion) // 5 seconds after the bang, the station begins to creak
			addtimer(CALLBACK(listener, TYPE_PROC_REF(/mob, playsound_local), epicenter, null, rand(FREQ_LOWER, FREQ_UPPER), TRUE, frequency, null, null, FALSE, SSexplosions.hull_creaking_sound, 0), CREAK_DELAY)

#undef CREAK_DELAY
#undef QUAKE_CREAK_PROB
#undef ECHO_CREAK_PROB
#undef FAR_UPPER
#undef FAR_LOWER
#undef FAR_SOUND_PROB
#undef NEAR_SHAKE_CAP
#undef FAR_SHAKE_CAP
#undef NEAR_SHAKE_DURATION
#undef FAR_SHAKE_DURATION
#undef FREQ_UPPER
#undef FREQ_LOWER

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

