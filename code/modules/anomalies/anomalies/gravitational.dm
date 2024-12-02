/obj/effect/anomaly/gravitational
	anomaly_type = ANOMALY_TYPE_GRAV
	icon_state = "shield2"
	/// Maximum level of changing gravity on touch.
	var/grav_change_level = 0
	/// Minimum time of changing gravity on touch.
	var/grav_change_time_low = 0
	/// Maximum time of changing gravity on touch.
	var/grav_change_time_high = 0

/obj/effect/anomaly/gravitational/collapse()
	for(var/i = 1 to max(2, rand(tier, tier * 2)))
		sleep(2)
		for(var/atom/movable/A in view(tier * 2, src))
			if(isobserver(A))
				continue

			if(!iseffect(A))
				A.random_throw(tier, tier * 3, 5)
				A.update_icon()

	. = ..()

/obj/effect/anomaly/gravitational/proc/random_gravity_change(atom/A)
	var/grav_delta = rand(-grav_change_level * 100, grav_change_level * 100) / 100
	var/id = GRAVITY_SOURCE_ANOMALY + "[rand(1, 1000000)]"

	A.add_gravity(id, grav_delta)
	addtimer(CALLBACK(A, TYPE_PROC_REF(/atom, remove_gravity_source), id), rand(grav_change_time_low, grav_change_time_high))

/obj/effect/anomaly/gravitational/mob_touch_effect(mob/living/M)
	. = ..()
	random_gravity_change(M)

/obj/effect/anomaly/gravitational/item_touch_effect(obj/item/I)
	. = ..()
	var/grav_delta = -I.get_gravity()
	var/id = GRAVITY_SOURCE_ANOMALY + "[rand(1, 1000000)]"
	I.add_gravity(id, grav_delta)
	addtimer(CALLBACK(I, TYPE_PROC_REF(/atom, remove_gravity_source), id), rand(grav_change_time_low, grav_change_time_high))

/obj/effect/anomaly/gravitational/process()
	. = ..()
	for(var/obj/O in oview(max(2, tier * 2 - 1), src))
		if(!O.anchored)
			step_towards(O,src)

/obj/effect/anomaly/gravitational/tier1
	name = "малая гравитационная аномалия"
	ru_names = list(NOMINATIVE = "малая гравитационная аномалия", \
					GENITIVE = "малой гравитационной аномалии", \
					DATIVE = "малой гравитационной аномалии", \
					ACCUSATIVE = "малую гравитационную аномалию", \
					INSTRUMENTAL = "малой гравитационной аномалией", \
					PREPOSITIONAL = "малой гравитационной аномалии")
	core_type = /obj/item/assembly/signaler/core/gravitational/tier1
	stronger_anomaly_type = /obj/effect/anomaly/gravitational/tier2
	tier = 1
	impulses_types = list(
		/datum/anomaly_impulse/change_grav/tier1,
		/datum/anomaly_impulse/random_throws/tier1,
	)

	grav_change_level = 1
	grav_change_time_low = 3 SECONDS
	grav_change_time_high = 5 SECONDS

/obj/effect/anomaly/gravitational/tier2
	name = "гравитационная аномалия"
	ru_names = list(NOMINATIVE = "гравитационная аномалия", \
					GENITIVE = "гравитационной аномалии", \
					DATIVE = "гравитационной аномалии", \
					ACCUSATIVE = "гравитационную аномалию", \
					INSTRUMENTAL = "гравитационной аномалией", \
					PREPOSITIONAL = "гравитационной аномалии")
	core_type = /obj/item/assembly/signaler/core/gravitational/tier2
	weaker_anomaly_type = /obj/effect/anomaly/gravitational/tier1
	stronger_anomaly_type = /obj/effect/anomaly/gravitational/tier3
	tier = 2
	impulses_types = list(
		/datum/anomaly_impulse/change_grav/tier2,
		/datum/anomaly_impulse/random_throws/tier2,
	)

	grav_change_level = 2
	grav_change_time_low = 20 SECONDS
	grav_change_time_high = 60 SECONDS

/obj/effect/anomaly/gravitational/tier3
	name = "большая гравитационная аномалия"
	ru_names = list(NOMINATIVE = "большая гравитационная аномалия", \
					GENITIVE = "большой гравитационной аномалии", \
					DATIVE = "большой гравитационной аномалии", \
					ACCUSATIVE = "большую гравитационную аномалию", \
					INSTRUMENTAL = "большой гравитационной аномалией", \
					PREPOSITIONAL = "большой гравитационной аномалии")
	core_type = /obj/item/assembly/signaler/core/gravitational/tier3
	weaker_anomaly_type = /obj/effect/anomaly/gravitational/tier2
	tier = 3
	impulses_types = list(
		/datum/anomaly_impulse/change_grav/tier3,
		/datum/anomaly_impulse/random_throws/tier3,
	)

	grav_change_level = 3
	grav_change_time_low = 5 SECONDS
	grav_change_time_high = 20 SECONDS

/obj/effect/anomaly/gravitational/tier3/New()
	. = ..()

	for(var/mob/living/M in GLOB.player_list)
		if(M.stat)
			continue

		if(get_dist(src, M) > 20 || z != M.z)
			return

		M.playsound_local(null, 'sound/effects/empulse.ogg', 15, TRUE)
		to_chat(M, "<span class='gravitational_anomaly'>Ваше тело становится необычайно легким... Или тяжелым... Все вокруг неестественно подрагивает.</span>") // It used in one place.

/obj/effect/anomaly/gravitational/tier3/collapse()
	for(var/i = 1 to rand(30, 60))
		var/mob/living/M = pick(GLOB.mob_living_list)
		random_gravity_change(M)

	. = ..()


//			 TIER 4 ADMIN SPAWN ONLY

/obj/effect/anomaly/gravitational/tier4
	name = "колоссальная гравитационная аномалия"
	ru_names = list(NOMINATIVE = "колоссальная гравитационная аномалия", \
					GENITIVE = "колоссальной гравитационной аномалии", \
					DATIVE = "колоссальной гравитационной аномалии", \
					ACCUSATIVE = "колоссальную гравитационную аномалию", \
					INSTRUMENTAL = "колоссальной гравитационной аномалией", \
					PREPOSITIONAL = "колоссальной гравитационной аномалии")
	core_type = /obj/item/assembly/signaler/core/gravitational/tier3/tier4
	weaker_anomaly_type = /obj/effect/anomaly/gravitational/tier3
	tier = 4
	impulses_types = list(
		/datum/anomaly_impulse/change_grav/tier4,
		/datum/anomaly_impulse/random_throws/tier4,
		/datum/anomaly_impulse/grav_fastmove,
	)

	grav_change_level = 10
	grav_change_time_low = 60 SECONDS
	grav_change_time_high = 360 SECONDS

/obj/effect/anomaly/gravitational/tier4/New()
	. = ..()

	for(var/mob/living/M in GLOB.player_list)
		if(M.stat)
			continue

		M.playsound_local(null, 'sound/effects/empulse.ogg', 15, TRUE)
		to_chat(M, "<span class='gravitational_anomaly'>Вы чувствуете, что кто-то решил поиграть в бога...</span>") // It used in one place.

/obj/effect/anomaly/gravitational/tier4/collapse()
	for(var/i = 1 to rand(100, 200))
		var/mob/living/M = pick(GLOB.mob_living_list)
		random_gravity_change(M)

	. = ..()

/obj/effect/anomaly/gravitational/tier4/do_move(dir)
	. = ..()
	for(var/turf/simulated/wall/wall in range(3, src))
		wall.take_damage(700)

	for(var/obj/structure/struct in range(3, src))
		struct.take_damage(700)

	for(var/obj/item/I in range(3, src))
		I.random_throw(tier, tier * 3, 5)

	for(var/mob/living/M in range(3, src))
		M.random_throw(tier, tier * 3, 5)

/obj/effect/anomaly/gravitational/process()
	. = ..()
	for(var/obj/O in oview(max(2, tier * 2 - 1), src))
		step_towards(O, src)
		step_towards(O, src)
