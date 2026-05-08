/datum/event/carp_migration
	announceWhen	= 50
	endWhen		= 900

	/// Normal carp numbers
	var/list/spawned_mobs = list(
		/mob/living/simple_animal/hostile/carp = 95,
		/mob/living/simple_animal/hostile/carp/megacarp = 5
	)
	/// Carp infestation numbers
	var/list/spawned_infestation_mobs = list(
		/mob/living/simple_animal/hostile/carp = 60,
		/mob/living/simple_animal/hostile/carp/megacarp = 40
	)
	/// Normal koi numbers
	var/spawned_kois = list(
		/mob/living/simple_animal/hostile/carp/koi = 98,
		/mob/living/simple_animal/hostile/carp/koi/honk = 2,
	)
	/// Koi infestation numbers
	var/list/spawned_infestation_kois = list(
		/mob/living/simple_animal/hostile/carp/koi = 40,
		/mob/living/simple_animal/hostile/carp/koi/honk = 5,
		/mob/living/simple_animal/hostile/carp = 55,
	)

/datum/event/carp_migration/setup()
	announceWhen = rand(40, 60)
	endWhen = rand(600, 1200)

/datum/event/carp_migration/koi/start()
	if(HAS_TRAIT(SSstation, STATION_TRAIT_CARP_INFESTATION))
		spawn_fish(spawned_infestation_kois, length(GLOB.landmarks_list))
	else
		spawn_fish(spawned_kois, length(GLOB.landmarks_list))

/datum/event/carp_migration/announce()
	var/announcement = ""
	if(severity == EVENT_LEVEL_MAJOR || HAS_TRAIT(SSstation, STATION_TRAIT_CARP_INFESTATION))
		announcement = "Массовая миграция неизвестных биологических объектов была зафиксирована вблизи станции [station_name()], будьте наготове."
	else
		announcement = "Неизвестные биологические объекты были зафиксированы вблизи станции [station_name()], будьте наготове."
	GLOB.minor_announcement.announce(
		message = announcement,
		new_title = ANNOUNCE_UNID_LIFEFORMS_RU
	)

/datum/event/carp_migration/start()

	if(severity == EVENT_LEVEL_MAJOR || HAS_TRAIT(SSstation, STATION_TRAIT_CARP_INFESTATION))
		spawn_fish(spawned_infestation_mobs, length(GLOB.landmarks_list))
	else if(severity == EVENT_LEVEL_MODERATE)
		spawn_fish(spawned_mobs, rand(4, 6))			//12 to 30 carp, in small groups
	else
		spawn_fish(spawned_mobs, rand(1, 3), 1, 2)	//1 to 6 carp, alone or in pairs

/datum/event/carp_migration/proc/spawn_fish(spawned_mobs, num_groups, group_size_min = 3, group_size_max = 5)
	var/list/spawn_locations = list()

	var/carptype = pickweight(spawned_mobs)

	spawn_locations += GLOB.carplist
	spawn_locations = shuffle(spawn_locations)
	num_groups = min(num_groups, length(spawn_locations))

	var/i = 1
	while(i <= num_groups)
		var/group_size = rand(group_size_min, group_size_max)
		for(var/j = 1, j <= group_size, j++)
			new carptype(spawn_locations[i])
		i++
