/// Fails for every type that failed to garbage collect while the other unit tests ran.
/// Runs last, so it sees what every other test deleted.
/datum/unit_test/gc_failures
	priority = TEST_AFTER_CREATE_AND_DESTROY
	/// Types that already failed to collect when this test was added. Remove a type once its leak is fixed.
	var/static/list/known_failures = list(
		/obj/item/stock_parts/cell/energy_gun,
	)
	/// How long each object waits in the check queue during this test.
	var/check_wait = 10 SECONDS
	/// How long a failed object waits in the hard delete queue during this test.
	/// Long enough that nothing is hard deleted while the queues drain.
	var/hard_delete_wait = 10000 HOURS
	/// Fail the test if the queues are not drained by then.
	var/drain_timeout = 5 MINUTES
	/// How often the queues are checked while draining.
	var/poll_interval = 1 SECONDS

/datum/unit_test/gc_failures/Run()
	var/old_check_wait = SSgarbage.collection_timeout[GC_QUEUE_CHECK]
	var/old_hard_delete_wait = SSgarbage.collection_timeout[GC_QUEUE_HARDDELETE]
	SSgarbage.collection_timeout[GC_QUEUE_CHECK] = check_wait
	SSgarbage.collection_timeout[GC_QUEUE_HARDDELETE] = hard_delete_wait

	var/drained = wait_for_queues(world.time)

	SSgarbage.collection_timeout[GC_QUEUE_CHECK] = old_check_wait
	SSgarbage.collection_timeout[GC_QUEUE_HARDDELETE] = old_hard_delete_wait

	if(!drained)
		TEST_FAIL("The garbage queues were not checked within [DisplayTimeText(drain_timeout)]. The types below may be incomplete.")

	for(var/path in known_failures)
		var/datum/qdel_item/item = SSgarbage.items[path]
		if(drained && item?.qdels && !item.failures)
			TEST_FAIL("[path] collected all [item.qdels] times. Remove it from known_failures.")

	for(var/path in SSgarbage.items)
		var/datum/qdel_item/item = SSgarbage.items[path]
		if(!item.failures || (path in known_failures))
			continue
		TEST_FAIL("[path] failed to garbage collect [item.failures] of [item.qdels] times. Its references are in gc_debug.log (REF SEARCH).")

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
