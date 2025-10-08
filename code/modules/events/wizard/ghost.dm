/datum/event/wizard/ghost //The spook is real

/datum/event/wizard/ghost/start()
	var/msg = span_warning("Внезапно для вас все становится чрезвычайно очевидным...")
	set_observer_default_invisibility(0, msg)
