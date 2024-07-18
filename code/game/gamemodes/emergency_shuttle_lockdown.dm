/datum/controller/subsystem/shuttle/proc/lockdown_escape()
	emergencyNoEscape = TRUE

/datum/controller/subsystem/shuttle/proc/stop_lockdown()
	emergencyNoEscape = FALSE
	if(emergency.mode == SHUTTLE_STRANDED)
		emergency.mode = SHUTTLE_DOCKED
		emergency.timer = world.time
		GLOB.priority_announcement.Announce("Угроза устранена. У вас есть 3 минуты, чтобы подняться на борт эвакуационного шаттла.", "Приоритетное оповещение.")
