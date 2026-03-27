/**
 * SUBSCRIPTIONS SUBSYSTEM
 * Created by Raingor
 * Architecture: Bucket Scheduler with Resume Support (Non-blocking)
 *
 * This subsystem manages the lifecycle of all active financial subscriptions on the station.
 * It uses the "Bucket Scheduler" pattern to distribute the load over time (like a timer), preventing server latency.
 * Makes subscriptions centarized and pay at the same time.
 *
 * MAIN FEATURES:
 * - Group subscription system: Subscriptions are grouped by time slots (buckets) depending on their interval.
 * - Resumption logic
 * - Cyclic buffer: 12 segments are used to cover a 60-minute interval (with a 5-minute frequency).
 *
 * CONFIGURATION:
 * - BASE_FREQUENCY_SUBSYSTEM: Subsystem response frequency (default: 5 minutes).
 * - BUCKET_COUNT: number of time intervals. Total Coverage = Frequency * Amount (default: 12 buckets).
*/

/// Global list of subscription templates available for users to purchase via PDA.
/// Populated in initialize_catalog().
GLOBAL_LIST_EMPTY(available_subscriptions)

/// Global registry of ALL subscription instances ever created (active or inactive).
/// Acts as a persistent database for auditing and lookup.
GLOBAL_LIST_EMPTY(all_subscriptions)

/// The base tick rate of this subsystem. All subscription intervals should ideally be
/// multiples of this value for precise scheduling.
#define BASE_FREQUENCY_SUBSYSTEM (5 MINUTES)

/// Number of time buckets. With a 5-minute wait, 12 buckets cover 1 hour of scheduling.
/// Increase this value if you plan to have subscriptions with intervals > 1 hour.
#define BUCKET_COUNT 12

SUBSYSTEM_DEF(subscriptions_subsystem)
	name = "Subscriptions"
	ss_id = "subscriptions_subsystem"
	init_order = INIT_ORDER_SUBSCRIPTIONS
	offline_implications = "Это планировщик подписок. Отключение приведет к остановке проверки всех подписок, а так же списаний за них"
	wait = BASE_FREQUENCY_SUBSYSTEM
	flags = SS_BACKGROUND

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

/datum/controller/subsystem/subscriptions_subsystem/Initialize()
	. = ..()
	init_buckets()

	return SS_INIT_SUCCESS

/**
 * Main entry point for the subsystem tick.
 * Called every [BASE_FREQUENCY_SUBSYSTEM] by the Master Controller.
 */
/datum/controller/subsystem/subscriptions_subsystem/fire(resumed)
	// Ensure the catalog of available subscriptions is initialized once.
	if(!catalog_initialized)
		initialize_catalog()
		catalog_initialized = TRUE

	fire_buckets(resumed)

/**
 * Processes the subscriptions in the current bucket.
 * Implements resume logic to prevent server overrun (lag).
 */
/datum/controller/subsystem/subscriptions_subsystem/proc/fire_buckets(resumed)
	if(!resumed)
		var/list/source_bucket = buckets[current_bucket_index]
		current_bucket = source_bucket.Copy()

	var/list/cached_current_bucket = current_bucket
	var/index_bucket = length(cached_current_bucket)

	while(index_bucket > 0)
		var/datum/subscription/current_sub = cached_current_bucket[index_bucket]

		if(current_sub.active)
			current_sub.subscription_process()

		// This check is necessary to verify whether the subscription survived after its processing
		// and to prevent adding a non-working subscription to the scheduler.
		if(current_sub.active)
			add_subscription(current_sub)

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
/datum/controller/subsystem/subscriptions_subsystem/proc/init_buckets()
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
/datum/controller/subsystem/subscriptions_subsystem/proc/add_subscription(datum/subscription/added_subscription)
	/// ticks means bucket, not ticks in the usual understanding of the DM engine
	/// Calculate how many subsystem ticks (buckets) ahead this subscription should go.
	/// Minimum 1 tick to ensure it doesn't run in the current pass.
	var/ticks = max(1, floor(added_subscription.interval / BASE_FREQUENCY_SUBSYSTEM))

	/// Calculate the target bucket index.
	/// The math handles the circular nature of the buffer (wrapping from 12 back to 1).
	var/target_bucket = ((current_bucket_index - 1 + ticks) % BUCKET_COUNT) + 1

	// Add the subscription to the target future bucket.
	buckets[target_bucket] += added_subscription

#undef BASE_FREQUENCY_SUBSYSTEM
#undef BUCKET_COUNT
