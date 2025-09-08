/datum/event/rogue_drone
	startWhen = 10
	endWhen = 1000
	var/list/drones_list = list()

/datum/event/rogue_drone/start()
	var/list/possible_spawns = list()
	possible_spawns += GLOB.carplist

	var/num = rand(2, 12)
	for(var/i = 0, i < num, i++)
		var/mob/living/simple_animal/hostile/malf_drone/D = new(get_turf(pick(possible_spawns)))
		drones_list.Add(D)

/datum/event/rogue_drone/announce()
	var/msg
	if(prob(33))
		msg = "Группа боевых дронов, оперируемых с борта ИКН \"Икар\", не вернулась с зачистки сектора. В случае контакта с дронами проявляйте осторожность."
	else if(prob(50))
		msg = "Потеряна связь с группой боевых дронов, оперируемых с борта ИКН \"Икар\". В случае контакта с дронами проявляйте осторожность."
	else
		msg = "Неопознанные хакеры взломали систему контроля боевых дронов, оперируемых с борта ИКН \"Икар\". В случае контакта с дронами проявляйте осторожность."
	GLOB.minor_announcement.announce(msg,
									ANNOUNCE_ROGUE_DRONE_RU
	)

/datum/event/rogue_drone/tick()
	return

/datum/event/rogue_drone/end()
	var/num_recovered = 0
	for(var/mob/living/simple_animal/hostile/malf_drone/D in drones_list)
		do_sparks(3, FALSE, D.loc)
		qdel(D)
		num_recovered++

	if(num_recovered > length(drones_list) * 0.75)
		GLOB.minor_announcement.announce("Система контроля боевых дронов сообщает, что все единицы успешно вернулись на борт ИКН \"Икар\".",
										ANNOUNCE_ROGUE_DRONE_RU
		)
	else
		GLOB.minor_announcement.announce("Система контроля боевых дронов сообщает о потере всех боевых единиц, однако жертв не зарегистрировано.",
										ANNOUNCE_ROGUE_DRONE_RU
		)
