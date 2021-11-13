/datum/game_mode/sandbox
	name = "sandbox"
	config_tag = "sandbox"
	required_players = 0

	uplink_welcome = "Syndicate Uplink Console:"
	uplink_uses = 10

/datum/game_mode/sandbox/announce()
	to_chat(world, "<B>Текущий игровой режим - Sandbox!</B>")
	to_chat(world, "<B>Создайте свою собственную Космическую Станцию с помощью команды sandbox-panel!</B>")

/datum/game_mode/sandbox/pre_setup()
	for(var/mob/M in GLOB.player_list)
		M.CanBuild()
	return 1

/datum/game_mode/sandbox/post_setup()
	..()
	if(emergency_shuttle)
		emergency_shuttle.no_escape = 1
