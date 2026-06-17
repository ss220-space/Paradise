ADMIN_VERB(play_sound, R_SOUNDS, "Play Global Sound", "Play a sound to all connected players.", ADMIN_CATEGORY_SOUNDS, sound as sound)
	var/frequency = 1
	var/volume = tgui_input_number(user, "С какой громкостью воспроизвести звук?", max_value = 100)
	if(!volume)
		return
	volume = clamp(volume, 1, 100)

	var/sound/admin_sound = new
	admin_sound.file = sound
	admin_sound.priority = 250
	admin_sound.channel = CHANNEL_ADMIN
	admin_sound.frequency = frequency
	admin_sound.wait = 1
	admin_sound.repeat = FALSE
	admin_sound.status = SOUND_STREAM
	admin_sound.volume = volume

	var/show_song_title = tgui_alert(user, "Показать игрокам название композиции?", "Воспроизведение звука", list("Да", "Нет", "Отмена"))
	switch(show_song_title)
		if("Да")
			to_chat(world, span_boldannounceooc(("Администратор включил: [sound]")), confidential = TRUE)
		if("Отмена")
			return

	log_admin("[key_name(user)] played sound [sound]")
	message_admins("[key_name_admin(user)] played sound [sound]")

	for(var/mob/target as anything in GLOB.player_list)
		var/client/target_client = target.client
		if(!(target_client.prefs.sound & SOUND_MIDI))
			continue
		if(isnewplayer(target) && (target_client.prefs.sound & SOUND_LOBBY))
			target_client.tgui_panel?.stop_music()
		admin_sound.volume = volume * target_client.prefs.get_channel_volume(CHANNEL_ADMIN)
		SEND_SOUND(target, admin_sound)

	BLACKBOX_LOG_ADMIN_VERB("Play Global Sound")

ADMIN_VERB(play_local_sound, R_SOUNDS, "Play Local Sound", "Plays a sound only you can hear.", ADMIN_CATEGORY_SOUNDS, sound as sound)
	log_admin("[key_name(user)] played a local sound [sound]")
	message_admins("[key_name_admin(user)] played a local sound [sound]")
	var/volume = tgui_input_number(user, "С какой громкостью воспроизвести звук?", max_value = 100)
	playsound(get_turf(user.mob), sound, volume || 50, FALSE)
	BLACKBOX_LOG_ADMIN_VERB("Play Local Sound")

/// Shared cooldown so only one admin web sound plays at a time. Lasts the track's duration.
GLOBAL_VAR_INIT(web_sound_cooldown, FALSE)

ADMIN_VERB_CUSTOM_EXIST_CHECK(play_web_sound)
	return !!CONFIG_GET(string/invoke_youtubedl)

ADMIN_VERB(play_web_sound, R_SOUNDS, "Play Internet Sound", "Play a given internet sound to all players.", ADMIN_CATEGORY_SOUNDS)
	if(!CLIENT_COOLDOWN_FINISHED(GLOB, web_sound_cooldown))
		var/time_left = DisplayTimeText(CLIENT_COOLDOWN_TIMELEFT(GLOB, web_sound_cooldown), 1)
		if(tgui_alert(user, "Кто-то уже проигрывает интернет-звук! Осталось [time_left]. Перебить?", "Musicalis Interruptus", list("Нет", "Да")) != "Да")
			return

	var/web_sound_input = tgui_input_text(user, "Введите URL (только поддерживаемые сайты, оставьте пустым, чтобы остановить воспроизведение)", "Воспроизведение интернет-звука через yt-dlp", encode = FALSE)
	if(!istext(web_sound_input))
		return

	if(length(web_sound_input))
		web_sound_input = trim(web_sound_input)
		if(findtext(web_sound_input, ":") && !findtext(web_sound_input, GLOB.is_http_protocol))
			to_chat(user, span_boldwarning("Не-http(s) URL запрещены."), confidential = TRUE)
			to_chat(user, span_warning("Для сокращений yt-dlp вроде ytsearch: используйте полный URL с сайта."), confidential = TRUE)
			return

	web_sound(user, web_sound_input)

/**
 * Resolves a URL through yt-dlp and, after admin confirmation, plays it to everyone.
 *
 * Shared by the Play Internet Sound verb and the player music request PLAY link.
 *
 * Arguments:
 * * user - the admin client triggering playback.
 * * input - the page url to play, or blank to stop the currently playing web sound.
 * * credit - optional ckey of the player who requested the track, shown in the announcement.
 */
/proc/web_sound(client/user, input, credit)
	if(!user || !check_rights_for(user, R_SOUNDS))
		return
	if(!user.tgui_panel || !SSassets.initialized)
		return

	var/youtubedl = CONFIG_GET(string/invoke_youtubedl)
	if(!youtubedl)
		to_chat(user, span_boldwarning("yt-dlp не настроен, действие недоступно"), confidential = TRUE) //Check config.txt for the INVOKE_YOUTUBEDL value
		return

	var/web_sound_path = ""
	var/web_sound_url = ""
	var/web_sound_id = ""
	var/cooldown_duration = 0
	var/stop_web_sounds = FALSE
	var/list/music_extra_data = list()
	if(length(input))
		var/datum/web_sound_info/sound_info = get_web_sound_info(youtubedl, input)
		if(!sound_info.success)
			to_chat(user, span_boldwarning("Не удалось получить URL через yt-dlp:"), confidential = TRUE)
			to_chat(user, span_warning("[sound_info.error_message]"), confidential = TRUE)
			return

		if(sound_info.url)
			web_sound_path = "cache/songs/[sound_info.id].mp3"
			web_sound_url = sound_info.url
			web_sound_id = sound_info.id
			var/song_title = "[sound_info.title]"
			var/title_link = song_title
			if(sound_info.webpage_url)
				title_link = "<a href=\"[sound_info.webpage_url]\">[song_title]</a>"
			var/music_duration = sound_info.duration * 1 SECONDS
			cooldown_duration = music_duration
			music_extra_data["duration"] = DisplayTimeText(music_duration)
			SSticker.music_available = REALTIMEOFDAY + music_duration
			music_extra_data["link"] = sound_info.webpage_url
			music_extra_data["artist"] = sound_info.artist
			music_extra_data["upload_date"] = sound_info.upload_date
			music_extra_data["album"] = sound_info.album

			if(music_duration > 10 MINUTES)
				if(tgui_alert(user, "Этот трек длиннее 10 минут. Точно проиграть его?", "Предупреждение о длине", list("Нет", "Да", "Отмена")) != "Да")
					return

			var/include_song_data = tgui_alert(user, "Показать игрокам название и ссылку?\n[song_title]", "Показывать ссылку?", list("Нет", "Да", "Отмена"))
			switch(include_song_data)
				if("Да")
					music_extra_data["title"] = sound_info.title
				if("Нет")
					music_extra_data["link"] = "Ссылка скрыта"
					music_extra_data["title"] = "Название скрыто"
					music_extra_data["artist"] = "Исполнитель скрыт"
					music_extra_data["upload_date"] = "Дата загрузки скрыта"
					music_extra_data["album"] = "Альбом скрыт"
				if("Отмена", null)
					return

			var/credit_yourself = tgui_alert(user, "Показывать, кто запустил?", "Указывать себя?", list("Нет", "Да", "Отмена"))
			var/list/announcement = list()
			switch(credit_yourself)
				if("Да")
					if(include_song_data == "Да")
						announcement += "[span_bold(user.ckey)] запустил: [span_linkify(title_link)]"
					else
						announcement += "[span_bold(user.ckey)] запустил музыку."
				if("Нет")
					if(include_song_data == "Да")
						announcement += "Администратор запустил: [span_linkify(title_link)]"
				if("Отмена", null)
					return
			if(credit)
				announcement += "По запросу: [span_bold(credit)]"
			if(length(announcement))
				to_chat(world, fieldset_block(span_bold("Сейчас играет: [span_bold(music_extra_data["title"])][music_extra_data["artist"] ? " — [span_bold(music_extra_data["artist"])]" : ""]"), jointext(announcement, "<br>"), "boxed_message"), confidential = TRUE)

			SSblackbox.record_feedback("nested tally", "played_url", 1, list("[user.ckey]", "[input]"))
			log_admin("[key_name(user)] played web sound: [input][credit ? " (requested by [credit])" : ""]")
			message_admins("[key_name(user)] played web sound: [input][credit ? " (requested by [credit])" : ""]")

	else //pressed ok with blank
		log_admin("[key_name(user)] stopped web sound")
		message_admins("[key_name(user)] stopped web sound")
		web_sound_path = null
		stop_web_sounds = TRUE
		SSticker.music_available = 0

	if(stop_web_sounds)
		for(var/mob/target as anything in GLOB.player_list)
			var/client/target_client = target.client
			if(!(target_client.prefs.sound & SOUND_MIDI))
				continue
			target_client.tgui_panel?.stop_music()
	else
		if(!web_sound_url)
			return
		var/playback_url = web_sound_url
		switch(CONFIG_GET(string/asset_transport))
			if(ASSET_TRANSPORT_WEBROOT)
				var/datum/asset/music/music_asset = GLOB.cached_songs[web_sound_path]
				if(!music_asset)
					music_asset = new /datum/asset/music(youtubedl, input, web_sound_id)
					if(!music_asset.item_filename)
						to_chat(user, span_boldwarning("Не удалось скачать через yt-dlp."), confidential = TRUE)
						return
					GLOB.cached_songs[web_sound_path] = music_asset
				playback_url = music_asset.get_url()

		for(var/mob/target as anything in GLOB.player_list)
			var/client/target_client = target.client
			if(!(target_client.prefs.sound & SOUND_MIDI))
				continue
			target_client.tgui_panel?.play_music(playback_url, music_extra_data)

	CLIENT_COOLDOWN_START(GLOB, web_sound_cooldown, cooldown_duration)
	BLACKBOX_LOG_ADMIN_VERB("Play Internet Sound")

ADMIN_VERB(play_direct_mob_sound, R_SOUNDS, "Play Direct Mob Sound", "Play a sound directly to a mob.", ADMIN_CATEGORY_SOUNDS, sound as sound, mob/target in GLOB.mob_list)
	if(!target)
		target = tgui_input_list(user, "Выберите моба, которому проиграть звук. Только он его услышит.", "Воспроизведение звука мобу", sort_names(GLOB.player_list))
	if(QDELETED(target))
		return
	log_admin("[key_name(user)] played a direct mob sound [sound] to [key_name_admin(target)].")
	message_admins("[key_name_admin(user)] played a direct mob sound [sound] to [ADMIN_LOOKUPFLW(target)].")
	var/volume = tgui_input_number(user, "С какой громкостью воспроизвести звук?", max_value = 100)
	var/sound/admin_sound = sound(sound)
	if(volume)
		admin_sound.volume = volume
	SEND_SOUND(target, admin_sound)
	BLACKBOX_LOG_ADMIN_VERB("Play Direct Mob Sound")

ADMIN_VERB(stop_sounds, R_SOUNDS, "Stop All Playing Sounds", "Stops all playing sounds for EVERYONE.", ADMIN_CATEGORY_SOUNDS)
	log_admin("[key_name(user)] stopped all currently playing sounds.")
	message_admins("[key_name_admin(user)] stopped all currently playing sounds.")
	for(var/mob/player as anything in GLOB.player_list)
		SEND_SOUND(player, sound(null))
		var/client/player_client = player.client
		player_client?.tgui_panel?.stop_music()

	CLIENT_COOLDOWN_RESET(GLOB, web_sound_cooldown)
	BLACKBOX_LOG_ADMIN_VERB("Stop All Playing Sounds")
