ADMIN_VERB(set_ticklag, R_DEBUG, "Set Ticklag", "Sets a new tick lag. Recommend you don't mess with this too much! Stable, time-tested ticklag value is 0.9", ADMIN_CATEGORY_DEBUG)
	var/newtick = tgui_input_number(user, "Sets a new tick lag. Please don't mess with this too much! The stable, time-tested ticklag value is 0.9", "Lag of Tick", world.tick_lag, , round_value = FALSE)
	//I've used ticks of 2 before to help with serious singulo lags
	if(newtick && newtick <= 2 && newtick > 0)
		log_and_message_admins("has modified world.tick_lag to [newtick]")
		world.tick_lag = newtick
		BLACKBOX_LOG_ADMIN_VERB("Set Ticklag")
	else
		to_chat(user, span_warning("Error: ticklag(): Invalid world.ticklag value. No changes made."))

