/datum/anomaly_impulse/random_temp
	name = "Температурная дестабилизация"
	desc = "Аномалия случайно меняет температуру окружающих ее газов, вызывая перепады давления."
	/// Minimum delta of temperature
	var/temp_delta_low = 0
	/// Maximum delta of temperature.
	var/temp_delta_high = 0
	/// Minimum range of effect.
	var/range_low = 0
	/// Maximum range of effect.
	var/range_high = 0

/datum/anomaly_impulse/random_temp/impulse()
	. = ..()
	for(var/turf/simulated/turf in view(scale_by_strength(range_low, range_high), owner))
		turf?.air?.temperature += max(0, rand(temp_delta_low, temp_delta_high))

/datum/anomaly_impulse/random_temp/tier1
	period_low = 15 SECONDS
	period_high = 45 SECONDS
	temp_delta_low = -100
	temp_delta_high = 100
	range_low = 1
	range_high = 2

/datum/anomaly_impulse/random_temp/tier2
	period_low = 15 SECONDS
	period_high = 45 SECONDS
	temp_delta_low = -150
	temp_delta_high = 150
	range_low = 1
	range_high = 3

/datum/anomaly_impulse/random_temp/tier3
	period_low = 15 SECONDS
	period_high = 45 SECONDS
	temp_delta_low = -200
	temp_delta_high = 200
	range_low = 2
	range_high = 4

/datum/anomaly_impulse/random_temp/tier4
	period_low = 5 SECONDS
	period_high = 10 SECONDS
	temp_delta_low = -200
	temp_delta_high = 1000
	range_low = 4
	range_high = 7

/datum/anomaly_impulse/random_temp/tier4/impulse()
	. = ..()
	for(var/mob/living/mob in view(scale_by_strength(range_low, range_high), owner))
		mob.IgniteMob()

/datum/anomaly_impulse/freese
	name = "Заморозка"
	desc = "Аномалия выпускает водяной пар понижает температуру окружающей среды, что приводит к образованию льда на полу."
	/// Minimum range of effect.
	var/range_low = 0
	/// Maximum range of effect.
	var/range_high = 0

/datum/anomaly_impulse/freese/impulse()
	. = ..()
	for(var/turf/simulated/turf in view(scale_by_strength(range_low, range_high) * 2, owner))
		if(turf.air)
			turf.air.temperature = rand(0, 50)

	for(var/turf/simulated/floor/turf in range(scale_by_strength(range_low, range_high), owner))
		if(prob(100 - get_dist(turf, owner) * 5))
			turf.MakeSlippery(TURF_WET_ICE, 120 SECONDS)

/datum/anomaly_impulse/freese/tier1
	period_low = 15 SECONDS
	period_low = 45 SECONDS
	range_low = 1
	range_high = 2

/datum/anomaly_impulse/freese/tier2
	period_low = 15 SECONDS
	period_low = 45 SECONDS
	range_low = 2
	range_high = 3

/datum/anomaly_impulse/freese/tier3
	period_low = 15 SECONDS
	period_low = 45 SECONDS
	range_low = 2
	range_high = 4

/datum/anomaly_impulse/freese/tier4
	period_low = 3 SECONDS
	period_low = 10 SECONDS
	range_low = 5
	range_high = 10

/datum/anomaly_impulse/freese/tier4/impulse()
	. = ..()
	for(var/mob/living/mob in view(7, owner))
		mob.adjust_bodytemperature(-100)
		mob.apply_status_effect(/datum/status_effect/freon)
		if(!ishuman(mob))
			continue

		mob.reagents.add_reagent("frostoil", 15)

/datum/anomaly_impulse/fire
	name = "Пожар"
	desc = "Аномалия создает вокруг себя нагретую горючую смесь плазмы и кислорода."
	/// Minimum range of effect.
	var/range_low = 0
	/// Maximum range of effect.
	var/range_high = 0
	/// Minimum generated amount of gases.
	var/gases_low = 0
	/// Maximum generated amount of gases.
	var/gases_high = 0

/datum/anomaly_impulse/fire/impulse()
	. = ..()
	for(var/turf/simulated/turf in view(scale_by_strength(range_low, range_high), owner))
		var/gases_amount = scale_by_strength(gases_low, gases_high)
		turf.atmos_spawn_air(LINDA_SPAWN_OXYGEN, gases_amount * 2/7)
		turf.atmos_spawn_air(LINDA_SPAWN_HEAT | LINDA_SPAWN_TOXINS, gases_amount * 5/7)

/datum/anomaly_impulse/fire/tier1
	period_low = 15 SECONDS
	period_high = 45 SECONDS
	range_low = 1
	range_high = 2
	gases_low = 0
	gases_high = 5

/datum/anomaly_impulse/fire/tier2
	period_low = 10 SECONDS
	period_high = 35 SECONDS
	range_low = 1
	range_high = 2
	gases_low = 0
	gases_high = 7

/datum/anomaly_impulse/fire/tier3
	period_low = 5 SECONDS
	period_high = 20 SECONDS
	range_low = 1
	range_high = 3
	gases_low = 0
	gases_high = 7

/datum/anomaly_impulse/fire/tier4
	period_low = 5 SECONDS
	period_high = 10 SECONDS
	range_low = 3
	range_high = 5
	gases_low = 7
	gases_high = 10

// TIER 4 ONLY

/datum/anomaly_impulse/dist_fire
	name = "Пожар на расстоянии"
	desc = "Аномалия создает в нескольких точках вокруг себя нагретую горючую смесь плазмы и кислорода."
	period_low = 5 SECONDS
	period_high = 10 SECONDS
	/// Minimum range of effect.
	var/range_low = 1
	/// Maximum range of effect.
	var/range_high = 5
	/// Minimum generated amount of gases.
	var/gases_low = 30
	/// Maximum generated amount of gases.
	var/gases_high = 60
	/// Minimum number of fire spawns.
	var/count_low = 0
	/// Maximum number of fire spawns.
	var/count_high = 5

/datum/anomaly_impulse/dist_fire/impulse()
	. = ..()
	var/radius = scale_by_strength(range_low, range_high)
	var/turf/start = get_turf(owner)
	var/gases_amount = scale_by_strength(gases_low, gases_high)
	for(var/i = 0 to scale_by_strength(count_low, count_high))
		var/try_x = start.x + rand(-radius, radius)
		var/try_y = start.y + rand(-radius, radius)
		try_x = clamp(try_x, 1, world.maxx)
		try_y = clamp(try_y, 1, world.maxy)
		var/turf/simulated/spawn_pos = get_turf(locate(try_x, try_y, start.z))
		spawn_pos?.atmos_spawn_air(LINDA_SPAWN_OXYGEN, gases_amount * 2/7)
		spawn_pos?.atmos_spawn_air(LINDA_SPAWN_HEAT | LINDA_SPAWN_TOXINS, gases_amount * 5/7)


/datum/anomaly_impulse/atmosfastmove
	name = "Рывок"
	desc = "Аномалия быстро двигается в определенном направлении сжигая все на своем пути."
	stability_high = 60
	period_low = 3 SECONDS
	period_high = 5 SECONDS
	/// Minimum range of effect.
	var/range_low = 5
	/// Maximum range of effect.
	var/range_high = 10
	/// Minimum generated amount of gases.
	var/gases_low = 5
	/// Maximum generated amount of gases.
	var/gases_high = 15

/datum/anomaly_impulse/atmosfastmove/impulse()
	. = ..()
	var/dir = pick(GLOB.alldirs)
	var/gases_amount = scale_by_strength(gases_low, gases_high)
	for(var/i = 0 to scale_by_strength(range_low, range_high))
		owner.do_move(dir)
		var/turf/simulated/spawn_pos = get_turf(owner)
		spawn_pos?.atmos_spawn_air(LINDA_SPAWN_OXYGEN, gases_amount * 2/7)
		spawn_pos?.atmos_spawn_air(LINDA_SPAWN_HEAT | LINDA_SPAWN_TOXINS, gases_amount * 5/7)
		sleep(2)
