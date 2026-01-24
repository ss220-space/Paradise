ADMIN_VERB(call_shuttle, R_ADMIN, "Call Shuttle", "Force a shuttle call with additional modifiers.", ADMIN_CATEGORY_SHUTTLE)
	if(EMERGENCY_AT_LEAST_DOCKED)
		return

	var/confirm = tgui_alert(user, "You sure?", "Confirm", list("Yes", "No"))
	if(confirm != "Yes")
		return

	if(tgui_alert(user, "Set Shuttle Recallable (Select Yes unless you know what this does)", "Recallable?", list("Yes", "No")) == "Yes")
		SSshuttle.emergency.canRecall = TRUE
	else
		SSshuttle.emergency.canRecall = FALSE

	if(SSsecurity_level.get_current_level_as_number() >= SEC_LEVEL_RED)
		SSshuttle.emergency.request(coefficient = 0.5, redAlert = TRUE)
	else
		SSshuttle.emergency.request()

	BLACKBOX_LOG_ADMIN_VERB("Call Shuttle")
	log_admin("[key_name(user)] admin-called the emergency shuttle.")
	message_admins(span_adminnotice("[key_name_admin(user)] admin-called the emergency shuttle[SSshuttle.emergency.canRecall == TRUE ? "" : " (non-recallable)"]."))

ADMIN_VERB(cancel_shuttle, R_ADMIN, "Cancel Shuttle", "Recall the shuttle, regardless of circumstances.", ADMIN_CATEGORY_SHUTTLE)
	if(tgui_alert(user, "You sure?", "Confirm", list("Yes", "No")) != "Yes")
		return

	if(EMERGENCY_AT_LEAST_DOCKED)
		return

	if(SSshuttle.emergency.canRecall == FALSE)
		if(tgui_alert(user, "Shuttle is currently set to be nonrecallable. Recalling may break things. Respect Recall Status?", "Override Recall Status?", list("Yes", "No")) == "Yes")
			return
		else
			var/keepStatus = tgui_alert(user, "Maintain recall status on future shuttle calls?", "Maintain Status?", list("Yes", "No")) == "Yes" //Keeps or drops recallability
			SSshuttle.emergency.canRecall = TRUE // must be true for cancel proc to work
			SSshuttle.emergency.cancel()
			if(keepStatus)
				SSshuttle.emergency.canRecall = FALSE // restores original status
	else
		SSshuttle.emergency.cancel()

	BLACKBOX_LOG_ADMIN_VERB("Cancel Shuttle")
	log_admin("[key_name(user)] admin-recalled the emergency shuttle.")
	message_admins(span_adminnotice("[key_name_admin(user)] admin-recalled the emergency shuttle."))
