ADMIN_VERB(triple_ai, R_ADMIN, "Create AI Triumvirate", "", ADMIN_CATEGORY_EVENTS)

	if(SSticker.current_state > GAME_STATE_PREGAME)
		to_chat(user, "This option is currently only usable during pregame. This may change at a later date.")
		return

	if(SSjobs && SSticker)
		var/datum/job/job = SSjobs.GetJob(JOB_TITLE_AI)
		if(!job)
			to_chat(user, "Unable to locate the AI job")
			return
		if(SSticker.triai)
			SSticker.triai = FALSE
			to_chat(user, "Only one AI will be spawned at round start.")
			log_and_message_admins(span_notice("has toggled off triple AIs at round start."))
		else
			SSticker.triai = TRUE
			to_chat(user, "There will be an AI Triumvirate at round start.")
			log_and_message_admins(span_notice("has toggled on triple AIs at round start."))
	return
