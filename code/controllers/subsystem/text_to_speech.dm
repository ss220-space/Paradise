SUBSYSTEM_DEF(tts)
	name = "Text-to-Speech"
	flags = SS_NO_FIRE
	init_order = INIT_ORDER_DEFAULT

	var/tts_wanted = 0
	var/tts_request_failed = 0
	var/tts_request_succeeded = 0
	var/tts_reused = 0
	var/list/tts_errors = list()
	var/tts_error_raw = ""

	var/is_enabled = TRUE

	var/list/tts_replacement_list = list(\
		"Тесла" = "Тэсла",
		"тесла" = "тэсла",
		"НТ" = "ЭнТэ",
		"трейзен" = "трэйзэн",
		"СМО" = "ЭсМэО",
		"ГП" = "ГэПэ",
		"РД" = "ЭрДэ",
		"ГСБ" = "ГэЭсБэ",
	)

	var/list/tts_seeds = list()

/datum/controller/subsystem/tts/stat_entry(msg)
	msg += "W:[tts_wanted] "
	msg += "F:[tts_request_failed] "
	msg += "S:[tts_request_succeeded] "
	msg += "R:[tts_reused] "
	..(msg)

/datum/controller/subsystem/tts/Initialize(start_timeofday)
	for(var/path in subtypesof(/datum/tts_seed))
		var/datum/tts_seed/seed = new path
		tts_seeds[seed.name] = seed
	return ..()

/datum/controller/subsystem/tts/proc/get_tts(mob/speaker = null, mob/listener = null, message, datum/tts_seed/seed = SStts.tts_seeds["Arthas"], is_local = TRUE)
	if(!is_enabled)
		return

	if(!message)
		return

	tts_wanted++

	var/datum/tts_provider/provider = seed.provider
	if(!provider.is_enabled)
		return

	var/dirty_text = message
	var/text = sanitize_tts_input(dirty_text)
	var/hash = rustg_hash_string(RUSTG_HASH_MD5, lowertext(text))
	var/filename = "sound/tts_cache/[seed.name]/[hash]"

	if(fexists("[filename].ogg"))
		tts_reused++
		playsound_tts(speaker, listener ? list(listener) : null, filename, is_local)

		return

	var/datum/callback/cb = CALLBACK(src, .proc/get_tts_callback, speaker, listener, filename, seed, is_local)
	provider.request(text, seed, cb)

	return

/datum/controller/subsystem/tts/proc/get_tts_callback(mob/speaker, mob/listener, filename, datum/tts_seed/seed, is_local, datum/http_response/response)
	var/datum/tts_provider/provider = seed.provider

	// Bail if it errored
	if(response.errored)
		message_admins("<span class='warning'>Error connecting to [provider.name] TTS API. Please inform a maintainer or server host.</span>")
		return

	if(response.status_code != 200)
		message_admins("<span class='warning'>Error performing [provider.name] TTS API request (Code: [response.status_code])</span>")
		tts_request_failed++
		if(response.status_code)
			if(tts_errors["[response.status_code]"])
				tts_errors["[response.status_code]"]++
			else
				tts_errors += "[response.status_code]"
				tts_errors["[response.status_code]"] = 1
		tts_error_raw = response.error
		return

	tts_request_succeeded++

	var/voice = provider.process_response(response)
	if(!voice)
		return

	rustg_file_write(voice, "[filename].ogg", "true")

	if(!config.tts_cache)
		addtimer(CALLBACK(src, .proc/cleanup_tts_file, "[filename].ogg"), 30 SECONDS)

	playsound_tts(speaker, listener ? list(listener) : null, filename, is_local)

/datum/controller/subsystem/tts/proc/cleanup_tts_file(filename)
	fdel(filename)

/datum/controller/subsystem/tts/proc/sanitize_tts_input(message)
	. = message
	. = trim_strip_html_properly(.)
	. = replace_characters(., tts_replacement_list)
	. = rustg_latin_to_cyrillic(.)

/proc/tts_cast(mob/listener, message, datum/tts_seed/seed)
	SStts.get_tts(null, listener, message, seed)

/proc/tts_broadcast(mob/speaker, message, datum/tts_seed/seed, is_local = TRUE)
	SStts.get_tts(speaker, null, message, seed, is_local)
