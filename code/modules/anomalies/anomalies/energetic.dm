/obj/effect/anomaly/energetic
	anomaly_type = ANOMALY_TYPE_FLUX
	icon_state = "electricity2"
	icon = 'icons/effects/anomalies.dmi'
	icon_state = "energetic1"

	/// The voltage that this anomaly supplies to nearby powernets.
	var/voltage = 0
	/// Minimum number of jumps when collapsed.
	var/collapse_jumps_low = 0
	/// Maximum number of jumps when collapsed.
	var/collapse_jumps_high = 0
	/// Range of do_shock_ex when collapse.
	var/collapse_shock_range = 0
	/// Damage of do_shock_ex when collapses.
	var/collapse_shock_damage = 0
	/// Minimum number of generated energy balls.
	var/eballs_num_low = 0
	/// Maximum number of generated energy balls.
	var/eballs_num_high = 0
	/// List of energy balls connected to rhis anomaly.
	var/list/obj/effect/energy_ball/eballs = list()

/obj/effect/anomaly/energetic/New()
	. = ..()
	for(var/i = 1 to rand(eballs_num_low, eballs_num_high))
		eballs.Add(new /obj/effect/energy_ball(loc, src))

/obj/effect/anomaly/energetic/Destroy()
	if(tier != 3)
		QDEL_LIST(eballs)
		return ..()

	for(var/obj/effect/energy_ball/eball in eballs)
		if(prob(50))
			new /obj/effect/anomaly/energetic/tier1(eball.loc)

	QDEL_LIST(eballs)
	return ..()

/obj/effect/anomaly/energetic/process()
	. = ..()
	var/list/powernets = list()
	for(var/obj/machinery/power/P in view(3, src))
		if(!P.powernet)
			continue

		if(!(P.powernet in powernets))
			powernets.Add(P)

	for(var/datum/powernet/P in powernets)
		P.newavail += voltage / powernets.len

/obj/effect/anomaly/energetic/mob_touch_effect(mob/living/M)
	. = ..()
	M.electrocute_act(collapse_shock_damage, "энергетической аномалии", flags = SHOCK_NOGLOVES)

/obj/effect/anomaly/energetic/item_touch_effect(obj/item/I)
	. = ..()
	do_shock_ex(collapse_shock_range / 2, collapse_shock_damage / 2, TRUE)

/obj/effect/anomaly/energetic/proc/jump_to_machinery(damage)
	var/list/possible_targets = list()
	for(var/obj/machinery/mach in view(5, src))
		if(!(mach.stat & BROKEN))
			possible_targets += mach

	var/obj/target = pick(possible_targets)
	target.take_damage(damage, BURN, ENERGY, TRUE, get_dir(src, target))
	jump(target)
	after_move()

/obj/effect/anomaly/energetic/collapse()
	for(var/i = 1 to rand(collapse_jumps_low, collapse_jumps_high))
		jump_to_machinery(collapse_shock_damage * 2)
		do_shock_ex(collapse_shock_range, collapse_shock_damage, TRUE)
		sleep(0.5 SECONDS)

	. = ..()

/obj/effect/anomaly/energetic/do_move(dir)
	var/turf/target = get_step(src, dir)
	if(target && target.Enter(src))
		jump(target)

	return TRUE

// A jump accompanied by an electric shock.
/obj/effect/anomaly/energetic/proc/jump(target)
	var/turf/target_turf = get_turf(target)
	if(!target_turf)
		return

	Beam(target_turf, icon_state = "lightning[rand(1, 12)]", icon = 'icons/effects/effects.dmi', time = 0.5 SECONDS)
	forceMove(target_turf)

/obj/effect/anomaly/energetic/tier1
	name = "малая энергетическая аномалия"
	ru_names = list(NOMINATIVE = "малая энергетическая аномалия", \
					GENITIVE = "малой энергетической аномалии", \
					DATIVE = "малой энергетической аномалии", \
					ACCUSATIVE = "малую энергетическую аномалию", \
					INSTRUMENTAL = "малой энергетической аномалией", \
					PREPOSITIONAL = "малой энергетической аномалии")
	icon_state = "energetic1"
	core_type = /obj/item/assembly/signaler/core/tier1/energetic
	stronger_anomaly_type = /obj/effect/anomaly/energetic/tier2
	tier = 1
	light_range = 5
	impulses_types = list(
		/datum/anomaly_impulse/move/energ_fastmove/tier1,
		/datum/anomaly_impulse/energ_shock_ex/tier1,
		/datum/anomaly_impulse/move/machinery_jump/tier1,
	)

	voltage = 50000
	collapse_jumps_low = 3
	collapse_jumps_high = 7
	collapse_shock_range = 3
	collapse_shock_damage = 10

/obj/effect/anomaly/energetic/tier2
	name = "энергетическая аномалия"
	ru_names = list(NOMINATIVE = "энергетическая аномалия", \
					GENITIVE = "энергетической аномалии", \
					DATIVE = "энергетической аномалии", \
					ACCUSATIVE = "энергетическую аномалию", \
					INSTRUMENTAL = "энергетической аномалией", \
					PREPOSITIONAL = "энергетической аномалии")
	icon_state = "energetic2"
	core_type = /obj/item/assembly/signaler/core/tier2/energetic
	weaker_anomaly_type = /obj/effect/anomaly/energetic/tier1
	stronger_anomaly_type = /obj/effect/anomaly/energetic/tier3
	tier = 2
	light_range = 6
	impulses_types = list(
		/datum/anomaly_impulse/move/energ_fastmove/tier2,
		/datum/anomaly_impulse/energ_shock_ex/tier2,
		/datum/anomaly_impulse/move/machinery_jump/tier2,
	)

	voltage = 250000
	collapse_jumps_low = 5
	collapse_jumps_high = 10
	collapse_shock_range = 3
	collapse_shock_damage = 30
	eballs_num_low = 2
	eballs_num_high = 3

/obj/effect/anomaly/energetic/tier3
	name = "большая энергетическая аномалия"
	ru_names = list(NOMINATIVE = "большая энергетическая аномалия", \
					GENITIVE = "большой энергетической аномалии", \
					DATIVE = "большой энергетической аномалии", \
					ACCUSATIVE = "большую энергетическую аномалию", \
					INSTRUMENTAL = "большой энергетической аномалией", \
					PREPOSITIONAL = "большой энергетической аномалии")
	icon_state = "energetic3"
	core_type = /obj/item/assembly/signaler/core/tier3/energetic
	weaker_anomaly_type = /obj/effect/anomaly/energetic/tier2
	tier = 3
	light_range = 7
	impulses_types = list(
		/datum/anomaly_impulse/move/energ_fastmove/tier3,
		/datum/anomaly_impulse/energ_shock_ex/tier3,
		/datum/anomaly_impulse/move/machinery_jump/tier3,
	)

	voltage = 1000000 // A stabilized flux anomaly can be a useful source of energy.
	collapse_jumps_low = 10
	collapse_jumps_high = 15
	collapse_shock_range = 4
	collapse_shock_damage = 70
	eballs_num_low = 3
	eballs_num_high = 5

/obj/effect/anomaly/energetic/tier3/New()
	. = ..()
	for(var/mob/living/M in GLOB.player_list)
		if(M.stat)
			continue

		if(get_dist(src, M) > 20 || z != M.z)
			return

		M.playsound_local(null, 'sound/magic/lightningbolt.ogg', 15, TRUE)
		to_chat(M, "<span class='energetic_anomaly'>Статическое электричество чувствуется в воздухе. Окружающие механизмы подозрительно гудят!</span>") // It used in one place.


/obj/effect/energy_ball
	name = "энергетический шар"
	ru_names = list(NOMINATIVE = "энергетический шар", \
					GENITIVE = "энергетического шара", \
					DATIVE = "энергетическому шару", \
					ACCUSATIVE = "энергетический шар", \
					INSTRUMENTAL = "энергетическим шаром", \
					PREPOSITIONAL = "энергетическом шаре")
	desc = "Миниатюрная, отностилельно стабильная шаровая молния. Обычно появляется вместе с энергетическими аномалиями."
	icon = 'icons/effects/anomalies.dmi'
	icon_state = "energetic1"
	gender = MALE
	alpha = 0
	light = 5
	/// Anomaly that src conected with.
	var/obj/effect/anomaly/energetic/owner

/obj/effect/energy_ball/New(loc, owner)
	. = ..()
	src.owner = owner

	var/matrix/M = matrix()
	M.Scale(0.1, 0.1)
	animate(src, transform = M, time = 0, flags = ANIMATION_PARALLEL)
	M.Scale(5, 5)
	animate(src, transform = M, time = 1 SECONDS, alpha = 255, flags = ANIMATION_PARALLEL)

	START_PROCESSING(SSobj, src)

/obj/effect/energy_ball/Destroy()
	. = ..()
	STOP_PROCESSING(SSobj, src)

/obj/effect/energy_ball/process()
	if(!owner)
		qdel(src)
		return

	if(get_dist(src, owner) <= 2)
		jump(get_step(src, owner.get_move_dir()))
		return

	if(z != owner.z || get_dist(src, owner) > 10)
		jump(get_turf(owner))
		return

	while(get_dist(src, owner) > 2)
		jump(get_step(src, get_dir(src, owner)))
		sleep(2)

/obj/effect/energy_ball/proc/jump(target)
	var/turf/target_turf = get_turf(target)
	if(!target_turf)
		return

	Beam(target_turf, icon_state = "lightning[rand(1, 12)]", icon = 'icons/effects/effects.dmi', time = 0.5 SECONDS)
	forceMove(target_turf)
	if(!prob(20))
		return

	var/list/obj/connected = list(owner) + owner.eballs
	Beam(pick(connected), icon_state = "lightning[rand(1, 12)]", icon = 'icons/effects/effects.dmi', time = 0.5 SECONDS)

/obj/effect/energy_ball/CanAllowThrough(atom/movable/mover, border_dir)
	. = ..()
	if(isliving(mover))
		var/mob/living/M = mover
		M.electrocute_act(rand(20, 30), "энергетического шара",  flags = SHOCK_NOGLOVES)
