/obj/effect/anomaly/grav
	anomaly_type = ANOMALY_TYPE_GRAV
	icon_state = "shield2"
	/// Maximum level of changing gravity on touch.
	var/grav_change_level = 0
	/// Minimum time of changing gravity on touch.
	var/grav_change_time_low = 0
	/// Maximum time of changing gravity on touch.
	var/grav_change_time_high = 0

/obj/effect/anomaly/grav/collapse()
	for(var/i = 1 to max(2, rand(tier, tier * 2)))
		sleep(2)
		for(var/atom/movable/A in range(tier * 2, src))
			if(!iseffect(A))
				A.random_throw(tier, tier * 3, tier * 2)

	. = ..()

/obj/effect/anomaly/grav/proc/random_gravity_change(atom/A)
	var/grav_delta = rand(-grav_change_level * 100, grav_change_level * 100) / 100

	if(GRAVITY_SOURCE_ANOMALY in A.gravity_sources)
		grav_delta -= A.gravity_sources[GRAVITY_SOURCE_ANOMALY]

	A.add_gravity(GRAVITY_SOURCE_ANOMALY, grav_delta)
	addtimer(CALLBACK(A, TYPE_PROC_REF(/atom, add_gravity), GRAVITY_SOURCE_ANOMALY, -grav_delta), rand(grav_change_time_low, grav_change_time_high))

/obj/effect/anomaly/grav/mob_touch_effect(mob/living/M)
	. = ..()
	random_gravity_change(M)

/obj/effect/anomaly/grav/item_touch_effect(obj/item/I)
	. = ..()
	random_gravity_change(I)

/obj/effect/anomaly/grav/tier1
	name = "малая гравитационная аномалия"
	ru_names = list(NOMINATIVE = "малая гравитационная аномалия", \
					GENITIVE = "малой гравитационной аномалии", \
					DATIVE = "малой гравитационной аномалии", \
					ACCUSATIVE = "малую гравитационную аномалию", \
					INSTRUMENTAL = "малой гравитационной аномалией", \
					PREPOSITIONAL = "малой гравитационной аномалии")
	core_type = /obj/item/assembly/signaler/anomaly/tier1/grav
	stronger_anomaly_type = /obj/effect/anomaly/grav/tier2
	tier = 1
	impulses_types = list(
		/datum/anomaly_impulse/change_grav/tier1,
		/datum/anomaly_impulse/random_throws/tier1,
	)

	grav_change_level = 1
	grav_change_time_low = 3 SECONDS
	grav_change_time_high = 5 SECONDS

/obj/effect/anomaly/grav/tier2
	name = "гравитационная аномалия"
	ru_names = list(NOMINATIVE = "гравитационная аномалия", \
					GENITIVE = "гравитационной аномалии", \
					DATIVE = "гравитационной аномалии", \
					ACCUSATIVE = "гравитационную аномалию", \
					INSTRUMENTAL = "гравитационной аномалией", \
					PREPOSITIONAL = "гравитационной аномалии")
	core_type = /obj/item/assembly/signaler/anomaly/tier2/grav
	weaker_anomaly_type = /obj/effect/anomaly/grav/tier1
	stronger_anomaly_type = /obj/effect/anomaly/grav/tier3
	tier = 2
	impulses_types = list(
		/datum/anomaly_impulse/change_grav/tier2,
		/datum/anomaly_impulse/random_throws/tier2,
	)

	grav_change_level = 2
	grav_change_time_low = 20 SECONDS
	grav_change_time_high = 60 SECONDS

/obj/effect/anomaly/grav/tier3
	name = "большая гравитационная аномалия"
	ru_names = list(NOMINATIVE = "большая гравитационная аномалия", \
					GENITIVE = "большой гравитационной аномалии", \
					DATIVE = "большой гравитационной аномалии", \
					ACCUSATIVE = "большую гравитационную аномалию", \
					INSTRUMENTAL = "большой гравитационной аномалией", \
					PREPOSITIONAL = "большой гравитационной аномалии")
	core_type = /obj/item/assembly/signaler/anomaly/tier3/grav
	weaker_anomaly_type = /obj/effect/anomaly/grav/tier2
	tier = 3
	impulses_types = list(
		/datum/anomaly_impulse/change_grav/tier3,
		/datum/anomaly_impulse/random_throws/tier3,
	)

	grav_change_level = 3
	grav_change_time_low = 5 SECONDS
	grav_change_time_high = 20 SECONDS

/obj/effect/anomaly/grav/tier3/collapse()
	for(var/i = 1 to rand(30, 60))
		var/mob/living/M = pick(GLOB.mob_living_list)
		random_gravity_change(M)

	. = ..()
