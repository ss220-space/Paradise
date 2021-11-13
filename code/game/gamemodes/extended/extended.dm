/datum/game_mode/extended
	name = "extended"
	config_tag = "extended"
	required_players = 0

/datum/game_mode/announce()
	to_chat(world, "<B>Текущий игровой режим - Extended Role-Playing!</B>")
	to_chat(world, "<B>Просто развлекайся и играй роль!</B>")

/datum/game_mode/extended/pre_setup()
	return 1

/datum/game_mode/extended/post_setup()
	..()
