/datum/tts_provider
	var/name = "STUB"
	var/is_enabled = TRUE

/datum/tts_provider/proc/request(text, datum/tts_seed/seed, datum/callback/proc_callback)
	return TRUE

/datum/tts_provider/proc/process_response(datum/http_response/response)
	return null

