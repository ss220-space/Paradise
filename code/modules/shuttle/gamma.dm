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
		if(!(S.id == "gamma_home"))
			GLOB.major_announcement.announce("Центральное командование отозвало оружейный шаттл уровня Гамма.",
											new_sound = 'sound/AI/gamma_recall.ogg'
			)
			return
		GLOB.major_announcement.announce("Центральное командование отправило оружейный шаттл уровня Гамма.",
										new_sound = 'sound/AI/gamma_deploy.ogg'
		)
