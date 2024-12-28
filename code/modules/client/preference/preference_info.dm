/datum/preference_info
    var/name

/datum/preference_info/proc/get_preference_toggle()
    return

/datum/preference_info/proc/get_examine_text()
    return

/datum/preference_info/ghost_ears
    name = "Hearing All Speech as a Ghost"

/datum/preference_info/ghost_sight
    name = "Ghost Emote Viewing"

/datum/preference_info/ghost_radio
    name = "Ghost Radio"

/datum/preference_info/admin_radio
    name = "Admin Radio"

/datum/preference_info/ai_voice_announcements
    name = "AI Voice Announcements"

/datum/preference_info/admin_pm_sound
    name = "Admin PM Sound"

/datum/preference_info/mentor_pm_sound
    name = "Mentor PM Sound"

/datum/preference_info/deadchat_visibility
    name = "Deadchat Visibility"

/datum/preference_info/end_of_round_scoreboard
    name = "End of Round Scoreboard"

/datum/preference_info/title_music
    name = "Lobby Music"

/datum/preference_info/admin_midis
    name = "Admin Midis"

/datum/preference_info/ooc
    name = "OOC Chat"

/datum/preference_info/looc
    name = "LOOC Chat"

/datum/preference_info/ambience
    name = "Ambient Sounds"

/datum/preference_info/white_noise
    name = "White Noise"

/datum/preference_info/heartbeat_noise
    name = "Heartbeat Noise"

/datum/preference_info/instruments
    name = "Instruments"

/datum/preference_info/disco
    name = "Disco Machine Music"

/datum/preference_info/ghost_pda
    name = "Ghost PDA Messages"

/datum/preference_info/runechat
    name = "Runechat"

/datum/preference_info/ghost_death_notifs
    name = "Ghost Death Notifications"

/datum/preference_info/reverb
    name = "Reverb"

/datum/preference_info/simple_stat_panel
    name = "Item Outlines"

/datum/preference_info/anonmode
    name = "Anonymous Mode"

/datum/preference_info/typing_indicator
    name = "Typing Indicator"

/datum/preference_info/admin_logs
    name = "Admin Log Messages"

/datum/preference_info/mhelp_notification
    name = "Mentor Ticket Messages"

/datum/preference_info/ahelp_notification
    name = "Admin Ticket Messages"

/datum/preference_info/debug_logs
    name = "Debug Log Messages"

/datum/preference_info/mctabs
    name = "MC Tab"

/datum/preference_info/attack_animations
    name = "Attack Animations"

/datum/preference_info/prayers
    name = "Prayers"

/datum/preference_info/prayers_notify
    name = "Prayers Notify"

/datum/preference_info/karma_reminder
    name = "End Round Karma Reminder"

/datum/preference_info/parallax_multiz
    name = "Parallax Multi-Z"

/datum/preference_info/vote_popup
    name = "Vote Popup"

/datum/preference_info/tgui_input
    name = "TGUI Input"

/datum/preference_info/strip_tgui_size
    name = "TGUI Strip Menu Size"

/datum/preference_info/item_description_tips
    name = "Item Description Tips"

/datum/preference_info/take_out_of_the_round_without_obj
    name = "Вывод из игры без цели"

/datum/preference_info/deadchat_visibility/get_preference_toggle()
    return /datum/preference_toggle/deadchat_visibility

/datum/preference_info/ghost_ears/get_preference_toggle()
    return /datum/preference_toggle/ghost_ears

/datum/preference_info/ghost_sight/get_preference_toggle()
    return /datum/preference_toggle/ghost_sight

/datum/preference_info/ghost_radio/get_preference_toggle()
    return /datum/preference_toggle/ghost_radio

/datum/preference_info/admin_radio/get_preference_toggle()
    return /datum/preference_toggle/admin_radio

/datum/preference_info/ai_voice_announcements/get_preference_toggle()
    return /datum/preference_toggle/ai_voice_annoucements

/datum/preference_info/admin_pm_sound/get_preference_toggle()
    return /datum/preference_toggle/admin_pm_sound

/datum/preference_info/mentor_pm_sound/get_preference_toggle()
    return /datum/preference_toggle/mentor_pm_sound

/datum/preference_info/end_of_round_scoreboard/get_preference_toggle()
    return /datum/preference_toggle/end_of_round_scoreboard

/datum/preference_info/title_music/get_preference_toggle()
    return /datum/preference_toggle/title_music

/datum/preference_info/admin_midis/get_preference_toggle()
    return /datum/preference_toggle/admin_midis

/datum/preference_info/ooc/get_preference_toggle()
    return /datum/preference_toggle/ooc

/datum/preference_info/looc/get_preference_toggle()
    return /datum/preference_toggle/looc

/datum/preference_info/ambience/get_preference_toggle()
    return /datum/preference_toggle/ambience

/datum/preference_info/white_noise/get_preference_toggle()
    return /datum/preference_toggle/white_noise

/datum/preference_info/heartbeat_noise/get_preference_toggle()
    return /datum/preference_toggle/heartbeat_noise

/datum/preference_info/instruments/get_preference_toggle()
    return /datum/preference_toggle/instruments

/datum/preference_info/disco/get_preference_toggle()
    return /datum/preference_toggle/disco

/datum/preference_info/ghost_pda/get_preference_toggle()
    return /datum/preference_toggle/ghost_pda

/datum/preference_info/runechat/get_preference_toggle()
    return /datum/preference_toggle/runechat

/datum/preference_info/ghost_death_notifs/get_preference_toggle()
    return /datum/preference_toggle/ghost_death_notifs

/datum/preference_info/reverb/get_preference_toggle()
    return /datum/preference_toggle/reverb

/datum/preference_info/simple_stat_panel/get_preference_toggle()
    return /datum/preference_toggle/simple_stat_panel

/datum/preference_info/anonmode/get_preference_toggle()
    return /datum/preference_toggle/anonmode

/datum/preference_info/typing_indicator/get_preference_toggle()
    return /datum/preference_toggle/typing_indicator

/datum/preference_info/admin_logs/get_preference_toggle()
    return /datum/preference_toggle/admin_logs

/datum/preference_info/mhelp_notification/get_preference_toggle()
    return /datum/preference_toggle/mhelp_notification

/datum/preference_info/ahelp_notification/get_preference_toggle()
    return /datum/preference_toggle/ahelp_notification

/datum/preference_info/debug_logs/get_preference_toggle()
    return /datum/preference_toggle/debug_logs

/datum/preference_info/mctabs/get_preference_toggle()
    return /datum/preference_toggle/mctabs

/datum/preference_info/attack_animations/get_preference_toggle()
    return /datum/preference_toggle/attack_animations

/datum/preference_info/prayers/get_preference_toggle()
    return /datum/preference_toggle/toggleprayers

/datum/preference_info/prayers_notify/get_preference_toggle()
    return /datum/preference_toggle/prayers_notify

/datum/preference_info/karma_reminder/get_preference_toggle()
    return /datum/preference_toggle/karma_reminder

/datum/preference_info/parallax_multiz/get_preference_toggle()
    return /datum/preference_toggle/parallax_multiz

/datum/preference_info/vote_popup/get_preference_toggle()
    return /datum/preference_toggle/vote_popup

/datum/preference_info/tgui_input/get_preference_toggle()
    return /datum/preference_toggle/tgui_input

/datum/preference_info/strip_tgui_size/get_preference_toggle()
    return /datum/preference_toggle/strip_tgui_size

/datum/preference_info/item_descritpion_tips/get_preference_toggle()
    return /datum/preference_toggle/item_descritpion_tips

/datum/preference_info/take_out_of_the_round_without_obj/get_preference_toggle()
    return /datum/preference_toggle/take_out_of_the_round_without_obj

/datum/preference_info/take_out_of_the_round_without_obj/get_examine_text()
    return "\n<div class='examine'>[span_info("Вы можете вывести этого игрока из игры не имея соответствующей цели.")]</div>"
