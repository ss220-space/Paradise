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

	weighted_flora_spawn_list = list(/obj/structure/flora/ash/leaf_shroom = 2,
		/obj/structure/flora/ash/cap_shroom = 2,
		/obj/structure/flora/ash/stem_shroom = 2,
		/obj/structure/flora/ash/cacti = 1,
		/obj/structure/flora/ash/tall_shroom = 2,
		/obj/structure/flora/ash/fireblossom = 2
	)

	smoothing_iterations = 50

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

/datum/map_generator/cave_generator/lavaland/generate_terrain(list/turfs)
	. = ..()
	var/start_time = REALTIMEOFDAY
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
		var/list/changing_turfs = block(picked_turf.x - round(size_x/2),picked_turf.y - round(size_y/2),picked_turf.z, picked_turf.x + round(size_x/2),picked_turf.y + round(size_y/2),picked_turf.z)
		for(var/turf/T in changing_turfs) //shitcode
			if(!ismineralturf(T))
				continue
			var/index = changing_turfs.Find(T)
			var/hardened = text2num(node_gen[index]) + text2num(node_gen2[index])
			if(!hardened)
				continue
			var/hard_path
			switch(hardened)
				if(1)
					hard_path = text2path("[T.type]/hard")
				if(2)
					hard_path = text2path("[T.type]/hard/double")
			if(!ispath(hard_path)) //erm what the shit we dont have a hard(or er) type
				continue
			var/turf/new_turf = hard_path
			new_turf = T.ChangeTurf(new_turf)

	var/message = "Lavaland Auxiliary generation finished in [(REALTIMEOFDAY - start_time)/10]s!"
	log_startup_progress_global("Mapping", message)
