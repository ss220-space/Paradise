/datum/world_topic_handler/fixtts
	topic_key = "fixtts"
	requires_commskey = TRUE

/datum/world_topic_handler/fixtts/execute(list/input, key_valid)
	var/datum/tts_provider/ntts = SStts.tts_providers["nTTS"]
	log_debug("SStts.tts_providers\[nTTS].is_enabled = [ntts.is_enabled]")

	if(!ntts.is_enabled)
		ntts.is_enabled = TRUE
		ntts.failed_requests_limit += initial(ntts.failed_requests_limit)
		to_chat(world, span_announce("SERVER: провайдер nTTS в подсистеме SStts принудительно включен!"))
		return json_encode(list("success" = "SStts\[nTTS] was force enabled"))
	return json_encode(list("error" = "SStts\[nTTS] is already enabled"))
