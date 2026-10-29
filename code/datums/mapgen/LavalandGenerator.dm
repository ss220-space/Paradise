/datum/map_generator/cave_generator/lavaland //copies everything from CaveGenerator.dm, made for better access to it
	name = "Lavaland Base"
	weighted_simulated_turf_types = list(/turf/simulated/floor/plating/asteroid/basalt/lava_land_surface = 1)
	weighted_wall_turf_types =  list(/turf/simulated/mineral/random/volcanic = 1)

	weighted_feature_spawn_list = list(
		/obj/structure/spawner/lavaland = 2,
	) //this stuff needs to be on mob_spawn_list. This is temp stuff because we don't have any feature.... yet

	weighted_mob_spawn_list = list(
		/mob/living/simple_animal/hostile/asteroid/goliath/beast/random = 50,
		/mob/living/simple_animal/hostile/asteroid/basilisk/watcher/random = 40,
		/mob/living/simple_animal/hostile/asteroid/hivelord/legion/random = 30,
		/mob/living/simple_animal/hostile/asteroid/marrowweaver/dangerous/random = 30,
		/mob/living/simple_animal/hostile/asteroid/goldgrub = 15,
		SPAWN_MEGAFAUNA = 4,
		/obj/structure/spawner/lavaland = 2,
		/obj/structure/spawner/lavaland/legion = 2,
		/obj/structure/spawner/lavaland/goliath = 2,
		/obj/structure/spawner/lavaland/random_threat = 3,
		/obj/structure/spawner/lavaland/random_threat/dangerous = 1,
	)

	weighted_flora_spawn_list = list(
		/obj/structure/flora/ash/leaf_shroom = 2,
		/obj/structure/flora/ash/cap_shroom = 2,
		/obj/structure/flora/ash/stem_shroom = 2,
		/obj/structure/flora/ash/cacti = 1,
		/obj/structure/flora/ash/tall_shroom = 2,
		/obj/structure/flora/ash/fireblossom = 2,
		/obj/structure/flora/ash/coaltree = 1,
	)

	var/initial_basalt_chance = 40
	var/basalt_smoothing_interations = 100
	var/basalt_birth_limit = 4
	var/basalt_death_limit = 3
	var/basalt_turf = /turf/simulated/mineral/random/volcanic/hard

	var/initial_granite_chance = 25
	var/granite_smoothing_interations = 100
	var/granite_birth_limit = 4
	var/granite_death_limit = 3
	var/granite_turf = /turf/simulated/mineral/random/volcanic/hard/double

	var/big_node_min = 75
	var/big_node_max = 90

	var/list/hardness_overlay

/datum/map_generator/cave_generator/lavaland/generate_terrain(list/turfs, area/generate_in)
	if(!(generate_in.area_flags & CAVES_ALLOWED))
		return
	var/start_time = REALTIMEOFDAY
	build_hardness_overlay(turfs, generate_in.z)
	var/message = "Lavaland ore node generation finished in [(REALTIMEOFDAY - start_time)/10]s!"
	log_startup_progress_global("Mapping", message)
	return ..(turfs, generate_in)

///Rolls the ore node noise before any turf exists, so the cave walls can be created with their
///final type straight away instead of being changed into /hard variants afterwards.
/datum/map_generator/cave_generator/lavaland/proc/build_hardness_overlay(list/turfs, z)
	if(!z)
		return
	hardness_overlay = new /list(world.maxx * world.maxy)
	var/node_amount = rand(6, 10)

	var/list/possible_turfs = turfs.Copy()
	for(var/node=1 to node_amount)
		var/turf/picked_turf = pick_n_take(possible_turfs)
		if(!picked_turf)
			continue
		//time for bounds
		var/size_x = rand(big_node_min, big_node_max)
		var/size_y = rand(big_node_min, big_node_max)

		//time for noise
		var/node_gen = rustg_cnoise_generate("[initial_basalt_chance]", "[basalt_smoothing_interations]", "[basalt_birth_limit]", "[basalt_death_limit]", "[size_x + 1]", "[size_y + 1]")
		var/node_gen2 = rustg_cnoise_generate("[initial_granite_chance]", "[granite_smoothing_interations]", "[granite_birth_limit]", "[granite_death_limit]", "[size_x + 1]", "[size_y + 1]")

		var/min_x = picked_turf.x - round(size_x/2)
		var/min_y = picked_turf.y - round(size_y/2)
		var/gen_height = size_y + 1

		for(var/x = 0 to size_x)
			var/map_x = min_x + x
			if(map_x < 1 || map_x > world.maxx)
				continue
			for(var/y = 0 to size_y)
				var/map_y = min_y + y
				if(map_y < 1 || map_y > world.maxy)
					continue
				var/index = x * gen_height + y + 1
				var/hardened = text2num(node_gen[index]) + text2num(node_gen2[index])
				if(!hardened)
					continue
				hardness_overlay[world.maxx * (map_y - 1) + map_x] = hardened

/datum/map_generator/cave_generator/lavaland/get_wall_turf(turf/gen_turf)
	switch(hardness_overlay?[world.maxx * (gen_turf.y - 1) + gen_turf.x])
		if(1)
			return basalt_turf
		if(2)
			return granite_turf
	return ..()
