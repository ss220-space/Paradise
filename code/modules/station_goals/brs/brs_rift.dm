//Блюспейс разлом для создания веселья и беготни на станции
/obj/brs_rift
	name = "Блюспейс Разлом"
	desc = "Аномальное образование с неизвестными свойствами загадочного синего космоса."
	icon = 'icons/obj/singularity.dmi'
	icon_state = "singularity_fog"
	anchored = TRUE
	density = FALSE
	luminosity = TRUE
	simulated = FALSE
	move_resist = INFINITY
	appearance_flags = 0
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF | FREEZE_PROOF
	pass_flags = PASSTABLE | PASSGRILLE | PASSMOB
	layer = MASSIVE_OBJ_LAYER
	alpha = 180

	//для отображения T-ray сканнера
	invisibility = INVISIBILITY_ANOMALY
	level = 1

	var/timespan = 20 MINUTES	// промужуток времени смены направления
	var/required_time_per_tile = 0	// необходимо времени перед движением на тайл
	var/counter_direction_time		// счетчик времени перед сменой направления
	var/counter_move_time 			// счетчик времени перед движением

	var/force_sized = 3		// размер разлома и критической зоны
	var/dir_move = 0		// направление
	var/dir_loc = null		// место направления

	var/type_rift = DEFAULT_RIFT
	var/related_rifts_list = list()	// связанные разломы (пр. разломы-близнецы)
	var/anomaly_mod = 1.5

/obj/brs_rift/Initialize(mapload, new_type_rift = DEFAULT_RIFT)
	. = ..()
	GLOB.poi_list |= src
	GLOB.bluespace_rifts_list.Add(src)
	START_PROCESSING(SSobj, src)

	type_rift = new_type_rift
	var/num_related_rifts = 1
	var/prename = "Блюспейс Разлом"
	switch(type_rift)
		if(SMALL_FAST_RIFT)
			force_sized = 1
			timespan = 10 MINUTES
			prename = "Блюспейс Трещина"
			num_related_rifts = 4
		if(TWINS_RIFT)
			timespan = 15 MINUTES
			force_sized = 3
			prename = "Разлом-Близнец"
			num_related_rifts = 2
		if(DEFAULT_RIFT)
			force_sized = 5
			timespan = 20 MINUTES
			prename = "Блюспейс Разлом"
		if(BIG_RIFT)
			force_sized = 7
			timespan = 25 MINUTES
			prename = "Блюспейс Жерло"
		if(HUGE_RIFT)
			force_sized = 9
			timespan = 30 MINUTES
			prename = "Блюспейс Туманность"

	transform = matrix(force_sized, 0, 0, 0, force_sized, 0) //+ перекрас?
	name = "[prename] [length(GLOB.golem_female) ? "тип: \"[pick(GLOB.golem_female)]\"" : "неизвестного типа"]"

	related_rifts_list = get_related_list(num_related_rifts, type_rift)

	var/new_colour = "#[pick(list("FFFFFF", "FF0000","FF7F00","FFFF00","00FF00","0000FF","4B0082","8F00FF"))]"
	for (var/obj/brs_rift/rift in related_rifts_list)
		rift.color = new_colour

	change_move_direction()
	change_anomaly_chance(anomaly_mod, 1)

	var/count = length(GLOB.bluespace_rifts_list)
	notify_ghosts("[name] возник на станции! Всего разломов: [count]", title = "Блюспейс Разлом!", source = src, action = NOTIFY_FOLLOW)

/obj/brs_rift/Destroy()
	GLOB.bluespace_rifts_list.Remove(src)
	GLOB.poi_list.Remove(src)
	STOP_PROCESSING(SSobj, src)
	change_anomaly_chance(anomaly_mod, 0)
	return ..()

/obj/brs_rift/process()
	move_direction()

/obj/brs_rift/proc/event_process(var/is_critical = FALSE, var/dist = 0, var/rift_range = 0)
	var/event_type = is_critical ? BRS_EVENT_CRITICAL : random_event_type(dist, rift_range)
	make_event(event_type)
	if (prob(round(100 * max(1, length(related_rifts_list))/2)))
		make_local_related_event(event_type)
	else if (length(related_rifts_list))
		for(var/obj/brs_rift/rift in related_rifts_list)
			rift.make_local_event(event_type)

/obj/brs_rift/proc/make_event(var/type)
	var/datum/event_container/container = SSevents.brs_event_containers[type]
	var/datum/event_meta/event_meta = container.acquire_event()
	new event_meta.event_type(event_meta)
	message_admins("[name] произвел ивент типа [type], [event_meta.name]")

	//Возвращаем ивент в контейнер и изменяем веса прочих ивентов
	for(var/datum/event_meta/temp_meta in container.available_events)
		temp_meta.weight += 5
	event_meta.weight = max(0, event_meta.weight - 10)
	container.available_events.Add(event_meta)

/obj/brs_rift/proc/make_local_related_event(var/type)
	message_admins("[name] произвел связанный локальный ивент типа [type]")

/obj/brs_rift/proc/make_local_event(var/type)
	message_admins("[name] произвел локальный ивент типа [type]")

/obj/brs_rift/proc/random_event_type(var/dist, var/rift_range)
	var/chance = rand(100)
	var/n = round(force_sized * (1 - dist / rift_range))
	message_admins("Выпавший рандомный номер для прошансовки: [n], а шанс: [chance], тип: [type_rift]")
	switch(chance)
		if(0 to 49-n*3)
			return BRS_EVENT_MESS
		if(50-n*3 to 79-n*2)
			return BRS_EVENT_MINOR
		if(80-n*2 to 94-n)
			return BRS_EVENT_MAJOR
		if(95-n to 100)
			return BRS_EVENT_CRITICAL

/obj/brs_rift/proc/move_direction()
	//step(src, dir_move) //walk(src, dir_move)
	if(counter_move_time < world.time)
		forceMove(get_step(src, dir_move))
		counter_move_time = world.time + required_time_per_tile
		dir_move = get_dir(src.loc, dir_loc)

	if(counter_direction_time < world.time)
		change_move_direction()

/obj/brs_rift/proc/change_move_direction()
	counter_direction_time = world.time + timespan
	counter_move_time = world.time + required_time_per_tile

	//направление в сторону тюрфа находящегося на станции в функционирующей её части
	var/turf/simulated/floor/F
	F = find_safe_turf(zlevels = src.z)
	dir_loc = F//.loc
	dir_move = get_dir(src, dir_loc)

	var/dist = get_dist(src, F)

	required_time_per_tile = round(timespan/dist)

/obj/brs_rift/attackby(obj/item/I, mob/living/user, params)
	to_chat(user, "<span class='danger'>Невозможно взаимодействовать с разломом!</span>")
	return FALSE

/obj/brs_rift/proc/change_anomaly_chance(var/mod, var/multi = TRUE)	//!!!проверить на существование модификатора
	var/list/modif_list = list(
			/datum/event/anomaly/anomaly_pyro,
			/datum/event/anomaly/anomaly_vortex,
			/datum/event/anomaly/anomaly_bluespace,
			/datum/event/anomaly/anomaly_flux,
			/datum/event/anomaly/anomaly_grav,
			/datum/event/tear,
			/datum/event/mass_hallucination,
			/datum/event/wormholes
		)

	for(var/datum/event_container/container in SSevents.event_containers)
		for(var/datum/event_meta/M in container.available_events)
			if(M.event_type in modif_list)
				if (multi)
					M.weight_mod *= mod
				else
					M.weight_mod /= mod

/obj/brs_rift/proc/get_related_list(var/n = 1, var/type_rift)
	message_admins("[n] - создаем список")
	var/list/temp_list = list()
	temp_list.Add(src)
	if(n <= 1)
		message_admins("[n] - одиночный список создали")
		return temp_list

	var/list/glob_list = GLOB.bluespace_rifts_list
	glob_list.Remove(src)
	for(var/obj/brs_rift/rift in glob_list)
		if (rift.type_rift == type_rift && length(rift.related_rifts_list) < n)
			temp_list.Add(rift)
			if(length(temp_list) >= n)
				break
	message_admins("[n] - многомерный список создали")
	return temp_list
