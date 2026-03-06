// If you want to know how your subscription will be included in
// the "Possible Subscriptions Section of PDA Bank,"
// follow this path: code/modules/pda/core_apps.dm

// class for subscription
// This is the subscription parent class.
// To create your own subscription, take it as a parent and extend it.
// Don't forget to register it in available_subscriptions.
/datum/subscription
	var/subscription_name = "" // this like primary key!!! Don't create multiple subscriptions with the same name.
	var/datum/money_account/subscriber_account
	var/datum/money_account/recipient_account //recipient (product owner)
	var/cost = 0
	var/description = ""

	// time logic
	var/interval = 0 // must be a multiple of 5 minutes
	var/next_payment_time = 0
	var/creation_time = 0

	var/active = TRUE

/datum/subscription/New(subscriber, recipient, cost_val, interval_val, name_val, description_t)
	. = ..()
	subscriber_account = subscriber
	recipient_account = recipient
	cost = cost_val
	interval = interval_val
	subscription_name = name_val
	active = TRUE
	creation_time = world.time
	next_payment_time = world.time + interval
	description = description_t

// protection
/datum/subscription/proc/can_process()
	var/result = TRUE

	if(subscriber_account.suspended || recipient_account.suspended || subscriber_account.money < cost)
		result = FALSE

	return result

/datum/subscription/proc/subscription_process()
	if(!active)
		return

	// If the account is deleted, delete the subscription from the global and log out.
	if(!subscriber_account || !recipient_account)
		GLOB.all_subscriptions -= src
		return

	// check can start and safe check for charge (he can joke)
	if(!can_process() || !subscriber_account.charge(cost, recipient_account, subscription_name, subscriber_account.owner_name, subscription_name, "Оплата подписки", "Терминал Raingor Interstellar Banking №[rand(111,333)]"))
		cancel()
	else
		next_payment_time = world.time + interval
		//pda
		subscriber_account.notify_pda_owner("<b>Уведомление о проведении планового платежа</b>\"Произведено списание абонентской платы за услугу '[subscription_name]' в размере [cost] кредитов. Действие подписки продлено. Доступ к сервису подтверждён.\" (Невозможно Ответить)", FALSE)
		recipient_account.notify_pda_owner("<b>Уведомление о поступлении средств по подписке</b>\"От контрагента [subscriber_account.owner_name] получены периодические платежи по соглашению на услугу '[subscription_name]' в размере [cost] кредитов. Поступление отражено в реестре транзакций.\" (Невозможно Ответить)", FALSE)

/datum/subscription/proc/cancel()
	active = FALSE
	subscriber_account.notify_pda_owner("<b>Уведомление о приостановке действия подписки</b>\"Абонентская плата за услугу '[subscription_name]' в размере [cost] кредитов не поступила. Действие подписки приостановлено. Доступ к сервису деактивирован.\" (Невозможно Ответить)", FALSE)
	recipient_account.notify_pda_owner("<b>Уведомление о прекращении поступлений по подписке</b>\"Контрагент [subscriber_account.owner_name] прекратил действие соглашения на услугу '[subscription_name]'. Ожидаемые периодические поступления в размере [cost] кредитов более не производятся. Мониторинг транзакций приостановлен.\" (Невозможно Ответить)", FALSE)

/datum/subscription/proc/resub()
	active = TRUE
	subscriber_account.notify_pda_owner("<b>Уведомление о возобновлении действия подписки</b>\"Произведено списание абонентской платы за услугу '[subscription_name]' в размере [cost] кредитов. Действие подписки восстановлено. Доступ к сервису активирован.\" (Невозможно Ответить)", FALSE)
	recipient_account.notify_pda_owner("<b>Уведомление о возобновлении поступлений по подписке</b>\"Контрагент [subscriber_account.owner_name] возобновил действие соглашения на услугу '[subscription_name]'. Ожидаемые периодические поступления в размере [cost] кредитов активированы. Мониторинг транзакций возобновлен.\" (Невозможно Ответить)", FALSE)

/proc/find_subscription_with_name(subscriber_account_name, subscription_name_f)
	for(var/datum/subscription/check_subscription in GLOB.all_subscriptions)
		if(check_subscription.subscription_name ==  subscription_name_f && check_subscription.subscriber_account.owner_name == subscriber_account_name)
			return check_subscription
	return
