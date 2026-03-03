//Manager subscriptions
GLOBAL_LIST_EMPTY(all_subscriptions)

#define BASE_FREQUENCY_SUBSYSTEM 10 MINUTES

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
/datum/controller/subsystem/subscriptions_subsystem/fire()

#undef BASE_FREQUENCY_SUBSYSTEM
