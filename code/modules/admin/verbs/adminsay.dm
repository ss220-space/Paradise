#define SAY_ENABLED TRUE
#define SAY_DISABLED FALSE

GLOBAL_LIST_INIT(say_status, list(
	"msay" = SAY_ENABLED,
))

ADMIN_VERB(cmd_admin_say, R_ADMIN|R_MOD, "ASay", "Send a message to other admins", ADMIN_CATEGORY_HIDDEN, msg as text)
	msg = sanitize(copytext_char(msg, 1, MAX_MESSAGE_LEN))
	if(!msg)
		return

	// Do this up here before it gets sent to everyone & emoji'd
	if(SSredis.connected)
		var/list/data = list()
		data["author"] = user.ckey
		data["source"] = CONFIG_GET(string/instance_id)
		data["message"] = msg
		SSredis.publish("byond.asay", json_encode(data))

	msg = handleDiscordEmojis(msg)

	var/datum/say/asay = new(user.ckey, user.holder.rank, msg, world.timeofday)
	GLOB.asays += asay
	log_adminsay(msg, user)

	for(var/client/C in GLOB.admins)
		if(check_rights(R_ADMIN|R_MOD, FALSE, C.mob))
			// Lets see if this admin was pinged in the asay message
			if(findtext(msg, "@[C.ckey]") || findtext(msg, "@[C.key]")) // Check ckey and key, so you can type @AffectedArc07 or @affectedarc07
				SEND_SOUND(C, sound('sound/misc/ping.ogg'))
				msg = replacetext(msg, "@[C.ckey]", "<font color='red'>@[C.ckey]</font>")
				msg = replacetext(msg, "@[C.key]", "<font color='red'>@[C.key]</font>") // Same applies here. key and ckey.

			msg = span_emojienabled("[msg]")
			to_chat(C, span_admin_channel("ADMIN: [span_name("[key_name(user, 1)]")] ([admin_jump_link(user.mob)]): [span_message("[msg]")]"), MESSAGE_TYPE_ADMINCHAT, confidential = TRUE)

	BLACKBOX_LOG_ADMIN_VERB("Asay")

/client/proc/get_admin_say()
	if(check_rights(R_ADMIN|R_MOD, FALSE))
		var/msg = tgui_input_text(src, null, "asay \"text\"", encode = FALSE)
		SSadmin_verbs.dynamic_invoke_verb(usr, /datum/admin_verb/cmd_admin_say, msg)
	else if(check_rights(R_MENTOR))
		var/msg = tgui_input_text(src, null, "msay \"text\"", encode = FALSE)
		SSadmin_verbs.dynamic_invoke_verb(usr, /datum/admin_verb/cmd_mentor_say, msg)

ADMIN_VERB(cmd_mentor_say, R_ADMIN|R_MOD|R_MENTOR, "MSay", "Send a message to other mentors.", ADMIN_CATEGORY_HIDDEN, msg as text)
	msg = sanitize(copytext_char(msg, 1, MAX_MESSAGE_LEN))
	log_mentorsay(msg, user)
	var/datum/say/msay = new(user.ckey, user.holder.rank, msg, world.timeofday)
	GLOB.msays += msay
	if(!msg)
		return

	// Do this up here before it gets sent to everyone & emoji'd
	if(SSredis.connected)
		var/list/data = list()
		data["author"] = user.ckey
		data["source"] = CONFIG_GET(string/instance_id)
		data["message"] = msg
		SSredis.publish("byond.msay", json_encode(data))

	msg = handleDiscordEmojis(msg)

	for(var/client/client in GLOB.admins)
		if(check_rights(R_ADMIN|R_MOD|R_MENTOR, FALSE, client.mob))
			var/display_name = user.key
			if(user.holder.fakekey)
				if(client.holder && client.holder.rights & R_ADMIN)
					display_name = "[user.holder.fakekey]/([user.key])"
				else
					display_name = user.holder.fakekey
			msg = span_emojienabled("[msg]")
			to_chat(client, "<span class='[check_rights(R_ADMIN, FALSE) ? "mentor_channel_admin" : "mentor_channel"]'>MENTOR: [span_name("[display_name]")] ([admin_jump_link(user.mob)]): [span_message("[msg]")]</span>", MESSAGE_TYPE_MENTORCHAT, confidential = TRUE)

	BLACKBOX_LOG_ADMIN_VERB("MSay")

/client/proc/get_mentor_say()
	if(check_rights(R_ADMIN|R_MOD|R_MENTOR))
		var/msg = tgui_input_text(src, null, "msay \"text\"", encode = FALSE)
		SSadmin_verbs.dynamic_invoke_verb(usr, /datum/admin_verb/cmd_mentor_say, msg)

ADMIN_VERB(toggle_mentor_chat, R_ADMIN, "Toggle Mentor Chat", "Toggle whether mentors have access to the msay command.", ADMIN_CATEGORY_TOGGLES)
	var/enabling

	if(GLOB.say_status["msay"] == SAY_ENABLED)
		enabling = FALSE
		GLOB.say_status["msay"] = SAY_DISABLED
	else
		enabling = TRUE
		GLOB.say_status["msay"] = SAY_ENABLED

	for(var/client/client in GLOB.admins)
		if(check_rights(R_ADMIN|R_MOD, FALSE, client.mob))
			continue
		if(!check_rights(R_MENTOR, FALSE, client.mob))
			continue
		if(enabling)
			to_chat(client, "<b>Mentor chat has been enabled.</b> Use 'msay' to speak in it.")
		else
			to_chat(client, "<b>Mentor chat has been disabled.</b>")

	log_and_message_admins("toggled mentor chat [enabling ? "on" : "off"].")
	BLACKBOX_LOG_ADMIN_VERB("Toggle MSay")

ADMIN_VERB(cmd_dev_say, R_VIEWRUNTIMES|R_ADMIN, "Devsay", "Send a message to other developers.", ADMIN_CATEGORY_HIDDEN, msg as text)
	// Do this up here before it gets sent to everyone & emoji'd
	if(SSredis.connected)
		var/list/data = list()
		data["author"] = user.ckey
		data["source"] = CONFIG_GET(string/instance_id)
		data["message"] = msg
		SSredis.publish("byond.devsay", json_encode(data))

	msg = handleDiscordEmojis(copytext_char(sanitize(msg), 1, MAX_MESSAGE_LEN))

	if(!msg)
		return

	log_devsay(msg, user)
	var/datum/say/devsay = new(user.ckey, user.holder.rank, msg, world.timeofday)
	GLOB.devsays += devsay
	user.mob.create_log(OOC_LOG, "DEVSAY: [msg]")

	for(var/client/client in GLOB.admins)
		if(check_rights(R_VIEWRUNTIMES|R_ADMIN, FALSE, client.mob))
			var/display_name = user.key
			if(user.holder.fakekey)
				if(client.holder && client.holder.rights & R_ADMIN)
					display_name = "[user.holder.fakekey]/([user.key])"
				else
					display_name = user.holder.fakekey
			msg = span_emojienabled("[msg]")
			to_chat(client, "<span class='[check_rights(R_ADMIN, FALSE) ? "dev_channel_admin" : "dev_channel"]'>DEV: [span_name("[display_name]")] ([admin_jump_link(user.mob)]): [span_message("[msg]")]</span>", MESSAGE_TYPE_DEVCHAT, confidential = TRUE)

	BLACKBOX_LOG_ADMIN_VERB("Devsay")

/client/proc/get_dev_team_say()
	if(!check_rights(R_VIEWRUNTIMES|R_ADMIN))
		return

	var/msg = tgui_input_text(src, null, "devsay \"text\"", encode = FALSE)
	SSadmin_verbs.dynamic_invoke_verb(usr, /datum/admin_verb/cmd_dev_say, msg)

#undef SAY_ENABLED
#undef SAY_DISABLED
