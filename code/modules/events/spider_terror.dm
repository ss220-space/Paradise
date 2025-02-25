#define TS_HIGHPOP_TRIGGER 60
#define TS_MIDPOP_TRIGGER 50
#define TS_MINPLAYERS_TRIGGER 35

/datum/event/spider_terror
	announceWhen = 240

/datum/event/spider_terror/announce(false_alarm)
	if(false_alarm)
		GLOB.command_announcement.Announce("Вспышка биологической угрозы 3-го уровня зафиксирована на борту станции [station_name()]. Всему персоналу надлежит сдержать её распространение любой ценой!", "ВНИМАНИЕ: БИОЛОГИЧЕСКАЯ УГРОЗА.", 'sound/effects/siren-spooky.ogg')

/datum/event/spider_terror/start()
	// It is necessary to wrap this to avoid the event triggering repeatedly.
	INVOKE_ASYNC(src, PROC_REF(wrappedstart))

/datum/event/spider_terror/proc/wrappedstart()
	var/spider_type
	var/infestation_type
	var/spawncount
	var/player_count = num_station_players()
	if(player_count <= TS_MINPLAYERS_TRIGGER)
		var/datum/event_container/EC = SSevents.event_containers[EVENT_LEVEL_MAJOR]
		EC.next_event_time = world.time + (60 * 10)
		return kill()//we don't spawn spiders on lowpop. Instead, we reroll!
	else if(player_count >= TS_HIGHPOP_TRIGGER)
		infestation_type = pick(5, 6)
	else if(player_count >= TS_MIDPOP_TRIGGER)
		infestation_type = pick(3, 4)
	else
		infestation_type = pick(1, 2)
	switch(infestation_type)
		if(1)          //lowpop spawns
			spider_type = TERROR_DEFILER
			spawncount = 2
		if(2)
			spider_type = TERROR_PRINCESS
			spawncount = 2
		if(3)          //midpop spawns
			spider_type = TERROR_DEFILER
			spawncount = 3
		if(4)
			spider_type = TERROR_PRINCESS
			spawncount = 3
		if(5)          //highpop spawns
			spider_type = TERROR_QUEEN
			spawncount = 1
		if(6)
			spider_type = TERROR_PRINCE
			spawncount = 1

	var/successSpawn = create_terror_spiders(spider_type, spawncount)

	if(!successSpawn)
		log_and_message_admins("Warning: Could not spawn any mobs for event Terror Spiders")
		return kill()

#undef TS_MINPLAYERS_TRIGGER
#undef TS_HIGHPOP_TRIGGER
#undef TS_MIDPOP_TRIGGER
