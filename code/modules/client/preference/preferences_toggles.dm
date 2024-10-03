/client/verb/setup_character()
	set name = "Game Preferences"
	set category = "Special Verbs"
	set desc = "Allows you to access the Setup Character screen. Changes to your character won't take effect until next round, but other changes will."
	prefs.current_tab = 1
	prefs.ShowChoices(usr)

// Preference toggles
/datum/preference_toggle
	/// Name of the preference toggle. Don't set this if you don't want it to appear in game
	var/name
	/// Bitflag this datum will set to
	var/preftoggle_bitflag
	/// Category of the toggle
	var/preftoggle_category
	/// What toggles to set this to?
	var/preftoggle_toggle
	/// Description of what the pref setting does
	var/description
	/// Message to display when this toggle is enabled
	var/enable_message
	/// Message to display when this toggle is disabled
	var/disable_message
	/// Message for the blackbox, legacy verbs so we can't just use the name
	var/blackbox_message
	/// Rights required to be able to use this pref option
	var/rights_required

/datum/preference_toggle/proc/set_toggles(client/user)
	var/datum/preferences/our_prefs = user.prefs
	switch(preftoggle_toggle)
		if(PREFTOGGLE_SPECIAL)
			CRASH("[src] did not have it's set_toggles overriden even though it was a special toggle, please use the special_toggle path!")
		if(PREFTOGGLE_TOGGLE1)
			our_prefs.toggles ^= preftoggle_bitflag
			to_chat(user, "<span class='notice'>[(our_prefs.toggles & preftoggle_bitflag) ? enable_message : disable_message]</span>")
		if(PREFTOGGLE_TOGGLE2)
			our_prefs.toggles2 ^= preftoggle_bitflag
			to_chat(user, "<span class='notice'>[(our_prefs.toggles2 & preftoggle_bitflag) ? enable_message : disable_message]</span>")
		if(PREFTOGGLE_SOUND)
			our_prefs.sound ^= preftoggle_bitflag
			to_chat(user, "<span class='notice'>[(our_prefs.sound & preftoggle_bitflag) ? enable_message : disable_message]</span>")

	SSblackbox.record_feedback("tally", "toggle_verbs", 1, blackbox_message)
	our_prefs.save_preferences(user)

/datum/preference_toggle/toggle_ghost_ears
	name = "Toggle Hearing All Speech as a Ghost"
	description = "Toggle Between seeing all mob speech, and only speech of nearby mobs"
	preftoggle_bitflag = PREFTOGGLE_CHAT_GHOSTEARS
	preftoggle_toggle = PREFTOGGLE_TOGGLE1
	preftoggle_category = PREFTOGGLE_CATEGORY_GHOST
	enable_message = "As a ghost, you will now only see speech from nearby mobs."
	disable_message = "As a ghost, you will now see all speech in the world."
	blackbox_message = "Toggle GhostEars"

/datum/preference_toggle/toggle_ghost_sight
	name = "Toggle Ghost Emote Viewing"
	description = "Toggle Between seeing all mob emotes, and only emotes of nearby mobs"
	preftoggle_bitflag = PREFTOGGLE_CHAT_GHOSTSIGHT
	preftoggle_toggle = PREFTOGGLE_TOGGLE1
	preftoggle_category = PREFTOGGLE_CATEGORY_GHOST
	enable_message = "As a ghost, you will now only see speech from nearby mobs."
	disable_message = "As a ghost, you will now see all emotes in the world."
	blackbox_message = "Toggle GhostSight"

/datum/preference_toggle/toggle_ghost_radio
	name = "Toggle Ghost Radio"
	description = "Toggle between hearing all radio chatter, or only from nearby speakers"
	preftoggle_bitflag = PREFTOGGLE_CHAT_GHOSTRADIO
	preftoggle_toggle = PREFTOGGLE_TOGGLE1
	preftoggle_category = PREFTOGGLE_CATEGORY_GHOST
	enable_message = "As a ghost, you will now only hear from nearby speakers."
	disable_message = "As a ghost, you will now hear all radio chat in the world."
	blackbox_message = "Toggle GhostRadio"

/datum/preference_toggle/toggle_admin_radio
	name = "Admin Radio"
	description = "Toggle seeing radiochatter from radios and speakers"
	preftoggle_bitflag = PREFTOGGLE_CHAT_RADIO
	preftoggle_toggle = PREFTOGGLE_SOUND
	preftoggle_category = PREFTOGGLE_CATEGORY_ADMIN
	rights_required = R_ADMIN
	enable_message = "You will no longer see radio chatter from radios or speakers."
	disable_message = "You will now see radio chatter from radios or speakers."
	blackbox_message = "Toggle RadioChatter"

/datum/preference_toggle/toggle_ai_voice_annoucements
	name = "AI Voice Announcements"
	description = "Toggle hearing AI annoucements in voice form or in text form"
	preftoggle_bitflag = SOUND_AI_VOICE
	preftoggle_toggle = PREFTOGGLE_SOUND
	preftoggle_category = PREFTOGGLE_CATEGORY_GENERAL
	enable_message = "You will now hear AI announcements."
	disable_message = "You will now hear AI announcements."
	blackbox_message = "Toggle AI Voice"

/datum/preference_toggle/toggle_admin_pm_sound
	name = "Admin PM sound"
	description = "Toggle hearing a notification when admin PMs are received"
	preftoggle_bitflag = SOUND_ADMINHELP
	preftoggle_toggle = PREFTOGGLE_SOUND
	preftoggle_category = PREFTOGGLE_CATEGORY_ADMIN
	rights_required = R_ADMIN
	enable_message = "You will now hear a sound when adminhelp is sent."
	disable_message = "You will no longer hear a sound when adminhelp is sent."
	blackbox_message = "Toggle Admin Bwoinks"

/datum/preference_toggle/toggle_mentor_pm_sound
	name = "Mentor PM sound"
	description = "Toggle hearing a notification when mentor PMs are received"
	preftoggle_bitflag = SOUND_MENTORHELP
	preftoggle_toggle = PREFTOGGLE_SOUND
	preftoggle_category = PREFTOGGLE_CATEGORY_ADMIN
	rights_required = R_MENTOR
	enable_message = "You will now hear a sound when mentorhelp is sent."
	disable_message = "You will no longer hear a sound when mentorhelp is sent."
	blackbox_message = "Toggle Mentor Bwoinks"

/datum/preference_toggle/toggle_deadchat_visibility
	name = "Toggle Deadchat visibility"
	description = "Toggles Dchat's visibility"
	preftoggle_bitflag = PREFTOGGLE_CHAT_DEAD
	preftoggle_toggle = PREFTOGGLE_TOGGLE1
	preftoggle_category = PREFTOGGLE_CATEGORY_GENERAL
	enable_message = "You will now see deadchat."
	disable_message = "You will no longer see deadchat."
	blackbox_message = "Toggle Deadchat"

/datum/preference_toggle/end_of_round_scoreboard
	name = "Toggle the End of Round Scoreboard"
	description = "Prevents you from seeing the end of round scoreboard"
	preftoggle_bitflag = PREFTOGGLE_DISABLE_SCOREBOARD
	preftoggle_toggle = PREFTOGGLE_TOGGLE1
	preftoggle_category = PREFTOGGLE_CATEGORY_GENERAL
	enable_message = "You will now see the end of round scoreboard."
	disable_message = "You will no longer see see the end of round scoreboard."
	blackbox_message = "Toggle Scoreboard"

/datum/preference_toggle/title_music
	name = "Toggle Lobby Music"
	description = "Toggles hearing the GameLobby music"
	preftoggle_bitflag = SOUND_LOBBY
	preftoggle_toggle = PREFTOGGLE_SOUND
	preftoggle_category = PREFTOGGLE_CATEGORY_GENERAL
	enable_message = "You will now hear music in the game lobby."
	disable_message = "You will no longer hear music in the game lobby."
	blackbox_message = "Toggle Lobby Music"

/datum/preference_toggle/title_music/set_toggles(client/user)
	. = ..()
	if(user.prefs.sound & SOUND_LOBBY)
		if(isnewplayer(usr))
			user.playtitlemusic()
	else
		// usr.stop_sound_channel(CHANNEL_LOBBYMUSIC)
		user.tgui_panel?.stop_music()

/datum/preference_toggle/toggle_admin_midis
	name = "Toggle Admin Midis"
	description = "Toggles hearing sounds uploaded by admins"
	preftoggle_bitflag = SOUND_MIDI
	preftoggle_toggle = PREFTOGGLE_SOUND
	preftoggle_category = PREFTOGGLE_CATEGORY_GENERAL
	enable_message = "You will now hear any sounds uploaded by admins."
	disable_message = "You will no longer hear sounds uploaded by admins; any currently playing midis have been disabled."
	blackbox_message = "Toggle MIDIs"

/datum/preference_toggle/toggle_admin_midis/set_toggles(client/user)
	. = ..()
	if(user.prefs.sound & ~SOUND_LOBBY)
		usr.stop_sound_channel(CHANNEL_ADMIN)

/datum/preference_toggle/toggle_ooc
	name = "Toggle OOC chat"
	description = "Toggles seeing OutOfCharacter chat"
	preftoggle_bitflag = PREFTOGGLE_CHAT_OOC
	preftoggle_toggle = PREFTOGGLE_TOGGLE1
	preftoggle_category = PREFTOGGLE_CATEGORY_GENERAL
	enable_message = "You will now see the OOC channel."
	disable_message = "You will no longer see the OOC channel."
	blackbox_message = "Toggle OOC"

/datum/preference_toggle/toggle_looc
	name = "Toggle LOOC chat"
	description = "Toggles seeing Local OutOfCharacter chat"
	preftoggle_bitflag = PREFTOGGLE_CHAT_LOOC
	preftoggle_toggle = PREFTOGGLE_TOGGLE1
	preftoggle_category = PREFTOGGLE_CATEGORY_GENERAL
	enable_message = "You will now see the LOOC channel."
	disable_message = "You will no longer see the LOOC channel."
	blackbox_message = "Toggle LOOC"

/datum/preference_toggle/toggle_ambience
	name = "Toggle Ambient sounds"
	description = "Toggles hearing ambient sound effects"
	preftoggle_bitflag = SOUND_AMBIENCE
	preftoggle_toggle = PREFTOGGLE_SOUND
	preftoggle_category = PREFTOGGLE_CATEGORY_GENERAL
	enable_message = "You now hear ambient sounds."
	disable_message = "Ambience is now silenced."
	blackbox_message = "Toggle Ambience"

/datum/preference_toggle/toggle_ambience/set_toggles(client/user)
	. = ..()
	if(user.prefs.sound & ~SOUND_AMBIENCE)
		usr.stop_sound_channel(CHANNEL_AMBIENCE)
	user.update_ambience_pref()

/datum/preference_toggle/toggle_white_noise
	name = "Toggle White Noise"
	description = "Toggles hearing White Noise"
	preftoggle_bitflag = SOUND_BUZZ
	preftoggle_toggle = PREFTOGGLE_SOUND
	preftoggle_category = PREFTOGGLE_CATEGORY_GENERAL
	enable_message = "You will now hear ambient white noise."
	disable_message = "You will no longer hear ambient white noise."
	blackbox_message = "Toggle Whitenoise"

/datum/preference_toggle/toggle_white_noise/set_toggles(client/user)
	. = ..()
	if(user.prefs.sound & ~SOUND_BUZZ)
		usr.stop_sound_channel(CHANNEL_BUZZ)

/datum/preference_toggle/toggle_heartbeat_noise
	name = "Toggle Heartbeat noise"
	description = "Toggles hearing heartbeat sounds"
	preftoggle_bitflag = SOUND_HEARTBEAT
	preftoggle_toggle = PREFTOGGLE_SOUND
	preftoggle_category = PREFTOGGLE_CATEGORY_GENERAL
	enable_message = "You will now hear heartbeat sounds."
	disable_message = "You will no longer hear heartbeat sounds."
	blackbox_message = "Toggle Hearbeat"

/datum/preference_toggle/toggle_heartbeat_noise/set_toggles(client/user)
	. = ..()
	if(user.prefs.sound & ~SOUND_HEARTBEAT)
		usr.stop_sound_channel(CHANNEL_HEARTBEAT)

/datum/preference_toggle/toggle_instruments
	name = "Toggle Instruments"
	description = "Toggles hearing musical instruments like the violin and piano"
	preftoggle_bitflag = SOUND_INSTRUMENTS
	preftoggle_toggle = PREFTOGGLE_SOUND
	preftoggle_category = PREFTOGGLE_CATEGORY_GENERAL
	enable_message = "You will now hear people playing musical instruments."
	disable_message = "You will no longer hear musical instruments."
	blackbox_message = "Toggle Instruments"

/datum/preference_toggle/toggle_disco
	name = "Toggle Disco Machine Music"
	description = "Toggles hearing musical instruments like the violin and piano"
	preftoggle_bitflag = SOUND_DISCO
	preftoggle_toggle = PREFTOGGLE_SOUND
	preftoggle_category = PREFTOGGLE_CATEGORY_GENERAL
	enable_message = "You will now hear and dance to the radiant dance machine."
	disable_message = "You will no longer hear or dance to the radiant dance machine."
	blackbox_message = "Toggle Dance Machine"

/datum/preference_toggle/toggle_disco/set_toggles(client/user)
	. = ..()
	if(user.prefs.sound & ~SOUND_DISCO)
		usr.stop_sound_channel(CHANNEL_JUKEBOX)

/datum/preference_toggle/toggle_ghost_pda
	name = "Toggle Ghost PDA messages"
	description = "Toggle seeing PDA messages as an observer"
	preftoggle_bitflag = PREFTOGGLE_CHAT_GHOSTPDA
	preftoggle_toggle = PREFTOGGLE_TOGGLE1
	preftoggle_category = PREFTOGGLE_CATEGORY_GHOST
	enable_message = "As a ghost, you will now see all PDA messages."
	disable_message = "As a ghost, you will no longer see PDA messages."
	blackbox_message = "Toggle Ghost PDA"

/client/verb/silence_current_midi()
	set name = "Silence Current Midi"
	set category = "Special Verbs"
	set desc = "Silence the current admin midi playing"
	usr.stop_sound_channel(CHANNEL_ADMIN)
	to_chat(src, "The current admin midi has been silenced")

/datum/preference_toggle/toggle_runechat
	name = "Toggle Runechat"
	description = "Toggle seeing Runechat messages"
	preftoggle_bitflag = PREFTOGGLE_2_RUNECHAT
	preftoggle_toggle = PREFTOGGLE_TOGGLE2
	preftoggle_category = PREFTOGGLE_CATEGORY_GENERAL
	enable_message = "You will now see runechat."
	disable_message = "You will no longer see runechat."
	blackbox_message = "Toggle Runechat"

/datum/preference_toggle/toggle_ghost_death_notifs
	name = "Toggle Ghost Death Notifications"
	description = "Toggle a notification when a player dies"
	preftoggle_bitflag = PREFTOGGLE_2_DEATHMESSAGE
	preftoggle_toggle = PREFTOGGLE_TOGGLE2
	preftoggle_category = PREFTOGGLE_CATEGORY_GHOST
	enable_message = "You will now see a notification in deadchat when a player dies."
	disable_message = "You will no longer see a notification in deadchat when a player dies."
	blackbox_message = "Toggle Death Notifications"

/datum/preference_toggle/toggle_reverb
	name = "Toggle Reverb"
	description = "Toggles Reverb on specific sounds"
	preftoggle_bitflag = PREFTOGGLE_2_REVERB_DISABLE
	preftoggle_toggle = PREFTOGGLE_TOGGLE2
	preftoggle_category = PREFTOGGLE_CATEGORY_GENERAL
	enable_message = "You will now get reverb on some in game sounds."
	disable_message = "You will no longer get reverb on some in game sounds."
	blackbox_message = "Toggle reverb"

/datum/preference_toggle/toggle_simple_stat_panel
	name = "Toggle item outlines"
	description = "Toggles seeing item outlines on hover"
	preftoggle_bitflag = PREFTOGGLE_2_SEE_ITEM_OUTLINES
	preftoggle_toggle = PREFTOGGLE_TOGGLE2
	preftoggle_category = PREFTOGGLE_CATEGORY_LIVING
	enable_message = "You no longer see item outlines when hovering over an item with your mouse."
	disable_message = "You now see item outlines when hovering over an item with your mouse."
	blackbox_message = "Toggle item outlines"

/datum/preference_toggle/toggle_anonmode
	name = "Toggle Anonymous Mode"
	description = "Toggles showing your key in various parts of the game (deadchat, end round, etc)"
	preftoggle_bitflag = PREFTOGGLE_2_ANON
	preftoggle_toggle = PREFTOGGLE_TOGGLE2
	preftoggle_category = PREFTOGGLE_CATEGORY_GENERAL
	enable_message = "Your key will no longer be shown in certain events (end round reports, deadchat, etc)."
	disable_message = "Your key will now will be shown in certain events (end round reports, deadchat, etc)."
	blackbox_message = "Toggle Anon mode"

/datum/preference_toggle/toggle_typing_indicator
	name = "Toggle Typing Indicator"
	description = "Hides the typing indicator"
	preftoggle_bitflag = PREFTOGGLE_SHOW_TYPING
	preftoggle_toggle = PREFTOGGLE_TOGGLE1
	preftoggle_category = PREFTOGGLE_CATEGORY_LIVING
	enable_message = "You will no longer display a typing indicator."
	disable_message = "You will now display a typing indicator."
	blackbox_message = "Toggle Typing Indicator (Speech)"

/datum/preference_toggle/toggle_typing_indicator/set_toggles(client/user)
	. = ..()
	if(user.prefs.toggles & PREFTOGGLE_SHOW_TYPING)
		if(istype(usr))
			usr.set_typing_indicator(FALSE)

/datum/preference_toggle/toggle_admin_logs
	name = "Toggle Admin Log Messages"
	description = "Disables admin log messages"
	preftoggle_bitflag = PREFTOGGLE_CHAT_NO_ADMINLOGS
	preftoggle_toggle = PREFTOGGLE_TOGGLE1
	preftoggle_category = PREFTOGGLE_CATEGORY_ADMIN
	rights_required = R_ADMIN
	enable_message = "Admin logs disabled."
	disable_message = "Admin logs re-enabled."
	blackbox_message = "Admin logs toggled"

/datum/preference_toggle/toggle_mhelp_notification
	name = "Toggle Mentor Ticket Messages"
	description = "Disables mentor ticket notifications"
	preftoggle_bitflag = PREFTOGGLE_CHAT_NO_MENTORTICKETLOGS
	preftoggle_toggle = PREFTOGGLE_TOGGLE1
	preftoggle_category = PREFTOGGLE_CATEGORY_ADMIN
	rights_required = R_MENTOR | R_ADMIN
	enable_message = "You now won't get mentor ticket messages."
	disable_message = "You now will get mentor ticket messages."
	blackbox_message = "Mentor ticket notification toggled"

/datum/preference_toggle/toggle_ahelp_notification
	name = "Toggle Admin Ticket Messages"
	description = "Disables admin ticket notifications"
	preftoggle_bitflag = PREFTOGGLE_CHAT_NO_TICKETLOGS
	preftoggle_toggle = PREFTOGGLE_TOGGLE1
	preftoggle_category = PREFTOGGLE_CATEGORY_ADMIN
	rights_required = R_ADMIN
	enable_message = "You now won't get admin ticket messages."
	disable_message = "You now will get admin ticket messages."
	blackbox_message = "Admin ticket notification toggled"

/datum/preference_toggle/toggle_debug_logs
	name = "Toggle Debug Log Messages"
	description = "Disables debug notifications (Runtimes, ghost role notifications, weird checks that weren't removed)"
	preftoggle_bitflag = PREFTOGGLE_CHAT_DEBUGLOGS
	preftoggle_toggle = PREFTOGGLE_TOGGLE1
	preftoggle_category = PREFTOGGLE_CATEGORY_ADMIN
	rights_required = R_VIEWRUNTIMES | R_DEBUG
	enable_message = "You now won't get debug logs."
	disable_message = "You now will get debug logs."
	blackbox_message = "Debug logs toggled"

/datum/preference_toggle/toggle_mctabs
	name = "Toggle MC tab"
	description = "Toggles MC tab visibility"
	preftoggle_bitflag = PREFTOGGLE_2_MC_TAB
	preftoggle_toggle = PREFTOGGLE_TOGGLE2
	preftoggle_category = PREFTOGGLE_CATEGORY_ADMIN
	rights_required = R_VIEWRUNTIMES | R_DEBUG
	enable_message = "You'll now see subsystem information in the verb panel."
	disable_message = "You'll no longer see subsystem information in the verb panel."
	blackbox_message = "MC tabs toggled"

/datum/preference_toggle/special_toggle
	preftoggle_toggle = PREFTOGGLE_SPECIAL

/datum/preference_toggle/special_toggle/set_toggles(client/user)
	SSblackbox.record_feedback("tally", "toggle_verbs", 1, blackbox_message)
	user.prefs.save_preferences(user)

// /datum/preference_toggle/special_toggle/toggle_adminsound_mutes
// 	name = "Manage Admin Sound Mutes"
// 	description = "Manage admins that you wont hear played audio from"
// 	preftoggle_category = PREFTOGGLE_CATEGORY_GENERAL
// 	blackbox_message = "MC tabs toggled"

// /datum/preference_toggle/special_toggle/toggle_adminsound_mutes/set_toggles(client/user)
// 	if(!length(user.prefs.admin_sound_ckey_ignore))
// 		to_chat(usr, "You have no admins with muted sounds.")
// 		return

// 	var/choice = input(usr, "Select an admin to unmute sounds from.", "Pick an admin") as null|anything in user.prefs.admin_sound_ckey_ignore
// 	if(!choice)
// 		return

// 	user.prefs.admin_sound_ckey_ignore -= choice
// 	to_chat(usr, "You will now hear sounds from <code>[choice]</code> again.")
// 	return ..()

/datum/preference_toggle/special_toggle/set_ooc_color
	name = "Set Your OOC Color"
	description = "Pick a custom OOC color"
	preftoggle_category = PREFTOGGLE_CATEGORY_ADMIN
	rights_required = R_ADMIN | R_DEBUG
	blackbox_message = "Set Own OOC"

/datum/preference_toggle/special_toggle/set_ooc_color/set_toggles(client/user)
	var/new_ooccolor = input(usr, "Please select your OOC color.", "OOC color", user.prefs.ooccolor) as color|null
	if(new_ooccolor)
		user.prefs.ooccolor = new_ooccolor
		to_chat(usr, "Your OOC color has been set to [new_ooccolor].")
	else
		user.prefs.ooccolor = initial(user.prefs.ooccolor)
		to_chat(usr, "Your OOC color has been reset.")
	return ..()

/datum/preference_toggle/special_toggle/set_attack_logs
	name = "Change Attack Log settings"
	description = "Changes what attack logs you see, ranges from all attacklogs to no attacklogs"
	preftoggle_category = PREFTOGGLE_CATEGORY_ADMIN
	rights_required = R_ADMIN
	blackbox_message = "changed attack log settings"

/datum/preference_toggle/special_toggle/set_attack_logs/set_toggles(client/user)
	var/static/list/attack_log_settings = list("All attack logs" = ATKLOG_ALL, "Almost all attack logs" = ATKLOG_ALMOSTALL, "Most attack logs" = ATKLOG_MOST, "Few attack logs" = ATKLOG_FEW, "No attack logs" = ATKLOG_NONE)
	var/input = input(usr, "Please select your Attack Log settings.") as null|anything in attack_log_settings
	if(!input)
		return
	var/attack_log_type = attack_log_settings[input]
	switch(attack_log_type)
		if(ATKLOG_ALL)
			user.prefs.atklog = ATKLOG_ALL
			to_chat(usr, "Your attack logs preference is now: show ALL attack logs")
		if(ATKLOG_ALMOSTALL)
			user.prefs.atklog = ATKLOG_ALMOSTALL
			to_chat(usr, "Your attack logs preference is now: show ALMOST ALL attack logs (notable exceptions: NPCs attacking other NPCs, vampire bites, equipping/stripping, people pushing each other over)")
		if(ATKLOG_MOST)
			user.prefs.atklog = ATKLOG_MOST
			to_chat(usr, "Your attack logs preference is now: show MOST attack logs (like ALMOST ALL, except that it also hides player v. NPC combat, and certain areas like lavaland syndie base and thunderdome)")
		if(ATKLOG_FEW)
			user.prefs.atklog = ATKLOG_FEW
			to_chat(usr, "Your attack logs preference is now: show FEW attack logs (only the most important stuff: attacks on SSDs, use of explosives, messing with the engine, gibbing, AI wiping, forcefeeding, acid sprays, and organ extraction)")
		if(ATKLOG_NONE)
			user.prefs.atklog = ATKLOG_NONE
			to_chat(usr, "Your attack logs preference is now: show NO attack logs")
	return ..()

/datum/preference_toggle/toggle_attack_animations
	name = "Toggle Attack Animations"
	description = "Toggle seeing an attack animation"
	preftoggle_bitflag = PREFTOGGLE_2_ITEMATTACK
	preftoggle_toggle = PREFTOGGLE_TOGGLE2
	preftoggle_category = PREFTOGGLE_CATEGORY_LIVING
	enable_message = "You will now see attack animations."
	disable_message = "You will no longer see attack animations."

/datum/preference_toggle/toggleprayers
	name = "Toggle Prayers"
	description = "Toggles seeing prayers"
	preftoggle_bitflag = PREFTOGGLE_CHAT_PRAYER
	preftoggle_toggle = PREFTOGGLE_TOGGLE1
	preftoggle_category = PREFTOGGLE_CATEGORY_ADMIN
	rights_required = R_ADMIN
	enable_message = "You will now see prayerchat."
	disable_message = "You will no longer see prayerchat."
	blackbox_message = "Toggle Prayers"

/datum/preference_toggle/toggle_prayers_notify
	name = "Toggle Prayers Notify"
	description = "Toggles hearing prayers notify"
	preftoggle_bitflag = SOUND_PRAYERNOTIFY
	preftoggle_toggle = PREFTOGGLE_SOUND
	preftoggle_category = PREFTOGGLE_CATEGORY_ADMIN
	rights_required = R_ADMIN
	enable_message = "You will now hear when prayers are made."
	disable_message = "You will no longer hear when prayers are made."
	blackbox_message = "Toggle Prayer Sound"

/datum/preference_toggle/toggle_karma_reminder
	name = "Toggle End Round Karma Reminder"
	description = "Toggles displaying end of round karma reminder"
	preftoggle_bitflag = PREFTOGGLE_DISABLE_KARMA_REMINDER
	preftoggle_toggle = PREFTOGGLE_TOGGLE1
	preftoggle_category = PREFTOGGLE_CATEGORY_GENERAL
	enable_message = "You will now see the end of round karma reminder."
	disable_message = "You will no longer see the end of round karma reminder."
	blackbox_message = "Toggle Karma Reminder"

/datum/preference_toggle/toggle_parallax_multiz
	name = "Toggle Parallax Multi-Z"
	description = "Toggle seeing an attack animation"
	preftoggle_bitflag = PREFTOGGLE_2_PARALLAX_MULTIZ
	preftoggle_toggle = PREFTOGGLE_TOGGLE2
	preftoggle_category = PREFTOGGLE_CATEGORY_GENERAL
	enable_message = "You will now see 3D effect of multi-z parallax."
	disable_message = "You will no longer see 3D effect of multi-z parallax."
	blackbox_message = "Toggle Parallax Multi-Z"

/datum/preference_toggle/toggle_parallax_multiz/set_toggles(client/user)
	. = ..()
	var/datum/hud/my_hud = usr?.hud_used
	if(!my_hud)
		return

	for(var/group_key as anything in my_hud.master_groups)
		var/datum/plane_master_group/group = my_hud.master_groups[group_key]
		group.transform_lower_turfs(my_hud, my_hud.current_plane_offset)

/datum/preference_toggle/toggle_vote_popup
	name = "Toggle Vote Popup"
	description = "Toggles the popup of the voting window on the screen when voting starts (Now working only with map votes)"
	preftoggle_bitflag = PREFTOGGLE_2_DISABLE_VOTE_POPUPS
	preftoggle_toggle = PREFTOGGLE_TOGGLE2
	preftoggle_category = PREFTOGGLE_CATEGORY_GENERAL
	enable_message = "You will now receive popups when vote starts."
	disable_message = "You will no longer receive popups when vote starts."
	blackbox_message = "Toggle Vote Popup"

// /datum/preference_toggle/toggle_emote_indicator
// 	name = "Toggle Emote Typing Indicator"
// 	description = "Toggles showing an indicator when you are typing an emote."
// 	preftoggle_bitflag = PREFTOGGLE_2_EMOTE_BUBBLE
// 	preftoggle_toggle = PREFTOGGLE_TOGGLE2
// 	preftoggle_category = PREFTOGGLE_CATEGORY_GENERAL
// 	enable_message = "You will now  display a typing indicator for emotes."
// 	disable_message = "You will no longer  display a typing indicator for emotes."
// 	blackbox_message = "Toggle Typing Indicator (Emote)"

// /datum/preference_toggle/toggle_emote_indicator/set_toggles(client/user)
// 	. = ..()
// 	if(user.prefs.toggles & PREFTOGGLE_SHOW_TYPING)
// 		if(istype(usr))
// 			usr.set_typing_emote_indicator(FALSE)

/datum/preference_toggle/toggle_tgui_input
	name = "Toggle TGUI Input"
	description = "Switches inputs between the TGUI and the standard one"
	preftoggle_bitflag = PREFTOGGLE_2_DISABLE_TGUI_INPUT
	preftoggle_toggle = PREFTOGGLE_TOGGLE2
	preftoggle_category = PREFTOGGLE_CATEGORY_GENERAL
	enable_message = "You will no longer use TGUI Input."
	disable_message = "You will now use TGUI Input."
	blackbox_message = "Toggle TGUI Input"

/datum/preference_toggle/toggle_strip_tgui_size
    name = "Toggle TGUI strip menu size"
    description = "Toggles TGUI strip menu size between miniature and full-size."
    preftoggle_bitflag = PREFTOGGLE_2_BIG_STRIP_MENU
    preftoggle_toggle = PREFTOGGLE_TOGGLE2
    preftoggle_category = PREFTOGGLE_CATEGORY_GENERAL
    enable_message = "You will see full-size TGUI strip menu."
    disable_message = "You will see minuature TGUI strip menu."
    blackbox_message = "Toggle TGUI strip menu size"

/datum/preference_toggle/toggle_item_descritpion_tips
    name = "Toggle item description tips"
    description = "Toggles item description tips on hover."
    preftoggle_bitflag = PREFTOGGLE_2_DESC_TIPS
    preftoggle_toggle = PREFTOGGLE_TOGGLE2
    preftoggle_category = PREFTOGGLE_CATEGORY_LIVING
    enable_message = "You will see item description tips now."
    disable_message = "You will not see item description tips now."
    blackbox_message = "Toggle item description tips on hover"
