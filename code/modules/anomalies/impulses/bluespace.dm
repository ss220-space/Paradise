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
	anomaly.teleport(owner, scale_by_strenght(tp_range_low, tp_range_high))

	owner.matr.Scale(10, 10)
	animate(owner, transform = owner.matr, time = 0.5 SECONDS, alpha = 255)

/datum/anomaly_impulse/move/bs_selftp/tier1
	period_low = 3 SECONDS
	period_high = 5 SECONDS
	tp_range_low = 1
	tp_range_high = 2

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


/datum/anomaly_impulse/bs_tp_other
	name = "Всплеск телепортаций"
	desc = "Аномалия мгновенно меняет местоположение окружающих объектов не прикладывая к ним силу в процессе."
	/// Minimum range of teleportation.
	var/tp_range_low = -1
	/// Maximum range of teleportation.
	var/tp_range_high = -1

/datum/anomaly_impulse/bs_tp_other/impulse()
	var/obj/effect/anomaly/bluespace/anomaly = owner
	var/tp_range = scale_by_strenght(tp_range_low, tp_range_high)
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
	var/radius = scale_by_strenght(effect_range_low, effect_range_high)
	var/list/possible_turfs = list()
	for(var/turf/T in range(radius, owner))
		possible_turfs.Add(T)

	var/number_of_wormholes = scale_by_strenght(wormholes_num_low, wormholes_num_high)
	for(var/i in 1 to number_of_wormholes)
		var/turf/anomaly_turf = pick_n_take(possible_turfs)
		if(anomaly_turf)
			wormholes.Add(new /obj/effect/portal/wormhole/anomaly(anomaly_turf, null, null, -1, null, TRUE, wormholes))

	addtimer(CALLBACK(src, PROC_REF(end)), scale_by_strenght(wormholes_time_low, wormholes_time_high))

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
