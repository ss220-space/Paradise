/datum/controller/subsystem/shuttle/proc/lockdown_escape()
	emergencyNoEscape = TRUE

/datum/controller/subsystem/shuttle/proc/add_hostile_environment(environment)
	hostile_environment |= environment

/datum/controller/subsystem/shuttle/proc/remove_hostile_environment(environment, spec_sound)
	hostile_environment -= environment
	if(!hostile_environment.len)
		reload_shuttle(spec_sound = spec_sound, from_hostile = TRUE)

/datum/controller/subsystem/shuttle/proc/clear_hostile_environment()
	LAZYCLEARLIST(hostile_environment)

/datum/controller/subsystem/shuttle/proc/reload_shuttle(admin_called = FALSE, spec_sound = 'sound/misc/announce_dig.ogg', from_hostile = FALSE)
	if(emergency.mode == SHUTTLE_STRANDED)
		if(hostile_environment.len)
			if(!(admin_called && tgui_alert(usr, "Шаттл блокирован угрозами и не улетит, пока они не будут уничтожены. Вы можете удалить угрозы и позволить шаттлу улететь. Действие необратимо.", "Очистить шаттл от угроз?", list("Очистить", "Не очищать")) == "Очистить"))
				return FALSE
			clear_hostile_environment()
			from_hostile = TRUE

		emergency.mode = SHUTTLE_DOCKED
		emergency.timer = world.time + 3 MINUTES
		GLOB.priority_announcement.Announce("[from_hostile? "Угроза устранена" : "Блокировка снята"]. У вас есть 3 минуты, чтобы подняться на борт эвакуационного шаттла.", "Приоритетное оповещение.", spec_sound)
		return TRUE
	return TRUE

/datum/controller/subsystem/shuttle/proc/stop_lockdown()
	emergencyNoEscape = FALSE
