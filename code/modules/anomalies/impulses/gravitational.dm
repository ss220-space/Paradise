/datum/anomaly_impulse/change_grav
	name = "Гравитационная дестабилизация"
	desc = "Аномалия временно дестабилизирует работу гравитации относительно нескольких окружающих ее объектов."
	/// Minimum radius of effect.
	var/effect_radius_low = 0
	/// Maximum radius of effect.
	var/effect_radius_high = 0

/datum/anomaly_impulse/change_grav/impulse()
	var/obj/effect/anomaly/gravitational/anomaly = owner
	for(var/atom/movable/atom in view(scale_by_strenght(effect_radius_low, effect_radius_high), owner))
		if(!iseffect(atom))
			anomaly.random_gravity_change(atom)

/datum/anomaly_impulse/change_grav/tier1
	period_low = 5 SECONDS
	period_high = 10 SECONDS
	effect_radius_low = 1
	effect_radius_high = 3

/datum/anomaly_impulse/change_grav/tier2
	period_low = 5 SECONDS
	period_high = 10 SECONDS
	effect_radius_low = 3
	effect_radius_high = 5

/datum/anomaly_impulse/change_grav/tier3
	period_low = 5 SECONDS
	period_high = 10 SECONDS
	effect_radius_low = 3
	effect_radius_high = 5

/datum/anomaly_impulse/change_grav/tier4
	period_low = 5 SECONDS
	period_high = 10 SECONDS
	effect_radius_low = 6
	effect_radius_high = 10

/datum/anomaly_impulse/random_throws
	name = "Гравитационный всплеск"
	desc = "Аномалия случайно раскидывает окружающие ее объекты."
	/// Minimum radius of effect.
	var/effect_radius_low = 0
	/// Maximum radius of effect.
	var/effect_radius_high = 0
	/// Minimum radius of throwing.
	var/throw_range_low = 0
	/// Maximum radius of throwing.
	var/throw_range_high = 0
	/// Minimum speed of throwing.
	var/throw_speed_low = 0
	/// Maximum speed of throwing.
	var/throw_speed_high = 0

/datum/anomaly_impulse/random_throws/impulse()
	var/obj/effect/anomaly/anomaly = owner
	var/ost_atoms = 100
	for(var/atom/movable/atom in view(scale_by_strenght(effect_radius_low, effect_radius_high), owner))
		if(!anomaly.can_move_sth(atom))
			continue

		atom.random_throw(throw_range_low, throw_range_high, scale_by_strenght(throw_speed_low, throw_speed_high))
		ost_atoms--

		if(!ost_atoms)
			break

/datum/anomaly_impulse/random_throws/tier1
	period_low = 10 SECONDS
	period_high = 20 SECONDS
	effect_radius_low = 1
	effect_radius_high = 2
	throw_range_low = 2
	throw_range_high = 3
	throw_speed_low = 3
	throw_speed_high = 4

/datum/anomaly_impulse/random_throws/tier2
	period_low = 5 SECONDS
	period_high = 15 SECONDS
	effect_radius_low = 1
	effect_radius_high = 3
	throw_range_low = 2
	throw_range_high = 5
	throw_speed_low = 3
	throw_speed_high = 5

/datum/anomaly_impulse/random_throws/tier3
	period_low = 5 SECONDS
	period_high = 10 SECONDS
	effect_radius_low = 2
	effect_radius_high = 4
	throw_range_low = 3
	throw_range_high = 8
	throw_speed_low = 4
	throw_speed_high = 7

/datum/anomaly_impulse/random_throws/tier4
	period_low = 3 SECONDS
	period_high = 5 SECONDS
	effect_radius_low = 5
	effect_radius_high = 13
	throw_range_low = 5
	throw_range_high = 20
	throw_speed_low = 4
	throw_speed_high = 7


// Tier 4 only

/datum/anomaly_impulse/grav_fastmove
	name = "Рывок"
	desc = "Аномалия быстро двигается в случайном направлении сметая все на своем пути."
	period_low = 15 SECONDS
	period_high = 20 SECONDS
	/// Minimum radius of effect.
	var/range_low = 10
	/// Maximum radius of effect.
	var/range_high = 20

/datum/anomaly_impulse/grav_fastmove/impulse()
	var/dir = pick(GLOB.alldirs)
	for(var/i = 1 to scale_by_strenght(range_low, range_high))
		owner.do_move(dir)
		var/ost_atoms = 100
		for(var/atom/movable/atom in view(3, owner))
			if(isobserver(atom))
				continue

			atom.random_throw(15, 20, 6)
			ost_atoms--
			if(!ost_atoms)
				break

		sleep(2)
