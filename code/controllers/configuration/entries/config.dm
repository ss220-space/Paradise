/datum/config_entry/string/servername
	default = null

/datum/config_entry/string/server_tag_line
	default = null

/datum/config_entry/string/server_extra_features
	default = null

/datum/config_entry/number/server_suffix

/datum/config_entry/number/minimum_client_build
	default = 1421 // Build 1421 due to the middle mouse button exploit

/datum/config_entry/number/minimum_byondacc_age

/datum/config_entry/string/nudge_script_path
	default = "nudge.py"

/datum/config_entry/flag/twitch_censor

/datum/config_entry/str_list/topic_filtering_whitelist

/datum/config_entry/flag/dont_del_newmob

/datum/config_entry/string/hostedby

//unused
/datum/config_entry/flag/disable_dead_ooc

//unused
/datum/config_entry/flag/disable_dsay

/// log messages sent in OOC
/datum/config_entry/flag/log_ooc

/// log login/logout
/datum/config_entry/flag/log_access

/// log client say
/datum/config_entry/flag/log_say

/// log admin actions
/datum/config_entry/flag/log_admin
	protection = CONFIG_ENTRY_LOCKED

/// log debugging
/datum/config_entry/flag/log_debug

/// log game events
/datum/config_entry/flag/log_game

/// log voting
/datum/config_entry/flag/log_vote

/// log client whisper
/datum/config_entry/flag/log_whisper

/// log emotes
/datum/config_entry/flag/log_emote

/// log attack messages
/datum/config_entry/flag/log_attack

/// log conversion messages
/datum/config_entry/flag/log_conversion

/// log admin chat messages
/datum/config_entry/flag/log_adminchat
	protection = CONFIG_ENTRY_LOCKED

/// log admin warns
/datum/config_entry/flag/log_adminwarn

/// log pda messages
/datum/config_entry/flag/log_pda

/// log world.log << messages
/datum/config_entry/flag/log_world_output

/// logs world.log to a file
/datum/config_entry/flag/log_runtime

/// disable writing world.log to log panel / root logger of DreamDaemon
/datum/config_entry/flag/disable_root_log

/// logs all links clicked in-game. Could be used for debugging and tracking down exploits
/datum/config_entry/flag/log_hrefs

/// logs all timers in buckets on automatic bucket reset (Useful for timer debugging)
/datum/config_entry/flag/log_timers_on_bucket_reset

/// Reports roundstart active turfs. Super needful and useful for mappers for optimization sanity.
/datum/config_entry/flag/report_active_turfs

/// allows admins with relevant permissions to have their own ooc colour
/datum/config_entry/flag/allow_admin_ooccolor

/// Time it takes for the server to start the game
/datum/config_entry/number/pregame_timestart
	default = 240
/// allow votes to change mode
/datum/config_entry/flag/allow_vote_mode

/// minimum time between voting sessions (deciseconds, 10 minute default)
/datum/config_entry/number/vote_delay
	default = 6000
	integer = FALSE
	min_val = 0

/datum/config_entry/number/vote_period
	default = 600
	integer = FALSE
	min_val = 0

/// Length of time before the first autotransfer vote is called
/datum/config_entry/number/vote_autotransfer_initial
	default = 72000
	min_val = 0

/// length of time before next sequential autotransfer vote
/datum/config_entry/number/vote_autotransfer_interval
	default = 72000
	min_val = 18000

/// dead people can't vote (tbi)
/datum/config_entry/flag/vote_no_dead

/// vote does not default to nochange/norestart (tbi)
/datum/config_entry/flag/default_no_vote

/// qdel's new players if they log before they spawn in
/datum/config_entry/flag/del_new_on_log
	default = TRUE

///spawns a spellbook which gives object-type spells instead of verb-type spells for the wizard
/datum/config_entry/flag/feature_object_spell_system

///if amount of traitors scales based on amount of players
/datum/config_entry/number/traitor_scaling

///If security and such can be traitor/cult/other
/datum/config_entry/flag/protect_roles_from_antagonist

/// Gamemodes which end instantly will instead keep on going until the round ends by escape shuttle or nuke.
/datum/config_entry/flag/continuous_rounds

/// Metadata is supported.
/datum/config_entry/flag/allow_metadata

/// Gives the ability to send players a maptext popup.
/datum/config_entry/flag/popup_admin_pm

/datum/config_entry/number/ticklag
	default = 0.5
	integer = FALSE
	var/sync_validate = FALSE

/datum/config_entry/number/ticklag/New() //ticklag weirdly just mirrors fps
	var/datum/config_entry/CE = /datum/config_entry/number/fps
	default = 10 / initial(CE.default)
	..()

/datum/config_entry/number/ticklag/ValidateAndSet(str_val)
	. = text2num(str_val) > 0 && ..()
	if(.)
		sync_validate = TRUE
		var/datum/config_entry/number/fps/FPS = config.entries_by_type[/datum/config_entry/number/fps]
		if(!FPS.sync_validate)
			FPS.ValidateAndSet(10 / config_entry_value)
		sync_validate = FALSE

/datum/config_entry/number/fps
	default = 20
	integer = FALSE
	min_val = 1
	max_val = 100 //byond will start crapping out at 50, so this is just ridic
	var/sync_validate = FALSE

/datum/config_entry/number/fps/ValidateAndSet(str_val)
	. = ..()
	if(.)
		sync_validate = TRUE
		var/datum/config_entry/number/ticklag/TL = config.entries_by_type[/datum/config_entry/number/ticklag]
		if(!TL.sync_validate)
			TL.ValidateAndSet(10 / config_entry_value)
		sync_validate = FALSE

/// Default fps for clients with "0" in prefs. -1 for synced with server.
/datum/config_entry/number/clientfps
	default = 40

/// use socket_talk to communicate with other processes
/datum/config_entry/number/socket_talk

/datum/config_entry/str_list/resource_urls
	default = null
/// Ghosts can turn on Antagovision to see a HUD of who is the bad guys this round.
/datum/config_entry/flag/allow_antag_hud

/// Ghosts that turn on Antagovision cannot rejoin the round.
/datum/config_entry/flag/antag_hud_restricted

/datum/config_entry/flag/norespawn

/datum/config_entry/flag/guest_jobban
	default = TRUE

/// above this player count threshold, never-before-seen players are blocked from connecting
/datum/config_entry/number/panic_bunker_threshold

/datum/config_entry/flag/usewhitelist_database

/datum/config_entry/flag/usewhitelist_nojobbanned

/datum/config_entry/flag/mods_are_mentors

/datum/config_entry/flag/load_jobs_from_txt

///enables automuting/spam prevention
/datum/config_entry/flag/automute_on

///determines whether jobs use minimal access or expanded access.
/datum/config_entry/flag/jobs_have_minimal_access

/// Time from round start during which ghosting out is penalized
/datum/config_entry/number/round_abandon_penalty_period
	default = 30 MINUTES

/datum/config_entry/string/medal_hub_address
	default = null

/datum/config_entry/string/medal_hub_password
	default = null

///enables assistant limiting
/datum/config_entry/flag/assistant_limit

///how many assistants to security members
/datum/config_entry/number/assistant_ratio
	default = 2

// The AFK subsystem will not be activated if any of the below config values are equal or less than 0
/// How long till you get a warning while being AFK
/datum/config_entry/number/warn_afk_minimum

/// How long till you get put into cryo when you're AFK
/datum/config_entry/number/auto_cryo_afk

/// How long till you actually despawn in cryo when you're AFK (Not ssd so not automatic)
/datum/config_entry/number/auto_despawn_afk

/datum/config_entry/number/auto_cryo_ssd_mins

/datum/config_entry/flag/ssd_warning

/datum/config_entry/number/list_afk_minimum
	default = 5

/datum/config_entry/number/max_maint_drones //This many drones can spawn,
	default = 5

/datum/config_entry/flag/allow_drone_spawn //assuming the admin allow them to.
	default = TRUE

/datum/config_entry/number/drone_build_time //A drone will become available every X ticks since last drone spawn. Default is 2 minutes.
	default = 1200

/datum/config_entry/str_list/playable_species
	default = list(
		SPECIES_TAJARAN,
		SPECIES_SKRELL,
		SPECIES_UNATHI,
		SPECIES_DIONA,
		SPECIES_VULPKANIN,
		SPECIES_MOTH,
		SPECIES_DRASK,
		SPECIES_GREY,
		SPECIES_KIDAN,
		SPECIES_MACNINEPERSON,
		SPECIES_NUCLEATION,
		SPECIES_PLASMAMAN,
		SPECIES_SLIMEPERSON,
		SPECIES_VOX,
		SPECIES_WRYN,
	)

/datum/config_entry/number/alien_player_ratio
	integer = FALSE

/datum/config_entry/number/alien_to_human_ratio
	integer = FALSE

/datum/config_entry/string/server
	default = null

/datum/config_entry/string/banappeals
	default = null

/datum/config_entry/string/wikiurl
	default = "http://example.org"

/datum/config_entry/string/forumurl
	default = "http://example.org"

/datum/config_entry/string/rulesurl
	default = "http://example.org"

/datum/config_entry/string/githuburl
	default = "http://example.org"

/datum/config_entry/string/donationsurl
	default = "http://example.org"

/datum/config_entry/string/repositoryurl
	default = "http://example.org"

/datum/config_entry/string/discordurl
	default = "http://example.org"

/datum/config_entry/string/discordforumurl
	default = "http://example.org"

/datum/config_entry/string/discordbugreporturl
	default = "http://example.org"

/datum/config_entry/string/overflow_server_url
	default = null

/datum/config_entry/string/tutorial_server_url
	default = null

/datum/config_entry/flag/forbid_singulo_possession

/datum/config_entry/flag/check_randomizer

/datum/config_entry/flag/proxy_autoban

//IP Intel config entries

/datum/config_entry/string/ipintel_email

/datum/config_entry/string/ipintel_email/ValidateAndSet(str_val)
	return str_val != "ch@nge.me" && ..()

/datum/config_entry/number/ipintel_rating_bad
	default = 1
	integer = FALSE
	min_val = 0
	max_val = 1

/datum/config_entry/number/ipintel_save_good
	default = 12
	integer = FALSE
	min_val = 0

/datum/config_entry/number/ipintel_save_bad
	default = 1
	integer = FALSE
	min_val = 0

/datum/config_entry/string/ipintel_domain
	default = "check.getipintel.net"

/datum/config_entry/number/ipintel_maxplaytime

/datum/config_entry/flag/ipintel_whitelist

/datum/config_entry/string/ipintel_detailsurl
	default = "https://iphub.info/?ip="

/datum/config_entry/string/forum_link_url
	default = null

/datum/config_entry/string/forum_playerinfo_url
	default = null

///Defines whether the server uses the legacy admin system with admins.txt or the SQL system
/datum/config_entry/flag/admin_legacy_system
	protection = CONFIG_ENTRY_LOCKED

///Defines whether the server uses the legacy banning system with the files in /data or the SQL system. Config option in config.txt
/datum/config_entry/flag/ban_legacy_system
	protection = CONFIG_ENTRY_LOCKED

///Do jobs use account age restrictions? --requires database
/datum/config_entry/flag/use_age_restriction_for_jobs

///Do antags use account age restrictions? --requires database
/datum/config_entry/flag/use_age_restriction_for_antags

/datum/config_entry/flag/use_exp_tracking

/datum/config_entry/flag/use_exp_restrictions

/datum/config_entry/flag/use_exp_restrictions_admin_bypass

/datum/config_entry/number/simultaneous_pm_warning_timeout
	default = 100
///Do assistants get maint access?
/datum/config_entry/flag/assistant_maint

///How long the gateway takes before it activates. Default is 10 minutes. Only matters if roundstart_away is enabled.
/datum/config_entry/number/gateway_delay
	default = 6000
	integer = FALSE
	min_val = 0

/datum/config_entry/flag/ghost_interaction

/datum/config_entry/string/comms_password

/datum/config_entry/number/default_laws //Controls what laws the AI spawns with.
	default = 0
	min_val = 0
	max_val = 4

/datum/config_entry/number_list/station_levels
	default = list(1)

/datum/config_entry/number_list/admin_levels
	default = list(2)

/datum/config_entry/number_list/contact_levels
	default = list(1, 5)

/datum/config_entry/number_list/player_levels
	default = list(1, 3, 4, 5, 6, 7)

/datum/config_entry/number/expected_round_length
	default = 2 HOURS


/datum/config_entry/number/antag_paradise_double_antag_chance
	default = 33
	max_val = 100
	min_val = 0


/datum/config_entry/str_list/antag_paradise_random_antags_whitelist
	lowercase = TRUE
	default = list(
		ROLE_TRAITOR,
		ROLE_VAMPIRE,
	)


/datum/config_entry/keyed_list/antag_paradise_single_antags_weights
	key_mode = KEY_MODE_TEXT
	value_mode = VALUE_MODE_NUM
	default = list(
		ROLE_TRAITOR = 60,
		ROLE_THIEF = 0,
		ROLE_VAMPIRE = 20,
		ROLE_CHANGELING = 0,
	)


/datum/config_entry/keyed_list/antag_paradise_double_antags_weights
	key_mode = KEY_MODE_TEXT
	value_mode = VALUE_MODE_NUM
	default = list(
		ROLE_TRAITOR = 60,
		ROLE_THIEF = 0,
		ROLE_VAMPIRE = 20,
		ROLE_CHANGELING = 20,
	)


/datum/config_entry/keyed_list/antag_paradise_tripple_antags_weights
	key_mode = KEY_MODE_TEXT
	value_mode = VALUE_MODE_NUM
	default = list(
		ROLE_TRAITOR = 60,
		ROLE_THIEF = 0,
		ROLE_VAMPIRE = 20,
		ROLE_CHANGELING = 20,
	)


/datum/config_entry/keyed_list/antag_paradise_special_antags_weights
	key_mode = KEY_MODE_TEXT
	value_mode = VALUE_MODE_NUM
	default = list(
		"hijacker" = 10,
		"malfai" = 10,
		"ninja" = 10,
		"thief" = 10,
		"nothing" = 20,
	)


/datum/config_entry/keyed_list/antag_paradise_mode_subtypes
	key_mode = KEY_MODE_TEXT
	value_mode = VALUE_MODE_NUM
	default = list(
		ANTAG_SINGLE = 10,
		ANTAG_DOUBLE = 10,
		ANTAG_TRIPPLE = 10,
		ANTAG_RANDOM = 10,
	)


/datum/config_entry/keyed_list/antag_paradise_subtype_weights
	key_mode = KEY_MODE_TEXT
	value_mode = VALUE_MODE_NUM
	default = list(
		ANTAG_SINGLE = 6,
		ANTAG_DOUBLE = 4,
		ANTAG_TRIPPLE = 2,
	)


//Made that way because compatibility reasons.
/datum/config_entry/keyed_list/event_delay_lower
	default = list("ev_level_mundane" = 10, "ev_level_moderate" = 30, "ev_level_major" = 50) //minutes

	key_mode = KEY_MODE_TEXT
	value_mode = VALUE_MODE_NUM

/datum/config_entry/keyed_list/event_delay_lower/ValidateAndSet(str_val)
	. = ..()
	if(.)	//A bit of hacky code, but allows updating with conversion to minutes
		for(var/i in config_entry_value)
			GLOB.event_delay_lower[GLOB.string_to_severity[i]] = config_entry_value[i] MINUTES

//Made that way because compatibility reasons.
/datum/config_entry/keyed_list/event_delay_upper
	default = list("ev_level_mundane" = 15, "ev_level_moderate" = 45, "ev_level_major" = 70) //minutes
	key_mode = KEY_MODE_TEXT
	value_mode = VALUE_MODE_NUM

/datum/config_entry/keyed_list/event_delay_upper/ValidateAndSet(str_val)
	. = ..()
	if(.)	//A bit of hacky code, but allows updating with conversion to minutes
		for(var/i in config_entry_value)
			GLOB.event_delay_upper[GLOB.string_to_severity[i]] = config_entry_value[i] MINUTES

//The delay until the first time an event of the given severity runs in minutes.
//Unset setting use the EVENT_DELAY_LOWER and EVENT_DELAY_UPPER values instead.
/datum/config_entry/keyed_list/event_custom_start_minor
	default = list("lower" = 10, "upper" = 15) //minutes
	key_mode = KEY_MODE_TEXT
	value_mode = VALUE_MODE_NUM

/datum/config_entry/keyed_list/event_custom_start_moderate
	default = list("lower" = 30, "upper" = 40) //minutes
	key_mode = KEY_MODE_TEXT
	value_mode = VALUE_MODE_NUM

/datum/config_entry/keyed_list/event_custom_start_major
	default = list("lower" = 80, "upper" = 80) //minutes
	key_mode = KEY_MODE_TEXT
	value_mode = VALUE_MODE_NUM

/// Whether space turfs have ambient light or not
/datum/config_entry/flag/starlight

/datum/config_entry/flag/allow_holidays

///number of players before the server starts rerouting
/datum/config_entry/number/player_reroute_cap

/datum/config_entry/flag/disable_away_missions

/datum/config_entry/flag/disable_space_ruins

/datum/config_entry/number/extra_space_ruin_levels_min
	default = 4

/datum/config_entry/number/extra_space_ruin_levels_max
	default = 8

/datum/config_entry/flag/ooc_allowed
	default = TRUE

/datum/config_entry/flag/dooc_allowed
	default = TRUE

/datum/config_entry/flag/looc_allowed
	default = TRUE

/datum/config_entry/flag/dsay_allowed
	default = TRUE

/datum/config_entry/flag/disable_lobby_music

/datum/config_entry/flag/disable_cid_warn_popup

/datum/config_entry/number/max_loadout_points
	default = 5

/datum/config_entry/flag/disable_ooc_emoji

/datum/config_entry/flag/shutdown_on_reboot

/datum/config_entry/flag/autoreconnect

/datum/config_entry/flag/disable_karma

/datum/config_entry/number/base_mc_tick_rate
	integer = FALSE
	default = 1

/datum/config_entry/number/high_pop_mc_tick_rate
	integer = FALSE
	default = 1.1

/datum/config_entry/number/high_pop_mc_mode_amount
	default = 65

/datum/config_entry/number/disable_high_pop_mc_mode_amount
	default = 60

/datum/config_entry/flag/randomize_shift_time

/datum/config_entry/flag/enable_night_shifts

/datum/config_entry/flag/developer_express_start

/datum/config_entry/flag/disable_localhost_admin

/datum/config_entry/flag/start_now_confirmation

/datum/config_entry/number/lavaland_budget
	default = 70
	integer = FALSE
	min_val = 0

/datum/config_entry/number/can_cult_convert
	default = TRUE

/datum/config_entry/flag/enable_gamemode_player_limit

/datum/config_entry/number/byond_account_age_threshold
	default = 7

/datum/config_entry/flag/discord_webhooks_enabled

/datum/config_entry/string/discord_admin_role_id
	default = null

//Needs attention
/datum/config_entry/str_list/discord_main_webhook_urls

//Needs attention
/// Webhook URLs for the mentor webhook
/datum/config_entry/str_list/discord_mentor_webhook_urls

//Needs attention
/// Webhook URLs for the admin webhook
/datum/config_entry/str_list/discord_admin_webhook_urls

//Needs attention
/// Webhook URLs for the requests webhook
/datum/config_entry/str_list/discord_requests_webhook_urls

/// Do we want to forward all adminhelps to the discord or just ahelps when admins are offline.
/// (This does not mean all ahelps are pinged, only ahelps sent when staff are offline get the ping, regardless of this setting)
/datum/config_entry/flag/discord_forward_all_ahelps

/datum/config_entry/string/centcom_ban_db_url
	default = null

// Delay before respawning for players and drones (minutes)
/datum/config_entry/number/respawn_delay
	default = 20

/datum/config_entry/number/respawn_delay_drone
	default = 10

/datum/config_entry/flag/respawn_observer

/datum/config_entry/number/restrict_maint

/datum/config_entry/flag/full_day_logs

/datum/config_entry/flag/allow_head_of_departaments_assign_civilian

/datum/config_entry/number/auto_extended_players_num

/datum/config_entry/string/map_rotate
	default = "none"

/datum/config_entry/string/map_vote_mode
	default = "all"

//Needs proper handling?
/datum/config_entry/string/default_map
	default = null

/datum/config_entry/string/override_map
	default = null

/datum/config_entry/flag/item_animations_enabled

/datum/config_entry/flag/disable_taipan

/datum/config_entry/flag/disable_lavaland

/datum/config_entry/flag/config_errors_runtime

/// Whether demos are written, if not set demo SS never initializes
/datum/config_entry/flag/demos_enabled

//Needs proper testing
/datum/config_entry/keyed_list/probability
	key_mode = KEY_MODE_TEXT
	value_mode = VALUE_MODE_NUM

//Needs proper testing
/datum/config_entry/keyed_list/minplayers
	key_mode = KEY_MODE_TEXT
	value_mode = VALUE_MODE_NUM

//Needs proper testing
/datum/config_entry/keyed_list/emoji
	key_mode = KEY_MODE_TEXT
	value_mode = VALUE_MODE_TEXT

/datum/config_entry/number/shadowling_max_age

/datum/config_entry/flag/guest_ban

/datum/config_entry/flag/guest_ban/ValidateAndSet(str_val)
	. = ..()
	if(.)
		GLOB.guests_allowed = !config_entry_value

///CPU Affinity for FFmpeg. Check out taskset man page.
/datum/config_entry/string/ffmpeg_cpuaffinity
	protection = CONFIG_ENTRY_LOCKED | CONFIG_ENTRY_HIDDEN

//Example valid values: "0-3" or "1,4-7"
/datum/config_entry/string/ffmpeg_cpuaffinity/ValidateAndSet(str_val)
	. = ..()
	if(.)
		var/sanitized = regex(@"[^0-9,-]", "g").Replace(config_entry_value, "")
		if(config_entry_value != sanitized)
			log_config("Wrong value for setting in configuration: '[name]'. Check out taskset man page.")
		GLOB.ffmpeg_cpuaffinity = config_entry_value

/datum/config_entry/string/python_path
	default = null
	protection = CONFIG_ENTRY_LOCKED | CONFIG_ENTRY_HIDDEN

/datum/config_entry/string/python_path/ValidateAndSet(str_val)
	. = ..()
	if(.)
		if(config_entry_value)
			GLOB.python_path = config_entry_value
		else
			if(world.system_type == UNIX)
				GLOB.python_path = "/usr/bin/env python2"
			else //probably windows, if not this should work anyway
				GLOB.python_path = "pythonw"

/datum/config_entry/string/shutdown_shell_command
	default = null
	protection = CONFIG_ENTRY_LOCKED | CONFIG_ENTRY_HIDDEN

/datum/config_entry/string/shutdown_shell_command/ValidateAndSet(str_val)
	. = ..()
	if(.)
		GLOB.shutdown_shell_command = config_entry_value

/datum/config_entry/flag/disable_respawn

/datum/config_entry/flag/disable_respawn/ValidateAndSet(str_val)
	. = ..()
	if(.)
		GLOB.abandon_allowed = config_entry_value

/datum/config_entry/number/jobs_high_pop_mode_amount
	default = 80


/datum/config_entry/number/hard_deletes_overrun_threshold
	integer = FALSE
	min_val = 0
	default = 0.5

/datum/config_entry/number/hard_deletes_overrun_limit
	default = 0
	min_val = 0

/datum/config_entry/number/error_cooldown // The "cooldown" time for each occurrence of a unique error
	default = 600
	integer = FALSE
	min_val = 0


/datum/config_entry/number/error_limit // How many occurrences before the next will silence them
	default = 50


/datum/config_entry/number/error_silence_time // How long a unique error will be silenced for
	default = 6000
	integer = FALSE


/datum/config_entry/number/error_msg_delay // How long to wait between messaging admins about occurrences of a unique error
	default = 50
	integer = FALSE


/datum/config_entry/number/second_topic_limit
	default = 10
	min_val = 0


/datum/config_entry/number/minute_topic_limit
	default = 150
	min_val = 0


/datum/config_entry/number/second_click_limit
	default = 15
	min_val = 0


/datum/config_entry/number/minute_click_limit
	default = 400
	min_val = 0

/datum/config_entry/flag/cache_assets
	default = TRUE

/datum/config_entry/flag/save_spritesheets
	default = FALSE


/datum/config_entry/string/invoke_youtubedl
	protection = CONFIG_ENTRY_LOCKED | CONFIG_ENTRY_HIDDEN

/datum/config_entry/str_list/lobby_music
