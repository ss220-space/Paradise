GLOBAL_LIST_EMPTY(discord_ooc_cooldowns)

/datum/world_topic_handler/ooc
	topic_key = "ooc"
	requires_commskey = TRUE

/datum/world_topic_handler/ooc/execute(list/input, key_valid)
	var/sender_ckey = ckey(input["ooc"])
	if(!sender_ckey)
		return json_encode(list("error" = "No ckey provided"))

	if(!CONFIG_GET(flag/ooc_allowed))
		return json_encode(list("error" = "OOC is globally muted"))

	if(check_mute(sender_ckey, MUTE_OOC))
		return json_encode(list("error" = "You cannot use OOC (muted)"))

	if(GLOB.discord_ooc_cooldowns[sender_ckey] > world.time)
		return json_encode(list("error" = "You are sending messages too quickly"))

	var/msg = trim(sanitize(copytext_char(input["msg"], 1, MAX_MESSAGE_LEN)))
	if(!msg)
		return json_encode(list("error" = "Empty message"))

	if(findtext(msg, "byond://") || ((findtext(msg, "https://") || findtext(msg, "http://")) && !has_allowed_ooc_link(msg)))
		log_admin("[sender_ckey] has attempted to advertise in OOC from Discord: [msg]")
		message_admins("[sender_ckey] has attempted to advertise in OOC from Discord: [msg]")
		return json_encode(list("error" = "Advertising is not allowed"))

	GLOB.discord_ooc_cooldowns[sender_ckey] = world.time + OOC_COOLDOWN

	msg = handle_emojis(msg)
	log_ooc_discord(msg, sender_ckey)

	if(!CONFIG_GET(flag/disable_ooc_emoji))
		msg = span_emojienabled("[msg]")

	for(var/client/target in GLOB.clients)
		if(target.prefs.toggles & PREFTOGGLE_CHAT_OOC)
			to_chat(target, span_ooc("<span style='color:[GLOB.discord_ooc_colour];'>[span_prefix("OOC (Discord): ")]<em>[sender_ckey]:</em> [span_message(msg)]</span>"))

	return json_encode(list("success" = "Message sent"))
