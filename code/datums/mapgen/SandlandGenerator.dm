/datum/map_generator/cave_generator/sandland
	name = "Sandland Base"
	weighted_simulated_turf_types = list(/turf/simulated/floor/plating/asteroid/sand = 1)
	weighted_wall_turf_types =  list(/turf/simulated/mineral/sand/random = 1)

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
		/obj/structure/flora/ash/cacti = 10,
	)

	smoothing_iterations = 50

/datum/map_generator/cave_generator/sandland/surface
	name = "Sandland Surface"

	flora_spawn_chance = 4
	weighted_mob_spawn_list = null
	initial_closed_chance = 25
	birth_limit = 5
	death_limit = 4
	smoothing_iterations = 10

/datum/map_generator/cave_generator/sandland/deep
	name = "Sandland Underground"

	initial_closed_chance = 65

	/*
	weighted_mob_spawn_list = list(
		SPAWN_MEGAFAUNA = 1,
		/mob/living/basic/mining/ice_demon = 100,
		/mob/living/basic/mining/ice_whelp = 60,
		/mob/living/basic/mining/legion/snow = 100,
		/obj/effect/spawner/random/lavaland_mob/raptor = 25,

		/obj/structure/spawner/ice_moon/demonic_portal = 6,
		/obj/structure/spawner/ice_moon/demonic_portal/ice_whelp = 6,
		/obj/structure/spawner/ice_moon/demonic_portal/snowlegion = 6,
	)
	weighted_megafauna_spawn_list = list(/mob/living/simple_animal/hostile/megafauna/colossus = 1)
	weighted_flora_spawn_list = list(
		/obj/structure/flora/rock/icy/style_random = 6,
		/obj/structure/flora/rock/pile/icy/style_random = 6,
		/obj/structure/flora/ash/chilly = 1,
	)
	*/
