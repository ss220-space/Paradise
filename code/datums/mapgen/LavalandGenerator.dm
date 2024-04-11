/datum/map_generator/cave_generator/lavaland //copies everything from CaveGenerator.dm, made for better access to it
	weighted_simulated_turf_types = list(/turf/simulated/floor/plating/asteroid/basalt/lava_land_surface = 1)
	weighted_wall_turf_types =  list(/turf/simulated/mineral/random/volcanic = 1)

	weighted_feature_spawn_list = list(
		/obj/structure/spawner/lavaland = 2,
		/obj/structure/spawner/lavaland/legion = 2,
		/obj/structure/spawner/lavaland/goliath = 2,
		/obj/structure/spawner/lavaland/random_threat = 3,
		/obj/structure/spawner/lavaland/random_threat/dangerous = 1
	) //all this stuff needs to be on mob_spawn_list. This is temp stuff

	weighted_mob_spawn_list = list(/mob/living/simple_animal/hostile/asteroid/goliath/beast/random = 50,
		/mob/living/simple_animal/hostile/asteroid/basilisk/watcher/random = 40,
		/mob/living/simple_animal/hostile/asteroid/hivelord/legion/random = 30,
		SPAWN_MEGAFAUNA = 6,
		/mob/living/simple_animal/hostile/asteroid/goldgrub = 15,
		/mob/living/simple_animal/hostile/asteroid/marrowweaver/dangerous/random = 30,

	)

	weighted_flora_spawn_list = list(/obj/structure/flora/ash/leaf_shroom = 2,
		/obj/structure/flora/ash/cap_shroom = 2,
		/obj/structure/flora/ash/stem_shroom = 2,
		/obj/structure/flora/ash/cacti = 1,
		/obj/structure/flora/ash/tall_shroom = 2,
		/obj/structure/flora/ash/fireblossom = 2
	)
