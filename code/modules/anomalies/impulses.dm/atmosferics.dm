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
	for(var/turf/simulated/T in range(scale_by_strenght(range_low, range_high), owner))
		T.air.temperature += max(0, rand(temp_delta_low, temp_delta_high))

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


/datum/anomaly_impulse/freese
	name = "Заморозка"
	desc = "Аномалия выпускает водяной пар понижает температуру окружающей среды, что приводит к образованию льда на полу."
	/// Minimum range of effect.
	var/range_low = 0
	/// Maximum range of effect.
	var/range_high = 0

/datum/anomaly_impulse/freese/impulse()
	. = ..()
	for(var/turf/simulated/T in range(scale_by_strenght(range_low, range_high) * 2, owner))
		T.temperature = rand(0, 50)

	for(var/turf/simulated/T in spiral_range_turfs(scale_by_strenght(range_low, range_high), owner))
		T.MakeSlippery(TURF_WET_ICE, 120 SECONDS)

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
	for(var/turf/simulated/T in range(scale_by_strenght(range_low, range_high), owner))
		var/gases_amount = scale_by_strenght(gases_low, gases_high)
		T.atmos_spawn_air(LINDA_SPAWN_OXYGEN, gases_amount * 2/7)
		T.atmos_spawn_air(LINDA_SPAWN_HEAT | LINDA_SPAWN_TOXINS, gases_amount * 5/7)

/datum/anomaly_impulse/fire/tier1
	period_low = 15 SECONDS
	period_high = 45 SECONDS
	range_low = 1
	range_high = 2
	gases_low = 0
	gases_high = 7

/datum/anomaly_impulse/fire/tier2
	period_low = 10 SECONDS
	period_high = 35 SECONDS
	range_low = 1
	range_high = 2
	gases_low = 7
	gases_high = 14

/datum/anomaly_impulse/fire/tier3
	period_low = 5 SECONDS
	period_high = 20 SECONDS
	range_low = 2
	range_high = 4
	gases_low = 14
	gases_high = 21
