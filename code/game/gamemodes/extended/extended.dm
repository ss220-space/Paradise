/datum/game_mode/extended
	name = "extended"
	config_tag = "extended"
	required_players = 0


/datum/game_mode/announce()
	to_chat(world, "<b>The current game mode is - Extended Role-Playing!</b>")
	to_chat(world, "<b>Just have fun and role-play!</b>")


/datum/game_mode/extended/pre_setup()
	return TRUE

