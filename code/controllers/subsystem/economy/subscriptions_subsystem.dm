// Manager subscriptions by Raingor
// based on the bucket scheduler architecture

// To add your subscription, you need to include it in the list of available subscriptions
// (it will automatically add your subscriptions that can be paid for via PDA)
GLOBAL_LIST_EMPTY(available_subscriptions)

//This list stores all subscriptions ever created.
//That is, even those that have been disabled, it's like a database.
GLOBAL_LIST_EMPTY(all_subscriptions)

// All subsequent subscriptions must be created at intervals that are multiples of 5
// (note: look at BASE_FREQUENCY_SUBSYSTEM for the actual number, but from now on
// I'll use the intended 5 minutes). This isn't required, but it's highly recommended.
// The subscription placement check is performed using the following process:
// interval / BASE_FREQUENCY_SUBSYSTEM and rounded down.
// So, if you use 7 minutes, it will be counted as 5, 12 minutes as 10, and so on.
#define BASE_FREQUENCY_SUBSYSTEM (5 MINUTES)
// for your test uncommit this
// #define BASE_FREQUENCY_SUBSYSTEM 1 MINUTES

// It's designed for an hour. I hope we won't have subscriptions longer than an hour.
// If we do, we'll need to increase this number proportionally. We're calculating 12 buckets
// for every 5 minutes, which will be enough for 60 minutes.
#define BUCKET_COUNT  12

SUBSYSTEM_DEF(subscriptions_subsystem)
	name = "Subscription"
	ss_id = "subscriptions_subsystem"
	init_order = INIT_ORDER_SUBSCRIPTIONS
	offline_implications = "Это планировщик подписок. Отключение приведет к остановке проверки всех подписок, а так же списаний за них"
	wait = BASE_FREQUENCY_SUBSYSTEM
	flags = SS_BACKGROUND

	var/catalog_initialized = FALSE
	// for optimization system
	// An array of buckets (time slots).
	// Each bucket contains a list of subscriptions
	// that should be executed in this tick.
	var/list/buckets
	// Current active bucket
	var/current_bucket = 1

/datum/controller/subsystem/subscriptions_subsystem/Initialize()
	. = ..()
	buckets = list()

	for(var/i in 1 to BUCKET_COUNT )
		buckets += list(list())

	return SS_INIT_SUCCESS

// The main subsystem loop.
// Called every BASE_FREQUENCY_SUBSYSTEM (5 minutes).
/datum/controller/subsystem/subscriptions_subsystem/fire()
	if(!catalog_initialized)
		initialize_catalog()
		catalog_initialized = TRUE

	// Get a list of subscriptions that should be executed now.
	var/list/current_list = buckets[current_bucket]
	var/list/process_list = list() // snapshot for ANTI-DEBIL-DM-LIST
	process_list += current_list

	for(var/datum/subscription/S in process_list)
		// Fool check and gifts The subscription can be deactivated at any time and
		// we somehow missed it
		if(S.active)
			S.subscription_process() // here subscription can deactivation
		if(S.active)
			add_subscription(S)

	buckets[current_bucket] = list()
	current_bucket++

	if(current_bucket > BUCKET_COUNT)
		current_bucket = 1

/datum/controller/subsystem/subscriptions_subsystem/proc/add_subscription(datum/subscription/S)
	// Convert the subscription interval to the number of subsystem ticks
	var/ticks = max(1, floor(S.interval / BASE_FREQUENCY_SUBSYSTEM))

	// Calculate the bucket in which the subscription should be performed.
	var/target_bucket = ((current_bucket - 1 + ticks) % BUCKET_COUNT) + 1

	buckets[target_bucket] += S

#undef BASE_FREQUENCY_SUBSYSTEM
#undef BUCKET_COUNT
