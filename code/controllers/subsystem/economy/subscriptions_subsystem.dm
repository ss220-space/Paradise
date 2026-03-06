//Manager subscriptions
// If you create a subscription, the minimum interval will be 5 minutes.
// To add your subscription, you need to include it in the list of available subscriptions
// (it will automatically add your subscriptions that can be paid for via PDA)
GLOBAL_LIST_EMPTY(available_subscriptions)

//This list stores all subscriptions ever created.
//That is, even those that have been disabled, it's like a database.
GLOBAL_LIST_EMPTY(all_subscriptions)

// All subsequent subscriptions will have to be created at intervals that are multiples of 5.
// Because there will be a check every 5 minutes, and if the interval is 7 minutes,
// then the check will only be every 10 minutes, and there is no point.
#define BASE_FREQUENCY_SUBSYSTEM 5 MINUTES

SUBSYSTEM_DEF(subscriptions_subsystem)
	name = "Subscription"
	ss_id = "subscriptions_subsystem"
	init_order = INIT_ORDER_SUBSCRIPTIONS
	offline_implications = "Это планировщик подписок. Отключение приведет к остановке проверки всех подписок, а так же списаний за них"
	wait = BASE_FREQUENCY_SUBSYSTEM
	flags = SS_BACKGROUND

	//for optimization system
	var/list/subscriptions_queue = list()

//wip
/datum/controller/subsystem/subscriptions_subsystem/Initialize()
	. = ..()
	return SS_INIT_SUCCESS

//business logic here
//wip
// /datum/controller/subsystem/subscriptions_subsystem/fire()


#undef BASE_FREQUENCY_SUBSYSTEM
