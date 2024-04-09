/obj/docking_port/mobile/gamma
	name = "gamma shuttle"
	id = "gamma_shuttle"
	dwidth = 4
	height = 6
	width = 7
	dir = 4
	fly_sound = null
	callTime = 0
	ignitionTime = 0
	roundstart_move = "gamma_away"

/obj/docking_port/mobile/gamma/request(obj/docking_port/stationary/S)
	if(!check_dock(S))
		return
	destination = S
	dock(destination) // Slap it NOW

/obj/docking_port/mobile/gamma/dock(obj/docking_port/stationary/S1, force, transit)
	..()
	if(S1.id == "gamma_home") // Sending IN
		for(var/obj/machinery/door/airlock/hatch/gamma/H in GLOB.airlocks)
			H.unlock(TRUE)
		GLOB.event_announcement.Announce("Центральное Командование отправило оружейный шаттл уровня Гамма.", new_sound = 'sound/AI/commandreport.ogg')
	else // retrieving to CC
		for(var/obj/machinery/door/airlock/hatch/gamma/H in GLOB.airlocks)
			H.lock(TRUE)
		GLOB.event_announcement.Announce("Центральное Командование отозвало оружейный шаттл уровня Гамма.", new_sound = 'sound/AI/commandreport.ogg')
