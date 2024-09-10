/obj/docking_port/mobile/gamma
	name = "gamma shuttle"
	id = "gamma_shuttle"
	dwidth = 4
	height = 6
	width = 7
	dir = 4
	fly_sound = 'sound/effects/hyperspace_end.ogg'
	callTime = 10 SECONDS
	ignitionTime = 0
	roundstart_move = "gamma_away"

/obj/docking_port/mobile/gamma/request(obj/docking_port/stationary/S)
	. = ..()

	if(!.)
		GLOB.event_announcement.Announce("Центральное Командование [S.id == "gamma_home" ? "отправило" : "отозвало"] оружейный шаттл уровня Гамма.", new_sound = 'sound/AI/commandreport.ogg')
