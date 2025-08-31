#define LOBBY_WAIT_TIME 0.5 SECONDS
#define PLAYIND_WAIT_TIME 30 SECONDS

SUBSYSTEM_DEF(new_player_info)
	name = "New Players Info"
	wait = 1 SECONDS
	init_order = INIT_ORDER_NEW_PLAYERS_INFO
	priority = FIRE_PRIORITY_NEW_PLAYERS_INFO
	flags = SS_KEEP_TIMING
	runlevels = RUNLEVELS_DEFAULT | RUNLEVEL_LOBBY

/datum/controller/subsystem/new_player_info/Initialize()
	fire()
	RegisterSignal(SSticker, COMSIG_TICKER_GAME_STATE_CHANGED, PROC_REF(on_game_state_shanged))
	return SS_INIT_SUCCESS

/datum/controller/subsystem/new_player_info/proc/on_game_state_shanged(datum/source, new_state)
	SIGNAL_HANDLER
	if(new_state >= GAME_STATE_SETTING_UP)
		wait = PLAYIND_WAIT_TIME
	else
		wait = LOBBY_WAIT_TIME

/datum/controller/subsystem/new_player_info/fire(resumed)
	var/list/data = list()
	var/total_players_ready = 0

	for(var/mob/new_player/player as anything in GLOB.new_player_mobs)
		if(player.ready)
			total_players_ready++

	var/time_remaining = SSticker.pregame_timeleft
	if(time_remaining > 0)
		time_remaining = deciseconds_to_time_stamp(time_remaining)
	else if(time_remaining == -10)
		time_remaining = "РАУНД ОТЛОЖЕН"
	else if(SSticker.current_state >= GAME_STATE_PLAYING)
		time_remaining = "РАУНД НАЧАЛСЯ"
	else
		time_remaining = "НЕ ИЗВЕСТНО"

	data += time_remaining
	data += LAZYLEN(GLOB.clients)
	data += total_players_ready
	data += (SSticker.hide_mode)? "Скрыт" : (SSticker.current_state > GAME_STATE_SETTING_UP)? SSticker.mode.name : GLOB.master_mode
	var/params = list2params(data)
	for(var/mob/new_player/viewer as anything in GLOB.new_player_mobs)
		viewer << output(params, "title_browser:update_newplayer_info")



