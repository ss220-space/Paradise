#define HEADCRAB_NORMAL 0
#define HEADCRAB_FASTMIX 1
#define HEADCRAB_FAST 2
#define HEADCRAB_POISONMIX 3
#define HEADCRAB_POISON 4
#define HEADCRAB_MEGAMIX 5
#define HEADCRAB_SPAWNER 6

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

	var/num = rand(2,max_number)

	while(turfs.len > 0 && num > 0)
		var/turf/simulated/floor/T = pick(turfs)
		turfs.Remove(T)
		num--
		var/spawn_type = pick(spawn_types)
		new spawn_type(T)
		successSpawn = TRUE

	var/how_many_spawners = rand(2,4)

	while(turfs.len > 0 && how_many_spawners > 0)
		var/turf/simulated/floor/where_spawner = pick(availableareas)
		turfs.Remove(where_spawner)
		how_many_spawners--
		var/spawn_type = /obj/structure/spawner/headcrab
		new spawn_type(where_spawner)

	if(successSpawn)
		var/list/spawners = list()
		for(var/obj/structure/spawner/headcrab/headcrab_spawners in world)
			spawners += headcrab_spawners
		var/obj/structure/spawner/headcrab/spawner = pick(spawners)
		notify_ghosts("Появились хедкрабы.", source = spawner, action = NOTIFY_ATTACK, flashwindow = FALSE)


/datum/event/headcrabs/announce()
	if(successSpawn)
		GLOB.event_announcement.Announce("Биосканеры фиксируют размножение хедкрабов на борту станции. Избавьтесь от них, прежде чем это начнет влиять на продуктивность станции", "ВНИМАНИЕ: НЕОПОЗНАННЫЕ ФОРМЫ ЖИЗНИ")

#undef HEADCRAB_NORMAL
#undef HEADCRAB_FASTMIX
#undef HEADCRAB_FAST
#undef HEADCRAB_POISONMIX
#undef HEADCRAB_POISON
#undef HEADCRAB_MEGAMIX
#undef HEADCRAB_SPAWNER
