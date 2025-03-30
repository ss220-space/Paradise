/obj/docking_port/mobile/gamma
	name = "gamma shuttle"
	id = "gamma_shuttle"
	dwidth = 4
	height = 6
	width = 7
	dir = 4
	fly_sound = 'sound/effects/hyperspace_end.ogg'
	rechargeTime = 0
	callTime = 8 SECONDS

/obj/docking_port/mobile/gamma/request(obj/docking_port/stationary/S)
	. = ..()

	if(!.)
		if(S.id == "gamme_home")
			GLOB.event_announcement.Announce("Ожидайте важное сообщение от нашего сотрудника.", new_sound = 'sound/announcer/gamma.ogg')
