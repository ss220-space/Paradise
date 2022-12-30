//Блюспейс разлом для создания веселья и беготни на станции
/obj/brs_rift
	name = "Блюспейс Разлом"
	desc = "Аномальное образование с неизвестными свойствами загадочного синего космоса."
	icon = 'icons/obj/singularity.dmi'
	icon_state = "singularity_fog"
	anchored = TRUE
	density = FALSE
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

	var/force_sized = 3		//размер разлома и критической зоны
	var/dir_move = 0		//направление
	var/dir_loc = null		//место направления
	//var/critical_range = 5	//предельное допустимое расстояние сканирования

/obj/brs_rift/Initialize(mapload, type_rift = DEFAULT_RIFT)
	. = ..()
	GLOB.poi_list |= src
	GLOB.bluespace_rifts_list.Add(src)
	START_PROCESSING(SSobj, src)

	change_move_direction()
	name = "[name] [length(GLOB.golem_female) ? "тип: \"[pick(GLOB.golem_female)]\"" : "неизвестного типа"]"

	switch(type_rift)
		if(DEFAULT_RIFT)
			force_sized = 5
		if(BIG_RIFT)
			force_sized = 7
		if(HUGE_RIFT)
			force_sized = 9
		if(TWINS_RIFT)
			force_sized = 3
		if(SMALL_FAST_RIFT)
			force_sized = 1
	transform = matrix(force_sized, 0, 0, 0, force_sized, 0)

	var/count = length(GLOB.bluespace_rifts_list)
	//message_admins("[name] инициализирован в зоне [ADMIN_VERBOSEJMP(src)]. Всего разломов: [count].")
	//message_admins("[name] инициализирован [COORD(src)]. Всего разломов: [count].")
	notify_ghosts("[name] возник на станции! Всего разломов: [count]", title = "Блюспейс Разлом!", source = src, action = NOTIFY_FOLLOW)

/obj/brs_rift/Destroy()
	GLOB.bluespace_rifts_list.Remove(src)
	GLOB.poi_list.Remove(src)
	STOP_PROCESSING(SSobj, src)
	return ..()

/obj/brs_rift/attackby(obj/item/I, mob/living/user, params)
	to_chat(user, "<span class='danger'>Невозможно взаимодействовать с разломом!</span>")
	return FALSE

/obj/brs_rift/process()
	//message_admins(" === === Процесс [src.name], параметры: [dir_move] === === ")
	move_direction()

/obj/brs_rift/proc/move_direction()
	//step(src, dir_move) //walk(src, dir_move)
	if(counter_move_time < world.time)
		forceMove(get_step(src, dir_move))
		//message_admins("Разлом [src.name] движется, текущий [counter_move_time], новый: [world.time + required_time_per_tile], мировой: [world.time] ")
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

	//message_admins("Разлом [src.name] сменил направления на [dir_move],
	//\n тестовое, объекты([src], [F]); тестовое, объекты([src.loc], [F.loc]):
	//\n [get_dir(src, F)], [get_dir(src.loc, F.loc)]
	//\n [required_time_per_tile], [timespan/dist], [dist], [timespan]")
