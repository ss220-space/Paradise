ADMIN_VERB(play_sound, R_SOUNDS, "Play Global Sound", "Play a sound to all connected players.", ADMIN_CATEGORY_SOUNDS, sound as sound)
	var/freq = 1
	var/vol = tgui_input_number(user, "What volume would you like the sound to play at?", max_value = 100)
	if(!vol)
		return
	vol = clamp(vol, 1, 100)

	var/sound/admin_sound = new
	admin_sound.file = sound
	admin_sound.priority = 250
	admin_sound.channel = CHANNEL_ADMIN
	admin_sound.frequency = freq
	admin_sound.wait = 1
	admin_sound.repeat = FALSE
	admin_sound.status = SOUND_STREAM
	admin_sound.volume = vol

	var/res = tgui_alert(user, "Show the title of this song to the players?", "Play Sound", list("Yes", "No", "Cancel"))
	switch(res)
		if("Yes")
			to_chat(world, span_announce(span_bold("An admin played: [sound]")), confidential = TRUE)
		if("Cancel")
			return

	log_admin("[key_name(user)] played sound [sound]")
	message_admins("[key_name_admin(user)] played sound [sound]")

	for(var/mob/target in GLOB.player_list)
		var/client/target_client = target.client
		if(!(target_client.prefs.sound & SOUND_MIDI))
			continue
		if(isnewplayer(target) && (target_client.prefs.sound & SOUND_LOBBY))
			target_client.tgui_panel?.stop_music()
		admin_sound.volume = vol * target_client.prefs.get_channel_volume(CHANNEL_ADMIN)
		SEND_SOUND(target, admin_sound)

	BLACKBOX_LOG_ADMIN_VERB("Play Global Sound")

ADMIN_VERB(play_local_sound, R_SOUNDS, "Play Local Sound", "Plays a sound only you can hear.", ADMIN_CATEGORY_SOUNDS, sound as sound)
	log_admin("[key_name(user)] played a local sound [sound]")
	message_admins("[key_name_admin(user)] played a local sound [sound]")
	var/volume = tgui_input_number(user, "What volume would you like the sound to play at?", max_value = 100)
	playsound(get_turf(user.mob), sound, volume || 50, FALSE)
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
	if(!istext(web_sound_input))
		return

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
			catch(var/exception/parse_exception)
				to_chat(user, span_boldwarning("yt-dlp JSON parsing FAILED:"), confidential = TRUE)
				to_chat(user, span_warning("[parse_exception]: [stdout]"), confidential = TRUE)
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
		for(var/mob/target in GLOB.player_list)
			var/client/target_client = target.client
			if(target_client.prefs.sound & SOUND_MIDI)
				target_client.tgui_panel?.stop_music()
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

		for(var/mob/target in GLOB.player_list)
			var/client/target_client = target.client
			if(target_client.prefs.sound & SOUND_MIDI)
				target_client.tgui_panel?.play_music(url, music_extra_data)

	BLACKBOX_LOG_ADMIN_VERB("Play Internet Sound")

ADMIN_VERB(play_direct_mob_sound, R_SOUNDS, "Play Direct Mob Sound", "Play a sound directly to a mob.", ADMIN_CATEGORY_SOUNDS, sound as sound, mob/target in GLOB.mob_list)
	if(!target)
		target = tgui_input_list(user, "Choose a mob to play the sound to. Only they will hear it.", "Play Mob Sound", sort_names(GLOB.player_list))
	if(QDELETED(target))
		return
	log_admin("[key_name(user)] played a direct mob sound [sound] to [key_name_admin(target)].")
	message_admins("[key_name_admin(user)] played a direct mob sound [sound] to [ADMIN_LOOKUPFLW(target)].")
	var/volume = tgui_input_number(user, "What volume would you like the sound to play at?", max_value = 100)
	var/sound/admin_sound = sound(sound)
	if(volume)
		admin_sound.volume = volume
	SEND_SOUND(target, sound)
	BLACKBOX_LOG_ADMIN_VERB("Play Direct Mob Sound")

ADMIN_VERB(stop_sounds, R_SOUNDS, "Stop All Playing Sounds", "Stops all playing sounds for EVERYONE.", ADMIN_CATEGORY_SOUNDS)
	log_admin("[key_name(user)] stopped all currently playing sounds.")
	message_admins("[key_name_admin(user)] stopped all currently playing sounds.")
	for(var/mob/player as anything in GLOB.player_list)
		SEND_SOUND(player, sound(null))
		var/client/player_client = player.client
		player_client?.tgui_panel?.stop_music()

	BLACKBOX_LOG_ADMIN_VERB("Stop All Playing Sounds")
