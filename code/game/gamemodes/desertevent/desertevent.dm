#define GAMEMODE_DESERT_EVENT "desert_event"

/datum/game_mode/desert_event
	name = "desert event"
	config_tag = GAMEMODE_DESERT_EVENT

/datum/game_mode/desert_event/announce()
	to_chat(world, "<b>Текущий режим игры - Пустынный Ивент</b>")
	to_chat(world, "<b>Выживите на пустынной планете!</b>")


