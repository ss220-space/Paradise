/datum/anomaly_impulse/move/bs_selftp
	name = "Пространственный сдвиг"
	desc = "Аномалия перемещается из одной точки в другую без пересечения физического пространства между ними. \
			Уровень стабильности аномалии выше 60 полностью убирает данный вид импульсов."
	stability_high = 60
	do_shake = FALSE
	/// Minimum range of teleportation.
	var/tp_range_low = -1
	/// Maximum range of teleportation.
	var/tp_range_high = -1

/datum/anomaly_impulse/move/bs_selftp/impulse()
	owner.matr.Scale(0.1, 0.1)
	animate(owner, transform = owner.matr, time = 0.5 SECONDS, alpha = 0, flags = ANIMATION_PARALLEL)

	sleep(0.5 SECONDS)
	var/obj/effect/anomaly/bluespace/anomaly = owner
	anomaly.teleport(owner, scale_by_strength(tp_range_low, tp_range_high))

	owner.matr.Scale(10, 10)
	animate(owner, transform = owner.matr, time = 0.5 SECONDS, alpha = 255)

/datum/anomaly_impulse/move/bs_selftp/tier1
	period_low = 3 SECONDS
	period_high = 5 SECONDS
	tp_range_low = 1
	tp_range_high = 3

/datum/anomaly_impulse/move/bs_selftp/tier2
	period_low = 5 SECONDS
	period_high = 10 SECONDS
	tp_range_low = 1
	tp_range_high = 4

/datum/anomaly_impulse/move/bs_selftp/tier3
	period_low = 5 SECONDS
	period_high = 10 SECONDS
	tp_range_low = 2
	tp_range_high = 6

/datum/anomaly_impulse/move/bs_selftp/tier4
	period_low = 2 SECONDS
	period_high = 4 SECONDS
	tp_range_low = 5
	tp_range_high = 11


/datum/anomaly_impulse/bs_tp_other
	name = "Всплеск телепортаций"
	desc = "Аномалия мгновенно меняет местоположение окружающих объектов не прикладывая к ним силу в процессе."
	/// Minimum range of teleportation.
	var/tp_range_low = -1
	/// Maximum range of teleportation.
	var/tp_range_high = -1

/datum/anomaly_impulse/bs_tp_other/impulse()
	var/obj/effect/anomaly/bluespace/anomaly = owner
	var/tp_range = scale_by_strength(tp_range_low, tp_range_high)
	for(var/atom/movable/atom in view(tp_range, owner))
		if(atom != owner)
			anomaly.teleport(atom, tp_range)

// Not for tier 1

/datum/anomaly_impulse/bs_tp_other/tier2
	period_low = 5 SECONDS
	period_high = 10 SECONDS
	tp_range_low = 1
	tp_range_high = 3

/datum/anomaly_impulse/bs_tp_other/tier3
	period_low = 3 SECONDS
	period_high = 10 SECONDS
	tp_range_low = 2
	tp_range_high = 6


/datum/anomaly_impulse/wormholes
	name = "Генерация червоточин"
	desc = "Аномалия временно дестабилизирует окружающее пространство, создавая несколько червоточин."
	/// Minimum range of teleportation.
	var/effect_range_low = -1
	/// Maximum range of teleportation.
	var/effect_range_high = -1
	/// Minimum number of wormholes created.
	var/wormholes_num_low = 0
	/// Maximum number of wormholes created.
	var/wormholes_num_high = 0
	/// Minimum lifetime of wormholes.
	var/wormholes_time_low = 0
	/// Maximum lifetime of wormholes.
	var/wormholes_time_high = 0
	/// List of currently existing wormholes. Needed for simultaneous deletion.
	var/list/wormholes = list()

/datum/anomaly_impulse/wormholes/impulse()
	var/radius = scale_by_strength(effect_range_low, effect_range_high)
	var/list/possible_turfs = list()
	for(var/turf/turf in range(radius, owner))
		possible_turfs.Add(turf)

	var/number_of_wormholes = scale_by_strength(wormholes_num_low, wormholes_num_high)
	for(var/i in 1 to number_of_wormholes)
		var/turf/anomaly_turf = pick_n_take(possible_turfs)
		if(anomaly_turf)
			wormholes.Add(new /obj/effect/portal/wormhole/anomaly(anomaly_turf, null, null, -1, null, TRUE, wormholes))

	addtimer(CALLBACK(src, PROC_REF(end)), scale_by_strength(wormholes_time_low, wormholes_time_high))

/datum/anomaly_impulse/wormholes/proc/end()
	QDEL_LIST(wormholes)

// Not for tier 1

/datum/anomaly_impulse/wormholes/tier2
	period_low = 10 SECONDS
	period_high = 30 SECONDS
	effect_range_low = 2
	effect_range_high = 3
	wormholes_num_low = 2
	wormholes_num_high = 5
	wormholes_time_low = 3 SECONDS
	wormholes_time_high = 7 SECONDS

/datum/anomaly_impulse/wormholes/tier3
	period_low = 5 SECONDS
	period_high = 20 SECONDS
	effect_range_low = 3
	effect_range_high = 4
	wormholes_num_low = 5
	wormholes_num_high = 10
	wormholes_time_low = 3 SECONDS
	wormholes_time_high = 5 SECONDS

/datum/anomaly_impulse/wormholes/tier4
	period_low = 5 SECONDS
	period_high = 10 SECONDS
	effect_range_low = 7
	effect_range_high = 15
	wormholes_num_low = 10
	wormholes_num_high = 20
	wormholes_time_low = 10 SECONDS
	wormholes_time_high = 15 SECONDS


// Tier 4 only

/datum/anomaly_impulse/bs_tp_other_t4
	name = "Всплеск телепортаций"
	desc = "Аномалия мгновенно меняет местоположение окружающих объектов не прикладывая к ним силу в процессе."
	period_low = 3 SECONDS
	period_high = 5 SECONDS

/datum/anomaly_impulse/bs_tp_other_t4/impulse()
	var/list/turf/turfs = list()
	var/tp_range = scale_by_strength(5, 10)
	for(var/turf/simulated/turf in range(tp_range, owner))
		turfs.Add(turf)

	// swaps
	for(var/i = 1; i <= rand(20, 30); ++i)
		var/turf/T1 = pick(turfs)
		var/turf/T2 = pick(turfs)

		var/dir1 = T1.dir
		var/icon_state1 = T1.icon_state
		var/icon1 = T1.icon
		T2.dir = dir1
		T2.icon = icon1
		T2.icon_state = icon_state1

		var/list/C1 = list()
		for(var/atom/movable/atom in T1)
			C1.Add(atom)

		var/list/C2 = list()
		for(var/atom/movable/atom in T2)
			C2.Add(atom)

		for(var/atom/movable/atom in C1)
			atom.forceMove(T2)

		for(var/atom/movable/atom in C2)
			atom.forceMove(T2)

		C1 = list()
		C2 = list()
		for(var/V in T1.vars)
			if(!(V in list("type", "loc", "locs", "vars", "parent", "parent_type", "verbs", "ckey", "key", "x", "y", "z", "destination_z", "destination_x", "destination_y", "contents", "luminosity", "group")))
				C1[V] = T1.vars[V]

		for(var/V in T2.vars)
			if(!(V in list("type", "loc", "locs", "vars", "parent", "parent_type", "verbs", "ckey", "key", "x", "y", "z", "destination_z", "destination_x", "destination_y", "contents", "luminosity", "group")))
				C2[V] = T2.vars[V]

		var/type1 = T1.type
		var/type2 = T2.type
		T2.ChangeTurf(type1)
		T1.ChangeTurf(type2)
