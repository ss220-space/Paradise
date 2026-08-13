/datum/tts_provider/ntts
	name = "nTTS"
	writes_to_file = TRUE

/datum/tts_provider/ntts/request(text, datum/tts_seed/ntts/seed, datum/callback/proc_callback, output_file)
	if(throttle_check())
		return FALSE

	var/list/query = list(
		"speaker=[url_encode(seed.value)]",
		"text=[url_encode(text)]",
		"ext=ogg",
	)
	var/api_url = "[CONFIG_GET(string/tts_url_ntts)]?[query.Join("&")]"
	var/list/headers = list("Authorization" = "Bearer [CONFIG_GET(string/tts_token_ntts)]")

	var/partial_file = "[output_file][TTS_PARTIAL_SUFFIX]"
	rustg_file_write("", partial_file, "false")
	SShttp.create_async_request(RUSTG_HTTP_METHOD_GET, api_url, headers = headers, proc_callback = proc_callback, output_file = partial_file)

	return TRUE

/datum/tts_provider/ntts/process_response(datum/http_response/response)
	return TRUE
