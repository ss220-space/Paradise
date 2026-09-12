GLOBAL_DATUM_INIT(minor_announcement, /datum/announcer, new(config_type = /datum/announcement_configuration/minor))
GLOBAL_DATUM_INIT(major_announcement, /datum/announcer, new(config_type = /datum/announcement_configuration/major))

// please don't use these defines outside of this file in order to ensure a unified framework. unless you have a really good reason to make them global, then whatever

// these four are just text spans that furnish the TEXT itself with the appropriate CSS classes
#define MAJOR_ANNOUNCEMENT_TITLE(string) ("<span class='major_announcement_title'>" + string + "</span>")
#define SUBHEADER_ANNOUNCEMENT_TITLE(string) ("<span class='subheader_announcement_text'>" + string + "</span>")
#define MAJOR_ANNOUNCEMENT_TEXT(string) ("<span class='major_announcement_text'>" + string + "</span>")
#define MINOR_ANNOUNCEMENT_TITLE(string) ("<span class='minor_announcement_title'>" + string + "</span>")
#define MINOR_ANNOUNCEMENT_TEXT(string) ("<span class='minor_announcement_text'>" + string + "</span>")

#define ANNOUNCEMENT_HEADER(string) ("<span class='announcement_header'>" + string + "</span>")

// these two are the ones that actually give the striped background
#define CHAT_ALERT_DEFAULT_SPAN(string) ("<div class='chat_alert_default'>" + string + "</div>")
#define CHAT_ALERT_COLORED_SPAN(color, string) ("<div class='chat_alert_" + color + "'>" + string + "</div>")

#define STYLE_MAJOR "major"
#define STYLE_MINOR "minor"

/datum/announcement_configuration
	var/default_title = "Внимание!"
	/// The name used when describing the announcement type in logs.
	var/log_name = ANNOUNCE_KIND_DEFAULT
	/// Whether or not to log the announcement when made.
	var/add_log = FALSE
	/// Global announcements are received regardless of being in range of a
	/// radio, unless you're in the lobby, to prevent metagaming.
	var/global_announcement = FALSE
	/// What sound to play when the announcement is made.
	var/sound/sound
	var/style = "default"
	/// Color for CHAT_ALERT_COLORED_SPAN
	var/color_override = "default"

/datum/announcer
	/// The default configuration for new announcements.
	var/datum/announcement_configuration/config
	/// The name used to sign off on announcements.
	var/author
	var/language = LANGUAGE_GALACTIC_COMMON

/datum/announcer/New(config_type = null)
	config = config_type ? new config_type : new

// TODO: Make new_sound+new_sound2 a list to clean things up more
/datum/announcer/proc/announce(
		message,
		new_title = null,
		new_sound = null,
		msg_sanitized = FALSE,
		msg_language,
		new_sound2 = null,
		new_subtitle = null,
		color_override = null
	)

	if(!new_sound)
		new_sound = SSstation.announcer.get_rand_alert_sound()
	else if(SSstation.announcer.event_sounds[new_sound])
		new_sound = SSstation.announcer.event_sounds[new_sound]

	if(!message)
		return

	var/title = html_encode(new_title || config.default_title)
	var/subtitle = new_subtitle ? html_encode(new_subtitle) : null
	var/message_sound = new_sound ? sound(new_sound) : config.sound
	var/message_sound2 = new_sound2 ? sound(new_sound2) : null

	if(!msg_sanitized)
		message = html_encode(message)

	var/datum/language/message_language = GLOB.all_languages[msg_language ? msg_language : language]

	var/list/combined_receivers = get_receivers(message_language)
	var/list/receivers = combined_receivers[1]
	var/list/garbled_receivers = combined_receivers[2]

	var/formatted_message = format(message, title, subtitle, color_override)
	var/garbled_formatted_message = format(
		message_language.scramble(message),
		message_language.scramble(title),
		message_language.scramble(subtitle),
		color_override
	)

	announce_message(formatted_message, garbled_formatted_message, receivers, garbled_receivers, message_sound)

	var/datum/feed_message/feed_message = new
	feed_message.author = author ? author : "Новости станции"
	feed_message.title = subtitle ? "[title]: [subtitle]" : "[title]"
	feed_message.body = message
	GLOB.news_network.get_channel_by_name(NEWS_CHANNEL_STATION_LOG)?.add_message(feed_message)

	announce_sound(message_sound, combined_receivers[1] + combined_receivers[2])
	if(message_sound2)
		announce_sound(message_sound2, combined_receivers[1] + combined_receivers[2])

	if(config.add_log)
		announce_log(message, title)

/datum/announcer/proc/get_receivers(datum/language/message_language)
	var/list/receivers = list()
	var/list/garbled_receivers = list()

	if(config.global_announcement)
		for(var/mob/mob as anything in GLOB.player_list)
			if(!isnewplayer(mob) && mob.client)
				receivers |= mob
			if(!mob.say_understands(null, message_language))
				receivers -= mob
				garbled_receivers |= mob
	else
		for(var/obj/item/radio/radio as anything in GLOB.global_radios)
			receivers |= radio.send_announcement()
		for(var/mob/mob in receivers)
			if(!istype(mob) || !mob.client || mob.stat || HAS_TRAIT(mob, TRAIT_DEAF))
				receivers -= mob
				continue
			if(!mob.say_understands(null, message_language))
				receivers -= mob
				garbled_receivers |= mob
		for(var/mob/mob as anything in GLOB.dead_mob_list)
			if(mob.client && mob.stat == DEAD && !isnewplayer(mob))
				receivers |= mob

	return list(receivers, garbled_receivers)

/datum/announcer/proc/announce_message(message, garbled_message, receivers, garbled_receivers, message_sound)
	var/tts_seed = "Glados"
	if(length(GLOB.ai_list))
		var/mob/living/silicon/ai/AI = pick(GLOB.ai_list)
		tts_seed = AI.tts_seed
	var/message_tts = message
	var/garbled_message_tts = garbled_message
	message = replace_characters(message, list("+"))
	garbled_message = replace_characters(garbled_message, list("+"))
	for(var/mob/mob in receivers)
		to_chat(mob, message, MESSAGE_TYPE_WARNING)
		INVOKE_ASYNC(GLOBAL_PROC, /proc/tts_cast, null, mob, message_tts, tts_seed, FALSE, SOUND_EFFECT_NONE, TTS_TRAIT_RATE_MEDIUM, message_sound)
	for(var/mob/mob in garbled_receivers)
		to_chat(mob, garbled_message, MESSAGE_TYPE_WARNING)
		INVOKE_ASYNC(GLOBAL_PROC, /proc/tts_cast, null, mob, garbled_message_tts, tts_seed, FALSE, SOUND_EFFECT_NONE, TTS_TRAIT_RATE_MEDIUM, message_sound)

/datum/announcer/proc/format(message, title, subtitle = null, color_override = null)
	var/formatted_message = ""
	var/list/announcement_strings = list()
	var/list/header = list()
	switch(config.style)
		if(STYLE_MAJOR)
			header += MAJOR_ANNOUNCEMENT_TITLE(title)
		if(STYLE_MINOR)
			header += MINOR_ANNOUNCEMENT_TITLE(title)
		else
			header += MAJOR_ANNOUNCEMENT_TITLE(title)

	if(subtitle)
		header += SUBHEADER_ANNOUNCEMENT_TITLE(subtitle)

	announcement_strings += ANNOUNCEMENT_HEADER(header.Join(""))

	switch(config.style)
		if(STYLE_MAJOR)
			announcement_strings += MAJOR_ANNOUNCEMENT_TEXT(message)
		if(STYLE_MINOR)
			announcement_strings += MINOR_ANNOUNCEMENT_TEXT(message)
		else
			announcement_strings += MAJOR_ANNOUNCEMENT_TEXT(message)

	if(author)
		announcement_strings += MINOR_ANNOUNCEMENT_TEXT(" – [html_encode(author)]")

	var/joined_message = jointext(announcement_strings, "")

	var/final_color_override = color_override || config.color_override

	if(final_color_override)
		formatted_message = CHAT_ALERT_COLORED_SPAN(final_color_override, joined_message)
	else
		formatted_message = CHAT_ALERT_DEFAULT_SPAN(joined_message)

	return formatted_message

/datum/announcer/proc/announce_sound(message_sound, receivers)
	if(!message_sound)
		return
	for(var/mob/mob in receivers)
		if(CONFIG_GET(flag/tts_enabled))
			var/volume = mob.client.prefs.get_channel_volume(CHANNEL_TTS_RADIO)
			if(volume > 0)
				continue
		var/volume_mod = 100 * mob?.client?.prefs?.get_channel_volume(CHANNEL_ANNOUNCER)
		SEND_SOUND(mob, sound(
				message_sound,
				channel = CHANNEL_ANNOUNCER,
				volume = volume_mod,
			))

/datum/announcer/proc/announce_log(message, message_title)
	add_game_logs("has made \a [config.log_name]: [message_title] – [message] – [author]", usr)
	message_admins("[key_name_admin(usr)] has made \a [config.log_name].")

/proc/get_name_and_assignment_from_id(obj/item/card/id/id)
	// Format currently matches that of newscaster feeds: Registered Name (Assigned Rank)
	return id.assignment ? "[id.registered_name] ([id.assignment])" : id.registered_name

/datum/announcement_configuration/event
	default_title = ANNOUNCE_EVENT_RU
	sound = sound('sound/misc/notice2.ogg')
	style = STYLE_MINOR

/datum/announcement_configuration/major
	default_title = ANNOUNCE_MAJOR_RU
	global_announcement = TRUE
	sound = sound('sound/misc/notice2.ogg')
	style = STYLE_MAJOR

/datum/announcement_configuration/security
	default_title = ANNOUNCE_SECURITY_RU
	sound = sound('sound/misc/notice2.ogg')
	style = STYLE_MINOR

/datum/announcement_configuration/minor
	sound = sound('sound/misc/notice2.ogg')
	style = STYLE_MINOR

/datum/announcement_configuration/requests_console
	style = STYLE_MINOR
	add_log = TRUE
	sound = sound('sound/misc/announce_dig.ogg', volume = 90)
	color_override = "blue"

/datum/announcement_configuration/comms_console
	default_title = ANNOUNCE_PRIORITY_RU
	add_log = TRUE
	log_name = ANNOUNCE_KIND_PRIORITY
	sound = sound('sound/misc/announce.ogg')
	style = STYLE_MAJOR
	color_override = "blue"

/datum/announcement_configuration/ai
	default_title = ANNOUNCE_AI_RU
	add_log = TRUE
	log_name = ANNOUNCE_KIND_AI
	sound = sound('sound/misc/notice2.ogg')
	style = STYLE_MAJOR
	color_override = "pink"

/datum/announcer/Destroy()
	QDEL_NULL(config)
	return ..()

/// Proc that just dispatches the announcement to our applicable audience. Only the announcement is a mandatory arg.
/// `should_play_sound` can also be a callback, if you want to only play the sound to specific players.
/proc/dispatch_announcement_to_players(announcement, list/players = GLOB.player_list, sound_override = null, should_play_sound = TRUE)
	var/sound_to_play = !isnull(sound_override) ? sound_override : 'sound/misc/notice2.ogg'

	var/datum/callback/should_play_sound_callback = astype(should_play_sound)

	for(var/mob/target in players)
		if(isnewplayer(target) || HAS_TRAIT(target, TRAIT_DEAF))
			continue

		to_chat(target, announcement)
		if(!should_play_sound || (should_play_sound_callback && !should_play_sound_callback.Invoke(target)))
			continue
		//if(target.client?.prefs.read_preference(/datum/preference/toggle/sound_announcements))
		SEND_SOUND(target, sound(sound_to_play))

#undef MAJOR_ANNOUNCEMENT_TITLE
#undef MAJOR_ANNOUNCEMENT_TEXT
#undef MINOR_ANNOUNCEMENT_TITLE
#undef MINOR_ANNOUNCEMENT_TEXT
#undef CHAT_ALERT_DEFAULT_SPAN
#undef CHAT_ALERT_COLORED_SPAN
#undef SUBHEADER_ANNOUNCEMENT_TITLE
#undef ANNOUNCEMENT_HEADER
#undef STYLE_MAJOR
#undef STYLE_MINOR
