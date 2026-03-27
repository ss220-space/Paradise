// Relays messages to asay
/datum/redis_callback/asay_in
	channel = "byond.asay"

/datum/redis_callback/asay_in/on_message(message)
	var/list/data = json_decode(message)
	if(data["source"] == CONFIG_GET(string/instance_id)) // Ignore self messages
		return

	var/raw_msg = data["message"]

	for(var/client/client as anything in GLOB.admins)
		if(R_ADMIN & client.holder.rights)
			var/emoji_msg = raw_msg
			if(!CONFIG_GET(flag/disable_ooc_emoji))
				emoji_msg = handleDiscordEmojis(raw_msg, client)
			to_chat(client, span_admin_channel("ADMIN: <small>[data["author"]]\[[data["source"]]\]</small>: [span_message(emoji_msg)]"),
				MESSAGE_TYPE_ADMINCHAT, confidential = TRUE)
