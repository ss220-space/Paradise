// If you want to know how your subscription will be included in
// the "Possible Subscriptions Section of PDA Bank,"
// follow this path: code/modules/pda/core_apps.dm

// class for subscription
// This is the subscription parent class.
// To create your own subscription, take it as a parent and extend it.
// !!!!!Don't forget to register it in available_subscriptions !!!!
// !!!!via the process in this file called "initialize_catalog" !!!!
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
	// This flag determines whether the subscriber can remove it
	// Ideally, this is used to add salary "modifiers" or similar items, like fines. || forced subscription
	// If it is enabled, do not add it to available_subscriptions
	var/secure = FALSE

/datum/subscription/New(subscriber, recipient, cost_val, interval_val, name_val, description_t)
	if(!subscriber || !istype(subscriber, /datum/money_account))
		return
	. = ..()
	subscriber_account = subscriber
	recipient_account = recipient
	cost = cost_val
	interval = interval_val
	subscription_name = name_val
	active = TRUE
	description = description_t

	//logs
	creation_time = world.time
	next_payment_time = world.time + interval

	// need for subsystem
	GLOB.all_subscriptions += src
	SSsubscriptions_subsystem.add_subscription(src)

// protection
/datum/subscription/proc/can_process()
	if(!subscriber_account || !recipient_account)
		return FALSE

	if(subscriber_account.suspended || recipient_account.suspended || subscriber_account.money < cost)
		return FALSE

	return TRUE

/datum/subscription/proc/subscription_process()
	if(!active)
		return

	// If the account is deleted, delete the subscription from the global and log out.
	if(!subscriber_account || !recipient_account)
		GLOB.all_subscriptions -= src
		return

	// check can start and safe check for charge (he can joke)
	if(!can_process() || !subscriber_account.charge(cost, recipient_account, "Оплата подписки [subscription_name]", "Терминал Raingor Interstellar Banking №[rand(111,333)]", recipient_account.owner_name , "Оплата подписки [subscription_name]", subscriber_account.owner_name))
		cancel()
	else
		next_payment_time = world.time + interval
		//pda
		subscriber_account.notify_pda_owner("<b> Уведомление о проведении планового платежа</b>\"Произведено списание абонентской платы за услугу '[subscription_name]' в размере [cost] кредитов. Действие подписки продлено. \" (Невозможно Ответить)", FALSE)
		recipient_account.notify_pda_owner("<b> Уведомление о поступлении средств по подписке</b>\"От контрагента [subscriber_account.owner_name] получены периодические платежи по соглашению на услугу '[subscription_name]' в размере [cost] кредитов. Поступление отражено в реестре транзакций. \" (Невозможно Ответить)", FALSE)

/datum/subscription/proc/cancel()
	active = FALSE
	if(subscriber_account)
		subscriber_account.notify_pda_owner("<b> Уведомление о приостановке действия подписки</b>\"Абонентская плата за услугу '[subscription_name]' в размере [cost] кредитов не поступила. Действие подписки приостановлено. \" (Невозможно Ответить)", FALSE)
	if(recipient_account)
		recipient_account.notify_pda_owner("<b> Уведомление о прекращении поступлений по подписке</b>\"Контрагент [subscriber_account.owner_name] прекратил действие соглашения на услугу '[subscription_name]'. Ожидаемые периодические поступления в размере [cost] кредитов более не производятся. Мониторинг транзакций приостановлен.\" (Невозможно Ответить)", FALSE)

/datum/subscription/proc/resub()
	active = TRUE
	if(subscriber_account)
		subscriber_account.notify_pda_owner("<b> Уведомление о возобновлении действия подписки</b>\"Произведено списание абонентской платы за услугу '[subscription_name]' в размере [cost] кредитов. Действие подписки восстановлено. \" (Невозможно Ответить)", FALSE)
	if(recipient_account)
		recipient_account.notify_pda_owner("<b> Уведомление о возобновлении поступлений по подписке</b>\"Контрагент [subscriber_account.owner_name] возобновил действие соглашения на услугу '[subscription_name]'. Ожидаемые периодические поступления в размере [cost] кредитов активированы. Мониторинг транзакций возобновлен.\" (Невозможно Ответить)", FALSE)

// This process is one of the basic ones; if you don’t add your subscription
// as a test one, it won’t be displayed!
/datum/controller/subsystem/subscriptions_subsystem/proc/initialize_catalog()
	GLOB.available_subscriptions.Cut()
	// Because this is a DEMONSTRATION SUBSCRIPTION (the one that is not active, but which shows what subscriptions exist),
	// you must make sure that this subscription has sender and recipient accounts GLOB.station_account
	GLOB.available_subscriptions += new /datum/subscription/station_donations(GLOB.station_account)

/proc/find_subscription_with_name(subscriber_account_name, subscription_name_f)
	for(var/datum/subscription/check_subscription in GLOB.all_subscriptions)
		if(!check_subscription || !check_subscription.subscriber_account)
			continue
		if(check_subscription.subscription_name ==  subscription_name_f && check_subscription.subscriber_account.owner_name == subscriber_account_name)
			return check_subscription
	return

// An example of a station donation subscription
/datum/subscription/station_donations
	subscription_name = "Фонд развития станции"
	description = " Регулярное перечисление средств на модернизацию систем жизнеобеспечения. Поощряется руководством НТ и отделом кадров."
	cost = 199
	interval = 5 MINUTES

/datum/subscription/station_donations/New(subscriber)
	..(subscriber, GLOB.station_account, cost, interval, subscription_name, description)
