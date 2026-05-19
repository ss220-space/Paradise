//uncomment to show traffic
// #define LOG_TRAFFIC

/datum/controller/subsystem/voicechat/proc/test_library()
	var/text = "hello world"
	var/out = call_ext(get_library_path(), "byond:Echo")(text)
	var/confirmed = (out == text)
	return confirmed


/datum/controller/subsystem/voicechat/proc/get_library_path()
	if(world.system_type == MS_WINDOWS)
		return "voicechat/pipes/windows/byondsocket"
	else
		return "voicechat/pipes/unix/byondsocket"


/proc/json_encode_sanitize(list/data)
	. = json_encode(data)
	//NOT in: alphanumeric, ", {}, :, commas, spaces, []
	var/static/regex/r = new/regex(@'[^\w"{}:,\s\[\]]', "g")
	. = r.Replace(., "")
	. = replacetext(., "\\", "\\\\")
	return .


/datum/controller/subsystem/voicechat/proc/send_json(list/data)
	var/json = json_encode_sanitize(data)
	#ifdef LOG_TRAFFIC
	message_admins("BYOND: [json]")
	#endif
	call_ext(get_library_path(), "byond:SendJSON")(json)


/datum/controller/subsystem/voicechat/proc/handle_topic(T, addr)
	//sanity check
	if(addr != "127.0.0.1")
		return

	var/list/data = json_decode(T)
	if(data["error"])
		message_admins(T)
		return

	#ifdef LOG_TRAFFIC
	message_admins("NODE: [T]")
	#endif

	if(data["node_started"])
		on_node_start()
		return


	if(data["pong"])
		world.log << "started: [data["time"]] round trip: [world.timeofday] approx: [world.timeofday -  data["time"]] x 1/10 seconds, data: [data["pong"]]"
		return

	if(data["confirmed"])
		confirm_userCode(data["confirmed"])
		return

	if(data["voice_activity"])
		toggle_active(data["voice_activity"], data["active"])
		return

	if(data["disconnect"])
		disconnect(userCode = data["disconnect"])

	if(data["ice_failed"])
		on_ice_failed(userCode = data["ice_failed"])
		return
