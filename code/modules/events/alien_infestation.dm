#define ALIEN_HIGHPOP_TRIGGER 60
#define ALIEN_MIDPOP_TRIGGER 40

/datum/event/alien_infestation
	announceWhen	= 400
	var/spawncount = 2
	var/list/playercount
	var/successSpawn = FALSE	//So we don't make a command report if nothing gets spawned.

/datum/event/alien_infestation/setup()
	announceWhen = rand(announceWhen, announceWhen + 50)

/datum/event/alien_infestation/announce(false_alarm)
	if(successSpawn || false_alarm)
		GLOB.event_announcement.Announce("Вспышка биологической угрозы 4-го уровня зафиксирована на борту станции [station_name()]. Всему персоналу надлежит сдержать её распространение любой ценой!", "ВНИМАНИЕ: БИОЛОГИЧЕСКАЯ УГРОЗА.", 'sound/effects/siren-spooky.ogg')
		if(!false_alarm)
			SSshuttle.emergency.cancel()
	else
		log_and_message_admins("Warning: Could not spawn any mobs for event Alien Infestation")

/datum/event/alien_infestation/start()
	INVOKE_ASYNC(src, PROC_REF(wrappedstart))
	// It is necessary to wrap this to avoid the event triggering repeatedly.

/datum/event/alien_infestation/proc/wrappedstart()
	var/list/vents = get_valid_vent_spawns(exclude_mobs_nearby = TRUE, exclude_visible_by_mobs = TRUE)
	playercount = num_station_players() //grab playercount when event starts not when game starts
	if(playercount <= ALIEN_MIDPOP_TRIGGER)
		spawn_vectors(vents, playercount)
		return
	if(playercount >= ALIEN_HIGHPOP_TRIGGER) //spawn with 4 if highpop
		spawncount = 4
	var/list/candidates = SSghost_spawns.poll_candidates("Вы хотите сыграть за Чужого?", ROLE_ALIEN, TRUE, source = /mob/living/carbon/alien/larva)
	var/first_spawn = TRUE
	while(spawncount && length(vents) && length(candidates))
		var/obj/vent = pick_n_take(vents)
		var/mob/C = pick_n_take(candidates)
		if(C)
			GLOB.respawnable_list -= C.client
			var/mob/living/carbon/alien/larva/new_xeno = new(vent.loc)
			new_xeno.evolution_points += (0.75 * new_xeno.max_evolution_points)	//event spawned larva start off almost ready to evolve.
			new_xeno.key = C.key

			if(first_spawn)
				new_xeno.queen_maximum++
				first_spawn = FALSE

			if(SSticker && SSticker.mode)
				SSticker.mode.xenos += new_xeno.mind

			spawncount--
			successSpawn = TRUE
			log_game("[new_xeno.key] has become [new_xeno].")


/datum/event/alien_infestation/proc/spawn_vectors(list/vents, playercount)
	spawncount = 1
	var/list/candidates = SSghost_spawns.poll_candidates("Вы хотите сыграть за Чужого Вектора?", ROLE_ALIEN, TRUE, source = /mob/living/carbon/alien/humanoid/hunter/vector)
	var/first_spawn = TRUE
	while(spawncount && length(vents) && length(candidates))
		var/obj/vent = pick_n_take(vents)
		var/mob/C = pick_n_take(candidates)
		if(C)
			GLOB.respawnable_list -= C.client
			var/mob/living/carbon/alien/humanoid/hunter/vector/new_xeno = new(vent.loc)
			new_xeno.key = C.key

			if(first_spawn)
				new_xeno.queen_maximum++
				first_spawn = FALSE

			if(SSticker && SSticker.mode)
				SSticker.mode.xenos += new_xeno.mind

			spawncount--
			successSpawn = TRUE
			log_game("[new_xeno.key] has become [new_xeno].")


#undef ALIEN_HIGHPOP_TRIGGER
#undef ALIEN_MIDPOP_TRIGGER
