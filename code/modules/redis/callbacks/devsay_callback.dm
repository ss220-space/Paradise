// Relays messages to devsay
/datum/redis_callback/devsay_in
	channel = "byond.devsay"

/datum/redis_callback/devsay_in/on_message(message)
	var/list/data = json_decode(message)
	if(data["source"] == CONFIG_GET(string/instance_id)) // Ignore self messages
		return

	var/emoji_msg = handleDiscordEmojis(html_encode(data["message"]))

	for(var/client/C in GLOB.admins)
		if(check_rights(R_ADMIN|R_VIEWRUNTIMES, FALSE, C.mob))
			to_chat(C, "<span class='dev_channel'>DEV: <small>[data["author"]]\[[data["source"]]\]</small>: <span class='message'>[emoji_msg]</span></span>",
				MESSAGE_TYPE_DEVCHAT, confidential = TRUE)
