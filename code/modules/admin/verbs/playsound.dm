GLOBAL_LIST_EMPTY(sounds_cache)

ADMIN_VERB(stop_global_admin_sounds, R_SOUNDS, "Stop Global Admin Sounds", "Stop all playing admin sounds.", ADMIN_CATEGORY_SOUNDS)
	var/sound/awful_sound = sound(null, repeat = 0, wait = 0, channel = CHANNEL_ADMIN)

	log_and_message_admins("stopped admin sounds.")
	for(var/mob/M in GLOB.player_list)
		M << awful_sound

ADMIN_VERB(play_sound, R_SOUNDS, "Play Global Sound", "Play a sound to all connected players.", ADMIN_CATEGORY_SOUNDS, S as sound)
	var/sound/uploaded_sound = sound(S, repeat = 0, wait = 1, channel = CHANNEL_ADMIN)
	uploaded_sound.priority = 250

	GLOB.sounds_cache += S

	if(alert("Are you sure?\nSong: [S]\nNow you can also play this sound using \"Play Server Sound\".", "Confirmation request" ,"Play", "Cancel") == "Cancel")
		return

	log_and_message_admins("played sound [S]")

	for(var/mob/M in GLOB.player_list)
		if(M.client.prefs.sound & SOUND_MIDI)
			if(isnewplayer(M) && (M.client.prefs.sound & SOUND_LOBBY))
				// M.stop_sound_channel(CHANNEL_LOBBYMUSIC)
				M.client?.tgui_panel?.stop_music()
			uploaded_sound.volume = 100 * M.client.prefs.get_channel_volume(CHANNEL_ADMIN)
			SEND_SOUND(M, uploaded_sound)

	BLACKBOX_LOG_ADMIN_VERB("Play Global Sound")

ADMIN_VERB(play_local_sound, R_SOUNDS, "Play Local Sound", "Plays a sound only you can hear.", ADMIN_CATEGORY_SOUNDS, sound as sound)
	log_and_message_admins("played a local sound [sound]")
	playsound(get_turf(user.mob), sound, 50, FALSE, 0)
	BLACKBOX_LOG_ADMIN_VERB("Play Local Sound")

ADMIN_VERB_CUSTOM_EXIST_CHECK(play_web_sound)
	return !!CONFIG_GET(string/invoke_youtubedl)

ADMIN_VERB(play_web_sound, R_SOUNDS, "Play Internet Sound", "Play a given internet sound to all players.", ADMIN_CATEGORY_SOUNDS)
	if(!user.tgui_panel || !SSassets.initialized)
		return

	var/ytdl = CONFIG_GET(string/invoke_youtubedl)
	if(!ytdl)
		to_chat(user, span_boldwarning("yt-dlp was not configured, action unavailable"), confidential = TRUE) //Check config.txt for the INVOKE_YOUTUBEDL value
		return

	var/web_sound_input = tgui_input_text(user, "Enter content URL (supported sites only, leave blank to stop playing)", "Play Internet Sound via yt-dlp", encode = FALSE)
	if(istext(web_sound_input))
		var/web_sound_path = ""
		var/web_sound_url = ""
		var/stop_web_sounds = FALSE
		var/list/music_extra_data = list()
		if(length(web_sound_input))
			web_sound_input = trim(web_sound_input)
			if(findtext(web_sound_input, ":") && !findtext(web_sound_input, GLOB.is_http_protocol))
				to_chat(user, span_boldwarning("Non-http(s) URIs are not allowed."), confidential = TRUE)
				to_chat(user, span_warning("For yt-dlp shortcuts like ytsearch: please use the appropriate full url from the website."), confidential = TRUE)
				return
			var/shell_scrubbed_input = shell_url_scrub(web_sound_input)
			var/list/output = world.shelleo("[ytdl] -x --audio-format mp3 --audio-quality 0 --geo-bypass --no-playlist -o \"cache/songs/%(id)s.%(ext)s\" --dump-single-json --no-simulate \"[shell_scrubbed_input]\"")
			var/errorlevel = output[SHELLEO_ERRORLEVEL]
			var/stdout = output[SHELLEO_STDOUT]
			var/stderr = output[SHELLEO_STDERR]
			if(!errorlevel)
				var/list/data
				try
					data = json_decode(stdout)
				catch(var/exception/e)
					to_chat(user, span_boldwarning("yt-dlp JSON parsing FAILED:"), confidential = TRUE)
					to_chat(user, span_warning("[e]: [stdout]"), confidential = TRUE)
					return

				if(data["url"])
					web_sound_path = "cache/songs/[data["id"]].mp3"
					web_sound_url = data["url"]
					var/title = "[data["title"]]"
					var/webpage_url = title
					if(data["webpage_url"])
						webpage_url = "<a href=\"[data["webpage_url"]]\">[title]</a>"
					var/mus_len = data["duration"] * 1 SECONDS
					music_extra_data["duration"] = DisplayTimeText(mus_len)
					SSticker.music_available = REALTIMEOFDAY + mus_len
					music_extra_data["link"] = data["webpage_url"]
					music_extra_data["artist"] = data["artist"]
					music_extra_data["upload_date"] = data["upload_date"]
					music_extra_data["album"] = data["album"]

					var/res = tgui_alert(user, "Показать игрокам название и ссылку?\n[title]",, list("Нет", "Да", "Отмена"))
					switch(res)
						if("Да")
							music_extra_data["title"] = data["title"]
						if("Нет")
							music_extra_data["link"] = "Song Link Hidden"
							music_extra_data["title"] = "Song Title Hidden"
							music_extra_data["artist"] = "Song Artist Hidden"
							music_extra_data["upload_date"] = "Song Upload Date Hidden"
							music_extra_data["album"] = "Song Album Hidden"
						if("Отмена")
							return

					var/anon = tgui_alert(user, "Показывать, кто запустил?", "Указывать себя?", list("Нет", "Да", "Отмена"))
					switch(anon)
						if("Yes")
							if(res == "Yes")
								to_chat(world, span_boldannounceooc("[user] запустил: [webpage_url]"), confidential = TRUE)
							else
								to_chat(world, span_boldannounceooc("[user] запустил музыку"), confidential = TRUE)
						if("No")
							if(res == "Yes")
								to_chat(world, span_boldannounceooc("Запущено админом: [webpage_url]"), confidential = TRUE)

					SSblackbox.record_feedback("nested tally", "played_url", 1, list("[user.ckey]", "[web_sound_input]"))
					log_admin("[key_name(user)] played web sound: [web_sound_input]")
					message_admins("[key_name(user)] played web sound: [web_sound_input]")
			else
				to_chat(user, span_boldwarning("yt-dlp URL retrieval FAILED:"), confidential = TRUE)
				to_chat(user, span_warning("[stderr]"), confidential = TRUE)

		else //pressed ok with blank
			log_admin("[key_name(user)] stopped web sound")
			message_admins("[key_name(user)] stopped web sound")
			web_sound_path = null
			stop_web_sounds = TRUE
			SSticker.music_available = 0

		if(stop_web_sounds)
			for(var/m in GLOB.player_list)
				var/mob/M = m
				var/client/C = M.client
				if(C.prefs.toggles & SOUND_MIDI)
					C.tgui_panel?.stop_music()
		else
			var/url = web_sound_url
			switch(CONFIG_GET(string/asset_transport))
				if(ASSET_TRANSPORT_WEBROOT)
					var/datum/asset/music/my_asset
					if(GLOB.cached_songs[web_sound_path])
						my_asset = GLOB.cached_songs[web_sound_path]
					else
						my_asset = new /datum/asset/music(web_sound_path)
						GLOB.cached_songs[web_sound_path] = my_asset
					url = my_asset.get_url()

			for(var/m in GLOB.player_list)
				var/mob/M = m
				var/client/C = M.client
				if(C.prefs.sound & SOUND_MIDI)
					C.tgui_panel?.play_music(url, music_extra_data)

	BLACKBOX_LOG_ADMIN_VERB("Play Internet Sound")

ADMIN_VERB(play_server_sound, R_SOUNDS, "Play Server Sound", "Send a sound to players.", ADMIN_CATEGORY_SOUNDS)
	var/list/sounds = world.file2list("sound/serversound_list.txt")
	sounds += GLOB.sounds_cache

	var/melody = tgui_input_list(user, "Select a sound from the server to play", "Server sound list", sounds)
	if(!melody)
		return

	SSadmin_verbs.dynamic_invoke_verb(user, /datum/admin_verb/play_sound, melody)
	BLACKBOX_LOG_ADMIN_VERB("Play Server Sound")

ADMIN_VERB(play_intercomm_sound, R_SOUNDS, "Play Sound via Intercomms", "Plays a sound at every intercomm on the station z level. Works best with small sounds.", ADMIN_CATEGORY_SOUNDS)
	var/A = alert(user, "This will play a sound at every intercomm, are you sure you want to continue? This works best with short sounds, beware.","Warning","Yep","Nope")
	if(A != "Yep")
		return

	var/list/sounds = world.file2list("sound/serversound_list.txt")
	sounds += GLOB.sounds_cache

	var/melody = tgui_input_list(user, "Select a sound from the server to play", "Server sound list", sounds)
	if(!melody)
		return

	var/cvol = 35
	var/inputvol = tgui_input_number(user, "How loud would you like this to be? (1-70)", "Volume", cvol, min_value = 1, max_value = 70)
	if(!inputvol)
		return
	if(inputvol)
		cvol = inputvol

	//Allows for override to utilize intercomms on all z-levels
	var/B = alert(user, "Do you want to play through intercomms on ALL Z-levels, or just the station?", "Override", "All", "Station")
	var/ignore_z = 0
	if(B == "All")
		ignore_z = 1

	//Allows for override to utilize incomplete and unpowered intercomms
	var/C = alert(user, "Do you want to play through unpowered / incomplete intercomms, so the crew can't silence it?", "Override", "Yep", "Nope")
	var/ignore_power = 0
	if(C == "Yep")
		ignore_power = 1

	for(var/O in GLOB.global_intercoms)
		var/obj/item/radio/intercom/I = O
		if(!is_station_level(I.z) && !ignore_z)
			continue
		if(!I.is_on() && !ignore_power)
			continue
		playsound(I, melody, cvol)

ADMIN_VERB(play_direct_mob_sound, R_SOUNDS, "Play Direct Mob Sound", "Play a sound directly to a mob.", ADMIN_CATEGORY_SOUNDS, sound as sound, mob/target in GLOB.mob_list)
	if(!target)
		target = tgui_input_list(user, "Choose a mob to play the sound to. Only they will hear it.", "Play Mob Sound", sort_names(GLOB.player_list))
	if(QDELETED(target))
		return
	log_admin("[key_name(user)] played a direct mob sound [sound] to [key_name_admin(target)].")
	message_admins("[key_name_admin(user)] played a direct mob sound [sound] to [ADMIN_LOOKUPFLW(target)].")
	SEND_SOUND(target, sound)
	BLACKBOX_LOG_ADMIN_VERB("Play Direct Mob Sound")
