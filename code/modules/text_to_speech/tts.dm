GLOBAL_VAR_INIT(tts_wanted, 0)
GLOBAL_VAR_INIT(tts_request_failed, 0)
GLOBAL_VAR_INIT(tts_request_succeeded, 0)
GLOBAL_VAR_INIT(tts_reused, 0)

GLOBAL_LIST_EMPTY(tts_errors)
GLOBAL_VAR_INIT(tts_error_raw, "")

GLOBAL_LIST_INIT(tts_seeds, list(
		"arthas" = list("value" = "arthas", "category" = "any", "gender" = "male"),
		"kelthuzad" = list("value" = "kelthuzad", "category" = "any", "gender" = "male"),
		"anubarak" = list("value" = "anubarak", "category" = "any", "gender" = "male"),
		"thrall" = list("value" = "thrall", "category" = "any", "gender" = "male"),
		"grunt" = list("value" = "grunt", "category" = "any", "gender" = "male"),
		"cairne" = list("value" = "cairne", "category" = "any", "gender" = "male"),
		"rexxar" = list("value" = "rexxar", "category" = "any", "gender" = "male"),
		"uther" = list("value" = "uther", "category" = "any", "gender" = "male"),
		"jaina" = list("value" = "jaina", "category" = "any", "gender" = "male"),
		"kael" = list("value" = "kael", "category" = "any", "gender" = "male"),
		"maiev" = list("value" = "maiev", "category" = "any", "gender" = "male"),
		"naisha" = list("value" = "naisha", "category" = "any", "gender" = "male"),
		"tyrande" = list("value" = "tyrande", "category" = "any", "gender" = "male"),
		"furion" = list("value" = "furion", "category" = "any", "gender" = "male"),
		"illidan" = list("value" = "illidan", "category" = "any", "gender" = "male"),
		"ladyvashj" = list("value" = "ladyvashj", "category" = "any", "gender" = "male"),
		"narrator" = list("value" = "narrator", "category" = "any", "gender" = "male"),
		"medivh" = list("value" = "medivh", "category" = "any", "gender" = "male"),
		"villagerm" = list("value" = "villagerm", "category" = "any", "gender" = "male"),
		))

// var/list/tts_seeds = list()

// /proc/init_tts_directories()
// 	if(!fexists("config/tts_seeds.txt"))
// 		return

// 	for(var/i in file2list("config/tts_seeds.txt"))
// 		if(!LAZYLEN(i) || (copytext(i, 1, 2) == "#"))
// 			continue

// 		var/list/line = splittext_char(i, "=")
// 		if(!LAZYLEN(line))
// 			continue

// 		var/seed_name = line[1]
// 		var/seed_value = line[2]
// 		var/seed_category = line[3]
// 		var/seed_gender_restriction = line[4]

// 		tts_seeds += seed_name
// 		tts_seeds[seed_name] = list("value" = seed_value, "category" = seed_category, "gender" = seed_gender_restriction)

// 		rustg_file_write("[seed_value]", "sound/tts_cache/[seed_name]/seed.txt", "false")
// 		rustg_file_write("[seed_value]", "sound/tts_scrambled/[seed_name]/seed.txt", "false")

/proc/get_tts(message, seed = TTS_SEED_DEFAULT_MALE, datum/language/language=null)
	GLOB.tts_wanted++

	var/text = ""
	var/hash = ""
	if(language)
		text = sanitize_tts_input(language.scramble(message))
		hash = rustg_hash_string(RUSTG_HASH_MD5, text)
		. = "sound/tts_scrambled/[seed]/[language.name]_[hash].ogg"
	else
		text = sanitize_tts_input(message)
		hash = rustg_hash_string(RUSTG_HASH_MD5, text)
		. = "sound/tts_cache/[seed]/[hash].ogg"

	if(fexists(.))
		GLOB.tts_reused++
		return

	var/seed_value = GLOB.tts_seeds[seed] ? GLOB.tts_seeds[seed]["value"] : seed
	var/api_url = "https://api.silero.ai/voice"

	var/list/req_body = list()
	req_body["api_token"] = tts_token
	req_body["text"] = text
	req_body["sample_rate"] = 48000
	req_body["ssml"] = FALSE
	req_body["speaker"] = seed_value
	req_body["lang"] = "ru"
	req_body["remote_id"] = ""
	req_body["put_accent"] = TRUE
	req_body["put_yo"] = FALSE
	req_body["symbol_durs"] = list()
	req_body["format"] = "ogg"
	req_body["word_ts"] = FALSE
	var/json_body = json_encode(req_body)
	log_debug(json_body)

	// var/datum/callback/cb = CALLBACK(src, /datum/.proc/get_tts_callback, hash, seed, language)
	// SShttp.create_async_request(RUSTG_HTTP_METHOD_POST, api_url, json_encode(req_body), list("content-type" = "application/json"), cb)

	var/datum/http_request/req = new()
	req.prepare(RUSTG_HTTP_METHOD_POST, api_url, json_body, list("content-type" = "application/json"))
	req.begin_async()
	UNTIL(req.is_complete())
	var/datum/http_response/response = req.into_response()

	// var/list/log_data = list()
	// log_data += "BEGIN ASYNC RESPONSE (ID: [req.id])"
	// if(response.errored)
	// 	log_data += "\t ----- RESPONSE ERRROR -----"
	// 	log_data += "\t [response.error]"
	// else
	// 	log_data += "\tResponse status code: [response.status_code]"
	// 	log_data += "\tResponse body: [response.body]"
	// 	log_data += "\tResponse headers: [json_encode(response.headers)]"
	// log_data += "END ASYNC RESPONSE (ID: [req.id])"
	// WRITE_LOG(GLOB.http_log, log_data.Join("\n[GLOB.log_end]"))

	// Bail if it errored
	if(response.errored)
		message_admins("<span class='warning'>Error connecting to Silero TTS API. Please inform a maintainer or server host.</span>")
		return null

	if(response.status_code != 200)
		message_admins("<span class='warning'>Error performing Silero TTS API request (Code: [response.status_code])</span>")
		GLOB.tts_request_failed++
		if(response.status_code)
			if(GLOB.tts_errors["[response.status_code]"])
				GLOB.tts_errors["[response.status_code]"]++
			else
				GLOB.tts_errors += "[response.status_code]"
				GLOB.tts_errors["[response.status_code]"] = 1
		GLOB.tts_error_raw = req._raw_response
		return null

	GLOB.tts_request_succeeded++

	var/data = json_decode(response.body)
	// log_debug(response.body)

	for(var/voice in data["results"])
		// log_debug(voice["audio"])
		rustg_file_write(voice["audio"], ., "true")

	//var/sha1 = data["original_sha1"]

	if(!config.tts_cache)
		addtimer(CALLBACK(GLOBAL_PROC, /proc/cleanup_tts_file, .), 30 SECONDS)

/proc/tts_cast(mob/listener, message, seed)
	var/voice = get_tts(message, seed)
	if(voice)
		playsound_tts(null, list(listener), voice, null, null, TRUE)

/proc/tts_broadcast(mob/speaker, message, seed, datum/language/language)
	var/voice = get_tts(message, seed)
	var/voice_scrambled
	if(voice)
		if(language)
			voice_scrambled = get_tts(message, seed, language)
		playsound_tts(speaker, null, voice, voice_scrambled, language, TRUE)

/proc/cleanup_tts_file(file)
	fdel(file)

/proc/sanitize_tts_input(message)
	. = message
