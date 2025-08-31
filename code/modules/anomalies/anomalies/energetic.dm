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
	/// List of types of energy balls that can appear.
	var/list/eballs_types = list()
	/// Desired distance from the eball.
	var/eball_dist = 2

/obj/effect/anomaly/energetic/New()
	. = ..()
	for(var/i = 1 to rand(eballs_num_low, eballs_num_high))
		var/type = pick_weight_classic(eballs_types)
		eballs.Add(new type(loc, src))

/obj/effect/anomaly/energetic/Destroy()
	QDEL_LAZYLIST(eballs)
	. = ..()

/obj/effect/anomaly/energetic/collapse()
	for(var/i = 1 to rand(collapse_jumps_low, collapse_jumps_high))
		jump_to_machinery(collapse_shock_damage * 2)
		do_shock_ex(collapse_shock_range, collapse_shock_damage, TRUE)
		explosion(loc, -1, -1, -1, tier)
		sleep(0.2 SECONDS)

	explosion(loc, max(-1, tier - 2), max(-1, tier - 1), max(-1, tier), tier + 2)
	if(tier < 3)
		QDEL_LIST(eballs)
		return ..()

	for(var/obj/effect/energy_ball/eball as anything in eballs)
		if(!prob(50))
			continue

		var/spawn_type = eball.spawn_type
		new spawn_type(eball.loc)

	QDEL_LIST(eballs)
	return ..()

/obj/effect/anomaly/energetic/process()
	. = ..()
	var/list/powernets = list()
	for(var/turf/turf in view(3, src))
		var/obj/structure/cable/C = null
		if(isturf(turf))
			C = locate() in turf

		if(!C?.powernet)
			continue

		if(!(C.powernet in powernets))
			powernets.Add(C.powernet)

	var/cur_voltage = voltage * strenght / 100
	for(var/datum/powernet/powernet in powernets)
		powernet.newavail += cur_voltage / powernets.len

/obj/effect/anomaly/energetic/mob_touch_effect(mob/living/mob)
	. = ..(mob)
	mob.electrocute_act(collapse_shock_damage, "энергетической аномалии", flags = SHOCK_NOGLOVES)

/obj/effect/anomaly/energetic/item_touch_effect(obj/item/item)
	. = ..(item)
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
	ru_names = list(
		NOMINATIVE = "малая энергетическая аномалия", \
		GENITIVE = "малой энергетической аномалии", \
		DATIVE = "малой энергетической аномалии", \
		ACCUSATIVE = "малую энергетическую аномалию", \
		INSTRUMENTAL = "малой энергетической аномалией", \
		PREPOSITIONAL = "малой энергетической аномалии"
	)
	icon_state = "energetic1"
	core_type = /obj/item/assembly/signaler/core/energetic/tier1
	stronger_anomaly_type = /obj/effect/anomaly/energetic/tier2
	tier = 1
	light_range = 5
	impulses_types = list(
		/datum/anomaly_impulse/move/energ_fastmove/tier1,
		/datum/anomaly_impulse/energ_shock_ex/tier1,
		/datum/anomaly_impulse/move/machinery_jump/tier1,
	)

	voltage = 75000
	collapse_jumps_low = 3
	collapse_jumps_high = 7
	collapse_shock_range = 3
	collapse_shock_damage = 10

/obj/effect/anomaly/energetic/tier2
	name = "энергетическая аномалия"
	ru_names = list(
		NOMINATIVE = "энергетическая аномалия", \
		GENITIVE = "энергетической аномалии", \
		DATIVE = "энергетической аномалии", \
		ACCUSATIVE = "энергетическую аномалию", \
		INSTRUMENTAL = "энергетической аномалией", \
		PREPOSITIONAL = "энергетической аномалии"
	)
	icon_state = "energetic2"
	core_type = /obj/item/assembly/signaler/core/energetic/tier2
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
	eballs_types = list(/obj/effect/energy_ball = 1)

/obj/effect/anomaly/energetic/tier3
	name = "большая энергетическая аномалия"
	ru_names = list(
		NOMINATIVE = "большая энергетическая аномалия", \
		GENITIVE = "большой энергетической аномалии", \
		DATIVE = "большой энергетической аномалии", \
		ACCUSATIVE = "большую энергетическую аномалию", \
		INSTRUMENTAL = "большой энергетической аномалией", \
		PREPOSITIONAL = "большой энергетической аномалии"
	)
	icon_state = "energetic3"
	core_type = /obj/item/assembly/signaler/core/energetic/tier3
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
	eballs_types = list(/obj/effect/energy_ball = 3, /obj/effect/energy_ball/big = 1)

/obj/effect/anomaly/energetic/tier3/New()
	. = ..()
	for(var/mob/mob as anything in GLOB.player_list)
		if(mob.stat)
			continue

		if(get_dist(src, mob) > 20 || z != mob.z)
			return

		mob.playsound_local(null, 'sound/magic/lightningbolt.ogg', 15, TRUE)
		to_chat(mob, span_energeticanomaly("Вы слышите тихое потрескивание в воздухе. Подозрительно похоже на статическое электричество."))


/obj/effect/energy_ball
	name = "энергетический шар"
	ru_names = list(
		NOMINATIVE = "энергетический шар", \
		GENITIVE = "энергетического шара", \
		DATIVE = "энергетическому шару", \
		ACCUSATIVE = "энергетический шар", \
		INSTRUMENTAL = "энергетическим шаром", \
		PREPOSITIONAL = "энергетическом шаре"
	)
	desc = "Миниатюрная, отностилельно стабильная шаровая молния. Обычно появляется вместе с энергетическими аномалиями."
	icon = 'icons/effects/anomalies.dmi'
	icon_state = "energetic1"
	gender = MALE
	alpha = 0
	light = 5
	/// Anomaly that src conected with.
	var/obj/effect/anomaly/energetic/owner
	/// The proportion of the size relative to the default size.
	var/size = 0.5
	/// Type of anomaly that spawns instead of this eball when owner colapses.
	var/spawn_type = /obj/effect/anomaly/energetic/tier1

/obj/effect/energy_ball/New(loc, owner)
	. = ..()
	src.owner = owner

	var/matrix/mob = matrix()
	mob.Scale(0.1, 0.1)
	animate(src, transform = mob, time = 0, flags = ANIMATION_PARALLEL)
	mob.Scale(10 * size, 10 * size)
	animate(src, transform = mob, time = 1 SECONDS, alpha = 255, flags = ANIMATION_PARALLEL)

	START_PROCESSING(SSobj, src)

/obj/effect/energy_ball/Destroy()
	STOP_PROCESSING(SSobj, src)
	. = ..()

/obj/effect/energy_ball/process()
	if(QDELETED(owner) || owner.loc == null)
		qdel(src)
		return

	if(get_dist(src, owner) <= 2)
		jump(get_step(src, owner.get_move_dir()))
		return

	if(z != owner.z || get_dist(src, owner) > 10)
		jump(get_turf(owner))
		return

	while(get_dist(src, owner) > owner.eball_dist)
		jump(get_step(src, get_dir(src, owner)))
		sleep(2)

/obj/effect/energy_ball/proc/jump(target)
	if(QDELETED(owner) || owner.loc == null)
		qdel(src)
		return

	var/turf/target_turf = get_turf(target)
	if(!target_turf)
		return

	Beam(target_turf, icon_state = "lightning[rand(1, 12)]", icon = 'icons/effects/effects.dmi', time = 0.5 SECONDS)
	forceMove(target_turf)
	if(!prob(20))
		return

	var/list/obj/connected = list(owner) + owner.eballs
	Beam(pick(connected), icon_state = "lightning[rand(1, 12)]", icon = 'icons/effects/effects.dmi', time = 0.5 SECONDS)

/obj/effect/energy_ball/ex_act(severity)
	return

/obj/effect/energy_ball/CanAllowThrough(atom/movable/mover, border_dir)
	. = ..()
	if(!isliving(mover))
		return

	var/mob/living/mob = mover
	mob.electrocute_act(rand(20, 30), "энергетического шара",  flags = SHOCK_NOGLOVES)

/obj/effect/energy_ball/big
	size = 1

/obj/effect/energy_ball/verybig
	size = 1.5
	spawn_type = /obj/effect/anomaly/energetic/tier2


//			 TIER 4 ADMIN SPAWN ONLY

/obj/effect/anomaly/energetic/tier4
	name = "колоссальная энергетическая аномалия"
	ru_names = list(
		NOMINATIVE = "колоссальная энергетическая аномалия", \
		GENITIVE = "колоссальной энергетической аномалии", \
		DATIVE = "колоссальной энергетической аномалии", \
		ACCUSATIVE = "колоссальную энергетическую аномалию", \
		INSTRUMENTAL = "колоссальной энергетической аномалией", \
		PREPOSITIONAL = "колоссальной энергетической аномалии"
	)
	icon_state = "energetic3"
	core_type = /obj/item/assembly/signaler/core/energetic/tier3/tier4
	weaker_anomaly_type = /obj/effect/anomaly/energetic/tier3
	tier = 4
	light_range = 15
	impulses_types = list(
		/datum/anomaly_impulse/move/energ_fastmove/tier4,
		/datum/anomaly_impulse/energ_shock_ex/tier4,
		/datum/anomaly_impulse/move/machinery_jump/tier4,
		/datum/anomaly_impulse/move/machinery_destroy,
	)

	voltage = 5000000 // A stabilized flux anomaly can be a useful source of energy.
	collapse_jumps_low = 20
	collapse_jumps_high = 35
	collapse_shock_range = 6
	collapse_shock_damage = 120
	eballs_num_low = 10
	eballs_num_high = 12
	eballs_types = list(/obj/effect/energy_ball = 3, /obj/effect/energy_ball/big = 2, /obj/effect/energy_ball/verybig = 1)
	eball_dist = 5

/obj/effect/anomaly/energetic/tier4/New()
	. = ..()
	for(var/mob/living/mob as anything in GLOB.player_list)
		mob.electrocute_act(rand(5, 15), "[declent_ru(GENITIVE)]")
		if(mob.stat)
			continue

		if(is_admin_level(mob))
			continue

		mob.playsound_local(null, 'sound/magic/lightningbolt.ogg', 25, TRUE)
		to_chat(mob, span_energeticanomaly("Вы слышите черезвычайно громкий электрический треск!"))

/obj/effect/anomaly/energetic/tier4/do_move(dir)
	. = ..()
	explosion(get_turf(src), -1, 1, 2, cause = "tier4 energetic anomaly move", adminlog = FALSE)
