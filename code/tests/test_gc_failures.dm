/// The hard delete queue entry and the local variable that holds the object during a search.
#define QUEUED_OBJECT_REFS 2

/// Fails for every type that failed to garbage collect while the other unit tests ran.
/// Runs last, so it sees what every other test deleted.
/datum/unit_test/gc_failures
	priority = TEST_AFTER_CREATE_AND_DESTROY
	/// Types that already failed to collect when this test was added. Remove a type once its leak is fixed.
	var/static/list/known_failures = list(
		/obj/item/stock_parts/cell/energy_gun,
		// Terror spiders and their spells
		/mob/living/simple_animal/hostile/poison/terror_spider/defiler,
		/mob/living/simple_animal/hostile/poison/terror_spider/healer,
		/mob/living/simple_animal/hostile/poison/terror_spider/healer/strong,
		/mob/living/simple_animal/hostile/poison/terror_spider/mother,
		/mob/living/simple_animal/hostile/poison/terror_spider/prince,
		/mob/living/simple_animal/hostile/poison/terror_spider/queen,
		/mob/living/simple_animal/hostile/poison/terror_spider/queen/empress,
		/mob/living/simple_animal/hostile/poison/terror_spider/queen/empress/weak,
		/mob/living/simple_animal/hostile/poison/terror_spider/queen/princess,
		/datum/action/cooldown/spell/aoe/open_vent,
		/datum/action/cooldown/spell/aoe/terror_healing,
		/datum/action/cooldown/spell/aoe/terror_healing/greater,
		/datum/action/cooldown/spell/aoe/terror_shriek,
		/datum/action/cooldown/spell/aoe/terror_shriek_princess,
		/datum/action/cooldown/spell/aoe/terror_shriek_queen,
		/datum/action/cooldown/spell/aoe/terror_slam,
		/datum/action/cooldown/spell/list_target/mindscan,
		/datum/action/cooldown/spell/list_target/remotetalk,
		// Other mobs and their spells
		/mob/living/simple_animal/hostile/construct/builder,
		/mob/living/simple_animal/hostile/construct/builder/holy,
		/mob/living/simple_animal/hostile/construct/builder/hostile,
		/mob/living/simple_animal/hostile/guardian/fire,
		/mob/living/simple_animal/hostile/hellhound/greater,
		/mob/living/simple_animal/hostile/megafauna/blood_drunk_miner,
		/mob/living/simple_animal/hostile/megafauna/blood_drunk_miner/guidance,
		/mob/living/simple_animal/hostile/megafauna/blood_drunk_miner/hunter,
		/mob/living/simple_animal/hostile/megafauna/dragon/space_dragon,
		/mob/living/simple_animal/hostile/morph,
		/mob/living/simple_animal/hostile/morph/wizard,
		/mob/living/simple_animal/hostile/statue,
		/datum/action/cooldown/spell/aoe/guardian_hallucination,
		/datum/action/cooldown/spell/aoe/knock,
		/datum/action/cooldown/spell/aoe/magic_missile/lesser,
		/datum/action/cooldown/spell/list_target/impregnate,
		// Energy sphere projectiles
		/obj/projectile/energy/sphere,
		/obj/projectile/energy/sphere/attack,
		/obj/projectile/energy/sphere/heal,
		// Nuclear rod fabricators
		/obj/machinery/nuclear_rod_fabricator,
		/obj/machinery/nuclear_rod_fabricator/upgraded,
		// Other objects and datums
		/obj/item/gun/projectile/automatic/stationary_gun,
		/obj/structure/energy_net,
		/datum/turf_reservation,
		/datum/component/material_container,
	)
	/// How long each object waits in the check queue during this test.
	var/check_wait = 10 SECONDS
	/// How long a failed object waits in the hard delete queue during this test.
	/// Long enough that failed objects are still there for the reference search.
	var/hard_delete_wait = 10000 HOURS
	/// Fail the test if the queues are not drained by then.
	var/drain_timeout = 5 MINUTES
	/// How often the queues are checked while draining.
	var/poll_interval = 1 SECONDS
	/// How many new leaking types get a reference search. Each search takes 15 to 50 seconds.
	var/max_reference_searches = 5

/datum/unit_test/gc_failures/Run()
	var/old_check_wait = SSgarbage.collection_timeout[GC_QUEUE_CHECK]
	var/old_hard_delete_wait = SSgarbage.collection_timeout[GC_QUEUE_HARDDELETE]
	SSgarbage.collection_timeout[GC_QUEUE_CHECK] = check_wait
	SSgarbage.collection_timeout[GC_QUEUE_HARDDELETE] = hard_delete_wait

	var/drained = wait_for_queues(world.time)

	var/list/new_failures = list()
	for(var/path in SSgarbage.items)
		var/datum/qdel_item/item = SSgarbage.items[path]
		if(item.failures && !(path in known_failures))
			new_failures += path

	var/old_should_save_refs = SSgarbage.should_save_refs
	SSgarbage.should_save_refs = FALSE
	var/list/search_results = list()
	var/searches = 0
	for(var/path in new_failures)
		if(searches >= max_reference_searches)
			break
		search_results[path] = search_references(path)
		if(search_results[path])
			searches++
	SSgarbage.should_save_refs = old_should_save_refs

	SSgarbage.collection_timeout[GC_QUEUE_CHECK] = old_check_wait
	SSgarbage.collection_timeout[GC_QUEUE_HARDDELETE] = old_hard_delete_wait

	if(!drained)
		TEST_FAIL("The garbage queues were not checked within [DisplayTimeText(drain_timeout)]. The types below may be incomplete.")

	for(var/path in known_failures)
		var/datum/qdel_item/item = SSgarbage.items[path]
		if(drained && item?.qdels && !item.failures)
			TEST_FAIL("[path] collected all [item.qdels] times. Remove it from known_failures.")

	for(var/path in new_failures)
		var/datum/qdel_item/item = SSgarbage.items[path]
		var/where
		if(!(path in search_results))
			where = "Its references were not searched: the test stops after [max_reference_searches] searches."
		else if(search_results[path])
			where = "Its references are in gc_debug.log (REF SEARCH)."
		else
			where = "Its references were not searched: no failed object of it was left in the hard delete queue."
		TEST_FAIL("[path] failed to garbage collect [item.failures] of [item.qdels] times. [where]")

/// Sleeps until every object deleted before `start_time` has been through the filter and check queues.
/datum/unit_test/gc_failures/proc/wait_for_queues(start_time)
	var/real_start = REALTIMEOFDAY
	while(REALTIMEOFDAY < real_start + drain_timeout)
		var/oldest_deleted = INFINITY
		for(var/level in GC_QUEUE_FILTER to GC_QUEUE_CHECK)
			var/list/queue = SSgarbage.queues[level]
			for(var/i in 1 to length(queue))
				var/list/packet = queue[i]
				if(length(packet) < GC_QUEUE_ITEM_INDEX_COUNT)
					continue
				oldest_deleted = min(oldest_deleted, packet[GC_QUEUE_ITEM_GCD_DESTROYED])
				break
		if(oldest_deleted > start_time)
			return TRUE
		sleep(poll_interval)
	return FALSE

/// Logs what still holds one failed object of `path` to gc_debug.log.
/// Returns FALSE if no failed object of that type is waiting in the hard delete queue.
/datum/unit_test/gc_failures/proc/search_references(path)
	var/list/queue = SSgarbage.queues[GC_QUEUE_HARDDELETE]
	for(var/i in 1 to length(queue))
		var/list/packet = queue[i]
		if(length(packet) < GC_QUEUE_ITEM_INDEX_COUNT)
			continue
		var/datum/leaked = packet[GC_QUEUE_ITEM_REF]
		if(leaked?.type != path)
			continue
		leaked.find_references(refcount(leaked) - QUEUED_OBJECT_REFS)
		stoplag()
		return TRUE
	return FALSE

#undef QUEUED_OBJECT_REFS
