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
	GLOB.event_announcement.Announce("Ожидайте важное сообщение от нашего сотрудника.", "ВНИМАНИЕ: СБОЙНЫЕ ДРОНЫ.", 'sound/announcer/rogue_drone.ogg')

/datum/event/rogue_drone/tick()
	return

/datum/event/rogue_drone/end()
	var/num_recovered = 0
	for(var/mob/living/simple_animal/hostile/malf_drone/D in drones_list)
		do_sparks(3, 0, D.loc)
		qdel(D)
		num_recovered++

	if(num_recovered > drones_list.len * 0.75)
		GLOB.event_announcement.Announce("Система контроля боевых дронов сообщает, что все единицы успешно вернулись на борт «Икара».", "ВНИМАНИЕ: СБОЙНЫЕ ДРОНЫ.")
	else
		GLOB.event_announcement.Announce("Система контроля боевых дронов сообщает о потере всех боевых единиц, однако жертв не зарегистрировано.", "ВНИМАНИЕ: СБОЙНЫЕ ДРОНЫ.")
