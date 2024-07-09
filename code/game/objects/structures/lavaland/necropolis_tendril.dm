//Necropolis Tendrils, which spawn lavaland monsters and break into a chasm when killed
/obj/structure/spawner/lavaland
	name = "necropolis tendril"
	desc = "A vile tendril of corruption, originating deep underground. Terrible monsters are pouring out of it."

	icon = 'icons/mob/nest.dmi'
	icon_state = "tendril"

	faction = list("mining")
	max_mobs = 3
	max_integrity = 300
	mob_types = list(/mob/living/simple_animal/hostile/asteroid/basilisk/watcher/tendril = 90,
		/mob/living/simple_animal/hostile/asteroid/basilisk/watcher/icewing/tendril = 5,
		/mob/living/simple_animal/hostile/asteroid/basilisk/watcher/magmawing/tendril = 5
	)

	move_resist = INFINITY // just killing it tears a massive hole in the ground, let's not move it
	anchored = TRUE
	resistance_flags = FIRE_PROOF | LAVA_PROOF

	var/obj/effect/light_emitter/tendril/emitted_light
	scanner_taggable = TRUE
	mob_gps_id = "WT"
	spawner_gps_id = "Necropolis Tendril"

/obj/structure/spawner/lavaland/goliath
	mob_types = list(/mob/living/simple_animal/hostile/asteroid/goliath/beast/tendril)
	mob_gps_id = "GL"

/obj/structure/spawner/lavaland/legion
	mob_types = list(/mob/living/simple_animal/hostile/asteroid/hivelord/legion/tendril)
	spawn_time = 400 // say no to core farming
	mob_gps_id = "LG"

/obj/structure/spawner/lavaland/random_threat
	max_integrity = 400
	mob_types = list(
		/mob/living/simple_animal/hostile/asteroid/goliath/beast/tendril = 27,
		/mob/living/simple_animal/hostile/asteroid/hivelord/legion/tendril = 26,
		/mob/living/simple_animal/hostile/asteroid/basilisk/watcher/tendril = 26,
		/mob/living/simple_animal/hostile/asteroid/basilisk/watcher/icewing/tendril = 1,
		/mob/living/simple_animal/hostile/asteroid/marrowweaver/tendril = 20
	)
	max_mobs = 5
	spawn_time = 250 //they spawn a little faster
	mob_gps_id = "RND"

/obj/structure/spawner/lavaland/random_threat/dangerous //rare
	max_integrity = 500
	mob_types = list(
		/mob/living/simple_animal/hostile/asteroid/goliath/beast/tendril = 17,
		/mob/living/simple_animal/hostile/asteroid/hivelord/legion/tendril = 15,
		/mob/living/simple_animal/hostile/asteroid/basilisk/watcher/tendril = 18,
		/mob/living/simple_animal/hostile/asteroid/basilisk/watcher/icewing/tendril = 12,
		/mob/living/simple_animal/hostile/asteroid/basilisk/watcher/magmawing/tendril = 12,
		/mob/living/simple_animal/hostile/asteroid/marrowweaver/tendril = 12,
		/mob/living/simple_animal/hostile/asteroid/marrowweaver/frost/tendril = 14
	)
	mob_gps_id = "CHAOS"
	max_mobs = 7
	spawn_time = 150

GLOBAL_LIST_INIT(tendrils, list())

/obj/structure/spawner/lavaland/Initialize(mapload)
	. = ..()
	emitted_light = new(loc)
	GLOB.tendrils += src
	return INITIALIZE_HINT_LATELOAD

/obj/structure/spawner/lavaland/LateInitialize()
	for(var/F in RANGE_TURFS(1, src))
		if(ismineralturf(F))
			var/turf/simulated/mineral/M = F
			M.ChangeTurf(M.turf_type, FALSE, FALSE, TRUE)

/obj/structure/spawner/lavaland/deconstruct(disassembled)
	new /obj/effect/collapse(loc)
	new /obj/structure/closet/crate/necropolis/tendril(loc)
	return ..()


/obj/structure/spawner/lavaland/Destroy()
	var/last_tendril = TRUE
	if(GLOB.tendrils.len>1)
		last_tendril = FALSE

	if(last_tendril && !(flags & ADMIN_SPAWNED))
		if(SSmedals.hub_enabled)
			for(var/mob/living/L in view(7,src))
				if(L.stat || !L.client)
					continue
				SSmedals.UnlockMedal("[BOSS_MEDAL_TENDRIL] [ALL_KILL_MEDAL]", L.client)
				SSmedals.SetScore(TENDRIL_CLEAR_SCORE, L.client, 1)
	GLOB.tendrils -= src
	QDEL_NULL(emitted_light)
	return ..()

/obj/effect/light_emitter/tendril
	light_range = 4
	light_power = 2.5
	light_color = LIGHT_COLOR_LAVA

/obj/effect/collapse
	name = "collapsing necropolis tendril"
	desc = "Get clear!"
	layer = TABLE_LAYER
	icon = 'icons/mob/nest.dmi'
	icon_state = "tendril"
	anchored = TRUE
	density = TRUE
	var/obj/effect/light_emitter/tendril/emitted_light

/obj/effect/collapse/Initialize(mapload)
	. = ..()
	emitted_light = new(loc)
	visible_message("<span class='boldannounce'>The tendril writhes in fury as the earth around it begins to crack and break apart! Get back!</span>")
	visible_message("<span class='warning'>Something falls free of the tendril!</span>")
	playsound(loc, 'sound/effects/tendril_destroyed.ogg', 200, FALSE, 50, TRUE, TRUE)
	addtimer(CALLBACK(src, PROC_REF(collapse)), 50)

/obj/effect/collapse/Destroy()
	QDEL_NULL(emitted_light)
	return ..()

/obj/effect/collapse/proc/collapse()
	for(var/mob/M in range(7, src))
		shake_camera(M, 15, 1)
	playsound(get_turf(src),'sound/effects/explosionfar.ogg', 200, TRUE)
	visible_message("<span class='boldannounce'>The tendril falls inward, the ground around it widening into a yawning chasm!</span>")
	for(var/turf/T in range(2,src))
		if(!T.density)
			T.TerraformTurf(/turf/simulated/floor/chasm/straight_down/lava_land_surface)
	qdel(src)
