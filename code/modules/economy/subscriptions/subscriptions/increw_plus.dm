/proc/get_increw_plus_subscription()
	var/plan_name = INCREW_PLUS_NAME
	var/plan_type = /datum/economy_process/subscription/increw_plus
	return GLOB.all_subscriptions[SUBSCRIPTION_KEY(plan_name, plan_type)]

/datum/economy_process/subscription/increw_plus
	subscription_name = INCREW_PLUS_NAME
	description = "Групповые чаты и исходящие звонки InCrew. Первый платёж списывается при подключении."
	cost = INCREW_PLUS_COST
	interval = INCREW_PLUS_INTERVAL

/datum/economy_process/subscription/increw_plus/initialize(datum/money_account/recipient_account, cost, subscription_name, description)
	return ..(recipient_account, cost, INCREW_PLUS_NAME, description)

/datum/economy_process/subscription/increw_plus/get_default_account()
	return GLOB.station_account

/datum/economy_process/subscription/increw_plus/sub(datum/money_account/subscriber)
	if(QDELETED(subscriber) || QDELETED(recipient_account) || recipient_account.suspended || subscriber == recipient_account)
		return FALSE
	if(subscriber_accounts[subscriber])
		return TRUE
	if(!subscriber.charge(
		cost,
		recipient_account,
		"Оплата подписки [subscription_name]",
		"Терминал InCrew",
		recipient_account.owner_name,
		"Поступление по подписке [subscription_name]",
		subscriber.owner_name,
	))
		return FALSE

	RegisterSignal(subscriber, COMSIG_QDELETING, PROC_REF(on_subscriber_deleted))
	..(subscriber)
	subscriber_accounts[subscriber] = TRUE
	return TRUE

/datum/economy_process/subscription/increw_plus/unsub(datum/money_account/subscriber)
	UnregisterSignal(subscriber, COMSIG_QDELETING)
	return ..()

/datum/economy_process/subscription/increw_plus/proc/on_subscriber_deleted(datum/money_account/subscriber)
	SIGNAL_HANDLER
	subscriber_accounts -= subscriber
	UnregisterSignal(subscriber, COMSIG_QDELETING)

/datum/economy_process/subscription/increw_plus/on_destroy()
	for(var/datum/money_account/subscriber as anything in subscriber_accounts)
		UnregisterSignal(subscriber, COMSIG_QDELETING)
	return ..()
