/datum/controller
	/// Display name of the controller, shown in stat panel and logs.
	var/name

/// Called once on controller creation to perform setup work.
/datum/controller/proc/Initialize()
	return

/// Cleanup actions performed on world shutdown.
/datum/controller/proc/Shutdown()
	return

/// Called when we enter dmm_suite.load_map.
/datum/controller/proc/StartLoadingMap()
	return

/// Called when we exit dmm_suite.load_map.
/datum/controller/proc/StopLoadingMap()
	return

/// Called when the controller is being restored after a runtime, used to salvage state from the previous instance.
/datum/controller/proc/Recover()
	return

/// Returns the line shown for this controller in the stat panel; override to customize, call parent.
/datum/controller/proc/stat_entry(msg)
	SHOULD_CALL_PARENT(TRUE)
	SHOULD_NOT_SLEEP(TRUE)
	return msg

/// Standardized method for tracking startup times.
/datum/controller/proc/log_startup_progress(message)
	Master.last_init_info = "([name]): [message]"
	to_chat(world, span_danger("<small>\[[name]\]</small> [message]"), MESSAGE_TYPE_DEBUG, confidential = TRUE)
	log_world("\[[name]] [message]")
