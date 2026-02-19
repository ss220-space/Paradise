#define FREQUENCY_SALARY 5 MINUTES
#define EXTRA_MONEY 10000

SUBSYSTEM_DEF(capitalism)
	name = "Capitalism"
	ss_id = "capitalism_subsystem"
	init_order =  INIT_ORDER_CAPITALISM
	offline_implications = "Выплаты зарплат приостановлены, по идее выплаты за задания карго не сломаются. Награда за цель не выплачивается. Немедленных действий не требуется."
	runlevels = RUNLEVEL_GAME
	wait = FREQUENCY_SALARY
	flags = SS_BACKGROUND

	//This separation is necessary for tests and in general so that it is pleasant
	var/datum/money_account/base_account	= null //the account that receives money for orders and vending machines
	var/datum/money_account/payment_account = null //The account from which the salary is deducted badguy

	//Attention. Statistics for greentext
	//And why did I make tabs?...
	var/total_salary_payment = 0	//How much money was spent on salaries
	var/total_station_bounty = 0	//How much money did the money from the cargo bring to the station account
	var/total_cargo_bounty	= 0	//How much money was credited to the cargo account from the tasks
	var/total_personal_bounty = 0	//How much money was distributed to the beggars
	var/income_vedromat = 0		//Income from vending machines
	var/default_counter = 0		//The counter for the number of defaults, I definitely won't make a joke

	var/list/completed_goals = list()	//It is necessary not to pay again for the goal, gagaga
	var/default_status = FALSE			//TRUE if the default is in effect at the station, you can do it in the future, for example, as a cargo modifier

/datum/controller/subsystem/capitalism/Initialize()
	accounts_init()
	salary_account_init()
	return SS_INIT_SUCCESS

/datum/controller/subsystem/capitalism/fire()
	//If there is enough money to pay salaries at least twice before the default is lifted
	if(default_status && (payment_account.money > (potential_salary_payments() + EXTRA_MONEY)))
		default_status = FALSE
		default_announce()
		payment_process() //Pay the beggars immediately after the announcement
	else if(!payment_process() && !default_status)
		default_status = TRUE
		default_announce()

	var/total_station_goal_bounty = 0
	var/list/s_ex_personal_bounty = list() //Extended staff rewards
	//personal_reward
	for(var/datum/station_goal/goal in SSticker.mode.station_goals)
		if(!goal)
			continue
		if(!goal.check_completion() || (goal in completed_goals))
			continue

		completed_goals += goal
		total_station_goal_bounty += goal.station_bounty
		for(var/prom in goal.personal_reward)
			if(s_ex_personal_bounty[prom])
				s_ex_personal_bounty[prom] += goal.personal_reward[prom]
			else
				s_ex_personal_bounty[prom] = goal.personal_reward[prom]

	if(total_station_goal_bounty)
		base_account.credit(total_station_goal_bounty, "Начисление награды за выполнение цели.", "Отдел развития \"Нанотрейзен\"", base_account.owner_name)
		smart_job_payment(s_ex_personal_bounty)

//status - TRUE/FALSE
/datum/controller/subsystem/capitalism/proc/default_announce()
	if(default_status)
		// Both announcements are Minor because it happens all the time, because the system of capitalism is shit.
		GLOB.minor_announcement.announce(
			message = "На счёте станции зафиксировано отсутствие финансовых средств. В связи с этим выплаты заработной платы были приостановлены. Руководству станции необходимо незамедлительно принять меры для разрешения сложившейся ситуации.",
			new_title = ANNOUNCE_CAPITAL_DEFOLT_RU,
			new_sound = 'sound/AI/commandreport.ogg'
		)
	else
		GLOB.minor_announcement.announce(
			message = "На счёте станции имеется достаточное количество средств для осуществления выплат. Заработная плата сотрудникам выплачивается в полном объёме.",
			new_title = ANNOUNCE_CAPITAL_REPAY_RU,
			new_sound = 'sound/AI/commandreport.ogg'
		)

/datum/controller/subsystem/capitalism/proc/potential_salary_payments()
	var/total_salary = 0
	for(var/datum/money_account/account as anything in GLOB.all_money_accounts)
		if(!account.salary_payment_active || !account.linked_job.paycheck || account.suspended)
			continue
		total_salary += account.linked_job.paycheck
	return total_salary

/datum/controller/subsystem/capitalism/proc/accounts_init()
	if(!GLOB.CC_account)
		create_CC_account()

	if(!GLOB.station_account)
		create_station_account()

	if(!length(GLOB.department_accounts))
		for(var/department in GLOB.station_departments)
			create_department_account(department)

/datum/controller/subsystem/capitalism/proc/salary_account_init()
	base_account = GLOB.station_account		//The account that the bounty goes to, the money for the goal and the money from the machines.
	payment_account = GLOB.station_account	//GLOB.CC_account	//This is the account from which money is debited for salary. Made for catsmile tests

	if(!GLOB.vendor_account)
		GLOB.vendor_account = base_account //:catsmile:

/datum/controller/subsystem/capitalism/proc/payment_process()
	. = TRUE
	var/list/to_be_paid_accounts = list()
	for(var/datum/money_account/account as anything in GLOB.all_money_accounts)
		if(!account.salary_payment_active || !account.linked_job.paycheck || account.suspended)
			continue
		to_be_paid_accounts[account] = TRUE

	while(length(to_be_paid_accounts))
		var/datum/money_account/account = to_be_paid_accounts[length(to_be_paid_accounts)]
		to_be_paid_accounts.len--
		if(!payment_account.charge(account.linked_job.paycheck, account, "Выплата зарплаты персоналу.", "Отдел финансов \"Нанотрейзен\"" , "Поступление зарплаты.", "Поступление зарплаты" ,"Терминал Бизель №[rand(111,333)]"))
			return FALSE // If we somehow failed the payment (likely to not enough money), immediately return
		account.notify_pda_owner("<b>Поступление зарплаты </b>\"На ваш привязанный аккаунт поступило [account.linked_job.paycheck] кредитов\" (Невозможно Ответить)", FALSE)
		total_salary_payment += account.linked_job.paycheck

/datum/controller/subsystem/capitalism/proc/smart_bounty_payment(list/jobs_payment, money)
	if(!length(jobs_payment) || !money)
		return FALSE

	var/list/list_payment_accounts = list()
	var/bounty
	total_personal_bounty += money
	for(var/datum/money_account/account as anything in GLOB.all_money_accounts)
		if(!jobs_payment.Find(account.linked_job.title) || !account.salary_payment_active || account.suspended)
			continue
		list_payment_accounts[account] = TRUE

	if(!length(list_payment_accounts))
		return FALSE

	. = TRUE
	bounty = floor(money / length(list_payment_accounts))
	while(length(list_payment_accounts))
		var/datum/money_account/account = list_payment_accounts[length(list_payment_accounts)]
		list_payment_accounts.len--
		if(account.credit(bounty, "Начисление награды за выполнение заказа.", "Терминал Бизель №[rand(111,333)]", account.owner_name))
			account.notify_pda_owner("<b>Поступление награды </b>\"На ваш привязанный аккаунт поступило [bounty] кредитов за помощь в выполнении заказа.\" (Невозможно Ответить)", FALSE)

/datum/controller/subsystem/capitalism/proc/smart_job_payment(list/jobs_payment)
	if(!length(jobs_payment))
		return FALSE

	. = FALSE //If nothing is paid to anyone
	for(var/datum/money_account/account as anything in GLOB.all_money_accounts)
		if(!jobs_payment[account.linked_job.title] || !account.salary_payment_active || account.suspended)
			continue
		if(!account.credit(jobs_payment[account.linked_job.title], "Начисление награды за выполнение цели.", "Терминал Бизель №[rand(111,333)]", account.owner_name))
			continue
		total_personal_bounty += jobs_payment[account.linked_job.title]
		account.notify_pda_owner("<b>Поступление награды </b>\"На ваш привязанный аккаунт поступило [jobs_payment[account.linked_job.title]] кредитов за помощь в выполнении цель станции.\" (Невозможно Ответить)", FALSE)
		. = TRUE

// In short, as for beggars, but for departments
/datum/controller/subsystem/capitalism/proc/smart_department_payment(list/keys_department, money)
	if(!length(keys_department) || !money)
		return FALSE

	var/list/list_payment_accounts = list()
	var/bounty
	total_personal_bounty += money

	for(var/key_account_department in keys_department)
		if(GLOB.department_accounts[key_account_department])
			list_payment_accounts[GLOB.department_accounts[key_account_department]] = TRUE

	if(!length(list_payment_accounts))
		bounty = money // We are paying only one account
		base_account.credit(bounty, "Начисление награды за выполнение заказа.", "Терминал Бизель №[rand(111,333)]", base_account.owner_name)
		return TRUE

	bounty = floor(money / length(list_payment_accounts))
	while(length(list_payment_accounts))
		var/datum/money_account/account = list_payment_accounts[length(list_payment_accounts)]
		list_payment_accounts.len--
		account.credit(bounty, "Начисление награды за выполнение заказа.", "Терминал Бизель №[rand(111,333)]", account.owner_name)
	return TRUE

#undef FREQUENCY_SALARY
#undef EXTRA_MONEY
