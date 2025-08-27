/obj/effect/anomaly/atmospheric
	anomaly_type = ANOMALY_TYPE_ATMOS
	icon_state = "mustard"
	/// Range of collapse effects.
	var/collapse_range = 0
	/// Amount of gases spawned when anomaly collapses.
	var/collapse_gas_amount = 0
	/// Minimum amount of slimes spawned when anomaly collapses.
	var/collapse_slimes_low = 0
	/// Maximum amount of slimes spawned when anomaly collapses.
	var/collapse_slimes_high = 0

/obj/effect/anomaly/atmospheric/collapse()
	for(var/turf/simulated/turf in view(collapse_range * 2, src))
		if(turf.air)
			turf.air.temperature = rand(0, 50)

	for(var/turf/simulated/floor/turf in view(collapse_range, src))
		var/near_ice = 0 // Generation will be more beautiful.
		for(var/turf/simulated/checked in view(1, turf))
			if(checked.GetComponent(/datum/component/wet_floor))
				near_ice++

		if(prob(80 - near_ice * 20))
			new /obj/effect/snow(turf)
		else
			turf.MakeSlippery(TURF_WET_ICE, 120 SECONDS)

	for(var/mob/living/mob in view(collapse_range, src))
		mob.adjust_bodytemperature(-100)
		mob.apply_status_effect(/datum/status_effect/freon)
		if(ishuman(mob))
			mob.reagents.add_reagent("frostoil", 5)

	var/turf/simulated/turf = get_turf(src)
	if(istype(turf))
		turf.atmos_spawn_air(LINDA_SPAWN_OXYGEN, collapse_gas_amount * 2/7)
		turf.atmos_spawn_air(LINDA_SPAWN_HEAT | LINDA_SPAWN_TOXINS, collapse_gas_amount * 5/7)

	for(var/i = 1 to rand(collapse_slimes_low, collapse_slimes_high))
		INVOKE_ASYNC(src, PROC_REF(make_slime))

	. = ..()

/obj/effect/anomaly/atmospheric/mob_touch_effect(mob/living/mob)
	. = ..()
	var/new_temp = rand(0, 500)
	mob.adjust_bodytemperature(new_temp - mob.bodytemperature)
	if(new_temp >= T0C + 100 && prob(70))
		mob.adjust_fire_stacks(new_temp / 50)
		mob.IgniteMob()
	else
		mob.ExtinguishMob()

/obj/effect/anomaly/atmospheric/item_touch_effect(obj/item/item)
	. = ..()
	item.fire_act(null, rand(0, 1000), rand(20, 200))

/obj/effect/anomaly/atmospheric/proc/make_slime()
	var/turf/simulated/turf = get_turf(src)
	var/new_colour = pick("red", "orange", "blue", "dark blue")
	var/mob/living/simple_animal/slime/random/slime = new(turf, new_colour)
	slime.rabid = TRUE
	slime.set_nutrition(slime.get_max_nutrition())

	var/list/mob/dead/observer/candidates = SSghost_spawns.poll_candidates("Хотите сыграть за слайма из атмосферной аномалии?", ROLE_SENTIENT, FALSE, 100, source = slime, role_cleanname = "pyroclastic anomaly slime")
	if(!LAZYLEN(candidates))
		return

	var/mob/dead/observer/chosen = pick(candidates)
	slime.key = chosen.key
	slime.mind.special_role = SPECIAL_ROLE_PYROCLASTIC_SLIME
	add_game_logs("was made into a slime by pyroclastic anomaly at [AREACOORD(turf)].", slime)

/obj/effect/anomaly/atmospheric/tier1
	name = "малая атмосферная аномалия"
	core_type = /obj/item/assembly/signaler/core/atmospheric/tier1
	stronger_anomaly_type = /obj/effect/anomaly/atmospheric/tier2
	tier = 1
	impulses_types = list(
		/datum/anomaly_impulse/random_temp/tier1,
		/datum/anomaly_impulse/freese/tier1,
		/datum/anomaly_impulse/fire/tier1,
	)

	collapse_range = 2
	collapse_gas_amount = 150

/obj/effect/anomaly/atmospheric/tier1/get_ru_names()
	return list(
		NOMINATIVE = "малая атмосферная аномалия", \
		GENITIVE = "малой атмосферной аномалии", \
		DATIVE = "малой атмосферной аномалии", \
		ACCUSATIVE = "малую ​​атмосферную аномалию", \
		INSTRUMENTAL = "малой ​атмосферной аномалией", \
		PREPOSITIONAL = "малой ​​атмосферной аномалии"
	)

/obj/effect/anomaly/atmospheric/tier2
	name = "атмосферная аномалия"
	core_type = /obj/item/assembly/signaler/core/atmospheric/tier2
	weaker_anomaly_type = /obj/effect/anomaly/atmospheric/tier1
	stronger_anomaly_type = /obj/effect/anomaly/atmospheric/tier3
	tier = 2
	impulses_types = list(
		/datum/anomaly_impulse/random_temp/tier2,
		/datum/anomaly_impulse/freese/tier2,
		/datum/anomaly_impulse/fire/tier2,
	)

	collapse_range = 5
	collapse_gas_amount = 350
	collapse_slimes_low = 0
	collapse_slimes_high = 2

/obj/effect/anomaly/atmospheric/tier2/get_ru_names()
	return list(
		NOMINATIVE = "атмосферная аномалия", \
		GENITIVE = "атмосферной аномалии", \
		DATIVE = "атмосферной аномалии", \
		ACCUSATIVE = "​​атмосферную аномалию", \
		INSTRUMENTAL = "​атмосферной аномалией", \
		PREPOSITIONAL = "​​атмосферной аномалии"
	)

/obj/effect/anomaly/atmospheric/tier3
	name = "большая атмосферная аномалия"
	core_type = /obj/item/assembly/signaler/core/atmospheric/tier3
	weaker_anomaly_type = /obj/effect/anomaly/atmospheric/tier2
	tier = 3
	impulses_types = list(
		/datum/anomaly_impulse/random_temp/tier3,
		/datum/anomaly_impulse/freese/tier3,
		/datum/anomaly_impulse/fire/tier3,
	)

	collapse_range = 7
	collapse_gas_amount = 700
	collapse_slimes_low = 0
	collapse_slimes_high = 3

/obj/effect/anomaly/atmospheric/tier3/get_ru_names()
	return list(
		NOMINATIVE = "большая атмосферная аномалия", \
		GENITIVE = "большой атмосферной аномалии", \
		DATIVE = "большой атмосферной аномалии", \
		ACCUSATIVE = "большую ​​атмосферную аномалию", \
		INSTRUMENTAL = "большой ​атмосферной аномалией", \
		PREPOSITIONAL = "большой ​​атмосферной аномалии"
	)

/obj/effect/anomaly/atmospheric/tier3/New()
	. = ..()

	for(var/mob/mob as anything in GLOB.player_list)
		if(mob.stat)
			continue

		if(get_dist(src, mob) > 20 || z != mob.z)
			return

		mob.playsound_local(null, 'sound/effects/comfyfire.ogg', 15, TRUE)
		to_chat(mob, span_atmospferic_anomaly("Вас накрывает волна жара! Воздух вокруг дрожит."))

/obj/effect/anomaly/atmospheric/tier3/collapse()
	for(var/obj/item/paper in range(30)) // Just for fan.
		paper.fire_act(null, 1000, 1000)

	. = ..()


//		TIER 4 ANOMALY | ADMIN SPAWN ONLY!

/obj/effect/anomaly/atmospheric/tier4
	name = "колосальная атмосферная аномалия"
	core_type = /obj/item/assembly/signaler/core/atmospheric/tier3/tier4
	weaker_anomaly_type = /obj/effect/anomaly/atmospheric/tier4
	tier = 4
	impulses_types = list(
		/datum/anomaly_impulse/random_temp/tier4,
		/datum/anomaly_impulse/freese/tier4,
		/datum/anomaly_impulse/fire/tier4,
		/datum/anomaly_impulse/dist_fire,
		/datum/anomaly_impulse/atmosfastmove,
	)

	collapse_range = 15
	collapse_gas_amount = 5000
	collapse_slimes_low = 3
	collapse_slimes_high = 6

/obj/effect/anomaly/atmospheric/tier4/get_ru_names()
	return list(
		NOMINATIVE = "колосальная атмосферная аномалия", \
		GENITIVE = "колоссальной атмосферной аномалии", \
		DATIVE = "колоссальной атмосферной аномалии", \
		ACCUSATIVE = "колосальную ​​атмосферную аномалию", \
		INSTRUMENTAL = "колоссальной ​атмосферной аномалией", \
		PREPOSITIONAL = "колоссальной ​атмосферной аномалии"
	)

/obj/effect/anomaly/atmospheric/tier4/do_move(dir)
	. = ..()
	for(var/turf/simulated/wall/wall in range(2, src))
		wall.take_damage(700)

	for(var/mob/living/mob in range(2, src))
		to_chat(mob, span_danger("Вы были испепелены [declent_ru(INSTRUMENTAL)]!"))
		mob.dust()

/obj/effect/anomaly/atmospheric/tier4/New()
	. = ..()

	for(var/mob/mob as anything in GLOB.player_list)
		if(mob.stat)
			continue

		mob.playsound_local(null, 'sound/effects/comfyfire.ogg', 15, TRUE)
		to_chat(mob, span_atmospferic_anomaly("Вас накрывает волна жара! Воздух вокруг сильно дрожит."))
