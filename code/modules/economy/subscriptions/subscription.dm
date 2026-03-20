/**
 * If you want to know how your subscription will be included in
 * the "Possible Subscriptions Section of PDA Bank,"
 * follow this path: code/modules/pda/core_apps.dm
 *
 * To create your subscription correctly, please read this file in its entirety.
 * All documentation is available for this subsystem.
 * If anything is unclear, please contact the Raingor Discord.
 *
 * ======================================================================================
 *								Parent Subscription Class
 * ======================================================================================
 * This is the subscription parent class.
 * To create your own subscription, take it as a parent and extend it.
 *
 * Don't forget to register it in available_subscriptions
 * via the process in this file called "initialize_catalog"
*/

/datum/subscription
	var/subscription_name = "" /// this like primary key!!! Don't create multiple subscriptions with the same name.
	var/datum/money_account/subscriber_account
	var/datum/money_account/recipient_account /// recipient (product owner)
	var/cost = 0
	var/description = ""
	/// Path to class / Each subscription knows who it is | for creation
	var/subscription_type_path

	// time logic
	var/interval = 0 /// must be a multiple of 5 minutes
	var/next_payment_time = 0
	var/creation_time = 0

	var/active = TRUE
	/// This flag determines whether the subscriber can remove it
	/// Ideally, this is used to add salary "modifiers" or similar items, like fines. || forced subscription
	/// If it is enabled, do not add it to available_subscriptions
	var/secure = FALSE
	var/cancel_reason

/datum/subscription/New(datum/money_account/subscriber, list/extra_params)
	if(!subscriber || !is_money_account(subscriber))
		return
	..()

	// base init
	subscriber_account = subscriber
	active = TRUE
	cancel_reason = null
	subscription_type_path = type
	register_for_signals()

	// check that it is a subscription - template
	if(!(subscriber_account == recipient_account))
		GLOB.all_subscriptions += src
		SSsubscriptions_subsystem.add_subscription(src)

/datum/subscription/Destroy()
	subscriber_account = null
	recipient_account = null
	. = ..()

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

	subscriber_account?.notify_pda_owner(
		"<b> Уведомление о проведении планового платежа</b>\"Произведено списание абонентской платы за услугу '[subscription_name]' в размере [cost] кредитов. Действие подписки продлено. \" (Невозможно Ответить)",
		SUBSCRIPTION_NOTI_NO_REPLY)
	recipient_account?.notify_pda_owner(
		"<b> Уведомление о поступлении средств по подписке</b>\"От контрагента [subscriber_account.owner_name] получены периодические платежи по соглашению на услугу '[subscription_name]' в размере [cost] кредитов. Поступление отражено в реестре транзакций. \" (Невозможно Ответить)",
		SUBSCRIPTION_NOTI_NO_REPLY)

/**
 *	cancel(reason)
 *  reason is CANCEL_USER or CANCEL_SYSTEM
 *  default CANCEL_USER
 */
/datum/subscription/proc/cancel(reason = CANCEL_USER)
	active = FALSE
	cancel_reason = reason
	subscriber_account?.notify_pda_owner(
		"<b> Уведомление о приостановке действия подписки</b>\"Абонентская плата за услугу '[subscription_name]' в размере [cost] кредитов не поступила. Действие подписки приостановлено. \" (Невозможно Ответить)",
		SUBSCRIPTION_NOTI_NO_REPLY)
	recipient_account?.notify_pda_owner(
		"<b> Уведомление о прекращении поступлений по подписке</b>\"Контрагент [subscriber_account.owner_name] прекратил действие соглашения на услугу '[subscription_name]'. Ожидаемые периодические поступления в размере [cost] кредитов более не производятся. Мониторинг транзакций приостановлен.\" (Невозможно Ответить)",
		SUBSCRIPTION_NOTI_NO_REPLY)

/datum/subscription/proc/resub()
	if(subscriber_account.suspended || recipient_account.suspended)
		return

	active = TRUE
	cancel_reason = null
	if(SSsubscriptions_subsystem)
		SSsubscriptions_subsystem.add_subscription(src)

	subscriber_account?.notify_pda_owner(
		"<b> Уведомление о возобновлении действия подписки</b>\"Произведено списание абонентской платы за услугу '[subscription_name]' в размере [cost] кредитов. Действие подписки восстановлено. \" (Невозможно Ответить)",
		SUBSCRIPTION_NOTI_NO_REPLY)

	recipient_account?.notify_pda_owner(
		"<b> Уведомление о возобновлении поступлений по подписке</b>\"Контрагент [subscriber_account.owner_name] возобновил действие соглашения на услугу '[subscription_name]'. Ожидаемые периодические поступления в размере [cost] кредитов активированы. Мониторинг транзакций возобновлен.\" (Невозможно Ответить)",
		SUBSCRIPTION_NOTI_NO_REPLY)

/**
 * Registers this subscription for signals from accounts.
 * Called once when the subscription is created.
 */
/datum/subscription/proc/register_for_signals()
	if(subscriber_account)
		RegisterSignal(subscriber_account, COMSIG_ACCOUNT_SUSPENDED, PROC_REF(handle_account_suspended))
		RegisterSignal(subscriber_account, COMSIG_ACCOUNT_MONEY_CHANGED, PROC_REF(handle_money_changed))
		RegisterSignal(subscriber_account, COMSIG_ACCOUNT_UNSUSPENDED, PROC_REF(handle_account_unsuspended))
	if(recipient_account && recipient_account != subscriber_account)
		RegisterSignal(recipient_account, COMSIG_ACCOUNT_SUSPENDED, PROC_REF(handle_account_suspended))
		RegisterSignal(recipient_account, COMSIG_ACCOUNT_UNSUSPENDED, PROC_REF(handle_account_unsuspended))

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

	data["subscription_name"] = src.subscription_name
	data["recipient_name"] = counterpart_name
	data["cost"] = src.cost
	data["interval"] = src.interval
	data["status"] = src.active
	data["description"] = src.description
	data["secure"] = src.secure
	data["subscription_type"] = src.subscription_type_path
	data["direction"] = direction
	data["uid"] = src.UID()

	return data

/datum/subscription/proc/get_template_subscription_ui_data()
	var/data = list()

	data["available_subscription_name"] = src.subscription_name
	data["description"] = src.description
	data["cost"] = src.cost
	data["interval"] = src.interval
	data["provider"] = "Нет доступа"
	data["secure"] = src.secure
	data["subscription_type"] = src.subscription_type_path
	data["uid"] = src.UID()

	return data
