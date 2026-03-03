// class for subscription

/datum/subscription
	var/subscription_name = ""
	var/datum/money_account/subscriber_account
	var/datum/money_account/recipient_account //recipient (product owner)
	var/cost = 0

	// time logic
	var/interval = 0
	var/next_payment_time = 0
	var/creation_time = 0

	var/active = TRUE

/datum/subscription/New(subscriber, recipient, cost_val, interval_val, name_val)
	. = ..()
    subscriber_account = subscriber
    recipient_account = recipient
    cost = cost_val
    interval = interval_val
    subscription_name = name_val
    active = TRUE
	creation_time = world.time
	next_payment_time = world.time + interval

// protection
/datum/subscription/proc/can_process()
	var/result = TRUE

	if(subscriber_account.suspended || recipient_account.suspended || subscriber_account.money < cost)
		result = FALSE

	return result

/datum/subscription/proc/process_payment()
	// if inactive skip process
	if(!active)
		return
	// check can start and safe check for charge (he can joke)
	if(!can_process() || !subscriber_account.charge(cost, recipient_account, subscription_name, subscriber_account.owner_name, subscription_name, "Оплата подписки", "Терминал Raingor Interstellar Banking №[rand(111,333)]"))
		cancel()
	else
		next_payment_time = world.time + interval
		//pda
		subscriber_account.notify_pda_owner("<b>Подтверждение оплаты подписки</b>\"Оплата за услугу '[subscription_name]' ([cost] кредитов) успешно проведена. Следующее списание средств будет произведено в соответствии с тарифным планом.\" (Невозможно Ответить)", FALSE)
		recipient_account.notify_pda_owner("<b>Поступление средств от подписки</b>\"На ваш счёт зачислено [cost] кредитов в рамках подписки на услугу '[subscription_name]'.\" (Невозможно Ответить)", FALSE)

/datum/subscription/proc/cancel()
    subscriber_account.notify_pda_owner("<b>Уведомление об отмене подписки</b>\"Абонентская плата за услугу '[subscription_name]' ([cost] кредитов) не поступила. Подписка приостановлена.\" (Невозможно Ответить)", FALSE)
    // Notification to recipient (product owner)
    recipient_account.notify_pda_owner("<b>Прекращение действия подписки</b>\"Пользователь прекратил использование услуги '[subscription_name]'. Поступления платежей ([cost] кредитов) более не производятся.\" (Невозможно Ответить)", FALSE)

    active = FALSE

