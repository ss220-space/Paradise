// MARK: AI Saycode
/mob/living/silicon/ai/handle_track(message, verb = "говор%(ит,ят)%", atom/movable/speaker = null, speaker_name, atom/follow_target, hard_to_hear)
	if(hard_to_hear)
		return

	var/jobname // the mob's "job"
	var/mob/living/carbon/human/impersonating //The crewmember being impersonated, if any.
	var/changed_voice = FALSE

	if(ishuman(speaker))
		var/mob/living/carbon/human/H = speaker

		var/obj/item/card/id/id = H.wear_id
		if((istype(id) && id.is_untrackable()) && H.HasVoiceChanger())
			changed_voice = TRUE
			var/mob/living/carbon/human/I = locate(speaker_name)
			if(I)
				impersonating = I
				jobname = impersonating.get_assignment()
			else
				jobname = UNKNOWN_STATUS_RUS
		else
			jobname = H.get_assignment()

	else if(iscarbon(speaker)) // Nonhuman carbon mob
		jobname = "Без ID"
	else if(isAI(speaker))
		jobname = JOB_TITLE_AI
	else if(iscogscarab(speaker))
		jobname = UNKNOWN_STATUS_RUS
	else if(isrobot(speaker))
		var/mob/living/silicon/robot/R = speaker
		jobname = R.mind.role_alt_title ? R.mind.role_alt_title : JOB_TITLE_CYBORG
	else if(ispAI(speaker))
		jobname = "Персональный ИИ"
	else if(isradio(speaker))
		jobname = "Автоматическое оповещение"
	else
		jobname = UNKNOWN_STATUS_RUS

	var/track = ""
	var/mob/mob_to_track = null
	if(changed_voice)
		if(impersonating)
			mob_to_track = impersonating
		else
			track = "[speaker_name] ([jobname])"
	else
		if(isbot(follow_target))
			track = "<a href='byond://?src=[UID()];trackbot=\ref[follow_target]'>[speaker_name] ([jobname])</a>"
		else
			mob_to_track = speaker

	if(mob_to_track)
		track = "<a href='byond://?src=[UID()];track=\ref[mob_to_track]'>[speaker_name] ([jobname])</a>"
		track += "&nbsp;<a href='byond://?src=[UID()];open=\ref[mob_to_track]'>\[Open\]</a>"

	return track

// MARK: AI VOX Announcements
GLOBAL_VAR_INIT(announcing_vox, 0) // Stores the time of the last announcement
#define VOX_DELAY 100

/mob/living/silicon/ai/verb/announcement_help()
	set name = "Памятка по оповещениям"
	set desc = "Display a list of vocal words to announce to the crew."
	set category = STATPANEL_AICOMMANDS

	if(!ai_announcement_string_menu)
		var/list/dat = list()

		dat += "Here is a list of words you can type into the 'Announcement' button to create sentences to vocally announce to everyone on the same level at you.<br> \
		<ul><li>You can also click on the word to preview it.</li>\
		<li>You can only say 30 words for every announcement.</li>\
		<li>Do not use punctuation as you would normally, if you want a pause you can use the full stop and comma characters by separating them with spaces, like so: 'Alpha . Test , Bravo'.</li></ul>\
		<font class='bad'>WARNING:</font><br>Misuse of the announcement system will get you job banned.<hr>"

		// Show alert and voice sounds separately
		var/vox_words = GLOB.vox_sounds - GLOB.vox_alerts
		dat += help_format(GLOB.vox_alerts)
		dat += "<hr>"
		dat += help_format(vox_words)

		ai_announcement_string_menu = dat.Join("")

	var/datum/browser/popup = new(src, "announce_help", "Announcement Help", 500, 400)
	popup.set_content(ai_announcement_string_menu)
	popup.open()

/mob/living/silicon/ai/proc/help_format(word_list)
	var/list/localdat = list()
	var/uid_cache = UID() // Saves proc jumping
	for(var/word in word_list)
		localdat += "<a href='byond://?src=[uid_cache];say_word=[word]'>[word]</a>"
	return localdat.Join(" / ")

/mob/living/silicon/ai/proc/ai_announcement()
	if(check_unable(AI_CHECK_WIRELESS | AI_CHECK_RADIO))
		return

	if(GLOB.announcing_vox > world.time)
		to_chat(src, span_warning("Please wait [round((GLOB.announcing_vox - world.time) / 10)] seconds."))
		return

	var/message = tgui_input_text(src, "WARNING: Misuse of this verb can result in you being job banned. More help is available in 'Announcement Help'", "Announcement", last_announcement)

	last_announcement = message

	if(check_unable(AI_CHECK_WIRELESS | AI_CHECK_RADIO))
		return

	if(!message || GLOB.announcing_vox > world.time)
		return

	var/list/words = splittext(trim(message), " ")
	var/list/incorrect_words = list()

	if(length(words) > 30)
		words.Cut(31)

	for(var/word in words)
		word = lowertext(trim(word))
		if(!word)
			words -= word
			continue
		if(!GLOB.vox_sounds[word])
			incorrect_words += word

	if(length(incorrect_words))
		to_chat(src, span_warning("These words are not available on the announcement system: [english_list(incorrect_words)]."))
		return

	GLOB.announcing_vox = world.time + VOX_DELAY

	add_game_logs("[key_name_log(src)] made a vocal announcement: [message].", src)
	message_admins("[key_name_admin(src)] made a vocal announcement: [message].")

	for(var/word in words)
		play_vox_word(word, z, null)

	ai_voice_announcement_to_text(words)

/mob/living/silicon/ai/proc/ai_voice_announcement_to_text(words)
	var/words_string = jointext(words, " ")
	// Don't go through .announce because we need to filter by clients which have TTS enabled
	var/formatted_message = announcer.format(words_string, "Объявление ИИ")

	var/announce_sound = sound('sound/misc/notice2.ogg')
	for(var/mob/player_mob as anything in GLOB.player_list)
		if(player_mob.client && !(player_mob.client.prefs.sound & SOUND_AI_VOICE))
			var/turf/player_turf = get_turf(player_mob)
			if(player_turf && player_turf.z == z && player_mob.can_hear())
				SEND_SOUND(player_mob, announce_sound)
				to_chat(player_mob, formatted_message)

/proc/play_vox_word(word, z_level, mob/only_listener)
	word = lowertext(word)

	if(GLOB.vox_sounds[word])
		var/sound_file = GLOB.vox_sounds[word]
		var/sound/voice = sound(sound_file, wait = 1, channel = CHANNEL_VOX)
		voice.status = SOUND_STREAM

		// If there is no single listener, broadcast to everyone in the same z level
		if(!only_listener)
			// Play voice for all mobs in the z level
			for(var/mob/player_mob as anything in GLOB.player_list)
				if(player_mob.client && player_mob.client.prefs.sound & SOUND_AI_VOICE)
					var/turf/player_turf = get_turf(player_mob)

					if(player_turf && player_turf.z == z_level && player_mob.can_hear())
						voice.volume = 100 * player_mob.client.prefs.get_channel_volume(CHANNEL_VOX)
						SEND_SOUND(player_mob, voice)
		else
			SEND_SOUND(only_listener, voice)
		return TRUE
	return FALSE

#undef VOX_DELAY
