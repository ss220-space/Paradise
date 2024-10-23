#define REVENANT_SPAWN_THRESHOLD 10

/datum/event/revenant
	var/key_of_revenant


/datum/event/revenant/proc/get_revenant(var/end_if_fail = 0)
	if(!can_start())
		return

	spawn()
		var/list/candidates = SSghost_spawns.poll_candidates("Do you want to play as a revenant?", ROLE_REVENANT, TRUE, source = /mob/living/simple_animal/revenant)
		if(!candidates.len)
			key_of_revenant = null
			kill()
			return
		var/mob/C = pick(candidates)
		key_of_revenant = C.key

		if(!key_of_revenant)
			kill()
			return

		var/datum/mind/player_mind = new /datum/mind(key_of_revenant)
		player_mind.active = 1
		var/list/spawn_locs = list()
		for(var/obj/effect/landmark/L in GLOB.landmarks_list)
			if(isturf(L.loc))
				switch(L.name)
					if("revenantspawn")
						spawn_locs += L.loc
		if(!spawn_locs) //If we can't find any revenant spawns, try the carp spawns
			spawn_locs += GLOB.carplist
		if(!spawn_locs) //If we can't find either, just spawn the revenant at the player's location
			spawn_locs += get_turf(player_mind.current)
		if(!spawn_locs) //If we can't find THAT, then just retry
			kill()
			return
		var/mob/living/simple_animal/revenant/revvie = new /mob/living/simple_animal/revenant/(pick(spawn_locs))
		player_mind.transfer_to(revvie)
		player_mind.assigned_role = SPECIAL_ROLE_REVENANT
		player_mind.special_role = SPECIAL_ROLE_REVENANT
		SSticker.mode.traitors |= player_mind
		message_admins("[key_name_admin(revvie)] has been made into a revenant by an event.")
		add_game_logs("was spawned as a revenant by an event.", revvie)

/datum/event/revenant/start()
	get_revenant()

/datum/event/revenant/can_start()
	var/deadMobs = 0
	for(var/mob/M in GLOB.dead_mob_list)
		deadMobs++

	//it's never FALSE, because roundstart amount of deadmobs ~40 i guess..
	if(deadMobs >= REVENANT_SPAWN_THRESHOLD)
		return TRUE

	if(..()) // forced
		log_and_message_admins("Event \"[type]\" launched bypassing the minimum deadmobs limits!")
		return TRUE

	log_and_message_admins("Random event attempted to spawn a revenant, but there were only [deadMobs]/[REVENANT_SPAWN_THRESHOLD] dead mobs.")

	return FALSE
