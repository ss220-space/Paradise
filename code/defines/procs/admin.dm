// Always return "Something/(Something)", even if it's an error message.
/proc/key_name(whom, include_link = FALSE, type = null)
	return key_name_helper(whom, TRUE, include_link, type)

/proc/key_name_hidden(whom, include_link = FALSE, type = null)
	return key_name_helper(whom, FALSE, include_link, type)

/proc/key_name_helper(whom, include_name, include_link = FALSE, type = null)
	if(include_link != FALSE && include_link != TRUE)
		log_runtime(EXCEPTION("Key_name was called with an incorrect include_link [include_link]"))

	var/mob/M
	var/client/C
	var/key

	if(!whom)
		return "INVALID/(INVALID)"
	if(isclient(whom))
		C = whom
		M = C.mob
		key = C.key
	else if(ismob(whom))
		M = whom
		C = M.client
		key = M.key
	else if(istype(whom, /datum/mind))
		var/datum/mind/D = whom
		key = D.key
		M = D.current
		if(D.current)
			C = D.current.client
	else if(isdatum(whom))
		var/datum/D = whom
		return "INVALID/([D.type])"
	else if(istext(whom))
		return "AUTOMATED/([whom])"
	else
		return "INVALID/(INVALID)"

	. = ""

	if(key)
		if(C && C.holder && C.holder.fakekey && !include_name)
			if(include_link)
				. += "<a href='byond://?priv_msg=[C.getStealthKey()];type=[type]'>"
			. += "Administrator"
		else
			if(include_link && C)
				. += "<a href='byond://?priv_msg=[C.ckey];type=[type]'>"
			. += key

		if(include_link)
			if(C)	. += "</a>"
			else	. += " (DC)"
	else
		. += "INVALID"

	if(include_name)
		var/name = "INVALID"
		if(M)
			if(M.real_name)
				name = M.real_name
			else if(M.name)
				name = M.name

		. += "/([name])"

	return .

/proc/key_name_admin(whom)
	if(whom)
		var/datum/whom_datum = whom //As long as it's not null, will be close enough/has the proc UID() that is all that's needed
		var/message = "[key_name(whom, 1)]([ADMIN_QUE(whom_datum,"?")])[isAntag(whom) ? "<font color='red'>(A)</font>" : ""][isLivingSSD(whom) ? span_danger("(SSD!)") : ""] ([admin_jump_link(whom)])"
		return message

/proc/key_name_mentor(whom)
	// Same as key_name_admin, but does not include (?) or (A) for antags.
	var/message = "[key_name(whom, 1)] [isLivingSSD(whom) ? span_danger("(SSD!)") : ""] ([admin_jump_link(whom)])"
	return message

/proc/key_name_log(whom)
	// Key_name_admin, but does not include (?) or jump link - For logging purpose to reduce clutter while figuring out who is SSD and/or antag when being attacked. Also remove formatting since it is not displayed
	var/message = "[key_name(whom, 0)][isAntag(whom) ? "(ANTAG)" : ""][isLivingSSD(whom) ? "(SSD!)": ""]"
	return message

/proc/log_and_message_admins(message)
	log_admin("[key_name(usr)] " + message)
	message_admins("[key_name_admin(usr)] " + message)

/atom/proc/log_message(message, message_type, color = null, log_globally = TRUE, list/data)
	if(!log_globally)
		return

	var/log_text = "[key_name_and_tag(src)] [message] [loc_name(src)]"
	switch(message_type)
		/// ship both attack logs and victim logs to the end of round attack.log just to ensure we don't lose information
		if(LOG_ATTACK, LOG_VICTIM)
			log_attack(log_text, data)
		if(LOG_SAY)
			log_say(log_text, data)
		if(LOG_WHISPER)
			log_whisper(log_text, data)
		if(LOG_EMOTE)
			log_emote(log_text, data)
		if(LOG_DSAY)
			log_ghostsay(log_text, data)
		if(LOG_PDA)
			log_pda(log_text, data)
		if(LOG_CHAT)
			log_chat(log_text, data)
		//if(LOG_COMMENT)
		//	log_comment(log_text, data)
		//if(LOG_TELECOMMS)
		//	log_telecomms(log_text, data)
		//if(LOG_TRANSPORT)
		//	log_transport(log_text, data)
		//if(LOG_ECON)
		//	log_econ(log_text, data)
		if(LOG_OOC)
			log_ooc(log_text, data)
		if(LOG_ADMIN)
			log_admin(log_text, data)
		if(LOG_ADMIN_PRIVATE)
			log_admin_private(log_text, data)
		if(LOG_ASAY)
			log_adminsay(log_text, data)
		if(LOG_OWNERSHIP)
			log_game(log_text, data)
		if(LOG_GAME)
			log_game(log_text, data)
		//if(LOG_MECHA)
		//	log_mecha(log_text, data)
		//if(LOG_SHUTTLE)
		//	log_shuttle(log_text, data)
		//if(LOG_SPEECH_INDICATORS)
		//	log_speech_indicators(log_text, data)
		else
			stack_trace("Invalid individual logging type: [message_type]. Defaulting to [LOG_GAME] (LOG_GAME).")
			log_game(log_text, data)


/proc/key_name_and_tag(whom, include_link = null, include_name = TRUE)
	var/tag = "!tagless!" // whom can be null in key_name() so lets set this as a safety
	if(isatom(whom))
		var/atom/subject = whom
		tag = subject.tag
	return "[key_name(whom, include_link, include_name)] ([tag])"
