#define FREQUENCY_SALARY 5 MINUTES
#define EXTRA_MONEY 10000 //Хз честно как иначе назвать roflcat

SUBSYSTEM_DEF(capitalism)
	name = "Capitalism"
	ss_id = "capitalism_subsystem"
	init_order =  INIT_ORDER_CAPITALISM
	offline_implications = "Выплаты зарплат приостановлены, по идеи выплаты за задания карго не сломаются. Награда за цель не выплачивается. Немедленных действий не требуется."
	runlevels = RUNLEVEL_GAME
	wait = FREQUENCY_SALARY
	flags = SS_BACKGROUND

	//Такое разделение нужно для тестов и вобще чтоб приятно было
	var/datum/money_account/base_account 	= null //аккаунт на который идут ништяки с карго и ведроматики
	var/datum/money_account/payment_account = null //Аккаунт с которого списывается зарплата badguy


	//ВНИМАНИЕ. Статистика для гринтекста
	//А зачем я табы сделал....
	var/total_salary_payment 	= 0 //Сколько денег пошло на зарплаты
	var/total_station_bounty 	= 0 //Сколько денег принесли деньги с карго на счет станции
	var/total_cargo_bounty 		= 0 //Сколько денег попало на счет карго с заданий
	var/total_personal_bounty 	= 0 //Сколько денег было раздано нищебродам
	var/income_vedromat 		= 0 //Доходы с ведроматов

	var/list/complited_goals = list() 	//Нужно чтобы не платить повторно за цель, гагага
	var/default_status = FALSE 			//TRUE если на станции действует дефолт, можно в будущем к примеру как модификатор карго сделать

	var/default_counter = 0 		//Счетсчик количества дефолтов, я точно не сделаю смешнявку

/datum/controller/subsystem/capitalism/Initialize()
	//Бесмысленные и беспощадные иницилизации.
	accounts_init()
	salary_account_init()

	return SS_INIT_SUCCESS //Хз как ошибка может произойти

/datum/controller/subsystem/capitalism/fire()

	if(default_counter > 300)
		GLOB.priority_announcement.Announce("Станция признана убыточным объектом. Хорошего дня.", "Расторжение контрактов.", 'sound/AI/commandreport.ogg')
		set_security_level(SEC_LEVEL_EPSILON)

	//Если денег хватит оплатить зарплаты минимум два раза до дефолт снят
	if(default_status && (payment_account.money > (potential_salary_payments() + EXTRA_MONEY)))
		default_status = FALSE
		default_annonce(default_status)
		payment_process() //Выплатить нищебродам сразу после объявления
	else if(!payment_process() && !default_status)
		default_status = TRUE
		default_annonce(default_status)

	var/total_station_goal_bounty = 0
	for(var/datum/station_goal/goal in SSticker.mode.station_goals)
		if(!goal)
			continue
		if(goal.check_completion() && !(goal in complited_goals))
			total_station_goal_bounty += goal.station_bounty
			complited_goals += goal

	if(total_station_goal_bounty)
		base_account.credit(total_station_goal_bounty, "Начисление награды за выполнение цели.", "Отдел развития Нанотрейзен", base_account.owner_name)

//status - TRUE/FALSE
/datum/controller/subsystem/capitalism/proc/default_annonce(var/status)
	if(status)
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

	base_account = GLOB.station_account		//Аккаунт на который идут баунти, деньги за цель и баблишко с ведроматов.
	payment_account = GLOB.CC_account 	//GLOB.CC_account 	//Это аккаунт с которого списываются деньги на зарплату. Сделано для тестов catsmile

	if(!GLOB.vendor_account)
		GLOB.vendor_account = base_account //:catsmile:

/datum/controller/subsystem/capitalism/proc/payment_process()
	. = TRUE

	for(var/datum/money_account/account in GLOB.all_money_accounts)

		if(account.salary_payment_active && account.linked_job.salary && !account.suspended)

			if(payment_account.charge(account.linked_job.salary, account, "Выплата зарплаты персоналу.", "Nanotrasen personal deportament" , payment_account.owner_name, payment_account.owner_name , payment_account.owner_name))

				account.notify_pda_owner("<b>Поступление зарплаты </b>\"На ваш привязанный аккаунт поступило [account.linked_job.salary] кредитов\" (Невозможно Ответить)", FALSE)
				total_salary_payment += account.linked_job.salary //Считаю тотальную зарплату нищебродов.

			else
				return FALSE

/datum/controller/subsystem/capitalism/proc/smart_bounty_payment(var/list/jobs_payment, var/money)
	. = FALSE //Если никому ничего не уплочено
	var/list_payment_account = list() //каким челикам платить
	var/bounty = 0 //Какую денежку каждому челику
	total_personal_bounty += money
	for(var/prom in jobs_payment)
		to_chat(world, prom)

	for(var/datum/money_account/account in GLOB.all_money_accounts)
		to_chat(world, account.owner_name)
		if(jobs_payment.Find(account.linked_job.title) && account.salary_payment_active && !account.suspended)
			list_payment_account += account
			. = TRUE

	
	if(money == 0 || length(list_payment_account) == 0)
		return FALSE
	bounty = round(money / length(list_payment_account))

	for(var/datum/money_account/account in list_payment_account)
		//Возможно стоит сделать типо с компании заказчика... но мне лень
		if(account.credit(bounty, "Начисление награды за выполнение заказа.", "Biesel TCD Terminal #[rand(111,333)]", account.owner_name))
			account.notify_pda_owner("<b>Поступление награды </b>\"На ваш привязанный аккаунт поступило [bounty] кредитов за помощь в выполнении заказа.\" (Невозможно Ответить)", FALSE)

	return

//Короче как для нищебродов но для отделов
/datum/controller/subsystem/capitalism/proc/smart_deportament_payment(var/list/keys_deportament, var/money)
	. = FALSE 							//Если никому ничего не уплочено
	var/list_payment_account = list() 	//каким челикам платить
	var/bounty = 0 						//Какую денежку каждому депортаменту
	total_personal_bounty += money

	var/datum/money_account/account = base_account

	for(var/key_account_deportament in keys_deportament)
		account = GLOB.department_accounts?[key_account_deportament]
		if(!account)
			list_payment_account += account
			. = TRUE

	if(!length(list_payment_account))
		base_account.credit(bounty, "Начисление награды за выполнение заказа.", "Biesel TCD Terminal #[rand(111,333)]", account.owner_name)
		return TRUE

	bounty = round(money / length(list_payment_account))
	//Если не нашло и то, выплата станции (ну или что указано в base_account)


	for(var/datum/money_account/account_pay in list_payment_account)
		//пупупу
		account_pay.credit(bounty, "Начисление награды за выполнение заказа.", "Biesel TCD Terminal #[rand(111,333)]", account.owner_name)

	return
