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

	var/force_sized = 5		// размер разлома и критической зоны
	var/dir_move = 0		// направление
	var/dir_loc = null		// место направления

	var/type_rift = DEFAULT_RIFT
	var/num_related_rifts = 1	//Сколько разломов может быть связано
	var/related_rifts_list = list()	// связанные разломы (пр. разломы-близнецы)
	var/anomaly_mod = 1.5		//Модификатор для контейнера ивентов
	var/event_chance = 100	//Шанс появления ивентов для избегания флуда ивентами

/obj/brs_rift/crack
	name = "Блюспейс Трещина"
	type_rift = CRACK_RIFT
	force_sized = 1
	timespan = 10 MINUTES
	num_related_rifts = 4

/obj/brs_rift/twin
	name = "Разлом-Близнец"
	type_rift = TWINS_RIFT
	force_sized = 3
	timespan = 15 MINUTES
	num_related_rifts = 2

/obj/brs_rift/big
	name = "Блюспейс Жерло"
	type_rift = BIG_RIFT
	force_sized = 7
	timespan = 25 MINUTES

/obj/brs_rift/fog
	name = "Блюспейс Туманность"
	type_rift = FOG_RIFT
	force_sized = 9
	timespan = 30 MINUTES

/obj/brs_rift/twin/t_static	//Для тестов и баловства
	name = "Статичный Разлом-Близнец"
	timespan = 60 MINUTES
	invisibility = 0
	alpha = 255

/obj/brs_rift/Initialize(mapload, new_type_rift)
	. = ..()
	GLOB.poi_list |= src
	GLOB.bluespace_rifts_list.Add(src)
	START_PROCESSING(SSobj, src)

	type_rift = new_type_rift
	switch(type_rift)
		if(CRACK_RIFT)
			force_sized = 1
			timespan = 10 MINUTES
			name = "Блюспейс Трещина"
			num_related_rifts = 4
		if(TWINS_RIFT)
			timespan = 15 MINUTES
			force_sized = 3
			name = "Разлом-Близнец"
			num_related_rifts = 2
		if(DEFAULT_RIFT)
			force_sized = 5
			timespan = 20 MINUTES
			name = "Блюспейс Разлом"
		if(BIG_RIFT)
			force_sized = 7
			timespan = 25 MINUTES
			name = "Блюспейс Жерло"
		if(FOG_RIFT)
			force_sized = 9
			timespan = 30 MINUTES
			name = "Блюспейс Туманность"

	transform = matrix(force_sized, 0, 0, 0, force_sized, 0) //+ перекрас?
	name = "[name] [length(GLOB.golem_female) ? "тип: \"[pick(GLOB.golem_female)]\"" : "неизвестного типа"]"

	if (length(related_rifts_list) <= 1)
		make_related_list(num_related_rifts, type_rift)

	change_move_direction()
	change_anomaly_chance(anomaly_mod, 1)

	var/count = length(GLOB.bluespace_rifts_list)
	notify_ghosts("[name] возникло на станции! Всего разломов: [count]", title = "Блюспейс Разлом!", source = src, action = NOTIFY_FOLLOW)

/obj/brs_rift/Destroy()
	GLOB.bluespace_rifts_list.Remove(src)
	GLOB.poi_list.Remove(src)
	STOP_PROCESSING(SSobj, src)
	change_anomaly_chance(anomaly_mod, 0)
	return ..()

/obj/brs_rift/process()
	move_direction()

/obj/brs_rift/proc/event_process(var/is_critical = FALSE, var/dist = 1, var/rift_range = 1)
	var/division = round(force_sized * (1 - max(1, dist) / rift_range))

	if(prob(event_chance))
		event_chance = min(5, event_chance - (15 + division))
	else
		event_chance = max(100, event_chance + 5)
		return FALSE

	var/event_type = is_critical ? BRS_EVENT_CRITICAL : random_event_type(dist, rift_range)

	//даем шансы частого появления обычного эвента с локальным эвентом
	if(!is_critical && prob(70))
		make_event(event_type)
	if(!is_critical && prob(50))
		return FALSE
	if (prob(round(100 * max(1, length(related_rifts_list))/4)))
		make_local_related_event()
	else
		make_local_event()
	return TRUE

/obj/brs_rift/proc/make_event(var/type)
	var/datum/event_container/container = SSevents.brs_event_containers[type]
	var/datum/event_meta/event_meta = container.acquire_event()
	new event_meta.event_type(event_meta)

	//Возвращаем ивент в контейнер и изменяем веса прочих ивентов
	for(var/datum/event_meta/temp_meta in container.available_events)
		temp_meta.weight += 5
	event_meta.weight = max(0, event_meta.weight - 10)
	container.available_events.Add(event_meta)

/obj/brs_rift/proc/make_local_event()
	choose_random_event(related_rifts_list)

/obj/brs_rift/proc/make_local_related_event()
	var/list/objects_range = list()
	for(var/obj/brs_rift/rift in related_rifts_list)
		var/list/temp_range = range(round(force_sized * 2), src)
		for(var/i in temp_range)
			objects_range.Add(i)
	choose_random_related_event(objects_range)

/obj/brs_rift/proc/random_event_type(var/dist, var/rift_range, var/division)
	var/chance = rand(0, 100)
	var/n = division
	if(chance <= (49-n*3))
		return BRS_EVENT_MESS
	else if(chance >= (50-n*3) && chance <=  (79-n*2))
		return BRS_EVENT_MINOR
	else if(chance >= (80-n*2) && chance <=  (94-n))
		return BRS_EVENT_MAJOR
	else if(chance >= (95-n))
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

//Работа с весами в контейнерах
/obj/brs_rift/proc/change_anomaly_chance(var/mod, var/multi = TRUE)
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

/obj/brs_rift/proc/make_related_list(var/n = 1, var/type_rift)
	var/list/temp_list = list()
	temp_list.Add(src)
	message_admins("[name] Цвет: [color]")
	if(n <= 1)
		related_rifts_list = temp_list
		color = get_random_colour(FALSE, 0, 16)
		return

	for(var/obj/brs_rift/rift in GLOB.bluespace_rifts_list)
		if (rift.type_rift == type_rift && rift != src)
			if (length(rift.related_rifts_list) >= n)
				continue
			temp_list.Add(rift)
			if(length(temp_list) >= n)
				break

	message_admins("[name] Цвет: [color]")
	related_rifts_list = temp_list
	var/temp_colour = get_random_colour(FALSE, 0, 16)
	for(var/obj/brs_rift/rift in related_rifts_list)
		rift.related_rifts_list = related_rifts_list
		rift.color = temp_colour
	message_admins("[name] Цвет: [color]")
