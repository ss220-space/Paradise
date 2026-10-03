/// Global registry of ALL subscription instances ever created (active or inactive).
GLOBAL_LIST_EMPTY(all_subscriptions)

SUBSYSTEM_DEF(timed_economy)
	name = "Timed economy"
	wait = BASE_FREQUENCY_SUBSYSTEM
	ss_flags = SS_BACKGROUND

	var/catalog_initialized = FALSE /// Flag to ensure catalog is loaded only once.

	/// The core scheduler structure. An array where each index represents a future time slot.
	/// buckets[i] contains a list of /datum/subscription objects due to be processed in that slot.
	var/list/buckets

	/// Index of the bucket currently being processed (1 to BUCKET_COUNT).
	var/current_bucket_index = 1

	/// For resumed
	/// Temporary working list used during resumed processing.
	/// Holds the copy of the current bucket to allow safe modification (Cut) without affecting the original until completion.
	var/list/current_bucket

/datum/controller/subsystem/timed_economy/Initialize()
	. = ..()
	init_buckets()

	return SS_INIT_SUCCESS

/**
 * Main entry point for the subsystem tick.
 * Called every [BASE_FREQUENCY_SUBSYSTEM] by the Master Controller.
 */
/datum/controller/subsystem/timed_economy/fire(resumed)
	// Ensure the catalog of available subscriptions is initialized once.
	if(!catalog_initialized)
		initialize_catalog()
		catalog_initialized = TRUE

	fire_buckets(resumed)

/**
 * Processes the subscriptions in the current bucket.
 * Implements resume logic to prevent server overrun (lag).
 */
/datum/controller/subsystem/timed_economy/proc/fire_buckets(resumed)
	if(!resumed)
		var/list/source_bucket = buckets[current_bucket_index]
		current_bucket = source_bucket.Copy()

	var/list/cached_current_bucket = current_bucket
	var/index_bucket = length(cached_current_bucket)

	while(index_bucket > 0)
		var/datum/economy_process/current_sub = cached_current_bucket[index_bucket]

		current_sub.alt_process()

		if(MC_TICK_CHECK)
			cached_current_bucket.Cut(index_bucket)
			return

		index_bucket--

	buckets[current_bucket_index] = list()
	current_bucket_index++

	if(current_bucket_index > BUCKET_COUNT)
		current_bucket_index = 1

/**
 * Initializes the bucket array with empty lists.
 * Called once during subsystem initialization.
 */
/datum/controller/subsystem/timed_economy/proc/init_buckets()
	buckets = new/list(BUCKET_COUNT)

	for(var/i in 1 to BUCKET_COUNT)
		buckets[i] = list()

/**
 * Schedules a subscription for future processing.
 * Calculates the target bucket based on the subscription's interval and the current index.
 *
 * MATH:
 * target_bucket = ((current_index - 1 + ticks_to_wait) % BUCKET_COUNT) + 1
 * This formula ensures correct wrap-around behavior within the circular buffer.
 */
/datum/controller/subsystem/timed_economy/proc/add_economy_process(datum/economy_process/added_process)
	/// "ticks" refers to bucket indices (not regular DM ticks).
	/// Calculate how many subsystem steps to delay the subscription. Minimum is 1.
	var/ticks = max(1, floor(added_process.interval / BASE_FREQUENCY_SUBSYSTEM))

	/// Calculate the target bucket index.
	/// The math handles the circular nature of the buffer (wrapping from 12 back to 1).
	var/target_bucket = ((current_bucket_index - 1 + ticks) % BUCKET_COUNT) + 1

	// Add the subscription to the target future bucket.
	buckets[target_bucket] += added_process

/**
 * This process is one of the basic ones; if you don’t add your subscription
 * as a test one, it won’t be displayed!
*/
/datum/controller/subsystem/timed_economy/proc/initialize_catalog()
	for(var/type in valid_subtypesof(/datum/economy_process/subscription))
		new type

#undef BASE_FREQUENCY_SUBSYSTEM
#undef BUCKET_COUNT
