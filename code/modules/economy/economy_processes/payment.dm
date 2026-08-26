/datum/economy_process/payment
	interval = SALARY_INTERVAL
	var/modifier = 1
	var/datum/money_account/source_account
	var/datum/money_account/target_account

/datum/economy_process/payment/initialize(datum/money_account/source_account, datum/money_account/target_account, modifier = 1)
	if(!istype(source_account) || !istype(target_account) || !modifier)
		return
	src.source_account = source_account
	src.target_account = target_account
	src.modifier = modifier
	return ..()

/datum/economy_process/payment/on_destroy()
	source_account = null
	target_account = null
	return ..()

/datum/economy_process/payment/custom_process()
	var/paycheck = target_account.linked_job?.paycheck
	if(!paycheck)
		return
	if(!SScapitalism.default_status && !source_account.charge(paycheck * modifier, target_account, "Выплата зарплаты персоналу.", "Отдел финансов \"Нанотрейзен\"", "Поступление зарплаты.", "Поступление зарплаты", "Терминал Бизель №[rand(111,333)]"))
		SScapitalism.default_status = TRUE
		SScapitalism.default_announce()
		return
	target_account.notify_pda_owner("<b>Поступление зарплаты </b>\"На ваш привязанный аккаунт поступило [paycheck] кредитов\" (Невозможно Ответить)", FALSE)
	SScapitalism.total_salary_payment += paycheck

