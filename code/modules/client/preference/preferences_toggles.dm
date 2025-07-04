/client/verb/setup_character()
	set name = "Игровые настройки"
	set category = STATPANEL_SPECIALVERBS
	set desc = "Открывает меню \"Настройка персонажа\". Изменения персонажа вступят в силу с началом следующего раунда, остальные изменения – незамедлительно."
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
			to_chat(user, span_notice("[(our_prefs.toggles & preftoggle_bitflag) ? enable_message : disable_message]"))

		if(PREFTOGGLE_TOGGLE2)
			our_prefs.toggles2 ^= preftoggle_bitflag
			to_chat(user, span_notice("[(our_prefs.toggles2 & preftoggle_bitflag) ? enable_message : disable_message]"))

		if(PREFTOGGLE_TOGGLE3)
			our_prefs.toggles3 ^= preftoggle_bitflag
			to_chat(user, span_notice("[(our_prefs.toggles3 & preftoggle_bitflag) ? enable_message : disable_message]"))

		if(PREFTOGGLE_SOUND)
			our_prefs.sound ^= preftoggle_bitflag
			to_chat(user, span_notice("[(our_prefs.sound & preftoggle_bitflag) ? enable_message : disable_message]"))

	SSblackbox.record_feedback("tally", "toggle_verbs", 1, blackbox_message)
	our_prefs.save_preferences(user)

/datum/preference_toggle/toggle_ghost_ears
	name = "Слышимость речи – Призрак"
	description = "Переключает слышимость речи существ во всём мире или только в пределах видимости."
	preftoggle_bitflag = PREFTOGGLE_CHAT_GHOSTEARS
	preftoggle_toggle = PREFTOGGLE_TOGGLE1
	preftoggle_category = PREFTOGGLE_CATEGORY_GHOST
	enable_message = "Будучи призраком, теперь вы будете слышать речь существ только в пределах видимости."
	disable_message = "Будучи призраком, теперь вы будете слышать речь существ во всём мире."
	blackbox_message = "Toggle GhostEars"

/datum/preference_toggle/toggle_ghost_sight
	name = "Видимость эмоций – Призрак"
	description = "Переключает видимость эмоций существ во всём мире или только в пределах видимости."
	preftoggle_bitflag = PREFTOGGLE_CHAT_GHOSTSIGHT
	preftoggle_toggle = PREFTOGGLE_TOGGLE1
	preftoggle_category = PREFTOGGLE_CATEGORY_GHOST
	enable_message = "Будучи призраком, теперь вы будете видеть эмоции существ только в пределах видимости."
	disable_message = "Будучи призраком, теперь вы будете видеть эмоции существ во всём мире."
	blackbox_message = "Toggle GhostSight"

/datum/preference_toggle/toggle_ghost_radio
	name = "Слышимость речи – Призрак"
	description = "Переключает слышимость радиосообщений во всём мире или только в пределах видимости."
	preftoggle_bitflag = PREFTOGGLE_CHAT_GHOSTRADIO
	preftoggle_toggle = PREFTOGGLE_TOGGLE1
	enable_message = "Будучи призраком, теперь вы будете слышать радиосообщения только в пределах видимости."
	disable_message = "Будучи призраком, теперь вы будете слышать радиосообщения во всём мире."
	blackbox_message = "Toggle GhostRadio"

/datum/preference_toggle/toggle_admin_radio
	name = "Админ-радио"
	description = "Включает слышимость всех радиосообщений."
	preftoggle_bitflag = PREFTOGGLE_CHAT_RADIO
	preftoggle_toggle = PREFTOGGLE_SOUND
	preftoggle_category = PREFTOGGLE_CATEGORY_ADMIN
	rights_required = R_ADMIN
	enable_message = "Теперь вы не будете слышать все радиосообщения."
	disable_message = "Теперь вы будете слышать все радиосообщения."
	blackbox_message = "Toggle RadioChatter"

/datum/preference_toggle/toggle_ai_voice_annoucements
	name = "Слышимость аудио-оповещений ИИ"
	description = "Включает слышимость звуковых оповещений ИИ."
	preftoggle_bitflag = SOUND_AI_VOICE
	preftoggle_toggle = PREFTOGGLE_SOUND
	preftoggle_category = PREFTOGGLE_CATEGORY_GENERAL
	enable_message = "Теперь вы будете слышать звуковые оповещения ИИ."
	disable_message = "Теперь вы не будете слышать звуковые оповещения ИИ."
	blackbox_message = "Toggle AI Voice"

/datum/preference_toggle/toggle_admin_pm_sound
	name = "Звук ЛС от администрации"
	description = "Включает звуковое оповещения при личном сообщении от администрации."
	preftoggle_bitflag = SOUND_ADMINHELP
	preftoggle_toggle = PREFTOGGLE_SOUND
	preftoggle_category = PREFTOGGLE_CATEGORY_ADMIN
	rights_required = R_ADMIN
	enable_message = "Теперь вы будете слышать звуковое оповещение при получении личного сообщения от администрации."
	disable_message = "Теперь вы не будете слышать звуковое оповещение при получении личного сообщения от администрации."
	blackbox_message = "Toggle Admin Bwoinks"

/datum/preference_toggle/toggle_mentor_pm_sound
	name = "Звук ЛС от менторов"
	description = "Включает звуковое оповещения при личном сообщении от менторов."
	preftoggle_bitflag = SOUND_MENTORHELP
	preftoggle_toggle = PREFTOGGLE_SOUND
	preftoggle_category = PREFTOGGLE_CATEGORY_ADMIN
	rights_required = R_MENTOR | R_ADMIN
	enable_message = "Теперь вы будете слышать звуковое оповещение при получении личного сообщения от менторов."
	disable_message = "Теперь вы не будете слышать звуковое оповещение при получении личного сообщения от менторов."
	blackbox_message = "Toggle Mentor Bwoinks"

/datum/preference_toggle/toggle_deadchat_visibility
	name = "Видимость призрак-чата"
	description = "Включить видимость чата для призраков."
	preftoggle_bitflag = PREFTOGGLE_CHAT_DEAD
	preftoggle_toggle = PREFTOGGLE_TOGGLE1
	preftoggle_category = PREFTOGGLE_CATEGORY_GENERAL
	enable_message = "Теперь вы будете видеть призрак-чат."
	disable_message = "Теперь вы не будете видеть призрак-чат."
	blackbox_message = "Toggle Deadchat"

/datum/preference_toggle/end_of_round_scoreboard
	name = "Показ итогов по окончанию раунда"
	description = "Включает показ итогов раунда по его окончанию."
	preftoggle_bitflag = PREFTOGGLE_DISABLE_SCOREBOARD
	preftoggle_toggle = PREFTOGGLE_TOGGLE1
	preftoggle_category = PREFTOGGLE_CATEGORY_GENERAL
	enable_message = "Теперь вы будете видеть итоги раунда по его окончанию."
	disable_message = "Теперь вы не будете видеть итоги раунда по его окончанию."
	blackbox_message = "Toggle Scoreboard"

/datum/preference_toggle/title_music
	name = "Музыка в лобби"
	description = "Включает музыку в лобби."
	preftoggle_bitflag = SOUND_LOBBY
	preftoggle_toggle = PREFTOGGLE_SOUND
	preftoggle_category = PREFTOGGLE_CATEGORY_GENERAL
	enable_message = "Теперь вы будете слышать музыку в лобби."
	disable_message = "Теперь вы не будете слышать музыку в лобби."
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
	name = "Админ-MIDI"
	description = "Включает слышимость MIDI-файлов, воспроизводимых администрацией."
	preftoggle_bitflag = SOUND_MIDI
	preftoggle_toggle = PREFTOGGLE_SOUND
	preftoggle_category = PREFTOGGLE_CATEGORY_GENERAL
	enable_message = "Теперь вы будете слышать MIDI-файлы, воспроизводимые администрацией."
	disable_message = "Теперь вы не будете слышать MIDI-файлы, воспроизводимые администрацией; все текущие MIDI-файлы были отключены."
	blackbox_message = "Toggle MIDIs"

/datum/preference_toggle/toggle_admin_midis/set_toggles(client/user)
	. = ..()
	if(user.prefs.sound & ~SOUND_LOBBY)
		usr.stop_sound_channel(CHANNEL_ADMIN)

/datum/preference_toggle/toggle_ooc
	name = "OOC-чат"
	description = "Включает видимость OOC (OutOfCharacter) чата."
	preftoggle_bitflag = PREFTOGGLE_CHAT_OOC
	preftoggle_toggle = PREFTOGGLE_TOGGLE1
	preftoggle_category = PREFTOGGLE_CATEGORY_GENERAL
	enable_message = "Теперь вы будете видеть OOC-чат."
	disable_message = "Теперь вы не будете видеть OOC-чат."
	blackbox_message = "Toggle OOC"

/datum/preference_toggle/toggle_looc
	name = "LOOC-чат"
	description = "Включает видимость  LOOC (Local OutOfCharacter) чата."
	preftoggle_bitflag = PREFTOGGLE_CHAT_LOOC
	preftoggle_toggle = PREFTOGGLE_TOGGLE1
	preftoggle_category = PREFTOGGLE_CATEGORY_GENERAL
	enable_message = "Теперь вы будете видеть LOOC-чат."
	disable_message = "Теперь вы не будете видеть LOOC-чат."
	blackbox_message = "Toggle LOOC"

/datum/preference_toggle/toggle_ambience
	name = "Эмбиент"
	description = "Включает слышимость эмбиент-звуков."
	preftoggle_bitflag = SOUND_AMBIENCE
	preftoggle_toggle = PREFTOGGLE_SOUND
	preftoggle_category = PREFTOGGLE_CATEGORY_GENERAL
	enable_message = "Теперь вы будете слышать эмбиент-звуки."
	disable_message = "Теперь вы не будете слышать эмбиент-звуки."
	blackbox_message = "Toggle Ambience"

/datum/preference_toggle/toggle_ambience/set_toggles(client/user)
	. = ..()
	if(user.prefs.sound & ~SOUND_AMBIENCE)
		usr.stop_sound_channel(CHANNEL_AMBIENCE)
	user.update_ambience_pref()

/datum/preference_toggle/toggle_white_noise
	name = "Белый шум"
	description = "Включает слышимость белого шума."
	preftoggle_bitflag = SOUND_BUZZ
	preftoggle_toggle = PREFTOGGLE_SOUND
	preftoggle_category = PREFTOGGLE_CATEGORY_GENERAL
	enable_message = "Теперь вы будете слышать эмбиент белого шума."
	disable_message = "Теперь вы не будете слышать эмбиент белого шума."
	blackbox_message = "Toggle Whitenoise"

/datum/preference_toggle/toggle_white_noise/set_toggles(client/user)
	. = ..()
	if(user.prefs.sound & ~SOUND_BUZZ)
		usr.stop_sound_channel(CHANNEL_BUZZ)

/datum/preference_toggle/toggle_heartbeat_noise
	name = "Звуки сердцебиения"
	description = "Включает слышимость звуков сердцебиения."
	preftoggle_bitflag = SOUND_HEARTBEAT
	preftoggle_toggle = PREFTOGGLE_SOUND
	preftoggle_category = PREFTOGGLE_CATEGORY_GENERAL
	enable_message = "Теперь вы будете слышать звуки сердцебиения."
	disable_message = "Теперь вы не будете слышать звуки сердцебиения."
	blackbox_message = "Toggle Hearbeat"

/datum/preference_toggle/toggle_heartbeat_noise/set_toggles(client/user)
	. = ..()
	if(user.prefs.sound & ~SOUND_HEARTBEAT)
		usr.stop_sound_channel(CHANNEL_HEARTBEAT)

/datum/preference_toggle/toggle_instruments
	name = "Музыкальные инструменты"
	description = "Включает слышимость звуков музыкальных инструментов."
	preftoggle_bitflag = SOUND_INSTRUMENTS
	preftoggle_toggle = PREFTOGGLE_SOUND
	preftoggle_category = PREFTOGGLE_CATEGORY_GENERAL
	enable_message = "Теперь вы будете слышать звуки музыкальных инструментов."
	disable_message = "Теперь вы не будете слышать звуки музыкальных инструментов."
	blackbox_message = "Toggle Instruments"

/datum/preference_toggle/toggle_disco
	name = "Звуки диско-машины"
	description = "Включает слышимость диско-машины."
	preftoggle_bitflag = SOUND_DISCO
	preftoggle_toggle = PREFTOGGLE_SOUND
	preftoggle_category = PREFTOGGLE_CATEGORY_GENERAL
	enable_message = "Теперь вы будете слышать и танцевать под звуки диско-машины."
	disable_message = "Теперь вы не будете слышать и танцевать под звуки диско-машины."
	blackbox_message = "Toggle Dance Machine"

/datum/preference_toggle/toggle_disco/set_toggles(client/user)
	. = ..()
	if(user.prefs.sound & ~SOUND_DISCO)
		usr.stop_sound_channel(CHANNEL_JUKEBOX)

/datum/preference_toggle/toggle_ghost_pda
	name = "Сообщения на КПК – Призрак"
	description = "Переключает видимость КПК-сообщений."
	preftoggle_bitflag = PREFTOGGLE_CHAT_GHOSTPDA
	preftoggle_toggle = PREFTOGGLE_TOGGLE1
	preftoggle_category = PREFTOGGLE_CATEGORY_GHOST
	enable_message = "Будучи призраком, теперь вы будете видеть все КПК-сообщения."
	disable_message = "Будучи призраком, теперь вы не будете видеть все КПК-сообщения."
	blackbox_message = "Toggle Ghost PDA"

/client/verb/silence_current_midi()
	set name = "Заглушить MIDI"
	set category = STATPANEL_SPECIALVERBS
	set desc = "Заглушает текущие MIDI-файлы, проигрываемые администрацией."
	usr.stop_sound_channel(CHANNEL_ADMIN)
	to_chat(src, "Текущие проигрываемые админ-MIDI были заглушены.")

/datum/preference_toggle/toggle_runechat
	name = "Runechat-сообщения"
	description = "Переключает видимость Runechat облаков с сообщениями."
	preftoggle_bitflag = PREFTOGGLE_2_RUNECHAT
	preftoggle_toggle = PREFTOGGLE_TOGGLE2
	preftoggle_category = PREFTOGGLE_CATEGORY_GENERAL
	enable_message = "Теперь вы будете видеть Runechat облака с сообщениями."
	disable_message = "Теперь вы не будете видеть Runechat облака с сообщениями."
	blackbox_message = "Toggle Runechat"

/datum/preference_toggle/toggle_ghost_death_notifs
	name = "Уведомление о смерти – Призрак"
	description = "Включает уведомления о смерти игроков."
	preftoggle_bitflag = PREFTOGGLE_2_DEATHMESSAGE
	preftoggle_toggle = PREFTOGGLE_TOGGLE2
	preftoggle_category = PREFTOGGLE_CATEGORY_GHOST
	enable_message = "Теперь вы будете видеть уведомления в призрак-чате, если игрок в мире погибнет."
	disable_message = "Теперь вы не будете видеть уведомления в призрак-чате, если игрок в мире погибнет."
	blackbox_message = "Toggle Death Notifications"

/datum/preference_toggle/toggle_reverb
	name = "Ревербация звуков"
	description = "Включает ревербацию определённых звуков."
	preftoggle_bitflag = PREFTOGGLE_2_REVERB_DISABLE
	preftoggle_toggle = PREFTOGGLE_TOGGLE2
	preftoggle_category = PREFTOGGLE_CATEGORY_GENERAL
	enable_message = "Теперь некоторые звуки игры будут ревербироваться."
	disable_message = "Теперь никакие звуки игры не будут ревербироваться."
	blackbox_message = "Toggle reverb"

/datum/preference_toggle/toggle_simple_stat_panel
	name = "Обводка предметов"
	description = "Переключает видимость обводки предметов при наведении курсора."
	preftoggle_bitflag = PREFTOGGLE_2_SEE_ITEM_OUTLINES
	preftoggle_toggle = PREFTOGGLE_TOGGLE2
	preftoggle_category = PREFTOGGLE_CATEGORY_LIVING
	enable_message = "Теперь вы не будете видеть обводку предметов при наведении курсора мыши на них."
	disable_message = "Теперь вы будете видеть обводку предметов при наведении курсора мыши на них."
	blackbox_message = "Toggle item outlines"

/datum/preference_toggle/toggle_anonmode
	name = "Анонимный режим"
	description = "Переключает отображение вашего Ckey в некоторых местах (призрак-чат, итоги раунда, и так далее)."
	preftoggle_bitflag = PREFTOGGLE_2_ANON
	preftoggle_toggle = PREFTOGGLE_TOGGLE2
	preftoggle_category = PREFTOGGLE_CATEGORY_GENERAL
	enable_message = "Теперь ваш Ckey не будет отображаться где-либо (призрак-чат, итоги раунда, и так далее)."
	disable_message = "Теперь ваш Ckey будет отображаться в некоторых местах (призрак-чат, итоги раунда, и так далее)."
	blackbox_message = "Toggle Anon mode"

/datum/preference_toggle/toggle_typing_indicator
	name = "Индикатор наборе текста"
	description = "Переключает видимость индикатора наборе текста."
	preftoggle_bitflag = PREFTOGGLE_SHOW_TYPING
	preftoggle_toggle = PREFTOGGLE_TOGGLE1
	preftoggle_category = PREFTOGGLE_CATEGORY_LIVING
	enable_message = "Теперь индикатор набора текста не будет отображаться."
	disable_message = "Теперь индикатор набора текста будет отображаться."
	blackbox_message = "Toggle Typing Indicator (Speech)"

/datum/preference_toggle/toggle_typing_indicator/set_toggles(client/user)
	. = ..()
	if(user.prefs.toggles & PREFTOGGLE_SHOW_TYPING)
		if(istype(usr))
			usr.set_typing_indicator(FALSE)

/datum/preference_toggle/toggle_admin_logs
	name = "Логи администрации"
	description = "Переключает отображение логов администрации."
	preftoggle_bitflag = PREFTOGGLE_CHAT_NO_ADMINLOGS
	preftoggle_toggle = PREFTOGGLE_TOGGLE1
	preftoggle_category = PREFTOGGLE_CATEGORY_ADMIN
	rights_required = R_ADMIN
	enable_message = "Теперь вы не будете видеть логи администрации."
	disable_message = "Теперь вы будете видеть логи администрации."
	blackbox_message = "Admin logs toggled"

/datum/preference_toggle/toggle_mhelp_notification
	name = "Уведомления о ментор-запросах"
	description = "Переключает отображения уведомлений о запросах к менторам."
	preftoggle_bitflag = PREFTOGGLE_CHAT_NO_MENTORTICKETLOGS
	preftoggle_toggle = PREFTOGGLE_TOGGLE1
	preftoggle_category = PREFTOGGLE_CATEGORY_ADMIN
	rights_required = R_MENTOR | R_ADMIN
	enable_message = "Теперь вы не будете получать уведомления о запросах к менторам."
	disable_message = "Теперь вы будете получать уведомления о запросах к менторам."
	blackbox_message = "Mentor ticket notification toggled"

/datum/preference_toggle/toggle_ahelp_notification
	name = "Уведомления об админ-запросах"
	description = "Переключает отображения уведомлений о запросах к администрации."
	preftoggle_bitflag = PREFTOGGLE_CHAT_NO_TICKETLOGS
	preftoggle_toggle = PREFTOGGLE_TOGGLE1
	preftoggle_category = PREFTOGGLE_CATEGORY_ADMIN
	rights_required = R_ADMIN
	enable_message = "Теперь вы не будете получать уведомления о запросах к администрации."
	disable_message = "Теперь вы будете получать уведомления о запросах к администрации."
	blackbox_message = "Admin ticket notification toggled"

/datum/preference_toggle/toggle_debug_logs
	name = "Логи отладки"
	description = "Переключает отображения уведомления об отладке (Runtimes, уведомления призрак-ролей, неубранных проверок и т.д.)"
	preftoggle_bitflag = PREFTOGGLE_CHAT_DEBUGLOGS
	preftoggle_toggle = PREFTOGGLE_TOGGLE1
	preftoggle_category = PREFTOGGLE_CATEGORY_ADMIN
	rights_required = R_VIEWRUNTIMES | R_DEBUG
	enable_message = "Теперь вы не будете получать уведомления о логах отладки."
	disable_message = "Теперь вы будете получать уведомления о логах отладки."
	blackbox_message = "Debug logs toggled"

/datum/preference_toggle/toggle_mctabs
	name = "Вкладка MC"
	description = "Включает отображение вкладки MC в панели действий."
	preftoggle_bitflag = PREFTOGGLE_2_MC_TAB
	preftoggle_toggle = PREFTOGGLE_TOGGLE2
	preftoggle_category = PREFTOGGLE_CATEGORY_ADMIN
	rights_required = R_VIEWRUNTIMES | R_DEBUG
	enable_message = "Теперь вы будете видеть информацию о подсистемах в панели действий."
	disable_message = "Теперь вы не будете видеть информацию о подсистемах в панели действий."
	blackbox_message = "MC tabs toggled"

/datum/preference_toggle/toggle_split_admins_tabs
	name = "Разделение админ-вкладок"
	description = "Включает разделение админ-действий на подкатегории."
	preftoggle_bitflag = PREFTOGGLE_2_SPLIT_ADMIN_TABS
	preftoggle_toggle = PREFTOGGLE_TOGGLE2
	preftoggle_category = PREFTOGGLE_CATEGORY_ADMIN
	rights_required = R_ADMIN
	enable_message = "Теперь ваши админ-действия разделены по подкатегориям."
	disable_message = "Теперь ваши админ-действия не разделены по подкатегориям."
	blackbox_message = "Split Admins Tabs toggled"

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

// 	var/choice = tgui_input_list(usr, "Select an admin to unmute sounds from.", "Pick an admin", user.prefs.admin_sound_ckey_ignore)
// 	if(!choice)
// 		return

// 	user.prefs.admin_sound_ckey_ignore -= choice
// 	to_chat(usr, "Теперь вы будете слышать sounds from <code>[choice]</code> again.")
// 	return ..()

/datum/preference_toggle/special_toggle/set_ooc_color
	name = "Цвет OOC-сообщений"
	description = "Задаёт цвет для ваший сообщений в OOC-чате."
	preftoggle_category = PREFTOGGLE_CATEGORY_ADMIN
	rights_required = R_ADMIN | R_DEBUG
	blackbox_message = "Set Own OOC"

/datum/preference_toggle/special_toggle/set_ooc_color/set_toggles(client/user)
	var/new_ooccolor = tgui_input_color(usr, "Выберите цвет ваших сообщений в OOC-чате.", "Цвет OOC-сообщений", user.prefs.ooccolor)
	if(!isnull(new_ooccolor))
		user.prefs.ooccolor = new_ooccolor
		to_chat(usr, "Выбранный цвет OOC-сообщений – [new_ooccolor].")
	else
		user.prefs.ooccolor = initial(user.prefs.ooccolor)
		to_chat(usr, "Цвет OOC-сообщений был сброшен.")
	return ..()

/datum/preference_toggle/special_toggle/set_attack_logs
	name = "Отображение боевых сообщений"
	description = "Меняет режим отображения боевых сообщений."
	preftoggle_category = PREFTOGGLE_CATEGORY_ADMIN
	rights_required = R_ADMIN
	blackbox_message = "changed attack log settings"

/datum/preference_toggle/special_toggle/set_attack_logs/set_toggles(client/user)
	var/static/list/attack_log_settings = list("Все сообщения" = ATKLOG_ALL, "Почти все сообщения" = ATKLOG_ALMOSTALL, "Большая часть сообщений" = ATKLOG_MOST, "Некоторые сообщения" = ATKLOG_FEW, "Никакие сообщения" = ATKLOG_NONE)
	var/input = tgui_input_list(usr, "Выберите режим отображения боевых сообщений.", items = attack_log_settings)
	if(!input)
		return
	var/attack_log_type = attack_log_settings[input]
	switch(attack_log_type)
		if(ATKLOG_ALL)
			user.prefs.atklog = ATKLOG_ALL
			to_chat(usr, "Выбранный режим отображения боевых сообщений: показывать ВСЕ сообщения.")
		if(ATKLOG_ALMOSTALL)
			user.prefs.atklog = ATKLOG_ALMOSTALL
			to_chat(usr, "Выбранный режим отображения боевых сообщений: показывать ПОЧТИ ВСЕ сообщения (исключения: NPC, атакующие других NPC; укусы вампиров; надевание/снятие предметов; толчки гуманоидов другими гуманоидами).")
		if(ATKLOG_MOST)
			user.prefs.atklog = ATKLOG_MOST
			to_chat(usr, "Выбранный режим отображения боевых сообщений: показывать БОЛЬШУЮ ЧАСТЬ сообщений (идентично режиму ПОЧТИ ВСЕ, за исключением боевых сообщений между NPC и игроками, а также некоторыми локациями, такими как Лаваленд, Тайпан, тандердом и т.д.)")
		if(ATKLOG_FEW)
			user.prefs.atklog = ATKLOG_FEW
			to_chat(usr, "Выбранный режим отображения боевых сообщений: показывать НЕКОТОРЫЕ сообщения (только самое необходимое: атаки на КРС-игроков; взрывы; энего-двигатели; разрыв тела; форматирование ИИ; насильное кормление; кислотные спреи; извлечение органов).")
		if(ATKLOG_NONE)
			user.prefs.atklog = ATKLOG_NONE
			to_chat(usr, "Выбранный режим отображения боевых сообщений: не показывать НИКАКИЕ сообщения.")
	return ..()

/datum/preference_toggle/toggle_attack_animations
	name = "Анимации атаки"
	description = "Переключает видимость анимаций атаки."
	preftoggle_bitflag = PREFTOGGLE_2_ITEMATTACK
	preftoggle_toggle = PREFTOGGLE_TOGGLE2
	preftoggle_category = PREFTOGGLE_CATEGORY_LIVING
	enable_message = "Теперь вы будете видеть анимации атаки."
	disable_message = "Теперь вы не будете видеть анимации атаки."

/datum/preference_toggle/toggleprayers
	name = "Молитвы"
	description = "Включает видимость молитв в чате."
	preftoggle_bitflag = PREFTOGGLE_CHAT_PRAYER
	preftoggle_toggle = PREFTOGGLE_TOGGLE1
	preftoggle_category = PREFTOGGLE_CATEGORY_ADMIN
	rights_required = R_ADMIN
	enable_message = "Теперь вы будете видеть молитвы в чате."
	disable_message = "Теперь вы не будете видеть молитвы в чате."
	blackbox_message = "Toggle Prayers"

/datum/preference_toggle/toggle_prayers_notify
	name = "Уведомления о молитвах"
	description = "Включает слышимость уведомлений о молитвах."
	preftoggle_bitflag = SOUND_PRAYERNOTIFY
	preftoggle_toggle = PREFTOGGLE_SOUND
	preftoggle_category = PREFTOGGLE_CATEGORY_ADMIN
	rights_required = R_ADMIN
	enable_message = "Теперь вы будете слышать уведомления о совершении молитв игроками."
	disable_message = "Теперь вы не будете слышать уведомления о совершении молитв игроками."
	blackbox_message = "Toggle Prayer Sound"

/datum/preference_toggle/toggle_karma_reminder
	name = "Напоминание о карма-очках в конце раунда"
	description = "Включает отображения о карма-очках по окончании раунда."
	preftoggle_bitflag = PREFTOGGLE_DISABLE_KARMA_REMINDER
	preftoggle_toggle = PREFTOGGLE_TOGGLE1
	preftoggle_category = PREFTOGGLE_CATEGORY_GENERAL
	enable_message = "Теперь вы будете видеть напоминание о карма-очках в конце раунда."
	disable_message = "Теперь вы не будете видеть напоминание о карма-очках в конце раунда."
	blackbox_message = "Toggle Karma Reminder"

/datum/preference_toggle/toggle_parallax_multiz
	name = "Multi-Z параллакс"
	description = "Переключает видимость параллакс-эффектов Multi-Z."
	preftoggle_bitflag = PREFTOGGLE_2_PARALLAX_MULTIZ
	preftoggle_toggle = PREFTOGGLE_TOGGLE2
	preftoggle_category = PREFTOGGLE_CATEGORY_GENERAL
	enable_message = "Теперь вы будете видеть 3D-эффект Multi-Z параллакса."
	disable_message = "Теперь вы не будете видеть 3D-эффект Multi-Z параллакса."
	blackbox_message = "Toggle Parallax Multi-Z"

/datum/preference_toggle/toggle_parallax_multiz/set_toggles(client/user)
	. = ..()
	var/datum/hud/my_hud = usr?.hud_used
	if(!my_hud)
		return

	for(var/group_key as anything in my_hud.master_groups)
		var/datum/plane_master_group/group = my_hud.master_groups[group_key]
		group.build_planes_offset(my_hud, my_hud.current_plane_offset)

/datum/preference_toggle/toggle_vote_popup
	name = "Выскакивающее окно с голосованием"
	description = "Включает отображение выскакивающего окна с голосованием при его начале (работает только с голосованиями за карту)."
	preftoggle_bitflag = PREFTOGGLE_2_DISABLE_VOTE_POPUPS
	preftoggle_toggle = PREFTOGGLE_TOGGLE2
	preftoggle_category = PREFTOGGLE_CATEGORY_GENERAL
	enable_message = "Теперь при начале голосования будет появляться выскакивающее окно."
	disable_message = "Теперь при начале голосования не будет появляться выскакивающее окно."
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
	name = "TGUI-ввод"
	description = "Переключает между TGUI-вводом и стандартным."
	preftoggle_bitflag = PREFTOGGLE_2_DISABLE_TGUI_INPUT
	preftoggle_toggle = PREFTOGGLE_TOGGLE2
	preftoggle_category = PREFTOGGLE_CATEGORY_GENERAL
	enable_message = "Теперь вы не будете использовать TGUI-ввод."
	disable_message = "Теперь вы будете использовать TGUI-ввод."
	blackbox_message = "Toggle TGUI Input"

/datum/preference_toggle/toggle_strip_tgui_size
    name = "Размер TGUI strip-menu"
    description = "Переключает размер TGUI strip-menu между миниатюрным и полноэкранным."
    preftoggle_bitflag = PREFTOGGLE_2_BIG_STRIP_MENU
    preftoggle_toggle = PREFTOGGLE_TOGGLE2
    preftoggle_category = PREFTOGGLE_CATEGORY_GENERAL
    enable_message = "Теперь вы будете видеть TGUI strip menu в полноэкранном режиме."
    disable_message = "Теперь вы будете видеть TGUI strip menu в миниатюрном режиме."
    blackbox_message = "Toggle TGUI strip menu size"

/datum/preference_toggle/toggle_item_description_tips
    name = "Описания предметов при наведении"
    description = "Включает отображение описаний предмета при наведении курсора."
    preftoggle_bitflag = PREFTOGGLE_2_DESC_TIPS
    preftoggle_toggle = PREFTOGGLE_TOGGLE2
    preftoggle_category = PREFTOGGLE_CATEGORY_LIVING
    enable_message = "Теперь вы будете видеть описание предмета при наведении курсора на него."
    disable_message = "Теперь вы не будете видеть описание предмета при наведении курсора на него."
    blackbox_message = "Toggle item description tips on hover"

/datum/preference_toggle/toggle_facing_to_mouse
    name = "Следовать за курсором мыши"
    description = "Когда включено – при выбранном намерении ВРЕД ваш персонаж будет поворачиваться в сторону курсора."
    preftoggle_bitflag = PREFTOGGLE_3_FACING_TO_MOUSE
    preftoggle_toggle = PREFTOGGLE_TOGGLE3
    preftoggle_category = PREFTOGGLE_CATEGORY_LIVING
    enable_message = "Теперь ваш персонаж будет поворачиваться в сторону курсора мыши при выбранном намерении ВРЕД."
    disable_message = "Теперь ваш персонаж не будет поворачиваться в сторону курсора мыши при выбранном намерении ВРЕД."
    blackbox_message = "Переключение следования за курсором мыши."

/datum/preference_toggle/toggle_take_out_of_the_round_without_obj
    name = "Вывод из игры без цели"
    description = "Переключает разрешение антагонистам выводить вас из раунда без соответствующей цели."
    preftoggle_bitflag = PREFTOGGLE_2_GIB_WITHOUT_OBJECTIVE
    preftoggle_toggle = PREFTOGGLE_TOGGLE2
    preftoggle_category = PREFTOGGLE_CATEGORY_GENERAL
    enable_message = "Антагонисты теперь имеют право выводить вас из раунда без цели."
    disable_message = "Антагонисты больше не имеют права выводить вас из раунда без цели."
    blackbox_message = "Переключение разрешения выводить игрока из раунда"

/datum/preference_toggle/toggle_off_projectile_messages
    name = "Выключить боевые сообщения выстрелов"
    description = "Выключает большую часть сообщений, появляющихся при стрельбе."
    preftoggle_bitflag = PREFTOGGLE_2_OFF_PROJECTILE_MESSAGES
    preftoggle_toggle = PREFTOGGLE_TOGGLE2
    preftoggle_category = PREFTOGGLE_CATEGORY_GENERAL
    enable_message = "Теперь вы не будете видеть сообщения, появляющиеся при стрельбе."
    disable_message = "Теперь вы будете видеть сообщения, появляющиеся при стрельбе."
    blackbox_message = "Переключение комбат логов от выстрелов"

/datum/preference_toggle/toggle_auto_dnr
    name = "Запрет реанимации при смерти"
    description = "При смерти автоматически запрещает реанимацию вашего персонажа."
    preftoggle_bitflag = PREFTOGGLE_3_DNR_AFTER_DEATH
    preftoggle_toggle = PREFTOGGLE_TOGGLE3
    preftoggle_category = PREFTOGGLE_CATEGORY_GENERAL
    enable_message = "Смерть вашего персонажа теперь перманентная."
    disable_message = "Смерть персонажа более не перманентная."
    blackbox_message = "Переключение установки статуса DNR после смерти"

/datum/preference_toggle/ui_scale
    name = "Маштабирование UI"
    description = "Включает маштабирование содержимого UI окон."
    preftoggle_bitflag = PREFTOGGLE_3_UI_SCALE
    preftoggle_toggle = PREFTOGGLE_TOGGLE3
    preftoggle_category = PREFTOGGLE_CATEGORY_GENERAL
    enable_message = "Теперь содержимое UI маштабируется."
    disable_message = "Теперь содержимое UI не маштабируется."
    blackbox_message = "Переключение маштабирования UI"


/datum/preference_toggle/ui_scale/set_toggles(client/user)
	. = ..()
	if(!istype(user))
		return
	ASYNC
		user.acquire_dpi()
	INVOKE_ASYNC(user, TYPE_VERB_REF(/client, refresh_tgui))
	user.tgui_say?.load()


/datum/preference_toggle/pain_blurb
	name = "Переключить вывод боли на экран"
	description = "Переключает перенос сообщений о боли из чата на основной экран."
	preftoggle_bitflag = PREFTOGGLE_3_PAIN_BLURB
	preftoggle_toggle = PREFTOGGLE_TOGGLE3
	preftoggle_category = PREFTOGGLE_CATEGORY_GENERAL
	enable_message = "Теперь сообщения о боли будут выводиться на основной экран."
	disable_message = "Теперь сообщения о боли будут писаться в чат."
	blackbox_message = "Toggle painblurb"
