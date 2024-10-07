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
	var/datum/money_account/base_account 	= null //the account that receives money for orders and vending machines
	var/datum/money_account/payment_account = null //The account from which the salary is deducted badguy

	//Attention. Statistics for greentext
	//And why did I make tabs?...
	var/total_salary_payment = 0 	//How much money was spent on salaries
	var/total_station_bounty = 0 	//How much money did the money from the cargo bring to the station account
	var/total_cargo_bounty 	= 0 	//How much money was credited to the cargo account from the tasks
	var/total_personal_bounty = 0 	//How much money was distributed to the beggars
	var/income_vedromat = 0 		//Income from vending machines
	var/default_counter = 0 		//The counter for the number of defaults, I definitely won't make a joke

	var/list/complited_goals = list() 	//It is necessary not to pay again for the goal, gagaga
	var/default_status = FALSE 			//TRUE if the default is in effect at the station, you can do it in the future, for example, as a cargo modifier
	
/datum/controller/subsystem/capitalism/Initialize()
	accounts_init()
	salary_account_init()
	return SS_INIT_SUCCESS

/datum/controller/subsystem/capitalism/fire()

	//if(default_counter > 300)
	//	GLOB.priority_announcement.Announce("Станция признана убыточным объектом. Хорошего дня.", "Расторжение контрактов.", 'sound/AI/commandreport.ogg')
	//	set_security_level(SEC_LEVEL_EPSILON)

	//If there is enough money to pay salaries at least twice before the default is lifted
	if(default_status && (payment_account.money > (potential_salary_payments() + EXTRA_MONEY)))
		default_status = FALSE
		default_annonce()
		payment_process() //Pay the beggars immediately after the announcement
	else if(!payment_process() && !default_status)
		default_status = TRUE
		default_annonce()

	var/total_station_goal_bounty = 0
	var/s_ex_personal_bounry = list() //Extended staff rewards
	//personal_reward
	for(var/datum/station_goal/goal in SSticker.mode.station_goals)
		if(!goal)
			continue
		if(goal.check_completion() && !(goal in complited_goals))
			total_station_goal_bounty += goal.station_bounty
			for(var/prom in goal.personal_reward)
				if(s_ex_personal_bounry?[prom])
					s_ex_personal_bounry[prom] += goal.personal_reward[prom]
				else
					s_ex_personal_bounry[prom] = goal.personal_reward[prom]
			complited_goals += goal

	if(total_station_goal_bounty)
		base_account.credit(total_station_goal_bounty, "Начисление награды за выполнение цели.", "Отдел развития Нанотрейзен", base_account.owner_name)
		smart_job_payment(s_ex_personal_bounry)

//status - TRUE/FALSE
/datum/controller/subsystem/capitalism/proc/default_annonce()
	if(default_status)
		GLOB.priority_announcement.Announce("Внимание на счёте станции зафиксировано отсутствие финансов. Выплаты заработных плат заморожены. Командному составу необходимо немедленно решить возникший кризис", "Дефолт станции", 'sound/AI/commandreport.ogg')
	else
		GLOB.priority_announcement.Announce("Внимание на счёте станции достаточно средств для выплат. Выплаты заработных плат возобновлены.", "Возобновление выплат", 'sound/AI/commandreport.ogg')

/datum/controller/subsystem/capitalism/proc/potential_salary_payments()
	var/total_salary = 0
	for(var/datum/money_account/account in GLOB.all_money_accounts)
		if(account.salary_payment_active && account.linked_job.salary && !account.suspended)
			total_salary += account.linked_job.salary
	return total_salary

/datum/controller/subsystem/capitalism/proc/accounts_init()
	if(!GLOB.CC_account)
		create_CC_account()

	if(!GLOB.station_account)
		create_station_account()

	if(GLOB.department_accounts.len == 0)
		for(var/department in GLOB.station_departments)
			create_department_account(department)

/datum/controller/subsystem/capitalism/proc/salary_account_init()
	base_account = GLOB.station_account		//The account that the bounty goes to, the money for the goal and the money from the machines.
	payment_account = GLOB.CC_account 	//GLOB.CC_account 	//This is the account from which money is debited for salary. Made for catsmile tests

	if(!GLOB.vendor_account)
		GLOB.vendor_account = base_account //:catsmile:

/datum/controller/subsystem/capitalism/proc/payment_process()
	. = TRUE
	for(var/datum/money_account/account in GLOB.all_money_accounts)
		if(account.salary_payment_active && account.linked_job.salary && !account.suspended)
			if(payment_account.charge(account.linked_job.salary, account, "Выплата зарплаты персоналу.", "Nanotrasen personal departament" , "Поступление зарплаты.", "Поступление зарплаты" ,"Biesel TCD Terminal #[rand(111,333)]"))
				account.notify_pda_owner("<b>Поступление зарплаты </b>\"На ваш привязанный аккаунт поступило [account.linked_job.salary] кредитов\" (Невозможно Ответить)", FALSE)
				total_salary_payment += account.linked_job.salary
			else
				return FALSE

/datum/controller/subsystem/capitalism/proc/smart_bounty_payment(var/list/jobs_payment, var/money)
	. = FALSE //If nothing is paid to anyone
	var/list_payment_account = list() //which people should I pay
	var/bounty = 0 //What kind of money for each person
	total_personal_bounty += money
	for(var/datum/money_account/account in GLOB.all_money_accounts)
		if(jobs_payment.Find(account.linked_job.title) && account.salary_payment_active && !account.suspended)
			list_payment_account += account
			. = TRUE

	if(money == 0 || length(list_payment_account) == 0)
		return FALSE
	bounty = round(money / length(list_payment_account))
	for(var/datum/money_account/account in list_payment_account)
		//It may be worth doing a type from the customer's company... But I'm too lazy
		if(account.credit(bounty, "Начисление награды за выполнение заказа.", "Biesel TCD Terminal #[rand(111,333)]", account.owner_name))
			account.notify_pda_owner("<b>Поступление награды </b>\"На ваш привязанный аккаунт поступило [bounty] кредитов за помощь в выполнении заказа.\" (Невозможно Ответить)", FALSE)
	return

/datum/controller/subsystem/capitalism/proc/smart_job_payment(var/list/jobs_payment)
	. = FALSE //If nothing is paid to anyone
	for(var/datum/money_account/account in GLOB.all_money_accounts)
		if(jobs_payment?[account.linked_job.title] && account.salary_payment_active && !account.suspended)
			if(account.credit(jobs_payment[account.linked_job.title], "Начисление награды за выполнение цели.", "Biesel TCD Terminal #[rand(111,333)]", account.owner_name))
				total_personal_bounty += jobs_payment[account.linked_job.title]
				account.notify_pda_owner("<b>Поступление награды </b>\"На ваш привязанный аккаунт поступило [jobs_payment[account.linked_job.title]] кредитов за помощь в выполнении цель станции.\" (Невозможно Ответить)", FALSE)
				. = TRUE
	return

// In short, as for beggars, but for departments
/datum/controller/subsystem/capitalism/proc/smart_departament_payment(var/list/keys_departament, var/money)
	. = FALSE 							//If nothing is paid to anyone
	var/list_payment_account = list() 	//which people should I pay
	var/bounty = 0 						//What kind of money for each department
	total_personal_bounty += money
	var/datum/money_account/account = base_account

	for(var/key_account_departament in  keys_departament)
		account = GLOB.department_accounts?[key_account_departament]
		if(!account)
			list_payment_account += account
			. = TRUE

	if(!length(list_payment_account))
		base_account.credit(bounty, "Начисление награды за выполнение заказа.", "Biesel TCD Terminal #[rand(111,333)]", account.owner_name)
		return TRUE

	bounty = round(money / length(list_payment_account))
	//If it did not find that, the payment of the station (well, or what is indicated in the base_account)
	for(var/datum/money_account/account_pay in list_payment_account)
		account_pay.credit(bounty, "Начисление награды за выполнение заказа.", "Biesel TCD Terminal #[rand(111,333)]", account.owner_name)
	return
