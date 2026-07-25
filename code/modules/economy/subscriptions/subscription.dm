// Parent money subscription class; extend and register in available_subscriptions.
/datum/subscription
	/// this like primary key!!! Don't create multiple subscriptions with the same name.
	var/subscription_name = ""
	var/datum/money_account/subscriber_account
	/// recipient (product owner)
	var/datum/money_account/recipient_account
	var/cost = 0
	var/description = ""
	/// Path to class / Each subscription knows who it is | for creation
	var/subscription_type_path
a
	/// must be a multiple of 5 minutes
	var/interval = 0
	var/next_payment_time = 0
	var/creation_time = 0

	var/active = TRUE
	/// If secure, subscriber cannot remove it; used for forced or modifier subscriptions and excluded from available_subscriptions
	var/secure = FALSE
	var/cancel_reason

	/// Used to remove long-dead subscriptions after too many inactive subsystem cycles.
	var/dead_cycles = 0

/datum/subscription/New(datum/money_account/subscriber, list/extra_params)
	..()

	set_subscriber_account(subscriber)
	active = TRUE
	cancel_reason = null
	subscription_type_path = type

	subscriber.brg_profile.add_subscription(src)
	recipient_account.brg_profile.add_subscription(src)

	// check that it is a subscription - template
	if(!(subscriber_account == recipient_account))
		GLOB.all_subscriptions += src
		SSsubscriptions_subsystem.add_subscription(src)

/datum/subscription/Destroy()
	subscriber_account.brg_profile.remove_subscription(src)
	recipient_account.brg_profile.remove_subscription(src)

	set_subscriber_account(null)
	set_recipient_account(null)
	GLOB.all_subscriptions -= src
	return ..()

/datum/subscription/proc/subscription_process()
	if(!active)
		return

	// If the account is deleted, delete the subscription from the global and log out.
	if(!subscriber_account || !recipient_account)
		GLOB.all_subscriptions -= src
		return

	if(!subscriber_account.charge(
		cost,
		recipient_account,
		"Оплата подписки [subscription_name]",
		"Терминал Raingor Interstellar Banking №[rand(111,333)]",
		recipient_account.owner_name ,
		"Поступление по подписке [subscription_name]",
		subscriber_account.owner_name)
	)
		cancel()
		return

	dead_cycles = 0
	notify_payment_success()

/**
 *	cancel(reason)
 *  reason is CANCEL_USER or CANCEL_SYSTEM
 *  default CANCEL_USER
 */
/datum/subscription/proc/cancel(reason = CANCEL_USER)
	active = FALSE
	cancel_reason = reason
	notify_cancelled()

/datum/subscription/proc/resub()
	if(subscriber_account.suspended || recipient_account.suspended)
		return

	active = TRUE
	cancel_reason = null
	dead_cycles = 0
	if(SSsubscriptions_subsystem)
		SSsubscriptions_subsystem.add_subscription(src)
	notify_resubscribed()

/datum/subscription/proc/notify_payment_success()
	subscriber_account?.notify_pda_owner(
		"<b> Уведомление о проведении планового платежа</b>\"Произведено списание абонентской платы за услугу '[subscription_name]' в размере [cost] кредитов. Действие подписки продлено. \" (Невозможно Ответить)",
		SUBSCRIPTION_NOTI_NO_REPLY)
	recipient_account?.notify_pda_owner(
		"<b> Уведомление о поступлении средств по подписке</b>\"От контрагента [subscriber_account.owner_name] получены периодические платежи по соглашению на услугу '[subscription_name]' в размере [cost] кредитов. Поступление отражено в реестре транзакций. \" (Невозможно Ответить)",
		SUBSCRIPTION_NOTI_NO_REPLY)

/datum/subscription/proc/notify_cancelled()
	subscriber_account?.notify_pda_owner(
		"<b> Уведомление о приостановке действия подписки</b>\"Абонентская плата за услугу '[subscription_name]' в размере [cost] кредитов не поступила. Действие подписки приостановлено. \" (Невозможно Ответить)",
		SUBSCRIPTION_NOTI_NO_REPLY)
	recipient_account?.notify_pda_owner(
		"<b> Уведомление о прекращении поступлений по подписке</b>\"Контрагент [subscriber_account.owner_name] прекратил действие соглашения на услугу '[subscription_name]'. Ожидаемые периодические поступления в размере [cost] кредитов более не производятся. Мониторинг транзакций приостановлен.\" (Невозможно Ответить)",
		SUBSCRIPTION_NOTI_NO_REPLY)

/datum/subscription/proc/notify_resubscribed()
	subscriber_account?.notify_pda_owner(
		"<b> Уведомление о возобновлении действия подписки</b>\"Произведено списание абонентской платы за услугу '[subscription_name]' в размере [cost] кредитов. Действие подписки восстановлено. \" (Невозможно Ответить)",
		SUBSCRIPTION_NOTI_NO_REPLY)

	recipient_account?.notify_pda_owner(
		"<b> Уведомление о возобновлении поступлений по подписке</b>\"Контрагент [subscriber_account.owner_name] возобновил действие соглашения на услугу '[subscription_name]'. Ожидаемые периодические поступления в размере [cost] кредитов активированы. Мониторинг транзакций возобновлен.\" (Невозможно Ответить)",
		SUBSCRIPTION_NOTI_NO_REPLY)

/datum/subscription/proc/set_subscriber_account(datum/money_account/new_account)
	if(subscriber_account == new_account)
		return

	if(subscriber_account)
		UnregisterSignal(subscriber_account, COMSIG_ACCOUNT_SUSPENDED)
		UnregisterSignal(subscriber_account, COMSIG_ACCOUNT_MONEY_CHANGED)
		UnregisterSignal(subscriber_account, COMSIG_ACCOUNT_UNSUSPENDED)

	subscriber_account = new_account

	if(subscriber_account)
		RegisterSignal(subscriber_account, COMSIG_ACCOUNT_SUSPENDED, PROC_REF(handle_account_suspended), TRUE)
		RegisterSignal(subscriber_account, COMSIG_ACCOUNT_MONEY_CHANGED, PROC_REF(handle_money_changed), TRUE)
		RegisterSignal(subscriber_account, COMSIG_ACCOUNT_UNSUSPENDED, PROC_REF(handle_account_unsuspended), TRUE)

/datum/subscription/proc/set_recipient_account(datum/money_account/new_account)
	if(recipient_account == new_account)
		return

	if(recipient_account && recipient_account != subscriber_account)
		UnregisterSignal(recipient_account, COMSIG_ACCOUNT_SUSPENDED)
		UnregisterSignal(recipient_account, COMSIG_ACCOUNT_UNSUSPENDED)

	recipient_account = new_account

	if(recipient_account && recipient_account != subscriber_account)
		RegisterSignal(recipient_account, COMSIG_ACCOUNT_SUSPENDED, PROC_REF(handle_account_suspended), TRUE)
		RegisterSignal(recipient_account, COMSIG_ACCOUNT_UNSUSPENDED, PROC_REF(handle_account_unsuspended), TRUE)

/datum/subscription/proc/handle_account_suspended(datum/money_account/account)
	SIGNAL_HANDLER
	if(account != subscriber_account  && account != recipient_account)
		return
	if(active)
		cancel(CANCEL_SYSTEM)

/datum/subscription/proc/handle_account_unsuspended(datum/money_account/account)
	SIGNAL_HANDLER
	if(account != subscriber_account && account != recipient_account)
		return
	if(!active && cancel_reason == CANCEL_SYSTEM)
		resub()

/datum/subscription/proc/handle_money_changed(datum/money_account/account, new_balance, change_amount)
	SIGNAL_HANDLER
	if(account != subscriber_account)
		return

	if(new_balance < cost && active)
		cancel(CANCEL_SYSTEM)

/datum/subscription/proc/get_base_subscription_ui_data(counterpart_name, direction)
	var/data = list()

	data["subscription_name"] = subscription_name
	data["recipient_name"] = counterpart_name
	data["cost"] = cost
	data["interval"] = interval
	data["status"] = active
	data["description"] = description
	data["secure"] = secure
	data["subscription_type"] = subscription_type_path
	data["direction"] = direction
	data["uid"] = UID()

	return data

/datum/subscription/proc/get_template_subscription_ui_data()
	var/data = list()

	data["available_subscription_name"] = subscription_name
	data["description"] = description
	data["cost"] = cost
	data["interval"] = interval
	data["provider"] = "Нет доступа"
	data["secure"] = secure
	data["subscription_type"] = subscription_type_path
	data["uid"] = UID()

	return data
