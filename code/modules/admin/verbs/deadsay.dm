ADMIN_VERB(dsay, R_ADMIN|R_MOD, "DSay", "Speak to the dead.", ADMIN_CATEGORY_GAME, msg as text)
	if(!user.mob)
		return

	if(check_mute(user.ckey, MUTE_DEADCHAT))
		to_chat(user, span_danger("You cannot send DSAY messages (muted)."), confidential = TRUE)
		return

	if(!(user.prefs.toggles & PREFTOGGLE_CHAT_DEAD))
		to_chat(user, span_danger("You have deadchat muted."), confidential = TRUE)
		return

	if(user.handle_spam_prevention(msg, MUTE_DEADCHAT))
		return

	var/stafftype = null

	if(check_rights(R_MENTOR, FALSE))
		stafftype = "MENTOR"

	if(check_rights(R_MOD, FALSE))
		stafftype = "MOD"

	if(check_rights(R_ADMIN, FALSE))
		stafftype = "ADMIN"

	msg = sanitize(copytext_char(msg, 1, MAX_MESSAGE_LEN))
	log_admin("[key_name(user)] : [msg]")

	if(!msg)
		return

	msg = handleDiscordEmojis(msg)

	var/prefix = "[stafftype] ([user.key])"
	if(user.holder.fakekey)
		prefix = "Administrator"
	say_dead_direct("[span_name(prefix)] says, [span_message("\"[msg]\"")]")

	BLACKBOX_LOG_ADMIN_VERB("Dsay")

/client/proc/get_dead_say()
	var/msg = tgui_input_text(src, null, "dsay \"text\"", encode = FALSE)
	if(isnull(msg))
		return
	SSadmin_verbs.dynamic_invoke_verb(usr, /datum/admin_verb/dsay, msg)
