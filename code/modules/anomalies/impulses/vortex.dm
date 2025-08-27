/datum/anomaly_impulse/emp
	name = "ЭМИ"
	desc = "Аномалия выпускает электромагнитный импульс с эпицентром в аномалии."
	/// Minimum radius of the emitted light EMP.
	var/light_range_low = 0
	/// Maximum radius of the emitted light EMP.
	var/light_range_high = 0
	/// Minimum radius of the emitted heavy EMP.
	var/heavy_range_low = 0
	/// Maximum radius of the emitted heavy EMP.
	var/heavy_range_high = 0

/datum/anomaly_impulse/emp/impulse()
	empulse(owner, scale_by_strength(heavy_range_low, heavy_range_high), scale_by_strength(light_range_low, light_range_high))

/datum/anomaly_impulse/emp/tier1
	period_low = 10 SECONDS
	period_high = 20 SECONDS
	light_range_low = 0
	light_range_high = 3
	heavy_range_low = 0
	heavy_range_high = 0

/datum/anomaly_impulse/emp/tier2
	period_low = 10 SECONDS
	period_high = 15 SECONDS
	light_range_low = 2
	light_range_high = 4
	heavy_range_low = 0
	heavy_range_high = 2

/datum/anomaly_impulse/emp/tier3
	period_low = 5 SECONDS
	period_high = 10 SECONDS
	light_range_low = 3
	light_range_high = 7
	heavy_range_low = 1
	heavy_range_high = 5

/datum/anomaly_impulse/emp/tier4
	period_low = 3 SECONDS
	period_high = 5 SECONDS
	light_range_low = 10
	light_range_high = 20
	heavy_range_low = 5
	heavy_range_high = 10


/datum/anomaly_impulse/superpull
	name = "Всплеск притяжения"
	desc = "Способность аномалии притягивать предметы временно усиливается."
	/// Minimum amount of pulls.
	var/pulls_low = 0
	/// Maximum amount of pulls.
	var/pulls_high = 0

/datum/anomaly_impulse/superpull/impulse()
	var/obj/effect/anomaly/vortex/anomaly = owner
	for(var/i = 1 to scale_by_strength(pulls_low, pulls_high))
		anomaly.do_pulls()
		sleep(2)

/datum/anomaly_impulse/superpull/tier1
	period_low = 10 SECONDS
	period_high = 20 SECONDS
	pulls_low = 0
	pulls_high = 3

/datum/anomaly_impulse/superpull/tier2
	period_low = 10 SECONDS
	period_high = 15 SECONDS
	pulls_low = 2
	pulls_high = 5

/datum/anomaly_impulse/superpull/tier3
	period_low = 5 SECONDS
	period_high = 10 SECONDS
	pulls_low = 3
	pulls_high = 7

/datum/anomaly_impulse/superpull/tier4
	period_low = 5 SECONDS
	period_high = 10 SECONDS
	pulls_low = 10
	pulls_high = 20

// Tier 4 only

/datum/anomaly_impulse/vortex_fastmove
	name = "Рывок"
	desc = "Аномалия быстро двигается в случайном направлении сметая все на своем пути."
	period_low = 15 SECONDS
	period_high = 20 SECONDS
	/// Minimum radius of effect.
	var/range_low = 10
	/// Maximum radius of effect.
	var/range_high = 20

/datum/anomaly_impulse/vortex_fastmove/impulse()
	var/dir = pick(GLOB.alldirs)
	for(var/i = 1 to scale_by_strength(range_low, range_high))
		owner.do_move(dir)
		sleep(2)
