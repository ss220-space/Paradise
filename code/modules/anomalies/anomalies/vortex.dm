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

/obj/effect/anomaly/vortex/collapse()
	var/list/affected = list()
	for(var/turf/turf in range(collapse_range, src))
		var/key = "[get_dist(src, turf)]"
		if(!(key in affected))
			affected[key] = list()

		var/list/list = affected[key]
		list.Add(turf)

	for(var/key in affected)
		matr = matrix()
		var/mult = text2num(key)
		matr.Scale(mult, mult)
		animate(src, transform = matr, time = 0.2 SECONDS, flags = ANIMATION_PARALLEL)
		var/list/list = affected[key]
		for(var/turf/turf in list)
			if(!prob(mult * 10))
				continue

			turf.singularity_act(grav_pull_strenght)

		sleep(2)

	. = ..()

/obj/effect/anomaly/vortex/proc/pull(atom/movable/atom)
	if (QDELETED(atom))
		return

	// a - vector atom->src
	var/ax = x - atom.x
	var/ay = y - atom.y
	var/a_len = sqrt(ax * ax + ay * ay)

	// a1 - notmalised (len = 1) vector a
	var/a1x = ax * a_len
	var/a1y = ay * a_len

	// b - vector perpendicular to vector a1.
	var/bx = -a1y
	var/by = a1x

	var/radius = round(grav_pull_range_low + (grav_pull_range_high - grav_pull_range_low) * get_strenght() / 100)

	// c - vector of moving. Always move 1
	var/cx = ax * radius + bx * (a_len - 1)
	var/cy = ay * radius + by * (a_len - 1)

	var/turf/target = get_turf(locate(atom.x + cx, atom.y + cy, z))
	atom.singularity_pull(target, grav_pull_strenght)
	atom.update_icon()

/obj/effect/anomaly/vortex/proc/do_pulls()
	var/radius = round(grav_pull_range_low + (grav_pull_range_high - grav_pull_range_low) * get_strenght() / 100)
	for(var/atom/movable/atom in view(radius, src))
		if(!can_move_sth(atom))
			continue

		pull(atom)

/obj/effect/anomaly/vortex/process()
	var/list/obj/was_near = list()
	for(var/obj/O in range(1, src))
		was_near.Add(O)

	do_pulls()

	// If something movable was near and can not be pulled inside, it will be throwen.
	for(var/obj/O in range(1, src))
		if(!(O in was_near))
			continue

		if(!can_move_sth(O))
			continue

		O.random_throw(tier * 2, tier * 3, 4)

	. = ..()

/obj/effect/anomaly/vortex/mob_touch_effect(mob/living/mob)
	. = ..()
	if(can_move_sth(mob))
		mob.random_throw(tier * 2, tier * 3, 4)

/obj/effect/anomaly/vortex/item_touch_effect(obj/item/item)
	. = ..()
	if(can_move_sth(item))
		item.random_throw(tier * 2, tier * 3, 4)

/obj/effect/anomaly/vortex/process()
	. = ..()

	for(var/atom/movable/atom in loc.contents)
		if(!can_move_sth(atom))
			continue

		atom.random_throw(tier * 2, tier * 3, 5)

/obj/effect/anomaly/vortex/tier1
	name = "малая вихревая аномалия"
	ru_names = list(
		NOMINATIVE = "малая вихревая аномалия", \
		GENITIVE = "малой вихревой аномалии", \
		DATIVE = "малой вихревой аномалии", \
		ACCUSATIVE = "малую вихревую аномалию", \
		INSTRUMENTAL = "малой вихревой аномалией", \
		PREPOSITIONAL = "малой вихревой аномалии"
	)
	core_type = /obj/item/assembly/signaler/core/vortex/tier1
	stronger_anomaly_type = /obj/effect/anomaly/vortex/tier2
	tier = 1
	impulses_types = list(
		/datum/anomaly_impulse/emp/tier1,
		/datum/anomaly_impulse/superpull/tier1,
	)

	grav_pull_range_low = 1
	grav_pull_range_high = 2
	grav_pull_strenght = STAGE_THREE
	collapse_range = 0

/obj/effect/anomaly/vortex/tier2
	name = "вихревая аномалия"
	ru_names = list(
		NOMINATIVE = "вихревая аномалия", \
		GENITIVE = "вихревой аномалии", \
		DATIVE = "вихревой аномалии", \
		ACCUSATIVE = "вихревую аномалию", \
		INSTRUMENTAL = "вихревой аномалией", \
		PREPOSITIONAL = "вихревой аномалии"
	)
	core_type = /obj/item/assembly/signaler/core/vortex/tier2
	weaker_anomaly_type = /obj/effect/anomaly/vortex/tier1
	stronger_anomaly_type = /obj/effect/anomaly/vortex/tier3
	tier = 2
	impulses_types = list(
		/datum/anomaly_impulse/emp/tier2,
		/datum/anomaly_impulse/superpull/tier2,
	)

	grav_pull_range_low = 2
	grav_pull_range_high = 3
	grav_pull_strenght = STAGE_FOUR
	collapse_range = 1

/obj/effect/anomaly/vortex/tier3
	name = "большая вихревая аномалия"
	ru_names = list(
		NOMINATIVE = "большая вихревая аномалия", \
		GENITIVE = "большой вихревой аномалии", \
		DATIVE = "большой вихревой аномалии", \
		ACCUSATIVE = "большую вихревую аномалию", \
		INSTRUMENTAL = "большой вихревой аномалией", \
		PREPOSITIONAL = "большой вихревой аномалии"
	)
	core_type = /obj/item/assembly/signaler/core/vortex/tier3
	weaker_anomaly_type = /obj/effect/anomaly/vortex/tier2
	tier = 3
	impulses_types = list(
		/datum/anomaly_impulse/emp/tier3,
		/datum/anomaly_impulse/superpull/tier3,
	)

	grav_pull_range_low = 2
	grav_pull_range_high = 4
	grav_pull_strenght = STAGE_FIVE
	collapse_range = 3
	has_warp = TRUE

/obj/effect/anomaly/vortex/tier3/New()
	. = ..()

	for(var/mob/mob as anything in GLOB.player_list)
		if(mob.stat)
			continue

		if(get_dist(src, mob) > 20 || z != mob.z)
			return

		to_chat(mob, span_vortexanomaly("Сильный ветер дует вам прямо в лицо. Стоп, откуда на космической станции ветер?")) // It used in one place.

//			 TIER 4 ADMIN SPAWN ONLY

/obj/effect/anomaly/vortex/tier4
	name = "колоссальная вихревая аномалия"
	ru_names = list(
		NOMINATIVE = "колоссальная вихревая аномалия", \
		GENITIVE = "колоссальной вихревой аномалии", \
		DATIVE = "колоссальной вихревой аномалии", \
		ACCUSATIVE = "колоссальную вихревую аномалию", \
		INSTRUMENTAL = "колоссальной вихревой аномалией", \
		PREPOSITIONAL = "колоссальной вихревой аномалии"
	)
	core_type = /obj/item/assembly/signaler/core/vortex/tier3/tier4
	weaker_anomaly_type = /obj/effect/anomaly/vortex/tier3
	tier = 4
	impulses_types = list(
		/datum/anomaly_impulse/emp/tier4,
		/datum/anomaly_impulse/superpull/tier4,
		/datum/anomaly_impulse/vortex_fastmove,
	)

	grav_pull_range_low = 8
	grav_pull_range_high = 16
	grav_pull_strenght = STAGE_SIX
	collapse_range = 15
	has_warp = TRUE

/obj/effect/anomaly/vortex/tier4/New()
	. = ..()

	for(var/mob/mob as anything in GLOB.player_list)
		if(mob.stat)
			continue

		to_chat(mob, span_vortexanomaly("Ураганный поток ветра почти сбивает вас с ног. Это не предвещает ничего хорошего."))

/obj/effect/anomaly/vortex/tier4/item_touch_effect(obj/item/item)
	. = ..()
	if(!iscore(item))
		item.singularity_act()

/obj/effect/anomaly/vortex/tier4/mob_touch_effect(mob/living/mob)
	mob.singularity_act()

/obj/effect/anomaly/vortex/tier4/do_move(dir)
	. = ..()
	for(var/atom/atom in range(2, src))
		atom.singularity_act()

/obj/effect/anomaly/vortex/singularity_act()
	return
