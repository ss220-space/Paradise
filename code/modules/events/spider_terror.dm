#define TS_HIGHPOP_TRIGGER 60
#define TS_MIDPOP_TRIGGER 50
#define TS_MINPLAYERS_TRIGGER 35

/datum/event/spider_terror
	announceWhen = 240
	var/spawncount = 1
	var/successSpawn = FALSE	//So we don't make a command report if nothing gets spawned.

/datum/event/spider_terror/setup()
	announceWhen = rand(announceWhen, announceWhen + 30)
	spawncount = 1

/datum/event/spider_terror/announce(false_alarm)
	if(successSpawn || false_alarm)
		GLOB.command_announcement.Announce("Вспышка биологической угрозы 3-го уровня зафиксирована на борту станции [station_name()]. Всему персоналу надлежит сдержать её распространение любой ценой!", "ВНИМАНИЕ: БИОЛОГИЧЕСКАЯ УГРОЗА.", 'sound/effects/siren-spooky.ogg')
		if(!false_alarm)
			SSshuttle.emergency.cancel()
	else
		log_and_message_admins("Warning: Could not spawn any mobs for event Terror Spiders")

/datum/event/spider_terror/start()
	// It is necessary to wrap this to avoid the event triggering repeatedly.
	INVOKE_ASYNC(src, PROC_REF(wrappedstart))

/datum/event/spider_terror/proc/wrappedstart()
	var/spider_type
	var/infestation_type
	var/player_count = num_station_players()
	if(!can_start(player_count))
		var/datum/event_container/EC = SSevents.event_containers[EVENT_LEVEL_MAJOR]
		EC.next_event_time = world.time + (60 * 10)
		return	//we don't spawn spiders on lowpop. Instead, we reroll!
	if(player_count >= TS_HIGHPOP_TRIGGER)
		infestation_type = pick(5, 6)
	else if(player_count >= TS_MIDPOP_TRIGGER)
		infestation_type = pick(3, 4)
	else
		infestation_type = pick(1, 2)
	switch(infestation_type)
		if(1)          //lowpop spawns
			spider_type = /mob/living/simple_animal/hostile/poison/terror_spider/defiler
			spawncount = 2
		if(2)
			spider_type = /mob/living/simple_animal/hostile/poison/terror_spider/queen/princess
			spawncount = 2
		if(3)          //midpop spawns
			spider_type = /mob/living/simple_animal/hostile/poison/terror_spider/defiler
			spawncount = 3
		if(4)
			spider_type = /mob/living/simple_animal/hostile/poison/terror_spider/queen/princess
			spawncount = 3
		if(5)          //highpop spawns
			spider_type = /mob/living/simple_animal/hostile/poison/terror_spider/queen
			spawncount = 1
		if(6)
			spider_type = /mob/living/simple_animal/hostile/poison/terror_spider/prince
			spawncount = 1
	var/list/candidates = SSghost_spawns.poll_candidates("Вы хотите занять роль Паука Ужаса?", ROLE_TERROR_SPIDER, TRUE, 60 SECONDS, source = spider_type)
	if(length(candidates) < spawncount)
		message_admins("Warning: not enough players volunteered to be terrors. Could only spawn [length(candidates)] out of [spawncount]!")
	while(spawncount && length(candidates))
		var/mob/living/simple_animal/hostile/poison/terror_spider/S = new spider_type(pick(GLOB.xeno_spawn))
		var/mob/M = pick_n_take(candidates)
		S.key = M.key
		S.give_intro_text()
		spawncount--
		successSpawn = TRUE
		log_game("[S.key] has become [S].")


/datum/event/spider_terror/can_start(player_count)
	if(player_count > TS_MINPLAYERS_TRIGGER) // passed
		return TRUE

	if(..()) // forced
		log_and_message_admins("Event \"[type]\" launched bypassing the minimum players limit!")
		return TRUE

	log_and_message_admins("Random event attempted to spawn a terror spiders, but there were only [player_count]/[TS_MINPLAYERS_TRIGGER] players.")

	return FALSE


#undef TS_MINPLAYERS_TRIGGER
#undef TS_HIGHPOP_TRIGGER
#undef TS_MIDPOP_TRIGGER
