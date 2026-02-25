// Upgrade capitalsm.dm: Add feature like subs on real life
// че делаем
// консольку для командования с отображением денег станции, отделов, кредитов карго
// дальше тестим сабсистему
// затем как нить там доделаем штрафы, повышение зп
// идея для антагов сделать миссию по тому, что бы станция стала банкротом через эту консольку гыг


#define BASE_FREQUENCY_SUBSYSTEM 10 MINUTES

SUBSYSTEM_DEF(subscriptions_subsystem)
	name = "Subscription"
	ss_id = "subscriptions_subsystem"
	init_order = INIT_ORDER_SUBSCRIPTIONS
	offline_implications = "The system will stop tracking subscriptions. All subscriptions will be terminated. Its not guaranteed that this wont break other parts of the code at this point—we are working on it."
	wait = BASE_FREQUENCY_SUBSYSTEM
	flags = SS_BACKGROUND

/datum/controller/subsystem/subscriptions_subsystem/Initialize()
	. = ..()
	return SS_INIT_SUCCESS

//business logic here
/datum/controller/subsystem/subscriptions_subsystem/fire()

#undef BASE_FREQUENCY_SUBSYSTEM
