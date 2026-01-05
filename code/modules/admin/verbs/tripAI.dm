/client/proc/triple_ai()
	set category = ADMIN_CATEGORY_EVENTS
	set name = "Create AI Triumvirate"

	if(SSticker.current_state > GAME_STATE_PREGAME)
		to_chat(usr, "This option is currently only usable during pregame. This may change at a later date.")
		return

	if(SSjobs && SSticker)
		var/datum/job/job = SSjobs.GetJob(JOB_TITLE_AI)
		if(!job)
			to_chat(usr, "Unable to locate the AI job")
			return
		if(SSticker.triai)
			SSticker.triai = FALSE
			to_chat(usr, "Only one AI will be spawned at round start.")
			log_and_message_admins(span_notice("has toggled off triple AIs at round start."))
		else
			SSticker.triai = TRUE
			to_chat(usr, "There will be an AI Triumvirate at round start.")
			log_and_message_admins(span_notice("has toggled on triple AIs at round start."))
	return
