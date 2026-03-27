/// Minimum amount of players required to start this event
#define BINGLES_MINPLAYERS_TRIGGER 30
/// How many lords do we spawn
#define BINGLE_LORD_SPAWN_COUNT 2

/datum/event/bingles

/datum/event/bingles/start()
	// It is necessary to wrap this to avoid the event triggering repeatedly.
	INVOKE_ASYNC(src, PROC_REF(wrapped_start))

/datum/event/bingles/proc/wrapped_start()
	// Reroll event if not enough players
	var/player_count = num_station_players()
	if(player_count < BINGLES_MINPLAYERS_TRIGGER)
		log_and_message_admins("Random event attempted to spawn bingles, but there were only [player_count]/[BINGLES_MINPLAYERS_TRIGGER] players.")
		var/datum/event_container/major_container = SSevents.event_containers[EVENT_LEVEL_MAJOR]
		major_container.next_event_time = world.time + 1 MINUTES
		return kill()

	var/spawn_success = create_bingle_lords()
	if(!spawn_success)
		log_and_message_admins("Warning: Could not spawn any mobs for event Bingles")
		return kill()

/// Proc used to get candidates for bingle lords and spawn them
/datum/event/bingles/proc/create_bingle_lords()
	// Atom prototype for candidates poll
	var/mob/living/simple_animal/hostile/bingle/lord/spawn_bingle = /mob/living/simple_animal/hostile/bingle/lord
	var/list/candidates = SSghost_spawns.poll_candidates("Вы хотите занять роль Лорда Бинглов?", ROLE_BINGLE, TRUE, 30 SECONDS, source = spawn_bingle)
	if(!length(candidates))
		message_admins("Warning: No player volunteered to be a bingle lord!")
		return FALSE

	for(var/i in 1 to BINGLE_LORD_SPAWN_COUNT)
		if(!length(candidates))
			message_admins("Warning: Only [i-1] out of [BINGLE_LORD_SPAWN_COUNT] volunteered to be bingle lords!")
			return TRUE
		var/mob/candidate = pick_n_take(candidates)
		spawn_bingle_lord(candidate)
	return TRUE

/// Proc used to spawn a bingle lord out of a candidate
/datum/event/bingles/proc/spawn_bingle_lord(mob/candidate)
	var/turf/spawn_loc = pick(GLOB.xeno_spawn)
	var/mob/living/simple_animal/hostile/bingle/lord/bingle = new(spawn_loc)
	bingle.possess_by_player(candidate.key)
	bingle.add_datum_if_not_exist()
	log_and_message_admins("[bingle.key] has been made into a [bingle] by an event.")

#undef BINGLES_MINPLAYERS_TRIGGER
#undef BINGLE_LORD_SPAWN_COUNT
