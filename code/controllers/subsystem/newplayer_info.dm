#define LOBBY_WAIT_TIME 0.5 SECONDS
#define PLAYIND_WAIT_TIME 30 SECONDS
#define ROUND_DELAY "РАУНД ОТЛОЖЕН"
#define ROUND_STARTED "РАУНД НАЧАЛСЯ"
#define ROUND_UNKNOWN "НЕ ИЗВЕСТНО"

SUBSYSTEM_DEF(new_player_info)
	name = "New Players Info"
	wait = LOBBY_WAIT_TIME
	init_order = INIT_ORDER_NEW_PLAYERS_INFO
	priority = FIRE_PRIORITY_NEW_PLAYERS_INFO
	flags = SS_KEEP_TIMING
	runlevels = RUNLEVELS_DEFAULT | RUNLEVEL_LOBBY

/datum/controller/subsystem/new_player_info/Initialize()
	fire()
	return SS_INIT_SUCCESS

/datum/controller/subsystem/new_player_info/fire(resumed)
	var/list/data = list()

	var/time_remaining = SSticker.pregame_timeleft
	if(time_remaining == -10 || (SSticker?.delay_end && SSticker.current_state < GAME_STATE_PLAYING) || !SSticker.ticker_going)
		time_remaining = ROUND_DELAY
	else if(SSticker?.current_state >= GAME_STATE_PLAYING)
		time_remaining = ROUND_STARTED
	else if(time_remaining > 0)
		time_remaining = deciseconds_to_time_stamp(time_remaining)
	else
		time_remaining = ROUND_UNKNOWN

	data["time_remaining"] = time_remaining
	data["players"] = LAZYLEN(GLOB.clients)

	if(time_remaining != ROUND_STARTED)
		var/total_players_ready = 0

		for(var/mob/new_player/player as anything in GLOB.new_player_mobs)
			if(!player.ready)
				continue
			total_players_ready++

		data["total_players_ready"] = total_players_ready

	data["game_mode"] += (SSticker.hide_mode)? "Скрыт" : (SSticker.current_state > GAME_STATE_SETTING_UP)? SSticker.mode.name : GLOB.master_mode
	var/params = list2params(data)

	for(var/mob/new_player/viewer as anything in GLOB.new_player_mobs)
		viewer << output(params, "title_browser:update_newplayer_info")

#undef LOBBY_WAIT_TIME
#undef PLAYIND_WAIT_TIME
#undef ROUND_DELAY
#undef ROUND_STARTED
#undef ROUND_UNKNOWN
