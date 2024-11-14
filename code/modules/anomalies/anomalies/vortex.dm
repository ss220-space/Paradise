/obj/effect/anomaly/vortex
	anomaly_type = ANOMALY_TYPE_VORTEX
	icon_state = "bhole3"
	/// Minimum radius at which surrounding objects are attracted.
	var/grav_pull_range_low = 0
	/// Maximum radius at which surrounding objects are attracted.
	var/grav_pull_range_high = 0
	/// The level of singularity that corresponds to the force of attraction.
	var/grav_pull_strenght = 0
	/// The radius at which collapse effects are applied.
	var/collapse_range = 0

/obj/effect/anomaly/vortex/proc/pull(atom/movable/A)
	// a - vector A->src
	var/ax = x - A.x
	var/ay = y - A.y
	var/a_len = sqrt(ax * ax + ay * ay)

	// a1 - notmalised (len = 1) vector a
	var/a1x = ax * a_len
	var/a1y = ay * a_len

	// b - vector perpendicular to vector a1.
	var/bx = -a1y
	var/by = a1x

	var/radius = round(grav_pull_range_low + (grav_pull_range_high - grav_pull_range_low) * strenght / 100)

	// c - vector of moving. Always move 1
	var/cx = ax * radius + bx * (a_len - 1)
	var/cy = ay * radius + by * (a_len - 1)

	var/turf/target = get_turf(locate(A.x + cx, A.y + cy, z))
	A.singularity_pull(target, grav_pull_strenght)

/obj/effect/anomaly/vortex/proc/do_pulls()
	var/radius = round(grav_pull_range_low + (grav_pull_range_high - grav_pull_range_low) * strenght / 100)
	for(var/atom/movable/A in range(radius, src))
		if(!iseffect(A))
			pull(A)

/obj/effect/anomaly/vortex/process()
	do_pulls()
	. = ..()

/obj/effect/anomaly/vortex/mob_touch_effect(mob/living/M)
	. = ..()
	M.random_throw(tier * 2, tier * 3, tier * 2)

/obj/effect/anomaly/vortex/item_touch_effect(obj/item/I)
	. = ..()
	I.random_throw(tier * 2, tier * 3, tier * 2)

/obj/effect/anomaly/vortex/tier1
	name = "малая вихревая аномалия"
	ru_names = list(NOMINATIVE = "малая вихревая аномалия", \
					GENITIVE = "малой вихревой аномалии", \
					DATIVE = "малой вихревой аномалии", \
					ACCUSATIVE = "малую вихревую аномалию", \
					INSTRUMENTAL = "малой вихревой аномалией", \
					PREPOSITIONAL = "малой вихревой аномалии")
	core_type = /obj/item/assembly/signaler/anomaly/tier1/vortex
	stronger_anomaly_type = /obj/effect/anomaly/vortex/tier2
	tier = 1
	impulses_types = list(
		/datum/anomaly_impulse/energ_fastmove/tier1,
		/datum/anomaly_impulse/superpull/tier1,
	)

	grav_pull_range_low = 1
	grav_pull_range_high = 2
	grav_pull_strenght = STAGE_THREE

/obj/effect/anomaly/vortex/tier2
	name = "вихревая аномалия"
	ru_names = list(NOMINATIVE = "вихревая аномалия", \
					GENITIVE = "вихревой аномалии", \
					DATIVE = "вихревой аномалии", \
					ACCUSATIVE = "вихревую аномалию", \
					INSTRUMENTAL = "вихревой аномалией", \
					PREPOSITIONAL = "вихревой аномалии")
	core_type = /obj/item/assembly/signaler/anomaly/tier2/vortex
	weaker_anomaly_type = /obj/effect/anomaly/vortex/tier1
	stronger_anomaly_type = /obj/effect/anomaly/vortex/tier3
	tier = 2
	impulses_types = list(
		/datum/anomaly_impulse/energ_fastmove/tier2,
		/datum/anomaly_impulse/superpull/tier2,
	)

	grav_pull_range_low = 2
	grav_pull_range_high = 3
	grav_pull_strenght = STAGE_FOUR

/obj/effect/anomaly/vortex/tier3
	name = "большая вихревая аномалия"
	ru_names = list(NOMINATIVE = "большая вихревая аномалия", \
					GENITIVE = "большой вихревой аномалии", \
					DATIVE = "большой вихревой аномалии", \
					ACCUSATIVE = "большую вихревую аномалию", \
					INSTRUMENTAL = "большой вихревой аномалией", \
					PREPOSITIONAL = "большой вихревой аномалии")
	core_type = /obj/item/assembly/signaler/anomaly/tier3/vortex
	weaker_anomaly_type = /obj/effect/anomaly/vortex/tier2
	tier = 3
	impulses_types = list(
		/datum/anomaly_impulse/energ_fastmove/tier3,
		/datum/anomaly_impulse/superpull/tier3,
	)

	grav_pull_range_low = 2
	grav_pull_range_high = 4
	grav_pull_strenght = STAGE_FIVE
