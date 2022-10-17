#define HEADCRAB_NORMAL 0
#define HEADCRAB_FASTMIX 1
#define HEADCRAB_FAST 2
#define HEADCRAB_POISONMIX 3
#define HEADCRAB_POISON 4
#define HEADCRAB_MEGAMIX 5
#define HEADCRAB_SPAWNER 6

#define TS_HIGHPOP_TRIGGER 80

/datum/event/headcrabs
	announceWhen = 60
	endWhen = 61
	var/successSpawn = FALSE	//So we don't make a command report if nothing gets spawned.
	var/locstring
	var/headcrab_type

/datum/event/headcrabs/start()
	var/list/availableareas = list()
	for(var/area/maintenance/A in world)
		availableareas += A
		availableareas -= /area/maintenance/turbine // ввиду отсутствия каких либо вентиляций, это просто точка, откуда выходит 30 хедкрабов и все. так еще кучкуются в трех тайлах
	var/area/randomarea = pick(availableareas)
	var/list/turf/simulated/floor/turfs = list()
	for(var/turf/simulated/floor/F in randomarea)
		if(turf_clear(F))
			turfs += F
	var/list/spawn_types = list()
	var/max_number
	headcrab_type = rand(0, 6)
	switch(headcrab_type)
		if(HEADCRAB_NORMAL)
			spawn_types = list(/mob/living/simple_animal/hostile/headcrab)
			max_number = 6
		if(HEADCRAB_FASTMIX)
			spawn_types = list(/mob/living/simple_animal/hostile/headcrab, /mob/living/simple_animal/hostile/headcrab/fast)
			max_number = 8
		if(HEADCRAB_FAST)
			spawn_types = list(/mob/living/simple_animal/hostile/headcrab/fast)
			max_number = 6
		if(HEADCRAB_POISONMIX)
			spawn_types = list(/mob/living/simple_animal/hostile/headcrab, /mob/living/simple_animal/hostile/headcrab/poison)
			max_number = 4
		if(HEADCRAB_POISON)
			spawn_types = list(/mob/living/simple_animal/hostile/headcrab/poison)
			max_number = 3
		if(HEADCRAB_MEGAMIX)
			spawn_types = list(/mob/living/simple_animal/hostile/headcrab, /mob/living/simple_animal/hostile/headcrab/fast, /mob/living/simple_animal/hostile/headcrab/poison)
			max_number = 10
		if(HEADCRAB_SPAWNER)
			spawn_types = list(/obj/structure/spawner/headcrab)
			max_number = 2

	if((length(GLOB.clients)) > TS_HIGHPOP_TRIGGER)
		max_number += rand(2,4)

	var/num = rand(2,max_number)

	while(turfs.len > 0 && num > 0)
		var/turf/simulated/floor/T = pick(turfs)
		turfs.Remove(T)
		num--
		var/spawn_type = pick(spawn_types)
		new spawn_type(T)
		successSpawn = TRUE

	var/how_many_spawners = rand(2,4)

	if((length(GLOB.clients)) > TS_HIGHPOP_TRIGGER)
		how_many_spawners += rand(1,2)

	while(turfs.len > 0 && how_many_spawners > 0)
		var/turf/simulated/floor/where_spawner = pick(availableareas)
		turfs.Remove(where_spawner)
		how_many_spawners--
		var/spawn_type = /obj/structure/spawner/headcrab
		new spawn_type(where_spawner)

		if(successSpawn)
			var/list/spawners = list()
			for(var/obj/structure/spawner/headcrab/headcrab_spawners in availableareas)
				spawners += headcrab_spawners
			var/obj/structure/spawner/headcrab/spawner = pick(spawners)
			notify_ghosts("Появились хедкрабы", source = spawner, action = NOTIFY_ATTACK, flashwindow = FALSE)


/datum/event/headcrabs/announce()
	if(successSpawn)
		if(prob(66))
			GLOB.event_announcement.Announce("Биосканеры фиксируют размножение хедкрабов на борту станции. Избавьтесь от них, прежде чем это начнет влиять на продуктивность станции", "ВНИМАНИЕ: НЕОПОЗНАННЫЕ ФОРМЫ ЖИЗНИ")
		else
			GLOB.event_announcement.Announce("Обнаружены неопознанные формы жизни на борту станции [station_name()]. Обезопасьте все наружные входы и выходы, включая трубопроводы и вентиляцию.", "ВНИМАНИЕ: НЕОПОЗНАННЫЕ ФОРМЫ ЖИЗНИ")

//

/datum/event/headcrab
	endWhen = 1
	var/headcrab_type

/datum/event/headcrab/setup()
	headcrab_type = pick(GLOB.hctypes)

/datum/event/headcrab/start()
	processing = 0

	var/list/candidates = SSghost_spawns.poll_candidates("Хотите стать одиноким хедкрабом?", ROLE_HEADCRAB, TRUE, poll_time = 100, source = headcrab_type)

	if(!length(candidates))
		return // yeah, thats it.

	var/mob/picked = pick(candidates)

	var/list/vents = get_valid_vent_spawns(exclude_mobs_nearby = TRUE, exclude_visible_by_mobs = TRUE)
	var/obj/vent = pick(vents)

	var/mob/living/simple_animal/hostile/headcrab/lnhc = new headcrab_type(vent.loc)
	lnhc.forceMove(vent)
	lnhc.add_ventcrawl(vent)
	lnhc.key = picked.key

/*

==================================
=                                =
=        CRABMISSILES            =
=                                =
==================================

*/

/datum/event/crabmissiles
	startWhen = 14
	announceWhen = 4
	endWhen = 40
	var/locstring
	var/how_many_capsules

/datum/event/crabmissiles/setup()

	if((length(GLOB.clients)) < TS_HIGHPOP_TRIGGER)
		how_many_capsules = rand(4,14)
	else
		how_many_capsules = rand(6,20)

/datum/event/crabmissiles/start()

	var/list/availableareas = list()

	for(var/area/security/A in world)
		availableareas += A
		availableareas -= /area/security/checkpoint

	for(var/area/bridge/A2 in world)
		availableareas += A2
		availableareas -= /area/bridge/checkpoint

	for(var/area/quartermaster/A3 in world)
		availableareas += A3

	for(var/area/medical/A4 in world)
		availableareas += A4

	for(var/area/engine/A5 in world)
		availableareas += A5
		availableareas -= /area/engine/mechanic_workshop

	for(var/area/hallway/primary/A6 in world)
		availableareas += A6

	for(var/area/crew_quarters/bar/atrium/A7 in world)
		availableareas += A7

	while(how_many_capsules > 0)
		sleep(rand(0,10)) // не, я пожалуй откажусь от таймера.
		how_many_capsules--

		var/area/randomarea = pick(availableareas)
		var/list/turf/simulated/floor/turfs = list()

		for(var/turf/simulated/floor/thefloor in randomarea)
			if(turf_clear(thefloor))
				turfs += thefloor

		var/turf/simulated/floor/where_capsule = pick(turfs)
		explosion(where_capsule, 0, 0,1,1) // поидее тряска камеры и стан близлежащих карбонов.

		var/frequency = get_rand_frequency()
		var/sound/explosion_sound = sound(get_sfx("explosion"))
		var/sound/global_boom = sound('sound/effects/explosionfar.ogg') //звук оказался не очень. оставил взрыв.

		for(var/player in GLOB.player_list)
			var/mob/hear = player
			if(hear && hear.client)
				var/turf/hear_turf = get_turf(hear)
				if(hear_turf && hear_turf.z == where_capsule.z)
					var/dist = get_dist(hear_turf, where_capsule)
					if(dist <= round(2 + world.view - 2, 1))
						hear.playsound_local(where_capsule, null, 100, 1, frequency, S = explosion_sound)
					else if(hear.can_hear() && !isspaceturf(hear.loc))
						hear << global_boom

		var/datum/effect_system/explosion/smoke/smoky = new/datum/effect_system/explosion/smoke()
		smoky.set_up(where_capsule)
		smoky.start()
		var/obj/structure/crabmissile/capsule = new /obj/structure/crabmissile(where_capsule)
		message_admins("Headcrab capsule has been landed in [where_capsule.loc.name] [ADMIN_COORDJMP(where_capsule)] ")
		log_game("Headcrab capsule has been landed in [where_capsule.loc.name]")
		headcrabs_release(null, capsule, rand(0,1))

/datum/event/crabmissiles/proc/headcrabs_release(var/mob/living/simple_animal/hostile/headcrab/headcrab_type, var/obj/structure/crabmissile/capsule, var/randomized_headcrabs)
	var/headcrabs_in_capsule

	if((length(GLOB.clients)) < TS_HIGHPOP_TRIGGER)
		headcrabs_in_capsule = rand(4,14)
	else
		headcrabs_in_capsule = rand(8,18)

	var/mixed

	if(!randomized_headcrabs)
		mixed = rand(0,1)

	if(headcrab_type == null)
		headcrab_type = pick(GLOB.hctypes)
	var/capsule_position = get_turf(capsule)

	while(headcrabs_in_capsule > 0)
		headcrabs_in_capsule--
		sleep(60)
		if(randomized_headcrabs)
			headcrab_type = pick(GLOB.hctypes)
			new headcrab_type(capsule_position)
		else
			if(!mixed)
				new headcrab_type(capsule_position)
			else
				var/type1 = pick(GLOB.hctypes)
				var/type2 = pick(GLOB.hctypes)

				while(type1 == type2)
					type2 = pick(GLOB.hctypes)

				if(prob(50))
					new type1(capsule_position)
					headcrab_type = type1
				else
					new type2(capsule_position)
					headcrab_type = type2

	step(headcrab_type, pick(NORTH, SOUTH, EAST, WEST))

/datum/event/crabmissiles/end()

	var/list/capsules = list()
	for(var/obj/structure/crabmissile/thecapsules in world)
		var/turf/T = get_turf(thecapsules)
		if(is_station_level(T.z))
			capsules += thecapsules
	var/obj/structure/crabmissile/thecapsule = pick(capsules)
	notify_ghosts("Появились хедкрабы", source = thecapsule, action = NOTIFY_ATTACK, flashwindow = FALSE)

/datum/event/crabmissiles/announce()
	if(prob(76))
		var/phalanx_report = "Внимание, [station_name()]. Было зафиксировано приближение к вам нескольких капсул, содержащих многочисленное количество паразитов 'Хедкрабы'. Слава НаноТрейзен!"
		GLOB.event_announcement.Announce(phalanx_report, "Отчет от ОСН 'Фаланга'", 'sound/AI/commandreport.ogg') //йуху, ивент, прошедший на веге. Военный Инженер...
	else if(prob(30))
		var/syndie_message
		if(prob(40))
			syndie_message = "Эй, [station_name()], мы из НИС 'Кобра', прислали к вам парочку подарочков, удачи разгребать последствия после них!" //Тайпан назван в честь змеи. Хиасса Галао (Со) унати. Почему бы не сделать отсылочку на ее капюшон? (йуху, вега, Вердж Галао)
		else
			syndie_message = "Ой. Мы случайно отправили к вам несколько капсул с хедкрабами. Ну, объект хотя бы не наш. Да, [station_name()]?"
		GLOB.event_announcement.Announce(syndie_message, "Оповещение Синдиката", 'sound/AI/intercept2.ogg')
	else
		GLOB.event_announcement.Announce("Неизвестные биологические объекты были обнаружены рядом со [station_name()], пожалуйста, будьте наготове.", "ВНИМАНИЕ: НЕОПОЗНАННЫЕ ФОРМЫ ЖИЗНИ")

#undef HEADCRAB_NORMAL
#undef HEADCRAB_FASTMIX
#undef HEADCRAB_FAST
#undef HEADCRAB_POISONMIX
#undef HEADCRAB_POISON
#undef HEADCRAB_MEGAMIX
#undef HEADCRAB_SPAWNER

#undef TS_HIGHPOP_TRIGGER
