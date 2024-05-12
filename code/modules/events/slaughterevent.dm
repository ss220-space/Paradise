#define SLAUGHTER_MINPLAYERS 30
#define LAUGHTER_MINPLAYERS 30
#define SHADOW_MINPLAYERS 40

/datum/event/spawn_slaughter
	var/key_of_slaughter
	var/minplayers = SLAUGHTER_MINPLAYERS
	var/mob/living/simple_animal/demon/demon = /mob/living/simple_animal/demon/slaughter


/datum/event/spawn_slaughter/proc/get_slaughter()
	var/list/candidates = SSghost_spawns.poll_candidates("Вы хотите занять роль [initial(demon.name)]?", ROLE_DEMON, TRUE, source = demon)
	if(!length(candidates))
		kill()
		return

	var/mob/canidate = pick(candidates)
	key_of_slaughter = canidate.key

	if(!key_of_slaughter)
		kill()
		return

	var/datum/mind/player_mind = new /datum/mind(key_of_slaughter)
	player_mind.active = TRUE
	var/turf/spawn_loc = get_spawn_loc(player_mind.current)
	var/obj/effect/dummy/slaughter/holder = new /obj/effect/dummy/slaughter(spawn_loc)
	var/mob/living/simple_animal/demon/new_demon = new demon(holder)
	new_demon.holder = holder
	player_mind.transfer_to(new_demon)
	player_mind.assigned_role = ROLE_DEMON
	player_mind.special_role = SPECIAL_ROLE_DEMON
	SSticker.mode.demons |= player_mind
	message_admins("[key_name_admin(new_demon)] has been made into a [new_demon.name] by an event.")
	log_game("[key_name_admin(new_demon)] was spawned as a [new_demon.name] by an event.")


/datum/event/spawn_slaughter/proc/get_spawn_loc(mob/player)
	RETURN_TYPE(/turf)
	var/list/spawn_locs = list()
	for(var/thing in GLOB.landmarks_list)
		var/obj/effect/landmark/landmark = thing
		if(isturf(landmark.loc) && landmark.name == "revenantspawn")
			spawn_locs += landmark.loc
	if(!spawn_locs)	// If we can't find any good spots, try the carp spawns
		for(var/thing in GLOB.landmarks_list)
			var/obj/effect/landmark/landmark = thing
			if(isturf(landmark.loc) && landmark.name == "carpspawn")
				spawn_locs += landmark.loc
	if(!spawn_locs) //If we can't find a good place, just spawn at the player's location
		spawn_locs += get_turf(player)
	if(!spawn_locs) //If we can't find THAT, then give up
		kill()
		return
	return pick(spawn_locs)


/datum/event/spawn_slaughter/start()
	if(num_station_players() <= minplayers)
		var/datum/event_container/EC = SSevents.event_containers[EVENT_LEVEL_MAJOR]
		EC.next_event_time = world.time + (60 * 10)
		return	//we don't spawn demons on lowpop. Instead, we reroll!

	INVOKE_ASYNC(src, PROC_REF(get_slaughter))


/datum/event/spawn_slaughter/laughter
	demon = /mob/living/simple_animal/demon/slaughter/laughter
	minplayers = LAUGHTER_MINPLAYERS

/datum/event/spawn_slaughter/shadow
	demon = /mob/living/simple_animal/demon/shadow
	minplayers = SHADOW_MINPLAYERS


/datum/event/spawn_slaughter/shadow/get_spawn_loc()
	var/turf/spawn_loc = ..()
	for(var/turf/check in range(50, spawn_loc))
		if(check.get_lumcount()) // if the turf is not pitch black
			continue
		return check // return the first turf that is dark nearby.
	kill()

#undef SLAUGHTER_MINPLAYERS
#undef LAUGHTER_MINPLAYERS
#undef SHADOW_MINPLAYERS
