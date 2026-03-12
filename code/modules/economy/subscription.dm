// If you want to know how your subscription will be included in
// the "Possible Subscriptions Section of PDA Bank,"
// follow this path: code/modules/pda/core_apps.dm

// To create your subscription correctly, please read this file in its entirety.
// All documentation is available for this subsystem.
// If anything is unclear, please contact the Raingor Discord.

// ======================================================================================
//								Parent Subscription Class
// ======================================================================================

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
	// Path to class / Each subscription knows who it is / for creation
	var/subscription_type_path

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
	subscription_type_path = type

	//logs
	creation_time = world.time
	next_payment_time = world.time + interval

	// check that it is a subscription - template
	if(!(subscriber_account == recipient_account))
		GLOB.all_subscriptions += src
		SSsubscriptions_subsystem.add_subscription(src)

/datum/subscription/proc/subscription_process()
	if(!active)
		return

	// If the account is deleted, delete the subscription from the global and log out.
	if(!subscriber_account || !recipient_account)
		GLOB.all_subscriptions -= src
		return

	// check can start and safe check for charge (he can joke)
	if(!can_process())
		cancel()
	else if(!subscriber_account.charge(cost, recipient_account, "Оплата подписки [subscription_name]", "Терминал Raingor Interstellar Banking №[rand(111,333)]", recipient_account.owner_name , "Поступление по подписке [subscription_name]", subscriber_account.owner_name))
		cancel()
	else
		next_payment_time = world.time + interval
		//pda
		subscriber_account.notify_pda_owner("<b> Уведомление о проведении планового платежа</b>\"Произведено списание абонентской платы за услугу '[subscription_name]' в размере [cost] кредитов. Действие подписки продлено. \" (Невозможно Ответить)", FALSE)
		recipient_account.notify_pda_owner("<b> Уведомление о поступлении средств по подписке</b>\"От контрагента [subscriber_account.owner_name] получены периодические платежи по соглашению на услугу '[subscription_name]' в размере [cost] кредитов. Поступление отражено в реестре транзакций. \" (Невозможно Ответить)", FALSE)

// protection
/datum/subscription/proc/can_process()
	if(!subscriber_account || !recipient_account)
		return FALSE

	if(subscriber_account.suspended || recipient_account.suspended || subscriber_account.money < cost)
		return FALSE

	return TRUE

/datum/subscription/proc/cancel()
	active = FALSE
	if(subscriber_account)
		subscriber_account.notify_pda_owner("<b> Уведомление о приостановке действия подписки</b>\"Абонентская плата за услугу '[subscription_name]' в размере [cost] кредитов не поступила. Действие подписки приостановлено. \" (Невозможно Ответить)", FALSE)
	if(recipient_account)
		recipient_account.notify_pda_owner("<b> Уведомление о прекращении поступлений по подписке</b>\"Контрагент [subscriber_account.owner_name] прекратил действие соглашения на услугу '[subscription_name]'. Ожидаемые периодические поступления в размере [cost] кредитов более не производятся. Мониторинг транзакций приостановлен.\" (Невозможно Ответить)", FALSE)

/datum/subscription/proc/resub()
	active = TRUE

	if(SSsubscriptions_subsystem)
		SSsubscriptions_subsystem.add_subscription(src)

	if(subscriber_account)
		subscriber_account.notify_pda_owner("<b> Уведомление о возобновлении действия подписки</b>\"Произведено списание абонентской платы за услугу '[subscription_name]' в размере [cost] кредитов. Действие подписки восстановлено. \" (Невозможно Ответить)", FALSE)
	if(recipient_account)
		recipient_account.notify_pda_owner("<b> Уведомление о возобновлении поступлений по подписке</b>\"Контрагент [subscriber_account.owner_name] возобновил действие соглашения на услугу '[subscription_name]'. Ожидаемые периодические поступления в размере [cost] кредитов активированы. Мониторинг транзакций возобновлен.\" (Невозможно Ответить)", FALSE)

// ======================================================================================
//								    Additional Tools
// ======================================================================================

// This process is one of the basic ones; if you don’t add your subscription
// as a test one, it won’t be displayed!
/datum/controller/subsystem/subscriptions_subsystem/proc/initialize_catalog()
	GLOB.available_subscriptions.Cut()
	// Because this is a DEMONSTRATION SUBSCRIPTION (the one that is not active, but which shows what subscriptions exist),
	// you must make sure that this subscription has sender and recipient accounts GLOB.station_account
	GLOB.available_subscriptions += new /datum/subscription/station_donations(GLOB.station_account)
	GLOB.available_subscriptions += new /datum/subscription/salary_modifier(GLOB.station_account)

/proc/find_subscription_with_name(subscriber_account_name, subscription_name_f)
	for(var/datum/subscription/check_subscription in GLOB.all_subscriptions)
		if(!check_subscription || !check_subscription.subscriber_account)
			continue
		if(check_subscription.subscription_name ==  subscription_name_f && check_subscription.subscriber_account.owner_name == subscriber_account_name)
			return check_subscription
	return

/proc/find_subscription_with_type(subscriber_account_name, subscription_type)
	for(var/datum/subscription/S in GLOB.all_subscriptions)
		if(!S || !S.subscriber_account)
			continue
		if(S.subscription_type_path == subscription_type && S.subscriber_account.owner_name == subscriber_account_name)
			return S

/proc/find_subscription_salary_modifier_spec(subscriber_account_name, subscription_type)
	for(var/datum/subscription/salary_modifier/S in GLOB.all_subscriptions)
		if(!S || !S.subscriber_account)
			continue

		var/subscr

		if(S.modifier <= 0)
			subscr = S.subscriber_account.owner_name
		else
			subscr = S.recipient_account.owner_name

		if(S.subscription_type_path == subscription_type && subscr == subscriber_account_name)
			return S

/proc/create_subscription(
	datum/money_account/subscriber_account,
	subscription_type,
	extra_params
)

	// 9 rounds of testing
	if(!subscriber_account || !istype(subscriber_account, /datum/money_account))
		to_chat(usr, span_warning("Ошибка: неверный аккаунт подписчика."))
		return FALSE

	if(!subscription_type || !ispath(subscription_type,/datum/subscription))
		to_chat(usr, span_warning("Ошибка: неверный тип подписки."))
		return FALSE

	if(subscriber_account.suspended)
		to_chat(usr, span_warning("Ошибка: аккаунт #[subscriber_account.account_number] заблокирован."))
		return FALSE

	// Find a template in the catalog of available subscriptions
	var/datum/subscription/template = null

	for(var/datum/subscription/S in GLOB.available_subscriptions)
		if(S && S.type == subscription_type)
			template = S
			break

	if(!template)
		to_chat(usr, span_warning("Ошибка: подписка типа [subscription_type] не найдена в каталоге."))
		return FALSE

	var/datum/subscription/existing = find_subscription_with_type(subscriber_account.owner_name, subscription_type)

	if(existing)
		if(existing.active)
			to_chat(usr, span_warning("У вас уже есть активная подписка '[template.subscription_name]'."))
			return FALSE
		else
			existing.resub()
			if(existing.active)
				to_chat(usr, span_warning("Подписка '[template.subscription_name]' была ранее оформлена и восстановлена."))
				return TRUE
			else
				to_chat(usr, span_warning("Не удалось восстановить подписку '[template.subscription_name]'."))
				return FALSE

	// Basic variables
	var/sub_recipient_account = template.recipient_account
	var/sub_cost = template.cost
	var/sub_interval = template.interval
	var/sub_subscription_name = template.subscription_name
	var/sub_description = template.description

	// custom variables
	var/modifier

	// CUSTOM variables activate
	switch(subscription_type)
		if(/datum/subscription/salary_modifier)
			modifier = extra_params ? extra_params["modifier"] : 0
			modifier = text2num(modifier)
			modifier = clamp(modifier, -50, 50)

	// FABRIC PATTERN
	var/datum/subscription/new_sub = null
	switch(subscription_type)
		if(/datum/subscription/salary_modifier) // CUSTOM
			new_sub = new subscription_type(subscriber_account, modifier)
		else									// DEFAULT
			new_sub = new subscription_type(subscriber_account, sub_recipient_account, sub_cost, sub_interval, sub_subscription_name, sub_description)

	if(!new_sub || !istype(new_sub, /datum/subscription))
		to_chat(usr, span_warning("Критическая ошибка: не удалось создать подписку."))
		return FALSE

	if(!new_sub.active)
		to_chat(usr, span_warning("Ошибка: подписка создана, но не активирована."))
		return FALSE

	to_chat(usr, span_warning("Подписка '[sub_subscription_name]' успешно оформлена."))

	return TRUE

// ======================================================================================
//								    subscriptions
// ======================================================================================

// An example of a station donation subscription
/datum/subscription/station_donations
	subscription_name = "Фонд развития станции"
	description = " Регулярное перечисление средств на модернизацию систем жизнеобеспечения. Поощряется руководством НТ и отделом кадров."
	cost = 100
	interval = 10 MINUTES

/datum/subscription/station_donations/New(subscriber)
	..(subscriber, GLOB.station_account, cost, interval, subscription_name, description)

/datum/subscription/salary_modifier
	// Percentage change in salary
	subscription_name = "Персональная надбавка / удержание"
	description = "Изменение коэффициента оплаты труда в соответствии с должностными инструкциями. За разъяснениями, согласованием или отменой параметра обращайтесь к Главе Персонала."
	interval = FREQUENCY_SALARY
	secure = TRUE

	var/modifier = 0

/datum/subscription/salary_modifier/New(datum/money_account/subscriber, new_modifier = 0)
	modifier = new_modifier

	var/datum/job/J = subscriber.linked_job
	var/base_paycheck = 0

	if(J && istype(J, /datum/job))
		base_paycheck = J.paycheck

	if(modifier <= 0)
		subscriber_account = subscriber
		recipient_account = GLOB.station_account
		cost = (base_paycheck * (modifier / 100)) * -1
	else
		subscriber_account = GLOB.station_account
		recipient_account = subscriber
		cost = base_paycheck * (modifier / 100)

	..(subscriber_account, recipient_account, cost, interval, subscription_name, description)


