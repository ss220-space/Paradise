// Relays messages to asay
/datum/redis_callback/asay_in
	channel = "byond.asay"

/datum/redis_callback/asay_in/on_message(message)
	var/list/data = json_decode(message)
	if(data["source"] == CONFIG_GET(string/instance_id)) // Ignore self messages
		return
	for(var/client/C in GLOB.admins)
		if(R_ADMIN & C.holder.rights)
			to_chat(C, "<span class='admin_channel'>ADMIN: <small>[data["author"]]\[[data["source"]]\]</small>: <span class='message'>[html_encode(data["message"])]</span></span>", MESSAGE_TYPE_ADMINCHAT, confidential = TRUE)
