///This is a subsystem, which helps to process game modes through time.
SUBSYSTEM_DEF(game_events)
	name = "Game events"
	wait = 5 MINUTES
	cpu_display = SS_CPUDISPLAY_LOW
	offline_implications = "Timed Gamemode events and other events won't be processed. No immediate action is needed."
	ss_id = "game_modes"
	init_order = INIT_ORDER_GAME_EVENTS
	var/list/processing = list()

/datum/controller/subsystem/game_events/Initialize()
	return

/datum/controller/subsystem/game_events/proc/add_to_process(datum/event)
	if(!istype(event))
		return FALSE
	processing |= event
	return TRUE

/datum/controller/subsystem/game_events/fire(resumed)
	for(var/datum/event as anything in processing)
		if(event.process() == PROCESS_KILL)
			processing -= event


