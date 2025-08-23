/client/proc/dsay(msg as text)
	set category = STATPANEL_ADMIN_ADMIN
	set name = "Dsay" //Gave this shit a shorter name so you only have to time out "dsay" rather than "dead say" to use it --NeoFite

	if(!check_rights(R_ADMIN|R_MOD))
		return

	if(!src.mob)
		return

	if(check_mute(ckey, MUTE_DEADCHAT))
		to_chat(src, "<span class='warning'>You cannot send DSAY messages (muted).</span>")
		return

	if(!(prefs.toggles & PREFTOGGLE_CHAT_DEAD))
		to_chat(src, "<span class='warning'>You have deadchat muted.</span>")
		return

	if(handle_spam_prevention(msg,MUTE_DEADCHAT))
		return

	var/stafftype = null

	if(check_rights(R_MENTOR, 0))
		stafftype = "MENTOR"

	if(check_rights(R_MOD, 0))
		stafftype = "MOD"

	if(check_rights(R_ADMIN, 0))
		stafftype = "ADMIN"

	msg = sanitize(copytext_char(msg, 1, MAX_MESSAGE_LEN))
	log_admin("[key_name(src)] : [msg]")

	if(!msg)
		return

	msg = handleDiscordEmojis(msg)

	var/prefix = "[stafftype] ([src.key])"
	if(holder.fakekey)
		prefix = "Administrator"
	say_dead_direct("<span class='name'>[prefix]</span> says, <span class='message'>\"[msg]\"</span>")

	BLACKBOX_LOG_ADMIN_VERB("Dsay")

/client/proc/get_dead_say()
	if(!check_rights(R_ADMIN|R_MOD))
		return
	var/msg = tgui_input_text(src, null, "dsay \"text\"", encode = FALSE)
	dsay(msg)
