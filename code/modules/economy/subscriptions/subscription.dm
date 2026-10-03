// Parent money subscription class; extend and register in available_subscriptions.
/datum/economy_process/subscription
	abstract_type = /datum/economy_process/subscription
	var/subscription_name = ""
	var/alist/subscriber_accounts = alist()
	/// recipient (product owner)
	var/datum/money_account/recipient_account
	var/cost = 0
	var/description = ""
	var/secure

/datum/economy_process/subscription/on_destroy()
	subscriber_accounts = null
	recipient_account = null
	GLOB.all_subscriptions -= SUBSCRIPTION_KEY(subscription_name, type)
	return ..()

/datum/economy_process/subscription/initialize(datum/money_account/recipient_account, cost, subscription_name, description)
	src.recipient_account = recipient_account || get_default_account()
	if(!src.recipient_account)
		return
	if(cost)
		src.cost = cost
	if(subscription_name)
		src.subscription_name = subscription_name
	if(description)
		src.description = description

	var/key = SUBSCRIPTION_KEY(subscription_name, type)
	if(GLOB.all_subscriptions[key])
		return
	GLOB.all_subscriptions[key] = src
	return ..()

/datum/economy_process/subscription/proc/get_default_account()
	return

/datum/economy_process/subscription/custom_process()
	if(recipient_account.suspended)
		return ..()
	for(var/datum/money_account/subscriber_account, status in subscriber_accounts)
		if(!subscriber_account.charge(
			cost,
			recipient_account,
			"Оплата подписки [subscription_name]",
			"Терминал Raingor Interstellar Banking №[rand(111,333)]",
			recipient_account.owner_name ,
			"Поступление по подписке [subscription_name]",
			subscriber_account.owner_name)
		)
			subscriber_accounts[subscriber_account] = FALSE
			notify_cancelled(subscriber_account)
			unsub(subscriber_account)
			continue
		if(!subscriber_accounts[subscriber_account])
			subscriber_accounts[subscriber_account] = TRUE
			notify_resubscribed(subscriber_account)
			continue
		notify_payment_success(subscriber_account)

	return ..()


/datum/economy_process/subscription/proc/sub(datum/money_account/subscriber)
	subscriber_accounts[subscriber] = FALSE
	var/weakref = WEAKREF(src)
	LAZYOR(subscriber.subscriptions, weakref)
	LAZYREMOVE(subscriber.possible_resubscriptions, weakref)
	notify_resubscribed(subscriber)

/datum/economy_process/subscription/proc/unsub(datum/money_account/subscriber)
	subscriber_accounts -= subscriber
	var/weakref = WEAKREF(src)
	LAZYREMOVE(subscriber.subscriptions, weakref)
	LAZYOR(subscriber.possible_resubscriptions, weakref)
	notify_cancelled(subscriber)

/datum/economy_process/subscription/proc/notify_payment_success(datum/money_account/subscriber_account)
	subscriber_account?.notify_pda_owner(
		"<b> Уведомление о проведении планового платежа</b>\"Произведено списание абонентской платы за услугу '[subscription_name]' в размере [cost] кредитов. Действие подписки продлено. \" (Невозможно Ответить)",
		SUBSCRIPTION_NOTI_NO_REPLY)

/datum/economy_process/subscription/proc/notify_cancelled(datum/money_account/subscriber_account)
	subscriber_account?.notify_pda_owner(
		"<b> Уведомление о приостановке действия подписки на услугу '[subscription_name]'</b>\"Действие подписки приостановлено. \" (Невозможно Ответить)",
		SUBSCRIPTION_NOTI_NO_REPLY)

/datum/economy_process/subscription/proc/notify_resubscribed(datum/money_account/subscriber_account)
	subscriber_account?.notify_pda_owner(
		"<b> Уведомление о начале действия подписки</b>\"Произведено списание абонентской платы за услугу '[subscription_name]' в размере [cost] кредитов. \" (Невозможно Ответить)",
		SUBSCRIPTION_NOTI_NO_REPLY)

/datum/economy_process/subscription/proc/get_base_subscription_ui_data()
	var/data = list()

	data["subscription_name"] = subscription_name
	data["recipient_name"] = recipient_account.owner_name
	data["cost"] = cost
	data["interval"] = interval
	data["description"] = description
	data["secure"] = secure
	data["uid"] = UID()

	return data

/datum/economy_process/subscription/proc/get_template_subscription_ui_data()
	var/data = list()

	data["available_subscription_name"] = subscription_name
	data["description"] = description
	data["cost"] = cost
	data["interval"] = interval
	data["provider"] = "Нет доступа"
	data["secure"] = secure
	data["uid"] = UID()

	return data

