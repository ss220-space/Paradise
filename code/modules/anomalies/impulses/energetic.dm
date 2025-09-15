/datum/anomaly_impulse/move/energ_fastmove
	name = "Рывок"
	desc = "Аномалия совершает несколько коротких прыжков в случайном направлении. \
			В процессе прыжков аномалия игнорирует любые перпятствия. \
			Уровень стабильности аномалии выше 60 полностью убирает данный вид импульсов."
	stability_high = 60
	do_shake = FALSE
	/// Minimum number of jumps.
	var/jumps_low = 0
	/// Maximum number of jumps.
	var/jumps_high = 0

/datum/anomaly_impulse/move/energ_fastmove/impulse()
	var/obj/effect/anomaly/energetic/anomaly = owner

	var/list/turf/possible_targets = list()
	var/jumps = scale_by_strength(jumps_low, jumps_high)
	for(var/turf/turf in orange(jumps, owner))
		if(get_dist(owner, turf) == jumps)
			possible_targets.Add(turf)

	var/turf/target = pick(possible_targets)
	if(!target)
		return

	for(var/i = 1; i <= jumps; ++i)
		var/cur_dir = get_dir(anomaly, target)
		anomaly.jump(get_step(owner, cur_dir))
		anomaly.after_move()
		sleep(2)

	for(var/turf/turf in orange(7, src))
		if(iswallturf(turf))
			continue

		anomaly.jump(turf)
		anomaly.after_move()


/datum/anomaly_impulse/move/energ_fastmove/tier1
	period_low = 5 SECONDS
	period_high = 20 SECONDS
	jumps_low = 3
	jumps_high = 5

/datum/anomaly_impulse/move/energ_fastmove/tier2
	period_low = 10 SECONDS
	period_high = 30 SECONDS
	jumps_low = 3
	jumps_high = 7

/datum/anomaly_impulse/move/energ_fastmove/tier3
	period_low = 20 SECONDS
	period_high = 40 SECONDS
	jumps_low = 3
	jumps_high = 11

/datum/anomaly_impulse/move/energ_fastmove/tier4
	period_low = 10 SECONDS
	period_high = 15 SECONDS
	jumps_low = 10
	jumps_high = 20

/datum/anomaly_impulse/energ_shock_ex
	name = "Удар током"
	desc = "Аномалия бьет окружающих живых существ током."
	/// Minimum range of shock.
	var/effect_range_low = 0
	/// Maximum range of shock.
	var/effect_range_high = 0
	/// Minimum damage of shock.
	var/shock_damage_low = 0
	/// Maximum damage of shock.
	var/shock_damage_high = 0

/datum/anomaly_impulse/energ_shock_ex/impulse()
	var/radius = scale_by_strength(effect_range_low, effect_range_high)
	var/damage = scale_by_strength(shock_damage_low, shock_damage_high)
	owner.do_shock_ex(radius, damage, TRUE)

/datum/anomaly_impulse/energ_shock_ex/tier1
	period_low = 15 SECONDS
	period_high = 45 SECONDS
	effect_range_low = 1
	effect_range_high = 3
	shock_damage_low = 5
	shock_damage_high = 10

/datum/anomaly_impulse/energ_shock_ex/tier2
	period_low = 10 SECONDS
	period_high = 20 SECONDS
	effect_range_low = 1
	effect_range_high = 4
	shock_damage_low = 10
	shock_damage_high = 30

/datum/anomaly_impulse/energ_shock_ex/tier3
	period_low = 5 SECONDS
	period_high = 10 SECONDS
	effect_range_low = 3
	effect_range_high = 7
	shock_damage_low = 30
	shock_damage_high = 70

/datum/anomaly_impulse/energ_shock_ex/tier4
	period_low = 2 SECONDS
	period_high = 5 SECONDS
	effect_range_low = 5
	effect_range_high = 13
	shock_damage_low = 120
	shock_damage_high = 150


/datum/anomaly_impulse/move/machinery_jump
	name = "Перемещение по машинерии"
	desc = "Аномалия прыгает по энергосети к ближайшей машинерии. \
			Уровень стабильности аномалии выше 60 полностью убирает данный вид импульсов."
	do_shake = FALSE
	stability_high = 60
	/// Minimum damage that machinery takes when teleports.
	var/damage_low = 0
	/// Maximum damage that machinery takes when teleports.
	var/damage_high = 0

/datum/anomaly_impulse/move/machinery_jump/impulse()
	var/obj/effect/anomaly/energetic/anomaly = owner
	anomaly.jump_to_machinery(scale_by_strength(damage_low, damage_high))

/datum/anomaly_impulse/move/machinery_jump/tier1
	period_low = 15 SECONDS
	period_high = 45 SECONDS
	damage_low = 20
	damage_high = 40

/datum/anomaly_impulse/move/machinery_jump/tier2
	period_low = 10 SECONDS
	period_high = 25 SECONDS
	damage_low = 40
	damage_high = 60

/datum/anomaly_impulse/move/machinery_jump/tier3
	period_low = 5 SECONDS
	period_high = 15 SECONDS
	damage_low = 60
	damage_high = 80

/datum/anomaly_impulse/move/machinery_jump/tier4
	period_low = 3 SECONDS
	period_high = 5 SECONDS
	damage_low = 300
	damage_high = 500

/// Tier 4 only

/datum/anomaly_impulse/move/machinery_destroy
	name = "Репродукция"
	desc = "Аномалия собирает большой объем энергии в случайной машинерии неподалеку. \
			Машинерия разрушается и из нее появляется новая малая энергетическая аномалия."
	period_low = 5 SECONDS
	period_high = 15 SECONDS

/datum/anomaly_impulse/move/machinery_destroy/impulse()
	. = ..()
	for(var/obj/machinery/mob in range(10, owner))
		explosion(get_turf(mob), devastation_range = -1, heavy_impact_range = 1, light_impact_range = 2, cause = "machinery_destroy impulse")
		new /obj/effect/anomaly/energetic/tier1(get_turf(mob))
		qdel(mob)
		if(prob(30))
			break
