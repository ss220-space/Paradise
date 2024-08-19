// Relays messages to msay
/datum/redis_callback/msay_in
	channel = "byond.msay"

/datum/redis_callback/msay_in/on_message(message)
	var/list/data = json_decode(message)
	if(data["source"] == CONFIG_GET(string/instance_id)) // Ignore self messages
		return
	for(var/client/C in GLOB.admins)
		if(check_rights(R_ADMIN|R_MOD|R_MENTOR, FALSE, C.mob))
			to_chat(C, "<span class='[check_rights(R_ADMIN, 0) ? "mentor_channel_admin" : "mentor_channel"]'>MENTOR: <small>[data["author"]]\[[data["source"]]\]</small>: <span class='message'>[html_encode(data["message"])]</span></span>", MESSAGE_TYPE_MENTORCHAT, confidential = TRUE)
