#define SPAWN_ALWAYS 100
#define SPAWN_LIKELY 85
#define SPAWN_UNLIKELY 35
#define SPAWN_RARE 10

/obj/effect/landmark/bitrunning/mob_segment/proc/spawn_mobs(turf/origin, datum/modular_mob_segment/segment)
	var/list/mob/living/spawned_mobs = list()

	spawned_mobs += segment.spawn_mobs(origin)

	SEND_SIGNAL(src, COMSIG_BITRUNNING_MOB_SEGMENT_SPAWNED, spawned_mobs)

	var/list/datum/weakref/mob_refs = list()
	for(var/mob/living/spawned as anything in spawned_mobs)
		if(QDELETED(spawned))
			continue

		mob_refs += WEAKREF(spawned)

	return mob_refs

/datum/modular_mob_segment
	var/exact = FALSE
	var/list/mobs = list()
	var/max = 4
	var/probability = SPAWN_LIKELY

/datum/modular_mob_segment/proc/spawn_mobs(turf/origin)
	if(!prob(probability))
		return

	var/list/mob/living/spawned_mobs = list()
	var/total_amount = exact ? length(mobs) : rand(1, max)

	shuffle_inplace(mobs)

	var/list/turf/nearby = list()
	for(var/turf/tile as anything in RANGE_TURFS(2, origin))
		if(!tile.is_blocked_turf())
			nearby += tile

	if(!length(nearby))
		stack_trace("Couldn't find any valid turfs to spawn on")
		return

	for(var/index in 1 to total_amount)
		if(!length(nearby))
			break

		var/turf/destination = pick(nearby)
		var/path = exact ? mobs[index] : pick(mobs)

		spawned_mobs += new path(destination)
		nearby -= destination

	return spawned_mobs

/datum/modular_mob_segment/gondolas
	mobs = list(
		/mob/living/simple_animal/pet/gondola,
	)

/datum/modular_mob_segment/corgis
	max = 2
	mobs = list(
		/mob/living/simple_animal/pet/dog/corgi,
	)

/datum/modular_mob_segment/monkeys
	mobs = list(
		/mob/living/carbon/human/lesser/monkey,
	)

/datum/modular_mob_segment/abductor_agents
	mobs = list(
		/mob/living/simple_animal/hostile/abductor,
		/mob/living/simple_animal/hostile/abductor/ranged,
	)

/datum/modular_mob_segment/syndicate_team
	mobs = list(
		/mob/living/simple_animal/hostile/syndicate/ranged,
		/mob/living/simple_animal/hostile/syndicate/melee,
	)

/datum/modular_mob_segment/syndicate_elite
	mobs = list(
		/mob/living/simple_animal/hostile/syndicate/melee/space,
		/mob/living/simple_animal/hostile/syndicate/ranged/space,
	)

/datum/modular_mob_segment/bears
	max = 2
	mobs = list(
		/mob/living/simple_animal/hostile/bear,
	)

/datum/modular_mob_segment/bees
	exact = TRUE
	mobs = list(
		/mob/living/simple_animal/hostile/poison/bees,
		/mob/living/simple_animal/hostile/poison/bees,
		/mob/living/simple_animal/hostile/poison/bees,
		/mob/living/simple_animal/hostile/poison/bees,
		/mob/living/simple_animal/hostile/poison/bees/queen,
	)

/datum/modular_mob_segment/bees_toxic
	mobs = list(
		/mob/living/simple_animal/hostile/poison/bees/syndi,
	)

/datum/modular_mob_segment/blob_spores
	mobs = list(
		/mob/living/simple_animal/hostile/blob_minion/spore,
	)

/datum/modular_mob_segment/carps
	mobs = list(
		/mob/living/simple_animal/hostile/carp,
	)

/datum/modular_mob_segment/hivebots
	mobs = list(
		/mob/living/simple_animal/hostile/hivebot,
		/mob/living/simple_animal/hostile/hivebot/range,
	)

/datum/modular_mob_segment/hivebots_strong
	mobs = list(
		/mob/living/simple_animal/hostile/hivebot/strong,
		/mob/living/simple_animal/hostile/hivebot/range,
	)

/datum/modular_mob_segment/lavaland_assorted
	mobs = list(
		/mob/living/simple_animal/hostile/asteroid/basilisk,
		/mob/living/simple_animal/hostile/asteroid/goliath,
		/mob/living/simple_animal/hostile/asteroid/hivelord,
		/mob/living/simple_animal/hostile/asteroid/goldgrub,
	)

/datum/modular_mob_segment/spiders
	mobs = list(
		/mob/living/simple_animal/hostile/poison/giant_spider,
		/mob/living/simple_animal/hostile/poison/giant_spider/hunter,
		/mob/living/simple_animal/hostile/poison/giant_spider/nurse,
	)

/datum/modular_mob_segment/venus_trap
	mobs = list(
		/mob/living/simple_animal/hostile/venus_human_trap,
	)

/datum/modular_mob_segment/xenos
	mobs = list(
		/mob/living/simple_animal/hostile/alien,
		/mob/living/simple_animal/hostile/alien/sentinel,
		/mob/living/simple_animal/hostile/alien/drone,
	)

/datum/modular_mob_segment/deer
	max = 1
	mobs = list(
		/mob/living/simple_animal/deer,
	)

#undef SPAWN_ALWAYS
#undef SPAWN_LIKELY
#undef SPAWN_UNLIKELY
#undef SPAWN_RARE
