///This is a subsystem, which helps to process game modes through time.
SUBSYSTEM_DEF(game_events)
	name = "Game events"
	wait = 5 MINUTES

	var/list/processing = list()

/datum/controller/subsystem/game_events/Initialize()
	return SS_INIT_SUCCESS

/datum/controller/subsystem/game_events/proc/add_to_process(datum/event)
	if(!istype(event))
		return FALSE
	processing |= event
	return TRUE

/datum/controller/subsystem/game_events/fire(resumed)
	for(var/datum/event as anything in processing)
		if(event.process() == PROCESS_KILL)
			processing -= event

