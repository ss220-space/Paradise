#define SPACE_DRAGON_SPAWN_THRESHOLD 55


/datum/event/space_dragon
	announceWhen = 45
	var/successSpawn = FALSE	//So we don't make a command report if nothing gets spawned.


/datum/event/space_dragon/announce(false_alarm)
	if(successSpawn || false_alarm)
		GLOB.command_announcement.Announce("Зафиксирован большой поток органической энергии вблизи станции [station_name()]. Пожалуйста, ожидайте.", "ВНИМАНИЕ: НЕОПОЗНАННЫЕ ФОРМЫ ЖИЗНИ.")
	else
		log_and_message_admins("Warning: Could not spawn any mobs for event Space Dragon")


/datum/event/space_dragon/start()
	var/player_count = num_station_players()
	if(player_count < SPACE_DRAGON_SPAWN_THRESHOLD)
		log_and_message_admins("Random event attempted to spawn a space dragon, but there were only [player_count]/[SPACE_DRAGON_SPAWN_THRESHOLD] players.")
		var/datum/event_container/EC = SSevents.event_containers[EVENT_LEVEL_MAJOR]
		EC.next_event_time = world.time + (60 * 10)
		return
	// It is necessary to wrap this to avoid the event triggering repeatedly.
	INVOKE_ASYNC(src, PROC_REF(wrapped_start))


/datum/event/space_dragon/proc/wrapped_start()
	var/list/candidates = SSghost_spawns.poll_candidates("Вы хотите занять роль Космического Дракона?", ROLE_SPACE_DRAGON, TRUE, source = /mob/living/simple_animal/hostile/space_dragon)
	if(!length(candidates))
		log_and_message_admins("Warning: nobody volunteered to become a Space Dragon!")
		kill()
		return
	var/mob/living/simple_animal/hostile/space_dragon/space_dragon = new (pick(GLOB.carplist))
	var/mob/candidate = pick(candidates)
	space_dragon.key = candidate.key
	space_dragon.mind.add_antag_datum(/datum/antagonist/space_dragon)
	playsound(space_dragon, 'sound/magic/ethereal_exit.ogg', 50, TRUE, -1)
	log_and_message_admins("[ADMIN_LOOKUPFLW(space_dragon)] has been made into a Space Dragon by an event.")
	log_game("[space_dragon.key] was spawned as a Space Dragon by an event.")
	successSpawn = TRUE


#undef SPACE_DRAGON_SPAWN_THRESHOLD
