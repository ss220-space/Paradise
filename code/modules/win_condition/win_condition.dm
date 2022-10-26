GLOBAL_VAR(win_condition_timer_id)
GLOBAL_VAR(win_condition_forced_stop)

#define WIN_CONDITION_TIME 15 SECONDS
#define WIN_ROUND_END_TIME 15 SECONDS

GLOBAL_VAR_INIT(win_condition_blob, 2) // amount of blob structures to win
GLOBAL_VAR_INIT(blob_structures_station, 0)
GLOBAL_LIST_EMPTY(blob_cores_station)

/obj/structure/blob/Initialize(mapload)
	. = ..()
	if(is_station_level(z))
		GLOB.blob_structures_station++
		if(GLOB.blob_structures_station >= GLOB.win_condition_blob)
			start_win_condition("Blob")

/obj/structure/blob/Destroy()
	if(is_station_level(z))
		GLOB.blob_structures_station--
	. = ..()

/obj/structure/blob/core/Initialize(mapload)
	. = ..()
	if(is_station_level(z))
		GLOB.blob_cores_station += src
		SSshuttle.emergencyNoEscape = TRUE

/obj/structure/blob/core/Destroy()
	. = ..()
	if(src in GLOB.blob_cores_station)
		GLOB.blob_cores_station -= src
		if(!length(GLOB.blob_cores_station))
			resolve_win_condition()

GLOBAL_VAR_INIT(win_condition_terror_spider, 2) // amount of terror spiders to win
GLOBAL_LIST_EMPTY(terror_spider_alive_station)

/mob/living/simple_animal/hostile/poison/terror_spider/Initialize(mapload)
	. = ..()
	if(is_station_level(z))
		GLOB.terror_spider_alive_station += src
		SSshuttle.emergencyNoEscape = TRUE
		if(length(GLOB.terror_spider_alive_station) >= GLOB.win_condition_terror_spider)
			start_win_condition("Terror Spiders")

/mob/living/simple_animal/hostile/poison/terror_spider/death(gibbed)
	. = ..()
	if(src in GLOB.terror_spider_alive_station)
		GLOB.terror_spider_alive_station -= src
		if(!length(GLOB.terror_spider_alive_station))
			resolve_win_condition()

/mob/living/simple_animal/hostile/poison/terror_spider/Destroy()
	. = ..()
	if(src in GLOB.terror_spider_alive_station)
		GLOB.terror_spider_alive_station -= src
		if(!length(GLOB.terror_spider_alive_station))
			resolve_win_condition()

/* Waiting for aliens to be completed first
GLOBAL_VAR_INIT(win_condition_alien, 2) // amount of aliens to win
GLOBAL_LIST_EMPTY(alien_alive_station)
/mob/living/carbon/alien/Initialize(mapload)
	. = ..()
	if(is_station_level(z))
		GLOB.alien_alive_station += src
		SSshuttle.emergencyNoEscape = TRUE
		if(length(GLOB.alien_alive_station) >= GLOB.win_condition_alien)
			start_win_condition("Aliens")

/mob/living/carbon/alien/death(gibbed)
	. = ..()
	if(src in GLOB.alien_alive_station)
		GLOB.alien_alive_station -= src
		if(!length(GLOB.alien_alive_station))
			resolve_win_condition()

/mob/living/carbon/alien/Destroy()
	. = ..()
	if(src in GLOB.alien_alive_station)
		GLOB.alien_alive_station -= src
		if(!length(GLOB.alien_alive_station))
			resolve_win_condition()
*/

/proc/start_win_condition(hostile_name = "hostile environment")
	if(GLOB.win_condition_timer_id || GLOB.win_condition_forced_stop)
		return FALSE
	GLOB.priority_announcement.Announce("Обнаружена потеря контроля над ситуацией на станции [station_name()]. Проводится экстренное совещание, ожидайте ответ в близлежащие время.", "Central Command", 'sound/misc/notice2.ogg')
	GLOB.win_condition_timer_id = addtimer(CALLBACK(GLOBAL_PROC, .proc/execute_win_condition, hostile_name), WIN_CONDITION_TIME, TIMER_STOPPABLE)
	log_and_message_admins("<span class='userdanger'>Win condition timer has been started! Use Secrets in Admin panel to stop it.</span>")
	return TRUE

/proc/stop_win_condition()
	if(GLOB.win_condition_timer_id)
		log_and_message_admins("[usr] stopped the win condition.")
		deltimer(GLOB.win_condition_timer_id)
		GLOB.win_condition_timer_id = null

/proc/execute_win_condition(hostile_name = "hostile environment")
	var/obj/machinery/nuclearbomb/station_bomb
	for(var/obj/machinery/nuclearbomb/bomb in GLOB.machines)
		if(is_station_level(bomb.z))
			station_bomb = bomb
			break
	if(station_bomb)
		station_bomb.force_arm()
	else
		GLOB.priority_announcement.Announce("Станция выписана и является врагом корпорации НТ.", "Central Command", 'sound/misc/notice2.ogg')
		sleep(5 SECONDS)
		set_security_level("epsilon")
		sleep(WIN_ROUND_END_TIME)
		to_chat(world, "<B>Station was captured by \the [hostile_name]!</B>")
		SSticker.force_ending = TRUE

/proc/resolve_win_condition()
	if(GLOB.win_condition_timer_id)
		deltimer(GLOB.win_condition_timer_id)
		GLOB.win_condition_timer_id = null
	SSshuttle.emergencyNoEscape = FALSE
	if(SSshuttle.emergency.mode == SHUTTLE_STRANDED)
		SSshuttle.emergency.mode = SHUTTLE_DOCKED
		SSshuttle.emergency.timer = world.time
		GLOB.priority_announcement.Announce("Hostile environment resolved. You have 3 minutes to board the Emergency Shuttle.", "Priority Announcement", 'sound/AI/shuttledock.ogg')
	else
		GLOB.priority_announcement.Announce("Hostile environment resolved.", "Priority Announcement", 'sound/misc/notice2.ogg')

#undef WIN_CONDITION_TIME
#undef WIN_ROUND_END_TIME
