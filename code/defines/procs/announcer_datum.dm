GLOBAL_DATUM_INIT(minor_announcement, /datum/announcer, new(config_type = /datum/announcement_configuration/minor))
GLOBAL_DATUM_INIT(major_announcement, /datum/announcer, new(config_type = /datum/announcement_configuration/major))

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
	/// A CSS class name.
	var/style

/datum/announcer
	// The default configuration for new announcements.
	var/datum/announcement_configuration/config
	/// The name used to sign off on announcements.
	var/author
	var/language = LANGUAGE_GALACTIC_COMMON
	var/beannounced = TRUE


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
		new_subtitle = null
	)

	if(!message)
		return
	if(!beannounced)
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

	var/formatted_message = format(message, title, subtitle)
	var/garbled_formatted_message = format(
		message_language.scramble(message),
		message_language.scramble(title),
		message_language.scramble(subtitle)
	)

	announce_message(formatted_message, garbled_formatted_message, receivers, garbled_receivers, message_sound)

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
			if(!istype(mob) || !mob.client || mob.stat || !mob.can_hear())
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
	if(GLOB.ai_list.len)
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

/datum/announcer/proc/format(message, title, subtitle = null)
	var/formatted_message
	var/style = config.style ? "announcement [config.style]" : "announcement"

	formatted_message += "<div class='[style]'>"
	formatted_message += "<h1>[title]</h1>"

	if(subtitle)
		formatted_message += "<h2>[subtitle]</h2>"

	formatted_message += "<p>[message]</p>"

	if(author)
		formatted_message += "<p class='author'> – [html_encode(author)]</p>"

	formatted_message += "</div>"

	return formatted_message

/datum/announcer/proc/announce_sound(message_sound, receivers)
	if(!message_sound)
		return
	for(var/mob/mob in receivers)
		if(CONFIG_GET(flag/tts_enabled))
			var/volume = mob.client.prefs.get_channel_volume(CHANNEL_TTS_RADIO)
			if(volume > 0)
				continue
		SEND_SOUND(mob, message_sound)

/datum/announcer/proc/announce_log(message, message_title)
	add_game_logs("has made \a [config.log_name]: [message_title] – [message] – [author]", usr)
	message_admins("[key_name_admin(usr)] has made \a [config.log_name].")

/proc/get_name_and_assignment_from_id(var/obj/item/card/id/id)
	// Format currently matches that of newscaster feeds: Registered Name (Assigned Rank)
	return id.assignment ? "[id.registered_name] ([id.assignment])" : id.registered_name

/datum/announcement_configuration/event
	default_title = ANNOUNCE_EVENT_RU
	sound = sound('sound/misc/notice2.ogg')
	style = "minor"

/datum/announcement_configuration/major
	default_title = ANNOUNCE_MAJOR_RU
	global_announcement = TRUE
	sound = sound('sound/misc/notice2.ogg')

/datum/announcement_configuration/security
	default_title = ANNOUNCE_SECURITY_RU
	sound = sound('sound/misc/notice2.ogg')
	style = "sec"

/datum/announcement_configuration/minor
	sound = sound('sound/misc/notice2.ogg')
	style = "minor"

/datum/announcement_configuration/requests_console
	style = "minor"
	add_log = TRUE
	sound = sound('sound/misc/notice2.ogg')

/datum/announcement_configuration/comms_console
	default_title = ANNOUNCE_PRIORITY_RU
	add_log = TRUE
	log_name = ANNOUNCE_KIND_PRIORITY
	sound = sound('sound/misc/announce.ogg')
	style = "major"

/datum/announcement_configuration/ai
	default_title = ANNOUNCE_AI_RU
	add_log = TRUE
	log_name = ANNOUNCE_KIND_AI
	sound = sound('sound/misc/notice2.ogg')
	style = "major"

/datum/announcer/Destroy()
	QDEL_NULL(config)
	return ..()
